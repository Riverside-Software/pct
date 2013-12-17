 /*************************************************************/
 /* Copyright (c) 2012 by Progress Software Corporation.      */
 /*                                                           */
 /* All rights reserved.  No part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from Progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : UtilityTenantContext
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Wed May 09 22:32:23 EDT 2012
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.IDataAdminElement.
using OpenEdge.DataAdmin.IDataAdminCollection.
using OpenEdge.DataAdmin.ITenant.
using OpenEdge.DataAdmin.Binding.IDataAdminContext.
using OpenEdge.DataAdmin.Binding.UtilityContext.
using OpenEdge.DataAdmin.Internal.Util.UtilityTenantSet.
using OpenEdge.DataAdmin.Error.IllegalArgumentError.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.UtilityTenantContext inherits UtilityContext: 
	{daschema/tenantdata.i reference-only}
    
    define public override property Count as integer init ? no-undo  
        get(): 
            define buffer btnt for ttTenantData.
            if Count = ? then
            do:
                Count = 0.
                for each btnt:
                    Count = Count + 1.
                end. 
            end.    
            return Count.
        end.
        protected set.
        
    	
	constructor public UtilityTenantContext ( input ds as handle ):
		super ( ds, "Tenant").
	end constructor.
    
    method public override void Bind(pHdl as handle).
        Bind(table-handle phdl bind).
    end method.    
    
    method private void Bind(table ttTenantData bind):
    end method.
    
    method public override void AssignRow(pinst as IDataAdminElement,phBuffer as handle):
        define variable inst as ITenant no-undo. 
        inst = cast(pinst,ITenant).
        AssignRow(inst,phBuffer). 
    end method.
    
    method public void AssignRow(inst as ITenant,hBuffer as handle):
        hBuffer::name = inst:name. 
    end method.
  
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):     
        return new UtilityTenantSet(cntxt). 
    end method.
    
    method protected override IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
        if valid-object(TargetService) then
        do:
            if this-object:Find(cntxt:TableHandle::name) then 
               return TargetService:GetTenant(cntxt:TableHandle::name).
        end.   
    end method.
    
    method public override logical Find(pid as integer):
        define variable tnt as ITenant no-undo.
        if valid-object(TargetService) then
        do:
            tnt = TargetService:GetTenant(pid).
            if valid-object(tnt) then 
                return this-object:Find(tnt:name).
        end.
        return false.
    end.    
	
	method public override logical CanFind(pid as integer):
        define variable tnt as ITenant no-undo.
        if valid-object(TargetService) then
        do:
            tnt = TargetService:GetTenant(pid).
            if valid-object(tnt) then 
                return this-object:CanFind(tnt:name).
        end.
        return false.
    end.    
	
	method public logical FindTenantByExternalId(pext as character):
        define variable tnt as ITenant no-undo.
        if valid-object(TargetService) then
        do:
            tnt = TargetService:GetTenantByExternalId(pext).
            if valid-object(tnt) then 
                return this-object:Find(tnt:name). 
        end.
        return false.
    end.   
    
    method public IDataAdminElement FindEntityByExternalId(pext as character):
        define variable tnt as ITenant no-undo.
        if valid-object(TargetService) then
        do:
            tnt = TargetService:GetTenantByExternalId(pext).
            if valid-object(tnt) then 
                return this-object:FindEntity(tnt:name). 
        end.
        return ?.
    end.   
    
	method public logical CanFindTenantByExternalId(pext as character):
        define variable tnt as ITenant no-undo.
        if valid-object(TargetService) then
        do:
            tnt = TargetService:GetTenantByExternalId(pext).
            if valid-object(tnt) then 
                return this-object:CanFind(tnt:name).
        end.
        return false.
    end. 
         

end class.