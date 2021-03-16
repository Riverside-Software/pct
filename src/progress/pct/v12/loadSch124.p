/**
 * Copyright 2005-2019 Riverside Software
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

USING Progress.Lang.Class.
USING OpenEdge.DataAdmin.Binding.DataDefinitionOptions.
USING OpenEdge.DataAdmin.Binding.IDataDefinitionLoader.

DEFINE VARIABLE hQuery  AS HANDLE    NO-UNDO.
DEFINE VARIABLE hBuffer AS HANDLE    NO-UNDO.
DEFINE TEMP-TABLE ttUnfrozen NO-UNDO
   FIELD cTable AS CHARACTER.

DEFINE VARIABLE cFileList AS CHARACTER NO-UNDO.
DEFINE VARIABLE lUnfreeze AS LOGICAL   NO-UNDO.
DEFINE VARIABLE lCommit   AS LOGICAL   NO-UNDO.
DEFINE VARIABLE lOnline   AS LOGICAL   NO-UNDO.
DEFINE VARIABLE lInactIdx AS LOGICAL   NO-UNDO.

DEFINE VARIABLE cFile       AS CHARACTER NO-UNDO.
DEFINE VARIABLE callbackCls AS CHARACTER NO-UNDO.
DEFINE VARIABLE analyzerCls AS CHARACTER NO-UNDO.
DEFINE VARIABLE callback    AS rssw.pct.ILoadCallback NO-UNDO.
DEFINE VARIABLE analyzer    AS IDataDefinitionLoader NO-UNDO.
DEFINE VARIABLE logger      AS rssw.pct.LoadLogger  NO-UNDO.
DEFINE VARIABLE dictOpts    AS rssw.pct.LoadOptions NO-UNDO.
DEFINE VARIABLE dictOpts2   AS DataDefinitionOptions NO-UNDO.
DEFINE VARIABLE cLogFile    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lErr        AS LOGICAL   NO-UNDO INITIAL FALSE.

DEFINE STREAM sLogFile.

ASSIGN callbackCls = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'callbackClass')
       analyzerCls = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'analyzerClass')
       cFileList = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'fileList')
       lUnfreeze = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'unfreeze') EQ "true":U
       lCommit   = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'commitWhenErrors') EQ "true":U
       lOnline   = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'online') EQ "true":U
       lInactIdx = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'inactiveIdx') EQ "true":U.

IF (callbackCls > "") THEN DO:
    callback = CAST(Class:GetClass(callbackCls):new(), rssw.pct.ILoadCallback).
END.
IF (analyzerCls > "") THEN DO:
    analyzer = CAST(Class:GetClass(analyzerCls):new(), IDataDefinitionLoader).
end.

IF VALID-OBJECT(callback) THEN
  callback:beforeUnfreeze().

/** Added by Evan Todd */
IF lUnfreeze THEN DO:
   CREATE BUFFER hBuffer FOR TABLE "_file".
   CREATE QUERY hQuery.
   hQuery:SET-BUFFERS(hBuffer).
   hQuery:QUERY-PREPARE("for each _file where _file-number > 0 " +
                        "and _File-Number < 32768 " +
                        "and _frozen = yes").
   hQuery:QUERY-OPEN.
   hQuery:GET-FIRST().
   DO TRANSACTION WHILE NOT hQuery:QUERY-OFF-END:
      hQuery:GET-CURRENT(EXCLUSIVE-LOCK).
      CREATE ttUnfrozen.
      ASSIGN ttUnfrozen.cTable = hBuffer:BUFFER-FIELD("_file-name"):BUFFER-VALUE
             hBuffer:BUFFER-FIELD("_frozen"):BUFFER-VALUE = FALSE.
      hQuery:GET-NEXT.
   END.
   hQuery:QUERY-CLOSE.   
END.

IF VALID-OBJECT(callback) THEN
  callback:beforeFileList().

INPUT FROM VALUE(cFileList).
RptLoop:
REPEAT:
  IMPORT UNFORMATTED cFile.

  /* Clears existing error files */
  FILE-INFO:FILE-NAME = LDBNAME("DICTDB") + ".e".
  IF FILE-INFO:FULL-PATHNAME NE ? THEN DO:
    OS-DELETE VALUE(FILE-INFO:FULL-PATHNAME).
  END.

  MESSAGE 'Loading ' + cFile + ' in database'.

  ASSIGN logger = NEW rssw.pct.LoadLogger().
  ASSIGN dictOpts = NEW rssw.pct.LoadOptions(logger).
  ASSIGN dictOpts:FileName = cFile
         dictOpts:ForceCommit = lCommit
         dictOpts:SchemaChange = (IF lOnline THEN 'NEW OBJECTS' ELSE '')
         dictOpts:ForceIndexDeactivate = lInactIdx
         dictOpts:PreDeployLoad = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'preDeploySection')
         dictOpts:TriggerLoad = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'triggerSection')
         dictOpts:PostDeployLoad = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'postDeploySection')
         dictOpts:OfflineLoad = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'offlineSection')
         .

  IF VALID-OBJECT(analyzer) THEN DO:
    ASSIGN dictOpts2 = NEW rssw.pct.LoadOptions(analyzer).
    ASSIGN dictOpts2:FileName = cFile
           dictOpts2:ForceCommit = lCommit
           dictOpts2:SchemaChange = (IF lOnline THEN 'NEW OBJECTS' ELSE '')
           dictOpts2:ForceIndexDeactivate = lInactIdx.
  END.

  IF VALID-OBJECT(callback) THEN
    callback:beforeFile(cFile).
  DO ON ERROR UNDO, LEAVE:
    RUN prodict/dump/_load_df.p (dictOpts).
    IF VALID-OBJECT(dictOpts2) THEN
      RUN prodict/dump/_load_df.p (dictOpts2).

    FINALLY:
      /* If file is present, then there are errors or warnings during load */
      FILE-INFO:FILE-NAME = LDBNAME("DICTDB") + ".e".
      IF (FILE-INFO:FULL-PATHNAME NE ?) THEN DO:
        ASSIGN cLogFile = FILE-INFO:FULL-PATHNAME + "." + STRING(TODAY, "99999999") + "." + STRING(TIME) + "." + STRING(ETIME(FALSE)).
        OS-RENAME VALUE(FILE-INFO:FULL-PATHNAME) VALUE(cLogFile).
        MESSAGE SUBSTITUTE('&1 errors and &2 warnings during load', logger:numErrors, logger:numWarnings).
        MESSAGE 'Log file can be found in ' + cLogFile.
      END.
      IF VALID-OBJECT(callback) THEN
        callback:afterFile(cFile, logger).

      IF (logger:numErrors GT 0) THEN DO:
        lErr = TRUE.
        IF NOT lCommit THEN LEAVE RptLoop.
      END.

    END FINALLY.
  END. 
  

  DELETE OBJECT logger.
  DELETE OBJECT dictOpts.
END.
INPUT CLOSE.

IF VALID-OBJECT(callback) THEN
  callback:afterFileList().

IF VALID-OBJECT(callback) THEN
  callback:beforeRefreeze().
IF lUnfreeze THEN DO:
   FOR EACH ttUnfrozen:
      hQuery:QUERY-PREPARE("for each _file where _file-name = '" + ttUnfrozen.cTable + "'").
      hQuery:QUERY-OPEN.
      hQuery:GET-FIRST.
      IF NOT hQuery:QUERY-OFF-END THEN DO TRANSACTION:
         hQuery:GET-CURRENT(EXCLUSIVE-LOCK).
         hBuffer:BUFFER-FIELD("_frozen"):BUFFER-VALUE = TRUE.
      END.
      hQuery:QUERY-CLOSE.
   END.
   DELETE OBJECT hQuery.
   DELETE OBJECT hBuffer.
END.
IF VALID-OBJECT(callback) THEN
  callback:afterRefreeze().

IF lErr AND NOT lCommit THEN RETURN '1'.
RETURN '0'.
