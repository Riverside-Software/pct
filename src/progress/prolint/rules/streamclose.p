/* -----------------------------------------------------------------------------
   file    :  prolint/rules/streamclose.p
   by      :  Niek Knijnenburg
   purpose :  examine all named or unnamed streams, defines and usage, and warn if:
              1. A stream is defined but not used
              2. A stream is opened but not closed
              3. A stream is opened for INPUT/OUTPUT but not closed before it's used for OUTPUT/INPUT
   -----------------------------------------------------------------------------
   severity    : 5
   category    : Bug
   useProparse : yes
   useXref     : no
   useListing  : no
   useProclist : no
   ignoreUIB   : no
   -----------------------------------------------------------------------------

    Copyright (C) 2009 Niek Knijnenburg

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
   --------------------------------------------------------------------------------- */

{prolint/core/ruleparams.i}

define temp-table ttStream no-undo
  field NodeType   as character
  field ID         as character format "x(15)":U
  field Action     as character
  field LineNumber as integer
  field filename   as character format "x(100)":U
  index ID-LineNumber ID LineNumber.

define buffer bttStream for ttStream.

run searchNode (hTopnode,                 /* "Program_root" node                 */
                "InspectNode":U,          /* name of callback procedure          */
                "DEFINE,INPUT,OUTPUT":U). /* list of statements to search, ?=all */

for each ttStream:
  case ttStream.Action:
    when "":U /* DEFINE */
    then do:
      if not can-find(first bttStream where bttStream.ID = ttStream.ID
                                        and can-do("FROM,TO":U,bttStream.Action))
      then
        run WriteResult(ttStream.ID,
                        "stream &1 is defined but never used",
                        ttStream.LineNumber,
                        ttStream.FileName).
    end.
    when "TO":U or when "FROM":U
    then do:
      find first bttStream where bttStream.ID         = ttStream.ID
                             and bttStream.LineNumber > ttStream.LineNumber no-error.
      if not available bttStream
      then
        run WriteResult(ttStream.ID,
                        "stream &1 is opened for " + ttStream.NodeType + " but not correctly closed",
                        ttStream.LineNumber,
                        ttStream.FileName).
      else if bttStream.Action <> "CLOSE":U
      or bttStream.NodeType <> ttStream.NodeType
      then
        run WriteResult(ttStream.ID,
                        "stream &1 is opened for " + ttStream.NodeType + " but not correctly closed, before used differently on line " + string(bttStream.LineNumber),
                        ttStream.LineNumber,
                        ttStream.FileName).
    end.
  end case.
end.

return.

procedure InspectNode :
  define input  parameter piTheNode         as integer no-undo.
  define output parameter plAbortSearch     as logical no-undo .
  define output parameter plSearchChildren  as logical no-undo.

  define variable iChild          as integer   no-undo.
  define variable iGrandchild     as integer   no-undo.
  define variable cChildType      as character no-undo.
  define variable cGrandchildType as character no-undo.
  define variable cNodeType       as character no-undo.
  define variable iSibling        as integer   no-undo.

  /* Assign handles and pointers to specific nodes in the Pares Tree */
  assign iChild        = parserGetHandle()
         iGrandchild   = parserGetHandle()
         iSibling      = parserGetHandle()
         cNodeType     = parserGetNodeType(piTheNode)
         cChildType    = parserNodeFirstChild(piTheNode,iChild).

  if cChildType = "":U
  then do:
    parserReleaseHandle(iChild).
    parserReleaseHandle(iGrandchild).
    parserReleaseHandle(iSibling).
    return.
  end.

  /* Search for Find statements and can-find statements and seperate by the */
  /* findWhich qualifier that should follow.                                  */
  case cNodeType:

    when "DEFINE":U
    then do:
      if cChildType <> "STREAM":U
      or parserNodeNextSibling(iChild,iChild) <> "ID":U
      then
        return. /* We can say little or nothing about shared streams being used or not */
      run CreateTT(input cNodeType, input piTheNode).
      assign ttStream.Id = parserGetNodeText(iChild).
    end. /* DEFINE */
    when "INPUT":U or
    when "OUTPUT":U
    then do:
      /* only process if INPUT or OUTPUT is a statement (skip output parameters) */
      if parserAttrGet(piTheNode, "statehead":U) > ""
      then do:
        run CreateTT(input cNodeType, input piTheNode).

        /* by default assume its an unnamed stream. We'll try to find the stream id soon */
        assign ttStream.Id = "UNNAMED-":U + cNodeType
               ttStream.Action = cChildType.

        /* now try to find the ID and some more details */
        CHILD-LOOP:
        do while cChildType > "":U :
          case cChildType :
            when "STREAM-HANDLE":U or
            when "STREAM":U
            then do:
              assign cGrandchildType = parserNodeFirstChild(iChild,iGrandchild).
              GRANDCHILD-LOOP:
              do while cGrandchildType > "":U :
                case cGrandchildType:
                  when "ID":U  then  assign ttStream.Id = parserGetNodeText(iGrandchild).
                end case.
                assign cGrandchildType = parserNodeNextSibling(iGrandchild,iGrandchild).
              end. /* GRANDCHILD-LOOP */
            end.
            when "TO":U or
            when "FROM":U or
            when "CLOSE":U then  assign ttStream.Action = cChildType.
            when "THROUGH":U then assign ttStream.Action = (if cNodeType = "INPUT":U then "FROM":U else "TO":U). /* INPUT-THROUGH=FROM OUTPUT-THROUGH=TO */
          end case.
          assign cChildType = parserNodeNextSibling(iChild,iChild).
        end. /* CHILD-LOOP */
      end.
    end. /* INPUT or OUTPUT */
  end case.

  parserReleaseHandle(iChild).
  parserReleaseHandle(iGrandchild).
  parserReleaseHandle(iSibling).

end procedure.

procedure CreateTT:
  define input parameter pcNodeType as character no-undo.
  define input parameter piTheNode  as integer no-undo.

  create ttStream.
  assign ttStream.NodeType   = pcNodeType
         ttStream.FileName   = parserGetNodeFilename(piTheNode)
         ttStream.LineNumber = parserGetNodeLine(piTheNode).
end procedure.

procedure WriteResult :
  /* purpose : send warning to the outputhandlers(s) */
  define input parameter pcID         as character no-undo.
  define input parameter pcMessage    as character no-undo.
  define input parameter piLineNumber as integer   no-undo.
  define input parameter pcFilename   as character no-undo.

  run PublishResult(compilationunit,
                    pcFilename,
                    piLineNumber,
                    substitute(pcMessage, pcID),
                    rule_id).
end procedure.

