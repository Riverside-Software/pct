define input parameter ipTable as character no-undo.
define input parameter ipFile  as character no-undo.

{ prodict/dictvar11.i NEW }
{ prodict/user/uservar113.i NEW }

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
