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

DEFINE VARIABLE qSequence   AS HANDLE     NO-UNDO.
DEFINE VARIABLE bSequence   AS HANDLE     NO-UNDO.
DEFINE VARIABLE cEncoding   AS CHARACTER  NO-UNDO.

CREATE QUERY qSequence.
CREATE BUFFER bSequence  FOR TABLE '_Sequence':U.
qSequence:SET-BUFFERS(bSequence).

ASSIGN cEncoding = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'encoding').
IF (cEncoding = ?) OR (cEncoding = '') THEN ASSIGN cEncoding = SESSION:CPSTREAM.

OUTPUT TO VALUE(DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'destDir') + "/_seqvals.d") CONVERT TARGET cEncoding.
qSequence:QUERY-PREPARE('FOR EACH _Sequence':U).
qSequence:QUERY-OPEN().
qSequence:GET-FIRST(NO-LOCK).
REPEAT:
    IF qSequence:QUERY-OFF-END THEN LEAVE.
    EXPORT bSequence:BUFFER-FIELD('_Seq-num':U):BUFFER-VALUE
           bSequence:BUFFER-FIELD('_Seq-name':U):BUFFER-VALUE
           DYNAMIC-CURRENT-VALUE(bSequence:BUFFER-FIELD('_Seq-name':U):BUFFER-VALUE, 'DICTDB').
    qSequence:GET-NEXT(NO-LOCK).
END.
qSequence:QUERY-CLOSE().
DELETE OBJECT bSequence.
DELETE OBJECT qSequence.

PUT UNFORMATTED "." SKIP.
PUT UNFORMATTED "PSC" SKIP.
PUT UNFORMATTED SUBSTITUTE("cpstream=&1", cEncoding) SKIP.
PUT UNFORMATTED "." SKIP.
PUT UNFORMATTED "0000000000" SKIP.
OUTPUT CLOSE.

RETURN '0'.
