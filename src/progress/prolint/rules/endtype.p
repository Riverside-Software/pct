/* ------------------------------------------------------------------------
   file    :  prolint/rules/endtype.p
   by      :  Igor Natanzon
   purpose :  Locate any END statement for procedure, function, or case that
              does not have an END type qualifier (ie. END PROCEDURE).
   -----------------------------------------------------------------------------

    Copyright (C) 2002,2003 Igor Natanzon

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
/* Starting at the END statement, move up to the END's parent. Since END may belong to
many different types of blocks, check that the parent is either PROCEDURE, FUNCTION, or CASE.
It is probably more efficient though to start from the top and search for ENDs */

RUN searchNode            (hTopnode,            /* "Program_root" node          */
                           "InspectNode":U,     /* name of callback procedure   */
                           "END":U).            /* list of nodetypes to search  */
RETURN.

PROCEDURE InspectNode :
/* InspectNode is where the actual rule is implemented */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.

  DEFINE VARIABLE nodetype   AS CHAR NO-UNDO.
  DEFINE VARIABLE nodeparent AS CHAR NO-UNDO.
  DEFINE VARIABLE child      AS INT  NO-UNDO.

  ASSIGN child      = parserGetHandle()
         nodetype   = parserNodeFirstChild(theNode,child).
         nodeparent = parserNodeParent(theNode,child).

  /* END statement does not have a qualifier, and it is an END for PROCEDURE, FUNCTION, or CASE */
  IF NOT CAN-DO("PROCEDURE,FUNCTION,CASE,METHOD,CLASS,CONSTRUCTOR,DESTRUCTOR":U,nodetype) aND CAN-DO("PROCEDURE,FUNCTION,CASE,METHOD,CLASS,CONSTRUCTOR,DESTRUCTOR":U,nodeparent) then
     RUN PublishResult            (compilationunit,
                                   parserGetNodeFilename(theNode),
                                   parserGetNodeLine(theNode),
                                   SUBSTITUTE("Use END &1 to terminate a &2 block",nodeparent,LC(nodeparent)), rule_id).
  parserReleaseHandle(child).

END PROCEDURE.

