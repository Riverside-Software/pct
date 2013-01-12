 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : TenantSet of a TenantGroup
    Description : Updates (adds or removes) many to many relations between 
                  TenantGroup and Tenant with TenantGroup as parent
                  and a TenantSet as children    
    Author(s)   : hdaniels
    Created     : Mon Aug 29 04:54:29 EDT 2011
    Notes       : Add and Remove are overridden to update partition group 
                  detail context instead of TenantGroup context
                - No other updates allowed (no other fields) 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Progress.Lang.* from propath.

using OpenEdge.DataAdmin.TenantSet from propath.
using OpenEdge.DataAdmin.ITenant from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.TenantGroupMemberContext from propath.

using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.

class OpenEdge.DataAdmin.Support.TenantGroupTenantSet inherits TenantSet: 
    define private variable mTenantGroupName as char.
    
    constructor TenantGroupTenantSet(cntxt as FilteredContext):
        super(cntxt).  
        mTenantGroupName = cntxt:ParentValue.
    end constructor. 
      
    method protected override IDataAdminContext CreateLocalContext():
        return ?.
    end.     
    
    /* override to avoid attach to tenant context - create relation directly in manytomany table */
    method public override logical Add(tenant as ITenant).  
        if Contains(tenant) then
            return false.   
           
        Context:CreateRow(tenant).        
        return true.
    end method.  
     
     
end class.