/* ------------------------------------------------------------------------
   file    :  rules/tableusage.p
   by      :  Igor Natanzon
   purpose :  Identify unused Temp-tables, Work-Tables, and Buffers
    -----------------------------------------------------------------

    Copyright (C) 2001-2004 Igor Natanzon

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
    -----------------------------------------------------------------

   TODO: 1. Retrieve procedure names, function names, or trigger event descriptions
            in order to provide a more detailed warning message. 
         2. Some tree scans should be rewritten using named queries.
   ------------------------------------------------------------------------ */
  
{prolint/core/ruleparams.i}  

DEFINE TEMP-TABLE tt-tableList NO-UNDO
    FIELD tableName   AS CHAR
    FIELD tableFile   AS CHAR
    FIELD tableLine   AS INT
    FIELD tableType   AS CHAR
    FIELD tableBuffer AS CHAR
    FIELD endLine     AS INT
    FIELD isUsed      AS LOG
    FIELD isNew       AS LOG /* Is there a NEW attribute for the DEFINE? */
    FIELD isShared    AS LOG /* Is the definition SHARED? */
    INDEX tableName tableName
    INDEX isUsed isUsed.

DEF BUFFER bf-tt-tableList FOR tt-tableList.

FUNCTION fn-CheckRecord RETURNS LOGICAL PRIVATE(INPUT CHARACTER, INPUT INTEGER) FORWARD.

/* Line number of 'END' token will be used to tag local scope */
DEFINE VARIABLE v-endLine AS INTEGER NO-UNDO.

/* Process global scope */
RUN searchNode            (hTopnode,       
                           "ProcessGlobalDefine":U, 
                           "DEFINE":U).      

/* Process local scope by looking at the END keywords */
RUN searchNode            (hTopnode, 
                           "InspectEndNode":U,
                           "END":U).      

v-endLine = 0. /* Reset for global processing */

/* Process global record references */
RUN searchNode            (hTopnode,       
                           "InspectRecords":U, 
                           "RECORD_NAME":U).      

RUN searchNode            (hTopnode,       
                           "InspectBuffers":U, 
                           "BUFFER":U).
                                 
RUN p_produceReport.

RETURN.

PROCEDURE InspectEndNode :
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.

  DEFINE VARIABLE nodetype   AS CHAR NO-UNDO.
  DEFINE VARIABLE nodeparent AS CHAR NO-UNDO.
  DEFINE VARIABLE parent     AS INT  NO-UNDO.

  ASSIGN parent      = parserGetHandle()
         nodetype    = parserNodeFirstChild(theNode,parent)
         nodeparent  = parserNodeParent(theNode,parent).

  IF CAN-DO("PROCEDURE,FUNCTION,DO,METHOD":U, nodeparent) THEN DO:
     /* If 'DO', check parent of that node to see if it's a trigger */
     IF nodeparent eq "DO":U AND parserNodeStateHead(parent,parent) ne "ON":U THEN DO:
        parserReleaseHandle(parent).
        RETURN.
     END.
     /* Set to line number of END node for local scope processing. Since
        PROCEDURE, FUNCTION, and ON statements cannot be nested, this should work.
     */
     v-endLine = parserGetNodeLine(theNode).

     /* Process local definitions */
     RUN searchNode            (parent, "ProcessLocalDefine":U, "DEFINE":U).

     /* Process local record references */
     RUN searchNode            (parent, "InspectRecords":U,     "RECORD_NAME":U).
     RUN searchNode            (parent, "InspectBuffers":U,     "BUFFER":U).
  END.

  parserReleaseHandle(parent).

  RETURN.
END PROCEDURE.

PROCEDURE ProcessLocalDefine:
  /* The purpose of this procedure is to tag defines as local */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.

  DEFINE VARIABLE nodetype     AS CHAR NO-UNDO.
  DEFINE VARIABLE child        AS INT  NO-UNDO.
  DEFINE VARIABLE v-bufferName AS CHAR NO-UNDO.

  ASSIGN nodetype = parserGetNodeType(theNode).

  /* Temptables and work-tables cannot be defined locally, so only check buffers */
  IF parserAttrGet(theNode,"state2":U) NE "BUFFER":U THEN RETURN.

  ASSIGN child    = parserGetHandle()
         nodetype = parserNodeFirstChild(theNode,child).

  testNode:
  DO WHILE nodetype NE "":
     CASE nodetype:
          WHEN "ID":U          THEN v-bufferName =  parserGetNodeText(child).
          WHEN "RECORD_NAME":U THEN 
	        DO:
		    /* Locate the record and mark as local */
                    FIND tt-tableList where tt-tableList.tableName = v-bufferName and
			 tt-tableList.tableLine = parserGetNodeLine(child) and
		         tt-tableList.tableFile =  parserGetNodeFilename(child) and
			 tt-tableList.tableTYpe = "BUFFER":U NO-ERROR.
		    IF NOT AVAILABLE tt-tableList THEN DO:	/* Can this happen??? */
		       CREATE tt-tableList.
	               ASSIGN tt-tableList.tableLine = parserGetNodeLine(child)
		   	      tt-tableList.tableFile = parserGetNodeFilename(child)
			      tt-tableList.tableType = "BUFFER":U
		              tt-tableList.tableName = v-bufferName.
		    END.
		    ASSIGN tt-tableList.endLine = v-endLine.
	       END.
     END CASE.
     ASSIGN nodetype = parserNodeNextSibling(child,child).
  END.
  parserReleaseHandle(child).
  RETURN.
END PROCEDURE.

PROCEDURE ProcessGlobalDefine :
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.

  DEFINE VARIABLE nodetype AS CHAR NO-UNDO.
  DEFINE VARIABLE child    AS INT  NO-UNDO.

  DEFINE VARIABLE v-isNew     AS LOGICAL NO-UNDO.
  DEFINE VARIABLE v-isShared  AS LOGICAL NO-UNDO.

  IF parserAttrGet(theNode,"state2":U) NE "TEMPTABLE":U AND
     parserAttrGet(theNode,"state2":U) NE "WORKTABLE":U AND
     parserAttrGet(theNode,"state2":U) NE "BUFFER":U THEN RETURN.

  ASSIGN child    = parserGetHandle()
         nodetype = parserNodeFirstChild(theNode,child).

  testNode:
  DO WHILE nodetype NE "":
     IF nodetype EQ "ID":U THEN DO:
        CREATE tt-tableList.
        ASSIGN tt-tableList.tableLine = parserGetNodeLine(child)
	       tt-tableList.tableFile = parserGetNodeFilename(child)
	       tt-tableList.tableType = parserAttrGet(theNode,"state2":U)
	       tt-tableList.tableName = parserGetNodeText(child)
	       tt-tableList.isShared  = v-isShared
	       tt-tableList.isNew     = v-isNew
	       tt-tableList.endLine   = 0. /* Global */
     END.
     ELSE IF nodetype EQ "NEW":U THEN     /* I am assuming that if NEW keyword found, define is also SHARED */
          ASSIGN v-isNew    = TRUE
                 v-isShared = TRUE.
     ELSE IF nodetype EQ "SHARED":U THEN
          ASSIGN v-isShared = TRUE.
     ELSE IF nodetype EQ "RECORD_NAME":U AND tt-tableList.tableType EQ "BUFFER":U THEN
          tt-tableList.tableBuffer = parserGetNodeText(child).
     ASSIGN nodetype = parserNodeNextSibling(child,child).
  END.

  parserReleaseHandle(child).

END PROCEDURE.

PROCEDURE InspectRecords :
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.

  DEFINE VARIABLE child AS INT  NO-UNDO.

  ASSIGN child = parserGetHandle().

  /* RECORD_NAME token shows up in DEFINE BUFFER statement as well, so skip it in that case */
  IF parserNodeStateHead(theNode,child) EQ "DEFINE":U AND parserAttrGet(child,"state2":U) EQ "BUFFER":U THEN RETURN.
  parserReleaseHandle(child).

  fn-CheckRecord(parserGetNodeText(theNode),v-endLine).
  RETURN.
END PROCEDURE.

PROCEDURE InspectBuffers :
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.

  DEFINE VARIABLE tempnode AS INTEGER NO-UNDO.
  
  ASSIGN tempnode = parserGetHandle().
  IF parserNodeParent(theNode, tempnode) <> "Widget_ref":U THEN RETURN.
  IF parserNodeNextSibling(theNode, tempnode) = "ID":U THEN
     fn-CheckRecord(parserGetNodeText(tempnode), v-endLine).
  
  parserReleaseHandle(tempnode).
  RETURN.
END PROCEDURE.

PROCEDURE p_produceReport PRIVATE:
    /* Customization here may include skipping SHARED or NEW SHARED defines from being reported, as
      it may lead to unintended results. 
      Sort by scope - global first 
    */
    FOR EACH tt-tableList WHERE tt-tableList.isUsed = FALSE BY tt-tableList.endLine:
        RUN PublishResult            (compilationunit,
                                      tt-tableList.tableFile,
                                      tt-tableList.tableLine,
                                      substitute("&1 &2&3&4 &5 is not used",if tt-tableList.endLine eq 0 then 'Global' else 'Local',
							   if tt-tableList.isNew eq true then "NEW " else "",
							   if tt-tableList.isShared eq true then "SHARED " else "",
			                                   caps(tt-tableList.tableType),tt-tableList.tableName),rule_id).
    END.
    RETURN.
END PROCEDURE.

FUNCTION fn-CheckRecord RETURNS LOGICAL PRIVATE(ip-recordName AS CHARACTER, ip-endLine AS INTEGER):

  FIND tt-tableList WHERE tt-tableList.tableName EQ ip-recordName AND tt-tableList.endLine = ip-endLine NO-ERROR.
  IF NOT AVAILABLE tt-tableList THEN DO:
     IF ip-endLine EQ 0 THEN RETURN FALSE.

     /* Find global record */
     FIND tt-tableList WHERE tt-tableList.tableName EQ ip-recordName AND tt-tableList.endLine EQ 0 NO-ERROR.
     IF NOT AVAILABLE tt-tableList THEN RETURN FALSE.
  END.

  /* If we determined that a buffer was used, and the buffer was for a local temp/work-table, mark the
     temp/work-table used as well.
  */
  IF tt-tableList.tableType EQ "BUFFER":U THEN DO:
     /* Since temp-table can only be defined globally, look in the global stack for temp-table define */
     FIND FIRST bf-tt-tableList WHERE bf-tt-tableList.tableName = tt-tableList.tableBuffer AND bf-tt-tableList.endLine = 0 NO-ERROR.
     IF AVAILABLE bf-tt-tableList THEN
        bf-tt-tableList.isUsed = TRUE.
  END.
  ASSIGN tt-tableList.isUsed = TRUE.
  RETURN TRUE.
END FUNCTION. /* fn-CheckRecord() */

