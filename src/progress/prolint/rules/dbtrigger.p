/* ------------------------------------------------------------------------
   file    :  prolint/rules/dbtrigger.p
   by      :  Igor Natanzon
   purpose :  Identify any use of a trigger disable statement
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
                           "DISABLE":U).              /* list of nodetypes to search  */

RETURN.

PROCEDURE InspectNode :
/* InspectNode is where the actual rule is implemented */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.

  def var nodetype      as char no-undo.
  def var v-triggerType as char no-undo.
  def var v-tableName   as char no-undo.
  def var child         as int  no-undo.

  ASSIGN child    = parserGetHandle()
         nodetype = parserNodeFirstChild(theNode,child).

  IF nodetype EQ "TRIGGERS":U THEN DO:

     nodetype = parserNodeNextSibling(child,child). 

     DO WHILE nodetype NE "":
        CASE nodetype:
             WHEN "DUMP":U OR
	     WHEN "LOAD":U THEN v-triggerType = nodetype.
             WHEN "RECORD_NAME":U THEN v-tableName = parserGetNodeText(child).
        END CASE.
        nodetype = parserNodeNextSibling(child,child). 
     END.
     
     RUN PublishResult            (compilationunit,
                                   parserGetNodeFilename(theNode),
                                   parserGetNodeLine(theNode),
                                   substitute("&1 TRIGGERS disabled on table &2":U,v-triggerType,v-tableName), rule_id).
  end.
  parserReleaseHandle(child).

END PROCEDURE.
