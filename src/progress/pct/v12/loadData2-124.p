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

using Progress.Lang.Class.

define variable callback    as rssw.pct.ILoadDataCallback no-undo.
define variable callbackCls as character no-undo.
define variable cTbl        as character no-undo.

{ prodict/dictvar12.i NEW }
{ prodict/user/uservar124.i NEW }

do on error undo, retry:
 if retry then do:
  if valid-object(callback) then callback:onError("Error trapped").
  return '20'.
 end.
 
assign cTbl = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'tableName').
assign callbackCls = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'callbackClass').
if (callbackCls > "") then do:
    callback = cast(Class:GetClass(callbackCls):new(), rssw.pct.ILoadDataCallback).
    callback:initialize(cTbl).
end.

find first dictdb._db.
ASSIGN drec_db     = RECID(_Db)
       user_dbname = (IF _Db._Db-name = ? THEN LDBNAME("DICTDB") ELSE _Db._Db-Name)
       user_dbtype = (IF _Db._Db-name = ? THEN DBTYPE("DICTDB") ELSE _Db._Db-Type).
find first dictdb._file where dictdb._file._file-name = ctbl no-error.
if not available dictdb._file then do:
  if valid-object(callback) then do:
    callback:onError("No table " + ctbl + " found").
  end.
  else do:
    message "No table " + ctbl + " found".
  end.
  return '2'.
end.

define variable logger as rssw.pct.LoadDataLogger no-undo.
logger = new rssw.pct.LoadDataLogger().
assign dictMonitor = logger.

if valid-object(callback) then callback:beforeLoad( DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'fileName')).  
assign user_env[1] = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'tableName')
       user_env[2] = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'srcFile')
       user_env[3] = "NO-MAP"
       user_env[4] = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'errorPercentage')
       user_env[5] = ""
       user_env[6] = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'silent').

run prodict/dump/_loddata.p no-error.
if valid-object(callback) then callback:afterLoad(DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'fileName'), logger).

/* If process failed, return error code */
if logger:loadException or logger:bailed then do:
  return '1'.
end.

return "0":U.
end. /* do on error */
