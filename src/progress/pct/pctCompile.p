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

DEFINE SHARED VARIABLE pctVerbose AS LOGICAL NO-UNDO.

DEFINE VARIABLE hComp AS HANDLE NO-UNDO.

RUN pct/compile.p PERSISTENT SET hComp.

/** Parameters from ANT call */
DEFINE VARIABLE Filesets  AS CHARACTER  NO-UNDO.
DEFINE VARIABLE StopOnErr AS LOGICAL    NO-UNDO.

/** Internal use */
DEFINE VARIABLE CurrentFS AS CHARACTER  NO-UNDO.
DEFINE VARIABLE cLine     AS CHARACTER  NO-UNDO.
DEFINE VARIABLE lErr      AS LOGICAL    NO-UNDO INITIAL TRUE.
DEFINE VARIABLE iMyComp   AS INTEGER    NO-UNDO INITIAL 0.
DEFINE VARIABLE iCompOK   AS INTEGER    NO-UNDO INITIAL 0.
DEFINE VARIABLE iCompFail AS INTEGER    NO-UNDO.

DEFINE STREAM sParams.
DEFINE STREAM sFileset.

FUNCTION fileExists RETURNS LOGICAL (INPUT f AS CHARACTER):
    ASSIGN FILE-INFO:FILE-NAME = f.
    RETURN (FILE-INFO:FULL-PATHNAME NE ?).
END FUNCTION.

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
    WHEN 'STOPONERROR':U THEN
      ASSIGN StopOnErr = (ENTRY(2, cLine, '=':U) EQ '1':U).
    OTHERWISE
      RUN setOption IN hComp (ENTRY(1, cLine, '=':U), ENTRY(2, cLine, '=':U)).
  END CASE.
END.
INPUT STREAM sParams CLOSE.

/* Checks if valid config */
IF NOT FileExists(Filesets) THEN
  RETURN '3'.

RUN initModule IN hComp.

/* Parsing file list to compile */
INPUT STREAM sFileset FROM VALUE(Filesets).
CompLoop:
REPEAT:
  IMPORT STREAM sFileset UNFORMATTED cLine.
  IF (cLine BEGINS 'FILESET=':U) THEN DO:
    /* This is a new fileset -- Changing base dir */
    ASSIGN CurrentFS = ENTRY(2, cLine, '=':U).
    RUN logVerbose (SUBSTITUTE("Switching to fileset &1", currentFS)).
  END.
  ELSE DO:
    RUN compileXref IN hComp (INPUT currentFS, INPUT cLine, INPUT ?, OUTPUT lErr, OUTPUT iMyComp).
    IF (lErr) THEN DO:
      ASSIGN iCompFail = iCompFail + 1.
      IF StopOnErr THEN LEAVE CompLoop.
    END.
    ELSE IF (iMyComp GT 0) THEN
      ASSIGN iCompOK = iCompOK + 1.
  END.
END.
INPUT STREAM sFileset CLOSE.

RUN printErrorsWarningsJson IN hComp.

MESSAGE STRING(iCompOK) + " file(s) compiled".
IF (iCompFail GE 1) THEN
  MESSAGE "Failed to compile " iCompFail " file(s)".
RETURN (IF iCompFail GT 0 THEN '10' ELSE '0').

PROCEDURE logError.
  DEFINE INPUT PARAMETER ipMsg AS CHARACTER NO-UNDO.

  MESSAGE ipMsg.

END PROCEDURE.

PROCEDURE logWarning.
  DEFINE INPUT PARAMETER ipMsg AS CHARACTER NO-UNDO.

  MESSAGE ipMsg.

END PROCEDURE.

PROCEDURE logInfo.
  DEFINE INPUT PARAMETER ipMsg AS CHARACTER NO-UNDO.

  MESSAGE ipMsg.

END PROCEDURE.

PROCEDURE logVerbose.
  DEFINE INPUT PARAMETER ipMsg AS CHARACTER NO-UNDO.

  IF pctVerbose THEN MESSAGE ipMsg.

END PROCEDURE.

PROCEDURE logDebug.
  DEFINE INPUT PARAMETER ipMsg AS CHARACTER NO-UNDO.

  IF pctVerbose THEN MESSAGE ipMsg.

END PROCEDURE.
