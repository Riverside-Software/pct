/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : FieldDataSource
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sep 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.DataSource.DataSource.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.DataSource.FieldDataSource inherits DataSource: 
    define protected variable AreaUrl as char no-undo init "/areas/".
    define protected variable mBuffer as handle no-undo.
  
 
	define private variable mMapping as char
	   init  	   
"Name,_field-name,~
TableName,_file-name,~
DataType,_data-type,~
Description,_field._desc,~
trowid,rowid(_Field),~
IsMultiTenant,_File-attributes[1]"
 no-undo.
/*
Description,_Desc,~
SideLabel,_Label,~
IsMultiTenant,_File._file-attributes[1],~
ColumnLabel,_Col-label,~
Order,_Order,~
IsMandatory,_Mandatory" no-undo.
*/
	
	constructor public FieldDataSource (pcurl as char):        
        this-object ( ).   
        url = pcURL.
        AreaURL = pcURL + AreaURL.
    end constructor.
    
    constructor public FieldDataSource (hchanges as handle ):     
        super (hchanges,"_File,_Field","dictdb._File,dictdb._Field", 
               "Name,ttFieldChange.Fieldname,ttField.TableName,ttFieldChange.Tablename,DataType,_data-type,trowid,rowid(_Field),IsMultiTenant,_File-attributes[1]").
       
        BaseQuery = "for each ttFieldChange, each _file where _file._file-name = ttFieldChange.Tablename "
                  + " and " + DatabaseInfo:FileExpression + " no-lock,"
                  + " each _field of _file where  _field-name = ttFieldChange.Fieldname and (_field._data-type ='clob' or _field._data-type ='blob') no-lock" .
    end constructor.
    
    constructor public FieldDataSource ( ):	    
        super ("_File,_Field","dictdb._File,dictdb._Field", mMapping).	
/*		BaseQuery = "for each _file no-lock, each _field of _file  no-lock ".*/
        BaseQuery = "for each _file where " + DatabaseInfo:FileExpression  +  " no-lock, each _field of _file where (_field._data-type ='clob' or _field._data-type ='blob') no-lock ".
    end constructor.
    
    method public override logical Prepare(phBuffer as handle,pcTargetQuery as char,pcJoin as char):
        phBuffer:set-callback("After-Row-fill","AfterFieldRow").
        super:Prepare(phBuffer,pcTargetQuery,pcJoin).
        mBuffer = phBuffer.
    end method.
    
    method public void AfterFieldRow(dataset-handle hds):
        define variable cArea as character no-undo.
        define variable cAreaRef as character no-undo.
        define variable iSource as integer no-undo.
        assign 
            cArea = ""
            cAreaRef = ""
            iSource = lookup("_Field",Tables).
        
        find dictdb._field where recid(dictdb._field) = DataSourceHandle:get-source-buffer(iSource):recid no-lock.
        find dictdb._file of _field no-lock.
        
        if dictdb._file._file-attributes[1] = false 
        or dictdb._file._file-attributes[2] = true then
        do:
            find dictdb._storage where dictdb._storage._db-recid = dictdb._file._db-recid
                                   and dictdb._storage._object-type = 3                                     
                                   and dictdb._storage._object-number = dictdb._field._Fld-stlen
                                   and dictdb._storage._Partitionid = 0
                                   no-lock no-error.
                     
            if avail dictdb._storage then
            do:
                find dictdb._area where dictdb._Area._Area-number
                                      =  dictdb._storage._Area-number no-lock.   
                assign
                    cArea    = dictdb._area._area-name       
                    cAreaRef = AreaURL + WebUtil:UrlEncode(dictdb._Area._Area-name,"default"). 
          end.
        end. 
        assign
            mBuffer::AreaName = cArea
            mBuffer::AreaURL  = cAreaRef.
    end method.
    
    method private integer SaveField(phbuffer as handle):
        
        
        define variable ierror as integer no-undo.
        define variable imod as character no-undo.
 
        /* define input-output paramete minimum-index as integer.*/

        define variable scrap    as character no-undo.
        define variable fldrecid as recid     no-undo.
        define variable fldrpos  as integer   no-undo.
    
        define variable i        as integer   no-undo.
        define variable gotError as logical   no-undo.
        define variable freeOrder as int      no-undo.

        if phbuffer:row-state = row-created then 
            imod = "a".    
        else if phbuffer:row-state = row-deleted then 
            imod = "d".    
        else do:
        
        end. 
        
        find dictdb._File where recid(dictdb._File) = phbuffer::TableName no-error.
        
        if not available dictdb._File then 
            return ?.
            
        if dictdb._File._Frozen THEN
            ierror = 14. /* "Cannot alter field from frozen file" */
        IF dictdb._File._Db-lang = 1 AND imod <> "m" THEN
            ierror = 15. /* "Use SQL ALTER TABLE to change field" */
        IF ierror > 0 then 
            return iError.

        DO ON ERROR UNDO, LEAVE: /* OE00158774 */

            ASSIGN gotError = YES.
            IF imod <> "a" THEN
                FIND dictdb._Field OF dictdb._File
                    WHERE dictdb._Field._Field-name = phBuffer::TableName. /* proven to exist */
    /*
    IF imod = "a" THEN DO: /*---------------------------------------------------*/
      IF CAN-FIND(dictb._Field WHERE dictdb._Field._File-recid = recid(db._File)
                               AND _Field._Field-name = wfld._Field-name) THEN
        ierror = 7. /* "&2 already exists with name &3" */
      IF wfld._Data-type = "CLOB" AND
        (wfld._Charset = ? OR wfld._Collation = ?) THEN
        ierror = 46.
    
      /* OE00177533 - make sure attributes1 is correct based on column and db codepage */
      IF wfld._Data-type = "CLOB" AND wfld._Attributes1 = 1 THEN DO:
         FIND _Db WHERE RECID(_Db)= _File._Db-recid.
         /* if codepages don't match, then this must be 2 in spite of what the .df has */
         IF UPPER(wfld._Charset) NE UPPER(_Db._db-xl-name) THEN
            wfld._Attributes1 = 2.
      END.
    
      /* allow int64 for 10.1B an later */
      IF LOOKUP(wfld._Data-type,"CHARACTER,CHAR,DATE,DECIMAL,DEC,INTEGER,INT,LOGICAL,DATETIME,DATETIME-TZ,BLOB,CLOB,RAW,RECID"
                                + (IF NOT is-pre-101b-db THEN ",INT64" ELSE "")) = 0 THEN 
        ASSIGN ierror = 47.
    
      IF (wfld._Data-type = "CLOB" OR wfld._Data-type = "BLOB") AND 
          wfld._Extent > 0 THEN
          ierror = 55.
    
      IF ierror > 0 THEN RETURN.
    
      IF wfld._Order = ? THEN DO:
        FIND LAST _Field WHERE _Field._File-recid = drec_file
          USE-INDEX _field-position NO-ERROR.
        wfld._Order = (IF AVAILABLE _Field THEN _Field._Order ELSE 0) + 10.
      END.
      /* existing order! */
      IF CAN-FIND(_Field WHERE _Field._File-recid = drec_file
        AND _Field._Order = wfld._Order) THEN
        RUN bump_sub (wfld._Order).
    
      IF gate_dbtype <> "PROGRESS" THEN DO:
        wfld._Fld-stdtype = ?.
        RUN VALUE(gate_proc) (
          INPUT-OUTPUT wfld._Fld-stdtype,
          INPUT-OUTPUT wfld._Fld-stlen,
          INPUT-OUTPUT wfld._Data-type,
          INPUT-OUTPUT wfld._For-type,
          OUTPUT scrap).
    
        /* check if found valid type */
        IF wfld._For-type = ? or wfld._For-type = "" THEN DO:
           ierror = 59.
           RETURN.
        END.
    
        IF wfld._Format = ? THEN wfld._Format = scrap.
      END.
    
      CREATE _Field.
      ASSIGN
        _Field._File-recid = drec_file
        _Field._Field-name = wfld._Field-name
        _Field._Data-type  = wfld._Data-type
        _Field._Order      = wfld._Order NO-ERROR.
    
      { prodict/dump/copy_fld.i &from=wfld &to=_Field &all=false}
    
      fldrecid = RECID(_Field).
      IF wfld._Format  <> ?  THEN _Field._Format  = wfld._Format.
      
      IF wfld._Initial <> "" THEN DO:
          /* check for overflow (in case this is an int/int64 field */
          ASSIGN _Field._Initial = wfld._Initial NO-ERROR. 
          IF ERROR-STATUS:ERROR THEN DO:
            ierror = 52.
            RETURN.
          END.
      END.
      
      IF wfld._Field-rpos <> ? THEN _Field._Field-rpos = wfld._Field-rpos.
      IF wfld._Width <> ? THEN _Field._Width = wfld._Width.
      IF wfld._Charset <> ? THEN _Field._Charset = wfld._Charset.
      IF wfld._Collation <> ? THEN _Field._Collation = wfld._Collation.
      IF wfld._Attributes1 <> 0 AND wfld._Attributes1 <> ? THEN _Field._Attributes1 = wfld._Attributes1.
    
    END. /*---------------------------------------------------------------------*/
    ELSE
    IF imod = "m" THEN DO: /*---------------------------------------------------*/
      IF _Field._Data-type <> wfld._Data-type THEN DO:
        /* allow integer to int64 updates for 10.1B and later */
        IF (_Field._Data-type = "int" OR _Field._Data-type = "integer") AND 
            wfld._Data-type = "int64" AND NOT is-pre-101b-db THEN
            _Field._Data-type  = wfld._Data-type.
        ELSE
            ierror = 10. /* "Cannot change datatype of existing field" */
      END.
      IF _Field._Extent <> wfld._Extent THEN
        ierror = 11. /* "Cannot change extent of existing field" */
      IF ierror > 0 THEN RETURN.
    
      /* OE00177533 - make sure attributes1 is correct based on column and db codepage */
      IF _Field._Data-type = "CLOB" AND 
         _Field._Attributes1 = 2  AND wfld._Attributes1 = 1 THEN DO:
         FIND _Db WHERE RECID(_Db)= _File._Db-recid.
         /* if codepages don't match, then this must be 2 in spite of what the .df has */
         IF UPPER(_Field._Charset) NE UPPER(_Db._db-xl-name) THEN
            wfld._Attributes1 = _Field._Attributes1.
      END.
    
      /* existing order! */
      IF _Field._Order <> wfld._Order
        AND CAN-FIND(_Field WHERE _Field._File-recid = drec_file
          AND _Field._Order = wfld._Order) THEN
        RUN bump_sub (wfld._Order).
    
      IF gate_dbtype <> "PROGRESS" THEN DO:
        wfld._Fld-stdtype = ?.
        RUN VALUE(gate_proc) (
          INPUT-OUTPUT wfld._Fld-stdtype,
          INPUT-OUTPUT wfld._Fld-stlen,
          INPUT-OUTPUT wfld._Data-type,
          INPUT-OUTPUT wfld._For-type,
          OUTPUT scrap).
        IF wfld._Format = ? THEN wfld._Format = scrap.
      END.
    
      IF _File._Db-lang = 0 THEN DO:
        IF COMPARE(_Field._Can-write,"NE",wfld._Can-write,"RAW") THEN _Field._Can-write     = wfld._Can-write.
        IF COMPARE(_Field._Can-read,"NE",wfld._Can-read,"RAW")   THEN _Field._Can-read      = wfld._Can-read.
        IF _Field._Mandatory   <> wfld._Mandatory    THEN _Field._Mandatory     = wfld._Mandatory.
        IF _Field._Decimals    <> wfld._Decimals     THEN _Field._Decimals      = wfld._Decimals.
      END.
      ELSE IF _file._db-lang = 1 THEN DO:
        IF COMPARE(_Field._Can-write,"NE",wfld._Can-write,"RAW") OR
           COMPARE(_Field._Can-read,"NE",wfld._Can-read,"RAW")   OR
           _Field._Mandatory   <> wfld._Mandatory  OR
           _Field._Decimals    <> wfld._Decimals   THEN
           ASSIGN iwarnlst = iwarnlst + "23,"
                  ierror = 50.
      END.
    
      IF COMPARE(_Field._Col-label,"NE",wfld._Col-label,"RAW")  THEN _Field._Col-label     = wfld._Col-label.
      IF COMPARE(_Field._Col-label-SA,"NE",wfld._Col-label-SA,"RAW") THEN _Field._Col-label-SA  = wfld._Col-label-SA.
      IF COMPARE(_Field._Desc,"NE",wfld._Desc,"RAW")            THEN _Field._Desc          = wfld._Desc.
      IF COMPARE(_Field._Format,"NE",wfld._Format,"RAW")        THEN _Field._Format        = wfld._Format.
      IF COMPARE(_Field._Format-SA,"NE",wfld._Format-SA,"RAW")  THEN _Field._Format-SA     = wfld._Format-SA.
      IF COMPARE(_Field._Help,"NE",wfld._Help,"RAW")            THEN _Field._Help          = wfld._Help.
      IF COMPARE(_Field._Help-SA ,"NE",wfld._Help-SA,"RAW")     THEN _Field._Help-SA       = wfld._Help-SA.
      IF COMPARE(_Field._Initial,"NE",wfld._Initial,"RAW")      THEN _Field._Initial       = wfld._Initial.
      IF COMPARE(_Field._Initial-SA,"NE",wfld._Initial-SA,"RAW") THEN _Field._Initial-SA    = wfld._Initial-SA.
      IF COMPARE(_Field._Label,"NE",wfld._Label,"RAW")          THEN _Field._Label         = wfld._Label.
      IF COMPARE(_Field._Label-SA,"NE",wfld._Label-SA,"RAW")    THEN _Field._Label-SA      = wfld._Label-SA.
      IF _Field._Field-rpos    <> wfld._Field-rpos              THEN _Field._Field-rpos    = wfld._Field-rpos.
      IF COMPARE(_Field._Valexp,"NE",wfld._Valexp,"RAW")        THEN _Field._Valexp        = wfld._Valexp.
      IF _Field._Valmsg        <> wfld._Valmsg                  THEN _Field._Valmsg        = wfld._Valmsg.
      IF COMPARE(_Field._Valmsg-SA,"NE",wfld._Valmsg-SA,"RAW")  THEN _Field._Valmsg-SA     = wfld._Valmsg-SA.
      IF COMPARE(_Field._View-as,"NE",wfld._View-as,"RAW")      THEN _Field._View-as       = wfld._View-as.
    
      IF _Field._Fld-case      <> wfld._Fld-case                THEN DO:
       IF NOT CAN-FIND(FIRST _Index-field OF _Field) THEN _Field._Fld-case     = wfld._Fld-case.
       ELSE 
           ASSIGN iwarnlst = iwarnlst + "24,"
                  ierror = 50.
      END.
    
      IF _Field._Fld-stlen     <> wfld._Fld-stlen               THEN _Field._Fld-stlen     = wfld._Fld-stlen.
      IF _Field._Fld-stoff     <> wfld._Fld-stoff               THEN _Field._Fld-stoff     = wfld._Fld-stoff.
      IF _Field._Fld-stdtype   <> wfld._Fld-stdtype             THEN _Field._Fld-stdtype   = wfld._Fld-stdtype.
      IF _Field._For-Id        <> wfld._For-Id                  THEN _Field._For-Id        = wfld._For-Id.
      IF _Field._For-Name      <> wfld._For-Name                THEN _Field._For-Name      = wfld._For-Name.
      IF _Field._For-Type      <> wfld._For-Type                THEN _Field._For-Type      = wfld._For-Type.
      IF _Field._For-Xpos      <> wfld._For-Xpos                THEN _Field._For-Xpos      = wfld._For-Xpos.
      IF _Field._For-Itype     <> wfld._For-Itype               THEN _Field._For-Itype     = wfld._For-Itype.
      IF _Field._For-Retrieve  <> wfld._For-Retrieve            THEN _Field._For-Retrieve  = wfld._For-Retrieve.
      IF _Field._For-Scale     <> wfld._For-Scale               THEN _Field._For-Scale     = wfld._For-Scale.
      IF _Field._For-Spacing   <> wfld._For-Spacing             THEN _Field._For-Spacing   = wfld._For-Spacing.
      IF _Field._For-Separator <> wfld._For-Separator           THEN _Field._For-Separator = wfld._For-Separator.
      IF _Field._For-Allocated <> wfld._For-Allocated           THEN _Field._For-Allocated = wfld._For-Allocated.
      IF _Field._For-Maxsize   <> wfld._For-Maxsize             THEN _Field._For-Maxsize   = wfld._For-Maxsize.
      IF _Field._Fld-misc2[1]  <> wfld._Fld-misc2[1]            THEN _Field._Fld-misc2[1]  = wfld._Fld-misc2[1].
      IF _Field._Fld-misc2[2]  <> wfld._Fld-misc2[2]            THEN _Field._Fld-misc2[2]  = wfld._Fld-misc2[2].
      IF _Field._Fld-misc2[3]  <> wfld._Fld-misc2[3]            THEN _Field._Fld-misc2[3]  = wfld._Fld-misc2[3].
      IF _Field._Fld-misc2[4]  <> wfld._Fld-misc2[4]            THEN _Field._Fld-misc2[4]  = wfld._Fld-misc2[4]. 
      IF _Field._Fld-misc2[5]  <> wfld._Fld-misc2[5]            THEN _Field._Fld-misc2[5]  = wfld._Fld-misc2[5].
      IF _Field._Fld-misc2[6]  <> wfld._Fld-misc2[6]            THEN _Field._Fld-misc2[6]  = wfld._Fld-misc2[6].
      IF _Field._Fld-misc2[7]  <> wfld._Fld-misc2[7]            THEN _Field._Fld-misc2[7]  = wfld._Fld-misc2[7].
      IF _Field._Fld-misc2[8]  <> wfld._Fld-misc2[8]            THEN _Field._Fld-misc2[8]  = wfld._Fld-misc2[8].
      IF _Field._Fld-misc1[1]  <> wfld._Fld-misc1[1]            THEN _Field._Fld-misc1[1]  = wfld._Fld-misc1[1].
      IF _Field._Fld-misc1[2]  <> wfld._Fld-misc1[2]            THEN _Field._Fld-misc1[2]  = wfld._Fld-misc1[2].
      IF _Field._Fld-misc1[3]  <> wfld._Fld-misc1[3]            THEN _Field._Fld-misc1[3]  = wfld._Fld-misc1[3].
      IF _Field._Fld-misc1[4]  <> wfld._Fld-misc1[4]            THEN _Field._Fld-misc1[4]  = wfld._Fld-misc1[4].
      IF _Field._Fld-misc1[5]  <> wfld._Fld-misc1[5]            THEN _Field._Fld-misc1[5]  = wfld._Fld-misc1[5].
      IF _Field._Fld-misc1[6]  <> wfld._Fld-misc1[6]            THEN _Field._Fld-misc1[6]  = wfld._Fld-misc1[6].
      IF _Field._Fld-misc1[7]  <> wfld._Fld-misc1[7]            THEN _Field._Fld-misc1[7]  = wfld._Fld-misc1[7].
      IF _Field._Fld-misc1[8]  <> wfld._Fld-misc1[8]            THEN _Field._Fld-misc1[8]  = wfld._Fld-misc1[8].
      
      IF wfld._Width <> ? AND _Field._Width <> wfld._Width      THEN 
          _Field._Width  = wfld._Width.
    
      IF _Field._Order <> wfld._Order THEN DO: 
          ASSIGN freeOrder = _Field._Order
                 _Field._Order = wfld._Order.
    
          /* OE00166224 - see if some other field wanted this order value */
          RUN retryOrder(INPUT freeOrder).
      END.
    
      /* OE00177533 - catch incorrect changes for clob fields - manual editing */
      IF _Field._data-type = "clob" THEN DO:
          IF (wfld._Charset   <> ? AND UPPER(_Field._Charset) NE UPPER(wfld._Charset)) OR
             (wfld._Collation <> ? AND UPPER(_Field._Collation) NE UPPER(wfld._Collation)) THEN DO:
              ASSIGN ierror = 66. /* Cannot change codepage or collation of existing column */
              RETURN.
          END.
    
          IF wfld._Attributes1 <> 0 AND wfld._Attributes1 <> ? THEN 
             _Field._Attributes1 = wfld._Attributes1.
      END.
    
      fldrecid = RECID(_Field).
    
    END. /*---------------------------------------------------------------------*/
    ELSE
    IF imod = "r" THEN DO: /*---------------------------------------------------*/
      IF CAN-FIND(FIRST _View-ref
        WHERE _View-ref._Ref-Table = _File._File-name
        AND _View-ref._Base-Col = _Field._Field-name) THEN
        ierror = 20. /* "Cannot &1 &2 referenced in SQL view" */
      IF CAN-FIND(FIRST _Field OF _File WHERE _Field._Field-name = irename
                                          AND RECID(_Field) <> RECID (_Field)) THEN
        ierror = 7. /* "&2 already exists with name &3" */
      IF ierror > 0 THEN RETURN.
      
      /* OE00166224 - if this field is in the list of fields to be reordered,
         change its name in the temp-table too.
      */
      FIND FIRST ttFldOrder WHERE ttFldOrder.FILE-NAME = _File._File-name AND
                 ttFldOrder.Field-Name = _Field._Field-Name NO-ERROR.
      IF AVAILABLE ttFldOrder THEN
         ttFldOrder.Field-Name = irename.
    
      /* finally, change the field name now */
      ASSIGN _Field._Field-name = irename.
    
    END. /*---------------------------------------------------------------------*/
    ELSE
    IF imod = "d" THEN DO: /*---------------------------------------------------*/
      IF CAN-FIND(FIRST _View-ref
        WHERE _View-ref._Ref-Table = _File._File-name
        AND _View-ref._Base-Col = _Field._Field-name) THEN
        ierror = 20. /* "Cannot &1 &2 referenced in SQL view" */
      IF ierror > 0 THEN RETURN.
    
      /* This moves the primary index if the field being deleted is */
      /* part of the primary index. */
      FIND FIRST _Index-field OF _Field
        WHERE _Index-field._Index-recid = _File._Prime-Index NO-ERROR.
      IF AVAILABLE _Index-field THEN
        FOR EACH _Index-field OF _Field,
          _Index OF _Index-field
            WHERE _File._Prime-Index <> RECID(_Index) AND _Index._Wordidx <> 1:
          _File._Prime-Index = RECID(_Index).
          LEAVE.
        END.
    
      /* Now complain if we can't find another index to serve as primary. */
      IF _File._Prime-Index <> ? AND _File._Prime-index = RECID(_Index) THEN
        ierror = 8. /* "Field being deleted is part of primary index" */
      IF ierror > 0 THEN RETURN.
    
      /* The following is a sneaky way to delete all index-field records */
      /* associated with a given field, using only one index cursor. */
      FIND FIRST _Index-field OF _Field NO-ERROR.
      DO WHILE AVAILABLE _Index-field:
        FIND _Index OF _Index-field.
        FOR EACH _Index-field OF _Index:
          DELETE _Index-field.
        END.
        kindexcache = kindexcache + "," + _Index._Index-name.
        DELETE _Index.
        FIND FIRST _Index-field OF _Field NO-ERROR.
      END.
    
      /* and remove associated triggers */
      FOR EACH _Field-trig OF _Field:
        DELETE _Field-trig.
      END.
    
      freeOrder = _Field._Order.
      DELETE _Field.
    
      /* OE00166224 - see if some other field wanted this order value */
      RUN retryOrder (INPUT freeOrder).
    
    END. /*---------------------------------------------------------------------*/
    
    /* update triggers */
    IF imod = "a" OR imod = "m" THEN DO:
      scrap = "".
      FOR EACH wflt:
        IF wflt._Proc-name = "!" THEN DO:
          DELETE wflt. /* triggers are deleted via .df when proc-name set to "!" */
          NEXT.
        END.
        FIND _Field-trig OF _Field WHERE _Field-trig._Event = wflt._Event NO-ERROR.
        FIND _Field WHERE RECID(_Field) = fldrecid.
        ASSIGN
          scrap = scrap + (IF scrap = "" THEN "" ELSE ",") + wflt._Event.
        IF AVAILABLE _Field-trig
          AND _Field-trig._Event     = wflt._Event
          AND _Field-trig._Override  = wflt._Override
          AND _Field-trig._Proc-name = wflt._Proc-name 
          AND _Field-trig._Trig-CRC  = wflt._Trig-CRC THEN NEXT.
        IF AVAILABLE _Field-trig THEN DELETE _Field-trig.
        CREATE _Field-trig.
        ASSIGN
          _Field-trig._File-recid  = drec_file
          _Field-trig._Field-recid = fldrecid
          _Field-trig._Event       = wflt._Event
          _Field-trig._Override    = wflt._Override
          _Field-trig._Proc-Name   = wflt._Proc-Name
          _Field-trig._Trig-CRC    = wflt._Trig-CRC.
      END.
      FOR EACH _Field-trig OF _Field WHERE NOT CAN-DO(scrap,_Field-trig._Event):
        DELETE _Field-trig.
      END.
    
    END.
    */
    ASSIGN gotError = NO.
    END.
    
    IF gotError THEN
       ierror = 56. /* generic error - some client error raised */
       
    RETURN iError.
    
end method.    
    
    
end class.