 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : Domain
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Tue Jun 29 14:17:54 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.* from propath.
using OpenEdge.DataAdmin.Binding.* from propath.
using OpenEdge.DataAdmin.DataAccess.* from propath.
using OpenEdge.DataAdmin.Error.* from propath.

class OpenEdge.DataAdmin.Domain inherits Entity implements IDomain, IDataAdminElement,IDataAdminSerializable: 
    define private variable mChild as logical no-undo.
    define private variable myContext as IDataAdminContext no-undo.
    
    define public property IsBuiltin as logical no-undo                 
         get():
            if valid-handle(mBuffer) then
                return mBuffer::IsBuiltin.
            else
                return IsBuiltin. 
        end.
    
    define public property Id as integer no-undo                 
         get():
            if valid-handle(mBuffer) then
                return mBuffer::Id.
            else
                return Id. 
    end.      
    
    define public property Comments as char no-undo  
        get():
            if valid-handle(mBuffer) then
                return mBuffer::Comments.
            else
                return Comments. 
        end.
        set(pComments as char):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::Comments = pComments.
            end.
            Comments = pComments.
        end. 
  
    define public property AuditingContext as char no-undo 
        get():
            if valid-handle(mBuffer) then
                return mBuffer::AuditingContext.
            else
                return AuditingContext. 
        end.
        set(pAuditingContext as char):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::AuditingContext = pAuditingContext.
            end.
            AuditingContext = pAuditingContext.
        end. 
        
    define public property AccessCode as char no-undo 
        get():
            if valid-handle(mBuffer) then
                return mBuffer::AccessCode.
            else
                return AccessCode. 
        end.
        set(pAccessCode as char):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::AccessCode = pAccessCode.
            end.
            AccessCode = pAccessCode.
        end. 
        
    define public property RuntimeOptions  as char no-undo  
         get():
            if valid-handle(mBuffer) then
                return mBuffer::RuntimeOptions.
            else
                return RuntimeOptions. 
        end.
        set(pRuntimeOptions as char):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::RuntimeOptions = pRuntimeOptions.
            end.
            RuntimeOptions = pRuntimeOptions.
        end. 
	
	define public property SystemOptions  as char no-undo  
         get():
            if valid-handle(mBuffer) then
                return mBuffer::SystemOptions.
            else
                return SystemOptions. 
        end.
        set(pSystemOptions as char):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::SystemOptions = pSystemOptions.
            end.
            SystemOptions = pSystemOptions.
        end. 
         
    define public property Description as character no-undo 
         get():
            if valid-handle(mBuffer) then
                return mBuffer::Description.
            else
                return Description. 
        end.
        set(pDescription as char):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::Description = pDescription.
            end.
            Description = pDescription.
        end. 
    
    define public property IsEnabled as logical no-undo 
         init true
         get():
            if valid-handle(mBuffer) then
                return mBuffer::IsEnabled.
            else
                return IsEnabled. 
        end.
        set(pIsEnabled as logical):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::IsEnabled = pIsEnabled.
            end.
            IsEnabled = pIsEnabled.
        end. 
   
	define public property Tenant as ITenant no-undo 
    	get():
    	     if not valid-object(Tenant) then
    	     do:
    	         if valid-handle(mBuffer) and mBuffer::TenantName > "" 
                 and valid-object(Service) then
                     return Service:GetTenant(mBuffer::TenantName).   
             end.
             return Tenant.
        end.     
    	set(pTenant as ITenant ):
    	    /*
    	    if valid-object(Service) then 
    	        undo, throw new ReadOnlyPropertyError("Domain",name,"Tenant").     
    	    */
    	    if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).
                mdefaultbuffer::TenantId = pTenant:Id.  
                mdefaultbuffer::TenantName = pTenant:name.
            end.
            Tenant = pTenant.    
    	end.
	
	define public property Users as IUserSet no-undo  
        get():
            if not valid-object(Users) then
            do:
                Users = cast(GetChildCollection("users"),IUserSet).
/*                Users:Domain = this-object.*/
                             
            end.         
            return Users.     
        end.
        private set. 
	
	define public property AuthenticationSystem as IAuthenticationSystem no-undo 
	     get():
             if not valid-object(AuthenticationSystem) then
             do:
                 if valid-handle(mBuffer) and mBuffer::AuthenticationSystemName > "" 
                 and valid-object(Service) then
                     AuthenticationSystem = Service:GetAuthenticationSystem(mBuffer::AuthenticationSystemName).            
             end.
             return AuthenticationSystem.
        end.
        set(pType as IAuthenticationSystem):
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::AuthenticationSystemName = pType:Name.
            end.
            AuthenticationSystem = pType.
        end.  
	
	constructor public Domain (cntxt as IDataAdminContext,preq as IRequestInfo):
        super (cntxt,preq).        
    end constructor.
      
	constructor public Domain (cntxt as IDataAdminContext):
        super (cntxt).        
    
    end constructor.
      
    constructor public Domain (name as character):
        super (name).
    end constructor. 
    
    method protected override IDataAdminContext CreateLocalContext(): 
        return new DomainContext().  
    end method.
        
    method public override void ExportTree(pcfile as char):
        this-object:Export(pcFile).
    end method.     
     
	method public override  void Export(  ):
		Export("domain.json").
	end method.
	
end class.
