/*
  Base documenter - generates HTML documentation of databases.
  BaseDocPers.p 2001 by Gilles QUERRET
*/

/* 
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) 2002 The Apache Software Foundation.  All rights
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

/* Handles for table _File */
DEFINE VARIABLE hFile      AS HANDLE     NO-UNDO.
DEFINE VARIABLE hBFile     AS HANDLE     NO-UNDO.
DEFINE VARIABLE hDump      AS HANDLE     NO-UNDO.
DEFINE VARIABLE hTable     AS HANDLE     NO-UNDO.
DEFINE VARIABLE hTableDesc AS HANDLE     NO-UNDO.
DEFINE VARIABLE hPrime     AS HANDLE     NO-UNDO.
/* Handles for table _Field */
DEFINE VARIABLE hField     AS HANDLE     NO-UNDO.
DEFINE VARIABLE hBField    AS HANDLE     NO-UNDO.
DEFINE VARIABLE hOrder     AS HANDLE     NO-UNDO.
DEFINE VARIABLE hFieldName AS HANDLE     NO-UNDO.
DEFINE VARIABLE hDataType  AS HANDLE     NO-UNDO.
DEFINE VARIABLE hMandatory AS HANDLE     NO-UNDO.
DEFINE VARIABLE hFormat    AS HANDLE     NO-UNDO.
DEFINE VARIABLE hExtent    AS HANDLE     NO-UNDO.
DEFINE VARIABLE hInitial   AS HANDLE     NO-UNDO.
DEFINE VARIABLE hLabel     AS HANDLE     NO-UNDO.
DEFINE VARIABLE hFieldDesc AS HANDLE     NO-UNDO.
/* Handles for table _Index */
DEFINE VARIABLE hIndex     AS HANDLE     NO-UNDO.
DEFINE VARIABLE hBIndex    AS HANDLE     NO-UNDO.
DEFINE VARIABLE hIndexName AS HANDLE     NO-UNDO.
DEFINE VARIABLE hActive    AS HANDLE     NO-UNDO.
DEFINE VARIABLE hIndexDesc AS HANDLE     NO-UNDO.
DEFINE VARIABLE hUnique    AS HANDLE     NO-UNDO.
/* Handles for table _File-Trig */
DEFINE VARIABLE hTrig      AS HANDLE     NO-UNDO.
DEFINE VARIABLE hBTrig     AS HANDLE     NO-UNDO.
DEFINE VARIABLE hEvent     AS HANDLE     NO-UNDO.
DEFINE VARIABLE hProc      AS HANDLE     NO-UNDO.
DEFINE VARIABLE hOverride  AS HANDLE     NO-UNDO.
/* Handles for table _Index_Field */
DEFINE VARIABLE hIdxField   AS HANDLE     NO-UNDO.
DEFINE VARIABLE hBIdxField  AS HANDLE     NO-UNDO.
DEFINE VARIABLE hFieldRecID AS HANDLE     NO-UNDO.
/* Handles for XML nodes */
DEFINE VARIABLE xRoot       AS HANDLE     NO-UNDO.
DEFINE VARIABLE xTables     AS HANDLE     NO-UNDO.
DEFINE VARIABLE xTable      AS HANDLE     NO-UNDO.
DEFINE VARIABLE xField      AS HANDLE     NO-UNDO.
DEFINE VARIABLE xIndex      AS HANDLE     NO-UNDO.
DEFINE VARIABLE xIndexFld   AS HANDLE     NO-UNDO.
DEFINE VARIABLE xTrigger    AS HANDLE     NO-UNDO.
DEFINE VARIABLE xText       AS HANDLE     NO-UNDO.

DEFINE VARIABLE cQuery AS CHARACTER  NO-UNDO.

/* XML Init */
CREATE X-DOCUMENT xRoot.
xRoot:ENCODING = "UTF-8":U.

CREATE X-NODEREF xTables.
CREATE X-NODEREF xTable.
CREATE X-NODEREF xField.
CREATE X-NODEREF xIndex.
CREATE X-NODEREF xIndexFld.
CREATE X-NODEREF xTrigger.
CREATE X-NODEREF xText.

xRoot:CREATE-NODE(xTables, 'TABLES':U, 'ELEMENT':U).
xRoot:APPEND-CHILD(xTables).

/* Creating queries */
CREATE QUERY hFile.
CREATE QUERY hField.
CREATE QUERY hIndex.
CREATE QUERY hTrig.
CREATE QUERY hIdxField.

/* Creating buffers */
CREATE BUFFER hBFile  FOR TABLE '_File'.
CREATE BUFFER hBField FOR TABLE '_Field'.
CREATE BUFFER hBIndex FOR TABLE '_Index'.
CREATE BUFFER hBTrig  FOR TABLE '_File-Trig'.
CREATE BUFFER hBIdxField FOR TABLE '_Index-Field'.

/* Assigning buffers */
hFile:SET-BUFFERS (hBFile).
hField:SET-BUFFERS (hBField).
hIndex:SET-BUFFERS (hBIndex).
hTrig:SET-BUFFERS (hBTrig).
hIdxField:SET-BUFFERS (hBIdxField).

/* Getting buffer fields */
ASSIGN hDump      = hBFile:BUFFER-FIELD ('_Dump-Name')
       hTable     = hBFile:BUFFER-FIELD ('_File-Name')
       hTableDesc = hBFile:BUFFER-FIELD ('_Desc')
       hPrime     = hBFile:BUFFER-FIELD ('_Prime-Index')
       hOrder     = hBField:BUFFER-FIELD ('_Order')
       hFieldName = hBField:BUFFER-FIELD ('_Field-Name')
       hDataType  = hBField:BUFFER-FIELD ('_Data-Type')
       hMandatory = hBField:BUFFER-FIELD ('_Mandatory')
       hFormat    = hBField:BUFFER-FIELD ('_Format')
       hExtent    = hBField:BUFFER-FIELD ('_Extent')
       hInitial   = hBField:BUFFER-FIELD ('_Initial')
       hLabel     = hBField:BUFFER-FIELD ('_Label')
       hFieldDesc = hBField:BUFFER-FIELD ('_Desc')
       hEvent     = hBTrig:BUFFER-FIELD ('_Event')
       hProc      = hBTrig:BUFFER-FIELD ('_Proc-Name')
       hOverride  = hBTrig:BUFFER-FIELD ('_Override')
       hIndexName = hBIndex:BUFFER-FIELD ('_Index-Name')
       hUnique    = hBIndex:BUFFER-FIELD ('_Unique')
       hActive    = hBIndex:BUFFER-FIELD ('_Active')
       hIndexDesc = hBIndex:BUFFER-FIELD ('_Desc')
       hFieldRecID = hBIdxField:BUFFER-FIELD ('_Field-recid').
hFile:QUERY-PREPARE ('FOR EACH _File WHERE _File._File-Number GT 0 AND NOT (_File._File-Name BEGINS "SYS") BY _File._File-Name').
hFile:QUERY-OPEN.
hFile:GET-FIRST.
REPEAT:
    IF hFile:QUERY-OFF-END THEN LEAVE.
    xRoot:CREATE-NODE(xTable, 'TABLE':U, 'ELEMENT':U).
    xTables:APPEND-CHILD(xTable).
    xTable:SET-ATTRIBUTE('DumpName', (IF hDump:BUFFER-VALUE EQ ? THEN hTable:BUFFER-VALUE ELSE hDump:BUFFER-VALUE)).
    xTable:SET-ATTRIBUTE('Name', hTable:BUFFER-VALUE).
    IF (hTableDesc:BUFFER-VALUE NE ?) THEN DO:
        xRoot:CREATE-NODE(xText, '':U, 'TEXT':U).
        xText:NODE-VALUE = hTableDesc:BUFFER-VALUE.
        xTable:APPEND-CHILD(xText).
    END.
    
    ASSIGN cQuery = 'FOR EACH _Field WHERE _Field._File-recid = '
           cQuery = cQuery + STRING (hBFile:RECID) + ' BY _Field._Order'.
    hField:QUERY-PREPARE(cQuery).
    hField:QUERY-OPEN().
    hField:GET-FIRST(NO-LOCK).
    REPEAT:
        IF hField:QUERY-OFF-END THEN LEAVE.
        xRoot:CREATE-NODE(xField, 'FIELD':U, 'ELEMENT':U).
        xTable:APPEND-CHILD(xField).
        xField:SET-ATTRIBUTE('Name':U, hFieldName:BUFFER-VALUE).
        xField:SET-ATTRIBUTE('Order':U, STRING(hOrder:BUFFER-VALUE)).
        xField:SET-ATTRIBUTE('DataType':U, hDataType:BUFFER-VALUE).
        xField:SET-ATTRIBUTE('Mandatory':U, STRING (hMandatory:BUFFER-VALUE)).
        xField:SET-ATTRIBUTE('Format':U, STRING (hFormat:BUFFER-VALUE)).
        xField:SET-ATTRIBUTE('Extent':U, STRING (hExtent:BUFFER-VALUE)).
        xField:SET-ATTRIBUTE('InitialValue':U, (IF hInitial:BUFFER-VALUE EQ ? THEN '?':U ELSE STRING (hInitial:BUFFER-VALUE))).
        xField:SET-ATTRIBUTE('Label':U, (IF hLabel:BUFFER-VALUE EQ ? THEN '?':U ELSE STRING (hLabel:BUFFER-VALUE))).
        IF (hFieldDesc:BUFFER-VALUE NE ?) THEN DO:
            xRoot:CREATE-NODE(xText, '':U, 'TEXT':U).
            xText:NODE-VALUE = hFieldDesc:BUFFER-VALUE.
            xField:APPEND-CHILD(xText).
        END.
        hField:GET-NEXT(NO-LOCK).
    END.
    hField:QUERY-CLOSE().
    
    ASSIGN cQuery = 'FOR EACH _File-Trig WHERE _File-Trig._File-recid = ' + STRING (hBFile:RECID).
    hTrig:QUERY-PREPARE(cQuery).
    hTrig:QUERY-OPEN().
    hTrig:GET-FIRST(NO-LOCK).
    REPEAT:
        IF hTrig:QUERY-OFF-END THEN LEAVE.
        xRoot:CREATE-NODE(xTrigger, 'TRIGGER':U, 'ELEMENT':U).
        xTable:APPEND-CHILD(xTrigger).
        xTrigger:SET-ATTRIBUTE('Event':U, hEvent:BUFFER-VALUE).
        xTrigger:SET-ATTRIBUTE('Procedure':U, hProc:BUFFER-VALUE).
        xTrigger:SET-ATTRIBUTE('Overridable':U, hOverride:BUFFER-VALUE).
        hTrig:GET-NEXT(NO-LOCK).
    END.
    hTrig:QUERY-CLOSE().
            
    /* Tableau HTML contenant la description des index de la table PROGRESS*/
    ASSIGN cQuery = 'FOR EACH _Index WHERE _Index._File-recid EQ ' + STRING (hBFile:RECID) + ' BY _Index._Unique DESCENDING BY _Index._Index-Name'.
    hIndex:QUERY-PREPARE (cQuery).
    hIndex:QUERY-OPEN().
    hIndex:GET-FIRST(NO-LOCK).
    REPEAT:
        IF hIndex:QUERY-OFF-END THEN LEAVE.
        xRoot:CREATE-NODE(xIndex, 'INDEX', 'ELEMENT':U).
        xTable:APPEND-CHILD(xIndex).
        xIndex:SET-ATTRIBUTE('Name':U, hIndexName:BUFFER-VALUE).
        xIndex:SET-ATTRIBUTE('Primary':U, (IF (hPrime:BUFFER-VALUE EQ hBIndex:RECID) THEN 'True':U ELSE 'False')).
        xIndex:SET-ATTRIBUTE('Unique':U, (IF hUnique:BUFFER-VALUE THEN 'True':U ELSE 'False')).
        xIndex:SET-ATTRIBUTE('Active':U, (IF hActive:BUFFER-VALUE THEN 'True':U ELSE 'False')).
        IF (hIndexDesc:BUFFER-VALUE NE ?) THEN DO:
            xRoot:CREATE-NODE(xText, '':U, 'TEXT':U).
            xText:NODE-VALUE = hIndexDesc:BUFFER-VALUE.
            xIndex:APPEND-CHILD(xText).
        END.
        
        ASSIGN cQuery = 'FOR EACH _Index-Field WHERE _Index-Field._Index-recid EQ ' + STRING (hBIndex:RECID).
        hIdxField:QUERY-PREPARE (cQuery).
        hIdxField:QUERY-OPEN().
        hIdxField:GET-FIRST(NO-LOCK).
        REPEAT:
            IF hIdxField:QUERY-OFF-END THEN LEAVE.
            xRoot:CREATE-NODE(xIndexFld, 'INDEX-FIELD':U, 'ELEMENT':U).
            xIndex:APPEND-CHILD(xIndexFld).
            ASSIGN cQuery = 'FOR EACH _Field WHERE RECID (_Field) EQ ' + STRING (hFieldRecID:BUFFER-VALUE).
            hField:QUERY-PREPARE (cQuery).
            hField:QUERY-OPEN().
            hField:GET-FIRST(NO-LOCK).
            IF (NOT hField:QUERY-OFF-END) THEN DO:
                xIndexFld:SET-ATTRIBUTE('Name':U, hFieldName:BUFFER-VALUE).
            END.
            hField:QUERY-CLOSE().
            hIdxField:GET-NEXT (NO-LOCK).
        END.
        hIdxField:QUERY-CLOSE().
        hIndex:GET-NEXT (NO-LOCK).
    END.
    hIndex:QUERY-CLOSE().
    hFile:GET-NEXT (NO-LOCK).
END.
hFile:QUERY-CLOSE().

/* Freeing up memory */
/* Starting with buffer field handles */
DELETE OBJECT hDump.
DELETE OBJECT hTable.
DELETE OBJECT hTableDesc.
DELETE OBJECT hPrime.
DELETE OBJECT hOrder.
DELETE OBJECT hFieldName.
DELETE OBJECT hDataType.
DELETE OBJECT hMandatory.
DELETE OBJECT hFormat.
DELETE OBJECT hExtent.
DELETE OBJECT hInitial.
DELETE OBJECT hLabel.
DELETE OBJECT hFieldDesc.
DELETE OBJECT hEvent.
DELETE OBJECT hProc.
DELETE OBJECT hOverride.
DELETE OBJECT hIndexName.
DELETE OBJECT hUnique.
DELETE OBJECT hActive.
DELETE OBJECT hIndexDesc.
DELETE OBJECT hFieldRecID.
/* Continue with buffer handles */
DELETE OBJECT hBFile.
DELETE OBJECT hBField.
DELETE OBJECT hBIndex.
DELETE OBJECT hBTrig.
DELETE OBJECT hBIdxField.
/* And ends up with query handles */
DELETE OBJECT hFile.
DELETE OBJECT hField.
DELETE OBJECT hIndex.
DELETE OBJECT hTrig.
DELETE OBJECT hIdxField.

xRoot:SAVE("FILE":U, SESSION:PARAMETER).

DELETE OBJECT xRoot.
DELETE OBJECT xTables.
DELETE OBJECT xTable.
DELETE OBJECT xField.
DELETE OBJECT xIndex.
DELETE OBJECT xIndexFld.
DELETE OBJECT xTrigger.
DELETE OBJECT xText.

RETURN '0'.