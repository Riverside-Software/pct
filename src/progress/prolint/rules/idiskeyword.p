/* -----------------------------------------------------------------------------
   file    :  prolint/rules/idiskeyword.p
   purpose :  name of [variable|parameter|temp-table|field|index] '&1' is a keyword
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
                              "DEFINE":U).        /* list of nodetypes to search for */

RETURN.


PROCEDURE InspectNode :
/* InspectNode is where the actual rule is implemented.
   it is called from SearchNode */
   DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
   DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL YES.
                             
   DEFINE VARIABLE typenode   AS INTEGER   NO-UNDO.
   DEFINE VARIABLE childnode  AS INTEGER   NO-UNDO.
   DEFINE VARIABLE parentnode AS INTEGER   NO-UNDO.
   DEFINE VARIABLE numResults AS INTEGER   NO-UNDO.
   DEFINE VARIABLE i          AS INTEGER   NO-UNDO.
   DEFINE VARIABLE varname    AS CHARACTER NO-UNDO.

   ASSIGN
     typenode        = parserGetHandle()
     childnode       = parserGetHandle()
     parentnode      = parserGetHandle().

   /* Find every ID in this DEFINE statement.
      Check if the ID text is a Progress keyword */

   numResults = parserQueryCreate(theNode, "idiskeyword":U, "ID":U).
   DO i = 1 TO numResults :
      parserQueryGetResult("idiskeyword":U, i, childnode).
      /* funny proparse behaviour: SHORT and COMPONENT-HANDLE are ID's */
      IF parserNodeParent(childnode, parentnode)<>"AS":U THEN DO:
         varname = parserGetNodeText (childnode).
         IF KEYWORD-ALL(varname)<>? THEN DO:
            /* try to get the object type (variable, field, temp-table,...) */
            IF parserNodePrevSibling(childnode,typenode)="" THEN
               parserNodeParent(childnode,typenode).
            /* For a temp-table index, there is no need to nag about the index fields again.
               After all we have already complained about the FIELD name.
               But we still want to see the name of the index! */
            IF LOOKUP(parserGetNodeType(typenode),"ID,IS,PRIMARY,UNIQUE,ASCENDING,DESCENDING":U)=0 THEN
               RUN PublishResult            (compilationunit,
                                             parserGetNodeFilename(childnode),
                                             parserGetNodeLine(childnode),
                                             SUBSTITUTE("name of &1 '&2' is a keyword":T,
                                                        LOWER(KEYWORD-ALL(parserGetNodeText(typenode))),
                                                        varname),
                                             rule_id).
         END.
      END.
   END.
   parserQueryClear ("idiskeyword":U).

   /* release every proparse handle that was declared in this context */
   parserReleaseHandle(typenode).
   parserReleaseHandle(childnode).
   parserReleaseHandle(parentnode).
    
END PROCEDURE.                            


