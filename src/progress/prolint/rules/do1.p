/* ------------------------------------------------------------------------
   file    :  prolint/rules/do1.p
   by      :  Jurjen Dijkstra
   purpose :  find
                "IF condition THEN DO....END ELSE DO.....END."
              where any of the DO...END blocks contains only one statement.
         
   ------------------------------------------------------------------------
   modifications:     
     - 3 februari 2009 by Niek Knijnenburg
       StatementSkipList property so you can configure which statements may apear as single statements in a block
   ------------------------------------------------------------------------

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

define variable StatementSkipList as character no-undo.

StatementSkipList       = dynamic-function("ProlintProperty", "rules.do1.StatementSkipList").

DEFINE VARIABLE firstNode  AS INTEGER NO-UNDO.
ASSIGN firstNode = parserGetHandle().

RUN searchNode            (hTopnode,           /* "Program_root" node          */
                           "InspectTHEN":U,    /* name of callback procedure   */
                           "THEN":U).          /* list of statements to search */

RUN searchNode            (hTopnode,           /* "Program_root" node          */
                           "InspectELSE":U,    /* name of callback procedure   */
                           "ELSE":U).          /* list of statements to search */

parserReleaseHandle(firstNode).
RETURN.


PROCEDURE InspectTHEN :
  /* look for the subtile diff between InspectTHEN and InspectELSE */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL TRUE.

  IF parserNodeNextSibling(theNode,firstNode) = "DO":U THEN
     RUN InspectDO (firstNode).

END PROCEDURE.


PROCEDURE InspectELSE :
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL TRUE.

  IF parserNodeFirstChild(theNode,firstNode) = "DO":U THEN
     RUN InspectDO (firstNode).

END PROCEDURE.


PROCEDURE InspectDO :
  DEFINE INPUT  PARAMETER theNode  AS INTEGER NO-UNDO.

  DEFINE VARIABLE child            AS INTEGER NO-UNDO.
  DEFINE VARIABLE numChildren      AS INTEGER NO-UNDO.
  DEFINE VARIABLE nodetype         AS CHARACTER NO-UNDO.

  ASSIGN
    child  = parserGetHandle().

  /* first child must be "LEXCOLON".
     because "DO i=1 TO 5" :
     would be valid - firstchild would be "BlockIterator" */
  nodetype = parserNodeFirstChild(theNode,child).
  IF nodetype = "LEXCOLON":U THEN DO:

      /* Next sibling of LEXCOLON is "Code_block" */
      nodetype = parserNodeNextSibling(child,child).
      IF nodetype = "Code_block":U THEN DO:

          /* Count the number of statements in Code_block" */
          numChildren = 0.
          nodetype = parserNodeFirstChild(child,child).
          DO WHILE nodetype<>"" :
             numChildren = numChildren + 1.

             /* give a bonus point for IF statements. Why? Well,..
                An IF-statement inside an IF-statement can be hard to read,
                the DO..END block is probably added for increased readability.
                Increasing readability deserves a bonus, imho */
             IF can-do(StatementSkipList,nodetype) THEN
                numChildren = numChildren + 1.

             nodetype = parserNodeNextSibling(child,child).
          END.

          IF numChildren<2 THEN
             RUN PublishResult            (compilationunit,
                                           parserGetNodeFilename(theNode),
                                           parserGetNodeLine(theNode),
                                           '"DO:" contains only one statement':T,
                                           rule_id).

      END.
  END.
  parserReleaseHandle(child).

END PROCEDURE.

