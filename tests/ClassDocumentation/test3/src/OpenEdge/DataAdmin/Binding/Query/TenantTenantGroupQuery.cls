/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     : Used for a collection of PartionGroups for the tenant
                  indexed/mapped by PartionGroupName            
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Mon Apr 18 22:12:27 EDT 2011 
                - date applies to some unknown original - many save-as has happened since...
       Notes    : tenantgroupContext is the main context since this is to be used 
                  by ItenantgroupSet collections with Itenantgroup elements. 
                - The TenantGroupMemberContext is used for add and remove
                  sonce it defines the many to many relation ship that is being updated.
                - The query joins these context tables. 
                - This query is added to ttTenantgroupmember, but 
                  passed as tenant entityname, in the request.
                - There is an equivalent query to handle this from the other side;
                  tenantgroupTenantQuery 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
 
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.IDataAdminElement  from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.
using OpenEdge.DataAdmin.ITenantGroup  from propath.
using OpenEdge.DataAdmin.Binding.Query.ManyToManyQuery from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.TenantGroupMemberContext from propath.
using OpenEdge.DataAdmin.Binding.TenantGroupContext from propath.
using OpenEdge.DataAdmin.Binding.ContextTree from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Message.FetchRequest from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Lang.QueryString from propath.


routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.Query.TenantTenantGroupQuery inherits ManyToManyQuery: 
	
    /** UpdateContext(Model) may change so don't store this */   
    define private property TenantGroupMemberContext as TenantGroupMemberContext no-undo 
        get():
            return cast(UpdateContext,TenantGroupMemberContext).   
        end.
        
    constructor public TenantTenantGroupQuery (pparent as  TenantGroupContext,tenantName as char,pReq as IRequestInfo):
		super (pparent,"tenants",tenantName,"tenantGroupMembers",pReq).	
	end constructor.
  
    method public override logical CanFind(pname as character):    
        if TenantGroupMemberContext:Find(pname,ParentValue) then
            return CanFindCurrentModel(TenantGroupMemberContext). 
        return false.    
    end.    
     
    method public override logical Find(pname as character):
        if TenantGroupMemberContext:Find(pname,ParentValue) then
            return SynchWithModel(TenantGroupMemberContext). 
        return false.    
    end.    
    
    method public override logical Delete(pname as character):
        if this-object:Find(pname) then
        do:
            return TenantGroupMemberContext:Delete(pname,ParentValue).
        end.
        return false.    
    end.    
    
    
    
    /* the colletion should override Add to call this and avoid elem:Attach   */ 
    method public override void CreateRow (pelem as IDataAdminElement).
        define variable inst as Itenantgroup no-undo.
        inst = cast(pelem,Itenantgroup).
        TenantGroupMemberContext:CreateRow(inst:name,ParentValue).
    end method.
       
    method public override void ExportLastSaved(pcfile as char). 
        define variable hBuffer as handle no-undo.
        if valid-handle(LastSavedDataset) then
        do:
            hbuffer = LastSavedDataset:get-buffer-handle(TableHandle:Name) . 
            hbuffer:buffer-field ("TenantName"):serialize-hidden = true.
            hbuffer:buffer-field ("TenantUrl"):serialize-hidden = true.
            hbuffer:buffer-field ("Url"):serialize-hidden = true.         
            if valid-handle(hBuffer) then 
                hBuffer:write-json ("File",pcFile,yes).    
        end.
    end method.  
    
    method public override IFetchRequest GetQueryRequest():
        define variable tree as IContextTree no-undo.
        define variable msg as IFetchRequest no-undo.
        define variable hds as handle no-undo.
        define variable cSeqValQuery as character no-undo.
        define variable cSequenceQuery as character no-undo.
        define variable qstr as QueryString no-undo.
        
        tree = new ContextTree().
        TenantGroupMemberContext:AddTableTo(tree).
        tree:SetJoin("TenantGroupMembers","TenantGroups","TenantGroupName,Name"). 
        AddTableTo(tree).
        
        hds = tree:GetReadHandle().
        msg = new FetchRequest(Name,Id,hds). 
      
        return msg.
                 
    end method.
    
    method public override character GetJoinFields(pcparent as char):
        if pcParent = "Tenants" then
            return "Name,TenantName".
        else 
            return super:GetJoinFields(pcparent).
    end method.
    
    
end class.