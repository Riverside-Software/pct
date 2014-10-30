/* schemadump1.p
Dumps the schema for each database out to a text file
in a format expected by Proparse subroutines.
Assumes that the alias DICTDB already exists.

Input parameter is "outfile". Input ? to just use
"proparse.schema" in your working directory.
*/

DEFINE VARIABLE outFile AS CHARACTER NO-UNDO.

DEFINE VARIABLE dictdb_orig AS CHARACTER NO-UNDO.
DEFINE VARIABLE program2    AS CHARACTER NO-UNDO.
DEFINE VARIABLE dbnum       AS INTEGER NO-UNDO.
DEFINE VARIABLE i1          AS INTEGER NO-UNDO.

ASSIGN outFile = SESSION:PARAMETER.

ASSIGN program2 = REPLACE(PROGRAM-NAME(1), "schemadump1.p", "schemadump2.p").

OUTPUT TO VALUE (outFile).

ASSIGN dictdb_orig = LDBNAME("dictdb":U).
REPEAT dbnum = 1 TO NUM-DBS:
  IF DBTYPE(dbnum) <> "PROGRESS":U THEN NEXT.
  DELETE ALIAS DICTDB.
  CREATE ALIAS DICTDB FOR DATABASE VALUE(LDBNAME(dbnum)).
  PUT UNFORMATTED ":: ":U LDBNAME(dbnum) " ":U dbnum SKIP.
  RUN VALUE(program2).
END.
DELETE ALIAS dictdb.
CREATE ALIAS dictdb FOR DATABASE VALUE(dictdb_orig).

/* Now dump the meta-schema as "dictdb" */
PUT UNFORMATTED ":: dictdb 0":U SKIP.
FOR EACH DICTDB._file WHERE _file._tbl-type <> "T":U NO-LOCK BY _file._file-name:
  PUT UNFORMATTED ": ":U _file._file-name " ":U RECID(_file) SKIP.
  FOR EACH DICTDB._field OF _file NO-LOCK BY _field._field-rpos:
    PUT UNFORMATTED 
       _field._field-name 
       " ":U RECID(_field) 
       " ":U CAPS(_field._data-type) 
       " ":U _field._extent 
       SKIP.
  END.
END.

OUTPUT CLOSE.

RETURN "0".
