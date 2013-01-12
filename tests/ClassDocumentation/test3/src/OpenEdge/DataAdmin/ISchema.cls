/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : ISchema
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Jun 10 00:52:52 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
 
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.Binding.IDataDefinitionOptions from propath.
 
using OpenEdge.DataAdmin.ITableSet from propath.
using OpenEdge.DataAdmin.IPartitionCollection from propath.
using OpenEdge.DataAdmin.ISequenceSet from propath.
 
 

interface OpenEdge.DataAdmin.ISchema inherits IDataAdminElement:  
    
    /** SchemaState is "NEW" for unloaded schema, 
                    "LOADED" for loaded schema 
                    "IMPORTED" after import of partitions 
                    "NORMAL" n a regular instance retrieved through the service:GetSchema() */ 
    define public property SchemaState as character no-undo  get. 
    
    define public property Name as character no-undo      get.
    
    /** Tables in the schema. Not accessible in an unloaded schema.*/ 
    define public property Tables as ITableSet no-undo      get.
    
    /** Sequences in the schema. Not accessible in an unloaded schema.*/ 
    define public property Sequences as ISequenceSet no-undo      get.
    
    /** Partitions are accessible in a schema instance with newly loaded definition changes. 
        The property will throw an UnsupportedOperationError if referenced in a new 
        unloaded schema or in a regular instance retrieved through the service:GetSchema(). 
        For a regular Schema Partitions are available in the each table (ITable) in the Schema's 
        Tables collections and in the indexes (IIndex) and fields (IField) in the table's
        Indexes and LOBFields collections. */               
    define public property Partitions as IPartitionCollection  no-undo   get.
    
    /** Load options for new schema changes */ 
    define public property LoadOptions as IDataDefinitionOptions no-undo get.
    
    /** ImportTree overload to allow load of Options and Partitions 
        from JSON into a Schema with unloaded schema changes.
        @param filename json filename
        @param collections - Comma separated list of collections to load. 
        Currently expected to consist of 'options' and/or 'partitions'. */ 
    method public void ImportTree(pcfile as char,pcCollection as char).
end interface.
