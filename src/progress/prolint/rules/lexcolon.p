/* ------------------------------------------------------------------------
   file    :  prolint/rules/lexcolon.p
   by      :  Igor Natanzon
   purpose :  Identify block headers that did not terminate with a colon.
    -----------------------------------------------------------------

    Copyright (C) 2002-2004 Igor Natanzon

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

RUN searchNode            (hTopnode,                              /* "Program_root" node          */
                           "InspectNode":U,                       /* name of callback procedure   */
                           "PROCEDURE,FUNCTION,FOR,DO,REPEAT":U). /* list of nodetypes to search  */
RETURN.

PROCEDURE InspectNode :
/* InspectNode is where the actual rule is implemented */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.

  DEF VAR nodetype  AS CHAR NO-UNDO.
  DEF VAR child     AS INT  NO-UNDO.
  DEF VAR blockType AS CHAR NO-UNDO.

  ASSIGN child     = parserGetHandle()
         blockType = parserGetNodeType(theNode)
         nodetype  = parserNodeFirstChild(theNode,child).

  testNode:
  DO WHILE nodetype NE "":
     IF nodetype EQ "Code_Block":U THEN DO:
        nodetype = parserNodePrevSibling(child,child).
        IF nodetype NE "LEXCOLON":U THEN
	   RUN PublishResult            (compilationunit,
		   	                 parserGetNodeFilename(theNode),
                                         parserGetNodeLine(theNode),
					 SUBSTITUTE("&1 block header should terminate with a COLON":U,blockType),rule_id).
        LEAVE testNode.
     END.
     ASSIGN nodetype = parserNodeNextSibling(child,child).
  END.

  parserReleaseHandle(child).

END PROCEDURE.
