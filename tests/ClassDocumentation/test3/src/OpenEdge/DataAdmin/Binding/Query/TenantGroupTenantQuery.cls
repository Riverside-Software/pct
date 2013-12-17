/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     : Used for a collection of Tenants for a TenantGroup
                  indexed/mapped by TenantName            
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : 
    Notes       : TenantContext is the main context since this is to be used 
                  by ITenantSet collections with ITenant elements. 
                - The PartionGroupDetailContext is used for add and remove
                  sonce it defines the many to many relation ship that is being updated.
                - The query joins these context tables. 
                - This query is added to tttenantgroupmember, but 
                  passed as tenant entityname, in the request.
                - There is an equivalent query to handle this from the other side;
                  TenantTenantGroupQuery 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
 
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.
using OpenEdge.DataAdmin.ITenant from propath.

using OpenEdge.DataAdmin.Binding.Query.ManyToManyQuery from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.TenantGroupMemberContext from propath.
using OpenEdge.DataAdmin.Binding.TenantContext from propath.
using OpenEdge.DataAdmin.Binding.ContextTree from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Message.FetchRequest from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.


routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.Query.TenantGroupTenantQuery inherits ManyToManyQuery: 
	
 
    /** Update context (Model) may change so don't store this */   
    define private property TenantGroupMemberContext as TenantGroupMemberContext no-undo 
        get():
            return cast(UpdateContext,TenantGroupMemberContext).   
        end.
        
    constructor public TenantGroupTenantQuery (pparent as  TenantContext,pgroupName as char,pReq as IRequestInfo):
		super (pparent,"tenantGroups",pgroupName,"tenantGroupMembers",pReq).	
	end constructor.
        
    method public override logical CanFind(pname as character):
        if TenantGroupMemberContext:Find(ParentValue,pName) then
            return CanFindCurrentModel(TenantGroupMemberContext).
        return false.    
    end.    
     
    method public override logical Find(pname as character):
        if TenantGroupMemberContext:Find(ParentValue,pName) then
            return SynchWithModel(TenantGroupMemberContext).
        return false.    
    end.    
    
     method public override logical Delete(pname as character):
        if this-object:Find(pname) then
        do:
            return TenantGroupMemberContext:Delete(ParentValue,pName).
        end.
        return false.    
    end.    
      
    /* the colletion should override Add to call this and avoid elem:Attach   */ 
    method public override void CreateRow (pelem as IDataAdminElement).
        define variable inst as ITenant no-undo.
        inst = cast(pelem,ITenant).
        TenantGroupMemberContext:CreateRow(ParentValue,inst:name).
    end method.
    
    method public override void ExportLastSaved(pcfile as char). 
        define variable hBuffer as handle no-undo.
        if valid-handle(LastSavedDataset) then
        do:
            hbuffer = LastSavedDataset:get-buffer-handle(TableHandle:Name) . 
            hbuffer:buffer-field ("TenantGroupName"):serialize-hidden = true.
            hbuffer:buffer-field ("TenantGroupUrl"):serialize-hidden = true.
            hbuffer:buffer-field ("Url"):serialize-hidden = true.         
            if valid-handle(hBuffer) then 
                hBuffer:write-json ("File",pcFile,yes).    
        end.
    end method.  
    
    method public override IFetchRequest GetQueryRequest():
        define variable tree as IContextTree no-undo.
        define variable msg as IFetchRequest no-undo.
        define variable hds as handle no-undo.
          
        tree = new ContextTree().
        TenantGroupMemberContext:AddTableTo(tree).
        tree:SetJoin("TenantGroupMembers","Tenants","TenantName,Name"). 
       
        AddTableTo(tree).
        hds = tree:GetReadHandle().
        msg = new FetchRequest(Name,Id,hds). 
 
        return msg.                 
    end method.
    
    method public override character GetJoinFields(pcparent as char):
        if pcParent = "TenantGroups" then
            return "Name,TenantGroupName".
        else return super:GetJoinFields(pcparent).
    end method.
   
  
end class.