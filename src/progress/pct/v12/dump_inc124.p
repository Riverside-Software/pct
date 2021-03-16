/*********************************************************************
* Copyright (C) 2000,2011,2020 by Progress Software Corporation. All *
* rights reserved. Prior versions of this work may contain portions  *
* contributed by participants of Possenet.                           *
*                                                                    *
*********************************************************************/


/*--------------------------------------------------------------------   

File: prodict/dump_inc.p

Description:
    Batch-mode incremental .df maker 
    DICTDB  is the current database 
            (it's the first connected database, "master")
    DICTDB2 is the database chosen to compare against (second connected,
            (it's the second connected database,

Usage:
    In scripts, e.q.:
       #!/bin/sh
       DUMP_INC_DFFILE=/tmp/delta.df
       DUMP_INC_CODEPAGE=iso8859-2
       DUMP_INC_INDEXMODE=0
       DUMP_INC_DUMPSECTION=No
       DUMP_INC_RENAMEFILE=/tmp/master.rf
       DUMP_INC_DEBUG=2
       export DUMP_INC_DFFILE DUMP_INC_CODEPAGE DUMP_INC_INDEXMODE DUMP_INC_DUMPSECTION \
              DUMP_INC_RENAMEFILE DUMP_INC_DEBUG

       $DLC/bin/_progres -b -db master \
                            -db slave  \ 
                            -p prodict/dump_inc.p > /tmp/dump_inc.log
    DataServer Usage:

       $DLC/bin/_progres -b -db master \
                            -db slave  \ 
                            -p prodict/dump_inc.p > /tmp/dump_inc.log

       SHDBNAME1=/dlc/schema-holder1.db
       SHDBNAME2=/dlc/schema-holder2.db
       MSSDBNAME=<logical database name inside SHDBNAME1 schema holder with MSS foreign schema master target>
       MSSDBNAME2=<logical database name inside SHDBNAME2 schema holder with MSS foreign schema slave target>
       ORADBNAME1=<logical database name inside SHDBNAME1 schema holder with ORACLE foreign schema master target>
       ORADBNAME2=<logical database name inside SHDBNAME2 schema holder with ORACLE foreign schema slave target>

       NOTE: If -db parameters are not set at run-time, environment variables must be set to make up for them.
             If -db parameters are set at run-time, they are used for defaulting when certain environment variables is not set.
    

Environment Variables:
    DUMP_INC_DFFILE          : name of file to dump to
    DUMP_INC_CODEPAGE        : output codepage
    DUMP_INC_INDEXMODE       : index-mode for newly created indexes in exsting
                               tables: 0 = all indexes active
                                       1 = all unique indexes inactive
                                       2 = all indexes inactive
    DUMP_INC_DUMPSECTION     : whether dump the sections which 
                               support online schema change feature
    DUMP_INC_RENAMEFILE      : name of the file with rename definitions
    DUMP_INC_DEBUG           : debug-level: 0 = debug off (only errors
                                                and important warnings)
                                            1 = all the above plus all warnings
                                            2 = all the above plus config info
    
History
    Gary C    01/06/21  This FILE created, author of the original idea
    vap       02/01/29  patched accordingly to changed specs
    moloney   13/06/12  Extended to schema holder comparisons
    tmasood   11/11/20  Include four new sections to support online schema change feature.

Code-page - support:
    code-page = ?,""          : default conversion (SESSION:STREAM)
    code-page = "<code-page>" : convert to <code-page>

    if not convertable to code-page try to convert to SESSION:STREAM

rename field support
  The rename-file parameter is used to identify tables, database fields
  and sequences that have changed names. The format of the file is a comma 
  seperated list that identifies the renamed object, its old name and the new 
  name. When an object is found missing, this file is checked to determine if
  it was renamed.  If no matching entry is found, then the object
  If rename-file is ? or "", then all missing objects are deleted.
  The rename-file has following format:
       T,<old-table-name>,<new-table-name>
       F,<table-name>,<old-field-name>,<new-field-name>
       S,<old-sequence-name>,<new-sequence-name>


Silent Icremental dump process:
  FOR OE Architect: CR# OE00198400

  This is an example on how to call this proc persistently to set the
  newly added option of silent dump and to catch any errors:
    
routine-level on error undo, throw.
define variable h as handle no-undo.

CONNECT -1 t1 NO-ERROR.
CREATE ALIAS "DICTDB2":U FOR DATABASE t1.
run prodict/dump_inc.p PERSISTENT SET h .
run setFileName in h("inc7.df").
run setCodePage in h("ibm850").
run setIndexMode in h("active").
run setRenameFilename in h("r.rf").
run setDebugMode in h(1).
run setSilent in h(yes).
RUN doDumpIncr IN h.
delete procedure h. 

catch e as Progress.Lang.AppError :
    message e:ReturnValue
    view-as  alert-box .  
end catch.
--------------------------------------------------------------------*/        
/*h-*/

/* Definitions */ /*-------------------------------------------------------*/

&GLOBAL-DEFINE errFileName "incrdump.e"

&SCOPED-DEFINE VAR_PREFIX       DUMP_INC
&SCOPED-DEFINE DEFAULT_DF       delta.df
&SCOPED-DEFINE DEFAULT_INDEX    1

DEFINE VARIABLE rename-file  AS CHARACTER NO-UNDO.
DEFINE VARIABLE df-file-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE code-page    AS CHARACTER NO-UNDO.
DEFINE VARIABLE index-mode   AS INTEGER   NO-UNDO.
DEFINE VARIABLE debug-mode   AS INTEGER   INITIAL 0 NO-UNDO.
DEFINE VARIABLE del-df-file  AS LOGICAL   NO-UNDO.
DEFINE VARIABLE dump-section AS CHARACTER NO-UNDO.

DEFINE VARIABLE foo          AS CHARACTER NO-UNDO.
DEFINE VARIABLE setincrdmpSilent        AS LOGICAL   NO-UNDO INIT NO.
DEFINE VARIABLE hBuf         AS HANDLE    NO-UNDO.


/* For DataServer Use */
DEFINE VARIABLE ds_shname1   AS CHARACTER INITIAL "" NO-UNDO.
DEFINE VARIABLE ds_mssname1  AS CHARACTER INITIAL "" NO-UNDO.
DEFINE VARIABLE ds_oraname1  AS CHARACTER INITIAL "" NO-UNDO.
DEFINE VARIABLE ds_dbname1   AS CHARACTER INITIAL "" NO-UNDO.
DEFINE VARIABLE user-dbtype1 AS CHARACTER INITIAL ? NO-UNDO.
DEFINE VARIABLE rtconnect1   AS LOGICAL   INITIAL no NO-UNDO.
DEFINE VARIABLE ds_shname2   AS CHARACTER INITIAL "" NO-UNDO.
DEFINE VARIABLE ds_mssname2  AS CHARACTER INITIAL "" NO-UNDO.
DEFINE VARIABLE ds_oraname2  AS CHARACTER INITIAL "" NO-UNDO.
DEFINE VARIABLE ds_dbname2   AS CHARACTER INITIAL "" NO-UNDO.
DEFINE VARIABLE user-dbtype2 AS CHARACTER INITIAL ? NO-UNDO.
DEFINE VARIABLE ds_alias     AS CHARACTER INITIAL ? NO-UNDO.
DEFINE VARIABLE sav_dictdb   AS CHARACTER INITIAL ? NO-UNDO.
DEFINE VARIABLE sav_dictdb2  AS CHARACTER INITIAL ? NO-UNDO. 
DEFINE VARIABLE shdb1-id     AS RECID     INITIAL ? NO-UNDO.
DEFINE VARIABLE dictdb-id    AS RECID     INITIAL ? NO-UNDO.
DEFINE VARIABLE shdb2-id     AS RECID     INITIAL ? NO-UNDO.
DEFINE VARIABLE dictdb2-id   AS RECID     INITIAL ? NO-UNDO.

DEFINE VARIABLE errcode      AS INTEGER   INITIAL 0 NO-UNDO.
/* For DataServer Use */

DEFINE STREAM err-log. 

{ prodict/user/uservar124.i NEW }
{ prodict/user/userhue.i NEW }
{ prodict/dictvar12.i NEW }

/* LANGUAGE DEPENDENCIES START */ /*----------------------------------------*/
DEFINE VARIABLE new_lang AS CHARACTER EXTENT 24 NO-UNDO INITIAL [
  /*01*/ "ERROR: ~"&1~" only runs persistent or in batch mode." ,
  /*02*/ "ERROR: You must have at least 2 databases connected." ,
  /*03*/ ?  /* see below */ ,
  /*04*/ "Using default value of ~"&1~" for &2." ,
  /*05*/ ?  /* see below */ ,
  /*06*/ ?  /* see below */, 
  /*07*/ "First connected database that defines the new baseline definitions for incremental dump is required.",
  /*08*/ "Second connected database that defines old comparative definitions for incremental dump is required.", 
  /*09*/ "Resource failure.  Aborting operations.",
  /*10*/ "Unable to connect to logical database ~"&1~".",
  /*11*/ "  Reason for failure: ~&1~"",
  /*12*/ ?, /* see below */
  /*13*/ "Oracle User Password is required.",
  /*14*/ "Oracle connect parameters are required or ORACLE_SID must be set.",
  /*15*/ "Logical schema ~"&1~" is not in the schema holder database ~"&2~".",
  /*16*/ ?  /* see below */,
  /*17*/ ?,
  /*18*/ ?,
  /*19*/ ?,
  /*20*/ ?,
  /*21*/ ?,
  /*22*/ ?,
  /*23*/ "~nStarting Incremental dump at ~"&1~" ...",
  /*24*/ ?
]. 
new_lang[03] = "WARNING: Rename file ~"&1~" doesn~'t exist or is unreadable," +
               " ignoring.".
new_lang[05] = "WARNING: ~"&1~" is not valid codepage. " +
               "Using default value of ~"&2~" instead.".
new_lang[06] = "WARNING: ~"&1~" is not valid ~"index-mode~" identifier. " +
               "Using default value of ~"&2~" instead.".
new_lang[12] = "You can set a DataServer incremental dump to two logical databases in the same schema holder.  " +
               "Or, you can set one database to a logical database and the other to the PROGRESS schema in the " +
               "same schema holder database.  But you must select at least one database in which your schemas " +
               "can be found.".
new_lang[16] = "There is already a logical database ~"&1~" opened in another schema holder: ~"&2~".  " + 
               "Aborting operations: Logical database can only associated with one schema holder in a session.".

new_lang[18] = "Conflict with settings:  You must either set MSS environment variables or " +
               "ORA environment variables for incremental dump, not both.".
new_lang[19] = "First connected database ~"&1~" is being overridden by database selection ~"&2~" from " +
               "environment variables as the new, baseline definitions for the incremental dump.".
new_lang[20] = "Second connected database ~"&1~" is being overridden by database selection ~"&2~" from " +
               "environment variables as the old, comparative definitions for the incremental dump.".
new_lang[21] = "WARNING: Specified schema holder database ~"1~" did not have any non-PROGRESS logical databases.  " +
               "PROGRESS database schema will be used for the incremental dump.".
new_lang[22] = "Specified schema holder database ~"&1~" had more than one non-PROGRESS logical database.  " +
               "Your environement variables must select a logical database value when there are more than one in the specified schema holder.".
new_lang[24] = "Logical database ~"&1~" not found in specified schema holder ~"&2~".  " +
               "Use environement variables to set your databases explicitly.  Also ensure you are using the correct database names.".

/* LANGUAGE DEPENDENCIES END */ /*-------------------------------------------*/

/* function prototypes ****************************************************/
FUNCTION getEnvironment RETURNS CHARACTER (
  INPUT pcVariableName AS CHARACTER) FORWARD.

FUNCTION getEnvironmentInt RETURNS INTEGER (
  INPUT pcVariableName AS CHARACTER) FORWARD.

PROCEDURE setSilent:
    DEFINE INPUT PARAMETER setsilent AS LOGICAL NO-UNDO.
    ASSIGN setincrdmpSilent = setsilent.
END.

PROCEDURE setFileName:
    DEFINE INPUT PARAMETER inc_dffile AS CHARACTER NO-UNDO.
    ASSIGN df-file-name   =  inc_dffile.
END.

PROCEDURE setCodePage:
    DEFINE INPUT PARAMETER inc_codepage AS CHARACTER NO-UNDO.
    ASSIGN code-page   =  inc_codepage.
END.

PROCEDURE setIndexMode:
    DEFINE INPUT PARAMETER inc_indexmode AS INTEGER  NO-UNDO.
    ASSIGN index-mode   =  inc_indexmode.
END.

PROCEDURE setRemoveEmptyDFfile:
    DEFINE INPUT PARAMETER inc_deldffile AS LOGICAL NO-UNDO.
    ASSIGN del-df-file = inc_deldffile.
END.

PROCEDURE setRenameFilename:
    DEFINE INPUT PARAMETER inc_renamefile AS CHARACTER NO-UNDO.
    ASSIGN rename-file   =  inc_renamefile.
END.

PROCEDURE setDebugMode:
    DEFINE INPUT PARAMETER inc_debug AS INTEGER NO-UNDO.
    ASSIGN debug-mode   =  inc_debug.
END.

PROCEDURE setDumpSection:
    DEFINE INPUT PARAMETER inc_dump_section AS LOGICAL NO-UNDO.
    ASSIGN dump-section   =  STRING(inc_dump_section).
END.

Procedure doDumpIncr:

IF debug-mode GT 0 THEN
   OUTPUT STREAM err-log TO {&errFileName} APPEND NO-ECHO.

IF NUM-DBS LT 2 THEN DO:
 IF user-dbtype1 = "PROGRESS" AND user-dbtype2 = "PROGRESS" THEN DO:
    IF debug-mode GT 0 THEN
      PUT STREAM err-log UNFORMATTED new_lang[02].
    IF LDBNAME(2) = ? THEN
        PUT STREAM err-log UNFORMATTED new_lang[08] SKIP.
    RETURN.
  END.
  ELSE DO:
    IF NUM-DBS LT 1 THEN DO:
      IF debug-mode GT 0 THEN
        PUT STREAM err-log UNFORMATTED new_lang[12].
      RETURN.
    END.
  END.
END.  /* NUM-DBS LT 2 */

/* test, if `rename-file' exists */
IF rename-file NE "":U THEN DO:
  ASSIGN FILE-INFO:FILE-NAME = rename-file.
  IF FILE-INFO:FILE-TYPE MATCHES "*R*":U THEN.  /* this deals with the ? */
  ELSE DO:
    IF debug-mode GT 0 THEN
      PUT STREAM err-log UNFORMATTED SUBSTITUTE(new_lang[03], rename-file) SKIP.
    ASSIGN rename-file = "":U.
  END.
END.

/* setting the default value for df file */
IF df-file-name EQ "":U THEN DO:
  ASSIGN df-file-name = "{&DEFAULT_DF}":U.
  IF debug-mode GT 0 THEN
    PUT STREAM err-log UNFORMATTED SUBSTITUTE(new_lang[04], "{&DEFAULT_DF}":U, "delta file":U) SKIP.
END.

/* codepage checking */
IF code-page NE "":U THEN DO:
  ASSIGN foo = CODEPAGE-CONVERT("x":U, SESSION:CPSTREAM, code-page) NO-ERROR.
  IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES GT 0 THEN DO:
    IF debug-mode GT 0 THEN
      PUT STREAM err-log UNFORMATTED SUBSTITUTE(new_lang[05], code-page, SESSION:CPSTREAM) SKIP.
    ASSIGN code-page = SESSION:CPSTREAM.
  END.  /* codepage error */
  ERROR-STATUS:ERROR = NO.
END.
ELSE DO:
  ASSIGN code-page = SESSION:CPSTREAM.
  IF debug-mode GT 0 THEN
    PUT STREAM err-log UNFORMATTED SUBSTITUTE(new_lang[04], code-page, "code page":U) SKIP.
END.  /* code-page EQ "":U */

/* index-mode checking */
IF index-mode NE ? THEN DO:
  IF (index-mode LT 0) OR (index-mode GT 2) THEN DO:
    IF debug-mode GT 0 THEN
      PUT STREAM err-log UNFORMATTED SUBSTITUTE(new_lang[06], index-mode, "{&DEFAULT_INDEX}":U) SKIP.
    ASSIGN index-mode = {&DEFAULT_INDEX}.
  END.
END.
ELSE DO:
  ASSIGN index-mode = {&DEFAULT_INDEX}.
  IF debug-mode GT 0 THEN
    PUT STREAM err-log UNFORMATTED SUBSTITUTE(new_lang[04], index-mode, "index mode":U) SKIP.
END.  /* index-mode EQ "":U */

/* dump-section checking */
IF dump-section NE "":U THEN
  ASSIGN user_env[43] = dump-section.  
ELSE
  ASSIGN user_env[43] = "No".

/* user_env[19] will be changed BY _dmpincr.p */
ASSIGN user_env[19] = rename-file + ",":U + STRING(index-mode) + ",":U + 
                      STRING(debug-mode) + ",":U + STRING(setincrdmpSilent)
       user_env[02] = df-file-name
       user_env[05] = code-page.

IF debug-mode GT 1 THEN DO:
  PUT STREAM err-log UNFORMATTED "DUMP_INC_DFFILE     = ":U df-file-name SKIP.
  PUT STREAM err-log UNFORMATTED "DUMP_INC_CODEPAGE   = ":U code-page SKIP.
  PUT STREAM err-log UNFORMATTED "DUMP_INC_INDEXMODE  = ":U index-mode SKIP.
  PUT STREAM err-log UNFORMATTED "DUMP_INC_DUMPSECTION =":U dump-section SKIP.
  PUT STREAM err-log UNFORMATTED "DUMP_INC_RENAMEFILE = ":U rename-file SKIP.
  PUT STREAM err-log UNFORMATTED "DUMP_INC_DEBUG      = ":U debug-mode SKIP.
  IF user-dbtype1 <> "PROGRESS" THEN DO: 
    PUT STREAM err-log UNFORMATTED "SHDBNAME1           = ":U ds_shname1 SKIP.
    PUT STREAM err-log UNFORMATTED "MSSDBNAME1          = ":U ds_mssname1 SKIP.
    PUT STREAM err-log UNFORMATTED "ORADBNAME1          = ":U ds_oraname1 SKIP.
  END.
  IF user-dbtype2 <> "PROGRESS" THEN DO:
    PUT STREAM err-log UNFORMATTED "SHDBNAME2           = ":U ds_shname2 SKIP.
    PUT STREAM err-log UNFORMATTED "MSSDBNAME2          = ":U ds_mssname2 SKIP.
    PUT STREAM err-log UNFORMATTED "ORADBNAME2          = ":U ds_oraname2 SKIP.
  END.

END.  /* debug-mode GT 1 */

IF user-dbtype1 = "PROGRESS" THEN DO:
  /* Perform FIND on DICTDB dynamically to avoid compile errors that allow no feedback */
  CREATE BUFFER hBuf FOR TABLE "DICTDB._Db".
  IF VALID-HANDLE(hBuf) THEN DO:
    hBuf:FIND-FIRST('WHERE DICTDB._Db._Db-local = true', NO-LOCK) NO-ERROR.
    IF NOT hBuf:AVAILABLE OR ERROR-STATUS:ERROR THEN DO:
      IF debug-mode GT 0 THEN DO:
        PUT STREAM err-log UNFORMATTED new_lang[07] SKIP.
        IF ERROR-STATUS:ERROR THEN
          PUT STREAM err-log UNFORMATTED SUBSTITUTE(new_lang[11], ERROR-STATUS:GET-MESSAGE(1)).
      END.
      RETURN.
    END.
  END.
  ELSE DO:
    PUT STREAM err-log UNFORMATTED new_lang[09] SKIP.
    RETURN.
  END.

  ASSIGN drec_db = hBuf:RECID.
  s_DbType1 = user-dbtype1.
END.

IF  s_DbRecId = ? THEN DO:
    IF  NOT this-procedure:persistent THEN DO:
        DELETE ALIAS "DICTDB2":U.
        CREATE ALIAS "DICTDB2":U FOR DATABASE VALUE(LDBNAME(2)).
        s_DbType2 = "PROGRESS".
    END.
    ELSE DO : 
        s_DbType2 = "PROGRESS".
        s_DbType1 = "PROGRESS".
    END.
END.

IF drec_db EQ ? AND this-procedure:persistent THEN DO:
    FIND FIRST DICTDB._Db where DICTDB._db._db-local = true NO-LOCK.
    ASSIGN drec_db = RECID(DICTDB._Db).
END.

IF debug-mode GT 0 THEN DO:
  PUT STREAM err-log UNFORMATTED "" SKIP.
  OUTPUT STREAM err-log CLOSE.
END.

RUN pct/v12/_dmpincr124.p.
IF     del-df-file
   AND RETURN-VALUE MATCHES "*SEEK=*"
   AND INT64(REPLACE(RETURN-VALUE,"SEEK=","")) EQ 0
THEN DO:
  MESSAGE "No difference found. Deleting " + df-file-name.
  OS-DELETE VALUE(df-file-name).
END.

RETURN.
END. /* end of doDumpIncr */

/* mainline code **********************************************************/

IF NOT SESSION:BATCH-MODE THEN DO:
 if not THIS-PROCEDURE:persistent THEN 
  MESSAGE SUBSTITUTE(new_lang[01], "{0}":U) 
          VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.  /* NOT SESSION:BATCH-MODE */

IF this-procedure:persistent THEN DO:
  IF debug-mode GT 0 THEN DO:
    OUTPUT STREAM err-log TO {&errFileName} APPEND NO-ECHO.
    PUT STREAM err-log UNFORMATTED SUBSTITUTE(new_lang[23], STRING(NOW)) SKIP(1).
  END.
END.
ELSE DO:
  ASSIGN debug-mode   = getEnvironmentInt("{&VAR_PREFIX}_DEBUG":U)
         rename-file  = getEnvironment("{&VAR_PREFIX}_RENAMEFILE":U)
         df-file-name = getEnvironment("{&VAR_PREFIX}_DFFILE":U)
         code-page    = getEnvironment("{&VAR_PREFIX}_CODEPAGE":U)
         index-mode   = getEnvironmentInt("{&VAR_PREFIX}_INDEXMODE":U)
         dump-section = getEnvironment("{&VAR_PREFIX}_DUMPSECTION":U)
         ds_shname1   = getEnvironment("SHDBNAME1":U)
         ds_shname2   = getEnvironment("SHDBNAME2":U)
         ds_mssname1  = getEnvironment("MSSDBNAME1":U)
         ds_mssname2  = getEnvironment("MSSDBNAME2":U)
         ds_oraname1  = getEnvironment("ORADBNAME1":U)
         ds_oraname2  = getEnvironment("ORADBNAME2":U).


IF debug-mode GT 0 THEN DO:
    OUTPUT STREAM err-log TO {&errFileName} APPEND NO-ECHO.
    PUT STREAM err-log UNFORMATTED SUBSTITUTE(new_lang[23], STRING(NOW)) SKIP(1).
  END.

  IF debug-mode GT 1 THEN DO:
    IF ds_shname1 <> "" THEN
      PUT STREAM err-log UNFORMATTED "~nSHDBNAME1           = ":U ds_shname1 SKIP.
    IF ds_mssname1 <> "" THEN
      PUT STREAM err-log UNFORMATTED "MSSDBNAME1          = ":U ds_mssname1 SKIP.
    IF ds_oraname1 <> "" THEN
      PUT STREAM err-log UNFORMATTED "ORADBNAME1          = ":U ds_oraname1 SKIP.
    IF ds_shname2 <> "" THEN
      PUT STREAM err-log UNFORMATTED "SHDBNAME2           = ":U ds_shname2 SKIP.
    IF ds_mssname2 <> "" THEN
      PUT STREAM err-log UNFORMATTED "MSSDBNAME2          = ":U ds_mssname2 SKIP.
    IF ds_oraname2 <> "" THEN
      PUT STREAM err-log UNFORMATTED "ORADBNAME2          = ":U ds_oraname2 SKIP.
  END.  /* debug-mode GT 1 */

  /* PROGRESS determines normal legacy execution from here on */
  ASSIGN user-dbtype1 = "PROGRESS"
         user-dbtype2 = "PROGRESS". 

  IF ds_mssname1 <> "" THEN 
    ASSIGN user-dbtype1 = "MSS"
             ds_dbname1 = ds_mssname1.

  IF ds_mssname2 <> "" THEN 
    ASSIGN user-dbtype2 = "MSS"
             ds_dbname2 = ds_mssname2.

  IF ds_oraname1 <> "" AND user-dbtype1 = "MSS" THEN DO:
    IF debug-mode GT 0 THEN
      PUT STREAM err-log UNFORMATTED new_lang[18] SKIP.
    RETURN.
  END.
  ELSE IF ds_oraname1 <> "" THEN 
    ASSIGN user-dbtype1 = "ORACLE"
             ds_dbname1 = ds_oraname1.

  /* Check for setting conflicts */
  IF ds_oraname2 <> "" AND user-dbtype2 = "MSS" THEN DO:
    IF debug-mode GT 0 THEN
      PUT STREAM err-log UNFORMATTED new_lang[18] SKIP.
    RETURN.
  END.
  ELSE IF ds_oraname2 <> "" THEN 
    ASSIGN user-dbtype2 = "ORACLE"
             ds_dbname2 = ds_oraname2.

  IF LDBNAME(1) <> ? THEN DO:
    IF ds_shname1 = "" THEN DO:
      IF ds_dbname1 <> "" OR CAPS(ds_dbname1) = CAPS("<none>") THEN 
        ds_shname1 = LDBNAME(1). /* For now, assume logical db is in connected sh */
    END.
    ELSE DO:
      IF ds_shname1 <> LDBNAME(1) THEN DO:
        sav_dictdb = LDBNAME(1).
        IF debug-mode GT 0 THEN 
          PUT STREAM err-log UNFORMATTED SUBSTITUTE(new_lang[19], LDBNAME(1), ds_shname1) SKIP.
      END.
    END. 
  END.
  ELSE IF user-dbtype1 = "PROGRESS" OR ds_shname1 = "" THEN DO:
    IF debug-mode GT 0 THEN 
      PUT STREAM err-log UNFORMATTED new_lang[07] SKIP.
    IF user-dbtype2 <> "PROGRESS" AND ds_shname1 <> "" THEN 
      rtconnect1 = yes. /* ok to not have LDBNAME(1) when one or more db's is foreign */
    ELSE 
      RETURN.
  END.
 
  IF ds_shname1 <> "" AND ds_dbname1 = "" THEN user-dbtype1 = "". /* Need to search for db type */

  IF LDBNAME(2) <> ? THEN DO:
    IF ds_shname2 = "" THEN DO:
      IF ds_dbname2 <> "" OR CAPS(ds_dbname2) = CAPS("<none>") THEN 
        ds_shname2 = LDBNAME(2). /* For now, assume logical db is in connected sh */
    END.
    ELSE DO:
      IF ds_shname2 <> LDBNAME(2) THEN DO:
           sav_dictdb2 = LDBNAME(2).
           IF debug-mode GT 0 THEN 
             PUT STREAM err-log UNFORMATTED SUBSTITUTE(new_lang[20], LDBNAME(2), ds_shname2) SKIP.
      END.
    END.
  END.
  ELSE IF user-dbtype2 = "PROGRESS" OR ds_shname2 = "" THEN DO:
    IF debug-mode GT 0 THEN 
      PUT STREAM err-log UNFORMATTED new_lang[08] SKIP.
    RETURN.
  END.
 
  IF ds_shname2 <> "" AND ds_dbname2 = "" THEN user-dbtype2 = "". /* Need to search for db type */

  /* Connect any unconnected schema holder databases */
  IF (user-dbtype1 <> "PROGRESS" OR rtconnect1) AND NOT CONNECTED(ds_shname1) THEN DO:
    CONNECT VALUE(ds_shname1) -1 NO-ERROR.

    IF ERROR-STATUS:ERROR AND NOT CONNECTED(ds_shname1) THEN DO:
      IF debug-mode GT 0 THEN DO:
        PUT STREAM err-log UNFORMATTED SUBSTITUTE(new_lang[10], ds_shname1) SKIP.
        PUT STREAM err-log UNFORMATTED SUBSTITUTE(new_lang[11], ERROR-STATUS:GET-MESSAGE(1)).
      END.
      RETURN.
    END.
    ELSE
      rtconnect1 = yes. /* Reuse run-time connect flag if LDBNAME(1) is successful */ 
  END.

  IF user-dbtype2 <> "PROGRESS" AND NOT CONNECTED(ds_shname2) THEN DO:
    CONNECT VALUE(ds_shname2) -1 NO-ERROR.

    IF ERROR-STATUS:ERROR AND NOT CONNECTED(ds_shname2) THEN DO:
      IF debug-mode GT 0 THEN DO:
        PUT STREAM err-log UNFORMATTED SUBSTITUTE(new_lang[10], ds_shname2) SKIP.
        PUT STREAM err-log UNFORMATTED SUBSTITUTE(new_lang[11], ERROR-STATUS:GET-MESSAGE(1)).
      END.
      RETURN.
    END.
  END.

  IF user-dbtype1 <> "PROGRESS" THEN DO:

    IF ds_shname1 <> LDBNAME(1) OR rtconnect1 THEN DO:
      DELETE ALIAS "DICTDB":U.
      CREATE ALIAS "DICTDB":U FOR DATABASE VALUE(ds_shname1).
    END.

    ASSIGN ds_alias = "DICTDB".

    RUN "prodict/misc/_valsch.p" (INPUT ds_alias            /* Dictionary Alias Name */,
                                  INPUT ds_shname1          /* Schema holder name */,
                                  INPUT-OUTPUT ds_dbname1   /* Logical database name */,
                                  INPUT-OUTPUT user-dbtype1 /* Logical database type */,
                                  OUTPUT shdb1-id           /* RECID of DICTDB */,
                                  OUTPUT dictdb-id          /* RECID of DICTDB logical db */,
                                  OUTPUT errcode            /* Error Code */).  
    
    IF errcode > 0 THEN DO:
      ASSIGN dictdb-id = ?.
      CASE errcode:
        WHEN 1 THEN DO: 
          IF debug-mode GT 0 THEN
            PUT STREAM err-log UNFORMATTED SUBSTITUTE(new_lang[15], ds_dbname1, ds_shname1) SKIP.
        END.
        WHEN 2 THEN DO:
          IF debug-mode GT 0 THEN
            PUT STREAM err-log UNFORMATTED SUBSTITUTE(new_lang[16], ds_dbname1, SDBNAME(ds_dbname1)) SKIP.
        END.
        WHEN 3 THEN DO:
          IF debug-mode GT 0 THEN
            PUT STREAM err-log UNFORMATTED SUBSTITUTE(new_lang[22], ds_shname1) SKIP.
        END.
        WHEN 4 THEN DO:
          IF debug-mode GT 0 THEN
            PUT STREAM err-log UNFORMATTED SUBSTITUTE(new_lang[24], ds_dbname1, ds_shname1) SKIP.
        END.
      END CASE.
      RETURN.
    END.

    IF ds_dbname1 <> "" THEN DO:
      IF dictdb-id = ? THEN DO:
         IF CAPS(ds_dbname1) = CAPS("<none>") THEN DO:
          drec_db = shdb1-id.
          s_DbType1 = "PROGRESS".
        END. 
        ELSE DO:
          IF debug-mode GT 0 THEN 
            PUT STREAM err-log UNFORMATTED new_lang[17] SKIP.
          RETURN.
        END.
      END.
      ELSE DO:
        drec_db = dictdb-id.
        s_DbType1 = user-dbtype1.
      END.
    END.
    ELSE DO:
      PUT STREAM err-log UNFORMATTED new_lang[09] SKIP.
      RETURN.
    END.
  END.

  IF user-dbtype2 <> "PROGRESS" THEN DO:

    DELETE ALIAS "DICTDB2":U.
    CREATE ALIAS "DICTDB2":U FOR DATABASE VALUE(ds_shname2).

    ASSIGN ds_alias = "DICTDB2".

    RUN "prodict/misc/_valsch.p" (INPUT ds_alias            /* Dictionary Alias Name */,
                                  INPUT ds_shname2          /* Schema holder name */,
                                  INPUT-OUTPUT ds_dbname2   /* Logical database name */,
                                  INPUT-OUTPUT user-dbtype2 /* Logical database type */,
                                  OUTPUT shdb2-id           /* RECID of DICTDB2 */,
                                  OUTPUT dictdb2-id         /* RECID of DICTDB2 logical db */,
                                  OUTPUT errcode            /* Error Code */).  
    
    IF errcode > 0 THEN DO:
      ASSIGN dictdb2-id = ?.
      CASE errcode:
        WHEN 1 THEN DO: 
          IF debug-mode GT 0 THEN
            PUT STREAM err-log UNFORMATTED SUBSTITUTE(new_lang[15], ds_dbname2, ds_shname2) SKIP.
        END.
        WHEN 2 THEN DO:
          IF debug-mode GT 0 THEN
            PUT STREAM err-log UNFORMATTED SUBSTITUTE(new_lang[16], ds_dbname2, SDBNAME(ds_dbname2)) SKIP.
        END.
        WHEN 3 THEN DO:
          IF debug-mode GT 0 THEN
            PUT STREAM err-log UNFORMATTED SUBSTITUTE(new_lang[22], ds_shname2) SKIP.
        END.
        WHEN 4 THEN DO:
          IF debug-mode GT 0 THEN
            PUT STREAM err-log UNFORMATTED SUBSTITUTE(new_lang[24], ds_dbname2, ds_shname2) SKIP.
        END.
      END CASE.
      RETURN.
  END.

  s_DbRecId = ?. /* Borrow ADE dictionary variable not used by incremental dump */
  IF ds_dbname2 <> "" THEN DO:
      IF dictdb2-id = ? THEN DO:
         IF CAPS(ds_dbname2) = CAPS("<none>") THEN DO:
          s_DbRecId = shdb1-id.
          s_DbType2 = "PROGRESS".
        END.
        ELSE DO:
          IF debug-mode GT 0 THEN
            PUT STREAM err-log UNFORMATTED new_lang[17] SKIP.
          RETURN.
        END.
      END.
      ELSE DO:
        s_DbRecId = dictdb2-id.
        s_DbType2 = user-dbtype2.
      END.
    END.
    ELSE DO:
      PUT STREAM err-log UNFORMATTED new_lang[09] SKIP.
      RETURN.

    END.
  END.

  IF debug-mode GT 0 THEN DO:
     PUT STREAM err-log UNFORMATTED "" SKIP.
     OUTPUT STREAM err-log CLOSE.
  END.

  run doDumpIncr.

END.

/* functions **************************************************************/

FUNCTION getEnvironment RETURNS CHARACTER (INPUT pcVariableName AS CHARACTER).
  DEFINE VARIABLE cReturnValue AS CHARACTER NO-UNDO.
  ASSIGN cReturnValue = OS-GETENV(pcVariableName)
         cReturnValue = IF cReturnValue EQ ? THEN "":U
                        ELSE cReturnValue.
  RETURN cReturnValue.
END FUNCTION.  /* getEnvironment() */

FUNCTION getEnvironmentInt RETURNS INTEGER (INPUT pcVariableName AS CHARACTER).
  DEFINE VARIABLE iReturnValue AS INTEGER   NO-UNDO.
  DEFINE VARIABLE cValue       AS CHARACTER NO-UNDO.
  
  ASSIGN cValue       = getEnvironment(pcVariableName)
         iReturnValue = INTEGER(cValue) NO-ERROR.

  ERROR-STATUS:ERROR = NO.

  RETURN iReturnValue.
END FUNCTION.  /* getEnvironmentInt() */

/* prodict/dump_inc.p */
