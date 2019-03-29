/**
 * Copyright 2005-2018 Riverside Software
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

class rssw.pct.BackupDataCallback inherits rssw.pct.AbstractLoadDataCallback:
  define private property tblName as character no-undo get. set.
  define private property bkupFile as character initial ? no-undo get. set.

  define stream sBackup.

  method public override void initialize(tableName as character):
    if num-entries(tableName) > 1 then undo, throw new Progress.Lang.AppError("BackupDataCallback can only handle one table").
    this-object:tblName = tableName.
  end method.

  method public override void beforeLoad(file as character):
    define variable delCount as integer no-undo.

    this-object:bkupFile = session:temp-directory + '/' + this-object:tblName + '-' + string(year(now), "9999") + string(month(now),"99") + string(day(now),"99") + "-" + replace(substring(string(now),12, 8), ':', '') + '.backup.d'.
    delCount = backupTable (input bkupFile).
    message substitute("&1 records deleted and backed up to &2", delCount, this-object:bkupFile).

  end method.

  method public override void afterLoad(file as character, logger as rssw.pct.LoadDataLogger):

    if logger:loadException or logger:bailed then do:
      message substitute("Restoring &1 content from &2", this-object:tblName, this-object:bkupFile).
      if not logger:loadException then backupTable (input ?).
      if (decimal(substring(replace(proversion(0), '.', session:numeric-decimal-point), 1, 4)) le 11.6) then
        run pct/v11/restoreTableContent.p (this-object:tblName, this-object:bkupFile).
      else if (decimal(substring(replace(proversion(0), '.', session:numeric-decimal-point), 1, 4)) lt 12) then
        run pct/v11/restoreTableContent117.p (this-object:tblName, this-object:bkupFile).
      else
        run pct/v12/restoreTableContent.p (this-object:tblName, this-object:bkupFile).
    end.

  end method.

  method private integer backupTable(ipFileName as character):
    define variable hFile    as handle  no-undo.  
    define variable hQuery   as handle  no-undo.
    define variable opDelCount as integer no-undo.

    if (ipFileName > '') then
      output stream sBackup to value(ipFileName) convert target 'utf-8'.
    create buffer hFile for table this-object:tblName.
    create query hQuery.
    hQuery:set-buffers(hFile).
    hQuery:query-prepare('for each ' + this-object:tblName).
    hQuery:query-open().
    repeat transaction:
      hQuery:get-next(exclusive-lock).
      IF hQuery:query-off-end then leave.
      if (ipFileName > '') then 
        put stream sBackup unformatted exportRecord(input hFile, input " ") skip.
      hFile:buffer-delete().
      assign opDelCount = opDelCount + 1.
    end.
    hQuery:query-close().
    delete object hFile.
    delete object hQuery.

    if (ipFileName > '') then
      output stream sBackup close.

    return opDelCount.
END method.

  method private character exportRecord (input hRecord  as handle, input cDelim  as character):
    DEFINE VARIABLE hFld     AS HANDLE    NO-UNDO.
    DEFINE VARIABLE iCnt     AS INTEGER   NO-UNDO.
    DEFINE VARIABLE iExtnt   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE cTmp     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cArray   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cResult  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cLobname AS CHARACTER NO-UNDO.

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
  end method.

end class.

