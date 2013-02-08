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

DEFINE VARIABLE hQuery  AS HANDLE    NO-UNDO.
DEFINE VARIABLE hBuffer AS HANDLE    NO-UNDO.
DEFINE TEMP-TABLE ttUnfrozen NO-UNDO
   FIELD cTable AS CHARACTER.

/*
 * Parameters from ANT call 
 */
DEFINE VARIABLE cFileList AS CHARACTER NO-UNDO.
DEFINE VARIABLE cFile     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lUnfreeze AS LOGICAL   NO-UNDO.
DEFINE VARIABLE lCommit   AS LOGICAL   NO-UNDO.
DEFINE VARIABLE lOnline   AS LOGICAL   NO-UNDO.
DEFINE VARIABLE lErr      AS LOGICAL   NO-UNDO INITIAL FALSE.
DEFINE VARIABLE iErrors   AS INTEGER   NO-UNDO.
DEFINE VARIABLE iWarnings AS INTEGER   NO-UNDO.
DEFINE VARIABLE cLine     AS CHARACTER NO-UNDO.
DEFINE VARIABLE cLogFile  AS CHARACTER NO-UNDO.

DEFINE STREAM sLogFile.

ASSIGN cFileList = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'fileList')
       lUnfreeze = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'unfreeze') EQ "true":U
       lCommit   = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'commitWhenErrors') EQ "true":U
       lOnline   = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'online') EQ "true":U.

/** Added by Evan Todd */
IF lUnfreeze THEN DO:
   CREATE BUFFER hBuffer FOR TABLE "_file".
   CREATE QUERY hQuery.
   hQuery:SET-BUFFERS(hBuffer).
   hQuery:QUERY-PREPARE("for each _file where _file-number > 0 " +
                        "and _File-Number < 32768 " +
                        "and _frozen = yes").
   hQuery:QUERY-OPEN.
   hQuery:GET-FIRST().
   DO TRANSACTION WHILE NOT hQuery:QUERY-OFF-END:
      hQuery:GET-CURRENT(EXCLUSIVE-LOCK).
      CREATE ttUnfrozen.
      ASSIGN ttUnfrozen.cTable = hBuffer:BUFFER-FIELD("_file-name"):BUFFER-VALUE
             hBuffer:BUFFER-FIELD("_frozen"):BUFFER-VALUE = FALSE.
      hQuery:GET-NEXT.
   END.
   hQuery:QUERY-CLOSE.   
end.

&IF INTEGER(SUBSTRING(PROVERSION, 1, INDEX(PROVERSION, '.'))) GE 10 &THEN
IF lOnline THEN
  SESSION:SCHEMA-CHANGE = 'NEW OBJECTS'.
&ENDIF

INPUT FROM VALUE(cFileList).
RptLoop:
REPEAT:
  IMPORT UNFORMATTED cFile.

  /* Clears existing error files */
  FILE-INFO:FILE-NAME = LDBNAME("DICTDB") + ".e".
  IF FILE-INFO:FULL-PATHNAME NE ? THEN DO:
    OS-DELETE VALUE(FILE-INFO:FULL-PATHNAME).
  END.

  MESSAGE 'Loading ' + cFile + ' in database'.
  RUN prodict/load_df.p (INPUT cFile + ',' + STRING(lCommit, 'yes/no')) NO-ERROR.

  /* If file is present, then there are errors or warnings during load */
  FILE-INFO:FILE-NAME = LDBNAME("DICTDB") + ".e".
  IF (FILE-INFO:FULL-PATHNAME NE ?) THEN DO:
    ASSIGN iWarnings = 0 iErrors = 0.
    INPUT STREAM sLogFile FROM VALUE(FILE-INFO:FULL-PATHNAME).
    REPEAT:
      IMPORT STREAM sLogFile UNFORMATTED cLine.
      IF (cLine BEGINS '** Error') THEN ASSIGN iErrors = iErrors + 1.
      ELSE IF (LENGTH(cLine) GE 25) AND (cLine BEGINS '** ') AND (SUBSTRING(cLine, LENGTH(cLine) - 19) EQ ' caused a warning **') THEN ASSIGN iWarnings = iWarnings + 1.
    END.
    INPUT STREAM sLogFile CLOSE.
    ASSIGN cLogFile = FILE-INFO:FULL-PATHNAME + "." + STRING(TODAY, "99999999") + "." + STRING(TIME) + "." + STRING(ETIME(FALSE)).
    OS-RENAME VALUE(FILE-INFO:FULL-PATHNAME) VALUE(cLogFile).
    MESSAGE SUBSTITUTE('&1 errors and &2 warnings during load', iErrors, iWarnings).
    MESSAGE 'Log file can be found in ' + cLogFile.
    IF (iErrors GT 0) THEN DO:
      lErr = TRUE.
      IF NOT lCommit THEN LEAVE RptLoop.
    END.
  END.
END.
INPUT CLOSE.

IF lUnfreeze THEN DO:
   FOR EACH ttUnfrozen:
      hQuery:QUERY-PREPARE("for each _file where _file-name = '" + ttUnfrozen.cTable + "'").
      hQuery:QUERY-OPEN.
      hQuery:GET-FIRST.
      IF NOT hQuery:QUERY-OFF-END THEN DO TRANSACTION:
         hQuery:GET-CURRENT(EXCLUSIVE-LOCK).
         hBuffer:BUFFER-FIELD("_frozen"):BUFFER-VALUE = TRUE.
      END.
      hQuery:QUERY-CLOSE.
   END.
   DELETE OBJECT hQuery.
   DELETE OBJECT hBuffer.
END.

IF lErr AND NOT lCommit THEN RETURN '1'.
RETURN '0'.