 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : Set of domains 
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
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.

using OpenEdge.DataAdmin.DataAccess.* from propath.
using OpenEdge.DataAdmin.Error.* from propath.

class OpenEdge.DataAdmin.DomainSet inherits DataAdminCollection implements IDomainSet: 
    
    constructor DomainSet():      
        /* the super empty constructor will call CreateLocalContext() */ 
        super(). 
    end constructor.
   
    constructor DomainSet(cntxt as IDataAdminContext):
        super(cntxt).
        if not (type-of(cntxt,FilteredContext) or type-of(cntxt,DomainContext)) then 
            undo, throw new IllegalArgumentError("Invalid context type passed to DomainSet constructor"). 
         
    end constructor. 
    
    method protected override IDataAdminContext CreateLocalContext():
        return new DomainContext().
    end.     
    
    method public override logical Add(o as Object):
        define variable inst as IDomain no-undo.
        inst = cast(o,IDomain). /* cast to get error */
        return this-object:Add(inst).
    end method.
    
    method public logical Add(domain as IDomain):  
        if Contains(domain) then
            return false.   
        /*
        if valid-object(Tenant) then 
        do:
            if valid-object(domain:Tenant) and not domain:Tenant:Equals(Tenant) then
                undo, throw new IllegalArgumentError("Domain already belongs to a Tenant and cannot be added to Tenant" + quoter(Tenant:Name) ).
            domain:Tenant = Tenant.     
        end.
        */
        domain:Attach(Context).
       
        return true.
    end method.  
    
	method override public void Import(pcFile as character ):	
		super:Import(input pcFile).	
    end method.

    method public override logical Remove(o as Object):
        define variable dom as IDomain no-undo.
        dom = cast(o,IDomain).
        return Remove(dom).
    end method.  
    
    method public logical Remove(auser as IDomain):
        AssertNotNull(auser,"Domain").
        return Context:Delete(auser:Name).
    end method.  
   
    method public override logical Contains(obj as Object):
        return Contains(cast(obj,IDomain)).   
        catch e as Progress.Lang.Error :
            return false.   
        end catch.
    end method.
   
    method public logical Contains(domain as IDomain):
        if domain:ContextId <> ContextId then 
            return false.
        if not CanFind(domain:name) then
            return false.
        return domain:Equals(this-object:Find(domain:name)).      
    end method.  
    
    method override logical Equals(obj as Object): 
        define variable tset as DomainSet no-undo. 
        if super:Equals(obj) then 
            return true.
        else do:
            tset = cast(obj,DomainSet).  
            return this-object:ContextId = tset:ContextId. 
        end.
        catch e as Error :
            return false.   
        end catch.
    end method.
        
     method public IDomain Find(domainname as char):
        return cast(Context:FindEntity(domainname),IDomain). 
    end method.   
             
    method public logical CanFind(domainname as char):
        return Context:CanFind(domainname).
    end method.   
         
    method override protected void PrepareExport(  ):
        TableHandle:default-buffer-handle:buffer-field("UsersUrl"):serialize-hidden = true.
    end method.

    method override protected void PrepareExportTree(  ):
        TableHandle:default-buffer-handle:buffer-field("UsersUrl"):serialize-hidden = true.
    end method.
    
    method override protected void PrepareExportList(  ):
        TableHandle:default-buffer-handle:buffer-field("AuthenticationSystemName"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("Comments"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("AccessCode"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("RuntimeOptions"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("TenantName"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("IsEnabled"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("AuditingContext"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("TenantUrl"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("UsersUrl"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("BuiltIn"):serialize-hidden = true.
    end method.
    
end class.
