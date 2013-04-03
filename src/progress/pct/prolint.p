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

DEFINE TEMP-TABLE ttLintFiles NO-UNDO
  FIELD SourceFile AS CHARACTER.

FUNCTION FileExists RETURNS LOGICAL (INPUT f AS CHARACTER) FORWARD.

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
DEFINE VARIABLE FailOnErr AS LOGICAL    NO-UNDO.

/** Internal use */
DEFINE VARIABLE CurrentFS AS CHARACTER  NO-UNDO.
DEFINE VARIABLE cLine     AS CHARACTER  NO-UNDO.
DEFINE VARIABLE cFileExt  AS CHARACTER  NO-UNDO.
DEFINE VARIABLE BaseName  AS CHARACTER  NO-UNDO.
DEFINE VARIABLE RCodeName AS CHARACTER  NO-UNDO.
DEFINE VARIABLE RCodeTS   AS INTEGER    NO-UNDO.
DEFINE VARIABLE ProcTS    AS INTEGER    NO-UNDO.
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
        OTHERWISE
            MESSAGE "Unknown parameter : " + cLine.
    END CASE.
END.
INPUT STREAM sParams CLOSE.

/* Checks if valid config */
IF NOT FileExists(Filesets) THEN
    RETURN '3'.

/* Parsing file list to compile */
INPUT STREAM sFileset FROM VALUE(Filesets).
CompLoop:
REPEAT:
    IMPORT STREAM sFileset UNFORMATTED cLine.
    IF (cLine BEGINS 'FILESET=':U) THEN
        /* This is a new fileset -- Changing base dir */
        ASSIGN CurrentFS = ENTRY(2, cLine, '=':U).
    ELSE DO:
        CREATE ttLintFiles.
        ASSIGN ttLintFiles.SourceFile = CurrentFS + CHR(0x5C) + cLine.
    END.
END.

RUN prolint/core/prolint.p (INPUT ?, TEMP-TABLE ttLintFiles:HANDLE, 'pct', true).

RETURN (IF BuildExc THEN '10' ELSE '0').

FUNCTION fileExists RETURNS LOGICAL (INPUT f AS CHARACTER):
    ASSIGN FILE-INFO:FILE-NAME = f.
    RETURN (FILE-INFO:FULL-PATHNAME NE ?).
END FUNCTION.
