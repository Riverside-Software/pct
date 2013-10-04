 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    File        : TablePermissionDataSource
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sat Sep 04 02:01:56 EDT 2010
    Notes       : BaseQuery does not filter on _hidden 
                  but does filter on _Owner = "PUB"
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.DataSource.DataSource.
using OpenEdge.DataAdmin.DataAccess.DataAccessError.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.DataSource.TablePermissionDataSource inherits DataSource: 
    
    define protected variable mBuffer as handle no-undo.
    
    define protected property FileQueryExpression as character no-undo 
        get():
            return  DatabaseInfo:FileDBExpression + " and  _file._owner = 'PUB'".
        end.
 
    define private variable mMapping as char
	   init  	   
"SchemaName,_Owner,~
Name,_File-name,~
trowid,rowid(_File),~
CanRead,_Can-read,~
CanWrite,_Can-write,~
CanCreate,_Can-create,~
CanDelete,_Can-delete,~
CanDump,_Can-dump,~
CanLoad,_Can-load,~
Frozen,_Frozen,~
Hidden,_Hidden"

/*Description,_Desc,~  */
/*DumpName,_Dump-name,~*/
/*DisplayName,_File-label"*/
 no-undo.
 
    constructor protected TablePermissionDataSource (hParent as handle,pmap as char ):       
        super (hParent,"_File","dictdb._File", pmap).   
        BaseQuery = "for each _file where " + FileQueryExpression + " no-lock". 
    end constructor.
    
    constructor public TablePermissionDataSource (pmap as char ):       
        super ("_File","dictdb._File", pmap).   
        BaseQuery = "for each _file where " + FileQueryExpression + " no-lock". 
    end constructor.
    
	constructor public TablePermissionDataSource ( ):	    
        this-object(mMapping).
    end constructor.
    
       /* allow subclasses to override to set call back even if we don't have call back here 
          (so that we can safely add it here later)*/
    method protected logical SetCallBack(phBuffer as handle):
/*         phBuffer:set-callback("After-Row-fill","AfterTableRow").*/
    end method.
  
    method public override final logical Prepare(phBuffer as handle,pcTargetQuery as char,pcJoin as char):
        define variable lok as logical no-undo.
        SetCallback(phBuffer).
        lok = super:Prepare(phBuffer,pcTargetQuery,pcJoin).
        mBuffer = phBuffer.    
/*        message queryhandle:prepare-string*/
/*        view-as alert-box.                */
        return lok.
    end method.
    
    method public override logical Save(phbuffer as handle):
        define variable hDataset as handle no-undo. 
        define variable hBeforeBuff as handle    no-undo.
        
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
        hQuery:query-prepare("for each ttTablePermissionCopy").    
        /*CreateSaveSource("_File-name").*/
        hquery:query-open().       
        do transaction on error undo, throw:
            do while true:
                hquery:get-next.                             
                if not hBeforebuff:avail then 
                    leave.
                phBuffer:find-by-rowid (hBeforeBuff:after-rowid).
          
                 /* avoid merge changes if not success set to false at end */ 
                phBuffer:error = true.
                if hBeforeBuff:row-state = row-deleted then 
                    undo, throw new UnsupportedOperationError("Delete of TablePermission.").
                else if hBeforeBuff:row-state = row-created then 
                    undo, throw new UnsupportedOperationError("Create of TablePermission.").
                
            /*  Dont use Create and Attach data Source. Instead do it the way its done for fields.
                phBuffer:attach-data-source(DataSourceHandle,FieldMapping). 
                hBeforeBuff:save-row-changes ().*/
                find dictdb._file where rowid(dictdb._file) = phBuffer::trowid exclusive no-wait.
                
                IF phBuffer::CanRead <> _File._Can-read THEN DO:
                   mod = yes.
                   IF NOT CAN-DO(phBuffer::CanRead ,USERID("DICTDB")) THEN err = yes.
                END.
                IF NOT err AND phBuffer::CanWrite <> _File._Can-write THEN DO:
                   mod = yes.
                   IF NOT CAN-DO(phBuffer::CanWrite ,USERID("DICTDB")) THEN err = yes.
                END.
                IF NOT err AND phBuffer::CanCreate <> _File._Can-Create THEN DO:
                   mod = yes.
                   IF NOT CAN-DO(phBuffer::CanCreate ,USERID("DICTDB")) THEN err = yes.
                END.
                IF NOT err AND phBuffer::CanDelete <> _File._Can-Delete THEN DO:
                   mod = yes.
                   IF NOT CAN-DO(phBuffer::CanDelete ,USERID("DICTDB")) THEN err = yes.
                END.
                IF NOT err AND phBuffer::CanDump <> _File._Can-Dump THEN DO:
                   mod = yes.
                   IF NOT CAN-DO(phBuffer::CanDump ,USERID("DICTDB")) THEN err = yes.
                END.
                IF NOT err AND phBuffer::CanLoad <> _File._Can-load THEN DO:
                   mod = yes.
                   IF NOT CAN-DO(phBuffer::CanLoad ,USERID("DICTDB")) THEN err = yes.
                END.
                
                IF mod AND _File._Db-lang <> 0 THEN DO:
                     undo, throw new DataAccessError("You can only alter security on SQL tables with GRANT and REVOKE.").
                END.
                
                IF err THEN DO:
                     undo, throw new DataAccessError("You cannot change permissions to exclude yourself.").
                END.
                
                if mod AND NOT err AND _File._Db-lang = 0 then
                assign 
                    dictdb._file._can-write  = phBuffer::CanWrite
                    dictdb._file._can-read   = phBuffer::CanRead
                    dictdb._file._can-create = phBuffer::CanCreate
                    dictdb._file._can-delete = phBuffer::CanDelete
                    dictdb._file._can-dump   = phBuffer::CanDump
                    dictdb._file._can-load   = phBuffer::CanLoad.
                         
                phBuffer:find-by-rowid (hBeforeBuff:after-rowid).
                phBuffer:error = false.
                
            end.
            
        end. /* transaction */
        if error-status:error then
        do:
            undo, throw new DataAccessError(error-status:get-message(1)).
        end.        
    end method. 
end class.