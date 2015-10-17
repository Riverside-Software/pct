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
    FIELD dirName AS CHARACTER
    INDEX ttDirs-PK IS PRIMARY baseDir dirName.
DEFINE TEMP-TABLE ttXrefInc NO-UNDO
    FIELD ttIncName AS CHARACTER.
DEFINE TEMP-TABLE ttXrefCRC NO-UNDO
    FIELD ttTblName AS CHARACTER.
DEFINE TEMP-TABLE ttXrefClasses NO-UNDO
    FIELD ttClsName AS CHARACTER.
{ pct/v10/xrefd0003.i}

DEFINE SHARED VARIABLE pctVerbose AS LOGICAL NO-UNDO.

FUNCTION getTimeStampDF RETURN DATETIME (INPUT d AS CHARACTER, INPUT f AS CHARACTER) FORWARD.
FUNCTION getTimeStampF RETURN DATETIME (INPUT f AS CHARACTER) FORWARD.
FUNCTION CheckIncludes RETURNS LOGICAL  (INPUT f AS CHARACTER, INPUT TS AS DATETIME, INPUT d AS CHARACTER) FORWARD.
FUNCTION CheckCRC RETURNS LOGICAL (INPUT f AS CHARACTER, INPUT d AS CHARACTER) FORWARD.
FUNCTION FileExists RETURNS LOGICAL (INPUT f AS CHARACTER) FORWARD.
FUNCTION createDir RETURNS LOGICAL (INPUT base AS CHARACTER, INPUT d AS CHARACTER) FORWARD.

/** Named streams */
DEFINE STREAM sXref.
DEFINE STREAM sXref2.
DEFINE STREAM sParams.
DEFINE STREAM sFileset.
DEFINE STREAM sIncludes.
DEFINE STREAM sCRC.
DEFINE STREAM sDbgLst1.
DEFINE STREAM sDbgLst2.
DEFINE STREAM sWarnings.

/** Parameters from ANT call */
DEFINE VARIABLE Filesets  AS CHARACTER  NO-UNDO.
DEFINE VARIABLE OutputDir AS CHARACTER  NO-UNDO.
DEFINE VARIABLE PCTDir    AS CHARACTER  NO-UNDO.
DEFINE VARIABLE preprocessDir AS CHARACTER  NO-UNDO.
DEFINE VARIABLE dbgListDir AS CHARACTER NO-UNDO.
DEFINE VARIABLE flattenDbg AS LOGICAL   NO-UNDO.
DEFINE VARIABLE MinSize   AS LOGICAL    NO-UNDO.
DEFINE VARIABLE MD5       AS LOGICAL    NO-UNDO.
DEFINE VARIABLE FailOnErr AS LOGICAL    NO-UNDO.
DEFINE VARIABLE StopOnErr AS LOGICAL    NO-UNDO.
DEFINE VARIABLE ForceComp AS LOGICAL    NO-UNDO.
DEFINE VARIABLE NoComp    AS LOGICAL    NO-UNDO.
DEFINE VARIABLE NoParse   AS LOGICAL    NO-UNDO.
DEFINE VARIABLE StrXref   AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE AppStrXrf AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE SaveR     AS LOGICAL    NO-UNDO INITIAL TRUE.
DEFINE VARIABLE RunList   AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE Lst       AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE LstPrepro AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE PrePro    AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE DebugLst  AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE keepXref  AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE multiComp AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE streamIO  AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE lV6Frame  AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE lXmlXref  AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE lXCode    AS LOGICAL    NO-UNDO.
DEFINE VARIABLE XCodeKey  AS CHARACTER  NO-UNDO INITIAL ?.
DEFINE VARIABLE Languages AS CHARACTER  NO-UNDO INITIAL ?.
DEFINE VARIABLE gwtFact   AS INTEGER    NO-UNDO INITIAL -1.
DEFINE VARIABLE lRelative AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE lTwoPass  AS LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE twoPassID AS INTEGER    NO-UNDO.
DEFINE VARIABLE ProgPerc  AS INTEGER    NO-UNDO INITIAL 0.
DEFINE VARIABLE iLine     AS INTEGER    NO-UNDO.
DEFINE VARIABLE iTotlines AS INTEGER    NO-UNDO.
DEFINE VARIABLE iNrSteps  AS INTEGER    NO-UNDO.
DEFINE VARIABLE iStep     AS INTEGER    NO-UNDO.
DEFINE VARIABLE iStepPerc AS INTEGER    NO-UNDO.
DEFINE VARIABLE cDspSteps AS CHARACTER  NO-UNDO.

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
        WHEN 'STOPONERROR':U THEN
            ASSIGN StopOnErr = (ENTRY(2, cLine, '=':U) EQ '1':U).
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
        WHEN 'LISTINGSOURCE':U THEN
            ASSIGN LstPrepro = (ENTRY(2, cLine, '=':U) EQ 'PREPROCESSOR':U).
        WHEN 'PREPROCESS':U THEN
            ASSIGN PrePro = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'PREPROCESSDIR':U THEN
            ASSIGN preprocessDir = ENTRY(2, cLine, '=':U).
        WHEN 'DEBUGLISTING':U THEN
            ASSIGN DebugLst = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'DEBUGLISTINGDIR':U THEN
            ASSIGN dbgListDir = ENTRY(2, cLine, '=':U).
        WHEN 'FLATTENDBG':U THEN
            ASSIGN flattenDbg = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'STRINGXREF':U THEN
            ASSIGN StrXref = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'APPENDSTRINGXREF':U THEN
            ASSIGN AppStrXrf = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'SAVER':U THEN
            ASSIGN SaveR = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'KEEPXREF':U THEN
            ASSIGN keepXref = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'LANGUAGES':U THEN
            ASSIGN languages = ENTRY(2, cLine, '=':U).
        WHEN 'GROWTH':U THEN
            ASSIGN gwtFact = INTEGER(ENTRY(2, cLine, '=':U)).
        WHEN 'NOPARSE':U THEN
            ASSIGN noParse = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'MULTICOMPILE':U THEN
            ASSIGN multiComp = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'STREAM-IO':U THEN
            ASSIGN streamIO = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'V6FRAME':U THEN
            ASSIGN lV6Frame = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'RELATIVE':U THEN
            ASSIGN lRelative = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'PROGPERC':U THEN
            ASSIGN ProgPerc = INTEGER(ENTRY(2, cLine, '=':U)).
        WHEN 'TWOPASS':U THEN
            ASSIGN lTwoPass = (ENTRY(2, cLine, '=':U) EQ '1':U).
        WHEN 'TWOPASSID':U THEN
            ASSIGN twoPassID = INTEGER(ENTRY(2, cLine, '=':U)).
        WHEN 'NUMFILES':U THEN
            ASSIGN iTotLines = INTEGER(ENTRY(2, cLine, '=':U)).
        WHEN 'XMLXREF':U THEN
            ASSIGN lXmlXref = (ENTRY(2, cLine, '=':U) EQ '1':U).
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
IF debugLst AND (dbgListDir EQ '') THEN DO:
    ASSIGN dbgListDir = OutputDir + '/.dbg':U.
    createDir(outputDir, '.dbg':U).
END.
COMPILER:MULTI-COMPILE = multiComp.

IF ProgPerc GT 0 THEN DO:
  ASSIGN iNrSteps = 100 / ProgPerc.
  IF iNrSteps GT iTotLines THEN DO:
    ASSIGN iNrSteps = iTotLines
           ProgPerc = 100 / iNrSteps.
    /* MESSAGE "WARNING: Less files then percentage steps. Automatically increasing percentage to " + TRIM(STRING(ProgPerc,">>9%")). */
  END.  
  DO iStep = 1 TO iNrSteps:
    ASSIGN cDspSteps = cDspSteps
                     + (IF cDspSteps NE "" THEN "," ELSE "")
                     + STRING(MIN(INT((iTotLines / 100) * (ProgPerc * iStep)), iTotLines)).
  END.
  
END.

/* Parsing file list to compile */
INPUT STREAM sFileset FROM VALUE(Filesets).
CompLoop:
REPEAT:
    IMPORT STREAM sFileset UNFORMATTED cLine.
    IF (cLine BEGINS 'FILESET=':U) THEN DO:
        /* This is a new fileset -- Changing base dir */
        ASSIGN CurrentFS = ENTRY(2, cLine, '=':U).
        IF pctVerbose THEN MESSAGE SUBSTITUTE("Switching to fileset &1", currentFS).
    END.
    ELSE DO:
        /* output progress */
        IF ProgPerc GT 0 THEN DO:
          ASSIGN iLine = iLine + 1.
          IF LOOKUP(STRING(iLine),cDspSteps) GT 0
          THEN DO:
            ASSIGN iStepPerc = LOOKUP(STRING(iLine),cDspSteps) * ProgPerc.
            IF iStepPerc LT 100 THEN
              MESSAGE TRIM(STRING(iStepPerc,">>9%")) STRING(TIME,"HH:MM:SS") "Compiling " + cLine + " ...".
            ELSE
              MESSAGE STRING("100%") STRING(TIME,"HH:MM:SS").
          END.
          IF (iLine GE iTotLines) AND (iStepPerc LT 100) THEN DO:
            ASSIGN iStepPerc = 100.
            MESSAGE "100%" STRING(TIME,"HH:MM:SS").
          END.
        END.
      
        IF (noParse OR ForceComp OR lXCode) THEN DO:
            ASSIGN Recompile = TRUE.
            IF NoComp THEN
                MESSAGE cLine + ' [':U + (IF ForceComp THEN 'COMPILATION FORCED' ELSE 'XCODE') + ']':U.
        END.
        ELSE DO:
            /* Checking .r file exists */
            RUN adecomm/_osfext.p(cLine, OUTPUT cFileExt).
            ASSIGN RCodeName = SUBSTRING(cLine, 1, R-INDEX(cLine, cFileExt) - 1) + '.r':U.
            ASSIGN RCodeTS = getTimeStampDF(OutputDir, RCodeName).
            Recompile = (ltwoPass EQ TRUE).
            IF Recompile AND NoComp THEN
                MESSAGE cLine + ' [TWO PASS]'.
            IF (NOT Recompile) THEN DO:
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
        END.
        /* Selective compile */
        IF (NOT NoComp) AND Recompile THEN DO:
            IF lXCode THEN
                RUN PCTCompileXCode(CurrentFS, cLine, OutputDir, XCodeKey, OUTPUT lComp).
            ELSE IF noParse THEN
                RUN PCTCompile(CurrentFS, cLine, OutputDir, PCTDir, OUTPUT lComp).
            ELSE
                RUN PCTCompileXREF(CurrentFS, cLine, OutputDir, PCTDir, OUTPUT lComp).
            IF (lComp) THEN DO:
                ASSIGN iCompOK = iCompOK + 1.
            END.
            ELSE DO:
                ASSIGN BuildExc  = TRUE
                       iCompFail = iCompFail + 1.
                IF StopOnErr THEN LEAVE CompLoop.
            END.
        END.
    END.
END.

INPUT STREAM sFileset CLOSE.
MESSAGE STRING(iCompOK) + " file(s) compiled".
IF (iCompFail GE 1) THEN
    MESSAGE "Failed to compile " iCompFail " file(s)".
RETURN (IF BuildExc AND failOnErr THEN '10' ELSE '0').

FUNCTION CheckIncludes RETURNS LOGICAL (INPUT f AS CHARACTER, INPUT TS AS DATETIME, INPUT d AS CHARACTER).
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

    IF NOT fileExists(d + '/':U + f + '.crc':U) THEN RETURN TRUE.
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

PROCEDURE PCTCompile.
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
    DEFINE VARIABLE preprocessFile AS CHARACTER NO-UNDO.
    DEFINE VARIABLE debugListingFile AS CHARACTER NO-UNDO.

    IF (NOT fileExists(IF lRelative THEN pcInFile ELSE pcInDir + '/':U + pcInFile)) THEN DO:
      MESSAGE SUBSTITUTE("File [&1]/[&2] not found", pcInDir, pcInFile).
      ASSIGN plOK = FALSE.
      RETURN.    
    END.
    
    RUN adecomm/_osprefx.p(INPUT pcInFile, OUTPUT cBase, OUTPUT cFile).
    RUN adecomm/_osfext.p(INPUT cFile, OUTPUT cFileExt).
    ASSIGN plOK = createDir(pcOutDir, cBase).
    IF (NOT plOK) THEN RETURN.
    ASSIGN plOK = createDir(pcPCTDir, cBase).
    IF (NOT plOK) THEN RETURN.
    cSaveDir = IF cFileExt = ".cls" OR lRelative THEN pcOutDir ELSE pcOutDir + '/':U + cBase.

    IF PrePro THEN DO:
        IF preprocessDir = '' THEN
            ASSIGN preprocessFile = pcPCTDir + '/':U + pcInFile + '.preprocess':U.
        ELSE DO:
            ASSIGN preprocessFile = preprocessDir + '/':U + pcInFile.
            ASSIGN plOK = createDir(preprocessDir, cBase).
            IF (NOT plOK) THEN RETURN.
        END.
    END.
    ELSE
        ASSIGN preprocessFile = ?.
    IF debugLst AND NOT (cFile BEGINS '_') THEN DO:
        ASSIGN debugListingFile = REPLACE(REPLACE(pcInFile, '/', '_'), '~\', '_').
    END.
    ELSE
       ASSIGN debugListingFile = ?.

    IF pctVerbose THEN MESSAGE SUBSTITUTE("Compiling &1 IN DIRECTORY &2 TO &3", pcInFile, pcInDir, cSaveDir).
    COMPILE
      VALUE(IF lRelative THEN pcInFile ELSE pcInDir + '/':U + pcInFile)
      SAVE = SaveR INTO VALUE(cSaveDir)
      LANGUAGES (VALUE(languages)) TEXT-SEG-GROW=gwtFact
      STREAM-IO=streamIO
      V6FRAME=lV6Frame
      MIN-SIZE=MinSize
      GENERATE-MD5=MD5
      LISTING VALUE((IF Lst AND NOT LstPrepro THEN pcPCTDir + '/':U + pcInFile ELSE ?))
      DEBUG-LIST VALUE(debugListingFile)
      PREPROCESS VALUE(preprocessFile)
      NO-ERROR.
    ASSIGN plOK = NOT COMPILER:ERROR.
    IF NOT plOK THEN DO:
        ASSIGN c = '':U.
        DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
            ASSIGN c = c + ERROR-STATUS:GET-MESSAGE(i) + '~n':U.
        END.
        RUN displayCompileErrors(SEARCH(IF lRelative THEN pcInFile ELSE pcInDir + '/':U + pcInFile), INPUT SEARCH(COMPILER:FILE-NAME), INPUT COMPILER:ERROR-ROW, INPUT COMPILER:ERROR-COLUMN, INPUT c).
    END.
    IF (debugListingFile NE ?) THEN DO:
        OS-COPY VALUE(debugListingFile) VALUE(dbgListDir + '/':U + debugListingFile).
        OS-DELETE VALUE(debugListingFile).
    END.

END PROCEDURE.

/** Compilation with Xref */
PROCEDURE PCTCompileXref.
    DEFINE INPUT  PARAMETER pcInDir   AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER pcInFile  AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER pcOutDir  AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER pcPCTDir  AS CHARACTER  NO-UNDO.
    DEFINE OUTPUT PARAMETER plOK      AS LOGICAL    NO-UNDO.

    DEFINE VARIABLE i        AS INTEGER    NO-UNDO.
    DEFINE VARIABLE cBase    AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE cFile    AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE cFileExt AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE c        AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE cSaveDir AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cXrefFile AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE cStrXrefFile AS CHARACTER  NO-UNDO.    
    DEFINE VARIABLE preprocessFile AS CHARACTER NO-UNDO.
    DEFINE VARIABLE debugListingFile AS CHARACTER NO-UNDO.
    DEFINE VARIABLE warningsFile AS CHARACTER NO-UNDO.

    IF (NOT fileExists(IF lRelative THEN pcInFile ELSE pcInDir + '/':U + pcInFile)) THEN DO:
      MESSAGE SUBSTITUTE("File [&1]/[&2] not found", pcInDir, pcInFile).
      ASSIGN plOK = FALSE.
      RETURN.    
    END.
    
    RUN adecomm/_osprefx.p(INPUT pcInFile, OUTPUT cBase, OUTPUT cFile).
    RUN adecomm/_osfext.p(INPUT cFile, OUTPUT cFileExt).
    ASSIGN plOK = createDir(pcOutDir, cBase).
    IF (NOT plOK) THEN RETURN.
    ASSIGN plOK = createDir(pcPCTDir, cBase).
    IF (NOT plOK) THEN RETURN.
    cSaveDir = IF cFileExt = ".cls" OR lRelative THEN pcOutDir ELSE pcOutDir + '/':U + cBase.
    
    ASSIGN cXrefFile = pcPCTDir + '/':U + pcInFile + '.xref':U.
    ASSIGN warningsFile = pcPCTDir + '/':U + pcInFile + '.warnings':U.
    ASSIGN cStrXrefFile = (IF StrXref AND AppStrXrf
                           THEN pcPCTDir + '/strings.xref':U
                           ELSE (IF StrXref
                                 THEN pcPCTDir + '/':U + pcInFile + '.strxref'
                                 ELSE ?)).    
    
    IF PrePro THEN DO:
        IF preprocessDir = '' THEN
            ASSIGN preprocessFile = pcPCTDir + '/':U + pcInFile + '.preprocess':U.
        ELSE DO:
            ASSIGN preprocessFile = preprocessDir + '/':U + pcInFile.
            ASSIGN plOK = createDir(preprocessDir, cBase).
            IF (NOT plOK) THEN RETURN.
        END.
    END.
    ELSE
        ASSIGN preprocessFile = ?.
    IF debugLst AND NOT (cFile BEGINS '_') THEN DO:
        IF flattenDbg THEN
            ASSIGN debugListingFile = dbgListDir + '/' + REPLACE(REPLACE(pcInFile, '/', '_'), '~\', '_').
        ELSE DO:
            ASSIGN debugListingFile = pcInFile.
            ASSIGN debugListingFile = dbgListDir + '/' + debugListingFile.
            ASSIGN plOK = createDir(dbgListDir, cBase).
            IF (NOT plOK) THEN RETURN.
        END.
    END.
    ELSE
       ASSIGN debugListingFile = ?.

    IF lTwoPass THEN DO:
        IF pctVerbose THEN MESSAGE SUBSTITUTE("First pass - Generating preprocessed file for &1", pcInFile).
        COMPILE VALUE(IF lRelative THEN pcInFile ELSE pcInDir + '/':U + pcInFile) PREPROCESS VALUE(pcInDir + '/' + pcInFile + '.preprocess':U).
        OS-RENAME VALUE(pcInDir + '/':U + pcInFile) VALUE(pcInDir + '/':U + pcInFile + '.backup':U).
        OS-RENAME VALUE(pcInDir + '/':U + pcInFile + '.preprocess':U) VALUE(pcInDir + '/':U + pcInFile).
    END.

    IF pctVerbose THEN MESSAGE SUBSTITUTE("Compiling &1 in directory &2 TO &3", pcInFile, pcInDir, cSaveDir).
    IF (languages EQ ?) THEN DO:
      IF lXmlXref THEN
        COMPILE
          VALUE(IF lRelative THEN pcInFile ELSE pcInDir + '/':U + pcInFile)
          SAVE = SaveR INTO VALUE(cSaveDir)
          STREAM-IO=streamIO
          V6FRAME=lV6Frame
          LISTING VALUE((IF Lst AND NOT LstPrepro THEN pcPCTDir + '/':U + pcInFile ELSE ?))
          DEBUG-LIST VALUE(debugListingFile)
          PREPROCESS VALUE(preprocessFile) 
          MIN-SIZE=MinSize
          GENERATE-MD5=MD5
          STRING-XREF VALUE(cStrXrefFile) APPEND = AppStrXrf
          XREF-XML VALUE(cXrefFile)
          NO-ERROR.
      ELSE
        COMPILE
          VALUE(IF lRelative THEN pcInFile ELSE pcInDir + '/':U + pcInFile)
          SAVE = SaveR INTO VALUE(cSaveDir)
          STREAM-IO=streamIO
          V6FRAME=lV6Frame
          LISTING VALUE((IF Lst AND NOT LstPrepro THEN pcPCTDir + '/':U + pcInFile ELSE ?))
          DEBUG-LIST VALUE(debugListingFile)
          PREPROCESS VALUE(preprocessFile) 
          MIN-SIZE=MinSize
          GENERATE-MD5=MD5
          STRING-XREF VALUE(cStrXrefFile) APPEND = AppStrXrf
          XREF VALUE(cXrefFile) APPEND=FALSE
          NO-ERROR.
    END.
    ELSE DO:
      IF (gwtFact GE 0) THEN DO:
        IF lXmlXref THEN
          COMPILE
            VALUE(IF lRelative THEN pcInFile ELSE pcInDir + '/':U + pcInFile)
            SAVE = SaveR INTO VALUE(pcOutDir)
            LANGUAGES (VALUE(languages)) TEXT-SEG-GROW=gwtFact
            STREAM-IO=streamIO
            V6FRAME=lV6Frame
            LISTING VALUE((IF Lst AND NOT LstPrepro THEN pcPCTDir + '/':U + pcInFile ELSE ?))
            DEBUG-LIST VALUE(debugListingFile)
            PREPROCESS VALUE(preprocessFile)
            MIN-SIZE=MinSize
            GENERATE-MD5=MD5
            STRING-XREF VALUE(cStrXrefFile) APPEND = AppStrXrf
            XREF-XML VALUE(cXrefFile)
            NO-ERROR.
        ELSE
          COMPILE
            VALUE(IF lRelative THEN pcInFile ELSE pcInDir + '/':U + pcInFile)
            SAVE = SaveR INTO VALUE(pcOutDir)
            LANGUAGES (VALUE(languages)) TEXT-SEG-GROW=gwtFact
            STREAM-IO=streamIO
            V6FRAME=lV6Frame
            LISTING VALUE((IF Lst AND NOT LstPrepro THEN pcPCTDir + '/':U + pcInFile ELSE ?))
            DEBUG-LIST VALUE(debugListingFile)
            PREPROCESS VALUE(preprocessFile)
            MIN-SIZE=MinSize
            GENERATE-MD5=MD5
            STRING-XREF VALUE(cStrXrefFile) APPEND = AppStrXrf
            XREF VALUE(cXrefFile) APPEND=FALSE
            NO-ERROR.
      END.
      ELSE DO:
        IF lXmlXref THEN
          COMPILE
            VALUE(IF lRelative THEN pcInFile ELSE pcInDir + '/':U + pcInFile)
            SAVE = SaveR INTO VALUE(pcOutDir)
            LANGUAGES (VALUE(languages))
            STREAM-IO=streamIO
            V6FRAME=lV6Frame
            LISTING VALUE((IF Lst AND NOT LstPrepro THEN pcPCTDir + '/':U + pcInFile ELSE ?))
            DEBUG-LIST VALUE(debugListingFile)
            PREPROCESS VALUE(preprocessFile)
            MIN-SIZE=MinSize
            GENERATE-MD5=MD5
            STRING-XREF VALUE(cStrXrefFile) APPEND = AppStrXrf
            XREF-XML VALUE(cXrefFile)
            NO-ERROR.
        ELSE
          COMPILE
            VALUE(IF lRelative THEN pcInFile ELSE pcInDir + '/':U + pcInFile)
            SAVE = SaveR INTO VALUE(pcOutDir)
            LANGUAGES (VALUE(languages))
            STREAM-IO=streamIO
            V6FRAME=lV6Frame
            LISTING VALUE((IF Lst AND NOT LstPrepro THEN pcPCTDir + '/':U + pcInFile ELSE ?))
            DEBUG-LIST VALUE(debugListingFile)
            PREPROCESS VALUE(preprocessFile)
            MIN-SIZE=MinSize
            GENERATE-MD5=MD5
            STRING-XREF VALUE(cStrXrefFile) APPEND = AppStrXrf
            XREF VALUE(cXrefFile) APPEND=FALSE
            NO-ERROR.
      END.
    END.

    ASSIGN plOK = NOT COMPILER:ERROR.
    IF plOK THEN DO:
        IF lXmlXref THEN
        	RUN ImportXmlXref (INPUT cXrefFile, INPUT pcPCTDir, INPUT pcInFile) NO-ERROR.
        ELSE
        	RUN ImportXref (INPUT cXrefFile, INPUT pcPCTDir, INPUT pcInFile) NO-ERROR.
        /* Il faut verifier le code de retour */
        IF NOT keepXref THEN
          OS-DELETE VALUE(cXrefFile).
        IF COMPILER:WARNING THEN DO:
          OUTPUT STREAM sWarnings TO VALUE(warningsFile).
          DO i = 1 TO COMPILER:NUM-MESSAGES:
            IF (COMPILER:GET-MESSAGE-TYPE(i) EQ 2) THEN DO:
              PUT STREAM sWarnings UNFORMATTED SUBSTITUTE("[&1] [&3] &2", COMPILER:GET-ROW(i), COMPILER:GET-MESSAGE(i), COMPILER:GET-FILE-NAME(i)) SKIP.
            END.
          END.
          OUTPUT STREAM sWarnings CLOSE.
        END.
    END.
    ELSE DO:
        ASSIGN c = '':U.
        DO i = 1 TO COMPILER:NUM-MESSAGES:
            ASSIGN c = c + COMPILER:GET-MESSAGE(i) + '~n':U.
        END.
        RUN displayCompileErrors(SEARCH(IF lRelative THEN pcInFile ELSE pcInDir + '/':U + pcInFile), INPUT SEARCH(COMPILER:FILE-NAME), INPUT COMPILER:ERROR-ROW, INPUT COMPILER:ERROR-COLUMN, INPUT c).
    END.
    IF lTwoPass THEN DO:
        OS-DELETE VALUE(pcInDir + '/':U + pcInFile) .
        OS-RENAME VALUE(pcInDir + '/':U + pcInFile + '.backup':U) VALUE(pcInDir + '/':U + pcInFile) .
    END.
    IF (plOK AND lst AND lstPrepro AND (preprocessFile NE ?)) THEN DO:
        COMPILE VALUE(preprocessFile) SAVE=NO LISTING VALUE(pcPCTDir + '/':U + pcInFile) NO-ERROR.
        IF ERROR-STATUS:ERROR THEN DO:
            OS-DELETE VALUE(pcPCTDir + '/':U + pcInFile).
        END.
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
    DEFINE VARIABLE bit AS INTEGER NO-UNDO.
    DEFINE VARIABLE memvar AS MEMPTR NO-UNDO.
    
    /* Checking if file is xcoded */
    COPY-LOB FROM FILE (IF pcInit EQ pcFile THEN pcInit ELSE pcFile) FOR 1 TO memvar.
    bit = GET-BYTE (memvar,1).
    SET-SIZE(memvar)= 0.

    IF (pcInit EQ pcFile) THEN    
        MESSAGE "Error compiling file" pcInit "at line" STRING(piRow) "column" STRING(piColumn).
    ELSE
        MESSAGE "Error compiling file" pcInit "in included file" pcFile "at line" STRING(piRow) "column" STRING(piColumn).
  
    IF (bit NE 17) AND (bit NE 19) THEN DO:
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
   END.
   ELSE
        MESSAGE SUBSTITUTE(">> Can't display xcoded source &1", (IF pcInit EQ pcFile THEN pcInit ELSE pcFile)).
  
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
        COMPILE VALUE(pcInDir + '/':U + pcInFile) SAVE INTO VALUE(pcOutDir + '/':U + cBase) STREAM-IO=streamIO V6FRAME=lV6Frame MIN-SIZE=MinSize GENERATE-MD5=MD5 XCODE pcXCodeKey NO-ERROR.
    ELSE
        COMPILE VALUE(pcInDir + '/':U + pcInFile) SAVE INTO VALUE(pcOutDir + '/':U + cBase) STREAM-IO=streamIO V6FRAME=lV6Frame MIN-SIZE=MinSize GENERATE-MD5=MD5 NO-ERROR.
    ASSIGN plOK = NOT COMPILER:ERROR.
    IF (NOT plOK) THEN DO:
        ASSIGN c = '':U.
        DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
            ASSIGN c = c + ERROR-STATUS:GET-MESSAGE(i) + '~n':U.
        END.
        RUN displayCompileErrors(SEARCH(pcInDir + '/':U + pcInFile), INPUT SEARCH(COMPILER:FILE-NAME), INPUT COMPILER:ERROR-ROW, INPUT COMPILER:ERROR-COLUMN, INPUT c).
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
        ASSIGN ttXrefInc.ttIncName = SUBSTRING(Reference.Object-identifier, 1, INDEX(Reference.Object-identifier, ' ') - 1).
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

PROCEDURE importXref.
    DEFINE INPUT  PARAMETER pcXref AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER pcDir  AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER pcFile AS CHARACTER NO-UNDO.

    DEFINE VARIABLE cSearch AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE cTmp AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cTmp2 AS CHARACTER NO-UNDO.
    DEFINE VARIABLE zz AS INTEGER NO-UNDO.

    EMPTY TEMP-TABLE ttXref.

    INPUT STREAM sXREF FROM VALUE (pcXref).
    INPUT STREAM sXREF2 FROM VALUE (pcXref).
    REPEAT:
        CREATE ttXref.
        IMPORT STREAM sXREF ttXref.

        /* Sorry, this is crude... */
        IMPORT STREAM sXREF2 UNFORMATTED cTmp.
        /* GC Bug #47 - Lines longer than 2000 characters are truncated. This IMPORT is there to synchronize both streams. */
        IF LENGTH (cTmp) >= 2000 THEN
          IMPORT STREAM sXREF UNFORMATTED cTmp2.

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

FUNCTION getTimeStampDF RETURNS DATETIME(INPUT d AS CHARACTER, INPUT f AS CHARACTER):
    RETURN getTimeStampF(d + (IF d EQ '':U THEN '':U ELSE '/':U) + f).
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
