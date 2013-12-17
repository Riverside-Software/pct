/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : UserSet
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
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.

using OpenEdge.DataAdmin.DataAccess.* from propath.
using OpenEdge.DataAdmin.Error.* from propath.

class OpenEdge.DataAdmin.UserSet inherits DataAdminCollection implements IUserSet: 
        
    define public property Domain as IDomain no-undo     
        get.
        set(newdomain as IDomain):
            define variable filter as FilteredContext no-undo.
            define variable lok as logical no-undo.
            if type-of(Context,FilteredContext) then
            do:
 
                filter = cast(context,FilteredContext).  
                if filter:ParentSerializeName = "domains" 
                and filter:Service = newdomain:Service  
                and newdomain:Name = entry(2,filter:ParentUrl,"/") then
                    Domain = newdomain.   
            end.   
            Domain = newdomain.                               
            if not valid-object(Domain) then
               undo, throw new IllegalArgumentError("Set of Domain does not match the contents of the User collection.").    
        end.
 
        
    define public property Tenant as ITenant no-undo     
        get.
        set(newtenant as ITenant):
            define variable filter as FilteredContext no-undo.
            define variable lok as logical no-undo.
            if type-of(Context,FilteredContext) then
            do:
 
                filter = cast(context,FilteredContext).  
                if filter:ParentSerializeName = "tenants" 
                and filter:Service = newtenant:Service then
                do:
                    if filter:ParentUrl begins "tenants.id" then
                        lok = string(newtenant:Id) = entry(2,filter:ParentUrl,"/").
                    else
                        lok = newtenant:Name = entry(2,filter:ParentUrl,"/").
                    if lok then      
                        Tenant = newTenant.   
                end.
            end.      
            /* @TODO */
           
            Tenant = newTenant .                        
            
            if not valid-object(Tenant) then
               undo, throw new IllegalArgumentError("Set of Tenant does not match the contents of the User collection.").    
        end.
    
    constructor UserSet():      
        /* the super empty constructor will call CreateLocalContext() */ 
        super(). 
    end constructor.
    /*
    constructor UserSet(tenantparent as ITenant):      
        /* the super empty constructor will call CreateLocalContext() */ 
        super(). 
        Tenant = tenantparent.
    end constructor.
    
    constructor UserSet(domainparent as IDomain):      
        /* the super empty constructor will call CreateLocalContext() */ 
        super(). 
        Domain = domainparent.
        Tenant = Domain:Tenant.
    end constructor.
    */
    constructor UserSet(cntxt as IDataAdminContext):
        super(cntxt).
        if not (type-of(cntxt,FilteredContext) or type-of(cntxt,UserContext)) then 
             undo, throw new IllegalArgumentError("Invalid context type passed to UserSet constructor"). 
    end constructor. 


    method protected override IDataAdminContext CreateLocalContext():
        return new UserContext().
    end.  
    
    method public override logical Add(o as Object).  
        define variable userinst as IUser no-undo.
        userinst = cast(o,IUser).
        return this-object:Add(userinst).
    end method.
    
    method public logical Add(userImpl as IUser).  
        AssertNotNull(userImpl,"User").
        if Contains(userImpl) then
            return false.   
        if valid-object(Domain) then
            userImpl:Domain = Domain.
       
        userImpl:Attach(Context).
    
        return true.
    end method.  
 
    method public override logical Remove(o as Object):
        define variable auser as IUser no-undo.
        auser = cast(o,IUser).
        return Remove(aUser).
    end method.  
    
    method public logical Remove(auser as IUser):
        AssertNotNull(auser,"User").
        return Context:Delete(auser:Id).
    end method.  
   
    method public override logical Contains(obj as Object):
        define variable usr as IUser no-undo.
        usr = cast(obj,IUser).
     
        return Contains(usr).   
        catch e as Progress.Lang.Error :
            return false.   
        end catch.
    end method.
   
    method public logical Contains(userImpl as IUser):
        if userImpl:ContextId <> ContextId then 
            return false.
        if not CanFind(userImpl:Id) then
            return false.
        return userImpl:Equals(this-object:Find(userImpl:Id)).      
    end method.  
    
    method override logical Equals(obj as Object): 
        define variable tset as UserSet no-undo. 
        if super:Equals(obj) then 
            return true.
        else do:
            tset = cast(obj,UserSet).  
            return this-object:ContextId = tset:ContextId. 
        end.
        catch e as Error :
            return false.   
        end catch.    
    end method.
     
    method public IUser Find(pkey as char):
        if valid-object(Domain) then
        do:
            if index(pkey,"@") <> 0 then 
                undo, throw new IllegalArgumentError("@<Domain> passed to Find in UserSet owned by Domain").
            pkey = pkey + '@' + Domain:Name.
        end.           
        return cast(Context:FindEntity(pkey),IUser). 
    end method.     
    
    method public logical CanFind(pkey as char):           
        return Context:CanFind(pkey).
    end method.   
         
    method override void PrepareExport():
/*        buffer ttUser:handle:buffer-field("URL"):serialize-hidden = true.*/
    end method.    
     
    method override void PrepareExportTree():
/*       buffer ttUser:handle:buffer-field("PartitionsURL"):serialize-hidden = true.*/
    end method.      
      
    method override void PrepareExportList():
 
/*        buffer ttTenant:handle:buffer-field("Type"):serialize-hidden = true.                */
/*/*        buffer ttTenant:handle:buffer-field("Description"):serialize-hidden = true.*/     */
/*        buffer ttTenant:handle:buffer-field("DefaultDataAreaName"):serialize-hidden = true. */
/*        buffer ttTenant:handle:buffer-field("DefaultIndexAreaName"):serialize-hidden = true.*/
/*        buffer ttTenant:handle:buffer-field("DefaultLobAreaName"):serialize-hidden = true.  */
/*        buffer ttTenant:handle:buffer-field("DefaultDataAreaUrl"):serialize-hidden = true.  */
/*        buffer ttTenant:handle:buffer-field("DefaultIndexAreaUrl"):serialize-hidden = true. */
/*        buffer ttTenant:handle:buffer-field("DefaultLobAreaUrl"):serialize-hidden = true.   */
/*        buffer ttTenant:handle:buffer-field("PartitionsURL"):serialize-hidden = true.       */
/*        buffer ttTenant:handle:buffer-field("UsersURL"):serialize-hidden = true.            */
/*        buffer ttTenant:handle:buffer-field("IsLocked"):serialize-hidden = true.            */

    end method.    
    

end class.
