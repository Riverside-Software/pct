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

USING Progress.Lang.Class.

DEFINE VARIABLE hQuery  AS HANDLE    NO-UNDO.
DEFINE VARIABLE hBuffer AS HANDLE    NO-UNDO.
DEFINE TEMP-TABLE ttUnfrozen NO-UNDO
   FIELD cTable AS CHARACTER.

DEFINE VARIABLE cFileList AS CHARACTER NO-UNDO.
DEFINE VARIABLE lUnfreeze AS LOGICAL   NO-UNDO.
DEFINE VARIABLE lCommit   AS LOGICAL   NO-UNDO.
DEFINE VARIABLE lOnline   AS LOGICAL   NO-UNDO.
DEFINE VARIABLE lInactIdx AS LOGICAL   NO-UNDO.

DEFINE VARIABLE cFile       AS CHARACTER NO-UNDO.
DEFINE VARIABLE callbackCls AS CHARACTER NO-UNDO.
define variable analyzerCls as character no-undo.
DEFINE VARIABLE callback    AS rssw.pct.ILoadCallback NO-UNDO.
define variable analyzer    as OpenEdge.DataAdmin.Binding.IDataDefinitionLoader.
DEFINE VARIABLE logger      AS rssw.pct.LoadLogger  NO-UNDO.
DEFINE VARIABLE dictOpts    AS rssw.pct.LoadOptions NO-UNDO.
DEFINE VARIABLE dictOpts2   AS OpenEdge.DataAdmin.Binding.DataDefinitionOptions NO-UNDO.
DEFINE VARIABLE cLogFile  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lErr      AS LOGICAL   NO-UNDO INITIAL FALSE.

DEFINE STREAM sLogFile.

ASSIGN callbackCls = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'callbackClass')
       analyzerCls = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'analyzerClass')
       cFileList = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'fileList')
       lUnfreeze = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'unfreeze') EQ "true":U
       lCommit   = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'commitWhenErrors') EQ "true":U
       lOnline   = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'online') EQ "true":U
       lInactIdx = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'inactiveIdx') EQ "true":U.

IF (callbackCls > "") THEN DO:
    callback = CAST(Class:GetClass(callbackCls):new(), rssw.pct.ILoadCallback).
END.
IF (analyzerCls > "") THEN DO:
    analyzer = CAST(Class:GetClass(analyzerCls):new(), OpenEdge.DataAdmin.Binding.IDataDefinitionLoader).
end.

IF VALID-OBJECT(callback) THEN
  callback:beforeUnfreeze().

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
END.

IF VALID-OBJECT(callback) THEN
  callback:beforeFileList().

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

  ASSIGN logger = NEW rssw.pct.LoadLogger().
  ASSIGN dictOpts = NEW rssw.pct.LoadOptions(logger).
  ASSIGN dictOpts:FileName = cFile
         dictOpts:ForceCommit = lCommit
         dictOpts:SchemaChange = (IF lOnline THEN 'NEW OBJECTS' ELSE '')
         dictOpts:ForceIndexDeactivate = lInactIdx.
  IF VALID-OBJECT(analyzer) THEN DO:
    ASSIGN dictOpts2 = NEW rssw.pct.LoadOptions(analyzer).
    ASSIGN dictOpts2:FileName = cFile
           dictOpts2:ForceCommit = lCommit
           dictOpts2:SchemaChange = (IF lOnline THEN 'NEW OBJECTS' ELSE '')
           dictOpts2:ForceIndexDeactivate = lInactIdx.
  END.

  IF VALID-OBJECT(callback) THEN
    callback:beforeFile(cFile).
  DO ON ERROR UNDO, LEAVE:
    RUN prodict/dump/_load_df.p (dictOpts).
    IF VALID-OBJECT(dictOpts2) THEN
      RUN prodict/dump/_load_df.p (dictOpts2).

    FINALLY:
      /* If file is present, then there are errors or warnings during load */
      FILE-INFO:FILE-NAME = LDBNAME("DICTDB") + ".e".
      IF (FILE-INFO:FULL-PATHNAME NE ?) THEN DO:
        ASSIGN cLogFile = FILE-INFO:FULL-PATHNAME + "." + STRING(TODAY, "99999999") + "." + STRING(TIME) + "." + STRING(ETIME(FALSE)).
        OS-RENAME VALUE(FILE-INFO:FULL-PATHNAME) VALUE(cLogFile).
        MESSAGE SUBSTITUTE('&1 errors and &2 warnings during load', logger:numErrors, logger:numWarnings).
        MESSAGE 'Log file can be found in ' + cLogFile.
      END.
      IF VALID-OBJECT(callback) THEN
        callback:afterFile(cFile, logger).

      IF (logger:numErrors GT 0) THEN DO:
        lErr = TRUE.
        IF NOT lCommit THEN LEAVE RptLoop.
      END.

    END FINALLY.
  END. 
  

  DELETE OBJECT logger.
  DELETE OBJECT dictOpts.
END.
INPUT CLOSE.

IF VALID-OBJECT(callback) THEN
  callback:afterFileList().

IF VALID-OBJECT(callback) THEN
  callback:beforeRefreeze().
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
IF VALID-OBJECT(callback) THEN
  callback:afterRefreeze().

IF lErr AND NOT lCommit THEN RETURN '1'.
RETURN '0'.
