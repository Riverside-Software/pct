/*------------------------------------------------------------------------
   file    :  rules/groupassign.p
   by      :  Igor Natanzon
   purpose :  find possible groupings of ASSIGN statement.
    -----------------------------------------------------------------

    Copyright (C) 2002-2004 Igor Natanzon

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

RUN searchNode            (hTopnode,
                           "InspectNode":U,
                           "Program_root":U).

RUN searchNode            (hTopnode,
                           "InspectNode":U,
                           "Code_block":U).

RETURN.

PROCEDURE InspectNode :
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.

  def var child       as int  no-undo.
  def var child1      as int  no-undo.
  def var child2      as int  no-undo.
  def var nodetype    as char no-undo.
  def var iAssignLine as int  no-undo.
  def var iNodeLine   as int  no-undo.
  def var cAssignFile as char no-undo.
  def var cNodeFile   as char no-undo.

  assign child   = parserGetHandle()
         child1  = parserGetHandle()
         child2  = parserGetHandle()
         nodetype = parserNodeFirstChild(theNode,child).

  testNode:
  DO WHILE nodetype NE "":
     if nodetype eq "ASSIGN":U then do:
        /* If synthetic node, find next natural node. Synthetic node in this case *
         * is an ASSIGN statement without ASSIGN keyword, i.e. x = 1    */
        if parserGetNodeText(child) eq "" and parserGetNodeLine(child) eq 0 then  do:
           if parserNodeFirstChild(child,child1) ne "EQUAL":U then do:
              nodetype = parserNodeNextSibling(child,child).
             next testNode.
           end.
           /* child1 is now the "EQUAL" node. If the second child of child1 is "NEW" then
              we cannot suggest a possible group assign, because OE 10.1B does not allow
              ASSIGN on object instantiations (see OE Hive issue 845) */
           IF parserNodeFirstChild(child1,child2)>"" THEN
              IF parserNodeNextSibling(child2,child2)="NEW":U THEN DO:
                 nodetype = parserNodeNextSibling(child,child).
                 next testNode.
              END.
           assign cNodeFile = parserGetNodeFilename(child1)
                  iNodeLine = parserGetNodeLine(child1).
        end.
        else
           assign cNodeFile = parserGetNodeFilename(child)
                  iNodeLine = parserGetNodeLine(child).
        if iAssignLine ne 0 and cAssignFile eq cNodeFile then
           RUN PublishResult           
                        (compilationunit, cNodeFile, iNodeLine,
                         SUBSTITUTE("Possibly group ASSIGN with line &1":U,iAssignLIne),rule_id).
        else
           assign iAssignLine = iNodeLine
                  cAssignFile = cNodeFile.
     end.
     else /* Reset data */
        assign iAssignLine = 0
               cAssignFile = "".
     nodetype = parserNodeNextSibling(child,child).
  END.

  parserReleaseHandle(child).
  parserReleaseHandle(child1).
  parserReleaseHandle(child2).

END PROCEDURE.


