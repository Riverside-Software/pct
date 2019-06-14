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

DEFINE OUTPUT PARAMETER pmXML AS MEMPTR NO-UNDO.

/* Handles for table _Database */
DEFINE VARIABLE qDatabase  AS HANDLE     NO-UNDO.
DEFINE VARIABLE bDatabase  AS HANDLE     NO-UNDO.
/* Handles for table _Db */
DEFINE VARIABLE qDB        AS HANDLE     NO-UNDO.
DEFINE VARIABLE bDB        AS HANDLE     NO-UNDO.
DEFINE VARIABLE hCodepage  AS HANDLE     NO-UNDO.
DEFINE VARIABLE hCollation AS HANDLE     NO-UNDO.
/* Handles for table _File */
DEFINE VARIABLE hFile      AS HANDLE     NO-UNDO.
DEFINE VARIABLE hBFile     AS HANDLE     NO-UNDO.
DEFINE VARIABLE hDump      AS HANDLE     NO-UNDO.
DEFINE VARIABLE hTable     AS HANDLE     NO-UNDO.
DEFINE VARIABLE hTableDesc AS HANDLE     NO-UNDO.
DEFINE VARIABLE hPrime     AS HANDLE     NO-UNDO.
DEFINE VARIABLE bfFileNum  AS HANDLE     NO-UNDO.
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
DEFINE VARIABLE hColLabel  AS HANDLE     NO-UNDO.
DEFINE VARIABLE hCaseSens  AS HANDLE     NO-UNDO.
DEFINE VARIABLE hDecimals  AS HANDLE     NO-UNDO.
DEFINE VARIABLE hFieldDesc AS HANDLE     NO-UNDO.
DEFINE VARIABLE hValexp    AS HANDLE     NO-UNDO.
DEFINE VARIABLE hValmsg    AS HANDLE     NO-UNDO.
DEFINE VARIABLE hHelp      AS HANDLE     NO-UNDO.
/* Handles for table _Index */
DEFINE VARIABLE hIndex     AS HANDLE     NO-UNDO.
DEFINE VARIABLE hBIndex    AS HANDLE     NO-UNDO.
DEFINE VARIABLE hIndexName AS HANDLE     NO-UNDO.
DEFINE VARIABLE hActive    AS HANDLE     NO-UNDO.
DEFINE VARIABLE hIndexDesc AS HANDLE     NO-UNDO.
DEFINE VARIABLE hUnique    AS HANDLE     NO-UNDO.
DEFINE VARIABLE bfIdxNum   AS HANDLE     NO-UNDO.
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
/* Handles for table _Area */
DEFINE VARIABLE qArea      AS HANDLE     NO-UNDO.
DEFINE VARIABLE bArea      AS HANDLE     NO-UNDO.
/* Handles for table _StorageObject */
DEFINE VARIABLE qStorage   AS HANDLE     NO-UNDO.
DEFINE VARIABLE bStorage   AS HANDLE     NO-UNDO.
/* Handles for table _Sequence */
DEFINE VARIABLE qSequence   AS HANDLE     NO-UNDO.
DEFINE VARIABLE bSequence   AS HANDLE     NO-UNDO.

/* Handles for XML nodes */
DEFINE VARIABLE xRoot       AS HANDLE     NO-UNDO.
DEFINE VARIABLE xDB         AS HANDLE     NO-UNDO.
DEFINE VARIABLE xTable      AS HANDLE     NO-UNDO.
DEFINE VARIABLE xField      AS HANDLE     NO-UNDO.
DEFINE VARIABLE xIndex      AS HANDLE     NO-UNDO.
DEFINE VARIABLE xIndexFld   AS HANDLE     NO-UNDO.
DEFINE VARIABLE xTrigger    AS HANDLE     NO-UNDO.
DEFINE VARIABLE xText       AS HANDLE     NO-UNDO.
DEFINE VARIABLE xArea       AS HANDLE     NO-UNDO.
DEFINE VARIABLE xSequence   AS HANDLE     NO-UNDO.

DEFINE VARIABLE cQuery AS CHARACTER  NO-UNDO.

/* XML Init */
CREATE X-DOCUMENT xRoot.
xRoot:ENCODING = "UTF-8":U.

CREATE X-NODEREF xDB.
CREATE X-NODEREF xTable.
CREATE X-NODEREF xField.
CREATE X-NODEREF xIndex.
CREATE X-NODEREF xIndexFld.
CREATE X-NODEREF xTrigger.
CREATE X-NODEREF xText.
CREATE X-NODEREF xArea.
CREATE X-NODEREF xSequence.

xRoot:CREATE-NODE(xDB, 'database':U, 'ELEMENT':U).
xRoot:APPEND-CHILD(xDB).

/* Creating queries */
CREATE QUERY qDatabase.
CREATE QUERY qDB.
CREATE QUERY hFile.
CREATE QUERY hField.
CREATE QUERY hIndex.
CREATE QUERY hTrig.
CREATE QUERY hIdxField.
CREATE QUERY qArea.
CREATE QUERY qStorage.
CREATE QUERY qSequence.

/* Creating buffers */
CREATE BUFFER bDatabase FOR TABLE '_DbStatus':U.
CREATE BUFFER bDB       FOR TABLE '_Db':U.
CREATE BUFFER hBFile     FOR TABLE '_File':U.
CREATE BUFFER hBField    FOR TABLE '_Field':U.
CREATE BUFFER hBIndex    FOR TABLE '_Index':U.
CREATE BUFFER hBTrig     FOR TABLE '_File-Trig':U.
CREATE BUFFER hBIdxField FOR TABLE '_Index-Field':U.
CREATE BUFFER bArea      FOR TABLE '_Area':U.
CREATE BUFFER bStorage   FOR TABLE '_StorageObject':U.
CREATE BUFFER bSequence  FOR TABLE '_Sequence':U.

/* Assigning buffers */
qDatabase:SET-BUFFERS(bDatabase).
qDB:SET-BUFFERS(bDB).
hFile:SET-BUFFERS(hBFile).
hField:SET-BUFFERS(hBField).
hIndex:SET-BUFFERS(hBIndex).
hTrig:SET-BUFFERS(hBTrig).
hIdxField:SET-BUFFERS(hBIdxField).
qArea:SET-BUFFERS(bArea).
qStorage:SET-BUFFERS(bStorage).
qSequence:SET-BUFFERS(bSequence).

/* Getting buffer fields -- 9.1C compatibility */
ASSIGN hCodepage  = bDB:BUFFER-FIELD('_Db-xl-name')
       hCollation = bDB:BUFFER-FIELD('_Db-coll-name')
       hDump      = hBFile:BUFFER-FIELD ('_Dump-Name')
       hTable     = hBFile:BUFFER-FIELD ('_File-Name')
       hTableDesc = hBFile:BUFFER-FIELD ('_Desc')
       hPrime     = hBFile:BUFFER-FIELD ('_Prime-Index')
       bfFileNum  = hBFile:BUFFER-FIELD('_File-Number':U)
       hOrder     = hBField:BUFFER-FIELD ('_Order')
       hFieldName = hBField:BUFFER-FIELD ('_Field-Name')
       hDataType  = hBField:BUFFER-FIELD ('_Data-Type')
       hMandatory = hBField:BUFFER-FIELD ('_Mandatory')
       hFormat    = hBField:BUFFER-FIELD ('_Format')
       hExtent    = hBField:BUFFER-FIELD ('_Extent')
       hInitial   = hBField:BUFFER-FIELD ('_Initial')
       hLabel     = hBField:BUFFER-FIELD ('_Label')
       hColLabel  = hBField:BUFFER-FIELD ('_Col-label')
       hFieldDesc = hBField:BUFFER-FIELD ('_Desc')
       hCaseSens  = hBField:BUFFER-FIELD ('_Fld-case')
       hDecimals  = hBField:BUFFER-FIELD ('_Decimals')
       hValexp    = hBField:BUFFER-FIELD ('_Valexp')
       hValmsg    = hBField:BUFFER-FIELD ('_Valmsg')
       hHelp      = hBField:BUFFER-FIELD ('_Help')
       hEvent     = hBTrig:BUFFER-FIELD ('_Event')
       hProc      = hBTrig:BUFFER-FIELD ('_Proc-Name')
       hOverride  = hBTrig:BUFFER-FIELD ('_Override')
       hIndexName = hBIndex:BUFFER-FIELD ('_Index-Name')
       hUnique    = hBIndex:BUFFER-FIELD ('_Unique')
       hActive    = hBIndex:BUFFER-FIELD ('_Active')
       hIndexDesc = hBIndex:BUFFER-FIELD ('_Desc')
       bfIdxNum   = hBIndex:BUFFER-FIELD('_Idx-num':U)
       hFieldRecID = hBIdxField:BUFFER-FIELD ('_Field-recid').

/* Checking _Database record */
qDatabase:QUERY-PREPARE ('FOR EACH _DbStatus').
qDatabase:QUERY-OPEN().
qDatabase:GET-FIRST(NO-LOCK).
xDB:SET-ATTRIBUTE('blockSize', STRING(bDatabase:BUFFER-FIELD('_DbStatus-DbBlkSize'):BUFFER-VALUE)).
xDB:SET-ATTRIBUTE('creation', bDatabase:BUFFER-FIELD('_DbStatus-CreateDate'):BUFFER-VALUE).
xDB:SET-ATTRIBUTE('version', bDatabase:BUFFER-FIELD('_DbStatus-DbVers'):BUFFER-VALUE + '.' + bDatabase:BUFFER-FIELD('_DbStatus-DbVersMinor'):BUFFER-VALUE).
qDatabase:QUERY-CLOSE().

qDB:QUERY-PREPARE('FOR EACH _Db').
qDB:QUERY-OPEN().
qDB:GET-FIRST(NO-LOCK).
xDB:SET-ATTRIBUTE('codepage', hCodepage:BUFFER-VALUE).
xDB:SET-ATTRIBUTE('collation', hCollation:BUFFER-VALUE).
qDB:QUERY-CLOSE().

/* Parsing every _Area record */
qArea:QUERY-PREPARE('FOR EACH _Area WHERE _Area._Area-Number GT 5':U).
qArea:QUERY-OPEN().
qArea:GET-FIRST(NO-LOCK).
REPEAT:
    IF qArea:QUERY-OFF-END THEN LEAVE.
    xRoot:CREATE-NODE(xArea, 'area':U, 'ELEMENT':U).
    xDB:APPEND-CHILD(xArea).
    xArea:SET-ATTRIBUTE('num', STRING(bArea:BUFFER-FIELD('_Area-number':U):BUFFER-VALUE)).
    xArea:SET-ATTRIBUTE('name', bArea:BUFFER-FIELD('_Area-name':U):BUFFER-VALUE).
    qArea:GET-NEXT(NO-LOCK).
END.
qArea:QUERY-CLOSE().

/* Parsing every _Sequence record */
qSequence:QUERY-PREPARE('FOR EACH _Sequence':U).
qSequence:QUERY-OPEN().
qSequence:GET-FIRST(NO-LOCK).
REPEAT:
    IF qSequence:QUERY-OFF-END THEN LEAVE.
    xRoot:CREATE-NODE(xSequence, 'sequence':U, 'ELEMENT':U).
    xDB:APPEND-CHILD(xSequence).
    xSequence:SET-ATTRIBUTE('name', STRING(bSequence:BUFFER-FIELD('_Seq-name':U):BUFFER-VALUE)).
    xSequence:SET-ATTRIBUTE('init', STRING(bSequence:BUFFER-FIELD('_Seq-init':U):BUFFER-VALUE)).
    xSequence:SET-ATTRIBUTE('incr', STRING(bSequence:BUFFER-FIELD('_Seq-incr':U):BUFFER-VALUE)).
    xSequence:SET-ATTRIBUTE('min', STRING(bSequence:BUFFER-FIELD('_Seq-min':U):BUFFER-VALUE)).
    xSequence:SET-ATTRIBUTE('max', STRING(bSequence:BUFFER-FIELD('_Seq-max':U):BUFFER-VALUE)) NO-ERROR.
    xSequence:SET-ATTRIBUTE('cycle', STRING(bSequence:BUFFER-FIELD('_Cycle-ok':U):BUFFER-VALUE)).
    qSequence:GET-NEXT(NO-LOCK).
END.
qSequence:QUERY-CLOSE().

/* Parsing every _File record */
hFile:QUERY-PREPARE ('FOR EACH _File WHERE _File._File-Number GT 0 AND _File._File-Number LT 32768 BY _File._File-Name').
hFile:QUERY-OPEN().
hFile:GET-FIRST(NO-LOCK).
REPEAT:
    IF hFile:QUERY-OFF-END THEN LEAVE.
    xRoot:CREATE-NODE(xTable, 'table':U, 'ELEMENT':U).
    xDB:APPEND-CHILD(xTable).
    xTable:SET-ATTRIBUTE('dumpName', (IF hDump:BUFFER-VALUE EQ ? THEN hTable:BUFFER-VALUE ELSE hDump:BUFFER-VALUE)).
    xTable:SET-ATTRIBUTE('name', hTable:BUFFER-VALUE).
    IF (hTableDesc:BUFFER-VALUE NE ?) THEN DO:
        xRoot:CREATE-NODE(xText, '':U, 'TEXT':U).
        xText:NODE-VALUE = hTableDesc:BUFFER-VALUE.
        xTable:APPEND-CHILD(xText).
    END.
    
    /* Searching area number */
    qStorage:QUERY-PREPARE('FOR EACH _StorageObject WHERE _Object-Number EQ ' + STRING(bfFileNum:BUFFER-VALUE) + ' AND _Object-type EQ 1').
    qStorage:QUERY-OPEN().
    qStorage:GET-FIRST(NO-LOCK).
    REPEAT:
        IF qStorage:QUERY-OFF-END THEN LEAVE.
        xTable:SET-ATTRIBUTE('areaNum', STRING(bStorage:BUFFER-FIELD('_Area-number':U):BUFFER-VALUE)).
        qStorage:GET-NEXT(NO-LOCK).
    END.
    qStorage:QUERY-CLOSE().
    
    /* Parsing table's fields */
    ASSIGN cQuery = 'FOR EACH _Field WHERE _Field._File-recid = '
           cQuery = cQuery + STRING (hBFile:RECID) + ' BY _Field._Order'.
    hField:QUERY-PREPARE(cQuery).
    hField:QUERY-OPEN().
    hField:GET-FIRST(NO-LOCK).
    REPEAT:
        IF hField:QUERY-OFF-END THEN LEAVE.
        xRoot:CREATE-NODE(xField, 'field':U, 'ELEMENT':U).
        xTable:APPEND-CHILD(xField).
        xField:SET-ATTRIBUTE('name':U, hFieldName:BUFFER-VALUE).
        xField:SET-ATTRIBUTE('order':U, STRING(hOrder:BUFFER-VALUE)).
        xField:SET-ATTRIBUTE('dataType':U, hDataType:BUFFER-VALUE).
        xField:SET-ATTRIBUTE('mandatory':U, STRING (hMandatory:BUFFER-VALUE)).
        xField:SET-ATTRIBUTE('format':U, STRING (hFormat:BUFFER-VALUE)).
        xField:SET-ATTRIBUTE('extent':U, STRING (hExtent:BUFFER-VALUE)).
        xField:SET-ATTRIBUTE('initialValue':U, (IF hInitial:BUFFER-VALUE EQ ? THEN '?':U ELSE STRING (hInitial:BUFFER-VALUE))).
        xField:SET-ATTRIBUTE('label':U, (IF hLabel:BUFFER-VALUE EQ ? THEN '?':U ELSE STRING (hLabel:BUFFER-VALUE))).
        xField:SET-ATTRIBUTE('columnLabel':U, (IF hColLabel:BUFFER-VALUE EQ ? THEN '?':U ELSE STRING (hColLabel:BUFFER-VALUE))).
        xField:SET-ATTRIBUTE('caseSensitive':U, STRING (hCaseSens:BUFFER-VALUE)).
        xField:SET-ATTRIBUTE('decimals':U, (IF hDecimals:BUFFER-VALUE EQ ? THEN '?':U ELSE STRING (hDecimals:BUFFER-VALUE))).
        xField:SET-ATTRIBUTE('valExp':U, (IF hValexp:BUFFER-VALUE EQ ? THEN '?':U ELSE STRING (hValexp:BUFFER-VALUE))).
        xField:SET-ATTRIBUTE('valMsg':U, (IF hValmsg:BUFFER-VALUE EQ ? THEN '?':U ELSE STRING (hValmsg:BUFFER-VALUE))).
        xField:SET-ATTRIBUTE('help':U, (IF hHelp:BUFFER-VALUE EQ ? THEN '?':U ELSE STRING (hHelp:BUFFER-VALUE))).
        IF (hFieldDesc:BUFFER-VALUE NE ?) THEN DO:
            xRoot:CREATE-NODE(xText, '':U, 'TEXT':U).
            xText:NODE-VALUE = hFieldDesc:BUFFER-VALUE.
            xField:APPEND-CHILD(xText).
        END.
        hField:GET-NEXT(NO-LOCK).
    END.
    hField:QUERY-CLOSE().
    
    /* Parsing table's triggers */
    ASSIGN cQuery = 'FOR EACH _File-Trig WHERE _File-Trig._File-recid = ' + STRING (hBFile:RECID).
    hTrig:QUERY-PREPARE(cQuery).
    hTrig:QUERY-OPEN().
    hTrig:GET-FIRST(NO-LOCK).
    REPEAT:
        IF hTrig:QUERY-OFF-END THEN LEAVE.
        xRoot:CREATE-NODE(xTrigger, 'trigger':U, 'ELEMENT':U).
        xTable:APPEND-CHILD(xTrigger).
        xTrigger:SET-ATTRIBUTE('event':U, hEvent:BUFFER-VALUE).
        xTrigger:SET-ATTRIBUTE('procedure':U, hProc:BUFFER-VALUE).
        xTrigger:SET-ATTRIBUTE('overridable':U, (IF hOverride:BUFFER-VALUE THEN 'True' ELSE 'False')).
        hTrig:GET-NEXT(NO-LOCK).
    END.
    hTrig:QUERY-CLOSE().

    /* Parsing table's indexes */
    ASSIGN cQuery = 'FOR EACH _Index WHERE _Index._File-recid EQ ' + STRING (hBFile:RECID) + ' BY _Index._Unique DESCENDING BY _Index._Index-Name'.
    hIndex:QUERY-PREPARE (cQuery).
    hIndex:QUERY-OPEN().
    hIndex:GET-FIRST(NO-LOCK).
    REPEAT:
        IF hIndex:QUERY-OFF-END THEN LEAVE.
        xRoot:CREATE-NODE(xIndex, 'index', 'ELEMENT':U).
        xTable:APPEND-CHILD(xIndex).
        xIndex:SET-ATTRIBUTE('name':U, hIndexName:BUFFER-VALUE).
        xIndex:SET-ATTRIBUTE('primary':U, (IF (hPrime:BUFFER-VALUE EQ hBIndex:RECID) THEN 'True':U ELSE 'False')).
        xIndex:SET-ATTRIBUTE('unique':U, (IF hUnique:BUFFER-VALUE THEN 'True':U ELSE 'False')).
        xIndex:SET-ATTRIBUTE('active':U, (IF hActive:BUFFER-VALUE THEN 'True':U ELSE 'False')).
        IF (hIndexDesc:BUFFER-VALUE NE ?) THEN DO:
            xRoot:CREATE-NODE(xText, '':U, 'TEXT':U).
            xText:NODE-VALUE = hIndexDesc:BUFFER-VALUE.
            xIndex:APPEND-CHILD(xText).
        END.
        
        /* Searching area number */
        qStorage:QUERY-PREPARE('FOR EACH _StorageObject WHERE _Object-Number EQ ' + STRING(bfIdxNum:BUFFER-VALUE) + ' AND _Object-type EQ 2').
        qStorage:QUERY-OPEN().
        qStorage:GET-FIRST(NO-LOCK).
        REPEAT:
            IF qStorage:QUERY-OFF-END THEN LEAVE.
            xIndex:SET-ATTRIBUTE('areaNum', STRING(bStorage:BUFFER-FIELD('_Area-number':U):BUFFER-VALUE)).
            qStorage:GET-NEXT(NO-LOCK).
        END.
        qStorage:QUERY-CLOSE().

        /* Parsing index's fields */
        ASSIGN cQuery = 'FOR EACH _Index-Field WHERE _Index-Field._Index-recid EQ ' + STRING (hBIndex:RECID).
        hIdxField:QUERY-PREPARE (cQuery).
        hIdxField:QUERY-OPEN().
        hIdxField:GET-FIRST(NO-LOCK).
        REPEAT:
            IF hIdxField:QUERY-OFF-END THEN LEAVE.
            xRoot:CREATE-NODE(xIndexFld, 'indexField':U, 'ELEMENT':U).
            xIndex:APPEND-CHILD(xIndexFld).
            ASSIGN cQuery = 'FOR EACH _Field WHERE RECID (_Field) EQ ' + STRING (hFieldRecID:BUFFER-VALUE).
            hField:QUERY-PREPARE (cQuery).
            hField:QUERY-OPEN().
            hField:GET-FIRST(NO-LOCK).
            IF (NOT hField:QUERY-OFF-END) THEN DO:
                xIndexFld:SET-ATTRIBUTE('name':U, hFieldName:BUFFER-VALUE).
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
DELETE OBJECT hCodepage.
DELETE OBJECT hCollation.
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
DELETE OBJECT hColLabel.
DELETE OBJECT hCaseSens.
DELETE OBJECT hDecimals.
DELETE OBJECT hFieldDesc.
DELETE OBJECT hValexp.
DELETE OBJECT hValmsg.
DELETE OBJECT hHelp.
DELETE OBJECT hEvent.
DELETE OBJECT hProc.
DELETE OBJECT hOverride.
DELETE OBJECT hIndexName.
DELETE OBJECT hUnique.
DELETE OBJECT hActive.
DELETE OBJECT hIndexDesc.
DELETE OBJECT hFieldRecID.
/* Continue with buffer handles */
DELETE OBJECT bDatabase.
DELETE OBJECT bDB.
DELETE OBJECT hBFile.
DELETE OBJECT hBField.
DELETE OBJECT hBIndex.
DELETE OBJECT hBTrig.
DELETE OBJECT hBIdxField.
/* And ends up with query handles */
DELETE OBJECT qDatabase.
DELETE OBJECT qDB.
DELETE OBJECT hFile.
DELETE OBJECT hField.
DELETE OBJECT hIndex.
DELETE OBJECT hTrig.
DELETE OBJECT hIdxField.

xRoot:SAVE("MEMPTR":U, pmXML).

DELETE OBJECT xRoot.
DELETE OBJECT xDB.
DELETE OBJECT xArea.
DELETE OBJECT xTable.
DELETE OBJECT xField.
DELETE OBJECT xIndex.
DELETE OBJECT xIndexFld.
DELETE OBJECT xTrigger.
DELETE OBJECT xText.

RETURN '0'.
