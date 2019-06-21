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
 
DEFINE INPUT-OUTPUT PARAMETER TABLE-HANDLE hCRC.

DEFINE VARIABLE i       AS INTEGER    NO-UNDO.
DEFINE VARIABLE hDB     AS HANDLE     NO-UNDO.
DEFINE VARIABLE h_file  AS HANDLE     NO-UNDO.
DEFINE VARIABLE hQuery  AS HANDLE     NO-UNDO.
DEFINE VARIABLE hBuffer AS HANDLE     NO-UNDO.
DEFINE VARIABLE hCRCTab AS HANDLE     NO-UNDO.
DEFINE VARIABLE hCRCVal AS HANDLE     NO-UNDO.
DEFINE VARIABLE hFld1   AS HANDLE     NO-UNDO.
DEFINE VARIABLE hFld2   AS HANDLE     NO-UNDO.

IF (hCRC EQ ?) THEN RETURN '1'.
ASSIGN hBuffer = hCRC:DEFAULT-BUFFER-HANDLE
       hCRCTab = hBuffer:BUFFER-FIELD('ttTable')
       hCRCVal = hBuffer:BUFFER-FIELD('ttCRC').
DO i = 1 TO NUM-DBS:
  /* Flavio Cordova : no CRC for dataservers */
  /* TODO : I'll have to add testcases for dataservers... */
  /* TODO : is this still useful ? Check with Flavio */
  IF DBTYPE(i) NE "PROGRESS":U THEN NEXT.
  CREATE BUFFER hDB FOR TABLE LDBNAME(i) + '._Db'.
  CREATE BUFFER h_File FOR TABLE LDBNAME(i) + '._file'.
  CREATE QUERY hQuery.
  hQuery:SET-BUFFERS(hDB, h_File).
  ASSIGN hFld1 = h_File:BUFFER-FIELD('_file-name':U)
         hFld2 = h_File:BUFFER-FIELD('_crc':U).
  hQuery:QUERY-PREPARE('FOR EACH _Db, EACH _file WHERE _File._Db-recid EQ RECID(_Db) AND _File._File-Number GT 0 AND _File._File-Number LT 32768').
  hQuery:QUERY-OPEN().
  REPEAT:
    hQuery:GET-NEXT().
    IF hQuery:QUERY-OFF-END THEN LEAVE.
    hBuffer:BUFFER-CREATE().
    /* NO-ERROR, because when using multiple schema holders on the same Progress DB */
    /* We get the identical table names for tablespace_name */
    /* In fact, there's still a problem, as I assume the ldbname(i) shouldn't be the one used here */
    /* CRC support with PCTCompile is broken in this revision */
    ASSIGN hCRCTab:BUFFER-VALUE = (IF hDB:BUFFER-FIELD('_Db-slave'):BUFFER-VALUE THEN hDB:BUFFER-FIELD('_Db-name'):BUFFER-VALUE ELSE LDBNAME(i)) + "." + hFld1:BUFFER-VALUE
           hCRCVal:BUFFER-VALUE = hFld2:BUFFER-VALUE.
    hBuffer:BUFFER-RELEASE().
  END.
  hQuery:QUERY-CLOSE().
  DELETE OBJECT hFld1.
  DELETE OBJECT hFld2.
  DELETE OBJECT hQuery.
  DELETE OBJECT h_File.
END.
DELETE OBJECT hCRCTab.
DELETE OBJECT hCRCVal.
DELETE OBJECT hCRC.
RETURN '0'.
