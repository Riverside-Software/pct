/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    Purpose     : Interface for table (data source _file)
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Jun 10 00:12:35 EDT 2010
    Notes       : Currently only for MT
  ----------------------------------------------------------------------*/
 
 
using OpenEdge.DataAdmin.ISchemaElement from propath.
 
using OpenEdge.DataAdmin.ISchema from propath.
using OpenEdge.DataAdmin.IIndexSet from propath.
using OpenEdge.DataAdmin.IFieldSet from propath.
 
interface OpenEdge.DataAdmin.ITable  inherits ISchemaElement  :  
    /** is the table multi-tenant. Only updatable before create  */
    define public property IsMultitenant as logical no-undo get. set.
    /** keep area for default tenant. Only updatable before create  */
    define public property KeepDefaultArea as logical no-undo get. set.
    /* collection of the table's indexes */
    define public property Indexes as IIndexSet no-undo get.
    
    /* collection of the table's LOBfields */
    define public property LOBFields as IFieldSet no-undo   get.
    
    /** Allocate all delayed partitions for all tenants
        Does not allocate group partitions  
        @return true if any partition was allocated  */
    method public logical Allocate().
    
    /** Allocate tenant partitions for table   
        Does not allocate partitions belonging to a tenantgroup  
        @param AllocationState Specify state of partitions to allocate - All, Delayed or None 
        @return true if any partition was allocated  */     
    method public logical Allocate(pcmode as char).
 
      
end interface.
