/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     : Query for partitions of a single Tenant 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Mon Apr 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAdminService from propath. 
using OpenEdge.DataAdmin.IRequestInfo  from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.PartitionContext from propath.
using OpenEdge.DataAdmin.Binding.IPartitionContext from propath.
using OpenEdge.DataAdmin.Binding.IRow from propath.
 
using OpenEdge.DataAdmin.Binding.ContextTree from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.Query.IPartitionQuery from propath.
using OpenEdge.DataAdmin.Binding.Query.PartitionQuery from propath.

using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Message.FetchRequest from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.Query.TenantPartitionQuery inherits PartitionQuery implements IPartitionQuery,IPartitionContext: 
	/*------------------------------------------------------------------------------
			Purpose: Used for a collection of partitions of a tenant
			 		 indexed/mapped by tenant															  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	/** Parent context (Model) may change so don't store this */   
    define private property PartitionContext as PartitionContext no-undo
        get():
            return cast(Parent,PartitionContext).   
        end.
	
    define private variable mNew as logical no-undo.
    define protected property DefaultAllocation as char get. set.
    define protected property DefaultDataArea as char get. set.
    define protected property DefaultIndexArea as char get. set.
    define protected property DefaultLobArea as char get. set.
    
    constructor public TenantPartitionQuery (pModel as PartitionContext, pParent as IRow,pReq as IRequestInfo):
        super (pModel,pParent,pReq).     
        if pparent:Created then
        do:
            assign
                DefaultAllocation = pParent:FieldValue("DefaultAllocation")
                DefaultDataArea   = pParent:FieldValue("DefaultDataAreaName") 
                DefaultIndexArea  = pParent:FieldValue("DefaultIndexAreaName") 
                DefaultLobArea    = pParent:FieldValue("DefaultLobAreaName"). 
            mNew = true.
        end.
    end constructor.
    
    method public override logical CanFind(pname as character):
        undo, throw new UnsupportedOperationError("TenantPartitionQuery CanFind with single key").
    end.    
     
    method public override logical Find(pname as character):
        undo, throw new UnsupportedOperationError("TenantPartitionQuery Find with single key").
    end.    
    
    method public override void ExportLastSaved(pcfile as char). 
        define variable hBuffer as handle no-undo.
        if valid-handle(LastSavedDataset) then
        do:
            hbuffer = LastSavedDataset:get-buffer-handle(TableHandle:Name) . 
            /*
            hbuffer:buffer-field ("SchemaName"):serialize-hidden = true.
            hbuffer:buffer-field ("SequenceName"):serialize-hidden = true.
            hbuffer:buffer-field ("Url"):serialize-hidden = true.         
             */
            if valid-handle(hBuffer) then 
                hBuffer:write-json ("File",pcFile,yes).    
        end.
    end method.  
    
     method public logical FindTable(pctable as char):
        return this-object:Find(pctable,"","",""). 
    end method.
    
    method public logical FindField(pctable as char, pcfield as char):
        return this-object:Find(pctable,pcfield,"",""). 
    end method.
     
    method public logical FindIndex(pctable as char, pcIndex as char,pcCollection as char):
        return this-object:Find(pctable,"",pcIndex,pcCollection). 
    end method.
    
    method protected logical Find(pctable as char,pcField as char, pcIndex as char,pccollection as char):
        if cast(parent,PartitionContext):FindTenant(ParentValue,pctable,pcField,pcIndex,pcCollection) then
        do:
            TableHandle:default-buffer-handle:rowid.
            
            return true.  
/*            FindInQuery(TableHandle:default-buffer-handle:rowid).*/
        end.
        else return false.    
    end method.
    
    method public logical CanFindTable(pctable as char):
        return this-object:CanFind(pctable,"","",""). 
    end method.
    
    method public logical CanFindField(pctable as char,pcfield as char):
        return this-object:CanFind(pctable,pcfield,"",""). 
    end method.
    
    method public logical CanFindIndex(pctable as char, pcIndex as char,pccollection as char):
        return this-object:CanFind(pctable,"",pcIndex,pcCollection). 
    end method.
    
    method protected logical CanFind(pctable as char,pcField as char, pcIndex as char, pccollection as char):
        return PartitionContext:CanFindTenant(ParentValue,pctable,pcField,pcIndex,pcCollection).
    end method.
    
    method public logical CanFindTenant(pcTenant as char,pctable as char,pcField as char, pcIndex as char, pccollection as char):
        if ParentValue = pcTenant then 
            return cast(parent,PartitionContext):CanFindTenant(ParentValue,pctable,pcField,pcIndex,pcCollection).
        else
            return false.
    end method.
    
    method public logical CanFindGroup(pcGroup as char,pctable as char,pcField as char, pcIndex as char, pccollection as char):
        return false.  
    end method.
    
    method public logical FindTenant(pcTenant as char,pctable as char,pcField as char, pcIndex as char, pccollection as char):
        if ParentValue = pcTenant then 
            return cast(parent,PartitionContext):FindTenant(ParentValue,pctable,pcField,pcIndex,pcCollection).
        else
            return false.
    end method.
    
    method public logical FindGroup(pcGroup as char,pctable as char,pcField as char, pcIndex as char, pccollection as char):
        return false.  
    end method.
    
    method public logical AllocateTable(pcTable as char):        
        return PartitionContext:AllocateTenantTablePartition(ParentValue,pcTable).  
    end method.     
    
    /****************
    method public logical DeallocateTable(pcTable as char):        
        return PartitionContext:DeallocateTenantTablePartition(ParentValue,pcTable).  
    end method.  
    ***/
    
    /**  Query partitions for new tenant
         this is a hack - the fields are not used to query, but to assign default 
         data on fill  */
    method private char GetNewQuery():   
        return "for each ttpartition where ttTenant.DefaultAllocation = "  + quoter(DefaultAllocation)
                                  + "  and ttTenant.DefaultDataArea = "  + quoter(DefaultDataArea)
                                  + "  and ttTenant.DefaultIndexArea = "  + quoter(DefaultIndexArea)
                                  + "  and ttTenant.DefaultLobArea = "   + quoter(DefaultLobArea) .
    end method.
    
    method public override IFetchRequest GetQueryRequest():   
        if mNew then 
            return GetNewRequest().
        else 
            return super:GetQueryRequest().   
    end method.
    
    method public IFetchRequest GetNewRequest():   
        define variable msg as IFetchRequest no-undo.
        define variable cWhere as character no-undo.
        msg = new FetchRequest(Name,Id,DatasetHandle).
        msg:SetTableRequestType("ttPartition","NEW").
        msg:SetTableQuery("ttPartition",GetNewQuery()).
        return msg.
    end method.
   
    method public logical Allocate():        
        define variable rid as rowid no-undo.
        define variable lTrack as logical no-undo.
        define variable lok as logical no-undo.
        define variable hBuf as handle no-undo.
        lTrack = TableHandle:tracking-changes.
        TableHandle:tracking-changes = true. 
        hBuf = QueryHandle:get-buffer-handle (this-object:Table).
        rid = hBuf:rowid.
        QueryHandle:get-first ().
        do while hBuf:avail: 
            if hBuf::AllocationState = "Delayed" then
            do:
                hBuf::AllocationState = "Allocated".
                lok = true.
            end. 
            QueryHandle:get-next ().
        end.
        return lok.
        finally:
            TableHandle:tracking-changes = lTrack.          
            if rid <> ? then
                QueryHandle:reposition-to-rowid(rid). 
        end finally.       
       
    end method.     
    
    /**** 
    method public logical Deallocate(): 
        define variable rid as rowid no-undo.
        define variable lTrack as logical no-undo.
        define variable lok as logical no-undo.
        define variable hBuf as handle no-undo.
        hBuf = QueryHandle:get-buffer-handle (this-object:Table).
        
        lTrack = TableHandle:tracking-changes.
        TableHandle:tracking-changes = true. 
        rid = hBuf:rowid.
        QueryHandle:get-first ().
        do while hBuf:avail: 
            if hBuf::AllocationState = "Allocated"  
            and hBuf::ObjectType = "Table" then
            do:
                hBuf::AllocationState = "None".
                lok =  true. 
            end. 
            QueryHandle:get-next ().
        end.
        return lok.
        finally:
            TableHandle:tracking-changes = lTrack.          
            if rid <> ? then
                QueryHandle:reposition-to-rowid(rid). 
        end finally.       
              
    end method. 
    ****************************/
    
    
    
end class.