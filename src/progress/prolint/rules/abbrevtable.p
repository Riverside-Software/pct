/* ------------------------------------------------------------------------
   file    :  prolint/rules/abbrevtable.p
   by      :  Igor Natanzon
   purpose :  Identify abbreviated record names by accessing meta schema.
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

RUN searchNode            (hTopnode,                /* "Program_root" node          */
                           "InspectNode":U,         /* name of callback procedure   */
                           "RECORD_NAME":U).        /* list of nodetypes to search  */
RETURN.

PROCEDURE InspectNode :
/* InspectNode is where the actual rule is implemented */
  DEFINE INPUT  PARAMETER theNode        AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER AbortSearch    AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE OUTPUT PARAMETER SearchChildren AS LOGICAL NO-UNDO INITIAL NO.

  DEFINE VARIABLE v-nodeName   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-recordName AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-dbName     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-fullname   AS CHARACTER NO-UNDO.

  IF parserAttrGet(theNode,"storetype":U) NE "st-dbtable":U THEN RETURN.

  v-nodeName = parserGetNodeText(theNode).
  if num-entries(v-nodeName,".":U) eq 2 then
     assign v-dbName      = entry(1,v-nodeName,".":U)
            v-recordName  = entry(2,v-nodeName,".":U).
  else
     v-recordName = v-nodeName.

  run p_checkMeta (v-dbName, v-recordName, output v-fullname).

  if v-fullname ne "" and v-recordName ne v-fullname then
     RUN PublishResult            (compilationunit,
                                   parserGetNodeFilename(theNode),
                                   parserGetNodeLine(theNode),
                                   SUBSTITUTE("Abbreviation of table &1 used (&2)":T,v-fullname,v-recordName),rule_id).

END PROCEDURE.

PROCEDURE p_checkmeta PRIVATE:

  def input parameter  ip-database     as char no-undo.
  def input parameter  ip-table        as char no-undo.

  DEF OUTPUT PARAMETER op-fullname     AS CHAR NO-UNDO.

  DEF VAR v-queryHandle  AS HANDLE NO-UNDO.
  DEF VAR v-bufferHandle AS HANDLE NO-UNDO.
  DEF VAR v-fieldHandle  AS HANDLE NO-UNDO.
  DEF VAR v-tablename    AS CHAR   NO-UNDO.
  DEF VAR v-query        AS CHAR   NO-UNDO.

  DEF VAR v-queryResult  AS LOG NO-UNDO.
  DEF VAR v-idx          AS INT NO-UNDO.

  /* first a quick check.
     'create buffer' will fail for an abbreviated name.
     so if it doesn't fail, we know we don't have an issue.
     This does not help us find the unabbreviated name. */
  CREATE BUFFER v-bufferHandle FOR TABLE ip-table NO-ERROR.
  IF VALID-HANDLE(v-bufferHandle) AND v-bufferHandle:NAME=ip-table THEN DO:
     DELETE OBJECT v-bufferHandle.
     RETURN.
  END.
  IF VALID-HANDLE(v-bufferHandle) THEN
     DELETE OBJECT v-bufferHandle.


  /* find the unabbreviated name */
  CREATE QUERY v-queryHandle.

  dbscan:
  do v-idx = 1 to num-dbs:
     if dbtype(v-idx)<>"PROGRESS":U then 
	    next dbscan.
     if trim(ip-database) eq "" then
        v-tablename = ldbname(v-idx) + "._file":U.
     else
        v-tablename = ip-database + "._file":U.
     create buffer v-bufferHandle for table v-tablename.

     v-queryHandle:set-buffers(v-bufferHandle).
     v-query = substitute("for each &1 where &1._file-name begins '&2' no-lock":U,v-tablename,ip-table).

     v-queryResult = v-queryHandle:QUERY-PREPARE(v-query).

     IF v-queryResult = TRUE THEN DO:
        v-queryHandle:QUERY-OPEN().
        v-queryHandle:GET-FIRST().
        IF NOT v-queryHandle:QUERY-OFF-END THEN DO:
           v-fieldHandle = v-bufferHandle:BUFFER-FIELD('_file-name':U).
           IF VALID-HANDLE(v-fieldHandle) THEN do:
              op-fullname = v-fieldHandle:BUFFER-VALUE().
              leave.
           end.
        END.
     end.
     v-queryHandle:QUERY-CLOSE().
     v-bufferHandle:BUFFER-RELEASE().
     DELETE OBJECT v-bufferHandle.
     if ip-database ne "" then leave dbscan.
  END.
  if op-fullname ne "" then do:
     v-queryHandle:QUERY-CLOSE().
     v-bufferHandle:BUFFER-RELEASE().
  END.

  DELETE OBJECT v-queryHandle.
END PROCEDURE.


