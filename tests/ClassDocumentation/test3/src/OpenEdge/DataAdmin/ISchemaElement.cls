/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/

/** Purpose     : super Interface for schema elements ITable, IIndex and IField interfaces 
                  Allows the IPartition interface to have a single property to represent 
                  the ITable, IIndex or IField it belongs to.  
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Jun 10 00:12:12 EDT 2010
    Notes       :  */
 
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IArea from propath.
using OpenEdge.DataAdmin.ISchema from propath.
using OpenEdge.DataAdmin.ISchemaPartitionMap from propath.

using OpenEdge.DataAdmin.Binding.* from propath.  
interface OpenEdge.DataAdmin.ISchemaElement inherits IDataAdminElement:  
    
    define public property Schema as ISchema no-undo get. 
     
    /** Name of the element (tablename, indexname or fieldname) */ 
    define public property Name        as char      no-undo get.
 
    /** Area (for default tenant if Multi-tenant) */ 
    define public property Area        as IArea     no-undo get. 
    
    /** ObjectType "table","index" or "field"  */ 
    define public property ObjectType  as char      no-undo get.   
    
    /** Collection of partitions mapped by tenant or tenantgroup */  
    define public property Partitions  as ISchemaPartitionMap no-undo get.
   
    /** Description   */ 
    define public property Description   as character no-undo get.  

end interface.
