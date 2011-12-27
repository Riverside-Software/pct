/* ------------------------------------------------------------------------
   file    :  prolint/rules/runargs.p
   by      :  Jurjen Dijkstra
   purpose :  find RUN statements with run-time arguments
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

RUN searchNode            (hTopnode,                /* "Program_root" node          */
                           "InspectNode":U,         /* name of callback procedure   */
                           "RUN":U).                /* list of statements to search */

RETURN.

PROCEDURE InspectNode :
/* InspectNode is where the actual rule is implemented */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.

  /* a run-time argument appears to have nodetype "TYPELESS_TOKEN"
     so just query for that. Live can be so easy.. */

  define variable numResults as integer no-undo.

  numResults = parserQueryCreate(theNode, "runargs":U, "TYPELESS_TOKEN":U).
  parserQueryClear ("runargs":U).

  if numresults>0 then
     RUN PublishResult            (compilationunit,
                                   parserGetNodeFilename(theNode),
                                   parserGetNodeLine(theNode),
                                   'run-time arguments in RUN statement':U,
                                   rule_id).

END PROCEDURE.



