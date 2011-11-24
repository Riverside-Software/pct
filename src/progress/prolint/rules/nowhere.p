/* ------------------------------------------------------------------------
   file    :  prolint/rules/nowhere.p
   by      :  Jurjen Dijkstra
   purpose :  search for queries without WHERE-clause.
              (is somewhat similar to WHOLE-INDEX).
   note       the source for this rule is almost identical to 'sharelock.p'
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

RUN searchNodeQueries            (hTopnode,              /* "Program_root" node                 */
                                  "InspectNode":U,       /* name of callback procedure          */
                                  "FOR,FIND,OPEN":U).    /* list of statements to search, ?=all */

/* TODO: check if CAN-DO functions and PRESELECT statements also have a WHERE-clause */

RETURN.

                           
PROCEDURE InspectNode :             
  /* purpose : callback from searchNode. Inspect the node found by searchNode */

  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO.
  
  DEFINE VARIABLE child       AS INTEGER   NO-UNDO.
  DEFINE VARIABLE child2      AS INTEGER   NO-UNDO.
  DEFINE VARIABLE havewhere   AS LOGICAL   NO-UNDO INITIAL FALSE.
  DEFINE VARIABLE childtype   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE childtype2  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE nodetype    AS CHARACTER NO-UNDO.
  DEFINE VARIABLE recordname  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE temptable   AS LOGICAL   NO-UNDO INITIAL FALSE.

  ASSIGN
    nodetype       = parserGetNodeType(theNode)
    SearchChildren = nodetype="FOR":U /* only FOR can be a nested block */
    child          = parserGetHandle().

  /* ignore FOR in strong scoped block, like "DO FOR buffername" */
  IF nodetype="FOR":U THEN
     IF parserNodeParent(theNode, child) = "DO":U THEN DO:
        parserReleaseHandle(child).
        RETURN.
     END.
  /* FOR can also be an argument in a COPY-LOB statement */
  IF nodetype="FOR":U THEN
     IF parserNodeStateHead(theNode, child) = "COPYLOB":U THEN DO:
        parserReleaseHandle(child).
        RETURN.
     END.

  childtype      = parserNodeFirstChild(theNode,child).
    
  IF childtype="" THEN DO:
     parserReleaseHandle(child).
     RETURN.
  END.

  child2         = parserGetHandle().
  
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
       /* RECORD_NAME is the root to its record phrase, if any. Check its children for WHERE. */
       WHEN "RECORD_NAME":U   THEN DO:
                                      ASSIGN recordname = parserGetNodeText(child)
                                             temptable  = parserAttrGet(child,"storetype":U) = "st-ttable":U
                                             childtype2 = parserNodeFirstChild(child,child2).
                                      recordphrase-loop:
                                      DO WHILE childtype2<>"" :
                                         IF (childtype2 = "WHERE":U) OR (childtype2 = "OF":U) THEN DO:
                                            ASSIGN havewhere = TRUE.
                                            LEAVE recordphrase-loop.
                                         END.
                                         ASSIGN childtype2 = parserNodeNextSibling(child2,child2).
                                      END.
                                   END.

       WHEN "CURRENT":U       THEN IF NodeType="FIND":U THEN 
                                      ASSIGN havewhere = TRUE.
                                   
       WHEN "COMMA":U         THEN DO: /* a join contains a COMMA. 
                                          The joined part (after the comma) must also 
                                          have a WHERE-clause (but we also accept "order OF customer").
                                          So when we see a comma we can start over again */
                                       IF (NOT havewhere) AND (NOT temptable) THEN
                                          RUN WriteResult (theNode, recordname).
                                       ASSIGN havewhere  = FALSE
                                              recordname = ""
                                              temptable  = FALSE.
                                   END.
    END CASE.

    ASSIGN childtype = parserNodeNextSibling(child,child).
  END.      
             
  IF (NOT havewhere) AND (NOT temptable) THEN
    RUN WriteResult (theNode, recordname).
         
  parserReleaseHandle(child).
  parserReleaseHandle(child2).
    
END PROCEDURE.                            


PROCEDURE WriteResult :
  /* purpose : send warning to the outputhandler(s) */

  DEFINE INPUT PARAMETER theNode    AS INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER recordname AS CHARACTER NO-UNDO.
  
    RUN PublishResult            (compilationunit,
                                  parserGetNodeFilename(theNode),
                                  parserGetNodeLine(theNode), 
                                  SUBSTITUTE("no WHERE-clause on table &1":T, recordname),
                                  rule_id).
END PROCEDURE.
