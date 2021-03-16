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

define input parameter ipTable as character no-undo.
define input parameter ipFile  as character no-undo.

{ prodict/dictvar12.i NEW }
{ prodict/user/uservar124.i NEW }

find first dictdb._db.
ASSIGN drec_db     = RECID(_Db)
       user_dbname = (IF _Db._Db-name = ? THEN LDBNAME("DICTDB") ELSE _Db._Db-Name)
       user_dbtype = (IF _Db._Db-name = ? THEN DBTYPE("DICTDB") ELSE _Db._Db-Type).
find first dictdb._file where dictdb._file._file-name = ipTable no-error.

assign user_env[1] = ipTable
       user_env[2] = ipFile
       user_env[3] = "NO-MAP"
       user_env[4] = "100"
       user_env[5] = ""
       user_env[6] = "load-silent"
       user_env[10] = "utf-8".
run prodict/dump/_loddata.p no-error.
