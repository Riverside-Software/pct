/* ------------------------------------------------------------------------
   file    :  prolint/rules/nobrackets.p
   by      :  Jurjen Dijkstra
   purpose :  reports what "noeffect" excludes
                 QUERY-OPEN
                 GET-FIRST
                 GET-NEXT
                 GET-PREV
                 GET-LAST
              these methods are excluded from "noeffect" because they
              are so commonly used.
    -----------------------------------------------------------------

    Copyright (C) 2003 Jurjen Dijkstra

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
   ------------------------------------------------------------------------
*/

{prolint/core/ruleparams.i}
{prolint/rules/inc/nobrackets.i}

RUN searchNode            (hTopnode,                /* "Program_root" node */
                           "InspectNode":U,         /* name of callback procedure */
                           "OBJCOLON":U).          /* list of statements to search, ?=all */

RETURN.

PROCEDURE InspectNode:
  /* purpose: see if the statement in theNode is really a statement without effect */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.

  DEFINE VARIABLE result      AS INTEGER NO-UNDO.
  DEFINE VARIABLE methodname  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE nodetype    AS CHARACTER NO-UNDO.

  ASSIGN
    result = parserGetHandle()
    nodetype = parserNodeNextSibling(theNode, result)
    methodname = parserGetNodeText(RESULT).

  check-block:
  DO:
    IF nodetype <> "ID":U THEN
       LEAVE check-block.
    IF LOOKUP(methodname,nobracketlist)=0 THEN
       LEAVE check-block.
    IF parserNodeNextSibling(result, result) = "Method_param_list":U THEN
       LEAVE check-block.
    IF parserNodeNextSibling(result, result) = "Method_param_list":U THEN
       LEAVE check-block.

    RUN PublishResult            (compilationunit,
                                  parserGetNodeFilename(theNode),
                                  parserGetNodeLine(theNode),
                                  SUBSTITUTE("handle:&1 should have brackets":T,methodname),
                                  rule_id).
  END.

  parserReleaseHandle(result).

END PROCEDURE. /* InspectNode */

