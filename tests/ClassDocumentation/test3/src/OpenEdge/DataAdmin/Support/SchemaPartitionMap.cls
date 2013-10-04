 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : Collection of partititons for a table,index or field
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.

using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.ITenant from propath.
using OpenEdge.DataAdmin.ITenant from propath.
using OpenEdge.DataAdmin.ITenant from propath.

using OpenEdge.DataAdmin.ITenant from propath.
using OpenEdge.DataAdmin.ITenantGroup from propath.
using OpenEdge.DataAdmin.PartitionCollection from propath.
using OpenEdge.DataAdmin.ISchemaPartitionMap from propath.
using OpenEdge.DataAdmin.ISchemaElement from propath.
using OpenEdge.DataAdmin.IPartition from propath.
using OpenEdge.DataAdmin.Partition from propath.
 
using OpenEdge.DataAdmin.Binding.PartitionContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.


using OpenEdge.DataAdmin.Binding.Query.SchemaPartitionQuery from propath.

using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath. 
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath. 
 
class  OpenEdge.DataAdmin.Support.SchemaPartitionMap inherits PartitionCollection implements ISchemaPartitionMap: 
    
    define private variable SchemaPartitionQuery as SchemaPartitionQuery no-undo.
            
    constructor SchemaPartitionMap(cntxt as SchemaPartitionQuery):
        super(cntxt).  
        SchemaPartitionQuery = cntxt.
    end constructor. 
    
    method protected override IDataAdminContext CreateLocalContext():
        undo, throw new UnsupportedOperationError("Create local context in SchemaPartitionMap ") .
    end.     
    
    /** Get tenant partition
        @param element IDataAdminElement   
        @return IPartition if partition is mapped to specified IDataAdminElement, unknown if not found */
   method public IPartition Get(elm as IDataAdminElement):
        if type-of(elm,ITenant) then
            return Get(cast(elm,ITenant)).      
        else if type-of(elm,ITenantGroup) then
            return Get(cast(elm,ITenantGroup)).      
        return ?.
    end method. 
    
    /** Get group partition
        @param group ITenantGroup  
        @return IPartition if partition is mapped to specified ITenantGroup, unknown if not found */
    method public IPartition Get(grp as ITenantGroup):
        return FindGroup(grp:Name).      
    end method. 
 
    /** find tenant partition
        @param tenant ITenant  
        @return IPartition if partition is mapped to specified ITenant, unknown if not found */
    method public IPartition Get(tnt as ITenant):
        return FindTenant(tnt:Name).      
    end method. 
    
    /** find tenant partition
        @param group ITenantGroup  
        @return true if a partition is mapped to specified ITenantGroup */
    method public logical ContainsKey(grp as ITenantGroup):
        return CanFindGroup(grp:Name).      
    end method.  
    
    /** find tenant partition
        @param tenant ITenant  
        @return true if a partition is mapped to specified ITenant */
    method public logical ContainsKey(tnt as ITenant):
        return CanFindTenant(tnt:Name).      
    end method.  
    
    /** find tenant partition
        @param group ITenantGroup  
        @return partition if found in collection/map. unknown if not found */
    method public logical ContainsValue(pPartition as IPartition):
        return  Contains(pPartition).      
    end method.  
    
    /** find tenant partition
        @param tenantName   
        @return IPartition if partition is mapped to specified tenant name, unknown if not found */
    method public IPartition FindTenant(pctenant as char):
        if SchemaPartitionQuery:FindTenant(pctenant) then
             return new Partition( Context).
    end method. 
    
    /** find group partition
        @param groupName TenantGroup  
        @return IPartition if partition is mapped to specified group name, unknown if not found */
    method public IPartition FindGroup(pcGroup as char):
        if SchemaPartitionQuery:FindGroup(pcGroup) then
             return new Partition( Context).
    end method. 
    
    /** Can find tenant partition
        @param tenantName   
        @return true if a partition is mapped to specified Tenant */
    method public logical CanFindTenant(pcTenant as char):
        return SchemaPartitionQuery:CanFindTenant(pcTenant).
    end method. 
    
    /** Can find group partition
        @param groupName  
        @return true if a partition is mapped to specified TenantGroup */
    method public logical CanFindGroup(pcGroup as char):
        return SchemaPartitionQuery:CanFindGroup(pcGroup).
    end method. 
    
    /** Allocate all delayed partitions for all tenants
        Does not allocate partitions belonging to a TenantGroup  
        @return true if any partition was allocated  */
    method public logical AllocateTenants() :
        return SchemaPartitionQuery:Allocate().
    end method.
    
    /** Allocate all delayed partitions for all groups
        @return true if any partition was allocated  */
    method public logical AllocateGroups() :
        return SchemaPartitionQuery:AllocateGroups("Delayed").
    end method.
    
    /** Allocate tenant partitions for the parent schema elelement    
        Does not allocate partitions belonging to a TenantGroup  
        @param AllocationState Specify state of partitions to allocate - All, Delayed or None 
        @return true if any partition was allocated 
        @throw IllegalArgumentError if not valid AllocationState */     
    method public logical AllocateTenants(pcAllocationState as char): 
        return SchemaPartitionQuery:AllocateTenants(pcAllocationState).
    end method.
    
    /** Allocate TenantGroup partitions for the parent schema elelement    
         
        @param AllocationState Specify state of partitions to allocate - All, Delayed or None 
        @return true if any partition was allocated 
        @throw IllegalArgumentError if not valid AllocationState */     
    method public logical AllocateGroups(pcAllocationState as char): 
        return SchemaPartitionQuery:AllocateGroups(pcAllocationState).
    end method.
    
end class.
