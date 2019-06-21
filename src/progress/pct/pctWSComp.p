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

DEFINE TEMP-TABLE ttDirs NO-UNDO
    FIELD baseDir AS CHARACTER
    FIELD dirName AS CHARACTER.

FUNCTION getTimeStampDF RETURN INTEGER (INPUT d AS CHARACTER, INPUT f AS CHARACTER) FORWARD.
FUNCTION getTimeStampF RETURN INTEGER (INPUT f AS CHARACTER) FORWARD.
FUNCTION getDate RETURNS INTEGER (INPUT dt AS DATE, INPUT tm AS INTEGER) FORWARD.
FUNCTION FileExists RETURNS LOGICAL (INPUT f AS CHARACTER) FORWARD.
FUNCTION createDir RETURNS LOGICAL (INPUT base AS CHARACTER, INPUT d AS CHARACTER) FORWARD.

/** Named streams */
DEFINE STREAM sParams.
DEFINE STREAM sFileset.

/** Parameters from ANT call */
DEFINE VARIABLE Filesets  AS CHARACTER  NO-UNDO.
DEFINE VARIABLE OutputDir AS CHARACTER  NO-UNDO.
DEFINE VARIABLE cDebug    AS LOGICAL    NO-UNDO.
DEFINE VARIABLE cWebObj   AS LOGICAL    NO-UNDO.
DEFINE VARIABLE cKeepMCT  AS LOGICAL    NO-UNDO.
DEFINE VARIABLE FailOnErr AS LOGICAL    NO-UNDO.
DEFINE VARIABLE ForceComp AS LOGICAL    NO-UNDO.
DEFINE VARIABLE cOptions  AS CHARACTER  NO-UNDO INITIAL '':U.

/** Internal use */
DEFINE VARIABLE CurrentFS AS CHARACTER  NO-UNDO.
DEFINE VARIABLE cLine     AS CHARACTER  NO-UNDO.
DEFINE VARIABLE cFileExt  AS CHARACTER  NO-UNDO.
DEFINE VARIABLE RCodeName AS CHARACTER  NO-UNDO.
DEFINE VARIABLE RCodeTS   AS INTEGER    NO-UNDO.
DEFINE VARIABLE ProcTS    AS INTEGER    NO-UNDO.
DEFINE VARIABLE Recompile AS LOGICAL    NO-UNDO.
DEFINE VARIABLE lComp     AS LOGICAL    NO-UNDO INITIAL TRUE.
DEFINE VARIABLE iCompOK   AS INTEGER    NO-UNDO INITIAL 0.
DEFINE VARIABLE iCompFail AS INTEGER    NO-UNDO.
/** Throw build exception ? */
DEFINE VARIABLE BuildExc  AS LOGICAL    NO-UNDO INITIAL FALSE.


/* Checks for valid parameters */
IF (SESSION:PARAMETER EQ ?) THEN
    RETURN '1'.
IF NOT FileExists(SESSION:PARAMETER) THEN
    RETURN '2'.
/* Reads config */
INPUT STREAM sParams FROM VALUE(FILE-INFO:FULL-PATHNAME).
REPEAT:
    IMPORT STREAM sParams UNFORMATTED cLine.
    IF (NUM-ENTRIES(cLine, '=':U) EQ 2) THEN
    CASE ENTRY(1, cLine, '=':U):
        WHEN 'FILESETS':U THEN
            ASSIGN Filesets = ENTRY(2, cLine, '=':U).
        WHEN 'OUTPUTDIR':U THEN
            ASSIGN OutputDir = ENTRY(2, cLine, '=':U).
        WHEN 'DEBUG':U THEN
            ASSIGN cDebug = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'WEBOBJECT':U THEN
            ASSIGN cWebObj = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'KEEPMCT':U THEN
            ASSIGN cKeepMCT = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'FAILONERROR':U THEN
            ASSIGN FailOnErr = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'FORCECOMPILE':U THEN
            ASSIGN ForceComp = (ENTRY(2, cLine, '=':U) EQ '1':U).
        OTHERWISE
            MESSAGE "Unknow parameter : " + cLine.
    END CASE.
END.
INPUT STREAM sParams CLOSE.

/* Checks if valid config */
IF NOT FileExists(Filesets) THEN
    RETURN '3'.
IF NOT FileExists(OutputDir) THEN
    RETURN '4'.

/* Creating options list */
ASSIGN cOptions = cOptions + (IF cOptions EQ '':U THEN '':U ELSE ',':U) + (IF cDebug THEN 'debug':U ELSE '':U).
ASSIGN cOptions = cOptions + (IF cOptions EQ '':U THEN '':U ELSE ',':U) + (IF cWebObj THEN 'web-object':U ELSE 'include':U).
ASSIGN cOptions = cOptions + (IF cOptions EQ '':U THEN '':U ELSE ',':U) + (IF cKeepMCT THEN 'keep-meta-content-type':U ELSE '':U).

{web/method/cgidefs.i NEW}

/* Parsing file list to compile */
INPUT STREAM sFileset FROM VALUE(Filesets).
CompLoop:
REPEAT:
    IMPORT STREAM sFileset UNFORMATTED cLine.
    IF (cLine BEGINS 'FILESET=':U) THEN
        /* This is a new fileset -- Changing base dir */
        ASSIGN CurrentFS = ENTRY(2, cLine, '=':U).
    ELSE DO:
        /* Checking .w file exists */
        RUN adecomm/_osfext.p(cLine, OUTPUT cFileExt).
        ASSIGN RCodeName = SUBSTRING(cLine, 1, R-INDEX(cLine, cFileExt) - 1) + (IF cWebObj THEN '.w':U ELSE '.i':U).
        ASSIGN RCodeTS = getTimeStampDF(OutputDir, RCodeName).
        Recompile = (RCodeTS EQ ?).
        IF (NOT Recompile) THEN DO:
            /* Checking .w timestamp is prior procedure timestamp */
            ASSIGN ProcTS = getTimeStampDF(CurrentFS, cLine).
            Recompile = (ProcTS GT RCodeTS).
        END.
        /* Selective compile */
        IF Recompile THEN DO:
            RUN PCTWSComp(CurrentFS, cLine, OutputDir, RCodeName, cOptions, OUTPUT lComp).
            IF (lComp) THEN DO:
                ASSIGN iCompOK = iCompOK + 1.
            END.
            ELSE DO:
                ASSIGN BuildExc  = TRUE
                       iCompFail = iCompFail + 1.
                IF FailOnErr THEN LEAVE CompLoop.
            END.
        END.
    END.
END.
INPUT STREAM sFileset CLOSE.
MESSAGE STRING(iCompOK) + " file(s) compiled".
IF (iCompFail GE 1) THEN
    MESSAGE "Failed to compile " iCompFail " file(s)".
RETURN (IF BuildExc THEN '10' ELSE '0').

PROCEDURE PCTWSComp.
    DEFINE INPUT  PARAMETER pcInDir   AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER pcInFile  AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER pcOutDir  AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER pcOutFile AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER pcOptions AS CHARACTER  NO-UNDO.
    DEFINE OUTPUT PARAMETER plOK      AS LOGICAL    NO-UNDO.
    
    DEFINE VARIABLE cBase    AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE cFile    AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE cOutFile AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE cRetVal  AS CHARACTER  NO-UNDO.
    
    RUN adecomm/_osprefx.p(INPUT pcInFile, OUTPUT cBase, OUTPUT cFile).
    ASSIGN plOK = createDir(pcOutDir, cBase).
    IF (NOT plOK) THEN RETURN.
    
    ASSIGN cOutFile = pcOutDir + '/':U + pcOutFile.
    RUN webutil/e4gl-gen.p(pcInDir + '/':U + pcInFile, INPUT-OUTPUT pcOptions, INPUT-OUTPUT cOutFile).
    ASSIGN cRetVal = RETURN-VALUE
           plOK    = (cRetVal EQ '':U).
    IF (NOT plOK) THEN DO:
        MESSAGE cRetVal.
    END.
    
END PROCEDURE.    
    
FUNCTION getTimeStampDF RETURNS INTEGER(INPUT d AS CHARACTER, INPUT f AS CHARACTER):
    RETURN getTimeStampF(d + '/':U + f).
END FUNCTION.

FUNCTION getTimeStampF RETURNS INTEGER(INPUT f AS CHARACTER):
    ASSIGN FILE-INFO:FILE-NAME = f.
    RETURN getDate(FILE-INFO:FILE-MOD-DATE, FILE-INFO:FILE-MOD-TIME).
END FUNCTION.

FUNCTION getDate RETURNS INTEGER (INPUT dt AS DATE, INPUT tm AS INTEGER):
    IF (dt EQ ?) OR (tm EQ ?) THEN RETURN ?.
    RETURN (INTEGER(dt) - INTEGER(DATE(1, 1, 1990))) * 86400 + tm.
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
            IF (OS-ERROR EQ 0) THEN DO:
                CREATE ttDirs.
                ASSIGN ttDirs.baseDir = base
                       ttDirs.dirName = c.
            END.
            ELSE DO:
                RETURN FALSE.
            END.
        END.
    END.
    RETURN TRUE.

END FUNCTION.