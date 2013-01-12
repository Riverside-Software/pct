/*************************************************************/
/* Copyright (c) 2011,2012 by Progress Software Corporation  */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/
 /*------------------------------------------------------------------------
    File        : PartitionContext
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Aug 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDataAdminCollection  from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath. 
using OpenEdge.DataAdmin.Partition  from propath.
using OpenEdge.DataAdmin.PartitionCollection  from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath. 
using OpenEdge.DataAdmin.Binding.IRow from propath. 
using OpenEdge.DataAdmin.Binding.Factory.IContextFactory from propath. 
using OpenEdge.DataAdmin.Support.PartitionMap from propath.
using OpenEdge.DataAdmin.Support.SchemaPartitionMap from propath. 
using OpenEdge.DataAdmin.Support.TenantPartitionMap from propath. 

using OpenEdge.DataAdmin.Binding.DataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IPartitionContext from propath.
using OpenEdge.DataAdmin.Binding.PartitionFilteredContext from propath.
using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.
using OpenEdge.DataAdmin.Binding.Query.SchemaPartitionQuery from propath.
using OpenEdge.DataAdmin.Binding.Query.TenantPartitionQuery from propath.
using OpenEdge.DataAdmin.Binding.Query.TablePartitionQuery from propath.
using OpenEdge.DataAdmin.Binding.Query.IndexPartitionQuery from propath.
using OpenEdge.DataAdmin.Binding.Query.FieldPartitionQuery from propath.
using OpenEdge.DataAdmin.Binding.Query.IPartitionQuery from propath.
using OpenEdge.DataAdmin.Binding.Factory.IMultiTenantScope from propath. 
using OpenEdge.DataAdmin.Binding.Query.TenantGroupPartitionQuery from propath.
using OpenEdge.DataAdmin.Message.IFetchResponse from propath. 
 
using OpenEdge.DataAdmin.Error.* from propath.

class OpenEdge.DataAdmin.Binding.PartitionContext inherits DataAdminContext implements IDataAdminContext, IPartitionContext: 
    
    {daschema/partition.i}
    
    define private dataset dsPartition serialize-name "root" for ttPartition.
    define buffer bpartition for ttPartition.
    
    define private property xMissingAllocateKeyMessage  as char no-undo
        init "No &1 specified for allocate operation."
        get.
        
    define temp-table copytable reference-only like ttPartition .  
    
    define private variable mRefresh as logical no-undo.
    
    define protected property ContextFactory as IContextFactory  no-undo 
        get():
            return cast(ContextScope,IContextFactory) .
        end get.
    
    define private variable ValidAllocationStateList as char no-undo
        init   "Allocated,Delayed,None".
    define public override property DatasetHandle as handle no-undo 
        get():
            return dataset dsPartition:handle.
        end get.
    
	define public override property TableHandle as handle no-undo 
    	get():
    		return temp-table ttPartition:handle.
    	end get.
    
    define public override property KeyFields as character  no-undo  
        get():   
            return buffer ttPartition:keys. 
        end.   
    
    define public override property Count as integer init ? no-undo  
        get(): 
            
            if Count = ? then
            do:
                Count = 0.
                for each bpartition:
                    Count = Count + 1.
                end. 
            end.    
            return Count.
        end.
        protected set.
    
    constructor public PartitionContext ():
        super ("Partition").
    end constructor.
    
    
    constructor public PartitionContext ( pScope as IMultiTenantScope):
        super ("Partition",pScope).
    end constructor.
    
    constructor protected PartitionContext ( pScope as IMultiTenantScope,plLocal as log):
        super ("Partition",pScope,plLocal).
    end constructor.
    
 	
	method public override character GetJoinFields(parentid as char):
        case parentid:
            when "tenants" then
                return "Name,TenantName".
            when "tenantGroups" then
                return "Name,TenantGroupName".    
            when "areas" then
                return "Name,AreaName".
            when "tables" then
                return "Name,TableName".
            when "indexes" then
                return "TableName,TableName,Name,IndexName".
            when "fields" or when "lobFields" then
                return "TableName,TableName,Name,FieldName".
            when "schemas" then
                return "Name,SchemaName".   
        end.
    end.
	
	/* uncomment if id is used in GetJoinfields  
	method public override character GetClientJoinFields(parentid as char):
        case parentid:
            when "tenants" then
                return "Name,TenantName".
            when "tenantGroups" then
                return "Name,TenantGroupName".    
        end.
        return super:GetClientJoinFields(parentid).
    end.
	*/
	
	method public override character GetServerJoinFields(parentid as char):
        case parentid:
            when "tenants" then
                return "Id,ParentId".
            when "tenantGroups" then
                return "Id,ParentId".
             when "areas" then /* AreaNumber is not mapped - handled by PartitionDataSource:ColumnSource*/
                return "Number,AreaNumber".        
        end.
        return super:GetServerJoinFields(parentid).
    end.
	
    method public override character GetChildQuery(pcParent as char,pcKeys as char extent):
        if lookup(pcParent,"tables,fields,indexes") <> 0 then 
            return GetChildQuery(pcParent,pcKeys[1],pcKeys[2],pcKeys[3],pcKeys[4]).
        else 
            return super:GetChildQuery(pcParent,pcKeys).
    end method.
	
	method public override character GetServerChildQuery(pcParent as char,pcKeys as char extent):
        if lookup(pcParent,"tables,fields,indexes") <> 0 then 
            return GetServerChildQuery(pcParent,pcKeys[1],pcKeys[2],pcKeys[3],pcKeys[4]).
        else 
            return super:GetServerChildQuery(pcParent,pcKeys).
    end method.
  
    method private character GetChildQuery(pcParent as char,pcTable as char,pcfield as char, pcIndex as char, pcCollation as char):
        case pcparent:
            when "tables" then
                return "preselect each ttPartition where ttPartition.ObjectType= 'Table'" 
                   + " and ttPartition.TableName = "  + quoter(pcTable).
            when "fields" then
                return "preselect each ttPartition where ttPartition.ObjectType= 'Field'" 
                                   + " and ttPartition.TableName = "  + quoter(pcTable)
                                   + " and ttPartition.FieldName = "  + quoter(pcField).
             when "indexes" then
                return "preselect each ttPartition where ttPartition.ObjectType= 'Index'" 
                                   + " and ttPartition.TableName = "  + quoter(pcTable)
                                   + " and ttPartition.IndexName = "  + quoter(pcIndex)
                                   + " and ttPartition.Collation = "  + quoter(pcCollation).
      
        end.
    end method.
    
    method private character GetServerChildQuery(pcParent as char,pcTable as char,pcfield as char, pcIndex as char, pccollation as char):
        define variable cQuery as character no-undo.
        cQuery = GetChildQuery(pcParent,pcTable,pcfield,pcIndex,pccollation).
        cQuery = left-trim(cQuery).
        entry(1,cQuery," ") = "for".
        return cQuery.
           
    end method.
    
    method protected override void ValueChanged(pcfield as char, pcOld as char, pcnew as char):
        define variable i as integer no-undo.
        
        super:ValueChanged(pcfield,pcold,pcNew).
        if pcfield = "AllocationState" and ttPartition.ObjectType = "Table" then
        do: 
            i = lookup(pcnew,ValidAllocationStateList).
            if i > 0 then 
            do: /* just to case it , validation is done elsewhere  */
                ttPartition.AllocationState = entry(i,ValidAllocationStateList).
                pcNew = ttPartition.AllocationState.
            end.
            if ttPartition.TenantName > "" then 
            do: 
                UpdateTenantTableChildPartitions(ttPartition.TenantName,ttPartition.TableName,pcNew).
            end.
            else do:
                UpdateGroupTableChildPartitions(ttPartition.TenantGroupName,ttPartition.TableName,pcNew).
            end.
        end.
    end method.    
    
    method protected override void ValidateProperty(pcfield as char,poldvalue as char,pnewvalue as char).  
        super:ValidateProperty(pcfield,poldvalue,pnewvalue).
        case pcField:
            when "AllocationState" then
            do:
                ValidateAllocationState(poldvalue,pnewValue).
            end.    
        end.    
    end method.
     
    method protected void ValidateAllocationState(pOldvalue as char,pcValue as char):
        if lookup(pcValue,ValidAllocationStateList) = 0 then
            undo, throw new InvalidPropertyValueError ("Partition", "","AllocationState", pcValue, "Allocated,Delayed,None").                      
    
    end method.
    
    method public void ValidateAllocationKey(pcKeyValue as char,pcName as char):
        if pcKeyValue = "" or pcKeyValue = ? then
           undo, throw new IllegalArgumentError(substitute(xMissingAllocateKeyMessage,pcName)).         
    end method.
    
    method public void ValidateAllocationRequest(pcRequest as char):
        /* error is duplicated in TableImpl */
        if lookup(pcRequest,"All,Delayed,None") = 0 then
              undo, throw new IllegalArgumentError (
                               "Parameter value " + quoter(pcRequest) + " passed to allocate method. " 
                              + "Valid values are " 
                              + quoter("Delayed") 
                              + "," + quoter("All")
                              + " or " + quoter("None") + ".").                      
   
    end method.
    
    
    method protected override void ValidateBuffer(phPart as handle):
        define variable hBefore as handle no-undo.
        define variable lok as logical no-undo.
        
        /** allow to keep refreshed  ignored value on server 
        if phPart::ObjectType <> "table" and phPart:row-state <> row-created then 
        do:
           hBefore = phPart:before-buffer.
          
           lok = hbefore:find-by-rowid(phPart:before-rowid) no-error.
          
           if lok then 
           do:
              if phPart::allocationstate <> hBefore::allocationstate then
              do:
                   undo, throw new ReadOnlyPropertyError(
                                   lc(phPart::ObjectType) + " " + lc(name),
                                   "",
                                   "AllocationState",
                                   "AllocationState can only be changed in table partitions").
              end. 
           end.    
        end.
        **/             
    end method.      
    
    method public void UpdateTenantDefault(pckey as char,pfield as char, poldvalue as char,pValue as char):  
        case pfield:
            when "DefaultAllocation" then
                NewTenantDefaultAllocation(pckey,poldvalue,pValue).  
            when "DefaultDataAreaName" then
                NewTenantDefaultArea(pckey,"Data",poldvalue,pValue).  
            when "DefaultIndexAreaName" then
                NewTenantDefaultArea(pckey,"Index",poldvalue,pValue).  
            when "DefaultLobAreaName" then
                NewTenantDefaultArea(pckey,"Lob",poldvalue,pValue).  
        end case.  
    end method.
    
    method public void UpdateGroupDefault(pckey as char,pfield as char, poldvalue as char,pValue as char):  
        case pfield:
            when "DefaultAllocation" then
                NewGroupDefaultAllocation(pckey,poldvalue,pValue).  
            when "DefaultDataAreaName" then
                NewGroupDefaultArea(pckey,"Data",poldvalue,pValue).  
            when "DefaultIndexAreaName" then
                NewGroupDefaultArea(pckey,"Index",poldvalue,pValue).  
            when "DefaultLobAreaName" then
                NewGroupDefaultArea(pckey,"Lob",poldvalue,pValue).  
        end case.  
    end method.
    
    
	method public override void CreateRow(entity as IDataAdminElement):
	    undo, throw new UnsupportedOperationError("CreateRow in PartitionContext").
	end method.
    /*
    method public override void Copy(cntxt as IDataAdminContext):
        undo, throw new UnsupportedOperationError("Copy to PartitionContext").
    end method.    
    */
    
    method public override void CopyTable(cntxt as IDataAdminContext):
        define variable hTbl as handle no-undo.
        hTbl = cntxt:TableHandle.
        
        CopyTable(table-handle hTbl by-reference).
        
        Loaded = false.      
    end method.    
    
    method public logical FindGroupTable(pcGroup as char,pctable as char):
        return FindGroup(pcGroup,pctable,"","","").                      
    end method.    
    
    method public logical FindGroupIndex(pcGroup as char,pctable as char,pcIndex as char,pccollation as char):
        return FindGroup(pcGroup,pctable,"",pcIndex,pccollation).                      
    end method.    
    
    method public logical FindGroupField(pcGroup as char,pctable as char,pcfield as char):
        return FindGroup(pcGroup,pctable,pcfield,"","").                      
    end method.    
    
    method public logical FindTenantTable(pcTenant as char,pctable as char):
        return FindTenant(pcTenant,pcTable,"","","").                      
    end method.    
    
    method public logical FindTenantIndex(pcTenant as char,pctable as char,pcIndex as char,pccollation as char):
        return FindTenant(pcTenant,pctable,"",pcIndex,pccollation ).                      
    end method.    
    
    method public logical FindTenantField(pcTenant as char,pctable as char,pcfield as char):
        return FindTenant(pcTenant,pctable,pcfield,"","").                      
    end method.    
    
    method public logical FindTenant(pcTenant as char,pctable as char,pcField as char, pcIndex as char,pccollection as char):
        find ttpartition where ttPartition.TableName = pctable
                             and   ttPartition.FieldName = pcField
                             and   ttPartition.IndexName = pcIndex
                             and   ttPartition.TenantName = pcTenant
                             and   ttPartition.Collation = pccollection
                             no-error.
        return avail ttPartition.                     
    end method.    
    
    method public logical FindAreaTenant(pcArea as char, pcTenant as char,pctable as char,pcField as char, pcIndex as char,pccollection as char):
        find ttpartition where ttPartition.TableName = pctable
                             and   ttPartition.FieldName = pcField
                             and   ttPartition.IndexName = pcIndex
                             and   ttPartition.TenantName = pcTenant
                             and   ttPartition.Collation = pccollection
                             and   ttPartition.AreaName = pcArea 
                             no-error.
        return avail ttPartition.                     
    end method.    
    
    method public logical FindGroup(pcGroup as char,pctable as char,pcField as char, pcIndex as char,pccollation as char):
        find ttpartition where ttPartition.TableName = pctable
                             and   ttPartition.FieldName = pcField
                             and   ttPartition.IndexName = pcIndex
                             and   ttPartition.TenantGroupName = pcGroup
                             and   ttPartition.Collation = pccollation
                             no-error.
        return avail ttPartition.                     
    end method.    
   
    method public logical FindAreaGroup(pcarea as char,pcGroup as char,pctable as char,pcField as char, pcIndex as char,pccollation as char):
        find ttpartition where ttPartition.TableName = pctable
                             and   ttPartition.FieldName = pcField
                             and   ttPartition.IndexName = pcIndex
                             and   ttPartition.TenantGroupName = pcGroup
                             and   ttPartition.Collation = pccollation
                             and   ttPartition.AreaName = pcArea 
                             no-error.
        return avail ttPartition.                     
    end method.    
    
    method public logical CanFindTenant(pcTenant as char,pctable as char,pcField as char, pcIndex as char, pccollection as char):
        return can-find (ttpartition where ttPartition.TableName = pctable
                                     and   ttPartition.FieldName = pcField
                                     and   ttPartition.IndexName = pcIndex
                                     and   ttPartition.TenantName = pcTenant
                                     and   ttPartition.Collation = pccollection).
    end method.    
   
    method public logical CanFindAreaTenant(pcArea as char, pcTenant as char,pctable as char,pcField as char, pcIndex as char, pccollection as char):
        return can-find (ttpartition where ttPartition.TableName = pctable
                                     and   ttPartition.FieldName = pcField
                                     and   ttPartition.IndexName = pcIndex
                                     and   ttPartition.TenantName = pcTenant
                                     and   ttPartition.AreaName = pcArea 
                                     and   ttPartition.Collation = pccollection).
    end method.    
    
    method public logical CanFindGroup(pcGroup as char,pctable as char,pcField as char, pcIndex as char, pccollation as char):
        return can-find (ttpartition where ttPartition.TableName = pctable
                                     and   ttPartition.FieldName = pcField
                                     and   ttPartition.IndexName = pcIndex
                                     and   ttPartition.TenantGroupName = pcGroup
                                     and   ttPartition.Collation = pccollation).
    end method.    
   
    method public logical CanFindAreaGroup(pcArea as char,pcGroup as char,pctable as char,pcField as char, pcIndex as char, pccollation as char):
        return can-find (ttpartition where ttPartition.TableName = pctable
                                     and   ttPartition.FieldName = pcField
                                     and   ttPartition.IndexName = pcIndex
                                     and   ttPartition.TenantGroupName = pcGroup
                                     and   ttPartition.AreaName = pcArea 
                                     and   ttPartition.Collation = pccollation).
    end method.    
   
    method private void CopyTable(input table copytable):
        define variable dataerror as DataContextError no-undo.      
        define variable inst   as IDataAdminElement no-undo.
        temp-table ttPartition:tracking-changes = true.
       
        for each copytable:   
            find ttpartition where ttPartition.TableName = copytable.TableName
                             and   ttPartition.FieldName = copytable.FieldName
                             and   ttPartition.IndexName = copytable.IndexName
                             and   ttPartition.TenantName = copytable.TenantName
                             and   ttPartition.TenantGroupName = copytable.TenantGroupName
                             and   ttPartition.Collation = copytable.Collation
                             no-error.
            if not avail ttPartition then
            do:
                create ttPartition. 
                Count = Count + 1.
            end.
            buffer-copy copytable except trowid to ttpartition.
            OnRowCreated().
        end.
        temp-table ttPartition:tracking-changes = false.
            
    end method.   
    
    /** AllocateTableTenants does allocate all tenant partitions for a table and its indexes and fields  */
    method public logical AllocateTableTenants(pcTable as char,pcMode as char):
         
        define variable lTrack as logical no-undo.
        define variable lok as logical no-undo.
        
        ValidateAllocationRequest(pcMode).
        ValidateAllocationKey(pcTable,"Table").    
        lTrack =  temp-table ttPartition:tracking-changes .
        temp-table ttPartition:tracking-changes = true.
       
        for each ttpartition where ttPartition.TableName = pctable
                             and   ttPartition.TenantName > ""
                             and   ttPartition.AllocationState <> "Allocated" 
                             and   (pcMode = "all" or ttPartition.AllocationState = pcMode): 
             ttPartition.AllocationState = "Allocated".
             lok = true. 
          
        end.
     
        temp-table ttPartition:tracking-changes = lTrack.
        return lok.       
    end method.    
   
   /** AllocateTableGroups does allocate all group partitions for a table and its indexes and fields 
       (a group currently applies to only one table, but a table can in be in many groups) */
    method public logical AllocateTableGroups(pcTable as char,pcMode as char):
        define variable lTrack as logical no-undo.
        define variable lok as logical no-undo.
        
        ValidateAllocationRequest(pcMode).
        ValidateAllocationKey(pcTable,"Table").    
        lTrack =  temp-table ttPartition:tracking-changes .
        temp-table ttPartition:tracking-changes = true.
        define variable i as integer no-undo.
        for each ttpartition where ttPartition.TableName = pctable
                             and   ttPartition.TenantGroupName > ""
                             and   ttPartition.AllocationState <> "Allocated" 
                             and   (pcMode = "all" or ttPartition.AllocationState = pcMode): 
             ttPartition.AllocationState = "Allocated".
             lok = true. 
        end.
        temp-table ttPartition:tracking-changes = lTrack.
        return lok.       
    end method.    
   
    /* UPDATES FIELDS AND INDEXES, not the table */
    method private void UpdateTenantTableChildPartitions(pcTenant as char,pcTable as char,pcValue as char):
        define variable lTrack as logical no-undo.
        define buffer bttPartition for ttPartition.  
        lTrack =  temp-table ttPartition:tracking-changes .
        temp-table ttPartition:tracking-changes = true.
        
        for each bttPartition where bttPartition.TableName = pctable
                             and   bttPartition.ObjectType <> "Table"  
                             and   bttPartition.TenantName = pcTenant:
            bttPartition.AllocationState = pcValue. 
        end.
        temp-table ttPartition:tracking-changes = lTrack.
    end method.    
    
    /* UPDATES FIELDS AND INDEXES, not the table */
    method private void UpdateGroupTableChildPartitions(pcTenantGroup as char,pcTable as char,pcValue as char):
        define variable lTrack as logical no-undo.
        define buffer bttPartition for ttPartition.  
         
        lTrack =  temp-table ttPartition:tracking-changes .
        temp-table ttPartition:tracking-changes = true.
        
        for each bttPartition where bttPartition.TableName = pctable
                             and   bttPartition.ObjectType <> "Table"  
                             and   bttPartition.TenantGroupName = pcTenantGroup:
            bttPartition.AllocationState = pcValue. 
        end.
        temp-table ttPartition:tracking-changes = lTrack.
    end method.    
    
   
   
    /** Allocates a table partition including index and lob partitions 
        @param Tenant Tenant name  
        @param Table Table name
        @return true if any partion was allocated */     
    method public logical AllocateTenantTablePartition(pcTenant as char,pcTable as char):
        define variable lTrack as logical no-undo.
        define variable lok as logical no-undo.
        
        ValidateAllocationKey(pcTenant,"Tenant").    
        ValidateAllocationKey(pcTable,"Table").    
          
        lTrack =  temp-table ttPartition:tracking-changes .
        temp-table ttPartition:tracking-changes = true.
        
        for each ttpartition where ttPartition.TableName = pctable
                             and   ttPartition.TenantName = pcTenant
                             and   ttPartition.AllocationState <> "Allocated": 
              ttPartition.AllocationState = "Allocated". 
              lok = true.
        end.
        temp-table ttPartition:tracking-changes = lTrack.
        return lok.       
    end method.    
    
    /******
    method public logical DeallocateTenantTablePartition(pcTenant as char,pcTable as char):
        define variable lTrack as logical no-undo.
        define variable lok as logical no-undo.
        lTrack =  temp-table ttPartition:tracking-changes .
        temp-table ttPartition:tracking-changes = true.
        
        /* we do not want to touch any records of only index or lob records 
           should happen to be allocated (currently possible) */
        if can-find(ttpartition where ttPartition.TableName = pctable
                                and   ttPartition.TenantName = pcTenant
                                and   ttPartition.ObjectType  = "table"
                                and   ttPartition.AllocationState = "Allocated") then
        for each ttpartition where ttPartition.TableName = pctable
                             and   ttPartition.TenantName = pcTenant
                             and   ttPartition.AllocationState = "Allocated": 
              ttPartition.AllocationState = "None". 
              lok = true. 
        end.
        temp-table ttPartition:tracking-changes = lTrack.
        return lok.       
    end method.    
    ***************/
    
    
    method public void NewGroupDefaultArea (pcGroup as char,pcType as char,pcOldValue as char,pcNewvalue as char):
        define variable lTrack as logical no-undo.
        lTrack = temp-table ttPartition:tracking-changes .
        temp-table ttPartition:tracking-changes = false.
        
        for each ttpartition where ttPartition.TenantGroupName = pcGroup
                             and   ttPartition.ObjectType = pcType 
                             and   ttPartition.AreaName = pcOldValue: 
            ttPartition.AreaName = pcNewValue. 
        end.
        temp-table ttPartition:tracking-changes = lTrack.   
    end method.    
    
    method public void NewTenantDefaultArea (pcTenant as char,pcType as char,pcOldValue as char,pcNewvalue as char):
        define variable lTrack as logical no-undo.
        lTrack = temp-table ttPartition:tracking-changes .
        temp-table ttPartition:tracking-changes = false.
        
        for each ttpartition where ttPartition.TenantName = pcTenant
                             and   ttPartition.ObjectType = pcType
                             and   ttPartition.AreaName = pcOldValue: 
            ttPartition.AreaName = pcNewValue. 
        end.
        temp-table ttPartition:tracking-changes = lTrack.   
    end method.    
      
    method public void NewGroupDefaultAllocation (pcGroup as char,pcOldValue as char,pcNewvalue as char):
        define variable lTrack as logical no-undo.
        lTrack = temp-table ttPartition:tracking-changes .
        temp-table ttPartition:tracking-changes = false.
        
        for each ttpartition where ttPartition.TenantGroupName = pcGroup
                             and   ttPartition.AllocationState = pcOldValue: 
            ttPartition.AllocationState = pcNewValue. 
        end.
        temp-table ttPartition:tracking-changes = lTrack.   
    end method.    
    
    method public void NewTenantDefaultAllocation (pcTenant as char,pcOldValue as char,pcNewvalue as char):
        define variable lTrack as logical no-undo.
        lTrack = temp-table ttPartition:tracking-changes .
        temp-table ttPartition:tracking-changes = false.
        if pcOldValue = "Immediate" then 
             pcOldValue = "Allocated".
        if pcNewValue = "Immediate" then 
             pcNewValue = "Allocated".
        for each ttpartition where ttPartition.TenantName = pcTenant
                             and   ttPartition.AllocationState = pcOldValue: 
                                 
            ttPartition.AllocationState = pcNewValue. 
        end.
        temp-table ttPartition:tracking-changes = lTrack.   
    end method.    
       
    method public logical AllocateGroup (pcGroup as char,pcMode as char):
        define variable lTrack as logical no-undo.
        define variable lok as logical no-undo.
        
        ValidateAllocationRequest(pcMode).
        ValidateAllocationKey(pcGroup,"TenantGroup").    
       
        lTrack = temp-table ttPartition:tracking-changes .
        temp-table ttPartition:tracking-changes = true.
        
        for each ttpartition where ttPartition.TenantGroupName = pcGroup
                             and   ttPartition.AllocationState <> "Allocated" 
                             and   (pcMode = "all" or ttPartition.AllocationState = pcMode): 
            ttPartition.AllocationState = "Allocated". 
            lok = true.
        end.
        temp-table ttPartition:tracking-changes = lTrack.
        return lok.       
    end method.    
    
    /*  Allocate does not make sense for all partitions 
        (We currently implement IPartitionContext which really is for query objects.) */
    method public logical Allocate():
        undo, throw new UnsupportedOperationError("Allocate() in PartitionContext").
    end method.
     
     /**** deallocate is sdupported through utility 
      
    /*  Deallocate does not make sense for all partitions 
        (We currently implement IPartitionContext which really is for query objects.) */
    method public logical Deallocate():
        undo, throw new UnsupportedOperationError("Deallocate() in PartitionContext").
    end method.
 
    method public logical DeallocateGroupPartition(pcGroup as char):
        define variable lTrack as logical no-undo.
        define variable lok as logical no-undo.
        lTrack =  temp-table ttPartition:tracking-changes .
        temp-table ttPartition:tracking-changes = true.
         /* we do not want to touch any records of only index or lob records 
            should happen to be allocated (currently possible) */
        if can-find(ttpartition where ttPartition.TenantGroupName = pcGroup
                                and   ttPartition.ObjectType  = "table"
                                and   ttPartition.AllocationState = "Allocated") then
       
        for each ttpartition where ttPartition.TenantGroupName = pcGroup
                             and   ttPartition.AllocationState = "Allocated": 
              ttPartition.AllocationState = "None". 
              lok = true.
        end.
        temp-table ttPartition:tracking-changes = lTrack.
        return lok.       
    end method.    
  
    ******/
    
/*    method public IDataAdminCollection GetSchemaCollection(pchild as char):*/
/*        define variable cntxt as IDataAdminContext no-undo.                */
/*        cntxt = GetChild(pchild).                                          */
/*    end method.                                                            */
    
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):
        return new PartitionCollection(this-object).
    end method.
    
    method override protected FilteredContext CreateFilteredContext(pparent as char,pkey as char extent,pReq as IRequestInfo):     
        define variable cTable as character no-undo.
        ctable = pkey[1].
        
        case pparent:
            when "indexes" then
            do:              
                return new IndexPartitionQuery(this-object,cTable,pkey[2],"",pReq).
            end.
            when "fields"  or when "lobfields" then
            do:              
                return new FieldPartitionQuery(this-object,cTable,pkey[2],pReq).
            end.
            otherwise
                return super:CreateFilteredContext(pparent,pkey,pReq).                      
        end case.
             
    end method.
    
    method override protected FilteredContext CreateFilteredContext(pParent as IRow,pReq as IRequestInfo):     
        case pParent:SerializeName:  
            when "tenants" then
            do:
                return new TenantPartitionQuery(this-object,pParent,pReq).
            end.
            when "tenantGroups" then
            do:              
                return new TenantGroupPartitionQuery(this-object,pParent,pReq).
            end.              
        end.  
        super:CreateFilteredContext(pParent,pReq).
    end method. 
    
    method override protected FilteredContext CreateFilteredContext(pparent as char,pkey as char,pReq as IRequestInfo):     
         define variable parentcntxt as IDataAdminContext no-undo.
         case pparent:
/*             when "tenantGroups" then                                        */
/*             do:                                                             */
/*                 return new TenantGroupPartitionQuery(this-object,pkey,pReq).*/
/*             end.                                                            */
/*             when "tenants" then                                                */
/*             do:                                                                */
/*/*                 parentcntxt = ContextScope:GetContext("Tenant").           */*/
/*/*                 parentcntxt:Find(pkey).                                    */*/
/*/*                 tnt = cast(Factory:TenantContext:FindEntity(pkey),ITenant).*/*/
/*                 return new TenantPartitionQuery(this-object,pkey,pReq).        */
/*             end.                                                               */
             when "tables" then
             do:              
                 return new TablePartitionQuery(this-object,pkey,pReq).
             end.
             otherwise
                 return super:CreateFilteredContext(pparent,pkey,pReq).              
         end.        
    end method.
    
    method override protected IDataAdminCollection CreateCollection(pparent as char,pcntxt as FilteredContext):     
        case pparent:
            when "tenantGroups" then
            do:          
                return new PartitionMap(cast(pcntxt,IPartitionQuery)).
            end.   
            when "tenants" then
            do:          
                return new TenantPartitionMap(cast(pcntxt,IPartitionQuery)).
            end.   
            when "tables" or when "fields" or when "lobfields" or when "indexes" then
                return new SchemaPartitionMap(cast(pcntxt,SchemaPartitionQuery)).
            otherwise 
                return super:CreateCollection(pparent,pcntxt).             
        end.        
    end method.
    
    method override protected FilteredContext CreateFilteredContext(pfilter as char):     
        return new PartitionFilteredContext(this-object,pfilter).
    end method.
    
    /** create default filteredcontext with requestinfo  */
    method override protected FilteredContext CreateFilteredContext(pReq as IRequestInfo):
        return new PartitionFilteredContext(this-object,pReq).
    end method.
    
    method protected override IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
        return new Partition(cntxt).
    end method. 
        
    method protected override char FindExpression(i as int):
        undo, throw new UnsupportedOperationError("FindExpression with integer in PartitionContext").
    end method.
  
    method protected override char FindExpression(c as char):
        undo, throw new UnsupportedOperationError("FindExpression with character in PartitionContext").
    end method.

    method public override void DataRefreshed(pResponse as IFetchResponse):
/*        ShowPartitionData().*/
        define variable TblResponse as OpenEdge.DataAdmin.Message.ITableResponse no-undo.
        define variable hNewBuffer as handle no-undo.
        define variable LAFTER as logical no-undo.
        define variable hTable as handle no-undo.
        
        TblResponse = pResponse:GetTableResponse(TableHandle:name).
        if valid-object(TblResponse) 
        and TblResponse:RequestType = "NEW" then
        do:
            /* use copy to set row-state to row-created - needed to be updated 
               after parent on server  */
            hNewBuffer = pResponse:DataHandle:get-buffer-handle(TableHandle:name).
            hTable = hNewBuffer:table-handle.
            CopyTable(input table-handle hTable by-reference).
        end.
        else do: 
            if mRefresh or pResponse:Entityname <> "partition"  then
            do: 
                super:DataRefreshed(pResponse).
            end.
            else do:         
                tblResponse = pResponse:GetTableResponse("ttArea").
                if valid-object(tblResponse) then   
                do:
                    ContextFactory:AreaContext:DataRefreshed(pResponse) .
                end.
                
                tblResponse = pResponse:GetTableResponse("ttTenant").
                if valid-object(tblResponse) then   
                do:
                    mRefresh = true.          
                    ContextFactory:TenantContext:DataRefreshed(pResponse) .
                    mRefresh = false.
                end.
                else do:
                    tblResponse = pResponse:GetTableResponse("ttTenantGroup").
                    if valid-object(tblResponse) then  
                    do: 
                        mRefresh = true. 
                        ContextFactory:TenantGroupContext:DataRefreshed(pResponse) .
                        mRefresh = false.
                    end.
                    else 
                        super:DataRefreshed(pResponse).
                end.
            end.       
        end.
    end method.
/*                                                                           */
/*    method protected void ShowPartitionData():                             */
/*        current-window:width = 200.                                        */
/*        for each ttPartition with width 200:                               */
/*                                                                           */
/*            display                                                        */
/*              buffer  ttPartition:row-state                                */
/*               ttpartition.TableName                                       */
/*               ttpartition.FieldName                                       */
/*               ttpartition.IndexName                                       */
/*               ttpartition.TenantName                                      */
/*               ttpartition.TenantGroupName                                 */
/*               ttpartition.ObjectType                                      */
/*               ttpartition.AreaName                                        */
/*               ttPartition.AllocationState.                                */
/*        end.                                                               */
/*               */
/*    end method.*/

end class.
