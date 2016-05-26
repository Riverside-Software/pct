/**
 * Copyright 2005-2016 Riverside Software
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

DEFINE TEMP-TABLE CRCList NO-UNDO
  FIELD ttTable AS CHARACTER
  FIELD ttCRC   AS CHARACTER
  INDEX ttCRC-PK IS PRIMARY UNIQUE ttTable.
 
DEFINE INPUT-OUTPUT PARAMETER TABLE FOR CRCList.

DEFINE VARIABLE i       AS INTEGER    NO-UNDO.

DO i = 1 TO NUM-DBS:
    IF DBTYPE(i) NE "PROGRESS":U THEN NEXT.
    CREATE ALIAS 'DICTDB' FOR DATABASE VALUE(LDBNAME(i)).
    RUN pct/v8/crc.p (INPUT-OUTPUT TABLE CRCList).
END.

RETURN '0'.
