 /*************************************************************/
 /* Copyright (c) 2010 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : TenantGroupMemberSet
    Purpose     : set of partition group details for a tenant
                  with find on group name  
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Jun 10 00:20:07 EDT 2010
    Notes       : The entity contained in the collection is 
                  of type ITenantGroupMember, which has two properties
                  the ITenantGroup and ITenant
                 (the opposite ITenantTenantGroupSet collection 
                  contains the same type of object)
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.  
using OpenEdge.DataAdmin.DataAdminService from propath.
 
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.ITenantGroup from propath.
using OpenEdge.DataAdmin.ITenantGroupMember from propath.
using OpenEdge.DataAdmin.TenantGroupMember from propath.

 
using OpenEdge.DataAdmin.ITenant from propath.

using OpenEdge.DataAdmin.Support.TenantGroupMemberSet from propath.
using OpenEdge.DataAdmin.Support.TenantGroupTenantGroupMemberSet from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
 
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
using OpenEdge.DataAdmin.Binding.TenantGroupMemberContext from propath.

 
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.UnknownValueError from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.

class OpenEdge.DataAdmin.Support.TenantGroupTenantGroupMemberSet inherits TenantGroupMemberSet : 
    
    define private variable mTenantGroupName as char no-undo.
     
       
/*    constructor TenantGroupTenantSet(cntxt as TenantGroupMemberContext):*/
/*        super(cntxt).                                                         */
/*    end constructor.                                                          */
/*                                                                              */
    constructor TenantGroupTenantGroupMemberSet(cntxt as FilteredContext):
        super(cntxt).  
        mTenantGroupName = cntxt:ParentValue.
    end constructor. 
    
    method protected override IDataAdminContext CreateLocalContext():
        define variable cntxt as IDataAdminContext no-undo.
        return new TenantGroupMemberContext().
    end.     
       
    method public override logical Contains(detail as ITenantGroupMember ):
        if detail:ContextId <> ContextId then 
            return false.
        if detail:TenantGroup:name <> mTenantGroupName then    
            return false.
        return CanFind(detail:Tenant:Name).     
    end method.  
    
    method public override logical Remove(detail as ITenantGroupMember):
        define variable tenant as ITenant no-undo.
        if not valid-object(detail) then
            undo, throw new UnknownValueError("Remove","TenantGroupMember").
        tenant = detail:Tenant.
        if not valid-object(tenant) then
            undo, throw new UnknownValueError("TenantGroupMemberSet:Remove","TenantGroupMember:Tenant"). 
   
        return Context:Delete(detail:Tenant:Name).
    end method.
         
    method override logical Equals(obj as Object): 
        define variable tset as TenantGroupTenantGroupMemberSet no-undo. 
        if super:Equals(obj) then 
            return true.
        else do:
            tset = cast(obj,TenantGroupTenantGroupMemberSet).  
            return this-object:ContextId = tset:ContextId. 
        end.
        catch e as Error :
        	return false.	
        end catch.    
    end method.
    
    method override protected void PrepareExport(  ):
        TableHandle:default-buffer-handle:buffer-field("TenantGroupName"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("TenantGroupDescription"):serialize-hidden = true.
        TableHandle:default-buffer-handle:buffer-field("TenantGroupUrl"):serialize-hidden = true.
    end method.    
     
    method override protected void PrepareExportTree():
        PrepareExport().     
    end method.      
    
   
    method override protected void PrepareExportList():
        PrepareExport().     
    end method.    
    
   
end class.
