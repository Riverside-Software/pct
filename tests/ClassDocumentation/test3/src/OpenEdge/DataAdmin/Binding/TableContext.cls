 /*************************************************************/
 /* Copyright (c) 2010 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : TableContext
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :   2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.TableImpl from propath.
using OpenEdge.DataAdmin.TableSet from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.
using OpenEdge.DataAdmin.Binding.DataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IContextWriter from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.ContextTree from propath.
using OpenEdge.DataAdmin.Binding.PartitionContext from propath.
using OpenEdge.DataAdmin.Binding.IndexContext from propath.
using OpenEdge.DataAdmin.Binding.FieldContext from propath.
using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath.
using OpenEdge.DataAdmin.Binding.Factory.ISchemaScope from propath. 

using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.FetchRequest from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Message.SaveRequest from propath.

using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

class OpenEdge.DataAdmin.Binding.TableContext inherits DataAdminContext implements IDataAdminContext: 
    
    {daschema/table.i}
     
    define private dataset dsTable serialize-name "root" for ttTable.
    define buffer btable for ttTable.
    define temp-table copytable reference-only like ttTable .  
    
    define variable mpartitions     as PartitionContext no-undo.
    define variable mpartitionCache as PartitionContext no-undo. 
    define variable mLastSavedTable as handle no-undo.
    
    define temp-table ttTablePartitionRequest no-undo
        field tablename as char
        index partname as  unique tablename .
      
    define public override property DatasetHandle as handle no-undo 
        get():
            if not valid-handle(DatasetHandle) then 
                DatasetHandle  = CreateDataSet().
            return DatasetHandle.
        end get.
        private set.
    
	define public override property TableHandle as handle no-undo 
    	get():
    		return temp-table ttTable:handle.
    	end get.
    
    define public override property KeyFields as character  no-undo  
        get():
            return "Name". 
        end.   
    
    define public override property Count as integer init ? no-undo  
        get(): 
            define buffer bTable for ttTable.
            if Count = ? then
            do:
                Count = 0.
                for each bTable:
                    Count = Count + 1.
                end. 
            end.    
            return Count.
        end.
        protected set.
    
    constructor public TableContext ():
        super ("Table").
    end constructor.
        
    constructor protected TableContext (pname as char):
        super (pname).
    end constructor.
   
    constructor protected TableContext (pname as char,pScope as ISchemaScope):
        super (pname,pScope).
/*      idx:lazy = false.*/
/*      fld:lazy = false.*/
        mPartitions = pScope:PartitionContext.
        AddChild(pScope:IndexContext).
        AddChild(pScope:FieldContext).
   end constructor.
        
	constructor public TableContext ( pScope as ISchemaScope):
        this-object("Table",pScope).
    end constructor.
	
	method public override void CopyTable(cntxt as IDataAdminContext).
        undo, throw new UnsupportedOperationError("Copy Schema").
    end method. 
     
    method public override void CreateRow(entity as IDataAdminElement):
        undo, throw new UnsupportedOperationError("Create Schema row").
    end method. 
	
    method public override character GetJoinFields(parentid as char):
        case parentid:
            when "schemas" then 
                return "Name,SchemaName".
        end.
    end.
    
    method public override IDataAdminContext GetChild(child as char):
        if child = "partitions" then 
             return mpartitions.         
        return super:GetChild(child).
    end method.
    
    method public logical NeedPartitionRefresh():
        return can-find(first ttTablePartitionRequest).        
    end method.     
    
    /* Called from merge with the changes returned from server to keep track of 
       which partitions that will need to be refreshed. */        
    method private logical CreatePartitionRefreshIds (pdsChanged as handle):
        define variable hQuery     as handle no-undo.
        define variable hBuffer    as handle no-undo.
        define variable hBefore    as handle no-undo.
        define variable lok        as logical no-undo.
        define variable lRefresh   as logical no-undo.
        define variable hPartition as handle no-undo.
        
        hbuffer = pdsChanged:get-buffer-handle ("ttTable"). 
        if not valid-handle(hBuffer) then
            return false.
        create query hQuery.
        
        hquery:add-buffer (hbuffer).
        hQuery:query-prepare ("for each ttTable").
        hquery:query-open().
        hquery:get-first.
        do while hbuffer:avail:
            if hbuffer:row-state = row-created then
                lRefresh = true.
            else if hbuffer:row-state = row-modified then
            do:     
                hBefore = hbuffer:before-buffer.
                hbefore:find-by-rowid(hBuffer:before-rowid). 
                if hBuffer::isMultitenant and hBefore::isMultitenant = false then 
                   lRefresh = true.  
            end.            
            if lRefresh then 
            do:
                create ttTablePartitionRequest.
                ttTablePartitionRequest.Tablename = hBuffer::name.
            end.
            hQuery:get-next.
            lok = true.
        end.
    end method.
    
    method public logical HasPartitionChanges():
        define variable hBuffer as handle no-undo.
        hbuffer = mpartitions:Tablehandle:default-buffer-handle. 
        return hBuffer:before-buffer:table-handle:has-records. 
    end method.     
    
    method private void DeletePartitionsBeforeRequest ():
        define variable hQuery     as handle no-undo.
        define variable hBuffer    as handle no-undo.
        create query hQuery.
        
         /* now workaround the fact that fill cannot replace (even if it should? ) */
        hbuffer = mPartitions:Tablehandle:default-buffer-handle. 
        hquery:set-buffers (buffer  ttTablePartitionRequest:handle).
        hquery:add-buffer (hbuffer).
        hQuery:query-prepare ("for each ttTablePartitionRequest, each ttPartition of ttTablePartitionRequest").
        hquery:query-open().
        hquery:get-first.
        
/*        hBuffer:table-handle:tracking-changes = false.*/
        do while hbuffer:avail:
            hBuffer:buffer-delete ().
            hQuery:get-next.
        end.    
/*        hBuffer:table-handle:tracking-changes = true.*/
        delete object hQuery.
      
    end method.    
    
    method private IFetchRequest CreatePartitionRefreshRequest ():
        define variable tree as IContextTree no-undo.
        define variable msg  as IFetchRequest no-undo.
        tree = new ContextTree().  
        tree:Parse = true.   
        tree:SetHandle("requests",buffer ttTablePartitionRequest:handle).    
        mPartitions:AddTableTo(tree).         
        msg = new FetchRequest("Partition",Id,tree:GetReadHandle()).
        return msg. 
    end method.    
    
    method private logical EmptyPartitionRefresh():
        empty temp-table ttTablePartitionRequest.        
    end method.     
    
    method protected override handle CreateSaveDataset():
        define variable tree as IContextTree no-undo.    
        tree = new ContextTree().                        
        tree:Parse = true.                               
        AddTreeTo(tree).                                
        mpartitions:AddTableTo(tree).
        return tree:GetReadHandle().                     
    end method.                                         
    
    
     /* used by UpdateTable(s) to perform a second transaction */
    method public ISaveRequest GetPartitionSaveRequest():
        define variable hchanges as handle no-undo.
        define variable savemsg as ISaveRequest no-undo.
        define variable tree as IContextTree no-undo.
        tree = new ContextTree().  
        tree:Parse = true.        
        mPartitions:AddTableTo(tree).  
        SaveDataset = tree:GetReadHandle(). 
        hchanges = GetChanges(SaveDataset).  
        savemsg = new SaveRequest(Name,Id,hchanges).
/*        mCreate = true.*/
        return savemsg.
    end method.
    
    method public override void ExportLastSavedTree( pcfile as char ):
        define variable hDs as handle no-undo.
        define variable tree as IContextTree no-undo.
        tree = new ContextTree().
        if valid-handle(mLastSavedTable) then  
            tree:SetHandle("tables",mLastSavedTable).
        tree:SetJoin("tables","partitions","Name,TableName").    
        mPartitions:AddTableTo(tree).  
        hDs = tree:GetReadHandle().
        hDs:write-json ("File",pcFile,yes).    
        
    end method.
    
    method override public void MergeChanges( pResponse as ISaveRequest ):
        define variable lok as logical no-undo.
        define variable hbuffer  as handle no-undo.
        define variable msg as IFetchRequest no-undo.
        if not NeedPartitionRefresh() then    
        do: 
            CreatePartitionRefreshIds(pResponse:DataHandle).    
        end.
        
        hbuffer = pResponse:DataHandle:get-buffer-handle ("ttTable"). 
        if valid-handle(hBuffer) then
            mLastSavedTable = hBuffer.
            
        hbuffer = pResponse:DataHandle:get-buffer-handle ("ttPartitions"). 
        if valid-handle(hBuffer) then
            EmptyPartitionRefresh().    
           
        super:MergeChanges(pResponse).
        
        if NeedPartitionRefresh() then 
        do: 
            mPartitionCache = new PartitionContext().
            mPartitionCache:CopyTable(mPartitions).
            DeletePartitionsBeforeRequest().
            msg = CreatePartitionRefreshRequest().
            msg:UseReplaceOnClient = false.
            FetchData(msg).
            mPartitions:CopyTable(mPartitionCache).
        end.    
        
    end method.
    
    /** Allocate new partitions 
        Called from service after save and before partition save if table/tableset ForceAllocation 
        Used by REST api
        @param AllocationState Specify state of partitions to allocate - All, Delayed or None */
    method public void AllocateNewPartitions (pcAllocationState as char):
        for each ttTablePartitionRequest:
            mpartitions:AllocateTableTenants(ttTablePartitionRequest.tablename,pcAllocationState).   
        end.
    end method.    
    /*
    /** Allocate  
        @param AllocationState Specify state of partitions to allocate - All, Delayed or None */
    method public void Allocate (pcAllocationState as char):
        for each ttTable:
            mpartitions:AllocateTable(ttTable.name,pcAllocationState).   
        end.
    end method.    
    */
    
    method override public void WriteTo( input writer as OpenEdge.DataAdmin.Binding.IContextWriter ):
        super:WriteTo(input writer).
    end method.
   
    method public override void AddTreeTo(tree as IContextTree,pcCollections as char):
        define variable i as integer no-undo.
        if lookup("partitions",pcCollections) > 0 then
        do:
            tree:SetJoin("tables","partitions","Name,TableName").
            mpartitions:AddTableTo(tree).
        
        end.
        super:AddTreeTo(tree,pcCollections).
    end method.    
   
	method public override logical CanFind(name as character):
        return can-find(ttTable where ttTable.name = name).            
    end.    
     
    method public override logical Find(name as character):
        find ttTable where ttTable.name = name no-error.
        return avail ttTable.            
    end.    
      
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):     
          return new TableSet(cntxt).
    end method.
    
    method protected override IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
       return new TableImpl(cntxt).
    end method.
    
    method protected override IDataAdminElement CreateEntity(pReq as IRequestInfo):
       return new TableImpl(this-object,pReq).
    end method.
    
     method public override character ColumnSource(pcColumn as char):
        define variable cField  as character no-undo.
        define variable cBuffer as character no-undo.
        
        define variable cMsg as character no-undo. 
        
        if num-entries(pcColumn,".") > 1 then
        do:
            cBuffer = entry(1,pcColumn,".").
            cField  = entry(2,pcColumn,".").
            if cBuffer = "Area" and cField = "name" then
            do:
                return "ttTable.AreaName". 
            end. 
            if cBuffer = "Schema" and cField = "name" then
            do:
                return "ttTable.SchemaName". 
            end.          
        end.
        return super:ColumnSource(pcColumn).
    end method.
     
end class.
