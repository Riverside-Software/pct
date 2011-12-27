/* ------------------------------------------------------------------------
   file    :  prolint/rules/alertmessage.p
   by      :  Igor Natanzon
   purpose :  Identify any message that's not an alert box.
    -----------------------------------------------------------------

    Copyright (C) 2002,2003 Igor Natanzon

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

  def var nodetype   as char no-undo.
  def var child      as int  no-undo.
  def var lTypeFound as log  no-undo.
  def var lForm      as log  no-undo.

  assign child    = parserGetHandle()
         nodetype = parserNodeFirstChild(theNode,child).

  testNode:
  DO WHILE nodetype NE "":
     IF nodetype EQ "VIEWAS":U THEN DO:
        assign lTypeFound = TRUE
	       lForm      = TRUE.
        leave testNode.
     end.
     IF nodetype EQ "Form_Item":U then 
        lForm = true.
     ASSIGN nodetype = parserNodeNextSibling(child,child).
  end.

  if lForm eq true and not lTypeFound then 
      run PublishResult            (compilationunit,
                                         parserGetNodeFilename(theNode),
                                         parserGetNodeLine(theNode),
                                         "MESSAGE not an Alert Box",
                                         rule_id).
  parserReleaseHandle(child).

END PROCEDURE.


