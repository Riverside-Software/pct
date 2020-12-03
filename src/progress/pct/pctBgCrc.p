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
 
PROCEDURE getCRC.
    DEFINE INPUT  PARAMETER cPrm  AS CHARACTER  NO-UNDO.
    DEFINE OUTPUT PARAMETER opOK  AS LOGICAL    NO-UNDO.
    DEFINE OUTPUT PARAMETER opMsg AS CHARACTER  NO-UNDO.

    DEFINE VARIABLE i       AS INTEGER    NO-UNDO.
    DEFINE VARIABLE h_file  AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hQuery  AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hFld1   AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hFld2   AS HANDLE     NO-UNDO.

    DEFINE VARIABLE cReturn AS CHARACTER  NO-UNDO INITIAL '':U.

    DO i = 1 TO NUM-DBS:
        CREATE BUFFER h_File FOR TABLE LDBNAME(i) + '._file'.
        CREATE QUERY hQuery.
        hQuery:SET-BUFFERS(h_File).
        ASSIGN hFld1 = h_File:BUFFER-FIELD('_file-name':U)
               hFld2 = h_File:BUFFER-FIELD('_crc':U).
        hQuery:QUERY-PREPARE('FOR EACH _file WHERE _File._File-Number GT 0 AND _File._File-Number LT 32768').
        hQuery:QUERY-OPEN().
        REPEAT:
            hQuery:GET-NEXT().
            IF hQuery:QUERY-OFF-END THEN LEAVE.
            ASSIGN cReturn = cReturn + (if creturn eq '' then '' else '~n') + LDBNAME(i) + "." + string(hFld1:BUFFER-VALUE) + " " + string(hFld2:BUFFER-VALUE).
        END.
        hQuery:QUERY-CLOSE().
        DELETE OBJECT hFld1.
        DELETE OBJECT hFld2.
        DELETE OBJECT hQuery.
        DELETE OBJECT h_File.
    END.

    ASSIGN opOK = TRUE.    
END PROCEDURE.
