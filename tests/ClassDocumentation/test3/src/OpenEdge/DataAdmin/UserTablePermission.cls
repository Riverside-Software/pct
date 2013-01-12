/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : UserTablePermission
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/
 
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.Entity from propath.
 
using OpenEdge.DataAdmin.ISchema from propath.
using OpenEdge.DataAdmin.IUserFieldPermissionSet from propath.
using OpenEdge.DataAdmin.IUser  from propath.
 
 
using OpenEdge.DataAdmin.IUserTablePermission from propath.
using OpenEdge.DataAdmin.UserTablePermission from propath. 
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.

class OpenEdge.DataAdmin.UserTablePermission final inherits Entity  implements IUserTablePermission: 
           
    define public property Hidden as logical no-undo  
        get():
            if valid-handle(mBuffer) then
                return mBuffer::Hidden.
            else
                return Hidden. 
        end.
        
    define public property Frozen as logical no-undo   
        get():
            if valid-handle(mBuffer) then
                return mBuffer::Frozen.
            else
                return Frozen. 
        end.
        
    define public property CanRead as logical no-undo 
        get():
            if valid-handle(mBuffer) then
                return mBuffer::CanRead.
            else
                return CanRead. 
        end.
    
    define public property CanWrite as logical no-undo     
        get():
            if valid-handle(mBuffer) then
                return mBuffer::CanWrite.
            else
                return CanWrite. 
        end.
    
    define public property CanCreate as logical no-undo  
        get():
            if valid-handle(mBuffer) then
                return mBuffer::CanCreate.
            else
                return CanCreate. 
        end.
    
    define public property CanDelete as logical no-undo  
        get():
            if valid-handle(mBuffer) then
                return mBuffer::CanDelete.
            else
                return CanDelete. 
        end.
    
    define public property CanLoad as logical no-undo  
        get():
            if valid-handle(mBuffer) then
                return mBuffer::CanLoad.
            else
                return CanLoad. 
        end.
    
    define public property CanDump as logical no-undo  
        get():
            if valid-handle(mBuffer) then
                return mBuffer::CanDump.
            else
                return CanDump. 
        end.
    
    /* lists all LOBs in the schema */ 
    define public property UserFieldPermissions as IUserFieldPermissionSet no-undo     
        get():
            define variable c as character extent 2 no-undo.
            if valid-handle(mBuffer) and not valid-object(UserFieldPermissions) then
            do:
                c[1] = mbuffer::UserRef.
                c[2] = name.
                UserFieldPermissions = cast(GetChildCollection(c,"userFieldPermissions"),IUserFieldPermissionSet).         
            end.
            return UserFieldPermissions.
            
        end.
        protected set.
       
    method public override void Export():
        Export("tablepermission.json").
    end method.          
    
   /*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
		
	constructor public UserTablePermission ( cntxt as IDataAdmincontext ):
		super (cntxt).
	end constructor.
    
    /* No local context needed - no child collections   */ 
    method protected  override IDataAdminContext CreateLocalContext():
        return ?.
    end method.
    
    method public override void Export(cFile as char):
        define variable htbl as handle no-undo.
        if not valid-handle(mDefaultBuffer) then
        do:
            undo, throw new UnsupportedOperationError("Export of new table").
        end.
        create temp-table htbl.
        htbl:create-like(mDefaultBuffer).
        htbl:temp-table-prepare ("ttTablePermission").
        htbl:default-buffer-handle:buffer-copy (mBuffer).
        htbl:default-buffer-handle:serialize-name = "tablePermissions".     
        htbl:default-buffer-handle:write-json ("File",cFile,yes).   
    end method.
    
    
 end class.