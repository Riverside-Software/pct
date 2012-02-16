/* ------------------------------------------------------------------------
   file    :  prolint/rules/sharelock.p
   by      :  Jurjen Dijkstra
   purpose :  search for statements where NO-LOCK or EXCLUSIVE-LOCK should 
              have been used to prevent an implicit SHARE-LOCK
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

RUN searchNode            (hTopnode,              /* "Program_root" node                 */
                           "InspectNode":U,       /* name of callback procedure          */
                           "FOR,FIND,OPEN,PRESELECT":U).    /* list of statements to search, ?=all */

RETURN.

FUNCTION IsPreselected RETURNS LOGICAL (INPUT theNode AS INTEGER, recordname AS CHARACTER) :

/*
  example:

  DO PRESELECT EACH customer NO-LOCK
               BREAK BY customer.city :
    FIND NEXT customer.
  END.

  in this example, FIND NEXT customer must be allowed.
*/

   DEFINE VARIABLE retval        AS LOGICAL NO-UNDO INITIAL FALSE.
   DEFINE VARIABLE statehead     AS INTEGER NO-UNDO.
   DEFINE VARIABLE stateheadtype AS CHARACTER NO-UNDO.
   DEFINE VARIABLE child         AS INTEGER NO-UNDO.
   DEFINE VARIABLE childtype     AS CHARACTER NO-UNDO.

   IF parserGetNodeType(theNode)="PRESELECT":U THEN
      RETURN FALSE.

   statehead = parserGetHandle().
   child     = parserGetHandle().
   stateheadtype = parserNodeStateHead(theNode, statehead).
   DO WHILE NOT (retval=TRUE OR stateheadtype="" OR stateheadtype="FUNCTION":U OR stateheadtype="PROCEDURE":U) :
      IF stateheadtype="DO":U OR stateheadtype="REPEAT":U THEN
         IF parserNodeFirstChild(statehead,child) = "PRESELECT":U THEN DO:
            childtype = parserNodeFirstChild(child,child).
            DO WHILE childtype<>"" :
               IF childtype="RECORD_NAME":U THEN
                  IF parserGetNodeText(child)=recordname THEN
                     retval = TRUE.
               childtype = parserNodeNextSibling(child,child).
            END.
         END.
      stateheadtype = parserNodeStateHead(statehead, statehead).
   END.
   parserReleaseHandle(child).
   parserReleaseHandle(statehead).
   RETURN retval.
END FUNCTION.


PROCEDURE InspectNode :             
  /* purpose : callback from searchNode. Inspect the node found by searchNode */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO.
  
  DEFINE VARIABLE child       AS INTEGER   NO-UNDO.
  DEFINE VARIABLE child2      AS INTEGER   NO-UNDO.
  DEFINE VARIABLE havelock    AS LOGICAL   NO-UNDO INITIAL FALSE.
  DEFINE VARIABLE childtype   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE childtype2  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE nodetype    AS CHARACTER NO-UNDO.
  DEFINE VARIABLE recordname  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE temptable   AS LOGICAL   NO-UNDO INITIAL FALSE.
                         
  ASSIGN
    SearchChildren = parserGetNodeType(theNode)="FOR":U /* only FOR can be a nested block */
    child          = parserGetHandle()
    nodetype       = parserGetNodeType(theNode).

  /* ignore FOR in strong scoped block, like "DO FOR buffername" and REPEAT FOR buffername */
  IF nodetype="FOR":U THEN
     IF parserNodeParent(theNode, child) = "DO":U OR parserNodeParent(theNode, child) = "REPEAT":U THEN DO:
        parserReleaseHandle(child).
        RETURN.
     END.
  /* FOR can also be an argument in a COPY-LOB statement */
  IF nodetype="FOR":U THEN
     IF parserNodeStateHead(theNode, child) = "COPYLOB":U THEN DO:
        parserReleaseHandle(child).
        RETURN.
     END.

  ASSIGN
    child2         = parserGetHandle()
    childtype      = parserNodeFirstChild(theNode,child).
    
  IF childtype="" THEN DO:
     parserReleaseHandle(child).
     parserReleaseHandle(child2).
     RETURN.
  END.  
                                                               
  IF nodetype="OPEN":U THEN DO:
     IF childtype="QUERY":U THEN
        nodetype = "OPEN QUERY":U.
     ELSE DO:
        parserReleaseHandle(child).
        parserReleaseHandle(child2).
        RETURN.
     END.
  END.
    
  DO WHILE childtype<>"" :     

    CASE childtype :
       WHEN "RECORD_NAME":U   THEN IF recordname="":U THEN DO:
                                      ASSIGN recordname = parserGetNodeText(child)
                                             temptable  = parserAttrGet(child,"storetype":U)="st-ttable":U OR parserAttrGet(child,"storetype":U)="st-wtable":U
                                             childtype2 = parserNodeFirstChild(child,child2).
                                      recordphrase-loop:
                                      DO WHILE childtype2<>"" :
                                         CASE childtype2 :
                                            WHEN "NOLOCK":U OR WHEN "EXCLUSIVELOCK":U THEN DO:
                                               ASSIGN havelock = TRUE.
                                               LEAVE recordphrase-loop.
                                            END.
                                         END CASE.
                                         ASSIGN childtype2 = parserNodeNextSibling(child2,child2).
                                      END.
                                   END.
                                   
       WHEN "COMMA":U         THEN DO: /* a join contains a COMMA. 
                                          The joined part (after the comma) must also 
                                          have an explicit lock. So when we see a comma we 
                                          can start over again */
                                       IF (NOT havelock) AND (NOT temptable) THEN
                                          RUN WriteResult (theNode, nodetype, recordname).
                                       ASSIGN havelock   = FALSE
                                              recordname = ""
                                              temptable  = FALSE.
                                   END.
    END CASE.

    ASSIGN childtype = parserNodeNextSibling(child,child).
  END.      

  IF (NOT havelock) AND (NOT temptable) THEN
    IF NOT IsPreselected (theNode, recordname) THEN
      RUN WriteResult (theNode, nodetype, recordname).
         
  parserReleaseHandle(child).
  parserReleaseHandle(child2).
    
END PROCEDURE.                            


PROCEDURE WriteResult :
  /* purpose : send warning to the outputhandlers(s) */
  DEFINE INPUT PARAMETER theNode    AS INTEGER   NO-UNDO.
  DEFINE INPUT PARAMETER nodetype   AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER recordname AS CHARACTER NO-UNDO.
  
    RUN PublishResult            (compilationunit,
                                  parserGetNodeFilename(theNode),
                                  parserGetNodeLine(theNode), 
                                  SUBSTITUTE("&1 &2 has no NO-LOCK / EXCLUSIVE-LOCK":T, nodetype, recordname),
                                  rule_id).
END PROCEDURE.
