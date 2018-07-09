/**
 * Copyright 2005-2018 Riverside Software
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

&IF INTEGER(SUBSTRING(PROVERSION, 1, INDEX(PROVERSION, '.'))) GE 11 &THEN
  { pct/v11/xrefd0004.i}
&ELSEIF INTEGER(SUBSTRING(PROVERSION, 1, INDEX(PROVERSION, '.'))) GE 10 &THEN
  { pct/v10/xrefd0003.i}
&ENDIF

DEFINE TEMP-TABLE CRCList NO-UNDO
  FIELD ttTable AS CHARACTER
  FIELD ttCRC   AS CHARACTER
  INDEX ttCRC-PK IS PRIMARY UNIQUE ttTable.
DEFINE TEMP-TABLE TimeStamps NO-UNDO
  FIELD ttFile     AS CHARACTER CASE-SENSITIVE
  FIELD ttFullPath AS CHARACTER CASE-SENSITIVE
  FIELD ttExcept   AS LOGICAL INITIAL FALSE  /* True in case of includes to ignore for recompile */
  FIELD ttMod      AS DATETIME
  INDEX PK-TimeStamps IS PRIMARY UNIQUE ttFile
  INDEX TimeStamps-ttFile ttFile.
DEFINE TEMP-TABLE ttXref NO-UNDO
  FIELD xProcName   AS CHARACTER
  FIELD xFileName   AS CHARACTER
  FIELD xLineNumber AS CHARACTER
  FIELD xRefType    AS CHARACTER
  FIELD xObjID      AS CHARACTER FORMAT "X(50)"
  INDEX typ IS PRIMARY xRefType.
DEFINE TEMP-TABLE ttDirs NO-UNDO
  FIELD baseDir AS CHARACTER
  FIELD dirName AS CHARACTER
  INDEX ttDirs-PK IS PRIMARY baseDir dirName.
DEFINE TEMP-TABLE ttXrefInc NO-UNDO
  FIELD ttIncName AS CHARACTER.
DEFINE TEMP-TABLE ttXrefCRC NO-UNDO
  FIELD ttTblName AS CHARACTER.
DEFINE TEMP-TABLE ttXrefClasses NO-UNDO
  FIELD ttClsName AS CHARACTER.
DEFINE TEMP-TABLE ttWarnings NO-UNDO
  FIELD msgNum   AS INTEGER
  FIELD rowNum   AS INTEGER
  FIELD fileName AS CHARACTER
  FIELD msg      AS CHARACTER.
DEFINE TEMP-TABLE ttErrors NO-UNDO
  FIELD intNum   AS INTEGER
  FIELD fileName AS CHARACTER
  FIELD rowNum   AS INTEGER
  FIELD colNum   AS INTEGER
  FIELD msg      AS CHARACTER
  INDEX ttErrors-PK IS PRIMARY UNIQUE intNum
  INDEX ttErrors-PK2 IS UNIQUE fileName rowNum colNum.

DEFINE SHARED VARIABLE pctVerbose AS LOGICAL NO-UNDO.

FUNCTION getTimeStampDF RETURN DATETIME (INPUT d AS CHARACTER, INPUT f AS CHARACTER) FORWARD.
FUNCTION getTimeStampF RETURN DATETIME (INPUT f AS CHARACTER) FORWARD.
FUNCTION CheckIncludes RETURNS LOGICAL (INPUT f AS CHARACTER, INPUT TS AS DATETIME, INPUT d AS CHARACTER) FORWARD.
FUNCTION CheckCRC RETURNS LOGICAL (INPUT f AS CHARACTER, INPUT d AS CHARACTER) FORWARD.
FUNCTION fileExists RETURNS LOGICAL (INPUT f AS CHARACTER) FORWARD.
FUNCTION createDir RETURNS LOGICAL (INPUT base AS CHARACTER, INPUT d AS CHARACTER) FORWARD.

/** Named streams */
DEFINE STREAM sXref.
DEFINE STREAM sXref2.
DEFINE STREAM sIncludes.
DEFINE STREAM sCRC.
DEFINE STREAM sWarnings.

/* PCTCompile attributes */
DEFINE VARIABLE OutputDir AS CHARACTER  NO-UNDO.
DEFINE VARIABLE DestDir AS CHARACTER  NO-UNDO INITIAL ?.
DEFINE VARIABLE PCTDir    AS CHARACTER  NO-UNDO.
DEFINE VARIABLE preprocessDir AS CHARACTER  NO-UNDO.
DEFINE VARIABLE dbgListDir AS CHARACTER NO-UNDO.
DEFINE VARIABLE flattenDbg AS LOGICAL   NO-UNDO.
DEFINE VARIABLE ForceComp AS LOGICAL    NO-UNDO.
DEFINE VARIABLE NoParse   AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE StrXref   AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE AppStrXrf AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE RunList   AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE Lst       AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE LstPrepro AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE PrePro    AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE DebugLst  AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE keepXref  AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE multiComp AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE lXmlXref  AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE lXCode    AS LOGICAL    NO-UNDO.
DEFINE VARIABLE lRelative AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE ProgPerc  AS INTEGER    NO-UNDO INITIAL 0.
DEFINE VARIABLE lOptFullKw AS LOGICAL   NO-UNDO INITIAL FALSE.
DEFINE VARIABLE lOptFldQlf AS LOGICAL   NO-UNDO INITIAL FALSE.
DEFINE VARIABLE lOptFullNames AS LOGICAL NO-UNDO INITIAL FALSE.
DEFINE VARIABLE cOpts     AS CHARACTER NO-UNDO.
DEFINE VARIABLE iLine     AS INTEGER    NO-UNDO.
DEFINE VARIABLE iTotlines AS INTEGER    NO-UNDO.
DEFINE VARIABLE iNrSteps  AS INTEGER    NO-UNDO.
DEFINE VARIABLE iStep     AS INTEGER    NO-UNDO.
DEFINE VARIABLE iStepPerc AS INTEGER    NO-UNDO.
DEFINE VARIABLE cDspSteps AS CHARACTER  NO-UNDO.
DEFINE VARIABLE cIgnoredIncludes AS CHARACTER  NO-UNDO.
DEFINE VARIABLE lIgnoredIncludes AS LOGICAL    NO-UNDO.
DEFINE VARIABLE iFileList AS INTEGER    NO-UNDO.

/* Handle to calling procedure in order to log messages */
DEFINE VARIABLE hSrcProc AS HANDLE NO-UNDO.
ASSIGN hSrcProc = SOURCE-PROCEDURE.

DEFINE VARIABLE bAbove101 AS LOGICAL NO-UNDO INITIAL TRUE.
ASSIGN bAbove101 = (DECIMAL(REPLACE(SUBSTRING(PROVERSION, 1, INDEX(PROVERSION, '.') + 1), '.', SESSION:NUMERIC-DECIMAL-POINT)) GT 10.1).

PROCEDURE setOption.
  DEFINE INPUT PARAMETER ipName  AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER ipValue AS CHARACTER NO-UNDO.

  CASE ipName:
    when 'OUTPUTDIR':U        THEN ASSIGN DestDir = ipValue.
    WHEN 'PCTDIR':U           THEN ASSIGN PCTDir = ipValue.
    WHEN 'FORCECOMPILE':U     THEN ASSIGN ForceComp = (ipValue EQ '1':U).
    WHEN 'XCODE':U            THEN ASSIGN lXCode = (ipValue EQ '1':U).
    WHEN 'RUNLIST':U          THEN ASSIGN RunList = (ipValue EQ '1':U).
    WHEN 'LISTING':U          THEN ASSIGN Lst = (ipValue EQ '1':U).
    WHEN 'LISTINGSOURCE':U    THEN ASSIGN LstPrepro = (ipValue EQ 'PREPROCESSOR':U).
    WHEN 'PREPROCESS':U       THEN ASSIGN PrePro = (ipValue EQ '1':U).
    WHEN 'PREPROCESSDIR':U    THEN ASSIGN preprocessDir = ipValue.
    WHEN 'DEBUGLISTING':U     THEN ASSIGN DebugLst = (ipValue EQ '1':U).
    WHEN 'DEBUGLISTINGDIR':U  THEN ASSIGN dbgListDir = ipValue.
    WHEN 'FLATTENDBG':U       THEN ASSIGN flattenDbg = (ipValue EQ '1':U).
    WHEN 'STRINGXREF':U       THEN ASSIGN StrXref = (ipValue EQ '1':U).
    WHEN 'APPENDSTRINGXREF':U THEN ASSIGN AppStrXrf = (ipValue EQ '1':U).
    WHEN 'KEEPXREF':U         THEN ASSIGN keepXref = (ipValue EQ '1':U).
    WHEN 'NOPARSE':U          THEN ASSIGN noParse = (ipValue EQ '1':U).
    WHEN 'MULTICOMPILE':U     THEN ASSIGN multiComp = (ipValue EQ '1':U).
    WHEN 'RELATIVE':U         THEN ASSIGN lRelative = (ipValue EQ '1':U).
    WHEN 'PROGPERC':U         THEN ASSIGN ProgPerc = INTEGER(ipValue).
    WHEN 'XMLXREF':U          THEN ASSIGN lXmlXref = (ipValue EQ '1':U).
    WHEN 'IGNOREDINCLUDES':U  THEN ASSIGN cignoredIncludes = REPLACE(TRIM(ipValue), '~\':U, '/':U).
    WHEN 'FULLKW':U           THEN ASSIGN lOptFullKW = (ipValue EQ '1':U).
    WHEN 'FIELDQLF':U         THEN ASSIGN lOptFldQlf = (ipValue EQ '1':U).
    WHEN 'FULLNAMES':U        THEN ASSIGN lOptFullNames = (ipValue EQ '1':U).
    WHEN 'FILELIST':U         THEN ASSIGN iFileList = INTEGER(ipValue).
    WHEN 'NUMFILES':U         THEN ASSIGN iTotLines = INTEGER(ipValue).

    OTHERWISE RUN logError IN hSrcProc (SUBSTITUTE("Unknown parameter '&1' with value '&2'" ,ipName, ipValue)).
  END CASE.

END PROCEDURE.

PROCEDURE initModule:
  ASSIGN lIgnoredIncludes = (LENGTH(cignoredIncludes) > 0).

  /* Gets CRC list */
  DEFINE VARIABLE h AS HANDLE NO-UNDO.
  h = TEMP-TABLE CRCList:HANDLE.
  RUN pct/pctCRC.p (INPUT-OUTPUT TABLE-HANDLE h) NO-ERROR.
  IF (RETURN-VALUE NE '0') THEN
    RETURN RETURN-VALUE.

  /* Checks if valid config */
  OutputDir = if DestDir ne ? then DestDir else ".".
  IF NOT FileExists(OutputDir) THEN
    RETURN '4'.
  IF NOT FileExists(PCTDir) THEN
    ASSIGN PCTDir = OutputDir + '/.pct':U.
  IF debugLst AND (dbgListDir EQ '') THEN DO:
    ASSIGN dbgListDir = OutputDir + '/.dbg':U.
    createDir(outputDir, '.dbg':U).
  END.
  COMPILER:MULTI-COMPILE = multiComp.
  IF lOptFullKw THEN
    ASSIGN cOpts = 'require-full-keywords'.
  IF lOptFldQlf THEN
    ASSIGN cOpts = cOpts + (IF cOpts EQ '' THEN '' ELSE ',') + 'require-field-qualifiers'.
  IF lOptFullNames THEN
    ASSIGN cOpts = cOpts + (IF cOpts EQ '' THEN '' ELSE ',') + 'require-full-names'.

  IF ProgPerc GT 0 THEN DO:
    ASSIGN iNrSteps = 100 / ProgPerc.
    IF iNrSteps GT iTotLines THEN DO:
      ASSIGN iNrSteps = iTotLines
             ProgPerc = 100 / iNrSteps.
      RUN logVerbose IN hSrcProc ("WARNING: Less files then percentage steps. Automatically increasing percentage to " + TRIM(STRING(ProgPerc, ">>9%":U))).
    END.
    DO iStep = 1 TO iNrSteps:
      ASSIGN cDspSteps = cDspSteps + (IF cDspSteps NE "" THEN "," ELSE "") + STRING(MIN(INTEGER((iTotLines / 100) * (ProgPerc * iStep)), iTotLines)).
    END.
  END.

END PROCEDURE.

FUNCTION getRecompileLabel RETURNS CHARACTER (ipVal AS INTEGER):
  CASE ipVal:
    WHEN 0 THEN RETURN 'Up to date'.
    WHEN 1 THEN RETURN 'No r-code'.
    WHEN 2 THEN RETURN 'R-code older than source'.
    WHEN 3 THEN RETURN 'R-code older than include file'.
    WHEN 4 THEN RETURN 'Table CRC'.
    WHEN 5 THEN RETURN 'XCode or force'.
    OTHERWISE   RETURN '???'.
  END.
END FUNCTION.

PROCEDURE compileXref.
  DEFINE INPUT  PARAMETER ipInDir   AS CHARACTER  NO-UNDO. /* Fileset. Never null */
  DEFINE INPUT  PARAMETER ipInFile  AS CHARACTER  NO-UNDO. /* Path relative to fileset. Never null */
  DEFINE INPUT  PARAMETER ipOutFile AS CHARACTER  NO-UNDO. /* Path relative to pcOutDir. Can be null, in this case, the default rcode name */
  DEFINE OUTPUT PARAMETER opError   AS LOGICAL    NO-UNDO INITIAL FALSE.
  DEFINE OUTPUT PARAMETER opComp    AS INTEGER    NO-UNDO. /* 0 -> Not compiled, >0  recompiled */

  DEFINE VARIABLE i        AS INTEGER    NO-UNDO.
  DEFINE VARIABLE cBase    AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE cBase2    AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE cFile    AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE cFile2    AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE cFileExt AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE cFileExt2 AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE cSaveDir AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cXrefFile AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE cStrXrefFile AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE preprocessFile AS CHARACTER NO-UNDO.
  DEFINE VARIABLE debugListingFile AS CHARACTER NO-UNDO.
  DEFINE VARIABLE warningsFile AS CHARACTER NO-UNDO.
  DEFINE VARIABLE RCodeTS   AS DATETIME   NO-UNDO.
  DEFINE VARIABLE ProcTS    AS DATETIME   NO-UNDO.
  DEFINE VARIABLE cRenameFrom AS CHARACTER NO-UNDO INITIAL ''.
  DEFINE VARIABLE lWarnings AS LOGICAL NO-UNDO INITIAL FALSE.

  /* Output progress */
  IF ProgPerc GT 0 THEN DO:
    ASSIGN iLine = iLine + 1.
    IF LOOKUP(STRING(iLine), cDspSteps) GT 0 THEN DO:
      ASSIGN iStepPerc = LOOKUP(STRING(iLine), cDspSteps) * ProgPerc.
      IF iStepPerc LT 100 THEN
        RUN logInfo IN hSrcProc (SUBSTITUTE("&1 &2 Compiling &3...", TRIM(STRING(iStepPerc, ">>9%":U)), STRING(TIME, "HH:MM:SS":U), ipInFile)).
      ELSE
        RUN logInfo IN hSrcProc ("100% " + STRING(TIME,"HH:MM:SS":U)).
    END.
    IF (iLine GE iTotLines) AND (iStepPerc LT 100) THEN DO:
      ASSIGN iStepPerc = 100.
      RUN logInfo IN hSrcProc ("100% " + STRING(TIME,"HH:MM:SS":U)).
    END.
  END.

  IF (NOT fileExists(IF lRelative THEN ipInFile ELSE ipInDir + '/':U + ipInFile)) THEN DO:
    RUN logError IN hSrcProc (SUBSTITUTE("File [&1]/[&2] not found", ipInDir, ipInFile)).
    ASSIGN opError = TRUE.
    ASSIGN opComp = 0.
    RETURN.
  END.

  RUN adecomm/_osprefx.p(INPUT ipInFile, OUTPUT cBase, OUTPUT cFile).
  RUN adecomm/_osfext.p(INPUT cFile, OUTPUT cFileExt).
  ASSIGN opError = NOT createDir(outputDir, cBase).
  IF (opError) THEN RETURN.
  ASSIGN opError = NOT createDir(PCTDir, cBase).
  IF (opError) THEN RETURN.
  ASSIGN cSaveDir = (IF DestDir EQ ?
                       THEN ?
                       ELSE (IF cFileExt = ".cls":U OR lRelative
                               THEN outputDir
                               ELSE outputDir + '/':U + cBase)).

  IF (ipOutFile EQ ?) OR (ipOutFile EQ '') THEN DO:
    ASSIGN ipOutFile = SUBSTRING(ipInFile, 1, R-INDEX(ipInFile, cFileExt) - 1) + '.r':U.
  END.
  ELSE DO:
    RUN adecomm/_osprefx.p(INPUT ipOutFile, OUTPUT cBase2, OUTPUT cFile2).
    RUN adecomm/_osfext.p(INPUT cFile2, OUTPUT cFileExt2).
    ASSIGN opError = NOT createDir(outputDir, cBase2).
    IF (opError) THEN RETURN.
    ASSIGN opError = NOT createDir(PCTDir, cBase2).
    IF (opError) THEN RETURN.
    ASSIGN cRenameFrom = cBase + (IF cbase EQ '' THEN '' ELSE '/') + substring(cfile, 1, R-INDEX(cfile, '.') - 1) + '.r'.
  END.

  IF (noParse OR ForceComp OR lXCode) THEN DO:
    ASSIGN opComp = 5.
  END.
  ELSE DO:
    /* Does .r file exists ?,
       if DestDir = unknown rcode will be located in the same directory as the source : ipInDir */
    ASSIGN RCodeTS = getTimeStampDF(if DestDir = ? then ipInDir else OutputDir, ipOutFile).
    IF (RCodeTS EQ ?) THEN DO:
      opComp = 1.
    END.
    ELSE DO:
      /* Checking if .r timestamp is prior to procedure timestamp */
      ASSIGN ProcTS = getTimeStampDF(ipInDir, ipInFile).
      IF (ProcTS GT RCodeTS) THEN DO:
        opComp = 2.
      END.
      ELSE DO:
        IF CheckIncludes(ipInFile, RCodeTS, PCTDir) THEN DO:
          opComp = 3.
        END.
        ELSE DO:
          IF CheckCRC(ipInFile, PCTDir) THEN DO:
            opComp = 4.
          END.
        END.
      END.
    END.
  END.
  IF (iFileList GT 0) THEN DO:
    IF ((iFileList EQ 1) AND (opComp GT 0) ) OR (iFileList EQ 2) THEN DO:
      RUN logInfo IN hSrcProc (SUBSTITUTE("&1 [&2]", ipInFile, getRecompileLabel(opComp))).
    END.
  END.
  IF opComp EQ 0 THEN RETURN.

  ASSIGN cXrefFile = PCTDir + '/':U + ipInFile + '.xref':U.
  ASSIGN warningsFile = PCTDir + '/':U + ipInFile + '.warnings':U.
  ASSIGN cStrXrefFile = (IF StrXref AND AppStrXrf
                           THEN PCTDir + '/strings.xref':U
                           ELSE (IF StrXref
                                 THEN PCTDir + '/':U + ipInFile + '.strxref'
                                 ELSE ?)).

  IF PrePro THEN DO:
    IF preprocessDir = '' THEN
      ASSIGN preprocessFile = PCTDir + '/':U + ipInFile + '.preprocess':U.
    ELSE DO:
      ASSIGN preprocessFile = preprocessDir + '/':U + ipInFile.
      ASSIGN opError = NOT createDir(preprocessDir, cBase).
      IF (opError) THEN RETURN.
    END.
  END.
  ELSE
    ASSIGN preprocessFile = ?.

  IF debugLst AND NOT (cFile BEGINS '_') THEN DO:
    IF flattenDbg THEN
      ASSIGN debugListingFile = dbgListDir + '/' + REPLACE(REPLACE(ipInFile, '/', '_'), '~\', '_').
    ELSE DO:
      ASSIGN debugListingFile = ipInFile.
      ASSIGN debugListingFile = dbgListDir + '/' + debugListingFile.
      ASSIGN opError = NOT createDir(dbgListDir, cBase).
      IF (opError) THEN RETURN.
    END.
  END.
  ELSE
    ASSIGN debugListingFile = ?.

&IF DECIMAL(SUBSTRING(PROVERSION, 1, INDEX(PROVERSION, '.') + 1)) GE 11.7 &THEN
  IF (cOpts GT "") AND (DECIMAL(REPLACE(SUBSTRING(PROVERSION, 1, INDEX(PROVERSION, '.') + 1), '.', SESSION:NUMERIC-DECIMAL-POINT)) GE 11.7) THEN DO:
    EMPTY TEMP-TABLE ttWarnings.
    COMPILE VALUE(IF lRelative THEN ipInFile ELSE ipInDir + '/':U + ipInFile) SAVE=FALSE OPTIONS cOpts NO-ERROR.
    IF COMPILER:ERROR THEN DO i = 1 TO COMPILER:NUM-MESSAGES:
      /* Messages 14786, 14789, 18494 are the only relevant ones */
      IF (COMPILER:GET-NUMBER(i) EQ 14786) OR (COMPILER:GET-NUMBER(i) EQ 14789) OR (COMPILER:GET-NUMBER(i) EQ 18494) THEN DO:
        CREATE ttWarnings.
        ASSIGN ttWarnings.msgNum   = COMPILER:GET-NUMBER(i)
               ttWarnings.rowNum   = COMPILER:GET-ROW(i)
               ttWarnings.fileName = COMPILER:GET-FILE-NAME(i)
               ttWarnings.msg      = COMPILER:GET-MESSAGE(i)
               lWarnings           = TRUE.
      END.
    END.
  END.
&ENDIF

  RUN logVerbose IN hSrcProc (SUBSTITUTE("Compiling &1 in directory &2 TO &3", ipInFile, ipInDir, cSaveDir)).
  RUN pctcomp.p (IF lRelative THEN ipInFile ELSE ipInDir + '/':U + ipInFile,
                 cSaveDir, debugListingFile,
                 IF Lst AND NOT LstPrepro THEN PCTDir + '/':U + ipInFile ELSE ?,
                 preprocessFile, cStrXrefFile, cXrefFile).

  ASSIGN opError = COMPILER:ERROR.
  IF NOT opError THEN DO:
    /* In order to handle <mapper> element */
    IF cRenameFrom NE '' THEN DO:
      OS-COPY VALUE(outputDir + '/' + cRenameFrom) VALUE(outputDir + '/' + ipOutFile).
      OS-DELETE VALUE(outputDir + '/' + cRenameFrom).
    END.
    IF (NOT noParse) AND (NOT lXCode) THEN DO:
      IF lXmlXref THEN
        RUN ImportXmlXref (INPUT cXrefFile, INPUT PCTDir, INPUT ipInFile) NO-ERROR.
      ELSE
        RUN ImportXref (INPUT cXrefFile, INPUT PCTDir, INPUT ipInFile) NO-ERROR.
    END.
    IF COMPILER:WARNING OR lWarnings THEN DO:
      OUTPUT STREAM sWarnings TO VALUE(warningsFile).
      DO i = 1 TO COMPILER:NUM-MESSAGES:
        IF bAbove101 THEN DO:
          /* Messages 2363, 3619 and 3623 are in fact warnings (from -checkdbe switch) */
          IF (COMPILER:GET-MESSAGE-TYPE(i) EQ 2) OR (COMPILER:GET-NUMBER(i) EQ 2363) OR (COMPILER:GET-NUMBER(i) EQ 3619) OR (COMPILER:GET-NUMBER(i) EQ 3623) THEN DO:
            IF (LOOKUP(STRING(COMPILER:GET-NUMBER(i)), SESSION:SUPPRESS-WARNINGS-LIST) EQ 0) THEN DO:
              PUT STREAM sWarnings UNFORMATTED SUBSTITUTE("[&1] [&3] &2", COMPILER:GET-ROW(i), REPLACE(COMPILER:GET-MESSAGE(i), '~n', ' '), COMPILER:GET-FILE-NAME(i)) SKIP.
            END.
          END.
        END.
      END.
      FOR EACH ttWarnings:
        PUT STREAM sWarnings UNFORMATTED SUBSTITUTE("[&1] [&3] &2", ttWarnings.rowNum, ttWarnings.msg, ttWarnings.fileName) SKIP.
      END.
      OUTPUT STREAM sWarnings CLOSE.
    END.
    ELSE DO:
      OS-DELETE VALUE(warningsFile).
    END.
  END.
  ELSE DO:
    RUN logError IN hSrcProc (SUBSTITUTE("Error compiling file '&1' ...", REPLACE(ipInDir + (IF ipInDir EQ '':U THEN '':U ELSE '/':U) + ipInFile, CHR(92), '/':U))).
    EMPTY TEMP-TABLE ttErrors.
    DO i = 1 TO COMPILER:NUM-MESSAGES:
      IF COMPILER:GET-NUMBER(i) EQ 198 THEN NEXT.
      FIND ttErrors WHERE ttErrors.fileName EQ COMPILER:GET-FILE-NAME(i)
                      AND ttErrors.rowNum   EQ (IF bAbove101 THEN COMPILER:GET-ROW(i) ELSE COMPILER:GET-ERROR-ROW(i))
                      AND ttErrors.colNum   EQ (IF bAbove101 THEN COMPILER:GET-COLUMN(i) ELSE COMPILER:GET-ERROR-COLUMN(i))
                    NO-ERROR.
      IF NOT AVAILABLE ttErrors THEN DO:
        CREATE ttErrors.
        ASSIGN ttErrors.intNum   = i
               ttErrors.fileName = COMPILER:GET-FILE-NAME(i)
               ttErrors.rowNum   = (IF bAbove101 THEN COMPILER:GET-ROW(i) ELSE COMPILER:GET-ERROR-ROW(i))
               ttErrors.colNum   = (IF bAbove101 THEN COMPILER:GET-COLUMN(i) ELSE COMPILER:GET-ERROR-COLUMN(i)).
      END.
      ASSIGN ttErrors.msg = ttErrors.msg + (IF ttErrors.msg EQ '' THEN '' ELSE '~n') + COMPILER:GET-MESSAGE(i).
    END.
    FOR EACH ttErrors:
      RUN displayCompileErrors(ipInDir + (IF ipInDir EQ '':U THEN '':U ELSE '/':U) + ipInFile, ttErrors.fileName, ttErrors.rowNum, ttErrors.colNum, ttErrors.msg).
    END.
  END.
  IF NOT keepXref THEN
    OS-DELETE VALUE(cXrefFile).

  IF (NOT opError AND lst AND lstPrepro AND (preprocessFile NE ?)) THEN DO:
    COMPILE VALUE(preprocessFile) SAVE=NO LISTING VALUE(PCTDir + '/':U + ipInFile) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      OS-DELETE VALUE(PCTDir + '/':U + ipInFile).
    END.
  END.

END PROCEDURE.

PROCEDURE displayCompileErrors PRIVATE:
  DEFINE INPUT  PARAMETER pcInit    AS CHARACTER  NO-UNDO.
  DEFINE INPUT  PARAMETER pcFile    AS CHARACTER  NO-UNDO.
  DEFINE INPUT  PARAMETER piRow     AS INTEGER    NO-UNDO.
  DEFINE INPUT  PARAMETER piColumn  AS INTEGER    NO-UNDO.
  DEFINE INPUT  PARAMETER pcMsg     AS CHARACTER  NO-UNDO.

  DEFINE VARIABLE i       AS INTEGER    NO-UNDO .
  DEFINE VARIABLE c       AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE bit     AS INTEGER    NO-UNDO.
  DEFINE VARIABLE memvar  AS MEMPTR     NO-UNDO.
  DEFINE VARIABLE include AS LOGICAL    NO-UNDO.

  ASSIGN include = REPLACE(pcInit, CHR(92), '/') NE REPLACE(pcFile, CHR(92), '/').

  /* Checking if file is xcoded */
  COPY-LOB FROM FILE pcFile FOR 1 TO memvar.
  bit = GET-BYTE (memvar, 1).
  SET-SIZE(memvar) = 0.

  IF (include) THEN
    RUN logError IN hSrcProc (SUBSTITUTE(" ... in file '&1' at line &2 column &3", REPLACE(pcFile, CHR(92), '/'), piRow, piColumn)).
  ELSE
    RUN logError IN hSrcProc (SUBSTITUTE(" ... in main file at line &2 column &3", pcInit, piRow, piColumn, pcFile)).

  IF (bit NE 17) AND (bit NE 19) THEN DO:
    INPUT STREAM sXref FROM VALUE(pcFile).
    DO i = 1 TO piRow - 1:
      IMPORT STREAM sXref UNFORMATTED ^.
    END.
    IMPORT STREAM sXref UNFORMATTED c.
    RUN logError IN hSrcProc (INPUT ' ' + c).
    RUN logError IN hSrcProc (INPUT FILL('-':U, piColumn - 1) + '-^').
    RUN logError IN hSrcProc (INPUT pcMsg).
    RUN logError IN hSrcProc (INPUT '').

    INPUT STREAM sXref CLOSE.
  END.
  ELSE DO:
    RUN logError IN hSrcProc (INPUT pcMsg).
    RUN logError IN hSrcProc (INPUT ">> Can't display xcoded source").
    RUN logError IN hSrcProc (INPUT '').
  END.

END PROCEDURE.

PROCEDURE importXmlXref.
  DEFINE INPUT  PARAMETER pcXref AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER pcDir  AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER pcFile AS CHARACTER NO-UNDO.

  DEFINE VARIABLE cTmp      AS CHARACTER NO-UNDO.
  DEFINE VARIABLE zz        AS INTEGER NO-UNDO.

  EMPTY TEMP-TABLE ttXrefInc.
  EMPTY TEMP-TABLE ttXrefCRC.
  EMPTY TEMP-TABLE ttXrefClasses.

  DATASET Cross-reference:READ-XML("FILE", pcXref, "EMPTY", ?, ?).

  FOR EACH Reference WHERE LOOKUP(Reference-Type, 'INCLUDE,CREATE,REFERENCE,ACCESS,UPDATE,SEARCH,CLASS':U) NE 0:
    ASSIGN Reference.Object-identifier = TRIM(Reference.Object-identifier).
    IF Reference.Reference-Type EQ 'INCLUDE' THEN DO:
      /* Extract include file name from field (which contains include parameters */
      CREATE ttXrefInc.
      ASSIGN ttXrefInc.ttIncName = TRIM(SUBSTRING(Reference.Object-identifier, 1, INDEX(Reference.Object-identifier, ' ') - 1)).
    END.
    ELSE IF Reference.Reference-Type EQ 'CLASS' THEN DO:
      FOR EACH Class-Ref OF Reference:
        DO zz = 1 TO NUM-ENTRIES(Class-Ref.Inherited-list, ' '):
          CREATE ttXrefClasses.
          ASSIGN ttXrefClasses.ttClsName = ENTRY(zz, Class-Ref.Inherited-list, ' ').
        END.
        DO zz = 1 TO NUM-ENTRIES(Class-Ref.Implements-list, ' '):
          CREATE ttXrefClasses.
          ASSIGN ttXrefClasses.ttClsName = ENTRY(zz, Class-Ref.Implements-list, ' ').
        END.
      END.
    END.
    ELSE DO:
      /* Find CRC of each table */
      CREATE ttXrefCRC.
      IF (INDEX(Reference.Object-identifier, ' ') GT 0) THEN
        ASSIGN ttXrefCRC.ttTblName = SUBSTRING(Reference.Object-identifier, 1, INDEX(Reference.Object-identifier, ' ') - 1).
      ELSE
        ASSIGN ttXrefCRC.ttTblName = Reference.Object-identifier.
    END.
  END.

  OUTPUT TO VALUE (pcDir + '/':U + pcFile + '.inc':U).
  FOR EACH ttXrefInc BREAK BY ttIncName:
    IF FIRST-OF(ttXrefInc.ttIncName) THEN
      EXPORT ttXrefInc.ttIncName SEARCH(ttXrefInc.ttIncName).
  END.
  OUTPUT CLOSE.

  OUTPUT TO VALUE (pcDir + '/':U + pcFile + '.crc':U).
  FOR EACH ttXrefCRC BREAK BY ttTblName:
    IF FIRST-OF(ttXrefCRC.ttTblName) THEN DO:
      FIND CRCList WHERE CRCList.ttTable EQ ttXrefCRC.ttTblName NO-LOCK NO-ERROR.
      IF (AVAILABLE CRCList) THEN DO:
        EXPORT CRCList.
      END.
    END.
  END.
  OUTPUT CLOSE.

  OUTPUT TO VALUE (pcDir + '/':U + pcFile + '.hierarchy':U).
  FOR EACH ttXrefClasses NO-LOCK:
    EXPORT ttXrefClasses.ttClsName SEARCH(REPLACE(ttXrefClasses.ttClsName, '.', '/') + '.cls').
  END.
  OUTPUT CLOSE.

END PROCEDURE.

PROCEDURE importXref PRIVATE.
  DEFINE INPUT  PARAMETER pcXref AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER pcDir  AS CHARACTER NO-UNDO.
  DEFINE INPUT  PARAMETER pcFile AS CHARACTER NO-UNDO.

  DEFINE VARIABLE cSearch AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE cTmp    AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE cTmp2   AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE zz      AS INTEGER    NO-UNDO.

  EMPTY TEMP-TABLE ttXref.

  INPUT STREAM sXREF FROM VALUE (pcXref).
  INPUT STREAM sXREF2 FROM VALUE (pcXref).
  REPEAT:
    CREATE ttXref.
    IMPORT STREAM sXREF ttXref.

    /* Import full line in order to reposition the first stream if line is longer than 2000 characters */
    IMPORT STREAM sXREF2 UNFORMATTED cTmp.
    SEEK STREAM sXREF TO SEEK(sXREF2).
    /* Read content of xObjID field from full line */
    ASSIGN cTmp2 = ttXref.xLineNumber + ' ' + ttXref.xRefType + ' '.
    ASSIGN ttXref.xObjID = SUBSTRING(cTmp, INDEX(cTmp, cTmp2) + LENGTH(cTmp2)).

    /* Remove surrounding quotes */
    IF (SUBSTRING(ttXref.xObjId, 1, 1) EQ '"') AND (SUBSTRING(ttXref.xObjId, LENGTH(ttXref.xObjId), 1) EQ '"') THEN
      ASSIGN ttXref.xObjId = SUBSTRING(ttXref.xObjId, 2, LENGTH(ttXref.xObjId) - 2).

    IF (ttXref.xRefType EQ 'INCLUDE':U) OR (RunList AND (ttXref.xRefType EQ 'RUN':U)) THEN
      ttXref.xObjID = ENTRY(1, TRIM(ttXref.xObjID), ' ':U).
    ELSE IF (LOOKUP(ttXref.xRefType, 'CREATE,REFERENCE,ACCESS,UPDATE,SEARCH':U) NE 0) THEN DO:
      /* xObjID may contain DB.Table followed by IndexName or FieldName. We extract table name */
      IF (INDEX(ttXref.xObjID, ' ') GT 0) THEN
        ASSIGN ttXref.xObjID = SUBSTRING(ttXref.xObjID, 1, INDEX(ttXref.xObjID, ' ') - 1).
    END.
    ELSE IF (LOOKUP(ttXref.xRefType, 'CLASS':U) EQ 0) THEN
      DELETE ttXref.
  END.
  DELETE ttXref. /* ttXref is non-undo'able */
  INPUT STREAM sXREF CLOSE.
  INPUT STREAM sXREF2 CLOSE.

  OUTPUT TO VALUE (pcDir + '/':U + pcFile + '.inc':U).
  FOR EACH ttXref WHERE xRefType EQ 'INCLUDE':U NO-LOCK BREAK BY ttXref.xObjID:
    IF FIRST-OF (ttXref.xObjID) THEN
      EXPORT ttXref.xObjID SEARCH(ttXref.xObjID).
  END.
  OUTPUT CLOSE.

  OUTPUT TO VALUE (pcDir + '/':U + pcFile + '.crc':U).
  FOR EACH ttXref WHERE LOOKUP(ttXref.xRefType, 'CREATE,REFERENCE,ACCESS,UPDATE,SEARCH':U) NE 0 NO-LOCK BREAK BY ttXref.xObjID:
    IF FIRST-OF (ttXref.xObjID) THEN DO:
      FIND CRCList WHERE CRCList.ttTable EQ ttXref.xObjID NO-LOCK NO-ERROR.
      IF (AVAILABLE CRCList) THEN DO:
        EXPORT CRCList.
      END.
    END.
  END.
  OUTPUT CLOSE.

  OUTPUT TO VALUE (pcDir + '/':U + pcFile + '.hierarchy':U).
  FOR EACH ttXref WHERE xRefType EQ 'CLASS':U NO-LOCK:
    ASSIGN cTmp = ENTRY(2, ttXref.xObjID).
    IF cTmp BEGINS 'INHERITS ' THEN DO:
      ASSIGN cTmp = SUBSTRING(cTmp, 10). /* To remove INHERITS */
      DO zz = 1 TO NUM-ENTRIES(cTmp, ' '):
        EXPORT ENTRY(zz, cTmp, ' ') SEARCH(REPLACE(ENTRY(zz, cTmp, ' '), '.', '/') + '.cls').
      END.
    END.
    ASSIGN cTmp = ENTRY(3, ttXref.xObjID).
    IF cTmp BEGINS 'IMPLEMENTS ' THEN DO:
      ASSIGN cTmp = SUBSTRING(cTmp, 12). /* To remove IMPLEMENTS */
      DO zz = 1 TO NUM-ENTRIES(cTmp, ' '):
        EXPORT ENTRY(zz, cTmp, ' ') SEARCH(REPLACE(ENTRY(zz, cTmp, ' '), '.', '/') + '.cls').
      END.
    END.
  END.
  OUTPUT CLOSE.

  IF RunList THEN DO:
    OUTPUT TO VALUE (pcDir + '/':U + pcFile + '.run':U).
    FOR EACH ttXref WHERE xRefType EQ 'RUN':U AND ((ttXref.xObjID MATCHES '*~~.p') OR (ttXref.xObjID MATCHES '*~~.w')) NO-LOCK BREAK BY ttXref.xObjID:
      IF FIRST-OF (ttXref.xObjID) THEN DO:
        FIND TimeStamps WHERE TimeStamps.ttFile EQ ttXref.xObjID NO-LOCK NO-ERROR.
        IF (NOT AVAILABLE TimeStamps) THEN DO:
          ASSIGN cSearch = SEARCH(SUBSTRING(ttXref.xObjID, 1, R-INDEX(ttXref.xObjID, '.')) + 'r').
          IF (cSearch EQ ?) THEN
            ASSIGN cSearch = SEARCH(ttXref.xObjID).
          CREATE TimeStamps.
          ASSIGN TimeStamps.ttFile = ttXref.xObjID
                 TimeStamps.ttFullPath = (IF cSearch EQ ? THEN 'NOT FOUND' ELSE cSearch).
          ASSIGN TimeStamps.ttMod = getTimeStampF(TimeStamps.ttFullPath).
        END.
        EXPORT ttXref.xObjID TimeStamps.ttFullPath.
      END.
    END.
    OUTPUT CLOSE.
  END.

END PROCEDURE.

FUNCTION getTimeStampDF RETURNS DATETIME (INPUT d AS CHARACTER, INPUT f AS CHARACTER):
  RETURN getTimeStampF(d + (IF d EQ '':U THEN '':U ELSE '/':U) + f).
END FUNCTION.

FUNCTION getTimeStampF RETURNS DATETIME (INPUT f AS CHARACTER):
  ASSIGN FILE-INFO:FILE-NAME = f.
  RETURN DATETIME(FILE-INFO:FILE-MOD-DATE, FILE-INFO:FILE-MOD-TIME * 1000).
END FUNCTION.

FUNCTION CheckIncludes RETURNS LOGICAL (INPUT f AS CHARACTER, INPUT ts AS DATETIME, INPUT d AS CHARACTER).
  DEFINE VARIABLE IncFile     AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE IncFullPath AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE lReturn     AS LOGICAL    NO-UNDO INITIAL FALSE.

  /* Small workaround when compiling classes */
  FILE-INFO:FILE-NAME = d + '/':U + f + '.inc':U.
  IF FILE-INFO:FULL-PATHNAME EQ ? THEN DO:
    RETURN lReturn.
  END.

  INPUT STREAM sIncludes FROM VALUE (d + '/':U + f + '.inc':U).
  FileList:
  REPEAT:
    IMPORT STREAM sIncludes IncFile IncFullPath.
    FIND TimeStamps WHERE TimeStamps.ttFile EQ IncFile NO-LOCK NO-ERROR.
    IF (NOT AVAILABLE TimeStamps) THEN DO:
      CREATE TimeStamps.
      ASSIGN TimeStamps.ttFile = IncFile
             TimeStamps.ttFullPath = SEARCH(IncFile).
      ASSIGN TimeStamps.ttMod = getTimeStampF(TimeStamps.ttFullPath).
      IF lIgnoredIncludes AND CAN-DO(cIgnoredIncludes, REPLACE(IncFile, '~\':U, '/':U)) THEN /* include is not relevant for recompile */ DO:
        RUN logVerbose IN hSrcProc (SUBSTITUTE('Ignoring changes in &1', IncFile)).
        ASSIGN TimeStamps.ttExcept = TRUE.
      END.
    END.
    IF ((TimeStamps.ttFullPath NE IncFullPath) OR (TS LT TimeStamps.ttMod)) AND (TimeStamps.ttExcept EQ FALSE) THEN DO:
      ASSIGN lReturn = TRUE.
      LEAVE FileList.
    END.
  END.
  INPUT STREAM sIncludes CLOSE.
  RETURN lReturn.

END FUNCTION.

FUNCTION CheckCRC RETURNS LOGICAL (INPUT f AS CHARACTER, INPUT d AS CHARACTER).
  DEFINE VARIABLE cTab AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE cCRC AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE lRet AS LOGICAL    NO-UNDO INITIAL FALSE.

  IF NOT fileExists(d + '/':U + f + '.crc':U) THEN
    RETURN TRUE.
  INPUT STREAM sCRC FROM VALUE(d + '/':U + f + '.crc':U).
  CRCList:
  REPEAT:
    IMPORT STREAM sCRC cTab cCRC.
    FIND CRCList WHERE CRCList.ttTable EQ cTab NO-LOCK NO-ERROR.
    IF (NOT AVAILABLE CRCList) THEN DO:
      ASSIGN lRet = TRUE.
      LEAVE CRCList.
    END.
    IF (CRCList.ttCRC NE cCRC) THEN DO:
      ASSIGN lRet = TRUE.
      LEAVE CRCList.
    END.
  END.
  INPUT STREAM sCRC CLOSE.
  RETURN lRet.

END FUNCTION.

FUNCTION fileExists RETURNS LOGICAL (INPUT f AS CHARACTER):
  ASSIGN FILE-INFO:FILE-NAME = f.
  RETURN (FILE-INFO:FULL-PATHNAME NE ?).
END FUNCTION.

FUNCTION createDir RETURNS LOGICAL (INPUT base AS CHARACTER, INPUT d AS CHARACTER):
  DEFINE VARIABLE i AS INTEGER    NO-UNDO.
  DEFINE VARIABLE c AS CHARACTER  NO-UNDO.

  /* Asserts base is a writable directory */
  FIND ttDirs WHERE ttDirs.baseDir EQ base
                AND ttDirs.dirName EQ d
              NO-LOCK NO-ERROR.
  IF (AVAILABLE ttDirs) THEN
    RETURN TRUE.

  ASSIGN d = REPLACE(d, CHR(92), '/':U).
  DO i = 1 TO NUM-ENTRIES(d, '/':U):
    ASSIGN c = c + '/':U + ENTRY(i, d, '/':U).
    FIND ttDirs WHERE ttDirs.baseDir EQ base
                  AND ttDirs.dirName EQ c
                NO-LOCK NO-ERROR.
    IF (NOT AVAILABLE ttDirs) THEN DO:
      OS-CREATE-DIR VALUE(base + c).
      IF (OS-ERROR EQ 0) OR (OS-ERROR EQ 999) THEN DO:
        /* Issue #200: error code 999 is sometimes sent when 2 processes want to create dir at the same time */
        CREATE ttDirs.
        ASSIGN ttDirs.baseDir = base
               ttDirs.dirName = c.
      END.
      ELSE DO:
        RUN logError IN hSrcProc (SUBSTITUTE("Unable to create directory '&1' - Err &2", c, OS-ERROR)).
        RETURN FALSE.
      END.
    END.
  END.
  RETURN TRUE.

END FUNCTION.
