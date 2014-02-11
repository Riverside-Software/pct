/* schemadump2.p
Dumps the schema for DICTDB
*/

FOR EACH DICTDB._file WHERE _file._tbl-type = "T":U NO-LOCK BY _file._file-name:
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