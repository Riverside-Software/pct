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

DEFINE TEMP-TABLE ttIncExc NO-UNDO
  FIELD order AS INTEGER
  FIELD inc   AS LOGICAL
  FIELD pattern AS CHARACTER
  INDEX ttIncExc IS PRIMARY UNIQUE order ASCENDING.

DEFINE VARIABLE i          AS INTEGER    NO-UNDO.
DEFINE VARIABLE bFile      AS HANDLE     NO-UNDO.
DEFINE VARIABLE qry        AS HANDLE     NO-UNDO.
DEFINE VARIABLE bfFileName AS HANDLE     NO-UNDO.
DEFINE VARIABLE lInc       AS LOGICAL    NO-UNDO.

OUTPUT TO VALUE(ENTRY(1, SESSION:PARAMETER, '|':U)).

DO i = 2 TO NUM-ENTRIES(SESSION:PARAMETER, '|':U):
  CREATE ttIncExc.
  ASSIGN ttIncExc.order = i
         ttIncExc.inc   = (ENTRY(1, ENTRY(i, SESSION:PARAMETER, '|':U), '$':U) EQ 'I':U)
         ttIncExc.pattern = ENTRY(2, ENTRY(i, SESSION:PARAMETER, '|':U), '$':U).
END.

DO i = 1 TO NUM-DBS:
  IF DBTYPE(i) NE "PROGRESS":U THEN NEXT.
  CREATE BUFFER bFile FOR TABLE LDBNAME(i) + '._file'.
  CREATE QUERY qry.
  qry:SET-BUFFERS(bFile).
  ASSIGN bfFileName = bFile:BUFFER-FIELD('_file-name':U).
  qry:QUERY-PREPARE('FOR EACH _file WHERE _File._File-Number GT 0 AND _File._File-Number LT 32768').
  qry:QUERY-OPEN().
  REPEAT:
    qry:GET-NEXT(NO-LOCK).
    IF qry:QUERY-OFF-END THEN LEAVE.
    ASSIGN lInc = TRUE.
    FOR EACH ttIncExc NO-LOCK BY order:
      IF (lInc EQ TRUE) AND (ttIncExc.inc EQ FALSE) THEN DO:
        ASSIGN lInc = NOT (bfFileName:BUFFER-VALUE MATCHES ttIncExc.pattern).
      END.
      ELSE IF (lInc EQ FALSE) AND (ttIncExc.inc EQ TRUE) THEN DO:
        ASSIGN lInc = (bfFileName:BUFFER-VALUE MATCHES ttIncExc.pattern).
      END.
    END.
    IF (lInc EQ TRUE) THEN
      PUT UNFORMATTED bfFileName:BUFFER-VALUE SKIP.
  END.
  qry:QUERY-CLOSE().
  DELETE OBJECT bfFileName.
  DELETE OBJECT qry.
  DELETE OBJECT bFile.
END.
OUTPUT CLOSE.
RETURN '0'.
