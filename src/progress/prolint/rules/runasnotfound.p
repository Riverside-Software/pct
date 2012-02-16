/* ------------------------------------------------------------------------
   file    :  prolint/rules/runasnotfound.p
   by      :  Jurjen Dijkstra
   purpose :  find RUN statements like "RUN dir/name.p ON SERVER" and see if the name
              of the external procedure can be found
              (trying to prevent runtime error 293)
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
{prolint/core/ttprocedure.i}
           

FUNCTION WithoutQuotes RETURNS CHARACTER (qstring AS CHARACTER) FORWARD.

RUN searchNode            (hTopnode,                /* "Program_root" node          */
                           "InspectNode":U,         /* name of callback procedure   */
                           "RUN":U).                /* list of statements to search */

RETURN.


PROCEDURE InspectNode :
/* InspectNode is where the actual rule is implemented.
   it is called from SearchNode in ruledefs.i */                                                    
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO.
                             
  DEFINE VARIABLE child            AS INTEGER NO-UNDO.
  DEFINE VARIABLE grandchild       AS INTEGER NO-UNDO.
  DEFINE VARIABLE nodetype         AS CHARACTER NO-UNDO.
  DEFINE VARIABLE progname         AS CHARACTER NO-UNDO INITIAL "".
  DEFINE VARIABLE AppsHandleName   AS CHARACTER NO-UNDO INITIAL "".
  DEFINE VARIABLE found_on         AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE VARIABLE irtb             AS INTEGER NO-UNDO INITIAL 0.

  ASSIGN
    SearchChildren = FALSE  /* a RUN statement can not contain other RUN statements */
    child          = parserGetHandle()
    grandchild     = parserGetHandle()
    nodetype       = parserNodeFirstChild(theNode,child).
                      
  /* not every RUN node has children, for example ON "CHOOSE" PERSISTENT RUN ip IN THIS-PROCEDURE" */
  IF nodetype<>"" THEN DO:

     CASE nodetype :
        WHEN "FILENAME":U THEN progname = parserGetNodeText(child).
        WHEN "ID":U       THEN progname = parserGetNodeText(child).
     END CASE.

     IF progname<>"" THEN
        IF CAN-DO("',~"":U, SUBSTRING(progname,1,1)) THEN
           progname = WithoutQuotes(progname).
     
     /* roundtable XREF generator adds a signature to the filename. Remove it: */
     irtb = INDEX (progname, "*RTB-smObj*":U).
     IF irtb>0 THEN DO:
        SUBSTRING(progname, irtb, 11) = "".
        progname = TRIM(progname).
     END.

     /*  check for option "ON [SERVER] <AppsHandleName>" */
     nodetype = parserNodeNextSibling(child,child).
     DO WHILE nodetype<>"" :
        CASE nodetype :
           WHEN "ON":U  THEN
               DO:
                  found_on = TRUE.
                  /* we also want to know the name of the server handle.. */
                  nodetype  = parserNodeFirstChild(child,grandchild).
                  DO WHILE nodetype<>"":U :
                     IF nodetype="Field_ref":U THEN
                        AppsHandleName = GetFieldnameFromFieldref ( grandchild ).
                     nodetype = parserNodeNextSibling(grandchild,grandchild).
                  END.
               END.
        END CASE.
        nodetype = parserNodeNextSibling(child,child).
     END.

     IF found_on AND progname<>"" THEN
        IF SEARCH ( progname ) = ? THEN
           RUN PublishResult            ( compilationunit,
                                          parserGetNodeFilename( theNode ),
                                          parserGetNodeLine( theNode ),
                                          SUBSTITUTE( "proc '&1' not found on &2":T, progname, AppsHandleName ),
                                          rule_id ).
  END.

  parserReleaseHandle(child).
  parserReleaseHandle(grandchild).
    
END PROCEDURE.                            


FUNCTION WithoutQuotes RETURNS CHARACTER (qstring AS CHARACTER) :
  /* purpose: remove the quotes from nodetext "test" or 'test'. */
  DEFINE VARIABLE quote AS CHARACTER NO-UNDO.
  
  quote = SUBSTRING(qstring,1,1). 
  RETURN SUBSTRING(qstring,2,R-INDEX(qstring,quote) - 2).
  
END FUNCTION.



