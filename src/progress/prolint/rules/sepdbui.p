/* ------------------------------------------------------------------------
   file    :  prolint/rules/sepdbui.p
   by      :  Jurjen
   purpose :  a single procedure should not mix database access and 
              User Interface, enforce separation of tiers
    -----------------------------------------------------------------

    Copyright (C) 2001,2002 Jurjen Dijkstra

    This file is part of Prolint.

    Prolint is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    Prolint is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Prolint; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
   ------------------------------------------------------------------------ */
  
{prolint/core/ruleparams.i}  

/* in which line is database accessed? */                                                
DEFINE VARIABLE lineDbAccess AS INTEGER   NO-UNDO INITIAL 0.
DEFINE VARIABLE fileDbAccess AS CHARACTER NO-UNDO INITIAL "".
/* in which line is a User Interface statement? */                                                
DEFINE VARIABLE lineUiAccess AS INTEGER   NO-UNDO INITIAL 0.
DEFINE VARIABLE fileUiAccess AS CHARACTER NO-UNDO INITIAL "".
           
DEFINE VARIABLE tempNode     AS INTEGER   NO-UNDO.

tempNode = parserGetHandle().
                                                                          
RUN FindDatabaseAccess.
IF fileDbAccess NE "" THEN
   RUN FindUserInterface.
                           
parserReleaseHandle(tempNode).

IF (fileDbAccess NE "") AND (fileUiAccess NE "") THEN 
    RUN PublishResult            (compilationunit,
                                  fileDbAccess,
                                  lineDbAccess, 
                                  SUBSTITUTE("Separate UI from DB-access (UI in line &2 of &1)":T, fileUIAccess, STRING(lineUIAccess)),
                                  rule_id).


RETURN.


PROCEDURE FindDatabaseAccess :
/* purpose: do a quick scan for the first RECORD_NAME node which is not referencing a temp-table */
   
   RUN searchNode            (hTopnode,            /* "Program_root" node                 */
                              "FoundRecordName":U, /* name of callback procedure          */
                              "RECORD_NAME":U).    /* list of statements to search, ?=all */
END PROCEDURE.


PROCEDURE FindUserInterface :
/* purpose: do a quick scan for the first nodetype that indentifies a User Interface statement */
   DEFINE VARIABLE lstKeywords  AS CHARACTER NO-UNDO.
   DEFINE VARIABLE i            AS INTEGER   NO-UNDO.
   
   lstKeywords = "MESSAGE,VIEWAS,BUTTON,FILLIN,EDITOR,RADIOSET,BROWSE,TOGGLEBOX,WINDOW,FRAME,Form_item,APPLY,DISPLAY,ENABLE,DISABLE":U.
   /* it would be faster to simply open a query and see if numresults > 0
      but that would ignore &_proparse_ prolint-nowarn(sepdbui)  */
   DO i=1 TO NUM-ENTRIES(lstKeywords) :
      IF fileUiAccess EQ "" THEN 
         RUN searchNode            (hTopnode,             /* "Program_root" node                 */
                                    "FoundUIStatement":U, /* name of callback procedure          */
                                    ENTRY(i,lstKeywords)).
   END.                              

   /* step 2: look for attributes like VISIBLE, SENSITIVE, X, Y, ROW, COLUMN, HEIGHT, WIDTH, SCREEN-VALUE, .... */
   /* this will not work very well if programmer abbreviated those attribute names */
   /* be carefull not to report on properties for dynamic query-objects, XML-files etc */
   IF fileUiAccess EQ "" THEN 
      RUN searchNode            (hTopnode,          /* "Program_root" node                 */
                                 "FoundObjColon":U, /* name of callback procedure          */
                                 "OBJCOLON":U).
END PROCEDURE.
             
                                     
PROCEDURE FoundRecordName :
/* purpose: found nodetype RECORD_NAME in sourcefile, check if it refers to a database record */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO.

  /* ignore  "DEFINE .... LIKE */
  IF parserNodeParent(theNode, tempnode)="LIKE":U AND
     parserNodeParent(tempnode, tempnode)="DEFINE":U THEN
     RETURN.

  /* attribute "storetype" returns "st-ttable" if it's a temp-table or a buffer for a temp-table. */                                                                  
  IF parserAttrGet(theNode,"storetype":U) = "st-dbtable":U THEN DO: 
     AbortSearch = TRUE.
     RUN GetFilePosition            (theNode, OUTPUT lineDbAccess, OUTPUT fileDbAccess).
  END.
  
END PROCEDURE.


PROCEDURE FoundUiStatement :
/* purpose: found a nodetype for User Interface */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL YES.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO.

  RUN GetFilePosition            (theNode, OUTPUT lineUiAccess, OUTPUT fileUiAccess).
  AbortSearch = TRUE.
  
END PROCEDURE.

                                                                          
PROCEDURE FoundObjColon :
/* purpose: found a handle:property or handle:method. Try to recognize the name of the property/method
            to decide if the handle is a UI widget.
            The property/method name is the node immediately following OBJCOLON. */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO.

  parserNodeNextSibling(theNode, tempNode).

  IF LOOKUP(parserGetNodeText(tempNode),"VISIBLE,SENSITIVE,X,Y,ROW,COL,COLUMN,HEIGHT,HEIGHT-PIXELS,WIDTH,WIDTH-PIXELS,SCREEN-VALUE":U) GT 0 THEN DO:
     RUN GetFilePosition            (theNode, OUTPUT lineUiAccess, OUTPUT fileUiAccess).
     AbortSearch = YES.
  END.
  
END PROCEDURE.

