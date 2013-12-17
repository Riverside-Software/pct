 /*************************************************************/
 /* Copyright (c) 2010-2012 by progress Software Corporation  */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : TenantGroupContext
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.ITenantGroup from propath.
using OpenEdge.DataAdmin.TenantGroup from propath.
using OpenEdge.DataAdmin.TenantGroupSet from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.
using OpenEdge.DataAdmin.Binding.DataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath. 
using OpenEdge.DataAdmin.Binding.IContextTree from propath. 
using OpenEdge.DataAdmin.Binding.ContextTree from propath. 
using OpenEdge.DataAdmin.Binding.PartitionContext from propath. 
using OpenEdge.DataAdmin.Binding.NewPartitionContext from propath. 
using OpenEdge.DataAdmin.Binding.TenantContext from propath. 
using OpenEdge.DataAdmin.Binding.TenantGroupMemberContext from propath. 
using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath.
using OpenEdge.DataAdmin.Binding.DummyContext from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath. 
using OpenEdge.DataAdmin.Binding.Query.TenantTenantGroupQuery from propath. 
using OpenEdge.DataAdmin.Binding.Factory.IMultiTenantScope from propath. 

using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.DataContextError from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Error.InvalidPropertyValueError from propath.
using OpenEdge.DataAdmin.Error.ReadOnlyPropertyError from propath.

using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Message.SaveRequest from propath.
using OpenEdge.DataAdmin.Message.IFetchResponse from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.FetchRequest from propath.
using OpenEdge.DataAdmin.Support.TenantTenantGroupSet from propath.

class OpenEdge.DataAdmin.Binding.TenantGroupContext inherits DataAdminContext implements IDataAdminContext: 
    
    {daschema/tenantgroup.i} 
    define private dataset dsTenant serialize-name "root" for ttTenantGroup.
    define buffer bTenantGroup for ttTenantGroup.
    define temp-table copytable reference-only like ttTenantGroup.
      
    define private temp-table ttGroupNameRequest no-undo
        field id as int
        field objecttype as int
        field objectnumber as int
        field name as char
        index partname as  unique name
        index partidx as primary unique objecttype objectnumber id.
        
    define variable mCreate as logical no-undo.
    define variable mPartitionAfterQuery as handle no-undo.
  
    define private variable ValidTypeList as char init "Regular,Super" no-undo.
    define private variable ValidTypeString as char init "~"Regular~" or ~"Super~"" no-undo.
    define private variable ValidDefaultAllocationList as char init "Immediate,Delayed,None" no-undo.
    define private variable ValidDefaultAllocationString as char init "~"Immediate~", ~"Delayed~" and ~"None~"" no-undo.
    
      
    define public override property DatasetHandle as handle no-undo 
        get():
            if not valid-handle(DatasetHandle) then 
                DatasetHandle  = dataset dsTenant:handle.
            return DatasetHandle.
        end get.
        private set.
        
	define public override property TableHandle as handle no-undo 
    	get():
    		return temp-table ttTenantGroup:handle.
    	end get.
   
    define public override property KeyFields as character  no-undo  
        get():
            return "Name". 
        end.   
    
    define public override property Count as integer init ? no-undo  
        get(): 
            define buffer bTenantGroup for ttTenantGroup.
            if Count = ? then
            do:
                Count = 0.
                for each bTenantGroup:
                    Count = Count + 1.
                end. 
            end.    
            return Count.
        end.
        protected set.
        
    /* cannot initialize in TenantGroupContext constructor - 
       since it also wants this one, so wait til requested */
    define private variable ContextFactory as IMultiTenantScope no-undo.
    define private variable Tenantcontext as TenantContext no-undo.
    
    
    constructor public TenantGroupContext (pScope as IMultiTenantScope):
        super ("TenantGroup",pScope).
        TenantContext = pScope:TenantContext.
        ContextFactory = pScope.
        AddChild(pScope:TenantGroupMemberContext).
        AddChild(pScope:PartitionContext).
        CanEditKey = true.
    end method.
    
    constructor public TenantGroupContext ():
        define variable partitions     as PartitionContext no-undo.
        define variable details        as TenantGroupMemberContext no-undo.
        super ("TenantGroup").
        partitions = new PartitionContext().
        details = new TenantGroupMemberContext().
        
        AddChild(details).
        AddChild(partitions).                                    

/*        DatasetHandle = CreateDataset().*/
        
    end constructor.
	
 
	
	method public override void CreateRow(entity as IDataAdminElement):
	    /* the default syserror has all info */
	    CreateRow(cast(entity,ITenantGroup)).    
	end method.
	
    method public override character GetJoinFields(parentid as char):
        return "".
    end.
    
    /*
    /* override to use Name in JSON import  */
    method protected override character GetClientKeyFields():
        return "Name". 
    end method.
    */
    
    /* support many-to-many to tenants (tenants as child) */    
    method public override IDataAdminContext GetChild(pname as char):
        define variable i as integer no-undo.
        if pName = "tenants" then
        do:
            if not valid-object(TenantContext) then
            do:
                if valid-object(ContextScope) then
                    TenantContext = cast(ContextScope,IMultiTenantScope):TenantContext.
 
            end.
            return TenantContext.
        end.
        return super:GetChild(pname).
     
    end method.    
    
    method public override handle extent GetQueryHandles(pcParent as char):
        define variable h as handle extent 2 no-undo.
        if pcParent = "tenants" then
        do: 
            h[1] = ContextFactory:TenantGroupMemberContext:TableHandle:default-buffer-handle.
            h[2] = TableHandle:default-buffer-handle.
            return h.
        end.
        else 
            return super:GetQueryHandles(pcParent). 
    end method.
    
    method public override FilteredContext CreateFilteredContext( pparent as character, pkey as character, pReq as IRequestInfo ):
        if pparent = "tenants" then
        do:
            return new TenantTenantGroupQuery(this-object,pkey,pReq).          
        end.
        return super:CreateFilteredContext(pparent, pkey,pReq).

    end method.
    
    method override protected IDataAdminCollection CreateCollection(pparent as char,pcntxt as FilteredContext):     
        case pparent:
            when "tenants" then
                return new TenantTenantGroupSet(pcntxt).
            otherwise 
                return super:CreateCollection(pparent,pcntxt).             
        end.        
    end method.
    
    method public override character  GetChildQuery(parentid as char,pcKeyValue as char).
        define variable cQuery as character no-undo.
        
        case parentid:
            when "tenants" then
            do:
                cQuery = GetServerChildQuery(parentid,pcKeyValue) 
                       + " where ttTenantGroup.Name = ttTenantGroupMember.TenantGroupName".
                cQuery = left-trim(cQuery).       
                entry(1,cQuery," ") = "preselect".         
                
                return cQuery. 
            end.        
        end.    
        return super:GetChildQuery(parentid,pcKeyValue). 
        
    end method.
    
    method public override character  GetServerChildQuery(parentid as char,pcKeyValue as char).
        case parentid:
            when "tenants" then
            do:
                             
                 /* the left hand sisnde of the join is not transformed on server   
                    we manage the server relation in GetQueryRequest by defining a join in the request dataset()   */  
                 return  "for each ttTenantGroupMember where ttTenantGroupMember.TenantName "  
                            + " = "    
                            + quoter(pcKeyValue)
                            + ", each ttTenantGroup".
             end.    
        end. 
        return super:GetserverChildQuery(parentid,pcKeyValue). 
       
    end method.
    
    method public void Allocate(pcGroup as char):
        if this-object:Find(pcGroup) then
        do:
            GetPartitionContext():AllocateGroup(pcGroup,"Delayed").
        end.
        else 
            undo, throw new OpenEdge.DataAdmin.Error.IllegalArgumentError("Allocate called with invalid group" + quoter(pcGroup)).      
    end.
    
    
    method private PartitionContext GetPartitionContext():
        define variable partitions as PartitionContext no-undo.
        return cast(GetChild("partitions"),PartitionContext).     
    end method.
     
    method public override void CopyTable(cntxt as IDataAdminContext):
        define variable hTbl as handle no-undo.
        hTbl = cntxt:TableHandle.
        CopyTable(table-handle hTbl by-reference). 
        Loaded = false. 
    end method. 
    
	method private void CopyTable(input table copytable):
	    define variable dataerror as DataContextError no-undo.      
        for each copytable on error undo, throw:  
/*            if valid-object(Service) and valid-object(copytable.Entity) then*/
/*            do:                                                             */
/*                ValidateTenant(cast(copytable.Entity,ITenant)).             */
/*            end.                                                            */
            do on error undo, throw:
                find bTenantGroup where bTenantGroup.name = copytable.name no-error.
                /* force error message 
                   - DataError will transform progress message 
                     to "entity" message */
                if avail bTenantGroup then
                do:
                    create bTenantGroup.
                    bTenantGroup.name = copytable.name.               
                end.    
                catch e as Progress.Lang.Error :
                    delete bTenantGroup.
                    if not valid-object(DataError) then 
                        dataError = new DataContextError("PartititonGroup",e).
                    else 
                       dataError:AddMessage(e).             		
                end catch. 
            end.             
        end.    
        
        if valid-object(dataError) then
            undo, throw dataError. 
        temp-table ttTenantGroup:tracking-changes = true.
        for each copytable:
            create ttTenantGroup.    
            Count = Count + 1.
            buffer-copy copytable to ttTenantGroup.    
            OnRowCreated().
        end.
        temp-table ttTenantGroup:tracking-changes = false.
            
    end method. 
     
	method protected override void ValueChanged(pFieldName as char,pcOldValue as char,pNewValue as char).        
        define variable cntxt as IDataAdminContext no-undo. 
        
        super:ValueChanged(pfieldname,pcoldvalue,pNewValue).
        /* if new context then the partitions must be updated with default values */
        if pFieldName begins "Default" 
        and (   buffer ttTenantGroup:row-state = row-created 
            /* rootid implies new tenantgroup */
             or RootId = rowid(ttTenantGroup)) then
        do:    
            cntxt = GetChild("partitions").
            cast(cntxt,PartitionContext):UpdateGroupDefault(ttTenantGroup.name,pFieldName,pcOldValue,pNewValue).
        end.
    end method.
	
	method private character GetCreateError(tenantGroup as ITenantGroup):
        return this-object:GetCreateError(cast(tenantGroup,IDataAdminElement),tenantGroup:Name). 
    end method.
 
    method public handle CreateImportTable(cname as char):
        define variable child as IDataAdminContext no-undo.
        define variable h as handle no-undo.
        define variable ht as handle no-undo.
        child = GetChild(cname).
        /* todo add support to get index name */
        create temp-table h.
        ht = child:TableHandle.
        /*if cname = "partitions" then 
            h:create-like(ht,"idxpartgroup").
        else*/
            h:create-like(ht).
            
        h:temp-table-prepare (child:TableHandle:name).
        h:serialize-name = ht:serialize-name.
     
        return h.
    end method.    
    
    method public void CopyChildTable(cname as char, ht as handle):
        define variable child as IDataAdminContext no-undo.
        define variable cntxt as IDataAdminContext no-undo.
        define variable detailcntxt as TenantGroupMemberContext no-undo.
        child = GetChild(cname).
        cntxt = new DummyContext(ht).     
        if cname = "tenantGroupMembers" then
        do: 
           detailcntxt = cast(child,TenantGroupMemberContext).
           detailcntxt:ReplaceTable(cntxt).  
        end.    
        else do:
            child:Copy(cntxt).  
        end.
    end method.
        
	method public void CreateRow(tenantGroup as ITenantGroup):
	    define variable validateError as DataContextError no-undo.
       
	    temp-table ttTenantGroup:tracking-changes = true.
	    if valid-object(Service) then
	       ValidateGroup(tenantGroup).   
	                                  
	    do on error undo, throw: 
	        Count = Count + 1.
	        create ttTenantGroup.
            assign 
                ttTenantGroup.Name = tenantGroup:name
                ttTenantGroup.TableName = tenantGroup:Table:Name when valid-object(tenantGroup:Table)
                ttTenantGroup.Entity = tenantGroup
                ttTenantGroup.id = ?
                ttTenantGroup.Description =  tenantGroup:Description. 
                
            OnRowCreated().      
            catch e as Error:  
                delete ttTenantGroup.
                Count = Count - 1.
                undo, throw new DataContextError(GetCreateError(tenantGroup),"TenantGroup",e).  
            end catch.  
        end.
        finally:
            temp-table ttTenantGroup:tracking-changes = false.        		
        end finally.
    end method.
    
    method private void ValidateGroup(newgroup as ITenantGroup):
        define variable validateError as DataContextError no-undo.
        if not valid-object(newgroup:Table) then
        do:
            validateError = new DataContextError(GetCreateError(newgroup)). 
            validateError:AddMessage("- Table is undefined.",?).              
        end.
        else if newgroup:Table:ContextId <> Id then
        do:
            validateError = new DataContextError(GetCreateError(newgroup)). 
            validateError:AddMessage("- Table does not belong in this Service.",?).                       
        end.    
        if valid-object(validateError) then
            undo, throw validateError.       
    end method.    
    
    method public override logical CanFind(name as character):
        return can-find(ttTenantGroup where ttTenantGroup.name = name).            
    end.    
     
    method public override logical Find(name as character):
        find ttTenantGroup where ttTenantGroup.name = name no-error.
        return avail ttTenantGroup.            
    end.    
       
    method public override logical CanFind(id as integer):
        return can-find(ttTenantGroup where ttTenantGroup.Id = id).            
    end.    
     
    method public override logical Find(id as integer):
        find ttTenantGroup where ttTenantGroup.Id = id no-error.
        return avail ttTenantGroup.            
    end.    
    
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):
        return new TenantGroupSet(cntxt).
    end method.
    
    method protected override IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
         return new TenantGroup(cntxt).
    end method.
    
    method protected override IDataAdminElement CreateEntity(preq as IRequestInfo):
         return new TenantGroup(this-object,pReq).
    end method.
    
    /*
    method public ISaveRequest GetCreateRequest():
        define variable hchanges as handle no-undo.
        define variable savemsg as ISaveRequest no-undo.
        SaveDataset = CreateDataset("tenantGroupMembers").       
        hchanges = GetChanges(SaveDataset).
         
        savemsg = new SaveRequest(Name,Id,hchanges).
/*        mCreate = true.*/
        return savemsg.
    end method.
    */
    method public override IFetchRequest GetRequest():
        define variable hds as handle no-undo.
        hds = CreateDataset().
        return new FetchRequest(Name,Id,hds).
    end method.
    
    /*
    /* used by CreateTenant(s) to perform a second transaction */
    method public ISaveRequest GetPartitionSaveRequest():
        define variable hchanges as handle no-undo.
        define variable savemsg as ISaveRequest no-undo.
        SaveDataset = CreateDataset("partitions").       
        hchanges = GetChanges(SaveDataset).
         
        savemsg = new SaveRequest(Name,Id,hchanges).
/*        mCreate = true.*/
        return savemsg.
    end method.
    
    */
    
    /***
    /* Called from merge with the changes returned from server to keep track of 
       which partitions that will need to be refreshed. */        
    method private logical CreatePartionRefreshIds (pdsChanged as handle):
        define variable hQuery     as handle no-undo.
        define variable hBuffer    as handle no-undo.
        define variable hBefore    as handle no-undo.
        define variable lok        as logical no-undo.
        define variable lRefresh   as logical no-undo.
        define variable hPartition as handle no-undo.
        
        hbuffer = pdsChanged:get-buffer-handle ("ttTenantGroup"). 
       
        create query hQuery.
        
        hquery:add-buffer (hbuffer).
        hQuery:query-prepare ("for each ttTenantGroup").
        hquery:query-open().
        hquery:get-first.
        loop:
        do while hbuffer:avail:
            if hbuffer:row-state = row-created then
            do transaction on error undo, leave loop:
                create ttGroupNameRequest.
                assign
                    ttGroupNameRequest.Id = hBuffer::Id
                    ttGroupNameRequest.ObjectType = hBuffer::ObjectType
                    ttGroupNameRequest.ObjectNumber = hBuffer::ObjectNumber
                    ttGroupNameRequest.Name = hBuffer::name.
    
            end.
            hQuery:get-next.
            lok = true.
        end.
    end method.
    
    method public logical HasPartitionChanges():
        define variable hBuffer as handle no-undo.
        hbuffer = GetChild("partitions"):Tablehandle:default-buffer-handle. 
        return hBuffer:before-buffer:table-handle:has-records. 
    end method.     
    
    method public logical NeedPartitionRefresh():
        define variable lok as logical no-undo.
        return can-find(first ttGroupNameRequest).
  
    end method.     
    
    method private logical EmptyPartitionRefresh():
     
        empty temp-table ttGroupNameRequest.        
    end method.     
    
    method private void DeletePartitionsBeforeRequest ():
        define variable hQuery     as handle no-undo.
        define variable hBuffer    as handle no-undo.
        create query hQuery.
        
         /* now workaround the fact that fill cannot replace (even if it should? ) */
        hbuffer = GetChild("partitions"):Tablehandle:default-buffer-handle. 
        hquery:set-buffers (buffer  ttGroupNameRequest:handle).
        hquery:add-buffer (hbuffer).
        hQuery:query-prepare ("for each ttGroupNameRequest, each ttPartition where ttGroupNameRequest.name = ttPartition.TenantGroupname").
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
        tree:SetHandle("requests",buffer ttGroupNameRequest:handle).    
        GetChild("partitions"):AddTableTo(tree).         
        msg = new FetchRequest("Partition",Id,tree:GetReadHandle()).
        return msg.
   
    end method.    
    
    method override public void MergeChanges( pResponse as ISaveRequest ):
        define variable lok as logical no-undo.
        define variable msg as IFetchRequest no-undo.
        
        
        if not NeedPartitionRefresh() then    
        do: 
            CreatePartionRefreshIds(pResponse:DataHandle).    
        end.
       
        super:MergeChanges(pResponse).
        
        if (not HasPartitionChanges()) and NeedPartitionRefresh() then 
        do: 
            DeletePartitionsBeforeRequest().
            msg = CreatePartitionRefreshRequest().
            msg:UseReplaceOnClient = false.
            FetchData(msg).
            EmptyPartitionRefresh().
        end.    
   
    end method.
    */
    method protected override char FindExpression(i as int):
        return "ttTenantGroup.Id = " + quoter(i).
    end method.
    
    method protected override char FindExpression(c as char):
        return "ttTenantGroup.Name = " + quoter(c).
    end method.
    
    /** called from merge to check if allocationstate of a table changed   */      
    method private logical PartitionsNeedRefresh(pcGroup as char):
        define variable hbuffer as handle no-undo.
        define variable hbefore as handle no-undo.
        hBuffer = mPartitionAfterQuery:get-buffer-handle (1).
        hbefore  = hBuffer:before-buffer.  
        /* check modified rows for allocation changes (new are refreshed since parent is refreshed) */
        mPartitionAfterQuery:query-prepare(
           "for each ttPartition where ttPartition.TenantGroupName = " + quoter(pcGroup)
                                    + " and row-state(ttPartition) = row-modified"
                                    + " and ttPartition.ObjectType = 'Table'").
        mPartitionAfterQuery:query-open().
        mPartitionAfterQuery:get-first.
        do while hBuffer:avail:
            hBefore:find-by-rowid(hBuffer:before-rowid).
            if hBuffer::AllocationState <> hBefore::AllocationState then
                return true.
            mPartitionAfterQuery:get-next.
        end.
        return false.    
    end method.
    
    method private void DeletePartitionAfterQuery():
        delete object mPartitionAfterQuery.
    end method.
    
    method private void CreatePartitionAfterQuery(pbufferHandle as handle):
        define variable hbuffer as handle no-undo.
        create query mPartitionAfterQuery.
        mPartitionAfterQuery:add-buffer(pbufferHandle).
    end method.
    
    method private logical RefreshPartitions (pdsChanged as handle):
        define variable hQuery     as handle no-undo.
        define variable hBuffer    as handle no-undo.
        define variable hBefore    as handle no-undo.
        define variable lok        as logical no-undo.
        define variable lRefresh   as logical no-undo.
        define variable lTrack     as logical no-undo.
        define variable hPartition as handle no-undo.
        define variable msg as IFetchRequest no-undo.
            
        hbuffer = pdsChanged:get-buffer-handle ("ttTenantGroup"). 
        hPartition = pdsChanged:get-buffer-handle ("ttPartition"). 
        if valid-handle(hPartition) then
            CreatePartitionAfterQuery(hPartition).
             
        create query hQuery.
        
        hquery:add-buffer (hbuffer).
        hQuery:query-prepare ("for each ttTenantGroup").
        hquery:query-open().
        hquery:get-first.
        loop:
        do while hbuffer:avail:
            lRefresh = false.
            if hBuffer:row-state = 0 then
            do:
               /* @todo remove no-error and throw something  */  
               find ttTenantGroup where ttTenantGroup.name = hbuffer::name no-error.
               if avail ttTenantGroup then
               do: 
                   if ttTenantGroup.IsAllocated <> hbuffer::IsAllocated then
                   do:
                       lTrack = temp-table ttTenantGroup:tracking-changes.
                       temp-table ttTenantGroup:tracking-changes = false.
                       assign ttTenantGroup.IsAllocated = hbuffer::IsAllocated.
                       temp-table ttTenantGroup:tracking-changes = lTrack.
                   end. 
               end.
            end.
            /* we need refresh if isallocated is set to true   */  
            else if hbuffer:row-state = row-modified then
            do:
                hBefore = hbuffer:before-buffer.
                hbefore:find-by-rowid(hBuffer:before-rowid). 
                if hBuffer::isAllocated and hBefore::isAllocated = false then 
                do:
                   /** could be imporved by only doing the request of there are partitions */
                    lRefresh = true.  
                end.    
            end.    
            else if hbuffer:row-state = row-created then
            do:
                lRefresh = true.
            end.
            if not lRefresh and valid-handle(hPartition) then
            do: 
                lRefresh = PartitionsNeedRefresh(hbuffer::name).
            end.
            if lRefresh then 
            do:
                msg = CreatePartitionRefreshRequest(hBuffer::name).
                FetchData(msg).
                lok = true.
            end.
            hQuery:get-next.
        end.
        return lok.
        finally:
            DeletePartitionAfterQuery().		
            delete object hQuery no-error.
        end finally.
    end method.
  
    method private IFetchRequest CreatePartitionRefreshRequest (pcGroup as char):
        define variable tree as IContextTree no-undo.
        define variable msg  as IFetchRequest no-undo.
        tree = new ContextTree().  
        tree:Parse = true.        
        GetChild("partitions"):AddTableTo(tree).         
        
        msg = new FetchRequest("Partition",Id,tree:GetReadHandle()).
        msg:SetTableQuery("ttPartition","for each ttPartition where ttPartition.TenantGroupName = " + quoter(pcGroup)).
        return msg.
   
    end method.    
    
    
    method override public void DataRefreshed(presponse as IFetchResponse):
        
        if presponse:Entityname = "partition" 
        and not valid-handle(pResponse:DataHandle:get-buffer-handle(TableHandle:name)) then
            GetChild("partitions"):DataRefreshed(presponse).
        else
           super:DataRefreshed(presponse).
    end method.   
    
    /** override to refresh partitions for create  */
    method override public void MergeChanges( pResponse as ISaveRequest ):
        RefreshPartitions(pResponse:DataHandle). 
        super:MergeChanges(pResponse).
    end method.
/*                                                 */
/*	method public void showtables():                  */
/*        define variable cc as character no-undo.   */
/*        for each ttTenantGroup:                    */
/*            cc = cc + ttTenantGroup.Name + chr(10).*/
/*        end.                                       */
/*                                                   */
/*        if not session:batch-mode then             */
/*        do:                                        */
/*            message cc view-as alert-box.          */
/*        end.                                       */
/*    end method.                                    */
	
end class.
