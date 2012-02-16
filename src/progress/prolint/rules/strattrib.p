/* -------------------------------------------------------------------------
   file    :  prolint/rules/strattrib.p
   by      :  Jurjen Dijkstra
   purpose :  find strings without string attributes like "hello":U.
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
   ------------------------------------------------------------------------- */
  
{prolint/core/ruleparams.i}  

DEFINE VARIABLE IgnoreAppbuilderstuff AS LOGICAL NO-UNDO.

IgnoreAppbuilderstuff = LOGICAL ( DYNAMIC-FUNCTION ("ProlintProperty", "filters.IgnoreAppbuilderstuff")).

RUN IgnoreMenus.

RUN searchNode            (hTopnode,              /* "Program_root" node                 */
                           "InspectNode":U,       /* name of callback procedure          */
                           "QSTRING":U).          /* list of statements to search, ?=all */

RETURN.
                                                
                                                
PROCEDURE IgnoreMenus :
  /* purpose : workaround a bug in UIB/AppBuilder...
               if you create a menu using the menu-editor and specify string attributes, 
               then the menu will not be displayed in the Design window.
               The workaround is: simply don't use string attributes in menus.
               But then we have to learn this rule how to ignore menu-items and sub-menus */    
               
  DEFINE VARIABLE numResults AS INTEGER NO-UNDO EXTENT 3.
  DEFINE VARIABLE i          AS INTEGER NO-UNDO EXTENT 3.
  DEFINE VARIABLE node       AS INTEGER NO-UNDO EXTENT 3.
  
  node[1] = parserGetHandle().                      
  node[2] = parserGetHandle().                      
  node[3] = parserGetHandle().                      
              
  /* what the # is going on here...
     Appbuilder does not behave nice if you put attributes on menu-items!!
      - open query for each SUBMENU, each LABEL of SUBMENU, each QSTRING of LABEL.
      - set the pragma attribute on those labels.
      - open query for each MENUITEM, each LABEL of MENUITEM, each QSTRING of LABEL.
      - set the pragma attribute on those labels too. */
                 
  numResults[1] = parserQueryCreate(hTopnode, "submenu":U, "SUBMENU":U).
  DO i[1]=1 TO numResults[1] :
     IF parserQueryGetResult("submenu":U, i[1], node[1]) THEN DO:
        numResults[2] = parserQueryCreate(node[1], "label":U, "LABEL":U).
        DO i[2]=1 TO numResults[2] :
           IF parserQueryGetResult("label":U, i[2], node[2]) THEN DO:
              numResults[3] = parserQueryCreate(node[2], "qstring":U, "QSTRING":U).
              DO i[3]=1 TO numResults[3] :
                 IF parserQueryGetResult("qstring":U, i[3], node[3]) THEN
                    parserAttrSet(node[3],pragma_number,1).
              END.
              parserQueryClear("qstring":U).
           END.
        END.
        parserQueryClear("label":U).
     END.
  END.
  parserQueryClear("submenu":U).

  numResults[1] = parserQueryCreate(hTopnode, "menuitem":U, "MENUITEM":U).
  DO i[1]=1 TO numResults[1] :
     IF parserQueryGetResult("menuitem":U, i[1], node[1]) THEN DO:
        numResults[2] = parserQueryCreate(node[1], "label":U, "LABEL":U).
        DO i[2]=1 TO numResults[2] :
           IF parserQueryGetResult("label":U, i[2], node[2]) THEN DO:
              numResults[3] = parserQueryCreate(node[2], "qstring":U, "QSTRING":U).
              DO i[3]=1 TO numResults[3] :
                 IF parserQueryGetResult("qstring":U, i[3], node[3]) THEN
                    parserAttrSet(node[3],pragma_number,1).
              END.
              parserQueryClear("qstring":U).
           END.
        END.
        parserQueryClear("label":U).
     END.
  END.
  parserQueryClear("menuitem":U).

  
  parserReleaseHandle(node[3]).  
  parserReleaseHandle(node[2]).  
  parserReleaseHandle(node[1]).  

END PROCEDURE.                
                           
PROCEDURE InspectNode :             
  /* purpose: callback from searchNode.
              inspect the QSTRING node */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO.
  
  DEFINE VARIABLE thestring   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE quote       AS CHARACTER NO-UNDO.
  DEFINE VARIABLE attrib      AS CHARACTER NO-UNDO.
  DEFINE VARIABLE attJustif   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE attLength   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE i           AS INTEGER   NO-UNDO.
                         
  ASSIGN 
    theString = parserGetNodeText(theNode)
    quote     = SUBSTRING(theString,1,1)
    attrib    = SUBSTRING(theString, R-INDEX(theString,quote) + 2).

  /* empty strings like "" or '' are not listed in XREF, no matter if they have string attributes */
  IF LENGTH(SUBSTRING(theString,2,R-INDEX(theString,quote) - 2),"RAW":U)=0 THEN 
     RETURN.

  IF IgnoreAppbuilderstuff THEN
    /* ignore strings in read-only sections created by AppBuilder: */
    IF (theString='"The binary control file could not be found. The controls cannot be loaded."':U
             OR 
        theString='"Controls Not Loaded"':U) 
    THEN RETURN.

  /* attribute can be made up of two parts:
     attJustif - alpha.characters specifying the justification  (:L :T :R :C)
     attLength - integer specifying the size of tha string */

  DO i=1 TO LENGTH(attrib) :
     IF SUBSTRING(attrib,i,1)>="0":U AND SUBSTRING(attrib,i,1)<="9":U THEN
        attLength = attLength + SUBSTRING(attrib,i,1).
     ELSE
        attJustif = attJustif + SUBSTRING(attrib,i,1).
  END.

  /* make sure the warning isn't extremely long (but what is extreme?) */
  &SCOPED-DEFINE maxlen 30
  IF LENGTH(theString)>{&maxlen} THEN DO:
     theString = quote + SUBSTRING(theString,2,{&maxlen} - 5) + "...":U + quote + attrib.
  END.

  /* skip annotations, because they dont affect run-time */
  define variable statehead as integer no-undo.
  statehead  = parserGetHandle().
  IF parserNodeStateHead(theNode, statehead) = "ANNOTATION":U THEN DO:
     parserReleaseHandle(statehead).
     RETURN.
  END.
  parserReleaseHandle(statehead).
  

  /* trouble in outputhandlers if the string spans a linefeed */
  theString=REPLACE(theString, "~n":U, " ":U).

  IF attrib="" THEN          
     RUN PublishResult            (compilationunit,
                                   parserGetNodeFilename(theNode),
                                   parserGetNodeLine(theNode), 
                                   SUBSTITUTE("no string attributes on &1":T, theString),
                                   rule_id).
  ELSE                       
  /* in our company we prefer to accept only :U or :T */
  IF NOT (attJustif="U":U OR attJustif="T":U) THEN
     RUN PublishResult            (compilationunit,
                                   parserGetNodeFilename(theNode),
                                   parserGetNodeLine(theNode), 
                                   SUBSTITUTE("wrong string attributes on &1":T, theString),
                                   rule_id).
    
END PROCEDURE.                            
