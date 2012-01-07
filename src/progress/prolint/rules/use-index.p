/* ------------------------------------------------------------------------
   file    :  prolint/rules/use-index.p
   by      :  Jurjen Dijkstra
   purpose :  find USE-INDEX
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

RUN searchNode            (hTopnode,           /* "Program_root" node          */
                           "InspectNode":U,    /* name of callback procedure   */
                           "USEINDEX":U).      /* list of nodetypes to search  */

RETURN.

PROCEDURE InspectNode :
/* InspectNode is where the actual rule is implemented */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.

  DEFINE VARIABLE statenode AS INTEGER NO-UNDO.
  statenode = parserGetHandle().

  /* avoid warning for USE-INDEX when used in:
        DEFINE TEMP-TABLE tt_customer LIKE customer USE-INDEX custnum. */

  IF NOT (parserNodeStateHead(theNode,statenode)="DEFINE":U AND parserAttrGet(statenode,"state2":U)="TEMPTABLE":U) THEN
     RUN PublishResult            (compilationunit,
                                   parserGetNodeFilename(theNode),
                                   parserGetNodeLine(theNode),
                                   "avoid using USE-INDEX":U,
                                   rule_id).
  parserReleaseHandle(statenode).

END PROCEDURE.



