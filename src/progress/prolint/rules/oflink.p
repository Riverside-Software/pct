/* ------------------------------------------------------------------------
   file       :  prolint/rules/oflink.p
   by         :  Jurjen Dijkstra
   purpose    :  search for places where "OF" is used instead "WHERE",
                 as in "FIND FIRST order OF customer"
    -----------------------------------------------------------------

    Copyright (C) 2004 Jurjen Dijkstra

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

RUN searchNodeQueries            (hTopnode,              /* "Program_root" node                 */
                                  "InspectNode":U,       /* name of callback procedure          */
                                  "OF":U).               /* list of statements to search, ?=all */

RETURN.


PROCEDURE InspectNode :
  /* purpose : callback from searchNode. Inspect the node found by searchNode */

  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL YES.

  DEFINE VARIABLE hStatehead AS INTEGER   NO-UNDO.
  DEFINE VARIABLE hChild     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE hParent    AS INTEGER   NO-UNDO.
  DEFINE VARIABLE nodetype   AS CHARACTER NO-UNDO.

  /* check if this OF is used in a FIND, FOR or OPEN QUERY statement, or in a CAN-FIND function */

   ASSIGN
     hStatehead   = parserGetHandle()
     nodetype     = parserNodeStatehead(theNode,hStatehead).

   IF nodetype = "FOR":U OR nodetype="FIND":U THEN
       RUN WriteResult (theNode).
   ELSE
       IF nodetype = "OPEN":U THEN DO:
          hChild = parserGetHandle().
          nodetype = parserNodeFirstChild(hStatehead,hChild).
          parserReleaseHandle(hChild).
          IF nodetype = "QUERY":U THEN
             RUN WriteResult (theNode).
       END.
       ELSE DO:
          /* does FOR appear in CAN-FIND? */
          hParent  = parserGetHandle().
          nodetype = parserNodeParent(theNode, hParent).
          DO WHILE NOT (nodetype="" OR nodetype="CANFIND":U OR parserAttrGet(hParent,"statehead":U)<>"" ):
             nodetype = parserNodeParent(hParent, hParent).
          END.
          IF nodetype="CANFIND":U THEN
             RUN WriteResult (theNode).
          parserReleaseHandle(hParent).
       END.

   /* release every proparse handle that was declared in this context */
   parserReleaseHandle(hStatehead).


END PROCEDURE.

PROCEDURE WriteResult :
  /* purpose : send warning to the outputhandler(s) */

  DEFINE INPUT PARAMETER theNode    AS INTEGER NO-UNDO.

    RUN PublishResult            (compilationunit,
                                  parserGetNodeFilename(theNode),
                                  parserGetNodeLine(theNode),
                                  "OF used instead WHERE":T,
                                  rule_id).
END PROCEDURE.

