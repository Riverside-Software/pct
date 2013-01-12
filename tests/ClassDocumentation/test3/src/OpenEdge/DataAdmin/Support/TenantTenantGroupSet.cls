 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------ 
    Purpose     : TenantGroupSet of a Tenant
    Syntax      : 
    Description : Updates (adds or removes) many to many relations between 
                  TenantGroupSet and Tenant with Tenant as parent 
                  (TenantGroup is context parent)   
    Author(s)   : hdaniels
    Created     : Mon Aug 29 04:54:29 EDT 2011
    Notes       : Add and Remove are overridden to update partition group 
                  detail context instead of tenant context
                - No other updates allowed (no other fields) 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Progress.Lang.* from propath.

using OpenEdge.DataAdmin.TenantGroupSet from propath.
using OpenEdge.DataAdmin.ITenantGroup from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.TenantGroupMemberContext from propath.

using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.

class OpenEdge.DataAdmin.Support.TenantTenantGroupSet inherits TenantGroupSet: 
    
    define private variable mTenantName as char.
    
    constructor TenantTenantGroupSet(cntxt as FilteredContext  ):
        super(cntxt).  
        mTenantName = cntxt:ParentValue.
    end constructor. 
      
    method protected override IDataAdminContext CreateLocalContext():
        return ?.
    end.     
    
    /* override to avoid attach to tenant context - create relation directly in manytomany table */
    method public override logical Add(pgroup as ITenantGroup).    
        if Contains(pgroup) then
            return false.   
            
        Context:CreateRow(pGroup).
         
        return true.
         
    end method.  
    
end class.