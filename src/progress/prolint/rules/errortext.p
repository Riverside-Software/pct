/* -----------------------------------------------------------------------------
   file    :  prolint/rules/errortext.p
   purpose :  "RETURN ERROR." should specify a text, like "RETURN ERROR txt."
   -----------------------------------------------------------------------------

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
   --------------------------------------------------------------------------------- */
  
{prolint/core/ruleparams.i}  

   RUN searchNode            (hTopnode,           /* "Program_root" node          */
                              "InspectNode":U,    /* name of callback procedure   */
                              "ERROR":U).         /* list of nodetypes to search for */

RETURN.

PROCEDURE InspectNode :
/* InspectNode is where the actual rule is implemented.
   it is called from SearchNode */
   DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
   DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL YES.
                             
   DEFINE VARIABLE nSibling AS INTEGER NO-UNDO.
   DEFINE VARIABLE nParent  AS INTEGER NO-UNDO.
   DEFINE VARIABLE nodetype AS CHARACTER NO-UNDO.
   DEFINE VARIABLE foundargument AS LOGICAL NO-UNDO INITIAL NO.

   ASSIGN
     nParent      = parserGetHandle()
     nSibling     = parserGetHandle()
     nodetype     = parserNodeParent(theNode,nParent).

   parserReleaseHandle(nParent).
   IF nodetype <> "RETURN":U THEN
      RETURN.

   /* look for syntax like:
       a.  RETURN ERROR argument .
       b.  DO TRANSACTION ON ERROR UNDO blocklabel, RETURN ERROR argument :
      Note there is no PERIOD node in statement (b) */

   nodetype = parserNodeNextSibling(theNode, nSibling).
   DO WHILE nodetype<>"":U :
      IF nodetype<>"PERIOD":U THEN
         foundargument = YES.
      nodetype = parserNodeNextSibling(nSibling, nSibling).
   END.

   IF NOT foundargument THEN
      RUN PublishResult            (compilationunit,
                                    parserGetNodeFilename(theNode),
                                    parserGetNodeLine(theNode),
                                    "RETURN ERROR should have a string argument":T,
                                    rule_id).

   /* release every proparse handle that was declared in this context */
   parserReleaseHandle(nSibling).
    
END PROCEDURE.                            


