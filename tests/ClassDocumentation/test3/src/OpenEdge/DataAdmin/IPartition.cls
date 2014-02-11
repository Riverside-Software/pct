/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : IPartition
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Jun 10 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.ITenantGroup from propath.
using OpenEdge.DataAdmin.ITenant from propath.
using OpenEdge.DataAdmin.ISchemaElement from propath.
using OpenEdge.DataAdmin.IArea from propath.
 

interface OpenEdge.DataAdmin.IPartition inherits IDataAdminElement:  
    
    /** returns true if the partition belongs to a multi-tenant enabled table */
    define public property IsMultiTenant  as logical no-undo  get.
    
    /** The TenantGroup of the partition - unknown if this is a tenant partition */
    define public property TenantGroup as ITenantGroup no-undo get.  
    
    /** The ObjectType of the partition - character expression Table,Index or Field */
    define public property ObjectType as character no-undo get. 
    
    /** The Tenant of the partition - unknown if this is a group partition */
    define public property Tenant        as ITenant        no-undo get. 
    
    /** The SchemaElement (ITable,IField or IIndex) of the partition */
    define public property Element       as ISchemaElement no-undo get.  
    
    /** The Area of the partition - readonly when the partition is allocated */
    define public property Area          as IArea     no-undo get. set.
    
    /** The partition's allocation state - "Allocated", "Delayed" or "None".
        Readonly when "Allocated" */
    define public property AllocationState as char no-undo get. set.  
    
    /** The partition's buffer pool - "Primary", "Alternate" */
    define public property BufferPool      as char no-undo get. set.  
    
    /** Returns true if the partition's buffer pool can be set to "Alternate" */
    define public property CanAssignAlternateBufferPool  as logical no-undo get.   
    
    /** Allocates the partition () */
    method public logical Allocate().
    
/*    method public logical Deallocate().*/
end interface.
