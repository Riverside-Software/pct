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
 
DEFINE TEMP-TABLE CRCList NO-UNDO
  FIELD ttTable AS CHARACTER
  FIELD ttCRC   AS CHARACTER
  INDEX ttCRC-PK IS PRIMARY UNIQUE ttTable.

DEFINE VARIABLE h AS HANDLE     NO-UNDO.

h = TEMP-TABLE CRCList:HANDLE.
RUN pct/pctCRC.p (INPUT-OUTPUT TABLE-HANDLE h) NO-ERROR.
IF (RETURN-VALUE NE '0') THEN
    RETURN RETURN-VALUE.
OUTPUT TO VALUE(SESSION:PARAMETER).
FOR EACH CRCList NO-LOCK:
  PUT UNFORMATTED CRCList.ttTable CRCList.ttCRC SKIP.
END.
OUTPUT CLOSE.
RETURN '0'.
