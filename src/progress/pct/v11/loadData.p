/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) The Apache Software Foundation.  All rights
 * reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution, if
 *    any, must include the following acknowlegement:
 *       "This product includes software developed by the
 *        Apache Software Foundation (http://www.apache.org/)."
 *    Alternately, this acknowlegement may appear in the software itself,
 *    if and wherever such third-party acknowlegements normally appear.
 *
 * 4. The names "Ant" and "Apache Software
 *    Foundation" must not be used to endorse or promote products derived
 *    from this software without prior written permission. For written
 *    permission, please contact apache@apache.org.
 *
 * 5. Products derived from this software may not be called "Apache"
 *    nor may "Apache" appear in their names without prior written
 *    permission of the Apache Group.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE APACHE SOFTWARE FOUNDATION OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation.  For more
 * information on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 */

using OpenEdge.DataAdmin.Binding.ITableDataMonitor from propath .
using Progress.Lang.Class.

define variable callback    as rssw.pct.ILoadDataCallback.
define variable callbackCls as character no-undo.
define variable cTbl        as character no-undo.

define stream sBackup.

FUNCTION dynExport RETURNS CHARACTER
    (INPUT hRecord  AS HANDLE,
     INPUT cDelim   AS CHARACTER) FORWARD.

{ prodict/dictvar11.i NEW }
{ prodict/user/uservar113.i NEW }

do on error undo, retry:
 if retry then do:
  if valid-object(callback) then callback:onError("Error trapped").
  return '20'.
 end.
 
assign cTbl = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'tableName').
assign callbackCls = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'callbackClass').
if (callbackCls > "") then do:
    callback = cast(Class:GetClass(callbackCls):new(), rssw.pct.ILoadDataCallback).
    callback:initialize(cTbl).
end.

find first dictdb._db.
ASSIGN drec_db     = RECID(_Db)
       user_dbname = (IF _Db._Db-name = ? THEN LDBNAME("DICTDB") ELSE _Db._Db-Name)
       user_dbtype = (IF _Db._Db-name = ? THEN DBTYPE("DICTDB") ELSE _Db._Db-Type).
find first dictdb._file where dictdb._file._file-name = ctbl no-error.
if not available dictdb._file then do:
  if valid-object(callback) then do:
    callback:onError("No table " + ctbl + " found").
  end.
  else do:
    message "No table " + ctbl + " found".
  end.
  return '2'.
end.

if dynamic-function('getParameter' IN SOURCE-PROCEDURE, INPUT 'append') = 'false' then do:
  if valid-object(callback) then callback:beforePurge().

  define variable hFile    as handle  no-undo.  
  define variable hQuery   as handle  no-undo.
  define variable delCount as integer no-undo.

  output stream sBackup to value(session:temp-directory + '/' + cTbl + '-' + string(year(now),"9999") + string(month(now),"99") + string(day(now),"99") + "-" + replace(substring(string(now),12, 8), ':', '') + '.backup.d').
    create buffer hFile for table ctbl.
    create query hQuery.
    hQuery:set-buffers(hFile).
    hQuery:query-prepare('for each ' + cTbl).
    hQuery:query-open().
    repeat transaction:
      hQuery:get-next(exclusive-lock).
      IF hQuery:query-off-end then leave.
      put stream sBackup unformatted dynExport(INPUT hFile, INPUT " ") skip.
      hFile:buffer-delete().
      assign delCount = delCount + 1.
    END.
    hQuery:query-close().
    delete object hFile.
    delete object hQuery.
  output stream sBackup close.

  if valid-object(callback) then callback:afterPurge( delCount).  
end.

define variable logger as rssw.pct.LoadDataLogger.
logger = new rssw.pct.LoadDataLogger().
assign dictMonitor = logger.

if valid-object(callback) then callback:beforeLoad( DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'fileName')).  
assign user_env[1] = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'tableName')
       user_env[2] = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'srcdir') + '/' + DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'fileName')
       user_env[3] = "NO-MAP"
       user_env[4] = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'errorPercentage')
       user_env[5] = ""
       user_env[6] = "utf-8".


run prodict/dump/_loddata.p no-error.
if valid-object(callback) then callback:afterLoad( DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'fileName'), logger).  
if logger:loadException then return '1'.
if (logger:bailed) then return '1'.

return "0":U.
end.

FUNCTION dynExport RETURNS CHARACTER
    (INPUT hRecord  AS HANDLE,
     INPUT cDelim   AS CHARACTER):

  DEF VAR hFld     AS HANDLE    NO-UNDO.
  DEF VAR iCnt     AS INTEGER   NO-UNDO.
  DEF VAR iExtnt   AS INTEGER   NO-UNDO.
  DEF VAR cTmp     AS CHARACTER NO-UNDO.
  DEF VAR cArray   AS CHARACTER NO-UNDO.
  DEF VAR cResult  AS CHARACTER NO-UNDO.
  DEF VAR cLobname AS CHARACTER NO-UNDO.

  IF hRecord:TYPE <> "BUFFER" THEN
      RETURN ?.

  DO iCnt = 1 TO hRecord:NUM-FIELDS:

      ASSIGN hFld = hRecord:BUFFER-FIELD(iCnt).

      /* Handle export for large objects by writing them out to .blb files. This section should be omitted Progress 9.x */
      /* Names for blobs are NOT guaranteed the same as the static EXPORT statement. IMPORT does handle them correctly though. */
      IF hFld:DATA-TYPE = "clob" OR hFld:DATA-TYPE = "blob" THEN DO:
          IF hFld:BUFFER-VALUE = ? THEN DO:
             cResult = cResult + "?" + cDelim.
          END.
          ELSE DO:
              cLobname =  hFld:NAME + (IF hFld:DATA-TYPE = "clob" THEN "!" + GET-CODEPAGE(hFld:BUFFER-VALUE) + "!" ELSE "") + hRecord:TABLE + "_" + STRING(hRecord:RECID) + ".blb".
              COPY-LOB FROM hFld:BUFFER-VALUE TO FILE session:temp-directory + '/' + cLobname NO-CONVERT.
              cResult = cResult + QUOTER(cLobname) + cDelim.
          END.
          NEXT.
      END.
      
      IF hFld:EXTENT = 0 THEN DO:
         IF hFld:BUFFER-VALUE = ? then cTmp = "?".
            ELSE 
         
         CASE hFld:DATA-TYPE:
              WHEN "character"      THEN cTmp = QUOTER(hFld:BUFFER-VALUE).
              WHEN "raw"            THEN cTmp = '"' + STRING(hFld:BUFFER-VALUE) + '"'.
              WHEN "datetime" OR 
                 WHEN "datetime-tz" THEN cTmp = string(year(hFld:BUFFER-VALUE),"9999") + "-" + string(month(hFld:BUFFER-VALUE),"99") + "-" + string(day(hFld:BUFFER-VALUE),"99") + "T" + substring(string(hFld:BUFFER-VALUE),12).
             OTHERWISE                cTmp = STRING(hFld:BUFFER-VALUE).
         END CASE.
         
         cResult = cResult + cTmp + cDelim.
      END.
      ELSE DO:
          cArray = "".   
          DO iExtnt = 1 TO hFld:EXTENT:
              IF hFld:BUFFER-VALUE(iExtnt) = ? THEN cTmp = "?".
                 ELSE

              CASE hFld:DATA-TYPE:
                  WHEN "character"      THEN cTmp = QUOTER(hFld:BUFFER-VALUE(iExtnt)).
                  WHEN "raw"            THEN cTmp = '"' + STRING(hFld:BUFFER-VALUE(iExtnt)) + '"'.
                  WHEN "datetime" OR 
                  WHEN "datetime-tz"    THEN cTmp = string(year(hFld:BUFFER-VALUE(iExtnt)),"9999") + "-" + string(month(hFld:BUFFER-VALUE(iExtnt)),"99") + "-" + string(day(hFld:BUFFER-VALUE(iExtnt)),"99") + "T" + substring(string(hFld:BUFFER-VALUE(iExtnt)),12).
                 OTHERWISE                cTmp = STRING(hFld:BUFFER-VALUE(iExtnt)).
              END CASE.

              cArray = cArray + cTmp + cDelim.
          END.
          cResult = cResult + RIGHT-TRIM(cArray,cDelim) + cDelim.
      END.
  END.
  RETURN RIGHT-TRIM(cResult,cDelim).
END.