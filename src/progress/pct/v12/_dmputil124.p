/*********************************************************************
* Copyright (C) 2000,2011,2020 by Progress Software Corporation. All *
* rights reserved. Prior versions of this work may contain portions  *
* contributed by participants of Possenet.                           *
*                                                                    *
*********************************************************************/

/*----------------------------------------------------------------------------

File: _dmputil.p

Description:
   This is a persistent procedure library used by the incremental dump utility,
   _dmpincr.p.  

Author: Mario Brunetti

Date Created: 10/04/99
     History: 09/06/02 D. McMann inprimary should have been checking for
                                 field being in any index. 20020828-012
              03/28/00 D. McMann Checking inprimary was looking at the
                                 wrong database to determine if field was there
                                 20000327012.
              08/16/00 D. McMann Added _Db-recid to _storageObject find 
                                 20000815029
              01/29/02 vap       Added batch-mode support (IZ# 1525)
              09/16/05 kmcintos  Fixed problems with determining if fields 
                                 are members of an index 20040402-004.
              07/12/11 rkamboj   Fixed no record found issue for _Area.
              12/18/20 tmasood   Dump the data to correct stream.
-----------------------------------------------------------------------------*/


using Progress.Lang.*.
routine-level on error undo, throw.


/*------------------------ D E C L A R A T I O N S --------------------------*/

{ prodict/dump/dumpvars12.i SHARED }
{ prodict/user/uservar124.i }

DEFINE TEMP-TABLE ttRenameTable                   /* 02/01/29 vap (IZ# 1525) */
  FIELD RenameFrom LIKE DICTDB._Field._Field-Name COLUMN-LABEL "From":U
  FIELD RenameTo   LIKE DICTDB._Field._Field-Name COLUMN-LABEL "To":U
  INDEX ttRenameTable IS PRIMARY UNIQUE
  RenameFrom.

DEFINE TEMP-TABLE ttRenameField                   /* 02/01/29 vap (IZ# 1525) */
  FIELD TableName  LIKE DICTDB._File._File-Name   COLUMN-LABEL "Table":U
  FIELD RenameFrom LIKE DICTDB._Field._Field-Name COLUMN-LABEL "From":U
  FIELD RenameTo   LIKE DICTDB._Field._Field-Name COLUMN-LABEL "To":U
  INDEX ttRenameField IS PRIMARY UNIQUE
  TableName RenameFrom.

DEFINE TEMP-TABLE ttRenameSequence                /* 02/01/29 vap (IZ# 1525) */
  FIELD RenameFrom LIKE DICTDB._Field._Field-Name COLUMN-LABEL "From":U
  FIELD RenameTo   LIKE DICTDB._Field._Field-Name COLUMN-LABEL "To":U
  INDEX ttRenameSequence IS PRIMARY UNIQUE
  RenameFrom.

DEFINE VARIABLE debug-mode  AS INTEGER   NO-UNDO. /* 02/01/29 vap (IZ# 1525) */
DEFINE VARIABLE rename-file AS CHARACTER NO-UNDO  /* 02/01/29 vap (IZ# 1525) */
                            INITIAL ?.
DEFINE VARIABLE setincrdmpSilent AS LOGICAL  NO-UNDO INITIAL FALSE.

/* 02/01/29 vap (IZ# 1525) */
/* LANGUAGE DEPENDENCIES START */ /*----------------------------------------*/
DEFINE VARIABLE new_lang AS CHARACTER EXTENT 03 NO-UNDO INITIAL [
  /*01*/ "WARNING: Ambiguous &1-rename definition (~"&2-&3~").",
  /*02*/ "WARNING: Unrecognized rename-file line: ~"&1~".",
  /*03*/ "WARNING: Wrong &1-rename definition: (~"&2-&3~"), ignored."
]. 
/* LANGUAGE DEPENDENCIES END */ /*-------------------------------------------*/

/*--------------- F U N C T I O N S   &  P R O C E D U R E S ----------------*/
FUNCTION fileAreaMatch RETURNS LOGICAL (INPUT db1FileNo AS INT,
                                        INPUT db2FileNo AS INT,
                                        INPUT db1recid  AS RECID,
                                        INPUT db2recid  AS RECID).
   /* Checks to see that the DICTDB2 file area exists in DICTDB */
   FIND DICTDB._StorageObject 
        where DICTDB._StorageObject._Db-recid    = db1recid
          and DICTDB._StorageObject._Object-type = 1 
          and DICTDB._StorageObject._Object-number = db1FileNo 
          and DICTDB._Storageobject._Partitionid = 0                       
        NO-ERROR.
   
   IF AVAILABLE DICTDB._StorageObject THEN
      FIND DICTDB._Area WHERE
         DICTDB._Area._Area-number = DICTDB._StorageObject._Area-number
      NO-ERROR.
                                      
   FIND DICTDB2._StorageObject where DICTDB2._StorageObject._Db-recid    = db2recid
          and DICTDB2._StorageObject._Object-type = 1 
          and DICTDB2._StorageObject._Object-number = db2FileNo 
          and DICTDB2._Storageobject._Partitionid = 0                       
        NO-ERROR.
    
   IF AVAILABLE DICTDB2._StorageObject THEN
      FIND DICTDB2._Area WHERE
           DICTDB2._Area._Area-number = DICTDB2._StorageObject._Area-number
      NO-ERROR.
   IF AVAIL DICTDB._Area AND AVAIL DICTDB2._Area THEN
   DO:
      IF DICTDB._Area._Area-Name = DICTDB2._Area._Area-Name THEN
      RETURN TRUE.
   END.
   /* DICTDB._StorageObject._Area-number = 0 and DICTDB2._StorageObject._Area-number = 0 
      but there is no record with _Area-number = 0 in _Area table */
   IF AVAIL DICTDB._StorageObject AND AVAIL DICTDB2._StorageObject 
      AND DICTDB._StorageObject._Area-number = 0 AND DICTDB2._StorageObject._Area-number = 0 THEN
      RETURN TRUE.
   RETURN FALSE.

END FUNCTION.

FUNCTION indexAreaMatch RETURNS LOGICAL(INPUT db1IndexNo AS INT,
                                        INPUT db2IndexNo AS INT,
                                        INPUT db1recid   AS RECID,
                                        INPUT db2recid   AS RECID).

   FIND DICTDB._StorageObject WHERE
        DICTDB._StorageObject._Db-recid = db1recid AND
        DICTDB._StorageObject._Object-type = 2 AND
        DICTDB._Storageobject._Object-number = db1IndexNo and
        DICTDB._Storageobject._Partitionid = 0 NO-ERROR.
   IF AVAILABLE DICTDB._StorageObject AND DICTDB._StorageObject._Area-number NE 0 THEN
      FIND DICTDB._Area WHERE
           DICTDB._Area._Area-number = DICTDB._StorageObject._Area-number
      NO-ERROR.
   ELSE
   FIND DICTDB._Area WHERE
        DICTDB._Area._Area-number = db1IndexNo NO-ERROR.

   FIND DICTDB2._StorageObject WHERE
        DICTDB2._StorageObject._db-recid = db2recid AND
        DICTDB2._StorageObject._Object-type = 2 AND
        DICTDB2._Storageobject._Object-number = db2IndexNo and
        DICTDB2._Storageobject._Partitionid = 0 NO-ERROR.
   IF AVAILABLE DICTDB2._StorageObject AND DICTDB2._StorageObject._Area-number NE 0 THEN
      FIND DICTDB2._Area WHERE
           DICTDB2._Area._Area-number = DICTDB2._StorageObject._Area-number
      NO-ERROR.
   ELSE
   FIND DICTDB2._Area WHERE
        DICTDB2._Area._Area-number = db2IndexNo NO-ERROR.
   IF AVAIL DICTDB._Area AND AVAIL DICTDB2._Area THEN
   DO:
      IF DICTDB._Area._Area-Name = DICTDB2._Area._Area-Name THEN
         RETURN TRUE.
   END.
   /* Assuming if nothing is available then dictdb and dictdb2 index areas are same */
   IF NOT AVAIL DICTDB._StorageObject AND NOT AVAIL DICTDB2._StorageObject
      AND NOT AVAIL DICTDB._Area AND NOT AVAIL DICTDB2._Area THEN 
      RETURN TRUE.
      
   IF AVAILABLE DICTDB._StorageObject AND AVAIL DICTDB2._StorageObject 
      AND DICTDB._StorageObject._Area-number = 0 AND DICTDB2._StorageObject._Area-number = 0 THEN
      RETURN TRUE.
    
   RETURN FALSE.

END FUNCTION.

FUNCTION inprimary RETURNS LOGICAL (INPUT p_db1PrimeIndex AS RECID,
                                    INPUT p_db1RecId      AS RECID).
   
  /* Determines whether a field is part of a primary index */
  /* Function changed to verify if in any index so drop and add
     are done in the proper order 20020828-012 */

  FIND DICTDB2._index-field 
      WHERE DICTDB2._index-field._index-recid = p_db1PrimeIndex AND
            DICTDB2._index-field._field-recid = p_db1RecId NO-ERROR.
  RETURN AVAILABLE DICTDB2._index-field.
   
END FUNCTION.

FUNCTION inindex RETURNS LOGICAL (INPUT p_db1File  AS RECID,
                                  INPUT p_db1Field AS RECID).
   
  /* Function added to verify if in any index so drop and add
     are done in the proper order 20020828-012 */

  FOR EACH DICTDB2._Index WHERE DICTDB2._Index._File-recid = p_db1File:
    FIND DICTDB2._index-field OF DICTDB2._index 
        WHERE DICTDB2._index-field._field-recid = p_db1Field NO-ERROR.
    IF AVAILABLE DICTDB2._index-field THEN
      RETURN TRUE.
  END.

  RETURN FALSE.
   
END FUNCTION.

/* 02/01/29 vap (IZ# 1525) */
FUNCTION checkRenameTable RETURNS CHARACTER (
  INPUT pcRenameFrom   AS CHARACTER ,
  INPUT pcRenameToList AS CHARACTER ).
  /* It is allways a good practice to strong-scope all buffers in persistent
   * libraries, even although here it's not necessary. ADE code just should
   * serve as a code reference, too...
   */
  DEFINE BUFFER B_RenameTable FOR ttRenameTable.
  DEFINE VARIABLE cReturnValue AS CHARACTER NO-UNDO.
  FIND B_RenameTable WHERE
       B_RenameTable.RenameFrom EQ pcRenameFrom
       NO-ERROR.
  IF NOT AVAILABLE(B_RenameTable) THEN
    ASSIGN cReturnValue = ?.
  ELSE DO:
    IF CAN-DO(pcRenameToList, B_RenameTable.RenameTo) THEN
      ASSIGN cReturnValue = B_RenameTable.RenameTo.
    ELSE DO:
      ASSIGN cReturnValue = ?.
      IF debug-mode GT 0 THEN DO:
          if setincrdmpSilent THEN 
                undo, throw new AppError(SUBSTITUTE(new_lang[03], "Table":U, B_RenameTable.RenameFrom,
                           B_RenameTable.RenameTo)). 
          ELSE
                MESSAGE SUBSTITUTE(new_lang[03], "Table":U, B_RenameTable.RenameFrom,
                           B_RenameTable.RenameTo).
      END.
    END.
  END.  /* AVAILABLE(B_RenameTable) */
  RETURN cReturnValue.
END FUNCTION.  /* checkRenameTable() */

/* 02/01/29 vap (IZ# 1525) */
FUNCTION checkRenameField RETURNS CHARACTER (
  INPUT pcTableName    AS CHARACTER ,
  INPUT pcRenameFrom   AS CHARACTER ,
  INPUT pcRenameToList AS CHARACTER ).
  /* It is allways a good practice to strong-scope all buffers in persistent
   * libraries, even although here it's not necessary. ADE code just should
   * serve as a code reference, too...
   */
  DEFINE BUFFER B_RenameField FOR ttRenameField.
  DEFINE VARIABLE cReturnValue AS CHARACTER NO-UNDO.
  FIND B_RenameField WHERE
       B_RenameField.TableName  EQ pcTableName AND
       B_RenameField.RenameFrom EQ pcRenameFrom
       NO-ERROR.
  IF NOT AVAILABLE(B_RenameField) THEN
    ASSIGN cReturnValue = ?.
  ELSE DO:
    IF CAN-DO(pcRenameToList, B_RenameField.RenameTo) THEN
      ASSIGN cReturnValue = B_RenameField.RenameTo.
    ELSE DO:
      ASSIGN cReturnValue = ?.
      IF debug-mode GT 0 THEN DO:
         if setincrdmpSilent THEN 
                undo, throw new AppError(SUBSTITUTE(new_lang[03], "Field":U, B_RenameField.RenameFrom,
                           B_RenameField.RenameTo)). 
         ELSE
         MESSAGE SUBSTITUTE(new_lang[03], "Field":U, B_RenameField.RenameFrom,
                           B_RenameField.RenameTo).
      END.
    END.
  END.  /* AVAILABLE(B_RenameField) */
  RETURN cReturnValue.
END FUNCTION.  /* checkRenameField() */

/* 02/01/29 vap (IZ# 1525) */
FUNCTION checkRenameSequence RETURNS CHARACTER (
  INPUT pcRenameFrom   AS CHARACTER ,
  INPUT pcRenameToList AS CHARACTER ).
  /* It is allways a good practice to strong-scope all buffers in persistent
   * libraries, even although here it's not necessary. ADE code just should
   * serve as a code reference, too...
   */
  DEFINE BUFFER B_RenameSequence FOR ttRenameSequence.
  DEFINE VARIABLE cReturnValue AS CHARACTER NO-UNDO.
  FIND B_RenameSequence WHERE
       B_RenameSequence.RenameFrom EQ pcRenameFrom
       NO-ERROR.
  IF NOT AVAILABLE(B_RenameSequence) THEN
    ASSIGN cReturnValue = ?.
  ELSE DO:
    IF CAN-DO(pcRenameToList, B_RenameSequence.RenameTo) THEN
      ASSIGN cReturnValue = B_RenameSequence.RenameTo.
    ELSE DO:
      ASSIGN cReturnValue = ?.
      IF debug-mode GT 0 THEN DO:
         if setincrdmpSilent THEN 
                undo, throw new AppError(SUBSTITUTE(new_lang[03], "Sequence":U, B_RenameSequence.RenameFrom,
                           B_RenameSequence.RenameTo)). 
         ELSE
                MESSAGE SUBSTITUTE(new_lang[03], "Sequence":U, 
                           B_RenameSequence.RenameFrom,
                           B_RenameSequence.RenameTo).
      END.
    END.
  END.  /* AVAILABLE(B_RenameSequence) */
  RETURN cReturnValue.
END FUNCTION.  /* checkRenameSequence() */

/* We don't delete indexes first because Progress doesn't let you delete
   the last index.  So if we are about to rename an index or add a new
   one, see if an index with this name is in the list to be deleted.
   If so, rename that one so we don't get a name conflict.  It will 
   be deleted later.
*/
PROCEDURE Check_Index_Conflict:

   DEFINE INPUT PARAMETER p_i1Name LIKE index-list.i1-name.
   DEFINE INPUT PARAMETER p_db1-file-name LIKE _File._FIle-name.

   DEFINE VAR tempname AS CHAR INITIAL "temp-" NO-UNDO.
   DEFINE VAR lastCnt  AS INTEGER NO-UNDO.
   
   FIND FIRST index-alt WHERE NOT index-alt.i1-i2 AND /* to be deleted */
                    index-alt.i1-name = p_i1Name NO-ERROR. 
   IF AVAILABLE index-alt THEN DO:
      lastCnt = cnt.
      DO WHILE cnt = lastCnt:
         cnt = RANDOM(10000,99999).
      END.
      tempname = tempname + STRING(cnt).
      PUT STREAM-HANDLE hOfflineStream UNFORMATTED
        'RENAME INDEX "' index-alt.i1-name
        '" TO "' tempname
        '" ON "' p_db1-file-name '"' SKIP(1).
      index-alt.i1-name = tempname.
   END.
END.

PROCEDURE tmp-name:
   /* This procedure takes a field name and renames it to a unique
    * name so it can be deleted later. This is done in the instance
    * when a field has changed data-type or extent and is part of a
    * primary index. Since the index will not be deleted until later
    * on in the code. We will rename it and delete it later
    */
   DEFINE INPUT  PARAMETER fname   AS CHAR NO-UNDO.
   DEFINE OUTPUT PARAMETER newname AS CHAR NO-UNDO.

   DEFINE VARIABLE s AS INT NO-UNDO.

   DO s = 1 to 99:
     newname = "Z_" + substring(fname,1,28) + string(s,"99").
     FIND FIRST DICTDB.old-field WHERE DICTDB.old-field._Field-name = newname
          NO-ERROR.
     IF NOT AVAILABLE(DICTDB.old-field) THEN DO:
       FIND FIRST DICTDB2.new-field WHERE 
           DICTDB2.new-field._Field-name = newname
           NO-ERROR.
       IF NOT AVAILABLE(DICTDB2.new-field) THEN DO:
         FIND FIRST missing WHERE missing.name = newname NO-ERROR.
         IF NOT AVAILABLE(missing) THEN LEAVE. /* got it! */
       END.
     END.
   END. 
END PROCEDURE.   

/* Stolen from _dctquot.p - SO!  If you update this for any reason   
 *  (not very likely) consider if that should be updated             
 */
PROCEDURE dctquot:

   DEFINE INPUT  PARAMETER inline  AS CHARACTER            NO-UNDO.
   DEFINE INPUT  PARAMETER quotype AS CHARACTER            NO-UNDO.
   DEFINE OUTPUT PARAMETER outline AS CHARACTER INITIAL "" NO-UNDO.
   DEFINE        VARIABLE  i       AS INTEGER              NO-UNDO.

   IF INDEX(inline,quotype) > 0 THEN
     DO i = 1 TO LENGTH(inline):
       outline = outline + (IF SUBSTRING(inline,i,1) = quotype
                 THEN quotype + quotype ELSE SUBSTRING(inline,i,1)).
     END.
   ELSE
     outline = inline.

   outline = (IF outline = ? THEN "?" ELSE quotype + outline + quotype).

END PROCEDURE.

/* 02/01/29 vap (IZ# 1525) */
PROCEDURE set_Variables:
  DEFINE INPUT PARAMETER pcRenameFile AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER piDebugMode  AS INTEGER   NO-UNDO.
  DEFINE INPUT PARAMETER pcSilentincr AS LOGICAL   NO-UNDO.
  ASSIGN rename-file = pcRenameFile
         debug-mode = piDebugMode
	 setincrdmpSilent =  pcSilentincr.
  RETURN "":U.
END PROCEDURE.  /* set_Variables */

/* Loading the `rename definitions' for batch-mode from the
 * rename-file into respective temp-tables.
 * 02/01/29 vap (IZ# 1525)
 */
PROCEDURE load_Rename_Definitions:
  /* It is allways a good practice to strong-scope all buffers in persistent
   * libraries, even although here it's not necessary. ADE code just should
   * serve as a code reference, too...
   */
  DEFINE BUFFER B_RenameTable    FOR ttRenameTable.
  DEFINE BUFFER B_RenameField    FOR ttRenameField.
  DEFINE BUFFER B_RenameSequence FOR ttRenameSequence.

  DEFINE VARIABLE cInputLine AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cTable     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cFrom      AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cTo        AS CHARACTER NO-UNDO.

  EMPTY TEMP-TABLE B_RenameTable.
  EMPTY TEMP-TABLE B_RenameField.
  EMPTY TEMP-TABLE B_RenameSequence.

  IF rename-file NE "":U THEN DO:
    INPUT FROM VALUE(rename-file) NO-ECHO.
    REPEAT:
      ASSIGN cInputLine = "":U.
      IMPORT cInputLine.
      ASSIGN cInputLine = TRIM(cInputLine).
      IF cInputLine EQ "":U OR cInputLine BEGINS "#":U THEN
        NEXT.
      CASE TRIM(ENTRY(1, cInputLine)):
        WHEN "T":U THEN DO:
          IF NUM-ENTRIES(cInputLine) EQ 3 THEN DO:
            ASSIGN cFrom = TRIM(ENTRY(2, cInputLine))
                   cTo   = TRIM(ENTRY(3, cInputLine)).
            FIND B_RenameTable WHERE
                 B_RenameTable.RenameFrom EQ cFrom
                 NO-ERROR.
            IF AVAILABLE(B_RenameTable) THEN DO:
              IF debug-mode GT 0 THEN DO:
                 if setincrdmpSilent THEN 
                      undo, throw new AppError(SUBSTITUTE(new_lang[01], "Table":U, cFrom, cTo)). 
                 ELSE
                   MESSAGE SUBSTITUTE(new_lang[01], "Table":U, cFrom, cTo).
              END.
            END.
            ELSE DO:
              CREATE B_RenameTable.
              ASSIGN B_RenameTable.RenameFrom = cFrom.
            END.
            ASSIGN B_RenameTable.RenameTo = cTo.
          END.
          ELSE IF debug-mode GT 0 THEN DO:
               if setincrdmpSilent THEN 
                      undo, throw new AppError(SUBSTITUTE(new_lang[02], cInputLine)). 
               ELSE
                      MESSAGE SUBSTITUTE(new_lang[02], cInputLine).
          END.
        END.  /* Table */
        WHEN "F":U THEN DO:
          IF NUM-ENTRIES(cInputLine) EQ 4 THEN DO:
            ASSIGN cTable = TRIM(ENTRY(2, cInputLine))
                   cFrom  = TRIM(ENTRY(3, cInputLine))
                   cTo    = TRIM(ENTRY(4, cInputLine)).
            FIND B_RenameField WHERE
                 B_RenameField.TableName  EQ cTable AND
                 B_RenameField.RenameFrom EQ cFrom
                 NO-ERROR.
            IF AVAILABLE(B_RenameField) THEN DO:
              IF debug-mode GT 0 THEN DO:
                  if setincrdmpSilent THEN 
                      undo, throw new AppError(SUBSTITUTE(new_lang[01], "Field":U, cFrom, cTo)). 
                  ELSE
                      MESSAGE SUBSTITUTE(new_lang[01], "Field":U, cFrom, cTo).
              END.
            END.
            ELSE DO:
              CREATE B_RenameField.
              ASSIGN B_RenameField.TableName  = cTable
                     B_RenameField.RenameFrom = cFrom.
            END.         
            ASSIGN B_RenameField.RenameTo = cTo.
          END.
          ELSE IF debug-mode GT 0 THEN DO:
                if setincrdmpSilent THEN 
                      undo, throw new AppError(SUBSTITUTE(new_lang[02], cInputLine)). 
                ELSE
                      MESSAGE SUBSTITUTE(new_lang[02], cInputLine).
          END.
        END.  /* Field */
        WHEN "S":U THEN DO:
          IF NUM-ENTRIES(cInputLine) EQ 3 THEN DO:
            ASSIGN cFrom = TRIM(ENTRY(2, cInputLine))
                   cTo   = TRIM(ENTRY(3, cInputLine)).
            FIND B_RenameSequence WHERE
                 B_RenameSequence.RenameFrom EQ cFrom
                 NO-ERROR.
            IF AVAILABLE(B_RenameSequence) THEN DO:
              IF debug-mode GT 0 THEN DO:
                  if setincrdmpSilent THEN 
                      undo, throw new AppError(SUBSTITUTE(new_lang[01], "Sequence":U, cFrom, cTo)). 
                  ELSE
                      MESSAGE SUBSTITUTE(new_lang[01], "Sequence":U, cFrom, cTo).
              END.
            END.
            ELSE DO:
              CREATE B_RenameSequence.
              ASSIGN B_RenameSequence.RenameFrom = cFrom.
            END.  
            ASSIGN B_RenameSequence.RenameTo = cTo.
          END.
          ELSE IF debug-mode GT 0 THEN DO:
                if setincrdmpSilent THEN 
                      undo, throw new AppError(SUBSTITUTE(new_lang[02], cInputLine)). 
                ELSE
                      MESSAGE SUBSTITUTE(new_lang[02], cInputLine).
          END.
        END.  /* Sequence */
        OTHERWISE DO:
          IF debug-mode GT 0 THEN DO:
              if setincrdmpSilent THEN 
                      undo, throw new AppError(SUBSTITUTE(new_lang[02], cInputLine)). 
              ELSE
                      MESSAGE SUBSTITUTE(new_lang[02], cInputLine).
          END.
        END.  /* Unrecognized input */
      END CASE.  /* TRIM(ENTRY(1, cInputLine)) */
    END.  /* REPEAT: */
    INPUT CLOSE.

    IF debug-mode GT 1 THEN DO:
      OUTPUT STREAM err-log TO {&errFileName} APPEND NO-ECHO.
      FOR EACH B_RenameTable:
        DISPLAY STREAM err-log B_RenameTable WITH TITLE "Rename Table":U .
        DOWN.
      END.
      FOR EACH B_RenameField:
        DISPLAY STREAM err-log B_RenameField WITH TITLE "Rename Field":U WIDTH 120.
        DOWN.
      END.
      FOR EACH B_RenameSequence:
        DISPLAY STREAM err-log B_RenameSequence WITH TITLE "Rename Sequence":U.
        DOWN.
      END.
      PUT STREAM err-log UNFORMATTED " " SKIP(1).
      OUTPUT STREAM err-log CLOSE.
    END.  /* config-info */
  END.  /* rename-file NE ? */

  RETURN "":U.
END PROCEDURE.  /* load_Rename_Definitions */

/* prodict/dump/_dmputil.p */
