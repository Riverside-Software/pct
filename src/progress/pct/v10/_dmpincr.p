/*********************************************************************
* Copyright (C) 2005-2008 by Progress Software Corporation. All rights    *
* reserved.  Prior versions of this work may contain portions        *
* contributed by participants of Possenet.                           *
*                                                                    *
*********************************************************************/

/* _dmpincr.p - phase 2 of incremental .df maker

   DICTDB  is the current database
   DICTDB2 is the database chosen to compare against

   The aim is to produce a database like DICTDB.  So this .df file will be
   run against a database like DICTDB2 to create a database like DICTDB.

*/

/*
DICTDB  = new definitions
DICTDB2 = old definitions

for each file:
  match up filename
  match up indexnames
  match up fieldnames
  handle differences
end.

match up:
  find object of same name.
  if found, leave.
  otherwise, make note and continue until all matched.
  if none left over, assume deletes.
  otherwise, ask if renamed.
  return.
end.
*/
/*
in:       user_env[2] = Name of file to dump to.
          user_env[5] = "<internal defaults apply>" or "<target-code-page>"
changes:  user_env[19]

History:
    gfs         12/05/94    fixed problem with drop field if in pri indx
    hutegger    94/02/24    code-page - support and trailer-info added
    laurief     03/31/98    BUG 97-08-14-029 see note below
    mcmann      04/24/98    Added output of POSITION (_field-rpos).
    mcmann      05/07/98    Added logic to skip "default" indices 98-05-06-041
    laurief     06/02/98    Added database names to screen display and
                            combined thw two separate frames into one that can
                            be viewed in three-d.
    mcmann      06/18/99    Added third parameter to call of _dmpdefs.p
    Mario B     10/19/99    Several Bug Fixes and support for AREAS.  Added
                            warnings mechanisim.  BUG#'s  19981112-011,
                                        19990915-022, 19970814-029 (re-opened & re-fixed).
    McMann      12/15/99    Supporting hidden user files. 19991029-048
    McMann      01/11/00    Dump index desc 19991029042
    McMann      01/18/00    Added check for sql-default 19991102027
    McMann      02/02/00    Added comparison of Frozen 19991227010
    McMann      02/14/00    Checking for available index-alt in wrong place
                            20000209031
    McMann      03/28/00    Passing incorrect recid to function 20000327012
    McMann      04/20/00    Added code to only inactive unique indices if user
                            has specified to.
    McMann      06/28/00    Added code for renaming indexes 20000621001
    McMann      08/17/00    Added _db-recid to _StorageObject find 20000815029
    vap         01/29/02    Added batch-mode support
    McMann      08/08/02    Eliminated any sequences whose name begins "$" - Peer Direct
    McMann      09/13/02    Added logic to put inactive on non-unique indices if the record
                            is inactive 20020913-002
    McMann      02/24/03    Added LOB support
    P. Kullman  09/22/03    Changed call to _dmpisub.p from _dmpincr.p 12796
    McMann      10/17/03    Add NO-LOCK statement to _Db find in support of on-line schema add
    K. McIntosh 07/26/04    Added CLOB support for incremental dump
    kmcintos    09/16/05    Fixed problems with renaming indexed and non
                               indexed fields (Supporting changes in
                               dump/_dmputil.p) 20040402-004.
    fernando    06/12/06    Support for int64 - allow int->int64 type change
    fernando    08/16/06    raw comparison when checking if char values are different - 20060301-002
    fernando    02/27/2007  Added case for critical field change - OE00147106
    fernando    08/10/2007  Close error stream when area mismatch error is detected - OE00136202
    fernando    11/12/07    Ignore blank -sa fields during incremental - OE00150364
    fernando    11/24/08    Handle clob field differences - OE00177533
*/
/*h-*/

{ prodict/dictvar10.i }
{ prodict/user/uservar10.i }
{ prodict/user/userhue.i }
{ prodict/dump/dumpvars10.i "NEW SHARED" }

DEFINE            VARIABLE ans            AS LOGICAL   INITIAL FALSE NO-UNDO.
DEFINE            VARIABLE c              AS CHARACTER               NO-UNDO.
DEFINE            VARIABLE db             AS CHARACTER               NO-UNDO.
DEFINE            VARIABLE db2            AS CHARACTER               NO-UNDO.
DEFINE            VARIABLE fil            AS CHARACTER               NO-UNDO.
DEFINE            VARIABLE fil2           AS CHARACTER               NO-UNDO.
DEFINE            VARIABLE fld            AS CHARACTER               NO-UNDO.
DEFINE            VARIABLE fld2           AS CHARACTER               NO-UNDO.
DEFINE            VARIABLE idx            AS CHARACTER               NO-UNDO.
DEFINE            VARIABLE idx2           AS CHARACTER               NO-UNDO.
DEFINE            VARIABLE seq            AS CHARACTER               NO-UNDO.
DEFINE            VARIABLE seq2           AS CHARACTER               NO-UNDO.
DEFINE            VARIABLE i              AS INTEGER                 NO-UNDO.
DEFINE            VARIABLE j              AS INTEGER                 NO-UNDO.
DEFINE            VARIABLE l              AS LOGICAL                 NO-UNDO.
DEFINE            VARIABLE stopped        AS LOGICAL   INITIAL TRUE  NO-UNDO.
DEFINE            VARIABLE tmp_Field-name AS CHARACTER               NO-UNDO.
/* 02/01/29 vap (IZ# 1525) */
DEFINE            VARIABLE p-batchmode    AS LOGICAL                 NO-UNDO.
DEFINE            VARIABLE p-index-mode   AS CHARACTER               NO-UNDO.
DEFINE            VARIABLE p-rename-file  AS CHARACTER               NO-UNDO.
DEFINE            VARIABLE p-debug-mode   AS INTEGER                 NO-UNDO.
DEFINE            VARIABLE p-log-line     AS CHARACTER               NO-UNDO.
DEFINE            VARIABLE p-list         AS CHARACTER               NO-UNDO.
DEFINE            VARIABLE p-comma        AS CHARACTER               NO-UNDO.
DEFINE            VARIABLE p-foo          AS CHARACTER               NO-UNDO.
DEFINE            VARIABLE p-foo2         AS CHARACTER               NO-UNDO.
DEFINE            VARIABLE to-int64       AS LOGICAL                 NO-UNDO.
DEFINE            VARIABLE i-to-int64     AS INTEGER                 NO-UNDO.
DEFINE            VARIABLE numEntries     AS INTEGER                 NO-UNDO.
DEFINE            VARIABLE num-diff       AS INTEGER                 NO-UNDO.
DEFINE            VARIABLE iSeek          AS INT64                   NO-UNDO.


/* LANGUAGE DEPENDENCIES START */ /*----------------------------------------*/
DEFINE VARIABLE new_lang AS CHARACTER EXTENT 31 NO-UNDO INITIAL [
  /* 1*/ "(initializing)",
  /* 2*/ "", /* See Below */
  /* 3*/ "WARNING: The ",
  /* 4*/ " file AREA has",
  /* 5*/ "changed.  The incremental dump utility cannot be used to",
  /* 6*/ "change database AREAS.  Create AREAS with the ""prostrct""",
  /* 7*/ "utility and move tables with the ""proutil tablemove""",
  /* 8*/ "utility.  See the {&PRO_DISPLAY_NAME} Database Administration Guide and",
  /* 9*/ "Reference for details.",
  /*10*/ "WARNING: The index ",
  /*11*/ " in database ",
  /*12*/ "is identical to the index ",
  /*13*/ "except they are in different database AREAS.  The incremental dump",
  /*14*/ "utility cannot be used to change database AREAS.  Create",
  /*15*/ "AREAS with the ""prostrct"" utility and move indices",
  /*16*/ "with the ""proutil idxmove"" utility.  See the {&PRO_DISPLAY_NAME}",
  /*17*/ "Database Administration Guide and Reference for details.",
  /*18*/ "WARNING: The .df contains at least one new definition of an unique",
  /*19*/ "index that has been created as inactive.  Remember to use",
  /*20*/ """proutil -C idxbuild"" to activate this index.",
  /*21*/ " AREA does not exist",
  /*22*/ "in the target database.  This area must be created before",
  /*23*/ "loading this .df or an error will result.  The new index",
  /*24*/ " is in this AREA.  See the ""PROSTRUCT""",
  /*25*/ "entry in the {&PRO_DISPLAY_NAME} Database Administration Guide and",
  /*26*/ "Reference for details.",
  /*27*/ "Warnings have been written to a file called "{&errFileName}"",
  /*28*/ "located in your current working directory.  Please check",
  /*29*/ "this file prior to loading this incremental .df.  Failure",
  /*30*/ "to do so could result in errors or other undesirable results.",
  /*31*/ "loading this .df or an error will result.  The new table"
].

new_lang[2] = "The incremental definitions file will contain at least "
            + "one new definition of an  unique index. "
            + "If {&PRO_DISPLAY_NAME} finds duplicate values when creating the new "
            + "unique index, it will UNDO the entire transaction, causing "
            + "you to lose any other schema changes made.  Creating an "
            + "inactive index and then building it with ~"proutil -C "
            + "idxbuild~" will eliminate this problem.  Do you want to "
            + "create definitions for unique indexes as inactive?"
.

/* LANGUAGE DEPENDENCIES END */ /*-------------------------------------------*/

FORM
  db      LABEL "Scanning"              COLON 10 FORMAT "x(27)"
  db2     LABEL "Working on"            COLON 50 FORMAT "x(27)" SKIP
  fil     LABEL "TABLE"                 COLON 10 FORMAT "x(27)"
  fil2    LABEL "TABLE"                 COLON 50 FORMAT "x(27)" SKIP
  fld     LABEL "FIELD"                 COLON 10 FORMAT "x(27)"
  fld2    LABEL "FIELD"                 COLON 50 FORMAT "x(27)" SKIP
  idx     LABEL "INDEX"                 COLON 10 FORMAT "x(27)"
  idx2    LABEL "INDEX"                 COLON 50 FORMAT "x(27)" SKIP
  seq     LABEL "SEQ"                   COLON 10 FORMAT "x(27)"
  seq2    LABEL "SEQ"                   COLON 50 FORMAT "x(27)" SKIP
  HEADER
    " Press " +
    KBLABEL("STOP") + " to terminate the dump." FORMAT "x(50)"
  WITH FRAME seeking
  &IF "{&WINDOW-SYSTEM}" <> "TTY" &THEN VIEW-AS DIALOG-BOX THREE-D &ENDIF
  SIDE-LABELS WIDTH 80
  ROW 4 COLUMN 1 USE-TEXT.
COLOR DISPLAY MESSAGES fil fil2 fld fld2 idx idx2 seq seq2 WITH FRAME seeking.
/* LANGUAGE DEPENDENCIES END */ /*------------------------------------------*/

/* Definitions */ /*-------------------------------------------------------*/

DEFINE VARIABLE ddl  AS CHARACTER EXTENT 40 NO-UNDO.
DEFINE VARIABLE iact AS LOGICAL   INITIAL ? NO-UNDO.
DEFINE VARIABLE pri1 AS CHARACTER           NO-UNDO.
DEFINE VARIABLE pri2 AS CHARACTER           NO-UNDO.

DEFINE BUFFER database2 FOR DICTDB2._Db.
FIND FIRST database2 WHERE database2._Db-local NO-LOCK.

DEFINE WORKFILE drop-list NO-UNDO
   FIELD file-name  LIKE _File._File-Name
   FIELD f1-name    LIKE _Field._Field-Name
   FIELD f2-name    LIKE _Field._Field-Name.

DEFINE WORKFILE drop-temp-idx NO-UNDO
    FIELD temp-name LIKE _Index._Index-name
    FIELD fil-name  LIKE _File._File-name.

/* Persistent procedure library */
RUN prodict/dump/_dmputil.p PERSISTENT SET h_dmputil.

/* Forward Declare functions contained in library */
FUNCTION fileAreaMatch RETURNS LOGICAL (INPUT db1FileNo AS INT,
                                        INPUT db2FileNo AS INT,
                                        INPUT db1recid  AS RECID,
                                        INPUT db2recid  AS RECID) IN h_dmputil.

FUNCTION indexAreaMatch RETURNS LOGICAL(INPUT db1IndexNo AS INT,
                                        INPUT db2IndexNo AS INT,
                                        INPUT db1recid   AS RECID,
                                        INPUT db2recid   AS RECID) IN h_dmputil.
FUNCTION inprimary RETURNS LOGICAL (INPUT p_db1PrimeIndex AS RECID,
                                    INPUT p_db1RecId      AS RECID)
                                    IN h_dmputil.

FUNCTION inindex RETURNS LOGICAL (INPUT p_db1File AS RECID,
                                  INPUT p_db1Field      AS RECID)
                                  IN h_dmputil.

FUNCTION checkRenameTable RETURNS CHARACTER (  /* 02/01/29 vap (IZ# 1525) */
                          INPUT pcRenameFrom   AS CHARACTER ,
                          INPUT pcRenameToList AS CHARACTER ) IN h_dmputil.

FUNCTION checkRenameField RETURNS CHARACTER (  /* 02/01/29 vap (IZ# 1525) */
                          INPUT pcTableName    AS CHARACTER ,
                          INPUT pcRenameFrom   AS CHARACTER ,
                          INPUT pcRenameToList AS CHARACTER ) IN h_dmputil.

FUNCTION checkRenameSequence RETURNS CHARACTER (  /* 02/01/29 vap (IZ# 1525) */
                             INPUT pcRenameFrom   AS CHARACTER ,
                             INPUT pcRenameToList AS CHARACTER ) IN h_dmputil.

FUNCTION CHECK_SA_FIELDS RETURNS LOGICAL (INPUT c1 AS CHAR, INPUT c2 AS CHAR) FORWARD.

/* mainline code **********************************************************/

/* 02/01/29 vap (IZ# 1525) */
ASSIGN p-batchmode = SESSION:BATCH-MODE.
IF p-batchmode THEN DO:
  ASSIGN p-rename-file = ENTRY(1,user_env[19])
         p-index-mode  = ENTRY(2,user_env[19])
         p-debug-mode  = INTEGER(ENTRY(3,user_env[19])) NO-ERROR.
  RUN set_Variables           IN h_dmputil(p-rename-file, p-debug-mode).
  RUN load_Rename_Definitions IN h_dmputil.
END.  /* batchmode */

IF  user_env[5] = ""
 OR user_env[5] = ?  THEN assign user_env[5] = "<internal defaults apply>".

IF  user_env[5] = "<internal defaults apply>"
 THEN OUTPUT STREAM ddl TO VALUE(user_env[2]) NO-ECHO NO-MAP
            NO-CONVERT.
 ELSE OUTPUT STREAM ddl TO VALUE(user_env[2]) NO-ECHO NO-MAP
            CONVERT SOURCE SESSION:CHARSET TARGET user_env[5].

SESSION:IMMEDIATE-DISPLAY = yes.
/* Display database name at the top of the respective column. */
FIND FIRST DICTDB._Db WHERE RECID(DICTDB._Db) = drec_db NO-LOCK.
IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
  DISPLAY LDBNAME("DICTDB") @ db WITH FRAME seeking.
FIND FIRST DICTDB2._Db WHERE RECID(DICTDB2._Db) = RECID(database2) NO-LOCK.
IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
  DISPLAY LDBNAME("DICTDB2") @ db2 WITH FRAME seeking.

IF NOT p-batchmode THEN DO:  /* 02/01/29 vap (IZ# 1525) */
  DISPLAY new_lang[1] @ fil  WITH FRAME seeking. /* initializing */
  DISPLAY new_lang[1] @ fil2 WITH FRAME seeking. /* initializing */
  run adecomm/_setcurs.p ("WAIT").
END.  /* batchmode */

DO ON STOP UNDO, LEAVE:
  /* build missing file list for rename/delete determination */
  FOR EACH DICTDB2._File
    WHERE DICTDB2._File._Db-recid = RECID(database2)
      AND (DICTDB2._File._Owner = "PUB" OR DICTDB2._File._Owner = "_FOREIGN")
      AND DICTDB2._File._tbl-type = "T":
    FIND FIRST DICTDB._File
      WHERE DICTDB._File._Db-recid = drec_db
        AND DICTDB._File._File-name = DICTDB2._File._File-name
      AND (DICTDB._File._Owner = "PUB" OR DICTDB._File._Owner = "_FOREIGN")
      AND DICTDB._File._Tbl-type = "T" NO-ERROR.
    IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
      DISPLAY DICTDB2._File._File-name @ fil WITH FRAME seeking.
    IF AVAILABLE DICTDB._File THEN DO:
      IF NOT fileAreaMatch(INPUT DICTDB._File._File-number,
                           INPUT DICTDB2._File._File-Number,
                           INPUT DICTDB._File._Db-recid,
                           INPUT DICTDB2._File._Db-recid) THEN DO:
        s_errorsLogged = TRUE.
        OUTPUT STREAM err-log TO {&errFileName} APPEND NO-ECHO.
        p-log-line = new_lang[3] + '"' + DICTDB2._File._File-Name + '"' +
                     new_lang[4].  /* 02/01/29 vap (IZ# 1525) */
        PUT STREAM err-log UNFORMATTED p-log-line SKIP.
        DO i = 5 TO 8:
            PUT STREAM err-log UNFORMATTED new_lang[i] SKIP.
        END.
        PUT STREAM err-log UNFORMATTED new_lang[9] SKIP(1).
        OUTPUT STREAM err-log CLOSE.
      END.
      NEXT.
    END.
    CREATE missing.
    missing.name = DICTDB2._File._File-name.
  END.

  /* build list of new or renamed files */
  FOR EACH DICTDB._File WHERE DICTDB._File._Db-recid = drec_db
                          AND (DICTDB._File._Owner = "PUB" OR
                               DICTDB._File._Owner = "_FOREIGN")
                          AND DICTDB._File._Tbl-type = "T":

    FIND FIRST DICTDB2._File WHERE DICTDB2._File._Db-recid = RECID(database2)
                               AND DICTDB2._File._File-name =
                                   DICTDB._File._File-name
                               AND (DICTDB2._File._Owner = "PUB" OR
                                    DICTDB2._File._Owner = "_FOREIGN")
                                    NO-ERROR.
    IF NOT p-batchmode THEN /* 02/01/29 vap (IZ# 1525) */
      DISPLAY DICTDB._File._File-name @ fil WITH FRAME seeking.
    CREATE table-list.
    ASSIGN table-list.t1-name = DICTDB._File._File-name.
    IF AVAILABLE DICTDB2._File THEN
      table-list.t2-name = DICTDB._File._File-name.
  END.

  /* look for matches for renamed files with user input.  A prompt
     is given for each file in DICTDB2 that's not in DICTDB but only when
     there is also a file in DICTDB that's not in DICTDB2.  The 2nd list
     is the potential values to rename to.
  */
  IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
    run adecomm/_setcurs.p ("").  /* while dmpisub is running */
  ELSE DO:  /* 02/01/29 vap (IZ# 1525) */
    ASSIGN p-comma = "":U
           p-list  = "":U.
    FOR EACH table-list WHERE
             table-list.t2-name = ?:
      ASSIGN p-list  = p-list + p-comma + table-list.t1-name
             p-comma = ",":U.
    END.
  END.
  FOR EACH missing:
    /* 02/01/29 vap (IZ# 1525) */
    IF NOT p-batchmode THEN DO:
      DISPLAY missing.name @ fil WITH FRAME seeking.
      RUN "prodict/dump/_dmpisub.p"
        (INPUT "t",INPUT-OUTPUT missing.name,OUTPUT ans).
      IF missing.name = ? THEN
         DELETE missing.
      IF ans = ? THEN DO:
        HIDE FRAME seeking NO-PAUSE.
        user_path = "".
        RETURN.
      END.
    END.  /* NOT p-batchmode */
    ELSE DO:  /* 02/01/29 vap (IZ# 1525) */
      ASSIGN p-foo = checkRenameTable(missing.name, p-list).
      IF p-foo NE ? THEN DO:
         FIND FIRST table-list WHERE
                    table-list.t1-name = p-foo AND
                    table-list.t2-name = ?
                    NO-ERROR.
         IF AVAILABLE(table-list) THEN
           ASSIGN table-list.t2-name = missing.name.
         /* tablemove check */ /* peterk fix 12796*/
         RUN prodict/dump/_dmpisub.p(INPUT "table_check,":U + p-foo +
                                            ",":U + missing.name,
                                     INPUT-OUTPUT p-foo2,
                                     OUTPUT       ans).   /* dummy var */
         DELETE missing.
      END.  /* p-foo NE ? */
    END.  /* p-batchmode */
  END.
  IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
    run adecomm/_setcurs.p ("WAIT").

  /* handle deleted files */
  ans = FALSE.
  FOR EACH missing:
    ans = TRUE.
    PUT STREAM ddl UNFORMATTED
      'DROP TABLE "' missing.name '"' SKIP.
    IF NOT p-batchmode THEN DO: /* 02/01/29 vap (IZ# 1525) */
      DISPLAY missing.name @ fil WITH FRAME seeking.
      DISPLAY missing.name @ fil2 WITH FRAME seeking.
    END.
    DELETE missing.
  END.
  IF ans THEN PUT STREAM ddl UNFORMATTED SKIP(1).

  /* handle renamed files */
  ans = FALSE.
  FOR EACH table-list WHERE table-list.t1-name <> table-list.t2-name
                        AND table-list.t2-name <> ?:
    ASSIGN ans = TRUE.
    PUT STREAM ddl UNFORMATTED
      'RENAME TABLE "' table-list.t2-name
      '" TO "' table-list.t1-name '"' SKIP.
    IF NOT p-batchmode THEN DO: /* 02/01/29 vap (IZ# 1525) */
      DISPLAY table-list.t1-name @ fil WITH FRAME seeking.
      DISPLAY table-list.t1-name @ fil2 WITH FRAME seeking.
    END.
  END.
  IF ans THEN PUT STREAM ddl UNFORMATTED SKIP(1).

  /* dump newly created files */
  FOR EACH table-list WHERE table-list.t2-name = ?:
    FIND DICTDB._File WHERE DICTDB._File._Db-recid = drec_db AND
         DICTDB._File._File-name = table-list.t1-name AND
       (DICTDB._File._Owner = "PUB" OR DICTDB._File._Owner = "_FOREIGN").
    IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
      DISPLAY DICTDB._File._File-name @ fil WITH FRAME seeking.
    FIND DICTDB._StorageObject WHERE
         DICTDB._StorageObject._Object-type = 1 AND
         DICTDB._StorageObject._Object-number = DICTDB._File._File-number
    NO-ERROR.
    IF AVAILABLE DICTDB._StorageObject THEN
       FIND DICTDB._Area WHERE
            DICTDB._Area._Area-number = DICTDB._StorageObject._Area-number
       NO-ERROR.
       FIND DICTDB2._Area WHERE
            DICTDB2._Area._Area-name = DICTDB._Area._Area-name NO-ERROR.
       IF NOT AVAILABLE DICTDB2._Area THEN
       DO:
         ASSIGN s_errorsLogged = TRUE.
         OUTPUT STREAM err-log TO {&errFileName} APPEND NO-ECHO.
         PUT STREAM err-log UNFORMATTED new_lang[3] +
            '"' + DICTDB._Area._Area-name + '"' + new_lang[21]     SKIP
            new_lang[22]                                           SKIP
            new_lang[31]                                           SKIP
            '"' + DICTDB._File._File-name + '"' + new_lang[24]     SKIP
            new_lang[25]                                           SKIP
            new_lang[26]                                           SKIP(1).
         OUTPUT STREAM err-log CLOSE.
       END.
    RUN "prodict/dump/_dmpdefs.p" ("t",RECID(DICTDB._File),"Y").
    IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
      DISPLAY DICTDB._File._File-name @ fil2 WITH FRAME seeking.
    DELETE table-list.
  END.

  /* handle potentially altered files */
  FOR EACH table-list:
    IF NOT p-batchmode THEN DO: /* 02/01/29 vap (IZ# 1525) */
      DISPLAY table-list.t1-name @ fil "" @ fld "" @ idx WITH FRAME seeking.
      DISPLAY table-list.t1-name @ fil2 "" @ fld2 "" @ idx2 WITH FRAME seeking.
    END.
    FIND DICTDB._File WHERE DICTDB._File._Db-recid = drec_db
      AND DICTDB._File._File-name = table-list.t1-name
      AND (DICTDB._File._Owner = "PUB" OR DICTDB._File._Owner = "_FOREIGN").
    FIND DICTDB2._File WHERE DICTDB2._File._Db-recid = RECID(database2)
      AND DICTDB2._File._File-name = table-list.t2-name
      AND (DICTDB2._File._Owner = "PUB" OR DICTDB2._File._Owner = "_FOREIGN").

    /* clean out working storage */
    FOR EACH field-list:
      DELETE field-list.
    END.
    FOR EACH index-list:
      DELETE index-list.
    END.


    /* write out appropriate file definition changes */
    ASSIGN
      j      = 1
      ddl    = ""
      ddl[1] = 'UPDATE TABLE "' + DICTDB._File._File-name + '"'.
    RUN dctquot IN h_dmputil (DICTDB._File._Can-Read,'"',OUTPUT c).
    IF COMPARE(DICTDB._File._Can-read,"NE",DICTDB2._File._Can-read,"RAW") THEN ASSIGN
      j = j + 1
      ddl[j] = "  CAN-READ " + c.
    RUN dctquot IN h_dmputil (DICTDB._File._Can-Write,'"',OUTPUT c).
    IF COMPARE(DICTDB._File._Can-write,"NE",DICTDB2._File._Can-write,"RAW") THEN ASSIGN
      j = j + 1
      ddl[j] = "  CAN-WRITE " + c.
    RUN dctquot IN h_dmputil (DICTDB._File._Can-Create,'"',OUTPUT c).
    IF COMPARE(DICTDB._File._Can-create,"NE",DICTDB2._File._Can-create,"RAW") THEN ASSIGN
      j = j + 1
      ddl[j] = "  CAN-CREATE " + c.
    RUN dctquot IN h_dmputil (DICTDB._File._Can-Delete,'"',OUTPUT c).
    IF COMPARE(DICTDB._File._Can-delete,"NE",DICTDB2._File._Can-delete,"RAW") THEN ASSIGN
      j = j + 1
      ddl[j] = "  CAN-DELETE " + c.
    RUN dctquot IN h_dmputil (DICTDB._File._Can-Dump,'"',OUTPUT c).
    IF COMPARE(DICTDB._File._Can-Dump,"NE",DICTDB2._File._Can-Dump,"RAW") THEN ASSIGN
      j = j + 1
      ddl[j] = "  CAN-DUMP " + c.
    RUN dctquot IN h_dmputil (DICTDB._File._Can-Load,'"',OUTPUT c).
    IF COMPARE(DICTDB._File._Can-Load,"NE",DICTDB2._File._Can-Load,"RAW") THEN ASSIGN
      j = j + 1
      ddl[j] = "  CAN-LOAD " + c.
    RUN dctquot IN h_dmputil (DICTDB._File._Desc,'"',OUTPUT c).
    IF DICTDB._File._Desc <> DICTDB2._File._Desc THEN ASSIGN
      j = j + 1
      ddl[j] = "  DESCRIPTION " + c.
    RUN dctquot IN h_dmputil (DICTDB._File._File-label,'"',OUTPUT c).
    IF COMPARE(DICTDB._File._File-label,"NE",DICTDB2._File._File-label,"RAW") THEN ASSIGN
      j = j + 1
      ddl[j] = "  LABEL " + c.
    RUN dctquot IN h_dmputil (DICTDB._File._File-label-SA,'"',OUTPUT c).
    IF COMPARE(DICTDB._File._File-label-SA,"NE",DICTDB2._File._File-label-SA,"RAW") THEN ASSIGN
      j = j + 1
      ddl[j] = "  LABEL-SA " + c.
    RUN dctquot IN h_dmputil (DICTDB._File._Valexp,'"',OUTPUT c).
    IF COMPARE(DICTDB._File._Valexp,"NE",DICTDB2._File._Valexp,"RAW") THEN ASSIGN
      j = j + 1
      ddl[j] = "  VALEXP " + c.
    RUN dctquot IN h_dmputil (DICTDB._File._Valmsg,'"',OUTPUT c).
    IF DICTDB._File._Valmsg <> DICTDB2._File._Valmsg THEN ASSIGN
      j = j + 1
      ddl[j] = "  VALMSG " + c.
    RUN dctquot IN h_dmputil (DICTDB._File._Valmsg-SA,'"',OUTPUT c).
    IF COMPARE(DICTDB._File._Valmsg-SA,"NE",DICTDB2._File._Valmsg-SA,"RAW") THEN ASSIGN
      j = j + 1
      ddl[j] = "  VALMSG-SA " + c.
    RUN dctquot IN h_dmputil (DICTDB._File._Dump-name,'"',OUTPUT c).
    IF DICTDB._File._Dump-name <> DICTDB2._File._Dump-name THEN ASSIGN
      j = j + 1
      ddl[j] = "  DUMP-NAME " + c.
    RUN dctquot IN h_dmputil (DICTDB._File._Fil-misc2[6],'"',OUTPUT c).
    IF COMPARE(DICTDB._File._Fil-misc2[6],"NE",DICTDB2._File._Fil-misc2[6],"RAW") THEN ASSIGN
      j = j + 1
      ddl[j] = "  FILE-MISC26 " + c.
    IF DICTDB._File._Hidden <> DICTDB2._File._Hidden THEN DO:
        IF DICTDB._File._Hidden THEN
          ASSIGN j = j + 1
                 ddl[j] = "  HIDDEN ".
        ELSE
          ASSIGN j = j + 1
                 ddl[j] = " NOT-HIDDEN ".
    END.
    IF DICTDB._File._Frozen <> DICTDB2._File._Frozen AND NOT DICTDB2._File._Frozen THEN
        ASSIGN j = j + 1
               ddl[j] = "  FROZEN".

    /* deal with file triggers */
    /* 1st, find ones to be deleted */
    FOR EACH DICTDB2._File-trig OF DICTDB2._File:
      FIND DICTDB._File-trig OF DICTDB._File
        WHERE DICTDB._File-trig._Event = DICTDB2._File-trig._Event NO-ERROR.
      IF NOT AVAILABLE DICTDB._File-trig THEN DO:
        RUN dctquot IN h_dmputil (DICTDB2._File-trig._Event,'"',OUTPUT c).
        j = j + 1.
        ddl[j] = "  TABLE-TRIGGER " + c + " DELETE".
      END.
    END.
    /* now record updated or new ones */
    FOR EACH DICTDB._File-trig OF DICTDB._File:
      FIND DICTDB2._File-trig OF DICTDB2._File
        WHERE DICTDB2._File-trig._Event = DICTDB._File-trig._Event NO-ERROR.
      IF AVAILABLE DICTDB2._File-trig AND
        DICTDB2._File-trig._Override = DICTDB._File-trig._Override AND
        DICTDB2._File-trig._Proc-name = DICTDB._File-trig._Proc-name AND
        DICTDB2._File-trig._Trig-CRC = DICTDB._File-trig._Trig-CRC THEN
        NEXT.

      RUN dctquot IN h_dmputil (DICTDB._File-trig._Event,'"',OUTPUT c).
      j = j + 1.
      ddl[j] = "  TABLE-TRIGGER " + c +
               (IF DICTDB._File-trig._Override THEN " OVERRIDE "
                                               ELSE " NO-OVERRIDE ").
      RUN dctquot IN h_dmputil (DICTDB._File-trig._Proc-name,'"',OUTPUT c).
      ddl[j] = ddl[j] + "PROCEDURE " + c + " CRC """
               + (IF DICTDB._File-trig._Trig-CRC = ?
                  THEN "?" ELSE STRING(DICTDB._File-trig._Trig-CRC))
               + """".
    END.

    /* don't write out ddl[1] if j = 1 (i.e., we only have table header) */
    IF j > 1 THEN
      DO i = 1 TO j + 1:
        IF ddl[i] = "" THEN  /* this puts an extra skip after the last one */
          PUT STREAM ddl UNFORMATTED SKIP(1).
        ELSE
          PUT STREAM ddl UNFORMATTED ddl[i] SKIP.
      END.

    /* build missing field list for rename/delete determination */
    FOR EACH DICTDB2._Field OF DICTDB2._File BY DICTDB2._Field._field-rpos:
      FIND FIRST DICTDB._Field OF DICTDB._File
        WHERE DICTDB._Field._Field-name = DICTDB2._Field._Field-name NO-ERROR.
      IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
        DISPLAY DICTDB2._Field._Field-name @ fld WITH FRAME seeking.
      IF AVAILABLE DICTDB._Field THEN DO:
          /* OE00147106
             If the type or extent changed we need to give the user
             the option of selecting another field in case the original
             one still exists with a different name.
          */
          IF DICTDB._Field._Data-type EQ DICTDB2._Field._Data-type AND
             DICTDB._Field._Extent EQ DICTDB2._Field._Extent THEN NEXT.
          ELSE DO:
              /* SQL timestamp/datetime is not a difference. int -> int64
                 is not a change that require a field to be recreated,
                 so don't need to check in those cases.
              */
              IF NOT(DICTDB._Field._Dtype = 41 AND DICTDB2._Field._Dtype = 4)
                  AND NOT (DICTDB._Field._Dtype = DICTDB2._Field._Dtype AND
                  DICTDB._Field._Dtype = 34) THEN DO:
                  /* create a missing record with crit = yes - special case */
                  CREATE missing.
                  ASSIGN missing.name = DICTDB2._Field._Field-name
                         missing.crit = YES.
              END.

              NEXT. /* go to the next record */
          END.
      END.
      CREATE missing.
      missing.name = DICTDB2._Field._Field-name.
    END.

    /* build field rename list */
    FOR EACH DICTDB._Field OF DICTDB._File BY DICTDB._Field._field-rpos:
      FIND FIRST DICTDB2._Field OF DICTDB2._File
        WHERE DICTDB2._Field._Field-name = DICTDB._Field._Field-name NO-ERROR.
      IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
        DISPLAY DICTDB._Field._Field-name @ fld WITH FRAME seeking.
      CREATE field-list.
      field-list.f1-name = DICTDB._Field._Field-name.
      IF AVAILABLE DICTDB2._Field THEN
        ASSIGN field-list.f2-name = DICTDB._Field._Field-name.
    END.

    /* look for matches for renamed fields with user input.  A prompt
       is given for each field in DICTDB2 that's not in DICTDB but only when
       there is also a field in DICTDB that's not in DICTDB2.  The 2nd list
       is the potential values to rename to.
    */

    IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
      run adecomm/_setcurs.p ("").
    ELSE DO:  /* 02/01/29 vap (IZ# 1525) */
      ASSIGN p-comma = "":U
             p-list  = "":U.
      FOR EACH field-list WHERE
               field-list.f2-name = ?:
        ASSIGN p-list  = p-list + p-comma + field-list.f1-name
               p-comma = ",":U.
      END.
    END.
    user_env[19] = DICTDB._File._File-name. /* this is a hack */
    FOR EACH missing:
      /* 02/01/29 vap (IZ# 1525) */
      IF NOT p-batchmode THEN DO:
        DISPLAY missing.name @ fld WITH FRAME seeking.
        /* OE00147106 If crit = yes, this is a special case. See above */
        IF missing.crit = YES THEN
            RUN "prodict/dump/_dmpisub.p"
              (INPUT "fc",INPUT-OUTPUT missing.name,OUTPUT ans).
        ELSE
            RUN "prodict/dump/_dmpisub.p"
              (INPUT "f",INPUT-OUTPUT missing.name,OUTPUT ans).
        /* we always delete the missing record if crit = yes */
        IF missing.name = ? OR missing.crit THEN DELETE missing.
        IF ans = ? THEN DO:
          HIDE FRAME seeking NO-PAUSE.
          user_path = "".
          RETURN.
        END.
      END.  /* NOT p-batchmode */
      ELSE DO:  /* 02/01/29 vap (IZ# 1525) */
        ASSIGN p-foo = checkRenameField(DICTDB._File._File-name,
                                        missing.name, p-list).
        IF p-foo NE ? THEN DO:
           FIND FIRST field-list WHERE
                      field-list.f1-name = p-foo AND
                      field-list.f2-name = ?
                      NO-ERROR.
           IF AVAILABLE(field-list) THEN DO:
             ASSIGN field-list.f2-name = missing.name.

             IF missing.crit = YES THEN DO: /* OE00147106 special case */
                 /* fix the original field-list record so that we consider
                    it a new field .
                 */
                 FIND FIRST field-list WHERE field-list.f1-name = missing.name.
                 ASSIGN field-list.f2-name = ?.
             END.
           END.
           DELETE missing.
        END.  /* p-foo NE ? */
        ELSE IF missing.crit = YES THEN
            DELETE missing. /* always delete missing if crit = yes */

      END.  /* p-batchmode */
    END.
    IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
      run adecomm/_setcurs.p ("WAIT").

    /* We use to handle deleted fields here but now it's done after
       index stuff.  See below.
     */

    /* handle renamed fields */
    ans = FALSE.
    FOR EACH field-list
      WHERE field-list.f1-name <> field-list.f2-name
        AND field-list.f2-name <> ?:
      FIND FIRST DICTDB._Field OF DICTDB._File
        WHERE DICTDB._Field._Field-name = field-list.f1-name.
      FIND FIRST DICTDB2._Field OF DICTDB2._File
        WHERE DICTDB2._Field._Field-name = field-list.f2-name NO-ERROR.

      ans = TRUE.
      IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
        DISPLAY field-list.f1-name @ fld2 WITH FRAME seeking.

      /* If the field is in an index and a critical aspect of it changed,
         such as data-type or extent, it will be handled later */
      IF AVAILABLE DICTDB2._Field                               AND
         (DICTDB._Field._Data-type <> DICTDB2._Field._Data-type OR
          DICTDB._Field._Extent    <> DICTDB2._Field._Extent)   THEN NEXT.

      PUT STREAM ddl UNFORMATTED
        'RENAME FIELD "' field-list.f2-name
        '" OF "' DICTDB._File._File-name
        '" TO "' field-list.f1-name '"' SKIP.
    END.
    IF ans THEN PUT STREAM ddl UNFORMATTED SKIP(1).

    ASSIGN i-to-int64 = 0.

    /* handle new or potentially altered fields */
    FOR EACH field-list:
      FIND FIRST DICTDB._Field OF DICTDB._File
        WHERE DICTDB._Field._Field-name = field-list.f1-name.
      FIND FIRST DICTDB2._Field OF DICTDB2._File
        WHERE DICTDB2._Field._Field-name = field-list.f2-name NO-ERROR.
      IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
        DISPLAY field-list.f1-name @ fld2 WITH FRAME seeking.

      ASSIGN l = AVAILABLE DICTDB2._Field
             to-int64 = FALSE.

      /* 20060220-021
         In 10.1A, SQL timestamp is now datetime, in which case it's not a
         difference, so we need to check if the dype if 34.
      */
      IF l THEN DO:
        IF DICTDB._Field._Data-type <> DICTDB2._Field._Data-type THEN DO:

           /* check if this is a change from integer to int64 */
           ASSIGN to-int64 = (DICTDB._Field._Dtype = 41 AND DICTDB2._Field._Dtype = 4).

           IF DICTDB._Field._Dtype = DICTDB2._Field._Dtype AND
              DICTDB._Field._Dtype = 34 THEN
              ans = FALSE.
           ELSE IF to-int64 THEN
               /* we will allow integer to int64 changes */
               ASSIGN ans = FALSE
                      i-to-int64 = i-to-int64 + 1.
           ELSE
              ans = TRUE.
        END.
        ELSE DO:
           ans = FALSE.

           IF DICTDB._Field._Data-type = "CLOB" THEN DO:
               /* OE00177533 - if a clob field, check if there was a change
                  in codepage or collation */
               IF (DICTDB._Field._Charset NE DICTDB2._Field._Charset) OR
                   (DICTDB._Field._Collation NE DICTDB2._Field._Collation) THEN
                   ans = TRUE.
           END.
        END.
      END.

      IF l AND (ans OR DICTDB._Field._Extent <> DICTDB2._Field._Extent) THEN DO:

        /* If DICTDB2 field is part of a primary index, we cannot simply drop it.
         * instead, we will rename it to something else, and delete it
         * later, after the indexes are processed.
         */
        IF inprimary(INPUT DICTDB2._File._Prime-Index,
                     INPUT RECID(DICTDB2._Field)) THEN DO:

          /* field is part of primary index, don't DROP*/
          RUN tmp-name IN h_dmputil (INPUT DICTDB2._Field._Field-name,
                                     OUTPUT tmp_Field-name).
          PUT STREAM ddl UNFORMATTED
            'RENAME FIELD "' DICTDB2._Field._Field-name
            '" OF "' DICTDB2._File._File-name
            '" TO "' tmp_Field-name '"' SKIP.
          CREATE missing.
          ASSIGN missing.name = tmp_Field-name. /*record name to 'DROP' later*/
                            l = false.
        END.
        ELSE IF inindex(INPUT RECID(DICTDB2._File),
                        INPUT RECID(DICTDB2._Field)) THEN  DO:

          RUN tmp-name IN h_dmputil (INPUT DICTDB2._Field._Field-name,
                                     OUTPUT tmp_Field-name).
          PUT STREAM ddl UNFORMATTED
            'RENAME FIELD "' DICTDB2._Field._Field-name
            '" OF "' DICTDB2._File._File-name
            '" TO "' tmp_Field-name '"' SKIP.
          CREATE missing.
          ASSIGN missing.name = tmp_Field-name. /*record name to 'DROP' later*/
                            l = false.
        END.
        ELSE DO: /* is not in a primary index, we can DROP it now */

          /* We need to know it has been dropped in case it is a component *
           * of an index.  In that case, we don't want to drop the index   *
           * because dropping the field accomplished that.                 *
           * 19981112-011                                             */

          CREATE drop-list.
          ASSIGN drop-list.file-name  = DICTDB._File._File-Name
                 drop-list.f1-name    = field-list.f1-name
                 drop-list.f2-name    = field-list.f2-name.
          PUT STREAM ddl UNFORMATTED
            'DROP FIELD "' DICTDB._Field._Field-name
            '" OF "' DICTDB._File._File-name '"' SKIP.
          RELEASE DICTDB2._Field.
          l = FALSE.
        END.
      END.
      /* If l is true we're updating otherwise we're adding */
      ASSIGN ddl    = ""
             ddl[1] = (IF l THEN "UPDATE" ELSE "ADD")
                      + ' FIELD "' + DICTDB._Field._Field-name
                      + '" OF "' + DICTDB._File._File-name + '"'
                      + (IF l AND NOT to-int64 THEN "" ELSE " AS " + DICTDB._Field._Data-type).
      RUN dctquot IN h_dmputil (DICTDB._Field._Desc,'"',OUTPUT c).
      IF NOT l OR COMPARE(DICTDB._Field._Desc,"NE",DICTDB2._Field._Desc,"RAW") THEN
           ddl[2] = "  DESCRIPTION " + c.
      RUN dctquot IN h_dmputil (DICTDB._Field._Format,'"',OUTPUT c).
      IF NOT l OR COMPARE(DICTDB._Field._Format,"NE",DICTDB2._Field._Format,"RAW") THEN
        ddl[3] = "  FORMAT " + c.
      RUN dctquot IN h_dmputil (DICTDB._Field._Format-SA,'"',OUTPUT c).
      IF NOT l OR
          /* ignore this field if they are a combination of ? and empty strings */
          (CHECK_SA_FIELDS(DICTDB._Field._Format-SA,DICTDB2._Field._Format-SA) AND
          COMPARE(DICTDB._Field._Format-SA,"NE",DICTDB2._Field._Format-SA,"RAW")) THEN
        ddl[4] = "  FORMAT-SA " + c.
      RUN dctquot IN h_dmputil (DICTDB._Field._Initial,'"',OUTPUT c).
      IF NOT l OR DICTDB._Field._Field-rpos <> DICTDB2._Field._Field-rpos THEN
        ddl[5] = "  POSITION " + STRING(DICTDB._Field._Field-rpos).
      IF NOT l OR COMPARE(DICTDB._Field._Initial,"NE",DICTDB2._Field._Initial,"RAW") THEN
        ddl[6] = "  INITIAL " + c.
      RUN dctquot IN h_dmputil (DICTDB._Field._Initial-SA,'"',OUTPUT c).
      IF NOT l OR
           /* ignore this field if they are a combination of ? and empty strings */
           (CHECK_SA_FIELDS(DICTDB._Field._Initial-SA,DICTDB2._Field._Initial-SA) AND
             COMPARE(DICTDB._Field._Initial-SA,"NE",DICTDB2._Field._Initial-SA,"RAW")) THEN
        ddl[7] = "  INITIAL-SA " + c.
      RUN dctquot IN h_dmputil (DICTDB._Field._Help,'"',OUTPUT c).
      IF NOT l OR COMPARE(DICTDB._Field._Help,"NE",DICTDB2._Field._Help,"RAW") THEN
        ddl[8] = "  HELP " + c.
      RUN dctquot IN h_dmputil (DICTDB._Field._Help-SA,'"',OUTPUT c).
      IF NOT l OR COMPARE(DICTDB._Field._Help-SA,"NE",DICTDB2._Field._Help-SA,"RAW") THEN
        ddl[9] = "  HELP-SA " + c.
      RUN dctquot IN h_dmputil (DICTDB._Field._Label,'"',OUTPUT c).
      IF NOT l OR COMPARE(DICTDB._Field._Label,"NE",DICTDB2._Field._Label,"RAW") THEN
        ddl[10] = "  LABEL " + c.
      RUN dctquot IN h_dmputil (DICTDB._Field._Label-SA,'"',OUTPUT c).
      IF NOT l OR
             /* ignore this field if they are a combination of ? and empty strings */
             (CHECK_SA_FIELDS(DICTDB._Field._Label-SA,DICTDB2._Field._Label-SA) AND
             COMPARE(DICTDB._Field._Label-SA,"NE",DICTDB2._Field._Label-SA,"RAW")) THEN
        ddl[11] = "  LABEL-SA " + c.
      RUN dctquot IN h_dmputil (DICTDB._Field._Col-label,'"',OUTPUT c).
      IF NOT l OR COMPARE(DICTDB._Field._Col-label,"NE",DICTDB2._Field._Col-label,"RAW") THEN
        ddl[12] = "  COLUMN-LABEL " + c.
      RUN dctquot IN h_dmputil (DICTDB._Field._Col-label-SA,'"',OUTPUT c).
      IF NOT l OR
              /* ignore this field if they are a combination of ? and empty strings */
              (CHECK_SA_FIELDS(DICTDB._Field._Col-label-SA,DICTDB2._Field._Col-label-SA) AND
               COMPARE(DICTDB._Field._Col-label-SA,"NE",DICTDB2._Field._Col-label-SA,"RAW")) THEN
        ddl[13] = "  COLUMN-LABEL-SA " + c.
      RUN dctquot IN h_dmputil (DICTDB._Field._Can-Read,'"',OUTPUT c).
      IF NOT l OR COMPARE(DICTDB._Field._Can-read,"NE",DICTDB2._Field._Can-read,"RAW") THEN
        ddl[14] = "  CAN-READ " + c.
      RUN dctquot IN h_dmputil (DICTDB._Field._Can-Write,'"',OUTPUT c).
      IF NOT l OR COMPARE(DICTDB._Field._Can-write,"NE",DICTDB2._Field._Can-write,"RAW") THEN
        ddl[15] = "  CAN-WRITE " + c.
      RUN dctquot IN h_dmputil (DICTDB._Field._Valexp,'"',OUTPUT c).
      IF NOT l OR COMPARE(DICTDB._Field._Valexp,"NE",DICTDB2._Field._Valexp,"RAW") THEN
        ddl[16] = "  VALEXP " + c.
      RUN dctquot IN h_dmputil (DICTDB._Field._Valmsg,'"',OUTPUT c).
      IF NOT l OR DICTDB._Field._Valmsg <> DICTDB2._Field._Valmsg THEN
        ddl[17] = "  VALMSG " + c.
      RUN dctquot IN h_dmputil (DICTDB._Field._Valmsg-SA,'"',OUTPUT c).
      IF NOT l OR COMPARE(DICTDB._Field._Valmsg-SA,"NE",DICTDB2._Field._Valmsg-SA,"RAW") THEN
        ddl[18] = "  VALMSG-SA " + c.
      RUN dctquot IN h_dmputil (DICTDB._Field._View-as,'"',OUTPUT c).
      IF NOT l OR COMPARE(DICTDB._Field._View-as,"NE",DICTDB2._Field._View-as,"RAW") THEN
        ddl[19] = "  VIEW-AS " + c.
      IF NOT l OR DICTDB._Field._Extent <> DICTDB2._Field._Extent THEN
        ddl[20] = "  EXTENT " + STRING(DICTDB._Field._Extent).
      IF NOT l OR DICTDB._Field._Decimals <> DICTDB2._Field._Decimals THEN
        ddl[21] = "  DECIMALS " + (IF DICTDB._Field._Decimals = ? THEN "?"
                    ELSE STRING(DICTDB._Field._Decimals)).
      IF NOT l OR DICTDB._Field._Order <> DICTDB2._Field._Order THEN
        ddl[22] = "  ORDER " + STRING(DICTDB._Field._Order).
      IF NOT l OR DICTDB._Field._Mandatory <> DICTDB2._Field._Mandatory THEN
        ddl[23] = (IF DICTDB._Field._Mandatory
                    THEN "  MANDATORY" ELSE "  NULL-ALLOWED").
      IF NOT l OR DICTDB._Field._Fld-case <> DICTDB2._Field._Fld-case THEN
        ddl[24] = (IF DICTDB._Field._Fld-case
                    THEN "  CASE-SENSITIVE" ELSE "  NOT-CASE-SENSITIVE").
      IF NOT l AND CAN-DO("BLOB,CLOB",DICTDB._Field._Data-type) THEN DO:
        FIND DICTDB._storageobject WHERE DICTDB._Storageobject._Db-recid = RECID(DICTDB._Db)
                                AND DICTDB._Storageobject._Object-type = 3
                                AND DICTDB._Storageobject._Object-number = DICTDB._Field._Fld-stlen
                              NO-LOCK.
        FIND DICTDB._Area WHERE DICTDB._Area._Area-number = DICTDB._StorageObject._Area-number NO-LOCK.

        ASSIGN ddl[25] = "  LOB-AREA " + DICTDB._Area._Area-name
               ddl[26] = "  LOB-BYTES "+ STRING(DICTDB._Field._Width)
               ddl[27] = "  LOB-SIZE " + DICTDB._Field._Fld-Misc2[1].

        IF DICTDB._Field._Data-Type = "CLOB" THEN
          ASSIGN ddl[28] = "  CLOB-CODEPAGE "  + DICTDB._Field._Charset
                 ddl[29] = "  CLOB-COLLATION " + DICTDB._Field._Collation
                 ddl[30] = "  CLOB-TYPE "      + STRING(DICTDB._Field._Attributes1).
      END.
      /* Changing blob/clob field */
      ELSE IF l AND CAN-DO("BLOB,CLOB",DICTDB._Field._Data-type) THEN DO:
        IF DICTDB._Field._Width <> DICTDB2._Field._Width THEN
            ddl[25] = "  LOB-BYTES " + STRING(DICTDB._Field._Width).
        IF DICTDB._Field._Fld-Misc2[1] <> DICTDB2._Field._Fld-Misc2[1] THEN
            ddl[26] = "  LOB-SIZE " + DICTDB._Field._Fld-Misc2[1].

        IF DICTDB._Field._Data-type = "CLOB" AND
           DICTDB._Field._Attributes1  <> DICTDB2._Field._Attributes1 THEN DO:

          IF DICTDB._Field._Attributes1 = 1 AND DICTDB2._Field._Attributes1 = 2 THEN DO:
             /* OE00177533 - can't change it from 2 to 1 in the target db
               if the codepage of the db and column are not the same */
             IF UPPER(DICTDB2._Field._Charset) EQ UPPER(DICTDB2._Db._db-xl-name) THEN
                 ddl[27] = "  CLOB-TYPE "      + STRING(DICTDB._Field._Attributes1).
          END.
          ELSE
             ddl[27] = "  CLOB-TYPE "      + STRING(DICTDB._Field._Attributes1).
        END.

        FIND DICTDB._storageobject WHERE DICTDB._Storageobject._Db-recid = RECID(DICTDB._Db)
                                AND DICTDB._Storageobject._Object-type = 3
                                AND DICTDB._Storageobject._Object-number = DICTDB._Field._Fld-stlen
                                NO-LOCK.
        FIND DICTDB2._storageobject WHERE DICTDB2._Storageobject._Db-recid = RECID(DICTDB2._Db)
                                AND DICTDB2._Storageobject._Object-type = 3
                                AND DICTDB2._Storageobject._Object-number = DICTDB2._Field._Fld-stlen
                                NO-LOCK.
        IF DICTDB._StorageObject._Area-number <> DICTDB2._StorageObject._Area-number THEN DO:
          OUTPUT STREAM err-log TO {&errFileName} APPEND NO-ECHO.

          PUT STREAM err-log UNFORMATTED "Warning: Blob Field " +
                 '"' + DICTDB._Field._Field-name + '"' + new_lang[11] +
                 '"' + LDBNAME("DICTDB") + '"'     SKIP
                 "and Blob Field " + '"' + DICTDB2._Field._Field-name + '"' +
                 new_lang[11] + '"' + LDBNAME("DICTDB2") + '"'   SKIP
                "are not in the same area." SKIP(1).
          OUTPUT STREAM err-log CLOSE.

          ASSIGN s_errorsLogged = TRUE.
        END.
      END.
      ELSE IF NOT l OR DICTDB._Field._Width <> DICTDB2._Field._Width THEN
        ddl[25] = "  MAX-WIDTH " + STRING(DICTDB._Field._Width).

      /* deal with field triggers */
      /* 1st, find ones to be deleted if field is being updated */
      j = 31.
      IF l THEN
        FOR EACH DICTDB2._Field-trig OF DICTDB2._Field:
          FIND DICTDB._Field-trig OF DICTDB._Field
            WHERE DICTDB._Field-trig._Event = DICTDB2._Field-trig._Event
                  NO-ERROR.
          IF NOT AVAILABLE DICTDB._Field-trig THEN DO:
            RUN dctquot IN h_dmputil (DICTDB2._Field-trig._Event,'"',OUTPUT c).
            j = j + 1.
            ddl[j] = "  FIELD-TRIGGER " + c + " DELETE".
          END.
        END.
      /* now record updated or new ones */
      FOR EACH DICTDB._Field-trig OF DICTDB._Field:
        FIND DICTDB2._Field-trig OF DICTDB2._Field
          WHERE DICTDB2._Field-trig._Event = DICTDB._Field-trig._Event NO-ERROR.
        IF AVAILABLE DICTDB2._Field-trig AND
          DICTDB2._Field-trig._Override = DICTDB._Field-trig._Override AND
          DICTDB2._Field-trig._Proc-name = DICTDB._Field-trig._Proc-name AND
          DICTDB2._Field-trig._Trig-CRC = DICTDB._Field-trig._Trig-CRC THEN
          NEXT.

        RUN dctquot IN h_dmputil (DICTDB._Field-trig._Event,'"',OUTPUT c).
        j = j + 1.
        ddl[j] = "  FIELD-TRIGGER " + c +
                 (IF DICTDB._Field-trig._Override THEN " OVERRIDE "
                                                  ELSE " NO-OVERRIDE ").
        RUN dctquot IN h_dmputil (DICTDB._Field-trig._Proc-name,'"',OUTPUT c).
        ddl[j] = ddl[j] + "PROCEDURE " + c + " CRC """
                 + (IF DICTDB._Field-trig._Trig-CRC = ?
                    THEN "?" ELSE STRING(DICTDB._Field-trig._Trig-CRC))
                 + """".
      END.

      /* don't write out header or anything unless there's values to output */
      l = FALSE.
      DO i = 2 TO j WHILE NOT l:
        l = ddl[i] <> "".
      END.
      IF l THEN DO i = 1 TO j:
        /* if ddl[i] = "" this doesn't do anything */
        PUT STREAM ddl UNFORMATTED ddl[i] SKIP.
      END.
      ELSE IF to-int64 AND ddl[1] <> "" THEN /* write the type change from int to int64 */
          PUT STREAM ddl UNFORMATTED ddl[1] SKIP(1).

      IF l THEN PUT STREAM ddl UNFORMATTED SKIP(1).
    END.         /* end FOR EACH field-list */

    /* note that there is no user interface for resolving renamed
    indexes.  this is because we can completely match indexes by their
    component lists, which are invariant once the index is created.  */
    ASSIGN
      pri1   = ""
      pri2   = "".

    /* build index component match list */
    FOR EACH DICTDB2._Index OF DICTDB2._File:
      IF DICTDB2._Index._Index-name = "default" OR
          DICTDB2._Index._Index-name = "sql-default"  THEN NEXT.
      IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
        DISPLAY DICTDB2._Index._Index-name @ idx WITH FRAME seeking.
      c = STRING(DICTDB2._Index._Unique,"u/a")
        + (IF DICTDB2._Index._Wordidx = 1 THEN "w" ELSE "f").
      FOR EACH DICTDB2._Index-field OF DICTDB2._Index,
        DICTDB2._Field OF DICTDB2._Index-field:
        FIND FIRST field-list
          WHERE field-list.f2-name = DICTDB2._Field._Field-name NO-ERROR.
        c = c + ","
          + STRING(DICTDB2._Field._dtype) + ","
          + STRING(DICTDB2._Index-field._Ascending,"+/-")
          + STRING(DICTDB2._Index-field._Abbreviate,"y/n")
          + (IF AVAILABLE field-list THEN field-list.f2-name ELSE "*").
      END.
      CREATE index-list.
      ASSIGN
        index-list.i1-name = DICTDB2._Index._Index-name
        index-list.i1-comp = c
        index-list.i1-i2   = FALSE.
      IF DICTDB2._File._Prime-Index = RECID(DICTDB2._Index) THEN pri2 = c.
    END.
    FOR EACH DICTDB._Index OF DICTDB._File:
      IF DICTDB._Index._Index-name = "default" OR
         DICTDB._Index._Index-name = "sql-default" THEN NEXT.
      IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
        DISPLAY DICTDB._Index._Index-name @ idx WITH FRAME seeking.
      c = STRING(DICTDB._Index._Unique,"u/a")
        + (IF DICTDB._Index._Wordidx = 1 THEN "w" ELSE "f").
      FOR EACH DICTDB._Index-field OF DICTDB._Index,
        DICTDB._Field OF DICTDB._Index-field:
        FIND FIRST field-list
          WHERE field-list.f1-name = DICTDB._Field._Field-name NO-ERROR.
        c = c + ","
          + STRING(DICTDB._Field._dtype) + ","
          + STRING(DICTDB._Index-field._Ascending,"+/-")
          + STRING(DICTDB._Index-field._Abbreviate,"y/n")
          + (IF AVAIL field-list THEN field-list.f2-name ELSE DICTDB._Field._Field-name).
      END.
      CREATE index-list.
      ASSIGN
        index-list.i1-name = DICTDB._Index._Index-name
        index-list.i1-comp = c
        index-list.i1-i2   = TRUE.
      IF DICTDB._File._Prime-Index = RECID(DICTDB._Index) THEN pri1 = c.
    END.

    FOR EACH index-list WHERE index-list.i1-i2:
      FIND FIRST index-alt WHERE NOT index-alt.i1-i2
                             AND index-alt.i1-name = index-list.i1-name NO-LOCK NO-ERROR.
      IF AVAILABLE index-alt AND index-list.i1-comp <> index-alt.i1-comp THEN DO:

        /* let's check if the only change is a int->int64 change, i-to-int64 will not be 0
           if we processed a int->int64 change for the current table
        */
        IF i-to-int64 NE 0 THEN DO:

            ASSIGN numEntries = NUM-ENTRIES(index-list.i1-comp)
                   i-to-int64 = 0
                   num-diff = 0.

            /* if the number of entries is different, then there were field deleted or added to the
               index, so we just process it as usual .
            */
            IF numEntries EQ NUM-ENTRIES(index-alt.i1-comp) THEN DO:
                IF ENTRY(1, index-list.i1-comp) NE ENTRY(1, index-alt.i1-comp) THEN
                    num-diff = num-diff + 1.
                ELSE REPEAT i = 2 TO numEntries BY 2:
                    IF ENTRY(i + 1, index-list.i1-comp) NE ENTRY(i + 1, index-alt.i1-comp) THEN DO:
                       num-diff = num-diff + 1.
                       /* if anything other than data type is different, we have to recreate it, so
                          leave now
                       */
                       LEAVE.
                    END.

                    IF ENTRY(i, index-list.i1-comp) NE ENTRY(i, index-alt.i1-comp) THEN DO:
                        ASSIGN num-diff = num-diff + 1.

                        /* check if we are going from int->int64 */
                        IF ENTRY(i, index-list.i1-comp) = "41" AND
                           ENTRY(i, index-alt.i1-comp) = "4"  THEN
                           ASSIGN i-to-int64 = i-to-int64 + 1.
                        ELSE /* if other type change, leave now */
                            LEAVE.
                    END.
                END.

                /* if the only changes are from int->int64, then we are all set */
                IF num-diff EQ i-to-int64 THEN DO:
                    /* primary is also ok, so make them the same so we don't try to update it later */
                    IF pri1 = index-list.i1-comp AND pri2 = index-alt.i1-comp THEN
                       ASSIGN pri1 = pri2.

                    DELETE index-alt.
                    DELETE index-list.

                    NEXT. /* go to the next index */
                END.

            END.
        END.

        RUN Check_Index_Conflict IN h_dmputil (INPUT index-alt.i1-name,
          INPUT DICTDB._File._File-name).

        CREATE drop-temp-idx.
        ASSIGN temp-name = index-alt.i1-name
               fil-name  = DICTDB._File._File-name.
      END.
    END.

    /* find all unchanged or renamed indexes by comparing idx comp lists */
    FOR EACH index-list WHERE index-list.i1-i2:
      IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
        DISPLAY index-list.i2-name @ idx WITH FRAME seeking.
      FIND FIRST index-alt WHERE NOT index-alt.i1-i2
        AND index-list.i1-comp = index-alt.i1-comp NO-ERROR.
      IF NOT AVAILABLE index-alt THEN NEXT.
     /* Determine if area has changed and issue warning if so */
      FIND DICTDB._Index WHERE
           DICTDB._Index._Index-name = index-list.i1-name AND
           DICTDB._Index._File-recid = RECID(DICTDB._File) NO-ERROR.
      FIND DICTDB2._Index WHERE
           DICTDB2._Index._Index-name = index-alt.i1-name AND
           DICTDB2._Index._File-recid = RECID(DICTDB2._File) NO-ERROR.
      IF AVAIL DICTDB._Index AND AVAIL DICTDB2._Index THEN
      IF NOT indexAreaMatch(INPUT DICTDB._Index._idx-num,
                            INPUT DICTDB2._Index._idx-num,
                            INPUT RECID(DICTDB._Db),
                            INPUT RECID(DICTDB2._DB)) THEN DO:
        ASSIGN s_errorsLogged = TRUE.

        OUTPUT STREAM err-log TO {&errFileName} APPEND NO-ECHO.

        PUT STREAM err-log UNFORMATTED new_lang[10] +
                 '"' + DICTDB._Index._Index-name + '"' + new_lang[11] +
                 '"' + LDBNAME("DICTDB") + '"'     SKIP
                 new_lang[12] + DICTDB2._Index._Index-name + '"' +
                 new_lang[11] + '"' + LDBNAME("DICTDB2") + '"'   SKIP.
        DO i = 13 TO 16:
          PUT STREAM err-log UNFORMATTED new_lang[i] SKIP.
        END.

        PUT STREAM err-log UNFORMATTED new_lang[17] SKIP(1).
        OUTPUT STREAM err-log CLOSE.
      END.
      ASSIGN index-list.i2-name = index-alt.i1-name.
      DELETE index-alt.
    END.

   /* Now all index-list records where i1-i2 is false represent
      indexes in db2 that will not be renamed, therefore they will
      be deleted.
    */

    /* check deactivation on unchanged indexes */
    FOR EACH index-list WHERE index-list.i1-name = index-list.i2-name:
      FIND DICTDB._Index OF DICTDB._File
        WHERE DICTDB._Index._Index-name = index-list.i1-name NO-ERROR.
      IF NOT AVAILABLE DICTDB._Index THEN NEXT.
      FIND DICTDB2._Index OF DICTDB2._File
        WHERE DICTDB2._Index._Index-name = index-list.i2-name NO-ERROR.
      IF NOT AVAILABLE DICTDB2._Index THEN NEXT.
      IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
        DISPLAY DICTDB._Index._Index-name @ idx2 WITH FRAME seeking.
      IF NOT DICTDB._Index._Active AND DICTDB2._Index._Active THEN DO:
        PUT STREAM ddl UNFORMATTED
          'UPDATE INACTIVE INDEX "' DICTDB._Index._Index-name
          '" OF "' DICTDB._File._File-name '"' SKIP.
        IF DICTDB._Index._Desc <> DICTDB2._Index._Desc THEN DO:
          PUT STREAM ddl CONTROL "  DESCRIPTION ".
          EXPORT STREAM ddl DICTDB._Index._Desc SKIP(1).
        END.
      END.
      ELSE IF DICTDB._Index._Desc <> DICTDB2._Index._Desc THEN DO:
        PUT STREAM ddl UNFORMATTED
          'UPDATE INDEX "' DICTDB._Index._Index-name
               '" OF "' DICTDB._File._File-name '"' SKIP.
        PUT STREAM ddl CONTROL "  DESCRIPTION ".
        EXPORT STREAM ddl DICTDB._Index._Desc SKIP(1).
      END.
      DELETE index-list.
    END.

    /* handle renamed indexes */
    ans = FALSE.
    FOR EACH index-list WHERE index-list.i2-name <> ?:
      FIND DICTDB._Index OF DICTDB._File
        WHERE DICTDB._Index._Index-name = index-list.i1-name NO-ERROR.
      FIND DICTDB2._Index OF DICTDB2._File
        WHERE DICTDB2._Index._Index-name = index-list.i2-name NO-ERROR.
      IF NOT AVAILABLE DICTDB._Index OR NOT AVAILABLE DICTDB2._Index THEN NEXT.
      ans = TRUE.
      IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
        DISPLAY index-list.i1-name @ idx2 WITH FRAME seeking.
      RUN Check_Index_Conflict IN h_dmputil (INPUT index-list.i1-name,
          INPUT DICTDB._File._File-name).
      PUT STREAM ddl UNFORMATTED
        'RENAME INDEX "' index-list.i2-name
        '" TO "' index-list.i1-name
        '" ON "' DICTDB._File._File-name '"' SKIP(1).
      IF NOT DICTDB._Index._Active AND DICTDB2._Index._Active THEN DO:
        PUT STREAM ddl UNFORMATTED
          'UPDATE INACTIVE INDEX "' DICTDB._Index._Index-name
          '" OF "' DICTDB._File._File-name '"' SKIP.
        IF DICTDB._Index._Desc <> DICTDB2._Index._Desc THEN DO:
          PUT STREAM ddl CONTROL "  DESCRIPTION ".
          EXPORT STREAM ddl DICTDB._Index._Desc SKIP(1).
        END.
      END.
      ELSE IF DICTDB._Index._Desc <> DICTDB2._Index._Desc THEN DO:
        PUT STREAM ddl UNFORMATTED
          'UPDATE INDEX "' DICTDB._Index._Index-name
               '" OF "' DICTDB._File._File-name '"' SKIP.
        PUT STREAM ddl CONTROL "  DESCRIPTION ".
        EXPORT STREAM ddl DICTDB._Index._Desc SKIP(1).
      END.
      DELETE index-list.
    END.
    IF ans THEN PUT STREAM ddl UNFORMATTED SKIP(1).

    /* check if unique indexes to be created as inactive */
    FOR EACH index-list WHERE index-list.i1-i2,
      EACH DICTDB._Index OF DICTDB._File
      WHERE DICTDB._Index._Index-name = index-list.i1-name
        AND DICTDB._Index._Unique AND DICTDB._Index._Active:
      /* 02/01/29 vap (IZ# 1525) */
      IF NOT p-batchmode THEN DO:
        iact = TRUE.
        RUN "prodict/user/_usrdbox.p" (INPUT-OUTPUT iact,?,?,new_lang[2]).
      END.
      ELSE
        iact = p-index-mode NE "0":U.

      IF iact THEN DO:
        ASSIGN s_errorsLogged = TRUE.
        OUTPUT STREAM err-log TO {&errFileName} APPEND NO-ECHO.

        PUT STREAM err-log UNFORMATTED
             new_lang[18]                                  SKIP
             new_lang[19]                                  SKIP
             new_lang[20]                                  SKIP(1).

        OUTPUT STREAM err-log CLOSE.
      END.
      iact = NOT iact.
      LEAVE. /* we only need to ask once */
    END.

    /* handle new indexes */
    FOR EACH index-list WHERE index-list.i1-i2,
        DICTDB._Index OF DICTDB._File
        WHERE DICTDB._Index._Index-name = index-list.i1-name.
      IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
        DISPLAY DICTDB._Index._Index-name @ idx2 WITH FRAME seeking.
      /* Determine if a component of this index has been dropped.  If so,    *
       * no need to rename the index first.  Since the field is dropped,     *
       * the index no longer exists. Trying to rename it will cause a load   *
       * error.  Oh yes, this IS a hack way of doing it, but you find a      *
       * better way.                                                         */
      FIND FIRST drop-list WHERE
         (INDEX(index-list.i1-comp,drop-list.f1-name) > 0  OR
          INDEX(index-list.i1-comp,drop-list.f2-name) > 0) AND
         DICTDB._File._File-Name = drop-list.file-name NO-ERROR.
      IF NOT AVAIL drop-list THEN
        RUN Check_Index_Conflict IN h_dmputil (INPUT index-list.i1-name,
          INPUT DICTDB._File._File-name).
      PUT STREAM ddl UNFORMATTED "ADD "
        'INDEX "' DICTDB._Index._Index-Name
        '" ON "' DICTDB._File._File-name '"' SKIP.
      FIND DICTDB._StorageObject WHERE
           DICTDB._StorageObject._Object-type = 2 AND
           DICTDB._Storageobject._Object-number = DICTDB._Index._idx-num
      NO-LOCK NO-ERROR.
      IF AVAILABLE DICTDB._StorageObject THEN
         FIND DICTDB._Area WHERE
              DICTDB._Area._Area-number = DICTDB._StorageObject._Area-number
         NO-ERROR.
      ELSE
      FIND DICTDB._Area WHERE
           DICTDB._Area._Area-number = DICTDB._Index._idx-num NO-LOCK NO-ERROR.
      FIND DICTDB2._Area WHERE
           DICTDB2._Area._Area-name = DICTDB._Area._Area-name NO-ERROR.
      IF NOT AVAIL DICTDB2._Area THEN DO:
        ASSIGN s_errorsLogged = TRUE.
        OUTPUT STREAM err-log TO {&errFileName} APPEND NO-ECHO.

        PUT STREAM err-log UNFORMATTED new_lang[3] +
             '"' + DICTDB._Area._Area-name + '"' + new_lang[21]     SKIP
             new_lang[22]                                           SKIP
             new_lang[23]                                           SKIP
             '"' + DICTDB._Index._Index-name + '"' + new_lang[24]   SKIP
             new_lang[25]                                           SKIP
             new_lang[26]                                           SKIP(1).

        OUTPUT STREAM err-log CLOSE.
      END.
      PUT STREAM ddl UNFORMATTED
         "  AREA " '"' DICTDB._Area._Area-name '"' SKIP.

      IF DICTDB._Index._Unique THEN DO:
        PUT STREAM ddl UNFORMATTED "  UNIQUE" SKIP.
        IF NOT (DICTDB._Index._Active AND (IF iact = ? THEN TRUE ELSE iact)) THEN
        PUT STREAM ddl UNFORMATTED "  INACTIVE" SKIP.
      END.
      ELSE IF NOT DICTDB._Index._Active OR p-index-mode EQ "2":U THEN
          PUT STREAM ddl UNFORMATTED "  INACTIVE" SKIP.

      IF DICTDB._Index._Wordidx = 1 THEN
        PUT STREAM ddl UNFORMATTED "  WORD" SKIP.
      IF DICTDB._Index._Desc <> ? AND DICTDB._Index._Desc <> '' THEN DO:
        PUT STREAM ddl CONTROL "  DESCRIPTION ".
        EXPORT STREAM ddl DICTDB._Index._Desc SKIP.
      END.
      FOR EACH DICTDB._Index-field OF _Index,DICTDB._Field OF _Index-field
        BREAK BY DICTDB._Index-field._Index-seq:
        PUT STREAM ddl UNFORMATTED
          '  INDEX-FIELD "' DICTDB._Field._Field-Name '" '
          TRIM(STRING(DICTDB._Index-field._Ascending,"A/DE")) "SCENDING"
          (IF DICTDB._Index-field._Abbreviate THEN " ABBREVIATED" ELSE "")
          (IF DICTDB._Index-field._Unsorted   THEN " UNSORTED"    ELSE "") SKIP.
      END.
      PUT STREAM ddl UNFORMATTED SKIP(1).
    END.

    /* set primary index */
    RELEASE DICTDB._Index.
    IF DICTDB._File._Prime-Index <> ? THEN
      FIND DICTDB._Index WHERE RECID(DICTDB._Index) = DICTDB._File._Prime-Index
        NO-ERROR.
    IF AVAILABLE DICTDB._Index AND pri1 <> pri2 THEN
      PUT STREAM ddl UNFORMATTED
        'UPDATE PRIMARY INDEX "' DICTDB._Index._Index-name
        '" ON "' DICTDB._File._File-name '"' SKIP(1).

    /* handle deleted indexes */
    ans = FALSE.
    FOR EACH index-list WHERE NOT index-list.i1-i2:
      /* Determine if a component of this index has been dropped.  If so,    *
       * no need to drop the index; dropping it would cause a load error.    *
       * Oh yes, this IS a hack way of doing it, but you find a better way.  */
      FIND FIRST drop-temp-idx WHERE drop-temp-idx.temp-name = index-list.i1-name NO-ERROR.
        IF AVAILABLE drop-temp-idx THEN
           DELETE drop-temp-idx.
      FIND FIRST drop-list WHERE
         (INDEX(index-list.i1-comp,drop-list.f1-name) > 0  OR
          INDEX(index-list.i1-comp,drop-list.f2-name) > 0) AND
         DICTDB._File._File-Name = drop-list.file-name NO-ERROR.
      IF AVAIL drop-list THEN DO:
         DELETE index-list.
             NEXT.
      END.
      ans = TRUE.
      IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
        DISPLAY index-list.i1-name @ idx2 WITH FRAME seeking.
      IF index-list.i1-name <> "default" AND
          index-list.i1-name <> "sql-default" THEN
        PUT STREAM ddl UNFORMATTED
          'DROP INDEX "' index-list.i1-name
          '" ON "' DICTDB._File._File-name '"' SKIP.
      DELETE index-list.
    END.
    IF ans THEN PUT STREAM ddl UNFORMATTED SKIP(1).

    ans = FALSE.

    FOR EACH drop-temp-idx:
       PUT STREAM ddl UNFORMATTED
          'DROP INDEX "' temp-name
          '" ON "' Fil-name '"' SKIP.
       DELETE drop-temp-idx.
       IF NOT ans THEN ASSIGN ans =TRUE.
    END.
    IF ans THEN PUT STREAM ddl UNFORMATTED SKIP(1).

    /* handle deleted fields.
       Do this after index deletes since fields cannot be dropped when they
       belong to a primary index.  This is not done for fields that were
       dropped but replaced with another field (different data type or extent)
       but with the same name.  This still has to be done above so we can add
       the new field without conflict.
    */
    FIND FIRST missing NO-ERROR.
    ans = FALSE.
    FOR EACH missing:
      ans = TRUE.
      IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
        DISPLAY missing.name @ fld2 WITH FRAME seeking.
      PUT STREAM ddl UNFORMATTED
        'DROP FIELD "' missing.name
        '" OF "' DICTDB._File._File-name '"' SKIP.
      DELETE missing.
    END.
    IF ans THEN PUT STREAM ddl UNFORMATTED SKIP(1).


    DO ON ERROR UNDO,LEAVE ON ENDKEY UNDO,LEAVE:
      HIDE MESSAGE.
    END.
  END.  /* end FOR EACH potentially altered file */

  IF NOT p-batchmode THEN DO: /* 02/01/29 vap (IZ# 1525) */
    DISPLAY "" @ fil "" @ fld "" @ idx WITH FRAME seeking.
    DISPLAY "" @ fil2 "" @ fld2 "" @ idx2 WITH FRAME seeking.
  END.

  /* build missing sequence list for rename/delete determination */
  FOR EACH DICTDB2._Sequence
    WHERE DICTDB2._Sequence._Db-recid = RECID(database2)
      AND NOT DICTDB2._Sequence._Seq-name BEGINS "$":
    FIND FIRST DICTDB._Sequence
      WHERE DICTDB._Sequence._Db-recid = drec_db
        AND DICTDB._Sequence._Seq-name = DICTDB2._Sequence._Seq-name NO-ERROR.
    IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
      DISPLAY DICTDB2._Sequence._Seq-name @ seq WITH FRAME seeking.
    IF AVAILABLE DICTDB._Sequence THEN NEXT.
    CREATE missing.
    missing.name = DICTDB2._Sequence._Seq-name.
  END.

  /* build list of new or renamed sequences */
  FOR EACH DICTDB._Sequence
    WHERE DICTDB._Sequence._Db-recid = drec_db
      AND NOT DICTDB._Sequence._Seq-name BEGINS "$":
    FIND FIRST DICTDB2._Sequence
      WHERE DICTDB2._Sequence._Db-recid = RECID(database2)
        AND DICTDB2._Sequence._Seq-name = DICTDB._Sequence._Seq-name NO-ERROR.
    IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
      DISPLAY DICTDB._Sequence._Seq-name @ seq WITH FRAME seeking.
    CREATE seq-list.
    seq-list.s1-name = DICTDB._Sequence._Seq-name.
    IF AVAILABLE DICTDB2._Sequence THEN
      seq-list.s2-name = DICTDB._Sequence._Seq-name.
  END.

  /* look for matches for renamed sequences with user input.  A prompt
     is given for each seq in DICTDB2 that's not in DICTDB but only when
     there is also a seq in DICTDB that's not in DICTDB2.  The 2nd list
     is the potential values to rename to.
  */
  IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
    run adecomm/_setcurs.p ("").
  ELSE DO:  /* 02/01/29 vap (IZ# 1525) */
    ASSIGN p-comma = "":U
           p-list  = "":U.
    FOR EACH seq-list WHERE
             seq-list.s2-name = ?:
      ASSIGN p-list  = p-list + p-comma + seq-list.s1-name
             p-comma = ",":U.
    END.
  END.
  FOR EACH missing:
    IF NOT p-batchmode THEN DO:  /* 02/01/29 vap (IZ# 1525) */
      DISPLAY missing.name @ seq WITH FRAME seeking.
      RUN "prodict/dump/_dmpisub.p"
        (INPUT "s",INPUT-OUTPUT missing.name,OUTPUT ans).
      IF missing.name = ? THEN DELETE missing.
      IF ans = ? THEN DO:
        IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
          HIDE FRAME seeking NO-PAUSE.
        user_path = "".
        RETURN.
      END.
    END.  /* NOT p-batchmode */
    ELSE DO:  /* 02/01/29 vap (IZ# 1525) */
      ASSIGN p-foo = checkRenameSequence(missing.name, p-list).
      IF p-foo NE ? THEN DO:
         FIND FIRST seq-list WHERE
                    seq-list.s1-name = p-foo AND
                    seq-list.s2-name = ?
                    NO-ERROR.
         IF AVAILABLE(seq-list) THEN
           ASSIGN seq-list.s2-name = missing.name.
         DELETE missing.
      END.  /* p-foo NE ? */
    END.  /* p-batchmode */
  END.  /* FOR EACH missing */
  IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
    run adecomm/_setcurs.p ("WAIT").

  /* handle deleted sequences */
  ans = FALSE.
  FOR EACH missing:
    ans = TRUE.
    PUT STREAM ddl UNFORMATTED
      'DROP SEQUENCE "' missing.name '"' SKIP.
    IF NOT p-batchmode THEN DO: /* 02/01/29 vap (IZ# 1525) */
      DISPLAY missing.name @ seq WITH FRAME seeking.
      DISPLAY missing.name @ seq2 WITH FRAME seeking.
    END.
    DELETE missing.
  END.
  IF ans THEN PUT STREAM ddl UNFORMATTED SKIP(1).

  /* handle renamed sequences */
  ans = FALSE.
  FOR EACH seq-list
    WHERE seq-list.s1-name <> seq-list.s2-name
      AND seq-list.s2-name <> ?:
    ans = TRUE.
    PUT STREAM ddl UNFORMATTED
      'RENAME SEQUENCE "' seq-list.s2-name
      '" TO "' seq-list.s1-name '"' SKIP.
    IF NOT p-batchmode THEN DO: /* 02/01/29 vap (IZ# 1525) */
      DISPLAY seq-list.s1-name @ seq WITH FRAME seeking.
      DISPLAY seq-list.s1-name @ seq2 WITH FRAME seeking.
    END.
  END.
  IF ans THEN PUT STREAM ddl UNFORMATTED SKIP(1).

  /* handle new or potentially altered sequences.
     We can't use dumpdefs here like we do with files because it wasn't
     made to handle individual sequences - it would dump them all.
     Some day!
  */
  FOR EACH seq-list:
    IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
      DISPLAY seq-list.s1-name @ seq WITH FRAME seeking.

    FIND DICTDB._Sequence WHERE DICTDB._Sequence._Db-recid = drec_db
      AND DICTDB._Sequence._Seq-name = seq-list.s1-name.
    FIND DICTDB2._Sequence WHERE DICTDB2._Sequence._Db-recid = RECID(database2)
      AND DICTDB2._Sequence._Seq-name = seq-list.s2-name NO-ERROR.

    IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
      DISPLAY seq-list.s1-name @ seq2 WITH FRAME seeking.

    /* If l is true we're updateing otherwise we're adding */
    l = AVAILABLE DICTDB2._Sequence.

    /* write out appropriate seq definition changes */
    ASSIGN
      j      = 1
      ddl    = ""
      ddl[1] = (IF l THEN "UPDATE" ELSE "ADD")
               + ' SEQUENCE "' + DICTDB._Sequence._Seq-name + '"'.
      IF NOT l OR
               DICTDB._Sequence._Seq-init <> DICTDB2._Sequence._Seq-init THEN
        ASSIGN
          j = j + 1
          ddl[j] = "  INITIAL " + (IF DICTDB._Sequence._Seq-init = ? THEN "?"
                   ELSE STRING(DICTDB._Sequence._Seq-init)).
      IF NOT l OR
               DICTDB._Sequence._Seq-incr <> DICTDB2._Sequence._Seq-incr THEN
        ASSIGN
          j = j + 1
          ddl[j] = "  INCREMENT " + (IF DICTDB._Sequence._Seq-incr = ? THEN "?"
                   ELSE STRING(DICTDB._Sequence._Seq-incr)).
      IF NOT l OR
               DICTDB._Sequence._Cycle-OK <> DICTDB2._Sequence._Cycle-OK THEN
        ASSIGN
          j = j + 1
          ddl[j] = "  CYCLE-ON-LIMIT " +
                   (IF DICTDB._Sequence._Cycle-OK THEN "yes" ELSE "no").
      IF NOT l OR DICTDB._Sequence._Seq-min <> DICTDB2._Sequence._Seq-min THEN
        ASSIGN
          j = j + 1
          ddl[j] = "  MIN-VAL " + (IF DICTDB._Sequence._Seq-min = ? THEN "?"
                   ELSE STRING(DICTDB._Sequence._Seq-min)).
      IF NOT l OR DICTDB._Sequence._Seq-max <> DICTDB2._Sequence._Seq-max THEN
        ASSIGN
          j = j + 1
          ddl[j] = "  MAX-VAL " + (IF DICTDB._Sequence._Seq-max = ? THEN "?"
                   ELSE STRING(DICTDB._Sequence._Seq-max)).

      /* don't write out ddl[1] if j = 1 (i.e., we only have seq header) */
      IF j > 1 THEN
        DO i = 1 TO j + 1:
          IF ddl[i] = "" THEN  /* this puts an extra skip after the last one */
            PUT STREAM ddl UNFORMATTED SKIP(1).
          ELSE
            PUT STREAM ddl UNFORMATTED ddl[i] SKIP.
        END.

  END.  /* end FOR EACH new or potentially altered sequence */

  /* Sync up the auto-connect records.  If there's any auto-connect records
     in either database, drop all the ones in DICTDB2 and add what's in
     DICTDB.  Since there's no data associated with these, we can drop with
     a clear conscience.   This is easier than trying to compare the
     differences.
  */
  FOR EACH DICTDB2._Db WHERE DICTDB2._Db._Db-name <> ? AND
                             NOT DICTDB2._Db._Db-slave AND  /* not foreign db */
                             NOT DICTDB2._Db._Db-local NO-LOCK:
     PUT STREAM ddl UNFORMATTED
        'DROP DATABASE "' DICTDB2._Db._Db-name '"' SKIP(1).
  END.
  FOR EACH DICTDB._Db WHERE DICTDB._Db._Db-name <> ? AND
                            NOT DICTDB._Db._Db-slave AND  /* not foreign db */
                            NOT DICTDB._Db._Db-local NO-LOCK:
     PUT STREAM ddl UNFORMATTED
        'ADD DATABASE "' DICTDB._Db._Db-name '" TYPE PROGRESS' SKIP.
     PUT STREAM ddl UNFORMATTED 'DBNAME "' DICTDB._Db._Db-addr '"' SKIP.
     IF DICTDB._Db._Db-comm <> "" THEN
        PUT STREAM ddl UNFORMATTED 'PARAMS "'  DICTDB._Db._Db-comm '"' SKIP.
     PUT STREAM ddl UNFORMATTED SKIP(1).
  END.

  /* store seek value to see if a change was detected */
  ASSIGN  iSeek = SEEK(ddl).

  {prodict/dump/dmptrail10.i
    &entries      = " "
    &seek-stream  = "ddl"
    &stream       = "STREAM ddl "
    }  /* adds trailer with code-page-entrie to end of file */

  stopped = false.
END. /* on stop */

/* 02/01/29 vap (IZ# 1525) */
IF NOT p-batchmode AND NOT stopped AND s_errorsLogged THEN
   MESSAGE new_lang[27] SKIP
           new_lang[28] SKIP
           new_lang[29] SKIP
           new_lang[30]
   VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
  IF stopped THEN
     MESSAGE "Dump terminated."
                   VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
  ELSE
     MESSAGE "Dump completed."
                   VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

DELETE PROCEDURE h_dmputil NO-ERROR.
IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
  HIDE FRAME seeking NO-PAUSE.
SESSION:IMMEDIATE-DISPLAY = no.
IF NOT p-batchmode THEN  /* 02/01/29 vap (IZ# 1525) */
  run adecomm/_setcurs.p ("").

RETURN "SEEK=" + STRING(iSeek).

FUNCTION CHECK_SA_FIELDS RETURNS LOGICAL (INPUT c1 AS CHAR, INPUT c2 AS CHAR) :

    /* ignore this field if they are a combination of ? and empty strings */
    RETURN
            ( NOT (c1 EQ '' AND c2 EQ ?) AND
              NOT (c1 EQ ? AND c2 EQ '')).

END FUNCTION.
