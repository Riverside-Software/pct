 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : AuthenticationSystemContext
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Feb 2011
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath. 
using OpenEdge.DataAdmin.IDataAdminCollection from propath. 
using OpenEdge.DataAdmin.AuthenticationSystem from propath. 
using OpenEdge.DataAdmin.AuthenticationSystemSet from propath. 
using OpenEdge.DataAdmin.IDomain from propath. 
using OpenEdge.DataAdmin.IAuthenticationSystem from propath. 
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.DataAdminContext from propath. 
using OpenEdge.DataAdmin.Binding.UserContext from propath. 
using OpenEdge.DataAdmin.Binding.Factory.IIdentityScope from propath. 
using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath. 
using OpenEdge.DataAdmin.Error.DataContextError from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError  from propath.
using OpenEdge.DataAdmin.Error.ReadOnlyPropertyError from propath.

class OpenEdge.DataAdmin.Binding.AuthenticationSystemContext inherits DataAdminContext :

    {daschema/authenticationsystem.i} 
    define private dataset dsAuthenticationSystem serialize-name "root" for ttAuthenticationSystem.
    define buffer bauthenticationsystem for ttAuthenticationSystem.
    define temp-table copytable reference-only like ttAuthenticationSystem .  
   
    define public override property DatasetHandle as handle no-undo 
        get():
            return dataset dsAuthenticationSystem:handle.
        end get.
    
	define public override property TableHandle as handle no-undo 
    	get():
    		return temp-table ttAuthenticationSystem:handle.
    	end get.
    
    define public override property KeyFields as character  no-undo  
        get():
            return "Name". 
        end.   
    
    define public override property Count as integer init ? no-undo  
        get(): 
            define buffer bauthenticationSystem for ttAuthenticationSystem.
            if Count = ? then
            do:
                Count = 0.
                for each bauthenticationSystem:
                    Count = Count + 1.
                end. 
            end.    
            return Count.
        end.
        protected set.
    
    constructor public AuthenticationSystemContext ():
        super ("AuthenticationSystem"). 
    end constructor.
     
    constructor public AuthenticationSystemContext ( pScope as IIdentityScope):
        super ("AuthenticationSystem",pscope). 
    end constructor.
    
    	
	method public override character GetJoinFields(parentid as char):
        case parentid:
        end.
    end.

/*	method protected void LoadInstances().                   */
/*        if not Loaded then                                */
/*        for each ttDomain:                                */
/*            if not valid-object(ttDomain.Entity) then     */
/*                ttDomain.Entity = new Domain(this-object).*/
/*        end.                                              */
/*        Loaded = true.                                    */
/*    end method.                                           */
/*                                                          */
/*    method protected void UnLoadInstances().              */
/*        for each ttDomain:                                */
/*            ttDomain.Entity = ?.                          */
/*        end.                                              */
/*        Loaded = false.                                   */
/*    end method.                                           */
	
	method public override void CreateRow(entity as IDataAdminElement):
	    /* the default syserror has all info */
	    CreateRow(cast(entity,IAuthenticationSystem)).    
	end method.

    method public override void CopyTable(cntxt as IDataAdminContext):
        define variable hTbl as handle no-undo.
        hTbl = cntxt:TableHandle.
        CopyTable(table-handle hTbl by-reference). 
        Loaded = false.
    end method.    
    
	method private void CopyTable(input table copytable):
	    define variable dataerror as DataContextError no-undo.      
        for each copytable on error undo, throw:  
            if valid-object(Service) and valid-object(copytable.Entity) then 
            do:
                ValidateAuthenticationSystem(cast(copytable.Entity,IAuthenticationSystem)).
            end.
            do on error undo, throw:
                find bauthenticationsystem where bauthenticationsystem.name = copytable.name no-error.
                /* force error message 
                   - DataError will transform progress message 
                     to "entity" message */
                if avail bauthenticationSystem then
                do:
                    create bAuthenticationSystem.
                    bauthenticationSystem.name = copytable.name.               
                end.    
                catch e as Progress.Lang.Error :
                    delete bAuthenticationSystem.
                    if not valid-object(DataError) then 
                        dataError = new DataContextError("Domain",e).
                    else 
                       dataError:AddMessage(e).             		
                end catch. 
            end.             
        end.    
        
        if valid-object(dataError) then
            undo, throw dataError. 
        temp-table ttAuthenticationSystem:tracking-changes = true.
        for each copytable:
            create ttauthenticationSystem.    
            Count = Count + 1.
            buffer-copy copytable to ttauthenticationSystem.    
            OnRowCreated().
        end.
        temp-table ttAuthenticationSystem:tracking-changes = false.
            
    end method.  
	
	method private character GetCreateError(authenticationSystem as IAuthenticationSystem):
        return this-object:GetCreateError(cast(authenticationSystem,IDataAdminElement),authenticationSystem:Name). 
    end method.
    
    method protected override void ValidateBuffer(phSystem as handle):
        define variable hBefore as handle no-undo.
        if phSystem:row-state = row-modified then
        do:
            hBefore = phSystem:before-buffer.
            hbefore:find-by-rowid(phSystem:before-rowid).
            if phSystem::Name <> hBefore::Name then
               undo, throw new ReadOnlyPropertyError(Name,phSystem::Name,"Name").
        end.    
        
    end method.      
         
         
	method private void ValidateAuthenticationSystem(authenticationsystem as IAuthenticationSystem):
	    define variable validateError as DataContextError no-undo.
	    define variable e1 as logical no-undo.
/*	    define variable e2 as logical no-undo.   */
/*        define variable e3 as logical no-undo.*/
        define variable e11 as logical no-undo.
/*        define variable e12 as logical no-undo.*/
/*        define variable e13 as logical no-undo.*/

/*        e11 = not valid-object(domain:Tenant).*/
        /* 
        if not e11 and valid-object(Service) then
            assign
                e1 = domain:Tenant:Service <> Service.
        */
        
	end method.    
	
	method public void CreateRow(authenticationSystem as IAuthenticationSystem):
	    define variable validateError as DataContextError no-undo.
       
	    temp-table ttAuthenticationSystem:tracking-changes = true.
	    ValidateAuthenticationSystem(authenticationSystem).
	    
	    do on error undo, throw: 
	        Count = Count + 1.
	        create ttAuthenticationSystem.
            assign 
                ttAuthenticationSystem.Name            = authenticationSystem:name
                ttAuthenticationSystem.Entity          = authenticationSystem
                ttAuthenticationSystem.Description     = authenticationSystem:Description
                ttAuthenticationSystem.IsEnabled       = authenticationSystem:IsEnabled
                ttAuthenticationSystem.Callback        = authenticationSystem:Callback  
                ttAuthenticationSystem.Comments        = authenticationSystem:Comments    
                .   
            OnRowCreated().      
            catch e as Error:  
                delete ttAuthenticationSystem.
                Count = Count - 1.
                undo, throw new DataContextError(GetCreateError(authenticationSystem),"AuthenticationSystem",e).  
            end catch.  
        end.
        finally:
            temp-table ttAuthenticationSystem:tracking-changes = false.        		
        end finally.
    end method.
    
    method public override logical CanFind(name as character):
        return can-find(ttAuthenticationSystem where ttauthenticationSystem.name = name).            
    end.     
     
    method public override logical Find(name as character):
        find ttAuthenticationSystem where ttauthenticationSystem.name = name no-error.
        return avail ttauthenticationSystem.            
    end.     
   
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):     
        return new AuthenticationSystemSet(cntxt).
    end method.
    
    method protected override IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
        return new AuthenticationSystem(cntxt).
    end method.
    
    
     
end class.
