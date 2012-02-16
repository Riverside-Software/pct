/* ------------------------------------------------------------------------
   file    :  rules/ttlock.p
   by      :  Igor Natanzon
   purpose :  Identify locking statements applied to temp-tables and work-tables
    -----------------------------------------------------------------

    Copyright (C) 2003 Igor Natanzon

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
{prolint/core/ttprocedure.i}

RUN searchNode            (hTopnode, "InspectNode":U, "RECORD_NAME":U).

RETURN.

PROCEDURE InspectNode :
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.

  DEFINE VARIABLE nodetype   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE nodeparent AS CHARACTER NO-UNDO.
  DEFINE VARIABLE child      AS INTEGER   NO-UNDO.
  DEFINE VARIABLE parent     AS INTEGER   NO-UNDO.
  DEFINE VARIABLE recordname AS CHARACTER NO-UNDO.
  DEFINE VARIABLE tabletype  AS CHARACTER NO-UNDO.

  IF parserAttrGet(theNode,"storetype":U) EQ "st-dbtable":U THEN RETURN.

  ASSIGN parent      = parserGetHandle()
         child       = parserGetHandle()
         nodeparent  = parserNodeParent(theNode,parent).

  IF NOT CAN-DO("FOR,FIND,CANFIND,PRESELECT":U, nodeparent) THEN NEXT.

  ASSIGN recordname = parserGetNodeText(theNode)
         tabletype  = IF parserAttrGet(theNode,"storetype":U) EQ "st-ttable":U THEN "TEMP-TABLE":U ELSE "WORK-TABLE":U
         nodetype   = parserNodeFirstChild(theNode,child).
  testNode:
  DO WHILE nodetype NE "":
     IF nodetype EQ "NOLOCK":U OR
        nodetype EQ "EXCLUSIVELOCK":U OR
        nodetype EQ "SHARELOCK":U THEN DO:
                 RUN PublishResult            (
                        compilationunit,
                        parserGetNodeFilename(parent),
                        parserGetNodeLine(parent),
                        SUBSTITUTE("&1 on &2 &3 has no effect",CAPS(parserGetNodeText(child)),tabletype, recordname), rule_id).
                 LEAVE testNode.
     END.
     ASSIGN nodetype = parserNodeNextSibling(child,child).
  END.

  parserReleaseHandle(child).
  parserReleaseHandle(parent).

END PROCEDURE.

/* End Rule */