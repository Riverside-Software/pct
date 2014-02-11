/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    Purpose     : A tenant or tenantgroups partitions mapped to SchemaElements 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.ITenant from propath.
using OpenEdge.DataAdmin.IPartition from propath.
using OpenEdge.DataAdmin.ISchemaElement from propath.
using OpenEdge.DataAdmin.ITable from propath.
using OpenEdge.DataAdmin.IIndex from propath.
using OpenEdge.DataAdmin.IField from propath.
 
interface OpenEdge.DataAdmin.IPartitionMap inherits IDataAdminCollection:  
           
    method public logical ContainsKey(obj as ISchemaElement).  
    method public logical ContainsValue(partition as IPartition).  
    method public IPartition Get(obj as ISchemaElement).  
    
    method public IPartition FindTable(pcTable as char).  
    method public IPartition FindField(pcTable as char,pcField as char).  
    method public IPartition FindIndex(pcTable as char,pcIndex as char,pcCollation as char).  
    
    method public logical Allocate().    
    
end interface.
