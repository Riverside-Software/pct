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
 
DEFINE INPUT-OUTPUT PARAMETER TABLE-HANDLE hCRC.

DEFINE VARIABLE i       AS INTEGER    NO-UNDO.
DEFINE VARIABLE h_file  AS HANDLE     NO-UNDO.
DEFINE VARIABLE hQuery  AS HANDLE     NO-UNDO.
DEFINE VARIABLE hQuery2 AS HANDLE     NO-UNDO.
DEFINE VARIABLE hBuffer AS HANDLE     NO-UNDO.
DEFINE VARIABLE hCRCTab AS HANDLE     NO-UNDO.
DEFINE VARIABLE hCRCVal AS HANDLE     NO-UNDO.
DEFINE VARIABLE hFld1   AS HANDLE     NO-UNDO.
DEFINE VARIABLE hFld2   AS HANDLE     NO-UNDO.

IF (hCRC EQ ?) THEN RETURN '1'.
ASSIGN hBuffer = hCRC:DEFAULT-BUFFER-HANDLE
       hCRCTab = hBuffer:BUFFER-FIELD('ttTable')
       hCRCVal = hBuffer:BUFFER-FIELD('ttCRC').
DO i = 1 TO NUM-DBS:
  CREATE BUFFER h_File FOR TABLE LDBNAME(i) + '._file'.
  CREATE QUERY hQuery.
  hQuery:SET-BUFFERS(h_File).
  ASSIGN hFld1 = h_File:BUFFER-FIELD('_file-name':U)
         hFld2 = h_File:BUFFER-FIELD('_crc':U).
  hQuery:QUERY-PREPARE('FOR EACH _file WHERE _File._File-Number GT 0 AND NOT (_File._File-Name BEGINS "SYS")').
  hQuery:QUERY-OPEN().
  REPEAT:
    hQuery:GET-NEXT().
    IF hQuery:QUERY-OFF-END THEN LEAVE.
    hBuffer:BUFFER-CREATE().
    ASSIGN hCRCTab:BUFFER-VALUE = LDBNAME(i) + "." + hFld1:BUFFER-VALUE
           hCRCVal:BUFFER-VALUE = hFld2:BUFFER-VALUE.
    hBuffer:BUFFER-RELEASE().
  END.
  hQuery:QUERY-CLOSE().
  DELETE OBJECT hFld1.
  DELETE OBJECT hFld2.
  DELETE OBJECT hQuery.
  DELETE OBJECT h_File.
END.
DELETE OBJECT hCRCTab.
DELETE OBJECT hCRCVal.
DELETE OBJECT hCRC.
RETURN '0'.
