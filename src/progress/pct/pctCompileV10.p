/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) The Apache Software Foundation.  All rights
 * reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution, if
 *    any, must include the following acknowlegement:
 *       "This product includes software developed by the
 *        Apache Software Foundation (http://www.apache.org/)."
 *    Alternately, this acknowlegement may appear in the software itself,
 *    if and wherever such third-party acknowlegements normally appear.
 *
 * 4. The names "Ant" and "Apache Software
 *    Foundation" must not be used to endorse or promote products derived
 *    from this software without prior written permission. For written
 *    permission, please contact apache@apache.org.
 *
 * 5. Products derived from this software may not be called "Apache"
 *    nor may "Apache" appear in their names without prior written
 *    permission of the Apache Group.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE APACHE SOFTWARE FOUNDATION OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation.  For more
 * information on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 */

DEFINE TEMP-TABLE CRCList NO-UNDO
  FIELD ttTable AS CHARACTER
  FIELD ttCRC   AS CHARACTER
  INDEX ttCRC-PK IS PRIMARY UNIQUE ttTable.
DEFINE TEMP-TABLE TimeStamps NO-UNDO
  FIELD ttFile     AS CHARACTER CASE-SENSITIVE
  FIELD ttFullPath AS CHARACTER CASE-SENSITIVE
  FIELD ttMod      AS DATETIME
  INDEX PK-TimeStamps IS PRIMARY UNIQUE ttFile.
DEFINE TEMP-TABLE ttXref NO-UNDO
    FIELD xProcName   AS CHARACTER
    FIELD xFileName   AS CHARACTER
    FIELD xLineNumber AS CHARACTER
    FIELD xRefType    AS CHARACTER
    FIELD xObjID      AS CHARACTER FORMAT "X(50)"
    INDEX typ IS PRIMARY xRefType.
DEFINE TEMP-TABLE ttDirs NO-UNDO
    FIELD baseDir AS CHARACTER
    FIELD dirName AS CHARACTER.

FUNCTION getTimeStampDF RETURN DATETIME (INPUT d AS CHARACTER, INPUT f AS CHARACTER) FORWARD.
FUNCTION getTimeStampF RETURN DATETIME (INPUT f AS CHARACTER) FORWARD.
FUNCTION CheckIncludes RETURNS LOGICAL  (INPUT f AS CHARACTER, INPUT TS AS DATETIME, INPUT d AS CHARACTER) FORWARD.
FUNCTION CheckCRC RETURNS LOGICAL (INPUT f AS CHARACTER, INPUT d AS CHARACTER) FORWARD.
FUNCTION FileExists RETURNS LOGICAL (INPUT f AS CHARACTER) FORWARD.
FUNCTION createDir RETURNS LOGICAL (INPUT base AS CHARACTER, INPUT d AS CHARACTER) FORWARD.

/** Named streams */
DEFINE STREAM sXref.
DEFINE STREAM sParams.
DEFINE STREAM sFileset.
DEFINE STREAM sIncludes.
DEFINE STREAM sCRC.
/*DEFINE STREAM sPreProcess.*/

/** Parameters from ANT call */
DEFINE VARIABLE Filesets  AS CHARACTER  NO-UNDO.
DEFINE VARIABLE OutputDir AS CHARACTER  NO-UNDO.
DEFINE VARIABLE PCTDir    AS CHARACTER  NO-UNDO.
DEFINE VARIABLE MinSize   AS LOGICAL    NO-UNDO.
DEFINE VARIABLE MD5       AS LOGICAL    NO-UNDO.
DEFINE VARIABLE FailOnErr AS LOGICAL    NO-UNDO.
DEFINE VARIABLE ForceComp AS LOGICAL    NO-UNDO.
DEFINE VARIABLE NoComp    AS LOGICAL    NO-UNDO.
DEFINE VARIABLE RunList   AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE Lst       AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE PrePro    AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE DebugLst  AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE keepXref  AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE lXCode    AS LOGICAL    NO-UNDO.
DEFINE VARIABLE XCodeKey  AS CHARACTER  NO-UNDO INITIAL ?.
DEFINE VARIABLE Languages AS CHARACTER  NO-UNDO INITIAL ?.
DEFINE VARIABLE gwtFact   AS INTEGER    NO-UNDO INITIAL 100.

/** Internal use */
DEFINE VARIABLE CurrentFS AS CHARACTER  NO-UNDO.
DEFINE VARIABLE cLine     AS CHARACTER  NO-UNDO.
DEFINE VARIABLE cFileExt  AS CHARACTER  NO-UNDO.
DEFINE VARIABLE BaseName  AS CHARACTER  NO-UNDO.
DEFINE VARIABLE RCodeName AS CHARACTER  NO-UNDO.
DEFINE VARIABLE RCodeTS   AS DATETIME   NO-UNDO.
DEFINE VARIABLE ProcTS    AS DATETIME   NO-UNDO.
DEFINE VARIABLE Recompile AS LOGICAL    NO-UNDO.
DEFINE VARIABLE lComp     AS LOGICAL    NO-UNDO INITIAL TRUE.
DEFINE VARIABLE iCompOK   AS INTEGER    NO-UNDO INITIAL 0.
DEFINE VARIABLE iCompFail AS INTEGER    NO-UNDO.
/** Throw build exception ? */
DEFINE VARIABLE BuildExc  AS LOGICAL    NO-UNDO INITIAL FALSE.

compiler:multi-compile = true.
/* Gets CRC list */
DEFINE VARIABLE h AS HANDLE     NO-UNDO.
h = TEMP-TABLE CRCList:HANDLE.
RUN pct/pctCRC.p (INPUT-OUTPUT TABLE-HANDLE h) NO-ERROR.
IF (RETURN-VALUE NE '0') THEN
    RETURN RETURN-VALUE.

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
        WHEN 'PCTDIR':U THEN
            ASSIGN PCTDir = ENTRY(2, cLine, '=':U).
        WHEN 'MINSIZE':U THEN
            ASSIGN MinSize = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'MD5':U THEN
            ASSIGN MD5 = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'FAILONERROR':U THEN
            ASSIGN FailOnErr = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'FORCECOMPILE':U THEN
            ASSIGN ForceComp = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'XCODE':U THEN
            ASSIGN lXCode = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'XCODEKEY':U THEN
            ASSIGN XCodeKey = ENTRY(2, cLine, '=':U).
        WHEN 'NOCOMPILE':U THEN
            ASSIGN NoComp = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'RUNLIST':U THEN
            ASSIGN RunList = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'LISTING':U THEN
            ASSIGN Lst = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'PREPROCESS':U THEN
            ASSIGN PrePro = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'DEBUGLISTING':U THEN
            ASSIGN DebugLst = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'KEEPXREF':U THEN
            ASSIGN keepXref = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'LANGUAGES':U THEN
            ASSIGN languages = ENTRY(2, cLine, '=':U).
        WHEN 'GROWTH':U THEN
            ASSIGN gwtFact = INTEGER(ENTRY(2, cLine, '=':U)).
        OTHERWISE
            MESSAGE "Unknown parameter : " + cLine.
    END CASE.
END.
INPUT STREAM sParams CLOSE.

/* Checks if valid config */
IF NOT FileExists(Filesets) THEN
    RETURN '3'.
IF NOT FileExists(OutputDir) THEN
    RETURN '4'.
IF NOT FileExists(PCTDir) THEN
    ASSIGN PCTDir = OutputDir + '/.pct':U.

/* Parsing file list to compile */
INPUT STREAM sFileset FROM VALUE(Filesets).
CompLoop:
REPEAT:
    IMPORT STREAM sFileset UNFORMATTED cLine.
    IF (cLine BEGINS 'FILESET=':U) THEN
        /* This is a new fileset -- Changing base dir */
        ASSIGN CurrentFS = ENTRY(2, cLine, '=':U).
    ELSE DO:
        IF (ForceComp OR lXCode) THEN DO:
            ASSIGN Recompile = TRUE.
            IF NoComp THEN
                MESSAGE cLine + ' [':U + (IF ForceComp THEN 'COMPILATION FORCED' ELSE 'XCODE') + ']':U.
        END.
        ELSE DO:
            /* Checking .r file exists */
            RUN adecomm/_osfext.p(cLine, OUTPUT cFileExt).
            ASSIGN RCodeName = SUBSTRING(cLine, 1, R-INDEX(cLine, cFileExt) - 1) + '.r':U.
            ASSIGN RCodeTS = getTimeStampDF(OutputDir, RCodeName).
            Recompile = (RCodeTS EQ ?).
            IF Recompile AND NoComp THEN
                MESSAGE cLine + ' [NO RCODE]':U.
            IF (NOT Recompile) THEN DO:
                /* Checking .r timestamp is prior procedure timestamp */
                ASSIGN ProcTS = getTimeStampDF(CurrentFS, cLine).
                Recompile = (ProcTS GT RCodeTS).
                IF Recompile AND NoComp THEN
                    MESSAGE cLine + ' [OLD RCODE]':U.
                IF (NOT Recompile) THEN DO:
                    /* Checking included files */
                    Recompile = CheckIncludes(cLine, RCodeTS, PCTDir).
                    IF Recompile AND NoComp THEN
                        MESSAGE cLine + ' [INCLUDES]':U.
                    IF (NOT Recompile) THEN DO:
                        /* Checking CRC */
                        Recompile = CheckCRC(cLine, PCTDir).
                        IF Recompile AND NoComp THEN
                          MESSAGE cLine + ' [CRC]':U.
                        /* Compilation options should also be checked */
                        /* This is another story... */
                    END.
                END.
            END.
	    END.
	    /* Selective compile */
        IF (NOT NoComp) AND Recompile THEN DO:
            IF lXCode THEN
                RUN PCTCompileXCode(CurrentFS, cLine, OutputDir, XCodeKey, OUTPUT lComp).
            ELSE
                RUN PCTCompileXREF(CurrentFS, cLine, OutputDir, PCTDir, OUTPUT lComp).
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
OS-DELETE VALUE(SESSION:TEMP-DIRECTORY + '/PCTXREF':U).
INPUT STREAM sFileset CLOSE.
MESSAGE STRING(iCompOK) + " file(s) compiled".
IF (iCompFail GE 1) THEN
    MESSAGE "Failed to compile " iCompFail " file(s)".
RETURN (IF BuildExc THEN '10' ELSE '0').

FUNCTION CheckIncludes RETURNS LOGICAL (INPUT f AS CHARACTER, INPUT TS AS DATETIME, INPUT d AS CHARACTER).
    DEFINE VARIABLE IncFile     AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE IncFullPath AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE lReturn     AS LOGICAL    NO-UNDO INITIAL FALSE.

    /* Small workaround when compiling classes */
    FILE-INFO:FILE-NAME = d + '/':U + f + '.inc':U.
    IF FILE-INFO:FULL-PATHNAME EQ ? THEN DO:
      ASSIGN lReturn = TRUE.
      RETURN.
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
        END.
        IF (TimeStamps.ttFullPath NE IncFullPath) OR (TS LT TimeStamps.ttMod) THEN DO:
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

/** Compilation without XREF - Not used for the moment */
PROCEDURE PCTCompile.
    DEFINE INPUT  PARAMETER pcInDir   AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER pcInFile  AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER pcOutDir  AS CHARACTER  NO-UNDO.
    DEFINE OUTPUT PARAMETER plOK      AS LOGICAL    NO-UNDO.

    DEFINE VARIABLE i AS INTEGER    NO-UNDO.
    DEFINE VARIABLE c AS CHARACTER  NO-UNDO.

    COMPILE VALUE(pcInDir + pcInFile) SAVE INTO VALUE(pcOutDir) MIN-SIZE=MinSize GENERATE-MD5=MD5 NO-ERROR.
    ASSIGN plOK = COMPILER:ERROR.
    IF (NOT plOK) THEN DO:
        ASSIGN c = '':U.
        DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
            ASSIGN c = c + ERROR-STATUS:GET-MESSAGE(i) + '~n':U.
        END.
        RUN displayCompileErrors(SEARCH(pcInFile), INPUT COMPILER:FILE-NAME, INPUT COMPILER:ERROR-ROW, INPUT COMPILER:ERROR-COLUMN, INPUT c).
    END.

END PROCEDURE.

/** Compilation with Xref */
PROCEDURE PCTCompileXref.
    DEFINE INPUT  PARAMETER pcInDir   AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER pcInFile  AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER pcOutDir  AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER pcPCTDir  AS CHARACTER  NO-UNDO.
    DEFINE OUTPUT PARAMETER plOK      AS LOGICAL    NO-UNDO.

    DEFINE VARIABLE i     AS INTEGER    NO-UNDO.
    DEFINE VARIABLE cBase AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE cFile AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE cFileExt AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE c     AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE cSaveDir AS CHARACTER NO-UNDO.

    RUN adecomm/_osprefx.p(INPUT pcInFile, OUTPUT cBase, OUTPUT cFile).
    RUN adecomm/_osfext.p(INPUT cFile, OUTPUT cFileExt).
    ASSIGN plOK = createDir(pcOutDir, cBase).
    IF (NOT plOK) THEN RETURN.
    ASSIGN plOK = createDir(pcPCTDir, cBase).
    IF (NOT plOK) THEN RETURN.
    cSaveDir = IF cFileExt = ".cls" THEN pcOutDir ELSE pcOutDir + '/':U + cBase.
    COMPILE VALUE(pcInDir + '/':U + pcInFile) SAVE INTO VALUE(cSaveDir) LANGUAGES (VALUE(languages)) TEXT-SEG-GROW=gwtFact DEBUG-LIST VALUE((IF DebugLst THEN pcPCTDir + '/':U + cBase + '/':U + SUBSTRING(cFile, 1, R-INDEX(cFile, cFileExt) - 1) + '.dbg':U ELSE ?)) PREPROCESS VALUE((IF PrePro THEN pcPCTDir + '/':U + pcInFile + '.preprocess':U ELSE ?)) LISTING VALUE((IF Lst THEN pcPCTDir + '/':U + pcInFile ELSE ?)) MIN-SIZE=MinSize GENERATE-MD5=MD5 XREF VALUE(SESSION:TEMP-DIRECTORY + "/PCTXREF") APPEND=FALSE NO-ERROR.
    ASSIGN plOK = NOT COMPILER:ERROR.
    IF plOK THEN DO:
        RUN ImportXref (INPUT SESSION:TEMP-DIRECTORY + "/PCTXREF", INPUT pcPCTDir, INPUT pcInFile) NO-ERROR.
        /* Il faut verifier le code de retour */
        IF keepXref THEN
          OS-COPY VALUE(SESSION:TEMP-DIRECTORY + "/PCTXREF") VALUE(pcPCTDir + '/':U + pcInFile + '.xref':U).
    END.
    ELSE DO:
        ASSIGN c = '':U.
        DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
            ASSIGN c = c + ERROR-STATUS:GET-MESSAGE(i) + '~n':U.
        END.
        RUN displayCompileErrors(SEARCH(pcInDir + '/':U + pcInFile), INPUT SEARCH(COMPILER:FILE-NAME), INPUT COMPILER:ERROR-ROW, INPUT COMPILER:ERROR-COLUMN, INPUT c).
    END.

END PROCEDURE.

PROCEDURE displayCompileErrors.
    DEFINE INPUT  PARAMETER pcInit    AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER pcFile    AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER piRow     AS INTEGER    NO-UNDO.
    DEFINE INPUT  PARAMETER piColumn  AS INTEGER    NO-UNDO.
    DEFINE INPUT  PARAMETER pcMsg     AS CHARACTER  NO-UNDO.
    
    DEFINE VARIABLE i AS INTEGER    NO-UNDO INITIAL 1.
    DEFINE VARIABLE c AS CHARACTER  NO-UNDO.

    IF (pcInit EQ pcFile) THEN    
        MESSAGE "Error compiling file" pcInit "at line" STRING(piRow) "column" STRING(piColumn).
    ELSE
        MESSAGE "Error compiling file" pcInit "in included file" pcFile "at line" STRING(piRow) "column" STRING(piColumn).
    INPUT STREAM sXref FROM VALUE((IF pcInit EQ pcFile THEN pcInit ELSE pcFile)).
    DO WHILE (i LT piRow):
        IMPORT STREAM sXref UNFORMATTED c.
        ASSIGN i = i + 1.
    END.
    IMPORT STREAM sXref UNFORMATTED c.
    MESSAGE c.
    MESSAGE FILL('-':U, piColumn - 2) + '-^':U.
    MESSAGE pcMsg.
    MESSAGE '':U.
    
    INPUT STREAM sXref CLOSE.
    
END PROCEDURE.

PROCEDURE PCTCompileXCode.
    DEFINE INPUT  PARAMETER pcInDir    AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER pcInFile   AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER pcOutDir   AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER pcXCodeKey AS CHARACTER  NO-UNDO.
    DEFINE OUTPUT PARAMETER plOK       AS LOGICAL    NO-UNDO.

    DEFINE VARIABLE i     AS INTEGER    NO-UNDO.
    DEFINE VARIABLE cBase AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE cFile AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE c     AS CHARACTER  NO-UNDO.

    RUN adecomm/_osprefx.p(INPUT pcInFile, OUTPUT cBase, OUTPUT cFile).
    ASSIGN plOK = createDir(pcOutDir, cBase).
    IF (NOT plOK) THEN RETURN.
    IF (pcXCodeKey NE ?) THEN
        COMPILE VALUE(pcInDir + '/':U + pcInFile) SAVE INTO VALUE(pcOutDir + '/':U + cBase) MIN-SIZE=MinSize GENERATE-MD5=MD5 XCODE pcXCodeKey NO-ERROR.
    ELSE
        COMPILE VALUE(pcInDir + '/':U + pcInFile) SAVE INTO VALUE(pcOutDir + '/':U + cBase) MIN-SIZE=MinSize GENERATE-MD5=MD5 NO-ERROR.
    ASSIGN plOK = NOT COMPILER:ERROR.
    IF (NOT plOK) THEN DO:
        ASSIGN c = '':U.
        DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
            ASSIGN c = c + ERROR-STATUS:GET-MESSAGE(i) + '~n':U.
        END.
        RUN displayCompileErrors(SEARCH(pcInFile), INPUT COMPILER:FILE-NAME, INPUT COMPILER:ERROR-ROW, INPUT COMPILER:ERROR-COLUMN, INPUT c).
    END.

END PROCEDURE.

PROCEDURE importXref.
    DEFINE INPUT  PARAMETER pcXref AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER pcDir  AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER pcFile AS CHARACTER NO-UNDO.

    DEFINE VARIABLE cSearch AS CHARACTER  NO-UNDO.

    EMPTY TEMP-TABLE ttXref.

    INPUT STREAM sXREF FROM VALUE (pcXref).
    REPEAT:
        CREATE ttXref.
        IMPORT STREAM sXREF ttXref.
        IF (ttXref.xRefType EQ 'INCLUDE':U) OR (RunList AND (ttXref.xRefType EQ 'RUN':U)) THEN
            ttXref.xObjID = ENTRY(1, TRIM(ttXref.xObjID), ' ':U).
        ELSE IF (LOOKUP(ttXref.xRefType, 'CREATE,REFERENCE,ACCESS,UPDATE,SEARCH':U) EQ 0) THEN
            DELETE ttXref.
    END.
    DELETE ttXref. /* ttXref is non-undo'able */
    INPUT STREAM sXREF CLOSE.

    output to value(pcDir + '/':U + pcFile + '.zob':U).
    output close.
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

FUNCTION getTimeStampDF RETURNS DATETIME(INPUT d AS CHARACTER, INPUT f AS CHARACTER):
    RETURN getTimeStampF(d + '/':U + f).
END FUNCTION.

FUNCTION getTimeStampF RETURNS DATETIME(INPUT f AS CHARACTER):
    ASSIGN FILE-INFO:FILE-NAME = f.
    RETURN DATETIME(FILE-INFO:FILE-MOD-DATE, FILE-INFO:FILE-MOD-TIME * 1000).
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

    ASSIGN d = REPLACE(d, '~\':U, '/':U).
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
