/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : UserPermission
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.* from propath.
using OpenEdge.DataAdmin.Binding.* from propath.
using OpenEdge.DataAdmin.DataAccess.* from propath.
using OpenEdge.DataAdmin.Error.* from propath.
 
class OpenEdge.DataAdmin.UserPermission inherits Entity implements IUserPermission, IDataAdminElement,IDataAdminSerializable: 
    
    
    define public property Domain as IDomain no-undo     
        get():
            if not valid-object(Domain) then
            do:
                if valid-handle(mBuffer)  
                and valid-object(Service) then
                    return Service:GetDomain(mBuffer::DomainName).             
            end.
            return ?.
        end.
    
    define public property Id as character no-undo     
        get():
             define variable cDomain as character no-undo.
             cDomain = if valid-object(Domain) then Domain:Name
                       else if valid-handle(mbuffer) then mBuffer::DomainName 
                       else "". 
             return name 
                   + if cDomain > "" 
                     then "@" + cDomain
                     else "".
        end.
   
    define public property UserTablePermissions as IUserTablePermissionSet     no-undo 
        get():
            define variable h as handle no-undo.
            if not valid-object(UserTablePermissions) then
            do:
                UserTablePermissions = cast(Context:GetChildCollection(Id,"userTablePermissions"),IUserTablePermissionSet).
            end.
/*            if not mTablesLoaded then*/
/*                FetchTables().       */
            return UserTablePermissions.     
        end.
        protected set.
    
   
	constructor public UserPermission(cntxt as IDataAdminContext):
        super (cntxt).
    end constructor.
    
    /* No local context needed - no child collections   */ 
    method protected  override IDataAdminContext CreateLocalContext():
        return ?.
    end method.
      
    method public override void WriteTree(tree as IContextTree):
        undo, throw new UnsupportedOperationError("WriteTree to ContextTree").        
    end method. 
    
    method public override void WriteTree(tree as IContextTree,pcCollections as char):
       undo, throw new UnsupportedOperationError("WriteTree to ContextTree").        
    end method.
    
	method public override void ImportTree(pcFile as char). 
        undo, throw new UnsupportedOperationError("Import to UserSecurity").
    end method. 
 
    method public override void Import(cFile as char):
        undo, throw new UnsupportedOperationError("Import to UserSecurity").
    end method. 
                   
end class.
