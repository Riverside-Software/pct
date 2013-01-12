/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    Purpose     : SchemaElement partitions mapped to Tenants or Groups
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Aug 2010
    Notes       : 
  ----------------------------------------------------------------------*/
 
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.ISchemaElement from propath.
using OpenEdge.DataAdmin.ITenant from propath.
using OpenEdge.DataAdmin.ITenantGroup from propath.
using OpenEdge.DataAdmin.IPartition from propath.
 
interface OpenEdge.DataAdmin.ISchemaPartitionMap inherits IDataAdminCollection:  
    
    method public logical ContainsKey(ptenant as ITenant).  
    method public logical ContainsValue(partition as IPartition).  
    method public logical ContainsKey(pgroup as ITenantGroup).  
    method public IPartition Get(elm as IDataAdminElement).  
    method public IPartition Get(pgroup as ITenantGroup).  
    method public IPartition Get(tenant as ITenant).  
 
    method public IPartition FindGroup(name as char).  
    method public IPartition FindTenant(name as char).  
    
    /** Allocate all delayed partitions for all tenants
        Does not allocate partitions belonging to a tenantgroup  
        @return true if any partition was allocated  */
    method public logical AllocateTenants() .
    
    /** Allocate tenant partitions for the parent schema elelement    
        Does not allocate partitions belonging to a tenantgroup  
        @param AllocationState Specify state of partitions to allocate - All, Delayed or None 
        @return true if any partition was allocated 
        @throw IllegalArgumentError if not valid AllocationState */     
    method public logical AllocateTenants(pcAllocationState as char). 
    
    /** Allocate all delayed partitions for all tenantgroup
        Does not allocate partitions belonging to a tenantgroup  
        @return true if any partition was allocated  */
    method public logical AllocateGroups() .
    
    /** Allocate tenantgroup partitions for the parent schema elelement    
         
        @param AllocationState Specify state of partitions to allocate - All, Delayed or None 
        @return true if any partition was allocated 
        @throw IllegalArgumentError if not valid AllocationState */     
    method public logical AllocateGroups(pcAllocationState as char). 
    
end interface.
