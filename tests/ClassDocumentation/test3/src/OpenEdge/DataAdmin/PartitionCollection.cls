 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       :  
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.DataAdminCollection from propath.

using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IPartitionCollection from propath.
using OpenEdge.DataAdmin.IPartition from propath.
using OpenEdge.DataAdmin.Partition from propath.
using OpenEdge.DataAdmin.ITable from propath.
using OpenEdge.DataAdmin.IField from propath.
using OpenEdge.DataAdmin.IIndex from propath.
  
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.IPartitionContext from propath.
using OpenEdge.DataAdmin.Binding.PartitionContext from propath.
using OpenEdge.DataAdmin.Binding.QueryContext from propath.

 

class OpenEdge.DataAdmin.PartitionCollection inherits DataAdminCollection 
                                             implements IPartitionCollection : 
     
    
    define private variable mLoaded   as logical no-undo.
    
     
    define protected property PartitionContext as IPartitionContext no-undo 
       get():
           return cast(Context,IPartitionContext). 
       end.
     
    constructor PartitionCollection(cntxt as PartitionContext):
        super(cntxt).  
    end constructor. 
   
    
     constructor PartitionCollection(cntxt as IDataAdminContext):
        super(cntxt).  
/*        if not (type-of(cntxt,FilteredContext) or type-of(cntxt,TenantContext)) then                      */
/*             undo, throw new IllegalArgumentError("Invalid context type passed to TenantSet constructor").*/
/*                                                                                                          */
    end constructor. 
    
    constructor PartitionCollection(cntxt as QueryContext):
        super(cntxt).  
    end constructor. 
    
    constructor PartitionCollection(cntxt as FilteredContext):
        super(cntxt).  
    end constructor. 
    
    method protected override IDataAdminContext CreateLocalContext():
        return new PartitionContext().
    end.       
 
/*    method public logical CanFind(tenant as Itenant, element  as ISchemaElement):                       */
/*        define variable oTable as ITable no-undo.                                                       */
/*        define variable oIndex as IIndex no-undo.                                                       */
/*        define variable oLob   as IField no-undo.                                                       */
/*        define variable lok    as logical no-undo.                                                      */
/*                                                                                                        */
/*        if this-object:ContextId <> tenant:ContextId then                                               */
/*            return false.                                                                               */
/*                                                                                                        */
/*        if this-object:ContextId <> element:ContextId then                                              */
/*            return false.                                                                               */
/*                                                                                                        */
/*        if type-of(element,ITable) then                                                                 */
/*        do:                                                                                             */
/*            oTable = cast(element,ITable).                                                              */
/*            return PartitionContext:CanFindTable(oTable:Name).                                          */
/*        end.                                                                                            */
/*        else if type-of(element,IIndex) then                                                            */
/*        do:                                                                                             */
/*            assign                                                                                      */
/*                oIndex = cast(element,IIndex)                                                           */
/*                oTable = oIndex:Table.                                                                  */
/*            return PartitionContext:CanFindIndex(oTable:Name,oIndex:Name,"" /*oIndex:Collection:name*/).*/
/*        end.                                                                                            */
/*        else if type-of(element,IField) then                                                            */
/*        do:                                                                                             */
/*            assign                                                                                      */
/*                oLob     = cast(element,IField)                                                         */
/*                oTable   = oLob:Table.                                                                  */
/*            return PartitionContext:CanFindField(oTable:Name,oLob:Name).                                */
/*        end.                                                                                            */
/*                                                                                                        */
/*    end method.                                                                                         */
                  
    method public override logical Contains(obj as Object):
        return Contains(cast(obj,IPartition)).   
        catch e as Progress.Lang.Error :
            return false.   
        end catch.
    end method.
       
    method public logical Contains(ppartition as IPartition):         
        define variable cName as character no-undo.
        define variable cTableName as character no-undo.
        define variable cFieldName as character no-undo.
        define variable cIndexName as character no-undo.
        define variable cCollation as character no-undo.
        
        if ppartition:ContextId <> ContextId then 
            return false. 
            
        if type-of(ppartition:element,ITable) then                                                                                       
        do:
            cTableName = ppartition:element:Name.           
        end.
        else if type-of(ppartition:element,IIndex) then
        do: 
            assign
                cTableName = cast(ppartition:element,IIndex):Table:Name           
                cIndexName = ppartition:element:Name
                cCollation = "". 
        end.
        else if type-of(ppartition:element,IField) then
        do:
            assign
                cTableName = cast(ppartition:element,IField):Table:Name           
                cFieldName = ppartition:element:Name.
        end.        
        if valid-object(ppartition:Tenant) then       
            return CanFindTenant(ppartition:Tenant:Name,ctablename,cFieldname, cIndexName,ccollation).
        else          
            return CanFindGroup(ppartition:TenantGroup:Name,ctablename,cFieldname, cIndexName,ccollation).
    end method.
    
    method public IPartition FindTenant(pcTenant as char,pctable as char,pcField as char, pcIndex as char,pccollection as char):
        if PartitionContext:FindTenant(pcTenant,pctable,pcField,pcIndex,pcCollection) then
            return new Partition( Context).
    end method.    
   
    method public logical CanFindTenant(pcTenant as char,pctable as char,pcField as char, pcIndex as char,pccollection as char).
        return PartitionContext:CanFindTenant(pcTenant,pctable,pcField,pcIndex,pcCollection). 
    end method.
    
    method public IPartition FindGroup(pcGroup as char,pctable as char,pcField as char, pcIndex as char,pccollection as char):
        if PartitionContext:FindGroup(pcGroup,pctable,pcField,pcIndex,pcCollection) then
            return new Partition( Context).
    end method.    
   
    method public logical CanFindGroup(pcGroup as char,pctable as char,pcField as char, pcIndex as char,pccollection as char).
        return PartitionContext:CanFindGroup(pcGroup,pctable,pcField,pcIndex,pcCollection). 
    end method.     
    
    method protected override void PrepareExport():
/*        Tablehandle:default-buffer-handle:buffer-field("URL"):serialize-hidden = true.*/
    end method.
     
    method override void PrepareExportTree():
    end method.
      
    method protected override void PrepareExportList():   
    end method.
    
end class.
