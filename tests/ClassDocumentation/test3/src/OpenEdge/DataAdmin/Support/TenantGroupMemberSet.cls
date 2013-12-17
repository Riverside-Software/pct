/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    Purpose     : Set of TenantGroupMembers
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Jun 10 00:20:07 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.DataAdminCollection from propath.

using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.ITenantGroup from propath.
using OpenEdge.DataAdmin.ITenantGroupSet from propath.
using OpenEdge.DataAdmin.ITenantGroupMember from propath.
using OpenEdge.DataAdmin.ITenantGroupMemberSet from propath.
using OpenEdge.DataAdmin.ITenant from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
 

class OpenEdge.DataAdmin.Support.TenantGroupMemberSet abstract inherits DataAdminCollection implements ITenantGroupMemberSet :  
    
    constructor TenantGroupMemberSet(cntxt as FilteredContext):
        super (cntxt).
    end method.

    method protected override IDataAdminContext CreateLocalContext():
        return ?. 
/*        define variable cntxt as IDataAdminContext no-undo.*/
/*        return new TenantGroupMemberContext().          */
    end.
        
    method public logical Add(detail as ITenantGroupMember):
        if Contains(detail) then
            return false.  
        detail:Attach(Context).
        
        return true.      
    end method.  
    
    method public override logical Contains(obj as Object):
        return Contains(cast(obj,ITenantGroupMember)).   
        catch e as Progress.Lang.Error :
            return false.   
        end catch.
    end method.
    
    method public abstract logical Contains(newGroup as ITenantGroupMember).
    method public abstract logical Remove(detail as ITenantGroupMember).
                  
    method public ITenantGroupMember Find(name as char):
        return cast(Context:FindEntity(name),ITenantGroupMember).            
    end method.   
    
    method public logical CanFind(name as char):
        return Context:CanFind(name).
    end method.   
    
end class.
