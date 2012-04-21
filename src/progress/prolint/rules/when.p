/* -----------------------------------------------------------------------------
   file    :  prolint/rules/when.p
   purpose :  warn about confusing usage of ASSIGN...WHEN... statements
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
                              "WHEN":U).          /* list of nodetypes to search for */

RETURN.


PROCEDURE InspectNode :
/* InspectNode is where the actual rule is implemented.
   it is called from SearchNode */
   DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
   DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL YES.
                             
   DEFINE VARIABLE child          AS INTEGER NO-UNDO.
   DEFINE VARIABLE nFieldref      AS INTEGER NO-UNDO.
   DEFINE VARIABLE nAssign        AS INTEGER NO-UNDO.
   DEFINE VARIABLE nodetype       AS CHARACTER NO-UNDO.
   DEFINE VARIABLE whenfields     AS CHARACTER NO-UNDO.
   DEFINE VARIABLE numresults     AS INTEGER NO-UNDO.
   DEFINE VARIABLE warn           AS LOGICAL NO-UNDO INITIAL NO.
   DEFINE VARIABLE i              AS INTEGER NO-UNDO.

   ASSIGN
     nAssign     = parserGetHandle()
     child       = parserGetHandle().

   /* we have found a WHEN node. Find the matching ASSIGN node */
   IF "ASSIGN":U <> parserNodeStatehead(theNode, nAssign) THEN DO:
      parserReleaseHandle(child).
      parserReleaseHandle(nAssign).
      RETURN.
   END.

   ASSIGN
     nFieldref  = parserGetHandle().
   
   /* find the names of all variables/fields in the WHEN clause.
      store these names in comma-separated list whenfields */
   numResults = parserQueryCreate(theNode, "fieldrefs":U, "Field_ref":U).
   do i = 1 to numResults :
      parserQueryGetResult("fieldrefs":U, i, nFieldref).
      whenfields = whenfields + ",":U + GetFieldnameFromFieldref(nFieldref).
   end.
   parserQueryClear ("fieldrefs":U).
   whenfields = TRIM(whenfields, ",":U).


   /* find the names of the variables/fields that are assigned a new value.
      in other words: the variables on the left hand sides of the = .
      raise warning if this variable is also in 'whenfields' */
   nodetype = parserNodeFirstChild(nAssign,child).
   DO WHILE nodetype <> "PERIOD":U :
      IF nodetype = "EQUAL":U THEN
         IF "Field_ref":U = parserNodeFirstChild(child,nFieldref) THEN
            IF LOOKUP(GetFieldnameFromFieldref(nFieldref),whenfields)>0 THEN
               warn = YES.
      nodetype = parserNodeNextSibling(child, child).
   END.
   
   IF warn THEN
      RUN PublishResult            (compilationunit,
                                    parserGetNodeFilename(theNode),
                                    parserGetNodeLine(theNode),
                                    "wrong usage of ASSIGN..WHEN.. statement":T,
                                    rule_id).

   /* release every proparse handle that was declared in this context */
   parserReleaseHandle(child).
   parserReleaseHandle(nAssign).
   parserReleaseHandle(nFieldRef).
    
END PROCEDURE.                            


