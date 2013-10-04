 /*************************************************************/
 /* Copyright (c) 2010 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : Partitions for a tenantgroup or tenant mapped to schema elements
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
 
using OpenEdge.DataAdmin.ITable from propath.
using OpenEdge.DataAdmin.IIndex from propath.
using OpenEdge.DataAdmin.IField from propath.
using OpenEdge.DataAdmin.PartitionCollection from propath.
using OpenEdge.DataAdmin.IPartitionMap from propath.
using OpenEdge.DataAdmin.ISchemaElement from propath.
using OpenEdge.DataAdmin.IPartition from propath.
using OpenEdge.DataAdmin.Partition from propath.
 
using OpenEdge.DataAdmin.Binding.Query.IPartitionQuery from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
 

using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath. 
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath. 
 
class OpenEdge.DataAdmin.Support.PartitionMap inherits PartitionCollection implements IPartitionMap: 
    
    define private variable PartitionQuery as IPartitionQuery no-undo.
    
    constructor PartitionMap(cntxt as IPartitionQuery):
        super(cast(cntxt,IDataAdminContext)).   
        PartitionQuery = cntxt.   
    end constructor. 
    
    method protected override IDataAdminContext CreateLocalContext():
        undo, throw new UnsupportedOperationError("Create local context in PartitionMap"). 
    end.     
    
    method public logical ContainsValue(ppartition as IPartition):
        return Contains(ppartition).   
    end method. 
    
    method public IPartition Get(obj as ISchemaElement):
        if type-of(obj,ITable) then 
            return this-object:Get(cast(obj,ITable)). 
        else if type-of(obj,IField) then 
            return this-object:Get(cast(obj,IField)). 
        else if type-of(obj,IIndex) then 
            return this-object:Get(cast(obj,IIndex)).    
        return ?.
    end method.  
    
    method public IPartition Get(ptable as ITable):  
        return FindTable(ptable:name).
    end method.  
    
    method public IPartition Get(obj as IIndex).  
        return FindIndex(obj:Table:name,obj:name,"").
    end method.  
    
    method public IPartition Get(obj as IField).  
        return FindField(obj:Table:name,obj:name).
    end method.  
    
    method public logical ContainsKey(ptable as ITable):
        return CanFindTable(ptable:name).   
    end method.  
    
    method public logical ContainsKey(obj as IIndex):
        return CanFindIndex(obj:Table:name,obj:name,?).
    end method.  
    
    method public logical ContainsKey(obj as IField):
        return CanFindIndex(obj:Table:name,obj:name,?).
    end method.  
    
    method public logical ContainsKey(element as ISchemaElement):
        if type-of(element,ITable) then 
            return this-object:ContainsKey(cast(element,ITable)). 
        else if type-of(element,IField) then 
            return this-object:ContainsKey(cast(element,IField)). 
        else if type-of(element,IIndex) then 
            return this-object:ContainsKey(cast(element,IIndex)).    
        return ?.     
    end method.  
    
    method public IPartition FindTable(pctable as char):
        if PartitionQuery:FindTable(pctable) then
             return new Partition( Context).
    end method. 
    
    method public IPartition FindField(pctable as char,pcField as char):
        if PartitionQuery:FindField(pctable,pcfield) then
             return new Partition( Context).
    end method. 
    
    method public IPartition FindIndex(pctable as char,pcIndex as char,pcCollation as char):
       if PartitionQuery:FindIndex(pctable,pcIndex,pcCollation)  then
           return new Partition( Context).
    end method. 
             
    method public logical CanFindTable(pctable as char):
        return PartitionQuery:CanFindTable(pctable). 
    end method. 
    
    method public logical CanFindField(pctable as char,pcField as char):
        return PartitionQuery:CanFindField(pctable,pcfield). 
    end method. 
    
    method public logical CanFindIndex(pctable as char,pcIndex as char,pcCollation as char):
        return PartitionQuery:CanFindIndex(pctable,pcIndex,pccollation). 
    end method. 
    
    method public logical Allocate():
        return PartitionQuery:Allocate().
    end method.  
    
end class.
