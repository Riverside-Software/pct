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

DEFINE TEMP-TABLE ttIncExc NO-UNDO
  FIELD order AS INTEGER
  FIELD inc   AS LOGICAL
  FIELD pattern AS CHARACTER
  INDEX ttIncExc IS PRIMARY UNIQUE order ASCENDING.

DEFINE VARIABLE i          AS INTEGER    NO-UNDO.
DEFINE VARIABLE bFile      AS HANDLE     NO-UNDO.
DEFINE VARIABLE qry        AS HANDLE     NO-UNDO.
DEFINE VARIABLE bfFileName AS HANDLE     NO-UNDO.
DEFINE VARIABLE lInc       AS LOGICAL    NO-UNDO.

OUTPUT TO VALUE(ENTRY(1, SESSION:PARAMETER, ':':U)).

DO i = 2 TO NUM-ENTRIES(SESSION:PARAMETER, ':':U):
  CREATE ttIncExc.
  ASSIGN ttIncExc.order = i
         ttIncExc.inc   = (ENTRY(1, ENTRY(i, SESSION:PARAMETER, ':':U), '$':U) EQ 'I':U)
         ttIncExc.pattern = ENTRY(2, ENTRY(i, SESSION:PARAMETER, ':':U), '$':U).
END.

DO i = 1 TO NUM-DBS:
  IF DBTYPE(i) NE "PROGRESS":U THEN NEXT.
  CREATE BUFFER bFile FOR TABLE LDBNAME(i) + '._file'.
  CREATE QUERY qry.
  qry:SET-BUFFERS(bFile).
  ASSIGN bfFileName = bFile:BUFFER-FIELD('_file-name':U).
  qry:QUERY-PREPARE('FOR EACH _file WHERE _File._File-Number GT 0 AND NOT (_File._File-Name BEGINS "SYS")').
  qry:QUERY-OPEN().
  REPEAT:
    qry:GET-NEXT(NO-LOCK).
    IF qry:QUERY-OFF-END THEN LEAVE.
    ASSIGN lInc = TRUE.
    FOR EACH ttIncExc NO-LOCK BY order:
      IF (lInc EQ TRUE) AND (ttIncExc.inc EQ FALSE) THEN DO:
        ASSIGN lInc = (bfFileName:BUFFER-VALUE MATCHES ttIncExc.pattern).
      END.
      ELSE IF (lInc EQ FALSE) AND (ttIncExc.inc EQ TRUE) THEN DO:
        ASSIGN lInc = (bfFileName:BUFFER-VALUE MATCHES ttIncExc.pattern).
      END.
    END.
    IF (lInc EQ TRUE) THEN
      PUT UNFORMATTED bfFileName:BUFFER-VALUE SKIP.
  END.
  qry:QUERY-CLOSE().
  DELETE OBJECT bfFileName.
  DELETE OBJECT qry.
  DELETE OBJECT bFile.
END.
OUTPUT CLOSE.
RETURN '0'.
