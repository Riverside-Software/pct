/* -----------------------------------------------------------------------------
   file    :  prolint/rules/ifparens.p
   purpose :  find IF functions (not statements) that should better be
              surrounded by parentheses
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
                              "IF":U).           /* list of nodetypes to search for */

RETURN.

PROCEDURE InspectNode :
/* InspectNode is where the actual rule is implemented.
   it is called from SearchNode */
   DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
   DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL YES.
                             
   DEFINE VARIABLE child      AS INTEGER NO-UNDO.
   DEFINE VARIABLE elsenode   AS INTEGER NO-UNDO.
   DEFINE VARIABLE nodetype   AS CHARACTER NO-UNDO.
   DEFINE VARIABLE elseLine   AS INTEGER NO-UNDO.
   DEFINE VARIABLE numResults AS INTEGER NO-UNDO.
   DEFINE VARIABLE i1         AS INTEGER NO-UNDO.
   DEFINE VARIABLE linebreak  AS LOGICAL NO-UNDO INITIAL FALSE.

   /* is "IF" a statehead? If yes, then it is not a function -> return. */
   IF parserAttrGet(theNode, "statehead":U)<>"" THEN
      RETURN.
   
   ASSIGN
     child       = parserGetHandle()
     elsenode    = parserGetHandle()
     nodetype    = parserNodeFirstChild(theNode,child).  /* boolean expression */

   IF "THEN":U = parserNodeNextSibling(child,child) THEN DO:
      nodetype    = parserNodeNextSibling(child,child).   /* the 'then' value */
      IF "ELSE":U = parserNodeNextSibling(child,child) THEN DO:
         nodetype = parserNodeNextSibling(child,elsenode).   /* the 'else' value */
         IF parserAttrGet(elsenode, "operator":U)<>"" THEN DO:
            /* if the expression in the ELSE node contains a newline, then
               raise a warning */
            elseLine = parserGetNodeLine(elsenode).
            numResults = parserQueryCreate(elsenode, "ifparens":U, "":U).
            do i1 = 1 to numResults :
               parserQueryGetResult("ifparens":U, i1, child).
               IF parserGetNodeLine(child) <> elseLine THEN
                  IF parserGetNodeLine(child) <> 0 THEN  /* skip synthetic nodes */
                     linebreak = TRUE.
            end.
            parserQueryClear ("ifparens":U).
            IF linebreak THEN
               RUN PublishResult            (compilationunit,
                                             parserGetNodeFilename(theNode),
                                             parserGetNodeLine(theNode),
                                             "IF function is confusing, use parentheses":T,
                                             rule_id).
         END.
      END.
   END.

   /* release every proparse handle that was declared in this context */
   parserReleaseHandle(child).
   parserReleaseHandle(elsenode).
    
END PROCEDURE.                            


