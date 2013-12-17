 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    File        : UserTablePermissionDataSource
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sat Sep 04 02:01:56 EDT 2010
    Notes       : BaseQuery does not filter on _hidden 
                  but does filter on _Owner = "PUB"
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.DataSource.FieldPermissionDataSource.
 
using OpenEdge.DataAdmin.DataAccess.DataAccessError.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.DataSource.UserFieldPermissionDataSource inherits FieldPermissionDataSource: 
 
    define private variable mMapping as char
       init "TableName,_file-name,Name,_field-name" no-undo.
  
	constructor public UserFieldPermissionDataSource (hParent as handle ):     
        super (hParent, mMapping).
        entry(1,BaseQuery," ") = "for each " + hParent:name + ", ". 
    end constructor.
    
    constructor public UserFieldPermissionDataSource (hParent as handle,pcTableJoin as char ,pcjoin as char ):     
        super (hParent,pctablejoin,pcjoin, mMapping).
    end constructor.
    
    constructor public UserFieldPermissionDataSource ():     
        super (mMapping).
    end constructor.
    
    method public override logical Save(phbuffer as handle):
        undo, throw new UnsupportedOperationError("Save of UserTablePermission").        
    end method. 
    
       /* allow subclasses to override to set call back even if we don't have call back here */
    method protected override logical SetCallBack(phBuffer as handle):
        phBuffer:set-callback("After-Row-fill","AfterFieldRow"). 
    end method.
    
    method public void AfterFieldRow(dataset-handle hds):
        define variable hBuffer       as handle no-undo. 
        define variable hParent       as handle no-undo. 
        define variable iParentSource as integer no-undo.
        define variable iFieldSource  as integer no-undo.
        define variable hUserPerm     as handle no-undo.
        define variable hFieldbuf     as handle no-undo.
        define variable cid           as character no-undo.        
        define variable cList         as character no-undo.
        hbuffer = hds:get-buffer-handle("ttUserFieldPermission").
        assign 
            iParentSource = lookup("ttUserPermission",Tables)
            iFieldSource = lookup("_Field",Tables)
            hFieldbuf    = DataSourceHandle:get-source-buffer(iFieldSource).
        /*find dictdb._field where recid(dictdb._field) = hFieldBuf:recid no-lock.*/  
        if iParentSource > 0 then
        do:
            hUserPerm = DataSourceHandle:get-source-buffer(iParentSource).
            hbuffer::UserRef = hUserPerm::id.
            
            cid = hbuffer::UserRef.
        end.
        else do:
           cid = userid("dictdb").
           hbuffer::UserRef = cid.
        end. 
        
        /* this is not needed- commenting this out
        /* fred@ and fred need to be treated similar */
        if index(cid,"@") = 0 then 
        do:
           cidNoAt = cid. 
           cid = cid + "@". 
        end.
        else if cid matches "*@" then 
        do:
           cidNoAt = entry(1,cid,"@").
        end.   
        /* if not multitenant then fred@acme is ok with fred and fred@ in list*/  
        else if not DatabaseInfo:IsMultiTenant then
        do: 
            cidNoAt = entry(1,cid,"@").
            cidNoDomain = cidNoAt + "@".       
        end.      
        else /* OE00206538 temporary set cidNOat since this is the only we chack
               worksaround for user@domain*/
            cidNOat  = cid. */ 
       
        /* core bug OE00206538  need to be fixed before this 
          can be fully implemented /resolved
          as of current xxx@ inlist will not work 
        */         
        assign        
           clist = hFieldbuf::_can-read 
           hbuffer::CanRead   =  can-do(clist,cid) 
/*                                 or (if cidNoat = "" then false else can-do(clist,cidNoat))*/
/*                                 or (if cidNoDomain = "" then false else can-do(clist,cidNoDomain))*/
           clist = hFieldbuf::_can-write 
           hbuffer::CanWrite =  can-do(clist,cid) 
/*                                 or (if cidNoat = "" then false else can-do(clist,cidNoat))*/
/*                                 or (if cidNoDomain = "" then false else can-do(clist,cidNoDomain))*/
            .  
             
    end method.
    
end class.