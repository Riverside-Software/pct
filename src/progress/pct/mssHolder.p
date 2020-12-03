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

/** See prodict/mss/_mss_md2.p */

DEFINE VARIABLE shName   AS CHARACTER  NO-UNDO.
DEFINE VARIABlE cp       AS CHARACTER  NO-UNDO.
DEFINE VARIABLE coll     AS CHARACTER  NO-UNDO.
DEFINE VARIABLE caseSens AS CHARACTER  NO-UNDO.
DEFINE VARIABLE usr      AS CHARACTER  NO-UNDO.
DEFINE VARIABLE pwd      AS CHARACTER  NO-UNDO.

DEFINE VARIABLE bDB AS HANDLE NO-UNDO.

ASSIGN shName   = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'SchemaHolderName')
       coll     = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'Collation')
       caseSens = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'CaseSensitive')
       usr      = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'UserName')
       pwd      = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'Password')
       cp       = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'Codepage').

CREATE BUFFER bDB FOR TABLE '_Db':U.

DbRecord:
DO TRANSACTION ON ERROR UNDO, RETRY:
    IF RETRY THEN DO:
        MESSAGE "Unable to create _db record".
        RETURN '1'.
    END.
    
    bDB:BUFFER-CREATE().
    ASSIGN bDB:BUFFER-FIELD('_Db-name'):BUFFER-VALUE      = shName
           bDB:BUFFER-FIELD('_Db-addr'):BUFFER-VALUE      = shName
           bDB:BUFFER-FIELD('_Db-slave'):BUFFER-VALUE     = TRUE
           bDB:BUFFER-FIELD('_Db-comm'):BUFFER-VALUE      = '':U
           bDB:BUFFER-FIELD('_Db-type'):BUFFER-VALUE      = 'MSS':U
           bDB:BUFFER-FIELD('_Db-misc1'):BUFFER-VALUE[1]  = (IF caseSens EQ 'true' THEN 1 ELSE 0)
           bDB:BUFFER-FIELD('_Db-misc2'):BUFFER-VALUE[8]  = ?
           bDB:BUFFER-FIELD('_Db-xl-name'):BUFFER-VALUE   = cp
           bDB:BUFFER-FIELD('_Db-coll-name'):BUFFER-VALUE = coll.
END.
RETURN '0'.
