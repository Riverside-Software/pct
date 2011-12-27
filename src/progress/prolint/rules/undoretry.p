/* -----------------------------------------------------------------------------
   file    :  prolint/rules/undoretry.p
   purpose :  Locate statement "UNDO labelname."
              This behaves like "UNDO, RETRY labelname" but RETRY is almost
              never desired.
              The programmer should specify at least something like "UNDO, LEAVE labelname"
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
                              "UNDO":U).          /* list of nodetypes to search for */

RETURN.

PROCEDURE InspectNode :
/* InspectNode is where the actual rule is implemented.
   it is called from SearchNode */
   DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
   DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL YES.
                             
   DEFINE VARIABLE child       AS INTEGER NO-UNDO.
   DEFINE VARIABLE parentnode  AS INTEGER NO-UNDO.
   DEFINE VARIABLE nodetype    AS CHARACTER NO-UNDO.
   DEFINE VARIABLE OptionFound AS LOGICAL NO-UNDO INITIAL FALSE.

   ASSIGN
     child       = parserGetHandle().
     
   /* We are looking for UNDO as a statement that undoes a transactio. 
      So when UNDO is used as an option in a DEFINE statement, like "DEFINE TEMP-TABLE ttname UNDO" then don't bother */
   IF parserNodeStateHead(theNode, child) = "DEFINE":U THEN DO: 
      parserReleaseHandle(child). 
      RETURN. 
   END. 
   

   /* is this UNDO a statement or an option? */
   IF parserAttrGet(theNode, "statehead":U)<>"" THEN DO:

      /* so UNDO is a statement. Let's see if it has an option like LEAVE, NEXT etc */
      /* all you need to know is if one of the child nodes is a COMMA */
      nodetype = parserNodeFirstChild(theNode,child).
      DO WHILE nodetype<>"" :
         IF nodetype="COMMA":U THEN
            OptionFound = TRUE.
         nodetype = parserNodeNextSibling(child,child).
      END.
   END.
   ELSE DO:

      /* UNDO appears to be an option to a statement.
        The parent should be "ON"  */
      parentnode  = parserGetHandle().
      nodetype   = parserNodeParent(theNode, parentnode).
      IF nodetype = "ON":U THEN DO:
         IF "COMMA":U = parserNodeNextSibling(TheNode,child) THEN
            OptionFound = TRUE.
      END.
      parserReleaseHandle(parentnode).
   END.
   

   IF NOT OptionFound THEN
      RUN PublishResult            (compilationunit,
                                    parserGetNodeFilename(theNode),
                                    parserGetNodeLine(theNode),
                                    '"UNDO" defaults to "UNDO, RETRY"':T,
                                    rule_id).

   /* release every proparse handle that was declared in this context */
   parserReleaseHandle(child).
    
END PROCEDURE.                            


