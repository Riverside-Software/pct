/* ------------------------------------------------------------------------
   file    :  prolint/rules/andorparens.p
   by      :  Jurjen Dijkstra
   purpose :  if a WHERE clause has a mix of OR and AND operators, you must use 
              parentheses to avoid confusion about precendence of operators
   -----------------------------------------------------------------------------

    Copyright (C) 2008 Jurjen Dijkstra

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

RUN searchNode            (hTopnode,            /* "Program_root" node          */
                           "InspectNode":U,     /* name of callback procedure   */
                           "OR":U).            /* list of nodetypes to search  */
RETURN.

PROCEDURE InspectNode :
/* InspectNode is where the actual rule is implemented */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.

  DEFINE VARIABLE nodetype   AS CHAR NO-UNDO.
  DEFINE VARIABLE nodeparent AS CHAR NO-UNDO.
  DEFINE VARIABLE child      AS INT  NO-UNDO.
  DEFINE VARIABLE tempnode   AS INT  NO-UNDO.
  DEFINE VARIABLE lWrite     AS LOGICAL NO-UNDO INITIAL no.

  ASSIGN child      = parserGetHandle()
         tempnode   = parserGetHandle().

  /* raise a warning when:
       - OR is a sibling of AND
       - OR has a child (not grandchild) of type AND
       - OR is a child (not grandchild) of AND  */
       
  IF parserNodeParent(theNode,tempnode) = "AND":U THEN
     lWrite = YES. 
  
  nodetype = parserNodeFirstChild(theNode,child).
  DO WHILE nodetype<>"" AND lWrite<>YES:
      IF nodetype = "AND":U THEN lWrite = YES.
      nodetype = parserNodeNextSibling(child,child).
  END.

  nodetype = parserNodeNextSibling(theNode,child).
  DO WHILE nodetype<>"" AND lWrite<>YES :
      IF nodetype = "AND":U THEN lWrite = YES.
      nodetype = parserNodeNextSibling(child,child).
  END.

  IF lWrite = YES THEN 
     RUN PublishResult (compilationunit,
                        parserGetNodeFilename(theNode),
                        parserGetNodeLine(theNode),
                        "mixed AND and OR - please use parentheses":T, 
                        rule_id).
  parserReleaseHandle(child).
  parserReleaseHandle(tempnode).

END PROCEDURE.

