 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : AuthenticationSystemSet
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
using OpenEdge.DataAdmin.DataAccess.* from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.DataAdminCollection from propath.

using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IAuthenticationSystem from propath.
using OpenEdge.DataAdmin.Binding.AuthenticationSystemContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.

class OpenEdge.DataAdmin.AuthenticationSystemSet inherits DataAdminCollection implements IAuthenticationSystemSet: 
       
    constructor AuthenticationSystemSet():      
        /* the super empty constructor will call CreateLocalContext() */ 
        super(). 
    end constructor.
      
    constructor AuthenticationSystemSet(cntxt as IDataAdminContext):
        super(cntxt).
        if not (type-of(cntxt,FilteredContext) or type-of(cntxt,AuthenticationSystemContext)) then 
             undo, throw new IllegalArgumentError("Invalid context type passed to AuthenticationSystemSet constructor"). 
    end constructor. 
    
    constructor AuthenticationSystemSet(cntxt as AuthenticationSystemContext):
        super(cntxt).  
    end constructor. 
    
    constructor AuthenticationSystemSet(cntxt as FilteredContext):
        super(cntxt).  
    end constructor. 
    
    method protected override IDataAdminContext CreateLocalContext():
        return new AuthenticationSystemContext().
    end.     
    
    method public logical Add(authenticationSystem as IAuthenticationSystem):  
        if Contains(authenticationSystem) then
            return false.   
      
        authenticationSystem:Attach(Context).
         
        return true.
    end method.  
    
    method public override logical Remove(o as Object):
        define variable domt as IAuthenticationSystem no-undo.
        domt = cast(o,IAuthenticationSystem).
        return Remove(domt).
    end method.  
    
    method public logical Remove(pdomt as IAuthenticationSystem):
        AssertNotNull(pdomt,"AuthenticationSystem").
        return Context:Delete(pdomt:Name).
    end method.  
   
    method public override logical Contains(obj as Object):
        return Contains(cast(obj,IAuthenticationSystem)).   
        catch e as Progress.Lang.Error :
            return false.   
        end catch.
    end method.
   
    method public logical Contains(authenticationSystem as IAuthenticationSystem):
        if authenticationSystem:ContextId <> ContextId then 
            return false.
        if not CanFind(authenticationSystem:name) then
            return false.
        return authenticationSystem:Equals(this-object:Find(authenticationSystem:name)).      
    end method.  
    
    method override logical Equals(obj as Object): 
        define variable tset as AuthenticationSystemSet no-undo. 
        if super:Equals(obj) then 
            return true.
        else do:
            tset = cast(obj,AuthenticationSystemSet).  
            return this-object:ContextId = tset:ContextId. 
        end.
        catch e as Error :
            return false.   
        end catch.
            
    end method.
    
    method public IAuthenticationSystem Find(authenticationSystem as char):
           
        return cast(Context:GetEntity(authenticationSystem),IAuthenticationSystem).
        
    end method.   
             
    method public logical CanFind(domainname as char):
        return Context:CanFind(domainname).
    end method.   
         
    method override protected void PrepareExport(  ): 
    end method.

    method override protected void PrepareExportTree(  ):
    end method.
    
    method override protected void PrepareExportList(  ):
    
/*        TableHandle:default-buffer-handle:buffer-field("Description"):serialize-hidden = true.*/
        TableHandle:default-buffer-handle:buffer-field("Comments"):serialize-hidden = true.
  
    end method.
    
 
    
    
end class.
