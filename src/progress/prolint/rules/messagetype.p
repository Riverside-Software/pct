/* ------------------------------------------------------------------------
   file    :  prolint/rules/messagetype.p
   by      :  Igor Natanzon
   purpose :  Identify any alert message that does not have a type specified.
    -----------------------------------------------------------------

    Copyright (C) 2001,2002 Igor Natanzon

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
                           "MESSAGE":U).            /* list of nodetypes to search  */
RETURN.

PROCEDURE InspectNode :
/* InspectNode is where the actual rule is implemented */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.

  def var nodetype as char no-undo.
  def var node1    as char no-undo.
  def var child    as int no-undo.
  def var child1   as int no-undo.
  def var lTypeFound as log no-undo.

  assign child    = parserGetHandle()
	 child1   = parserGetHandle()
         nodetype = parserNodeFirstChild(theNode,child).

  testNode:
  DO WHILE nodetype NE "":
     lTypeFound = TRUE.
     IF nodetype EQ "VIEWAS":U THEN DO:
        ASSIGN node1      = parserNodeFirstChild(child,child1)
               lTypeFound = FALSE.
        DO WHILE node1 NE "":
	   IF node1 eq "ERROR":U       OR
	      node1 eq "WARNING":U     OR
	      node1 eq "INFORMATION":U OR
	      node1 eq "QUESTION":U    OR
	      node1 eq "MESSAGE":U     THEN DO:
		    lTypeFound = true.
		    leave.
	   END.
           node1 = parserNodeNextSibling(child1,child1).
        END.
        IF lTypeFound EQ FALSE THEN DO:
	   run PublishResult            (compilationunit,
		   	                 parserGetNodeFilename(theNode),
                                         parserGetNodeLine(theNode),
					 "ALERT BOX is missing alert type",rule_id).
           LEAVE testNode.
        end.
        LEAVE testNode.
     end.
     ASSIGN nodetype = parserNodeNextSibling(child,child).
  end.

  parserReleaseHandle(child).
  parserReleaseHandle(child1).

END PROCEDURE.
