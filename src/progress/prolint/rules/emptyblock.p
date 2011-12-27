/* ------------------------------------------------------------------------
   file    :  rules/emptyblock.p
   by      :  Igor Natanzon
   purpose :  Locate any empty block, i.e.:
              REPEAT:
                  /*    CREATE customer.
                        IMPORT customer.
                  */
              END.
    -----------------------------------------------------------------

    Copyright (C) 2001,2002,2009 Igor Natanzon, Niek Knijnenburg

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

run searchNode            (hTopnode,
                           "InspectNode":U,
                           "Code_block":U).
return.

procedure InspectNode :
  define input  parameter theNode        as integer no-undo.
  define output parameter AbortSearch    as logical no-undo initial no.
  define output parameter SearchChildren as logical no-undo initial no.

  define variable childNodeType   as char no-undo.
  define variable parentNodeType  as char no-undo.
  define variable parentHandle    as int  no-undo.
  define variable childHandle     as int  no-undo.
  define variable ProtoType       as log  no-undo.

  assign parentHandle   = parserGetHandle()
         childHandle    = parserGetHandle()
         parentNodeType = parserNodeParent(theNode,parentHandle)
         childNodeType  = parserNodeFirstChild(theNode,childHandle).

  if childNodeType = "":U
  then do:
    if parentNodeType = "PROCEDURE":U
    then do: /* Code_block is empty procedure_block, check if it's a prototype/external */
      assign childNodeType  = parserNodeFirstChild(parentHandle,childHandle).
      CHILD-LOOP:
      do while childNodeType > "":U :
        if childNodeType = "IN":U
        or childNodeType = "EXTERNAL":U
        then do:
          assign ProtoType = yes.
          leave CHILD-LOOP.
        end. /* IN */
        assign childNodeType = parserNodeNextSibling(childHandle,childHandle).
      end. /* CHILD-LOOP */
    end.
    if not ProtoType
    then
      run PublishResult            (compilationunit,
                                    parserGetNodeFilename(parentHandle),
                                    parserGetNodeLine(parentHandle),
                                    SUBSTITUTE("Empty &1 block":U,parentNodeType), rule_id).
  end.

  parserReleaseHandle(parentHandle).
  parserReleaseHandle(childHandle).

END PROCEDURE.

/* End Program */

