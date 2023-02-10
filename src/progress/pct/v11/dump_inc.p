/*********************************************************************
* Copyright (C) 2000,2011 by Progress Software Corporation. All      *
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
            (it's the second connected database, "slave")

Usage:
    In scripts, e.q.:
       #!/bin/sh
       DUMP_INC_DFFILE=/tmp/delta.df
       DUMP_INC_CODEPAGE=iso8859-2
       DUMP_INC_INDEXMODE=0
       DUMP_INC_RENAMEFILE=/tmp/master.rf
       DUMP_INC_DEBUG=2
       export DUMP_INC_DFFILE DUMP_INC_CODEPAGE DUMP_INC_INDEXMODE \
              DUMP_INC_RENAMEFILE DUMP_INC_DEBUG

       $DLC/bin/_progres -b -db master \
                            -db slave  \
                            -p prodict/dump_inc.p > /tmp/dump_inc.log

Environment Variables:
    DUMP_INC_DFFILE          : name of file to dump to
    DUMP_INC_CODEPAGE        : output codepage
    DUMP_INC_INDEXMODE       : index-mode for newly created indexes in exsting
                               tables: 0 = all indexes active
                                       1 = all unique indexes inactive
                                       2 = all indexes inactive
    DUMP_INC_RENAMEFILE      : name of the file with rename definitions
    DUMP_INC_DEBUG           : debug-level: 0 = debug off (only errors
                                                and important warnings)
                                            1 = all the above plus all warnings
                                            2 = all the above plus config info

History
    Gary C    01/06/21  This FILE created, author of the original idea
    vap       02/01/29  patched accordingly to changed specs

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

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE rename-file  AS CHARACTER NO-UNDO.
DEFINE VARIABLE df-file-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE code-page    AS CHARACTER NO-UNDO.
DEFINE VARIABLE index-mode   AS INTEGER   NO-UNDO.
DEFINE VARIABLE debug-mode   AS INTEGER   NO-UNDO.
DEFINE VARIABLE del-df-file  AS LOGICAL   NO-UNDO.

DEFINE VARIABLE foo          AS CHARACTER NO-UNDO.
DEFINE VARIABLE setincrdmpSilent        AS LOGICAL   NO-UNDO INIT NO.

DEFINE STREAM err-log.

{ prodict/user/uservar11.i NEW }
{ prodict/user/userhue.i NEW }
{ prodict/dictvar11.i NEW }

/* LANGUAGE DEPENDENCIES START */ /*----------------------------------------*/
DEFINE VARIABLE new_lang AS CHARACTER EXTENT 06 NO-UNDO INITIAL [
  /*01*/ "ERROR: ~"&1~" only runs persistent or in batch mode." ,
  /*02*/ "ERROR: You must have at least 2 databases connected." ,
  /*03*/ ?  /* see below */ ,
  /*04*/ "Using default value of ~"&1~" for &2." ,
  /*05*/ ?  /* see below */ ,
  /*06*/ ?  /* see below */
].
new_lang[03] = "WARNING: Rename file ~"&1~" doesn~'t exist or is unreadable," +
               " ignoring.".
new_lang[05] = "WARNING: ~"&1~" is not valid codepage. " +
               "Using default value of ~"&2~" instead.".
new_lang[06] = "WARNING: ~"&1~" is not valid ~"index-mode~" identifier. " +
               "Using default value of ~"&2~" instead.".
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

Procedure doDumpIncr:
IF debug-mode GT 0 THEN
  OUTPUT STREAM err-log TO {&errFileName} APPEND NO-ECHO.

IF NUM-DBS LT 2 THEN DO:
  PUT STREAM err-log UNFORMATTED new_lang[02].
  RETURN.
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

/* user_env[19] will be changed BY _dmpincr.p */
ASSIGN user_env[19] = rename-file + ",":U + STRING(index-mode) + ",":U +
                      STRING(debug-mode)
       user_env[02] = df-file-name
       user_env[05] = code-page.

IF debug-mode GT 1 THEN DO:
  PUT STREAM err-log UNFORMATTED "DUMP_INC_DFFILE     = ":U df-file-name SKIP.
  PUT STREAM err-log UNFORMATTED "DUMP_INC_CODEPAGE   = ":U code-page SKIP.
  PUT STREAM err-log UNFORMATTED "DUMP_INC_INDEXMODE  = ":U index-mode SKIP.
  PUT STREAM err-log UNFORMATTED "DUMP_INC_RENAMEFILE = ":U rename-file SKIP.
  PUT STREAM err-log UNFORMATTED "DUMP_INC_DEBUG      = ":U debug-mode SKIP.
END.  /* debug-mode GT 1 */

IF debug-mode GT 0 THEN DO:
  PUT STREAM err-log UNFORMATTED "" SKIP.
  OUTPUT STREAM err-log CLOSE.
END.

FIND FIRST DICTDB._Db where DICTDB._db._db-local = true NO-LOCK.
ASSIGN drec_db = RECID(DICTDB._Db).

if not this-procedure:persistent then DO:
  DELETE ALIAS "DICTDB2":U.
  CREATE ALIAS "DICTDB2":U FOR DATABASE VALUE(LDBNAME(2)).
END.

RUN pct/v11/_dmpincr.p.

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

if not this-procedure:persistent then DO:
  ASSIGN debug-mode   = getEnvironmentInt("{&VAR_PREFIX}_DEBUG":U)
         rename-file  = getEnvironment("{&VAR_PREFIX}_RENAMEFILE":U)
         df-file-name = getEnvironment("{&VAR_PREFIX}_DFFILE":U)
         code-page    = getEnvironment("{&VAR_PREFIX}_CODEPAGE":U)
         index-mode   = getEnvironmentInt("{&VAR_PREFIX}_INDEXMODE":U).

  run doDumpIncr.
end.

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
