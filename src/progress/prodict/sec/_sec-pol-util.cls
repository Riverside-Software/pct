/*********************************************************************
* Copyright (C) 2008-2010 by Progress Software Corporation. All rights    *
* reserved.                                                          *
*                                                                    *
*********************************************************************/

/*--------------------------------------------------------------------

File: prodict/sec/_sec-pol-util.cls

Description:
    Object for interfacing with encryption. This is the object that will get
    and set the encryption policies for encryption.
    
History:
    07/01/08  fernando   created

                            
--------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
USING Progress.Security.DB.* .

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS prodict.sec._sec-pol-util:

{prodict/sec/sec-pol.i}

&SCOPED-DEFINE TABLE_TYPE "Table"
&SCOPED-DEFINE INDEX_TYPE "Index"
&SCOPED-DEFINE CLOB_TYPE  "Clob"
&SCOPED-DEFINE BLOB_TYPE  "Blob"


DEFINE PRIVATE VARIABLE myEPolicy     AS EncryptionPolicy    NO-UNDO.
DEFINE PRIVATE VARIABLE TablePolicies AS TablePolicy  EXTENT NO-UNDO.
DEFINE PRIVATE VARIABLE IndexPolicies AS IndexPolicy  EXTENT NO-UNDO.
DEFINE PRIVATE VARIABLE LobPolicies   AS LobPolicy    EXTENT NO-UNDO.
DEFINE PRIVATE VARIABLE seq           AS INTEGER             NO-UNDO.
DEFINE PRIVATE VARIABLE hDB           AS HANDLE              NO-UNDO.

DEFINE PUBLIC PROPERTY CipherNames AS CHARACTER
    GET():
      DEFINE VARIABLE cList AS CHAR NO-UNDO.
      DEFINE VARIABLE cTmp AS CHAR NO-UNDO.
      DEFINE VARIABLE i     AS INT  NO-UNDO.
      DEFINE VARIABLE j     AS INT  NO-UNDO.

      IF NOT VALID-OBJECT(myEPolicy) THEN
          RETURN ?.
      ELSE DO:
          /* filter out null and pbe ciphers */
          ASSIGN ctmp = myEPolicy:CipherNames
                 ctmp = REPLACE(ctmp,"NULL_NULL_NULL,","")
                 j = NUM-ENTRIES(ctmp).

          REPEAT i = 1 TO j:
              IF NOT ENTRY(i,cTmp) MATCHES "*_PBE" THEN DO:
                  IF cList = "" THEN
                     ASSIGN cList = cList + ENTRY(i,cTmp).
                  ELSE
                      ASSIGN cList = cList + "," + ENTRY(i,cTmp).
              END.
          END.

          RETURN cList.
      END.
    END GET.

DEFINE PUBLIC PROPERTY DefaultCipher AS CHARACTER
    GET():
      IF NOT VALID-OBJECT(myEPolicy) THEN
          RETURN ?.
      ELSE
          RETURN myEPolicy:DefaultCipher.
    END GET.

DEFINE PUBLIC PROPERTY EncryptionEnabledOnly AS LOGICAL
    GET.
    SET.

DEFINE PUBLIC PROPERTY FillAreaNum AS LOGICAL
    GET.
    SET.

DEFINE PRIVATE PROPERTY nextSeqNum AS INTEGER
    GET():
         /* get next value if the instantiator is adding records to the temp-table */
         ASSIGN seq = seq + 1.
         RETURN seq.
    END GET.

DEFINE PUBLIC PROPERTY canMantainPolicies AS LOGICAL
    GET():
        RETURN myEPolicy:isKeyStoreAdmin.
    END GET.

CONSTRUCTOR _sec-pol-util():
    getEpolicyObj("DICTDB").
END CONSTRUCTOR.

CONSTRUCTOR _sec-pol-util(INPUT cDbName AS CHAR):
    getEpolicyObj(cDbName).
END CONSTRUCTOR.

METHOD PRIVATE VOID getEpolicyObj (INPUT cDbName AS CHAR):
   DEFINE VARIABLE lOk AS LOGICAL     NO-UNDO.
   DEFINE VARIABLE cOrig AS CHAR      NO-UNDO.

    myEPolicy = NEW EncryptionPolicy(cDbName).

    /* _dctadmn.p used DICTDB, but DICTDB may not be the db we are looking at */
    IF cDbName NE "DICTDB":U AND (LDBNAME("DICTDB") NE cDbName) THEN DO:
       cOrig = LDBNAME("DICTDB").
       CREATE ALIAS DICTDB FOR DATABASE VALUE(cDbName).
    END.

    RUN prodict/_dctadmn.p ( INPUT USERID(cDbName), OUTPUT lOk ).

    IF cOrig NE ? AND cOrig NE "" THEN
       CREATE ALIAS DICTDB FOR DATABASE VALUE(cOrig).
    
    IF NOT lOk THEN DO:
        /* make sure we delete the object now */
       DELETE OBJECT myEPolicy NO-ERROR.
       UNDO, THROW NEW Progress.Lang.AppError("You must be a Security Administrator to maintain encryption policies.", 14893).
    END.

    /* get a share lock on the schema so no one can make changes to it
       while we are in the same transaction.
    */
    getDbLock(NO).

    CATCH e AS PROGRESS.Lang.ProError:
       DEFINE VARIABLE cError AS CHAR    NO-UNDO.
       DEFINE VARIABLE iNum   AS INTEGER NO-UNDO.

       IF VALID-OBJECT(myEPolicy) THEN
           DELETE OBJECT myEPolicy.

       ASSIGN iNum = e:GetMessageNum(1).

       CASE iNum:
           WHEN 14889 THEN
               cError = "Database "  + LDBNAME(cDbName) + " does not have the encryption feature enabled.".
           WHEN 14890 THEN
               cError = "Cannot read encryption policies if database is remote.".
           WHEN 14888 THEN
               cError = "Database is not connected.".
           WHEN 14893 THEN
               cError = "You must be a Security Administrator to maintain encryption policies.".
           OTHERWISE
               cError=  'Error: ' + e:GetMessage(1).
       END CASE.

       DELETE OBJECT e.

       /* throw an application error */
       UNDO, THROW NEW Progress.Lang.AppError(cError, iNum).
    END CATCH. 

END METHOD.

/* get list of objects (table/index/lob) that are encryptable and info on the current 
  policy. The code is database reference-free - we use the db passed to the constructor.
*/
METHOD PUBLIC VOID getTableList(INPUT getCurrPolicyInfo AS LOGICAL,
                                OUTPUT DATASET dsObjAttrs):

    DEFINE VARIABLE cTmp    AS CHAR   NO-UNDO.
    DEFINE VARIABLE hQuery1 AS HANDLE NO-UNDO.
    DEFINE VARIABLE hQuery2 AS HANDLE NO-UNDO.
    DEFINE VARIABLE hQuery3 AS HANDLE NO-UNDO.

    DEFINE VARIABLE hFile   AS HANDLE NO-UNDO.
    DEFINE VARIABLE hField  AS HANDLE NO-UNDO.
    DEFINE VARIABLE hIndex  AS HANDLE NO-UNDO.
    DEFINE VARIABLE cType   AS CHAR   NO-UNDO.

    EMPTY TEMP-TABLE ttObjAttrs NO-ERROR.
    ASSIGN seq = 0 /* initial */
           cTmp = myEpolicy:LogicalDBName  + "._File".

    /* will not suppress errors - which will get thrown back to the caller */
    CREATE BUFFER hFile FOR TABLE cTmp.

    CREATE QUERY hQuery1.
    hQuery1:SET-BUFFERS(hFile).
    hQuery1:QUERY-PREPARE("FOR EACH " + cTmp + " WHERE ((_File-number > 0 AND _File-number < 32000) OR _File-name BEGINS '_aud-')"
                            + " AND _Owner = 'PUB' USE-INDEX _File-name" ).
    hQuery1:QUERY-OPEN().

    REPEAT ON ERROR UNDO, THROW:
       hQuery1:GET-NEXT(NO-LOCK).  
       IF hQuery1:QUERY-OFF-END THEN
          LEAVE.
       addIfEncryptable(INPUT hFile::_File-number,
                        INPUT hFile::_File-name,
                        INPUT hFile::_ianum,
                        INPUT {&TABLE_TYPE},
                        INPUT getCurrPolicyInfo).

       /* look for fields */
        IF NOT VALID-HANDLE(hField) THEN DO:
           CREATE BUFFER hField FOR TABLE myEPolicy:LogicalDBName + "._Field".
        
           CREATE QUERY hQuery2.
           hQuery2:SET-BUFFERS(hField).
        END.

        hQuery2:QUERY-PREPARE("FOR EACH _Field WHERE (_Field._Data-type = 'CLOB' OR _Field._Data-type = 'BLOB')"
                              + " AND _File-recid = " + STRING(hFile:RECID) ).
        hQuery2:QUERY-OPEN().
        REPEAT ON ERROR UNDO, THROW:
            hQuery2:GET-NEXT(NO-LOCK).  
            IF hQuery2:QUERY-OFF-END THEN
               LEAVE.

            /* use values from pre-processor so all of them show up with
               first letter as uppercase.
            */
            IF hField::_Data-type = {&BLOB_TYPE} THEN
                cType = {&BLOB_TYPE}.
            ELSE
                cType = {&CLOB_TYPE}.

            addIfEncryptable(INPUT hField::_Fld-stlen,
                             INPUT hFile::_File-name
                                  + "." + hField::_Field-name,
                             INPUT ?,
                             INPUT cType,
                             INPUT getCurrPolicyInfo).
        END.
        hQuery2:QUERY-CLOSE().

        /* look for indexes */
        IF NOT VALID-HANDLE(hIndex) THEN DO:
           CREATE BUFFER hIndex FOR TABLE myEPolicy:LogicalDBName + "._Index".
        
           CREATE QUERY hQuery3.
           hQuery3:SET-BUFFERS(hIndex).
        END.

        hQuery3:QUERY-PREPARE("FOR EACH _Index WHERE _File-recid = " + STRING(hFile:RECID)).
        hQuery3:QUERY-OPEN().
        REPEAT ON ERROR UNDO, THROW:
            hQuery3:GET-NEXT(NO-LOCK).  
            IF hQuery3:QUERY-OFF-END THEN
               LEAVE.

            addIfEncryptable(INPUT hIndex::_Idx-num,
                             INPUT hFile::_File-name 
                                   + "." + hIndex::_Index-name,
                             INPUT hIndex::_ianum,
                             INPUT {&INDEX_TYPE},
                             INPUT getCurrPolicyInfo).
        END.
        hQuery3:QUERY-CLOSE().
    END.

    hQuery1:QUERY-CLOSE().

   /* OUTPUT TO policies.txt.
    FOR EACH ttObjAttrs.
        EXPORT ttObjAttrs.
    END.
    OUTPUT CLOSE.*/

    CATCH e AS PROGRESS.Lang.ProError:
       UNDO, THROW NEW Progress.Lang.AppError(e:GetMessage(1), e:GetMessageNum(1)).
    END CATCH.
    FINALLY:
        DELETE OBJECT hQuery1 NO-ERROR.
        DELETE OBJECT hQuery2 NO-ERROR.
        DELETE OBJECT hQuery3 NO-ERROR.
        DELETE OBJECT hFile   NO-ERROR.
        DELETE OBJECT hField  NO-ERROR.
        DELETE OBJECT hIndex  NO-ERROR.
    END FINALLY.
        
END METHOD.

/* get list of table and/or its indexes and LOB columns that can be encryptable */
METHOD PUBLIC VOID getObjectList(INPUT cTableName AS CHARACTER,
                                 INPUT getCurrPolicyInfo AS LOGICAL,
                                 OUTPUT DATASET dsObjAttrs):

    DEFINE VARIABLE cTmp    AS CHAR   NO-UNDO.
    DEFINE VARIABLE hQuery1 AS HANDLE NO-UNDO.
    DEFINE VARIABLE hQuery2 AS HANDLE NO-UNDO.
    DEFINE VARIABLE hQuery3 AS HANDLE NO-UNDO.

    DEFINE VARIABLE hFile   AS HANDLE NO-UNDO.
    DEFINE VARIABLE hField  AS HANDLE NO-UNDO.
    DEFINE VARIABLE hIndex  AS HANDLE NO-UNDO.
    DEFINE VARIABLE cType   AS CHAR   NO-UNDO.

    EMPTY TEMP-TABLE ttObjAttrs NO-ERROR.
    ASSIGN seq = 0 /* initial */
           cTmp = myEpolicy:LogicalDBName  + "._File".

    /* will not suppress errors - which will get thrown back to the caller */
    CREATE BUFFER hFile FOR TABLE cTmp.

    CREATE QUERY hQuery1.
    hQuery1:SET-BUFFERS(hFile).
    hQuery1:QUERY-PREPARE("FOR EACH " + cTmp + " WHERE _File-name = '" +
                            cTableName + "' AND _Owner = 'PUB' USE-INDEX _File-name" ).
    hQuery1:QUERY-OPEN().

    REPEAT ON ERROR UNDO, THROW:
       hQuery1:GET-NEXT(NO-LOCK).  
       IF hQuery1:QUERY-OFF-END THEN
          LEAVE.
       addIfEncryptable(INPUT hFile::_File-number,
                        INPUT hFile::_File-name,
                        INPUT hFile::_ianum,
                        INPUT {&TABLE_TYPE},
                        INPUT getCurrPolicyInfo).

       /* look for fields */
        IF NOT VALID-HANDLE(hField) THEN DO:
           CREATE BUFFER hField FOR TABLE myEPolicy:LogicalDBName + "._Field".
        
           CREATE QUERY hQuery2.
           hQuery2:SET-BUFFERS(hField).
        END.

        hQuery2:QUERY-PREPARE("FOR EACH _Field WHERE (_Field._Data-type = 'CLOB' OR _Field._Data-type = 'BLOB')"
                              + " AND _File-recid = " + STRING(hFile:RECID) ).
        hQuery2:QUERY-OPEN().
        REPEAT ON ERROR UNDO, THROW:
            hQuery2:GET-NEXT(NO-LOCK).  
            IF hQuery2:QUERY-OFF-END THEN
               LEAVE.

            /* use values from pre-processor so all of them show up with
               first letter as uppercase.
            */
            IF hField::_Data-type = {&BLOB_TYPE} THEN
                cType = {&BLOB_TYPE}.
            ELSE
                cType = {&CLOB_TYPE}.

            addIfEncryptable(INPUT hField::_Fld-stlen,
                             INPUT hFile::_File-name
                                  + "." + hField::_Field-name,
                             INPUT ?,
                             INPUT cType,
                             INPUT getCurrPolicyInfo).
        END.
        hQuery2:QUERY-CLOSE().

        /* look for indexes */
        IF NOT VALID-HANDLE(hIndex) THEN DO:
           CREATE BUFFER hIndex FOR TABLE myEPolicy:LogicalDBName + "._Index".
        
           CREATE QUERY hQuery3.
           hQuery3:SET-BUFFERS(hIndex).
        END.

        hQuery3:QUERY-PREPARE("FOR EACH _Index WHERE _File-recid = " + STRING(hFile:RECID)).
        hQuery3:QUERY-OPEN().
        REPEAT ON ERROR UNDO, THROW:
            hQuery3:GET-NEXT(NO-LOCK).  
            IF hQuery3:QUERY-OFF-END THEN
               LEAVE.

            addIfEncryptable(INPUT hIndex::_Idx-num,
                             INPUT hFile::_File-name 
                                   + "." + hIndex::_Index-name,
                             INPUT hIndex::_ianum,
                             INPUT {&INDEX_TYPE},
                             INPUT getCurrPolicyInfo).
        END.
        hQuery3:QUERY-CLOSE().
    END.

    hQuery1:QUERY-CLOSE().

   /* OUTPUT TO policies.txt.
    FOR EACH ttObjAttrs.
        EXPORT ttObjAttrs.
    END.
    OUTPUT CLOSE.*/

    CATCH e AS PROGRESS.Lang.ProError:
       UNDO, THROW NEW Progress.Lang.AppError(e:GetMessage(1), e:GetMessageNum(1)).
    END CATCH.
    FINALLY:
        DELETE OBJECT hQuery1 NO-ERROR.
        DELETE OBJECT hQuery2 NO-ERROR.
        DELETE OBJECT hQuery3 NO-ERROR.
        DELETE OBJECT hFile   NO-ERROR.
        DELETE OBJECT hField  NO-ERROR.
        DELETE OBJECT hIndex  NO-ERROR.
    END FINALLY.
        
END METHOD.

/* Given an object name and type, get the encryption policy info.
*/
METHOD PUBLIC VOID getPolicyVersions(INPUT objName AS CHAR, 
                                     INPUT objectType AS CHAR, 
                                     OUTPUT DATASET dsObjAttrs):
    DEFINE VARIABLE cTable AS CHAR NO-UNDO.
    DEFINE VARIABLE cObj   AS CHAR NO-UNDO.

    FIND FIRST ttObjAttrs WHERE ttObjAttrs.obj-name EQ objName AND 
                                  ttObjAttrs.obj-type EQ objectType NO-ERROR.
    IF NOT AVAILABLE ttObjAttrs THEN DO:

       /* if not on the table yet, we will check if we can get it now */
       findAndAdd(INPUT NO, ?, objName, objectType).

       FIND FIRST ttObjAttrs WHERE ttObjAttrs.obj-name EQ objName NO-ERROR.
    END.

    /* if we can't find it for the object specified, bad table-name passed */    
    IF AVAILABLE ttObjAttrs THEN
        fillPolicyInfo(INPUT ttObjAttrs.seq-num, 
                       INPUT ttObjAttrs.obj-name, 
                       INPUT ttObjAttrs.obj-type, 
                       INPUT YES). /* fill policy versions table*/
END METHOD.

/* Given an object num and type, get the encryption policy info.
*/
METHOD PUBLIC VOID getPolicyVersions(INPUT objNum AS INTEGER, 
                                     INPUT objectType AS CHAR, 
                                     OUTPUT DATASET dsObjAttrs):

    FIND FIRST ttObjAttrs WHERE ttObjAttrs.obj-num = objNum AND 
        ttObjAttrs.obj-type = objectType NO-ERROR.

    IF NOT AVAILABLE ttObjAttrs THEN DO:
       /* if not on the table yet, we will check if we can get it now */
       findAndAdd(INPUT YES, objNum, ?, objectType).

       FIND FIRST ttObjAttrs WHERE ttObjAttrs.obj-num = objNum AND 
           ttObjAttrs.obj-type = objectType NO-ERROR.
    END.

    /* if we can't find it for the object specified, bad table-name passed */    
    IF AVAILABLE ttObjAttrs THEN
        fillPolicyInfo(INPUT ttObjAttrs.seq-num, 
                       INPUT ttObjAttrs.obj-name, 
                       INPUT ttObjAttrs.obj-type, 
                       INPUT YES). /* fill policy versions table*/
END METHOD.

/* Given an object num and type, get the encryption policy info.
   The object name is also passed. If we can't find an entry for it, we create it as a placeholder.
*/
METHOD PUBLIC VOID getPolicyVersions(INPUT objNum AS INTEGER, 
                                     INPUT objName AS CHAR, 
                                     INPUT objectType AS CHAR, 
                                     OUTPUT DATASET dsObjAttrs):

    FIND FIRST ttObjAttrs WHERE ttObjAttrs.obj-name = objName AND 
        ttObjAttrs.obj-type = objectType NO-ERROR.

    IF NOT AVAILABLE ttObjAttrs THEN DO:
        addIfEncryptable(INPUT objNum, INPUT objName, INPUT ?, 
                         INPUT objectType, INPUT YES).
        /* see if we added it */
        FIND FIRST ttObjAttrs WHERE ttObjAttrs.obj-name = objName AND 
             ttObjAttrs.obj-type = objectType NO-ERROR.
    END.

    /* if we can't find it for the object specified, bad table-name passed */    
    IF AVAILABLE ttObjAttrs THEN
        fillPolicyInfo(INPUT ttObjAttrs.seq-num, 
                       INPUT ttObjAttrs.obj-name, 
                       INPUT ttObjAttrs.obj-type, 
                       INPUT YES). /* fill policy versions table*/
END METHOD.

/* update encryption policy for the objects in the dataset */
METHOD PUBLIC VOID updatePolicies (INPUT callerForCallBack AS HANDLE,
                                   INPUT DATASET dsObjAttrs):

    DEFINE BUFFER bAfter FOR ttObjAttrs.
    DEF VAR cipherName AS CHAR NO-UNDO.
    DEF VAR fullobjName    AS CHAR NO-UNDO.
    DEF VAR tableName  AS CHAR NO-UNDO.
    DEF VAR objName    AS CHAR NO-UNDO.
    DEF VAR objType    AS CHAR NO-UNDO.
    DEFINE VARIABLE myTPol AS TablePolicy NO-UNDO.
    DEFINE VARIABLE myIPol AS IndexPolicy NO-UNDO.
    DEFINE VARIABLE myLPol AS LobPolicy   NO-UNDO.

    /* now go through all the changed records and make the necessary 
       changes. We are here either because the user wants to enable,
       disable or generate the encryption key. They are translated to
       a new policy, so we can just create a policy with the cipher
       we have. The only case to watch for is when the cipher is blank,
       which then means we have to pass the 'null_null_null' cipher.
    */
    main-trans:
    DO TRANS ON ERROR UNDO, THROW:

        FOR EACH bfttObjAttrs ON ERROR UNDO, THROW
            ON STOP UNDO, LEAVE: /* catches canceled lock */

            FIND FIRST bAfter WHERE ROWID(bAfter) = BUFFER bfttObjAttrs:AFTER-ROWID.
            ASSIGN cipherName = bAfter.obj-cipher
                   fullobjName = bAfter.obj-name
                   objType = bAfter.obj-type
                   tableName = ENTRY(1,fullobjName,".").

            IF cipherName = "" THEN
               ASSIGN cipherName = "NULL_NULL_NULL".

            CASE bAfter.obj-type:
                WHEN {&TABLE_TYPE} THEN DO:
                    myTPol = myEPolicy:CreateTablePolicy(tableName,cipherName).
                    DELETE OBJECT myTPol.
                END.
                WHEN {&INDEX_TYPE} OR 
                    WHEN {&CLOB_TYPE} OR 
                    WHEN {&BLOB_TYPE} THEN DO:

                    IF NUM-ENTRIES(fullobjName,".") > 1 THEN
                       objName = ENTRY(2,fullobjName,".").
                    ELSE
                       UNDO main-trans, THROW NEW Progress.Lang.AppError("Missing object name in : " + fullobjName, 1).

                    IF bAfter.obj-type = {&INDEX_TYPE} THEN DO:
                       myIPol = myEPolicy:CreateIndexPolicy(tableName, objName, cipherName).
                       DELETE OBJECT myIPol.
                    END.
                    ELSE DO:
                       myLPol = myEPolicy:CreateLobPolicy(tableName, objName, cipherName).
                       DELETE OBJECT myLPol.
                    END.

                END.
                OTHERWISE
                    UNDO, THROW NEW Progress.Lang.AppError("Invalid object type: " + bAfter.obj-type, 1).
            END CASE.

            CATCH e AS PROGRESS.Lang.ProError:
                DEFINE VARIABLE cError    AS CHAR    NO-UNDO.
                DEFINE VARIABLE iNum      AS INTEGER NO-UNDO.
                DEFINE VARIABLE lContinue AS LOGICAL NO-UNDO.
                
                ASSIGN  iNum = e:GetMessageNum(1)
                        cError = "Error: ".
    
                IF iNum = 14896 THEN
                   cError = cError + "Cannot change the object encryption policy until its encrypted data has been updated".
                ELSE IF iNum NE 12536 THEN
                   cError = cError + e:GetMessage(1).
    
                DELETE OBJECT e.
    
                IF iNum = 12536 THEN /* can't get schema lock */
                    STOP.
    
                cError = cError + " (Object: " + fullobjName +
                         " Type: "   + objType + ")".

                /* if callback is set up, caller wants to be notified or
                   errors and deal with them. If we should continue, we 
                   will just move on to the next record. If not, we undo
                   the transaction and return.
                   If not callback is defined, we throw an error.
                */
                IF callerForCallBack NE ? THEN DO:
                    RUN secErrorCallback IN callerForCallBack 
                         (INPUT cError, OUTPUT lContinue) NO-ERROR.
                    IF NOT lContinue THEN
                         UNDO main-trans, LEAVE main-trans.
                    NEXT.
                END.
                ELSE
                /* throw an application error */
                UNDO, THROW NEW Progress.Lang.AppError(cError, iNum).
            END CATCH.

        END.
    END.

END METHOD.

/* For the load process - cache settings from the .df */
METHOD PUBLIC LOGICAL cacheObjForLoad (INPUT cObjName AS CHAR,
                                       INPUT objType AS CHAR,
                                       INPUT objNum AS INT,
                                       INPUT-OUTPUT cipher AS CHAR):
DEFINE VARIABLE hasPrev AS LOGICAL NO-UNDO.
DEFINE VARIABLE cTmp    AS CHAR    NO-UNDO.

    FIND FIRST ttObjAttrs WHERE ttObjAttrs.obj-name = cObjName
      AND ttObjAttrs.obj-type = objType NO-ERROR.

    IF NOT AVAILABLE ttObjAttrs THEN DO:

        /* we are only called by the load process, but make sure the object name has the
           information needed.
        */
        cTmp = ENTRY(1,cObjName, ".").
        IF cTmp = "" OR cTmp = ? THEN
            UNDO, THROW NEW Progress.Lang.AppError("Invalid object name: "+ cObjName, 1).
        IF objType NE {&TABLE_TYPE} THEN DO:
            IF NUM-ENTRIES(cObjName, ".") = 2 THEN
               cTmp = ENTRY(2,cObjName, ".").
            ELSE
                ASSIGN cTmp = "".

            IF cTmp = "" OR cTmp = ? THEN
                UNDO, THROW NEW Progress.Lang.AppError("Invalid object name: " + cObjName, 1).
        END.


        TEMP-TABLE ttObjAttrs:TRACKING-CHANGES = NO.

        /* let's get the info for the policy on this object, 
           in case there is one, but don't do it if object number is zero,
           which means the object is being created in the same transaction.
        */
        IF objNum NE 0 THEN
           getPolicyVersions(INPUT cObjName, 
                             INPUT objType, 
                             OUTPUT DATASET dsObjAttrs BY-REFERENCE).

        FIND FIRST ttObjAttrs WHERE ttObjAttrs.obj-name = cObjName
             AND ttObjAttrs.obj-type = objType NO-ERROR.
        IF NOT AVAILABLE ttObjAttrs THEN DO:
            /* if this is a new object, it won't have any policies, so
               just add it manually for now.
            */
            CREATE ttObjAttrs.
            ASSIGN ttObjAttrs.seq-num = nextSeqNum
                   ttObjAttrs.obj-name = cObjName
                   ttObjAttrs.obj-type = objType
                   ttObjAttrs.obj-num = objNum.
        END.

        TEMP-TABLE ttObjAttrs:TRACKING-CHANGES = YES.
    END.

    ASSIGN hasPrev = ttObjAttrs.has-prev-pol.

    /* we will now record the new value (or first value). tracking changes should be on
       by now, so we will use the values in the before-table to see if there is an effective change
       when it's time to save the changes.
     */  
    IF cipher <> ttObjAttrs.obj-cipher THEN DO:
        IF NOT hasPrev THEN
            ttObjAttrs.obj-cipher = cipher.     
    END.
    ELSE
        cipher = ?. /* singal the caller that it was the same cipher */

    /* so we will return if it has a previous version, and cipher will be ? if it's the same
       cipher name of the current policy version
    */
    RETURN hasPrev.

END METHOD.

/* For the load process - save policy settings that we cached from the .df */
METHOD PUBLIC LOGICAL cacheSavePolicy(INPUT callerProc AS handle, 
                                      OUTPUT invalidObjName AS CHAR):

     DEFINE VARIABLE fixedAll  AS LOGICAL NO-UNDO.

     /* check if there are any changes at all */
     IF NOT CAN-FIND (FIRST bfttObjAttrs) THEN 
        RETURN YES.

     fixedAll = cacheFixObjNumBeforeUpdate().

     /* if we find a record with an invalid obj num, then we can't move on because
        we have some transaction above us that is holding up the creation of the objects.
        So if we couldn't fix them up, return no 
     */
     IF NOT fixedAll THEN DO:
         ASSIGN invalidObjName = ttObjAttrs.obj-name.
         RETURN NO.
     END.

     IF NOT canMantainPolicies THEN 
         UNDO, THROW NEW Progress.Lang.AppError("You must be the Key Store Administrator" +
                                                " to mantain encryption policies", 1).

     /* if not yet locked, get a lock on the schema so no one can make 
        changes to it while we are in this transaction.
     */
     getDbLock(YES).

     /* this throws an error if we fail to save a policy. Caller must catch the error */
     updatePolicies(INPUT callerProc, INPUT DATASET dsObjAttrs BY-REFERENCE).

     RETURN YES.
END METHOD.


/* this gets called when the caller wants us to get a lock on the _db
   so that no other user can make changes while we have the info cached 
*/
METHOD PUBLIC VOID getDbLock(INPUT lExclusive AS LOGICAL):

    /* if the first time, create the dynamic buffer object */
    IF NOT VALID-HANDLE(hDB) THEN
        CREATE BUFFER hDB FOR TABLE myEPolicy:LogicalDBName + "._Db" NO-ERROR.
    IF VALID-HANDLE(hDB) THEN DO:
        IF lExclusive  THEN
           hDB:FIND-FIRST("", EXCLUSIVE-LOCK) NO-ERROR.
        ELSE
           hDB:FIND-FIRST("", SHARE-LOCK) NO-ERROR.

        IF hDB:AVAILABLE THEN
           hDB:BUFFER-RELEASE().
    END.

END METHOD.

/* This is called through the load process to fix up the object number on the records in the
   temp-table before going through with the update of the policies.
*/
METHOD PRIVATE LOGICAL cacheFixObjNumBeforeUpdate():
   DEFINE VARIABLE cTable   AS CHAR    NO-UNDO.
   DEFINE VARIABLE cObj     AS CHAR    NO-UNDO.
   DEFINE VARIABLE fixedAll AS LOGICAL NO-UNDO INIT YES.

   DEFINE VARIABLE hFile  AS HANDLE NO-UNDO.
   DEFINE VARIABLE hField AS HANDLE NO-UNDO.
   DEFINE VARIABLE hIndex AS HANDLE NO-UNDO.

   /* go through changed records and see if we have any recors to fix up.
      Note that they will still remain invalid if there is a transaction outside the
      load process
    */
   FOR EACH bfttObjAttrs.
         FIND FIRST ttObjAttrs WHERE ROWID(ttObjAttrs) = BUFFER bfttObjAttrs:AFTER-ROWID.
         /* they should be different, but in any case... */
         IF ttObjAttrs.obj-cipher NE bfttObjAttrs.obj-cipher THEN DO:
             IF ttObjAttrs.obj-num = ? THEN DO:
                 /* this is the case where the table/field/index was newly created. Need to
                    refind the _File record and get the obj number.
                 */
                 ASSIGN cTable = ENTRY(1,ttObjAttrs.obj-name,".").
                 IF ttObjAttrs.obj-type NE {&TABLE_TYPE} THEN
                     ASSIGN cObj = ENTRY(2,ttObjAttrs.obj-name,".").

                 IF NOT VALID-HANDLE(hFile) THEN DO:
                     /* will assume that by now we can create the buffer */
                     CREATE BUFFER hFile FOR TABLE myEPolicy:LogicalDBName + "._File".
                 END.

                 hFile:FIND-FIRST("where _File-name = " + QUOTER(ctable), NO-LOCK).
                 IF hFile::_File-number > 0 THEN DO:
                     IF ttObjAttrs.obj-type = {&TABLE_TYPE} THEN
                        ttObjAttrs.obj-num = hFile::_File-number.
                     ELSE IF ttObjAttrs.obj-type = {&INDEX_TYPE} THEN DO:
                         IF NOT VALID-HANDLE(hIndex) THEN DO:
                             /* will assume that by now we can create the buffer */
                             CREATE BUFFER hIndex FOR TABLE myEPolicy:LogicalDBName + "._Index".
                         END.

                         hIndex:FIND-FIRST("where _Index-name = " + QUOTER(cObj) 
                                           + " AND _File-recid = " + STRING(hFile:RECID), NO-LOCK).

                         IF hIndex::_Idx-num > 0 THEN DO:
                             ttObjAttrs.obj-num = hIndex::_Idx-num.
                         END.
                         ELSE
                             fixedAll = NO.
                     END.
                     ELSE DO: /* lobs */
                         IF NOT VALID-HANDLE(hField) THEN DO:
                             /* will assume that by now we can create the buffer */
                             CREATE BUFFER hField FOR TABLE myEPolicy:LogicalDBName + "._Field".
                         END.

                         hField:FIND-FIRST("where _Field-name = " + QUOTER(cObj) 
                                           + " AND _File-recid = " + STRING(hFile:RECID), NO-LOCK).

                         /* for lobs, the _Fld-stlen field is set to the area number upon creation. So
                            it won't be zero, and I can't assume that it hasn't been created if
                            it's the area number, since it may have gotten it once it got created.
                         */
                         ttObjAttrs.obj-num = hField::_Fld-stlen.
                     END.
                 END.
                 ELSE
                     fixedAll = NO.
             END.
         END.
         ELSE DO:
             /* if cipher name is the same, reject the change */
             BUFFER bfttObjAttrs:REJECT-ROW-CHANGES().
         END.
   END.

   IF VALID-HANDLE(hFile) THEN
       DELETE OBJECT hFile.
   IF VALID-HANDLE(hField) THEN
       DELETE OBJECT hField.
   IF VALID-HANDLE(hIndex) THEN
       DELETE OBJECT hIndex.

   RETURN fixedAll.

END METHOD.

/* Database reference-free code to look for objects in the db (table/index/lobs),
   and add them to the temp-table with the encryption policy info.
   We use the db passed to the constructor.
*/
METHOD PRIVATE VOID findAndAdd(INPUT numMode AS LOGICAL, INPUT objNum AS INT, 
                               INPUT objName AS CHAR, INPUT objectType AS CHAR):
    DEFINE VARIABLE cTable AS CHAR NO-UNDO.
    DEFINE VARIABLE cObj   AS CHAR NO-UNDO.

    DEFINE VARIABLE hFile  AS HANDLE NO-UNDO.
    DEFINE VARIABLE hField AS HANDLE NO-UNDO.
    DEFINE VARIABLE hIndex AS HANDLE NO-UNDO.

    CREATE BUFFER hFile FOR TABLE myEPolicy:LogicalDBName + "._File" NO-ERROR.
    IF NOT VALID-HANDLE(hFile) THEN
       RETURN.

    IF NOT numMode THEN DO:
       /* It must be a string for table, or table.obj-name for indexes and LOBs */
       ASSIGN ctable = ENTRY(1,objName, ".").
       IF objectType NE {&TABLE_TYPE} THEN DO:
          IF NUM-ENTRIES(objName,".") = 2 THEN
             cObj = ENTRY(2,objName, ".").
       END.
    END.

    hFile:FIND-FIRST("where " 
                     + (IF numMode THEN "_File-number = " + STRING(objNum) 
                        ELSE "_File-name = " + QUOTER(ctable)) 
                     + " AND _Owner = 'PUB'" 
                     + (IF numMode THEN "" ELSE " USE-INDEX _File-name"), NO-LOCK) NO-ERROR.

    IF hFile:AVAILABLE AND (hFile::_File-name BEGINS "_aud-" OR
          (hFile::_File-number > 0 AND hFile::_file-number < 32000)) THEN DO:

       IF objectType = {&TABLE_TYPE} THEN
          addIfEncryptable(INPUT hFile::_File-number,
                           INPUT hFile::_File-name,
                           INPUT hFile::_ianum,
                           INPUT {&TABLE_TYPE},
                           INPUT YES).
       ELSE IF objectType = {&INDEX_TYPE} THEN DO:

          CREATE BUFFER hIndex FOR TABLE myEPolicy:LogicalDBName + "._Index" NO-ERROR.
          IF NOT VALID-HANDLE(hIndex) THEN DO:
            DELETE OBJECT hFile NO-ERROR.
            RETURN.
          END.

          hIndex:FIND-FIRST("where " 
                            + (IF numMode THEN "_Idx-num = " + STRING(objNum) 
                               ELSE "_Index-name = " + QUOTER(cObj) + " AND _File-recid = " + STRING(hFile:RECID)) 
                            + (IF numMode THEN "" ELSE " USE-INDEX _File/Index"), NO-LOCK) NO-ERROR.
          IF hIndex:AVAILABLE THEN
             addIfEncryptable(INPUT hIndex::_Idx-num,
                              INPUT hFile::_File-name 
                                  + "." + hIndex::_Index-name,
                              INPUT hIndex::_ianum,
                              INPUT {&INDEX_TYPE},
                              INPUT YES).
       END.
       ELSE IF objectType = {&CLOB_TYPE} OR objectType = {&BLOB_TYPE} THEN DO:
           CREATE BUFFER hField FOR TABLE myEPolicy:LogicalDBName + "._Field" NO-ERROR.
           IF NOT VALID-HANDLE(hField) THEN DO:
              DELETE OBJECT hFile NO-ERROR.
              RETURN.
           END.

           hField:FIND-FIRST("where _Data-type = " + QUOTER(objectType) + " AND "
                             + (IF numMode THEN "_Fld-stlen = " + STRING(objNum) 
                                ELSE "_Field-name = " + QUOTER(cObj) + " AND _File-recid = " + STRING(hFile:RECID)) 
                             + (IF numMode THEN "" ELSE " USE-INDEX _File/_Field"), NO-LOCK) NO-ERROR.
           IF hField:AVAILABLE THEN
              addIfEncryptable(INPUT hField::_Fld-stlen,
                               INPUT hFile::_File-name
                                     + "." + hField::_Field-name,
                               INPUT ?,
                               INPUT hField::_Data-type,
                               INPUT YES).
       END.
    END.

    IF VALID-HANDLE(hFile) THEN
        DELETE OBJECT hFile.
    IF VALID-HANDLE(hField) THEN
        DELETE OBJECT hField.
    IF VALID-HANDLE(hIndex) THEN
        DELETE OBJECT hIndex.
END METHOD.

METHOD PRIVATE VOID addObject(INPUT objNum AS INTEGER, 
                              INPUT objName AS CHAR, 
                              INPUT objArea AS INT,
                              INPUT objType AS CHAR,
                              INPUT getCurrPolicyInfo AS LOGICAL):

    CREATE ttObjAttrs.
    ASSIGN ttObjAttrs.seq-num = nextSeqNum
           ttObjAttrs.obj-num = objNum
           ttObjAttrs.obj-type = objType
           ttObjAttrs.obj-name = objName
           ttObjAttrs.obj-area = objArea.

    IF getCurrPolicyInfo THEN DO:
       fillPolicyInfo(INPUT ttObjAttrs.seq-num,
                      INPUT objName,
                      INPUT objType, 
                      INPUT NO). /* fill policy versions table */

       IF EncryptionEnabledOnly THEN DO:
           /* if we are interested only on objs with encryption enabled, 
              get rid of record if there is no policy or current policy is 
              'disabled' .
           */
           IF ttObjAttrs.obj-cipher = ? OR
              ttObjAttrs.obj-cipher = "" THEN
              DELETE ttObjAttrs.
       END.


    END.
    CATCH e AS PROGRESS.Lang.ProError:
        /* temp-table is no-undo, so if we failed to create the record, just 
           delete it now, and throw the exception to the caller which will get
           thrown all the way to the driver procedure.
        */
        DELETE ttObjAttrs NO-ERROR.
        UNDO, THROW e.
    END.
END METHOD.


METHOD PRIVATE VOID addIfEncryptable(INPUT objNum AS INT,
                                     INPUT fullName AS CHAR,
                                     INPUT objArea AS INT,
                                     INPUT objectType AS CHAR,
                                     INPUT getCurrPolicyInfo AS LOGICAL):

DEFINE VARIABLE hStorage  AS HANDLE NO-UNDO.
DEFINE VARIABLE cTmp      AS CHAR   NO-UNDO.
DEFINE VARIABLE cType     AS CHAR   NO-UNDO.
DEFINE VARIABLE tableName AS CHAR   NO-UNDO.
DEFINE VARIABLE objName   AS CHAR   NO-UNDO.

   ASSIGN tableName = ENTRY(1,fullName,".").

   IF NUM-ENTRIES(fullName,".") > 1 THEN
      objName = ENTRY(2,fullName,".").

   IF (objectType = {&TABLE_TYPE} AND myEPolicy:IsTableEncryptable(tableName)) OR
      (objectType = {&INDEX_TYPE} AND myEPolicy:IsIndexEncryptable(tableName, objName)) OR 
      ((objectType = {&CLOB_TYPE} OR objectType = {&BLOB_TYPE}) AND myEPolicy:IsLOBEncryptable(tableName, objName)) THEN
   DO:
       /* find the area num*/
      IF FillAreaNum THEN DO:
         /* for lobs and _aud- tables, we have to always find the area through the
             _Storageobject table.
         */
         IF objectType = {&CLOB_TYPE} OR objectType = {&BLOB_TYPE} OR objArea = ? THEN DO:
              IF objectType = {&TABLE_TYPE} THEN
                  cType = "1".
              ELSE IF objectType = {&INDEX_TYPE} THEN
                  cType = "2".
              ELSE
                  cType = "3".
                  
              ASSIGN cTmp= myEpolicy:LogicalDBName  + "._Storageobject".
              CREATE BUFFER hStorage FOR TABLE cTmp NO-ERROR.
              IF VALID-HANDLE(hStorage) THEN DO:
                  hStorage:FIND-FIRST("where _Object-type = " + cType + " AND _Object-number = "
                                      + STRING(objNum), NO-LOCK) NO-ERROR.
                  IF hStorage:AVAILABLE THEN DO:
                     objArea = hStorage::_Area-number.
                     hStorage:BUFFER-RELEASE().
                  END.
                  DELETE OBJECT hStorage NO-ERROR.
              END.
         END.
      END.

      addObject(INPUT objNum,
                INPUT fullName,
                INPUT objArea,
                INPUT objectType,
                INPUT getCurrPolicyInfo).
   END.
END METHOD.

METHOD PRIVATE VOID fillPolicyInfo(INPUT seqNum AS INT,
                                   INPUT fullName AS CHAR, 
                                   INPUT objType AS CHAR,
                                   INPUT fillVersions AS LOGICAL): /* fill policy versions table */

    DEFINE VARIABLE i         AS INTEGER NO-UNDO.
    DEFINE VARIABLE b         AS LOGICAL NO-UNDO.
    DEFINE VARIABLE tableName AS CHAR    NO-UNDO.
    DEFINE VARIABLE objName   AS CHAR    NO-UNDO.

    ASSIGN tableName = ENTRY(1,fullName, ".").

    IF NUM-ENTRIES(fullName,".") > 1 THEN
       objName = ENTRY(2,fullName, ".").

    IF objType = {&TABLE_TYPE} THEN DO:
        b = myEPolicy:GetTablePolicies (INPUT tableName, 
                                        OUTPUT TablePolicies).

        DO I = 1 TO EXTENT (TablePolicies):
           getPolicyInfo(INPUT CAST(TablePolicies[I],"Progress.Security.DB.Policy"),
                         INPUT seqNum,
                         INPUT fillVersions).
          DELETE OBJECT TablePolicies[I].
        END.

        /* reset extent size */
        EXTENT (TablePolicies) = ?.
    END.
    ELSE IF objType = {&INDEX_TYPE} THEN DO:
        b = myEPolicy:GetIndexPolicies (INPUT tableName, 
                                        INPUT objName,
                                        OUTPUT IndexPolicies).

        DO I = 1 TO EXTENT (IndexPolicies):
           getPolicyInfo(INPUT CAST(IndexPolicies[I],"Progress.Security.DB.Policy"),
                         INPUT seqNum,
                         INPUT fillVersions).
           DELETE OBJECT IndexPolicies[I].
        END.

        /* reset extent size */
        EXTENT (IndexPolicies) = ?.
    END.
    ELSE IF objType = {&CLOB_TYPE} OR objType = {&BLOB_TYPE} THEN DO:
        b = myEPolicy:GetLobPolicies (INPUT tableName, 
                                      INPUT objName, 
                                      OUTPUT LobPolicies).

        DO I = 1 TO EXTENT (LobPolicies):
           getPolicyInfo(INPUT CAST(LobPolicies[I],"Progress.Security.DB.Policy"),
                         INPUT seqNum,
                         INPUT fillVersions).
           DELETE OBJECT LobPolicies[I].
        END.
        /* reset extent size */
        EXTENT (LobPolicies) = ?.

    END.

END METHOD.

METHOD PRIVATE VOID getPolicyInfo(INPUT policyObj AS Progress.Security.DB.Policy,
                                  INPUT seqNum       AS INTEGER,
                                  INPUT fillVersions AS LOGICAL):
    
    /* we set cipher as an empty string, when disabled. Also, record whether we find
      a previous policy.*/
    IF policyObj:PolicyState = "Current" THEN DO:
       IF policyObj:CipherName NE "NULL_NULL_NULL" THEN
          ttObjAttrs.obj-cipher = policyObj:CipherName.
    END.
    ELSE IF policyObj:PolicyState = "Previous" THEN
        ttObjAttrs.has-prev-pol = YES.
     
    /* check if we need to add policy records too */
    IF fillVersions THEN DO:
       /* make sure we never add 2 records for the same obj and version */
       /* seq-num is unique for each object name. object name may not be unique
          if you have a LOB column and an index with the same name on the same
          table.
       */
       FIND FIRST ttObjEncPolicyVersions WHERE ttObjEncPolicyVersions.seq-num  = ttObjAttrs.seq-num 
           AND ttObjEncPolicyVersions.pol-version = policyObj:VersionNumber NO-ERROR.
       IF NOT AVAILABLE ttObjEncPolicyVersions THEN DO:
           CREATE ttObjEncPolicyVersions.
           ASSIGN ttObjEncPolicyVersions.obj-name = ttObjAttrs.obj-name
                  /* seq-num is unique for each object name. object name may 
                     not be unique if you have a LOB column and an index with
                     the same name on the same table.
                  */
                  ttObjEncPolicyVersions.seq-num = seqNum
                  ttObjEncPolicyVersions.pol-version = policyObj:VersionNumber
                  ttObjEncPolicyVersions.pol-state = policyObj:PolicyState.

           IF policyObj:CipherName NE "NULL_NULL_NULL" THEN
               ttObjEncPolicyVersions.pol-cipher = policyObj:CipherName.
           ELSE
               ttObjEncPolicyVersions.pol-cipher = "Disabled".
       END.
    END.
END METHOD.

DESTRUCTOR _sec-pol-util():

    IF VALID-HANDLE (hDb) THEN
       DELETE OBJECT hDB.

    IF VALID-OBJECT(myEPolicy) THEN
       DELETE OBJECT myEPolicy.
END DESTRUCTOR.

END CLASS.


