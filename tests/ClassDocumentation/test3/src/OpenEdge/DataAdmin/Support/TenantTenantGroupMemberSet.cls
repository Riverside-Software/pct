 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /** ------------------------------------------------------------------------
    Purpose     : Set of TenantGroupMembers for one Tenant 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : 
  ---------------------------------------------------------------------- */
routine-level on error undo, throw.
using Progress.Lang.* from propath.  

using OpenEdge.DataAdmin.ITenantGroup from propath.
using OpenEdge.DataAdmin.ITenantGroupMember from propath.  
using OpenEdge.DataAdmin.Support.TenantTenantGroupMemberSet from propath.
using OpenEdge.DataAdmin.Support.TenantGroupMemberSet from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
using OpenEdge.DataAdmin.Binding.TenantGroupMemberContext from propath.
 
using OpenEdge.DataAdmin.Error.UnknownValueError from propath.
 

class OpenEdge.DataAdmin.Support.TenantTenantGroupMemberSet inherits TenantGroupMemberSet : 
    
    define private variable mTenantName as char no-undo.
    /*
    define property Tenant as ITenant no-undo 
        get. 
        set.
   */
  
    constructor TenantTenantGroupMemberSet(cntxt as FilteredContext):
        super(cntxt).  
        mTenantname = cntxt:ParentValue.
    end constructor. 
     
    method public override logical Remove(detail as ITenantGroupMember):
        define variable groupinst as ITenantGroup no-undo.
        if not valid-object(detail) then
            undo, throw new UnknownValueError("Remove","TenantGroupMember").
        groupinst = detail:TenantGroup.
        if not valid-object(groupinst) then
            undo, throw new UnknownValueError("TenantGroupMemberSet:Remove","TenantGroupMember:TenantGroup"). 
        return Context:Delete(detail:TenantGroup:Name).
    end method.
    
    method public override logical Contains(detail as ITenantGroupMember ):
        if detail:ContextId <> ContextId then 
            return false.
        if detail:Tenant:name <> mTenantName then    
            return false.
        return CanFind(detail:TenantGroup:Name).     
    end method.    
/*    method public ITenantGroupMember Find(groupname as char):*/
/*        if Context:Find(groupname) then                         */
/*            return new TenantGroup(this-object:Context).     */
/*        return ?.                                               */
/*    end method.                                                 */
    
/*    method public logical CanFind(groupname as char):*/
/*        return Context:CanFind(groupname).           */
/*    end method.                                      */
/*                                                     */
    method override protected void PrepareExport(  ):
        TableHandle:default-buffer-handle:buffer-field("TenantName"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("TenantDescription"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("Tenanturl"):serialize-hidden = true.
    end method.    
     
    method override protected void PrepareExportTree():
        TableHandle:default-buffer-handle:buffer-field("PartitionsURL"):serialize-hidden = true.
    end method.      
    
    method override logical Equals(obj as Object): 
        define variable tset as TenantTenantGroupMemberSet no-undo. 
        if super:Equals(obj) then 
            return true.
        else do:
            tset = cast(obj,TenantTenantGroupMemberSet).  
            return this-object:ContextId = tset:ContextId. 
        end.
        catch e as Error :
        	return false.	
        end catch.    
    end method.
    
    method override protected void PrepareExportList():
        PrepareExport().
    end method.    
    
   
end class.
