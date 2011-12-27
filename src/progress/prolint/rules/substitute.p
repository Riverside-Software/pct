/* ------------------------------------------------------------------------
   file    :  prolint/rules/substitute.p
   by      :  Jurjen Dijkstra
   purpose :  Find string concatenations that might be replaced by the
              SUBSTITUTE function.
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
DEFINE VARIABLE parentnode       AS INTEGER NO-UNDO.
define variable numQstrings      as integer no-undo initial 0.
define variable numTranslatables as integer no-undo initial 0.
define variable totalLength      as integer no-undo initial 0.

ASSIGN parentnode = parserGetHandle().
RUN searchNode            (hTopnode,         /* "Program_root" node                 */
                           "InspectNode":U,  /* name of callback procedure          */
                           "PLUS":U).        /* list of statements to search, ?=all */

parserReleaseHandle(parentnode).

procedure InspectNode :
  /* purpose : callback from searchNode. Inspect the node found by searchNode */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO.

  DEFINE VARIABLE child       AS INTEGER NO-UNDO.
  DEFINE VARIABLE nodetype    AS CHARACTER NO-UNDO.

  /* skip if parent is also "PLUS" */
  IF "PLUS":U = parserNodeParent(theNode,parentnode) THEN
     RETURN.

  ASSIGN
    numQstrings      = 0
    numTranslatables = 0
    totalLength      = 0
    child            = parserGetHandle()
    nodetype         = parserNodeFirstChild(theNode,child).

  /* see if the first child is "PLUS" again */
  IF nodetype="PLUS":U THEN
     run CountQstrings(child).

  nodetype  = parserNodeNextSibling(child,child).
  IF nodetype="QSTRING":U THEN
     RUN TestStringAttribute(child).

  parserReleaseHandle(child).

  /* don't raise warning if every QSTRING has the :U attribute. */
  /* also, don't raise warning if totalLength>=188.
     Strings longer than 188 are not accepted by Translation Manager.
     (index limit)
     So, we will assume that the string is deliberately cut in
     pieces so the pieces would fit in Tranman. */
  IF (numQstrings>1) AND (numTranslatables>0) AND totalLength<188 THEN
     RUN PublishResult            (compilationunit,
                                   parserGetNodeFilename(theNode),
                                   parserGetNodeLine(theNode),
                                   'replace string concatenation by SUBSTITUTE':U,
                                   rule_id).

end procedure.

procedure CountQstrings :
  /* purpose: count the number or QSTRING nodes. recursive */
  define input parameter theNode as integer no-undo.

  DEFINE VARIABLE child       AS INTEGER NO-UNDO.
  DEFINE VARIABLE nodetype    AS CHARACTER NO-UNDO.

  ASSIGN
    child          = parserGetHandle()
    nodetype       = parserNodeFirstChild(theNode,child).

  CASE nodetype :
    WHEN "PLUS":U    THEN RUN CountQStrings(child).
    WHEN "QSTRING":U THEN RUN TestStringAttribute(child).
  END CASE.

  nodetype  = parserNodeNextSibling(child,child).
  IF nodetype="QSTRING":U THEN
     RUN TestStringAttribute(child).

  parserReleaseHandle(child).

end procedure.

procedure TestStringAttribute :
  /* purpose: don't count this qstring if it has the :U attribute. */
  define input parameter StringNode as integer no-undo.

  define variable TheString as character no-undo.
  define variable quote     as character no-undo.
  define variable attrib    as character no-undo.
  define variable strlen    as integer   no-undo.

  ASSIGN
    theString   = parserGetNodeText(StringNode)
    quote       = SUBSTRING(theString,1,1)
    strlen      = R-INDEX(theString,quote) - 2
    totalLength = totalLength + strlen
    attrib      = SUBSTRING(theString, R-INDEX(theString,quote) + 2).

  /* Increase numTranslatables if it doesn't have the :U attribute.
     Translatable strings: ignore them if they don't contain any chars */
  IF strlen=0 THEN
    numQstrings = numQstrings + 1.
  ELSE
    IF attrib<>"U":U THEN
        ASSIGN
           numQstrings      = numQstrings + 1
           numTranslatables = numTranslatables + 1.
    ELSE
        IF TRIM(SUBSTRING(theString, 2, strlen),"-1234567890 ¡!@#$%^&*()_+~`~{~}[]~\|:;'<>,.¿?/":U)<>"" THEN
           numQstrings = numQstrings + 1.

end procedure.

