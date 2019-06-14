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

DEFINE VARIABLE hQuery  AS HANDLE    NO-UNDO.
DEFINE VARIABLE hBuffer AS HANDLE    NO-UNDO.
DEFINE TEMP-TABLE ttUnfrozen NO-UNDO
   FIELD cTable AS CHARACTER.

/*
 * Parameters from ANT call 
 */
DEFINE VARIABLE cFileList AS CHARACTER NO-UNDO.
DEFINE VARIABLE cFile     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lUnfreeze AS LOGICAL   NO-UNDO.
DEFINE VARIABLE lCommit   AS LOGICAL   NO-UNDO.
DEFINE VARIABLE lOnline   AS LOGICAL   NO-UNDO.
DEFINE VARIABLE lErr      AS LOGICAL   NO-UNDO INITIAL FALSE.
DEFINE VARIABLE iErrors   AS INTEGER   NO-UNDO.
DEFINE VARIABLE iWarnings AS INTEGER   NO-UNDO.
DEFINE VARIABLE cLine     AS CHARACTER NO-UNDO.
DEFINE VARIABLE cLogFile  AS CHARACTER NO-UNDO.

DEFINE STREAM sLogFile.

ASSIGN cFileList = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'fileList')
       lUnfreeze = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'unfreeze') EQ "true":U
       lCommit   = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'commitWhenErrors') EQ "true":U
       lOnline   = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'online') EQ "true":U.

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
end.

&IF INTEGER(SUBSTRING(PROVERSION, 1, INDEX(PROVERSION, '.'))) GE 10 &THEN
IF lOnline THEN
  SESSION:SCHEMA-CHANGE = 'NEW OBJECTS'.
&ENDIF

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
  RUN prodict/load_df.p (INPUT cFile + ',' + STRING(lCommit, 'yes/no')) NO-ERROR.

  /* If file is present, then there are errors or warnings during load */
  FILE-INFO:FILE-NAME = LDBNAME("DICTDB") + ".e".
  IF (FILE-INFO:FULL-PATHNAME NE ?) THEN DO:
    ASSIGN iWarnings = 0 iErrors = 0.
    INPUT STREAM sLogFile FROM VALUE(FILE-INFO:FULL-PATHNAME).
    REPEAT:
      IMPORT STREAM sLogFile UNFORMATTED cLine.
      IF (cLine BEGINS '** Error') THEN ASSIGN iErrors = iErrors + 1.
      ELSE IF (LENGTH(cLine) GE 25) AND (cLine BEGINS '** ') AND (SUBSTRING(cLine, LENGTH(cLine) - 19) EQ ' caused a warning **') THEN ASSIGN iWarnings = iWarnings + 1.
    END.
    INPUT STREAM sLogFile CLOSE.
    ASSIGN cLogFile = FILE-INFO:FULL-PATHNAME + "." + STRING(TODAY, "99999999") + "." + STRING(TIME) + "." + STRING(ETIME(FALSE)).
    OS-RENAME VALUE(FILE-INFO:FULL-PATHNAME) VALUE(cLogFile).
    MESSAGE SUBSTITUTE('&1 errors and &2 warnings during load', iErrors, iWarnings).
    MESSAGE 'Log file can be found in ' + cLogFile.
    IF (iErrors GT 0) THEN DO:
      lErr = TRUE.
      IF NOT lCommit THEN LEAVE RptLoop.
    END.
  END.
END.
INPUT CLOSE.

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

IF lErr AND NOT lCommit THEN RETURN '1'.
RETURN '0'.