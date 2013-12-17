/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : FieldPermisssionDataSource
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sep 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.DataSource.DataSource.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath. 
using OpenEdge.DataAdmin.DataAccess.DataAccessError from propath.
routine-level on error undo, throw.

class OpenEdge.DataAdmin.DataSource.FieldPermissionDataSource inherits DataSource: 
    define protected variable AreaUrl as char no-undo init "/areas/".
    define protected variable mBuffer as handle no-undo.
  
/**/
	define private variable mMapping as char
	   init  	
"TableName,_file-name,~
SchemaName,_owner,~
Name,_field-name,~
CanWrite,_field._Can-write,~
CanRead,_field._Can-read,~
trowid,rowid(_Field)"
  no-undo.
 	
 	 define protected property FileQueryExpression as character no-undo 
        get():
            return  DatabaseInfo:FileDBExpression + " and  _file._owner = 'PUB'".
        end.
 	 
    constructor public FieldPermissionDataSource ( ):	    
       this-object (mMapping).	
    end constructor.
    
    constructor protected FieldPermissionDataSource (hParent as handle,pcMapping as char ):      
        super (hParent,"_Field,_File","dictdb._Field,dictdb._File", pcMapping).  
/*      BaseQuery = "for each _file no-lock, each _field of _file  no-lock ".*/
        BaseQuery = "for each _field no-lock, each _file of _field  where " + FileQueryExpression +  " no-lock".
    end constructor.

    constructor protected FieldPermissionDataSource (hParent as handle,pcTableJoin as char,pcFieldJoin as char,pcMapping as char ):      
        super (hParent,"_File,_Field","dictdb._File,dictdb._Field", pcMapping).  
/*      BaseQuery = "for each _file no-lock, each _field of _file  no-lock ".*/
        BaseQuery = "for each " + hParent:name + "," 
                  + " each _file where " + FileQueryExpression +  " and " + pctablejoin + " no-lock," 
                  + " each _field of _file where "  + pcFieldjoin + " no-lock".
     end   constructor.
  
    constructor public FieldPermissionDataSource (pcMapping as char ):      
        super ("_File,_Field","dictdb._File,dictdb._Field", pcMapping).  
/*      BaseQuery = "for each _file no-lock, each _field of _file  no-lock ".*/
        BaseQuery = "for each _file where " + FileQueryExpression +  " no-lock, each _field of _file no-lock ".
    end constructor.
  
    /* allow subclasses to override to set call back even if we don't have call back here */
    method protected logical SetCallBack(phBuffer as handle):
/*         phBuffer:set-callback("After-Row-fill","AfterFieldRow").*/
    end method.
  
    method public override final logical Prepare(phBuffer as handle,pcTargetQuery as char,pcJoin as char):
        define variable lok as logical no-undo.
        SetCallback(phBuffer).
        lok = super:Prepare(phBuffer,pcTargetQuery,pcJoin).
        mBuffer = phBuffer.
        return lok.       
    end method.
    /*
    method public void AfterFieldRow(dataset-handle hds):
         
        define variable iSource as integer no-undo.
        assign 
            iSource = lookup("_Field",Tables).
        
        find dictdb._field where recid(dictdb._field) = DataSourceHandle:get-source-buffer(iSource):recid no-lock.
        find dictdb._file of _field no-lock.
        mBuffer::TableName = dictdb._file._file-name.
    
        
    end method.
    */
    method public override logical Save(phbuffer as handle):
        define variable hDataset as handle no-undo. 
        define variable hBeforeBuff as handle    no-undo.
        define variable lok as logical no-undo.
        define variable hquery      as handle    no-undo.
        DEFINE VAR err as LOGICAL NO-UNDO INIT no.
        DEFINE VAR mod as LOGICAL NO-UNDO INIT no.
        DEFINE VAR ans as LOGICAL NO-UNDO.
        
        RUN "prodict/_dctadmn.p" (INPUT USERID("DICTDB"),OUTPUT ans).
        IF NOT ans THEN /* secu admin? */
             undo, throw new UnsupportedOperationError("You must be a Security Administrator to execute this function.").
                  
        create query hquery.
        hBeforeBuff = phBuffer:before-buffer.
        hquery:add-buffer(hBeforeBuff).
        hQuery:query-prepare("for each ttFieldPermissionCopy").    
        hquery:query-open().       
        hquery:get-first.             
        do transaction on error undo, throw:
            do while true:
            
                if not hBeforebuff:avail then 
                    leave.
                phBuffer:find-by-rowid (hBeforeBuff:after-rowid).
                /* avoid merge changes if not success set to false at end */ 
/*                phBuffer:error = true.*/
           
                if hBeforeBuff:row-state = row-deleted then 
                    undo, throw new UnsupportedOperationError("Delete of FieldPermission.").
                else if hBeforeBuff:row-state = row-created then 
                    undo, throw new UnsupportedOperationError("Create of FieldPermission.").
                phBuffer:find-by-rowid (hBeforeBuff:after-rowid).
                find dictdb._field where rowid(dictdb._field) = phBuffer::trowid exclusive no-wait.
               
                find dictdb._file where dictdb._file._File-name = phBuffer::TableName 
                                    and dictdb._file._owner = phBuffer::SchemaName exclusive no-wait.
                
               IF phBuffer::CanRead <> _Field._Can-read THEN DO:
                   mod = yes.
                   IF NOT CAN-DO(phBuffer::CanRead ,USERID("DICTDB")) THEN err = yes.
                END.
                IF NOT err AND phBuffer::CanWrite <> _Field._Can-write THEN DO:
                   mod = yes.
                   IF NOT CAN-DO(phBuffer::CanWrite ,USERID("DICTDB")) THEN err = yes.
                END.
                
                IF mod AND _File._Db-lang <> 0 THEN DO:
                     undo, throw new DataAccessError("You can only alter security on SQL tables with GRANT and REVOKE.").
                END.
                
                IF err THEN DO:
                     undo, throw new DataAccessError("You cannot change permissions to exclude yourself.").
                END.
                
                IF mod AND NOT err AND _File._Db-lang = 0 then
                assign 
                    dictdb._field._can-write = phBuffer::CanWrite
                    dictdb._field._can-read = phBuffer::CanRead.
/*                 if error-status:error then                                        */
/*                     undo, throw new DataAccessError(error-status:get-message (1)).*/
/*                                                                                   */
              
                hquery:get-next.    
            end.
        end. /* transaction */
        return true.   
        catch e as Progress.Lang.Error :             
             undo, throw new DataAccessError(e).
        end catch.
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
        ASSIGN gotError = NO.
    END.
        
    RETURN iError.
    
end method.    
    
    
end class.