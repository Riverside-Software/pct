{prolint/core/ttprocedure.i}

/* tt_object contains all variables and parameters, defined in CompilationUnit */
def temp-table tt_object no-undo
    field sourcefile  as char  /* sourcefile where object was defined               */
    field linenumber  as inte  /* linenumber in sourcefile where object was defined */
    field ProcRowid   as rowid /* function|procedure where object was defined       */
    field ProcName    as char /* function|procedure where object was defined       */
    field ParamType   as char  /* VARIABLE|STREAM|INPUT|INPUTOUTPUT|OUTPUT|PARAMETER */
    field objDataType as char
    field objScope    as char  /* MAIN|LOCAL|SHARED|GLOBALSHARED */
    field objType     as char  /* parameter|variable                                */
    field objName     as char  /* identifier                                        */
    field relName     as char  /* 2nd identifier : table-name for buffer, field-name for like */
    index idx_objname  as primary objname ProcRowid
    .
