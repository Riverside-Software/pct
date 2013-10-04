 /*************************************************************/
 /* Copyright (c) 2011,2012 by progress Software Corporation  */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : Tenant Context/Model
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Tue Aug 03 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.

using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.
using OpenEdge.DataAdmin.ITenant from propath.
using OpenEdge.DataAdmin.Tenant from propath.
using OpenEdge.DataAdmin.TenantSet from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.
using OpenEdge.DataAdmin.Binding.DataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath. 

using OpenEdge.DataAdmin.Binding.IContextTree from propath. 
using OpenEdge.DataAdmin.Binding.ContextTree from propath. 
using OpenEdge.DataAdmin.Binding.PartitionContext from propath. 
using OpenEdge.DataAdmin.Binding.NewPartitionContext from propath. 
using OpenEdge.DataAdmin.Binding.TenantGroupContext from propath. 
using OpenEdge.DataAdmin.Binding.UserContext from propath. 
using OpenEdge.DataAdmin.Binding.TenantGroupMemberContext from propath. 
using OpenEdge.DataAdmin.Binding.DomainContext from propath. 
using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath. 
 
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath. 
using OpenEdge.DataAdmin.Binding.Query.TenantGroupTenantQuery  from propath.
using OpenEdge.DataAdmin.Binding.Factory.IMultiTenantScope from propath.
using OpenEdge.DataAdmin.Binding.Factory.IContextFactory from propath.

using OpenEdge.DataAdmin.Error.* from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Message.SaveRequest from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.IFetchResponse from propath.
using OpenEdge.DataAdmin.Message.FetchRequest from propath.
using OpenEdge.DataAdmin.Support.TenantGroupTenantSet  from propath. 

using OpenEdge.DataAdmin.Support.TenantGroupTenantSet  from propath. 

class OpenEdge.DataAdmin.Binding.TenantContext inherits DataAdminContext implements IDataAdminContext: 
    
    {daschema/tenant.i} 
    define private dataset dsTenant serialize-name "root" for ttTenant.
    define buffer btenant for ttTenant.
    define temp-table copytable reference-only like ttTenant.
      
    define temp-table ttPartitionIdRequest no-undo
        field partitionid as int
        field tenantname as char
        index partname as  unique tenantname
        index partidx as primary unique partitionid.
        
    define private variable mCreate as logical no-undo.
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
    		return temp-table ttTenant:handle.
    	end get.
   
    define public override property KeyFields as character  no-undo  
        get():
            return "Name". 
        end.   
    
    define public override property Count as integer init ? no-undo  
        get(): 
            define buffer btenant for ttTenant.
            if Count = ? then
            do:
                Count = 0.
                for each btenant:
                    Count = Count + 1.
                end. 
            end.    
            return Count.
        end.
        protected set.
    
   
    define private variable ContextFactory as IMultiTenantScope no-undo.
    define private variable TenantGroupContext as TenantGroupContext no-undo.
    
    constructor public TenantContext ():
        define variable users as UserContext no-undo.
        define variable partitioncntxt as PartitionContext no-undo.
        define variable tenantgroupmembercntxt as TenantGroupMemberContext no-undo.
        
        super ("Tenant").
        
        users = new UserContext().
        /* users is not part of default tree (users on domain is) */
        SkipList = "users".
        AddChild(new DomainContext(users)).
        AddChild(users).
        partitioncntxt = new PartitionContext().
        AddChild(partitioncntxt).
        tenantgroupmembercntxt = new TenantGroupMemberContext().
        AddChild(tenantgroupmembercntxt).
        /*  */
                
        
/*        DatasetHandle = CreateDataset().*/
        
    end constructor.
    
  
    constructor public TenantContext (pScope as IMultiTenantScope):
        super ("Tenant",pScope).
        
        AddChild(pScope:DomainContext).
        AddChild(pScope:UserContext).
        AddChild(pScope:PartitionContext).
        AddChild(pScope:TenantGroupMemberContext).
        if not pScope:IsLocal then
        do:
            AddChild(pScope:SequenceValueContext).
            /* users is not part of default tree (users on domain is) 
               sequencevalues is not part of defaulot tree at all */
            SkipList = "users,sequenceValues".
        end.
        else
             /* users is not part of default tree (users on domain is) */
            SkipList = "users".
        ContextFactory = pScope.
        CanEditKey = true.
    end method.
 
	method public override void CreateRow(entity as IDataAdminElement):
	    /* the default syserror has all info */
	    CreateRow(cast(entity,ITenant)).    
	end method.
	
    method public override character GetJoinFields(parentid as char):
        return "".
    end.
    
    /* override to use Name in JSON import 
    method protected override character GetClientKeyFields():
        return "Name". 
    end method.
      */
                                                         
    method protected override handle CreateSaveDataset():
        define variable tree as IContextTree no-undo.    
        tree = new ContextTree().                        
        tree:Parse = true.                               
        AddTreeTo(tree).                                
        ContextFactory:SequenceValueContext:AddTableTo(tree).
        return tree:GetReadHandle().                     
    end method.                                         
    
    
/*    method public void LoadInstances().                   */
/*        if not Loaded then                                */
/*        for each ttTenant:                                */
/*            if not valid-object(ttTenant.Entity) then     */
/*                ttTenant.Entity = new Tenant(this-object).*/
/*        end.                                              */
/*        Loaded = true.                                    */
/*    end method.                                           */
/*                                                          */
/*    method protected void UnLoadInstances().              */
/*        for each ttTenant:                                */
/*            ttTenant.Entity = ?.                          */
/*        end.                                              */
/*        Loaded = false.                                   */
/*    end method.                                           */
              
    method public override void CopyTable(cntxt as IDataAdminContext):
        define variable hTbl as handle no-undo.
        hTbl = cntxt:TableHandle.
        CopyTable(table-handle hTbl by-reference). 
        Loaded = false. 
    end method. 
    
	method private void CopyTable(input table copytable):
	    define variable dataerror as DataContextError no-undo.      
        define variable lTrack as logical no-undo.
        for each copytable on error undo, throw:  
            if valid-object(Service) and valid-object(copytable.Entity) then 
            do:
                ValidateTenant(cast(copytable.Entity,ITenant)).
            end.
            do on error undo, throw:
                find btenant where btenant.name = copytable.name no-error.
                /* force error message 
                   - DataError will transform progress message 
                     to "entity" message */
                if avail btenant then
                do:
                    create bTenant.
                    btenant.name = copytable.name.               
                end.    
                catch e as Progress.Lang.Error :
                    delete bTenant.
                    if not valid-object(DataError) then 
                        dataError = new DataContextError("Tenant",e).
                    else 
                       dataError:AddMessage(e).             		
                end catch. 
            end.             
        end.    
        
        if valid-object(dataError) then
            undo, throw dataError. 
        lTrack = temp-table ttTenant:tracking-changes.
        temp-table ttTenant:tracking-changes = true.
        for each copytable:
            create tttenant.    
            Count = Count + 1.
            buffer-copy copytable except id to tttenant.    
            OnRowCreated().
        end.
        temp-table ttTenant:tracking-changes = lTrack.
    end method.  
	
	/** fires after change - validation should have been done */
	method protected override void ValueChanged(pFieldName as char,pcOldValue as char,pNewValue as char).        
        define variable cntxt as IDataAdminContext no-undo. 
        super:ValueChanged(pfieldname,pcoldvalue,pNewValue).
        /* if new tenant then the partitions must be updated with default values */
        if pFieldName begins "Default" 
        and (buffer ttTenant:row-state = row-created 
             /* rootid = rowid implies new tenant */
             or RootId = rowid(ttTenant) ) then
        do:    
            cntxt = GetChild("partitions").
            cast(cntxt,PartitionContext):UpdateTenantDefault(ttTenant.name,pFieldName,pcOldValue,pNewValue).
        end.
    end method.
	
	method private character GetCreateError(tenant as ITenant):
        return this-object:GetCreateError(cast(tenant,IDataAdminElement),tenant:Name). 
    end method.
    
    method protected override void ValidateBuffer(phTenant as handle):
        define variable hBefore as handle no-undo.
       
        if phTenant:row-state = row-modified then
        do:
            hBefore = phTenant:before-buffer.
            hbefore:find-by-rowid(phTenant:before-rowid).
            if phTenant::Type <> hBefore::Type then
               undo, throw new CreateOnlyPropertyError(Name,phTenant::Name,"Type").
            /* OEM 449- allow rename of tenants */
            /*if phTenant::Name <> hBefore::Name then
               undo, throw new ReadOnlyPropertyError(Name,phTenant::Name,"Name").*/
        end. 
        else if phTenant:row-state = row-created then
            ValidateType(phTenant::Name,phTenant::Type).
      
    end method.      
    
    method private void ValidateType(pcKey as char,pcType as char ):
         define variable cErr as character no-undo.
         if pcType = "" then
         do:
             undo, throw new ValidationError(Name,pckey,"Type","cannot be blank. Valid types are " + ValidTypeString + "."). 
         end.
         else if pcType = "Default" then
             undo, throw new ValidationError(Name,pckey,"Type","is invalid. Cannot create another ~"Default~" Tenant."). 
         else if lookup(pctype,ValidTypeList) = 0 then
             undo, throw new InvalidPropertyValueError(Name,pcKey,"Type",pcType,ValidTypeList). 
    end.  
    
	method private void ValidateTenant(tenant as ITenant):
	    define variable validateError as DataContextError no-undo.
	    define variable lError as logical no-undo.
        define variable cErr as character extent 8 no-undo.
        define variable i as integer no-undo.   
        
        if tenant:Type = "regular" then
        do:           
            if not valid-object(tenant:DefaultDataArea) then
            do:
                cErr[1] = "DefaultDataArea is undefined.". 
                lerror = true.
            end.
            else if valid-object(Service) and tenant:DefaultDataArea:Service <> Service then
            do:
                cErr[1] = "DefaultDataArea " + quoter(tenant:DefaultDataArea:Name) + " does not exist in service.".              
                lerror = true.
            end.
                 
            if not valid-object(tenant:DefaultIndexArea) then
            do:
                cErr[2] = "DefaultIndexArea is undefined". 
                lerror = true.
            end.
            else if valid-object(Service) and tenant:DefaultIndexArea:Service <> Service then
            do:
                cErr[2] = "DefaultIndexArea " + quoter(tenant:DefaultIndexArea:Name) + " does not exist in service.".              
                lerror = true.
            end.
            
            if not valid-object(tenant:DefaultLobArea) then
            do:
                cErr[3] = "DefaultLobArea is undefined". 
                lerror = true.
            end.
            else if valid-object(Service) and tenant:DefaultDataArea:Service <> Service then
            do:
                cErr[3] = "DefaultLobArea " + quoter(tenant:DefaultDataArea:Name) + " does not exist in service.".              
                lerror = true.
            end.
            
            if tenant:DefaultAllocation = "" or tenant:DefaultAllocation = ? then
            do:
                cErr[4] = "DefaultAllocation cannot be blank.".              
                lerror = true.
            end.
            else if lookup(tenant:DefaultAllocation,ValidDefaultAllocationList) = 0 then
            do:
                cErr[4] = quoter(tenant:DefaultAllocation) + " is not a valid DefaultAllocation value. Valid values are " + ValidDefaultAllocationString + ".".              
                lerror = true.
            end. 
             
        end.
        else if tenant:Type = "super" then
        do:
            if valid-object(tenant:DefaultDataArea) then
            do:
               cErr[1]  = "DefaultDataArea cannot be defined on a super-tenant" .              
               lerror = true.
            end. 
            
            if valid-object(tenant:DefaultIndexArea) then
            do:
                cErr[2]  = "DefaultIndexArea cannot be defined on a super-tenant" .              
                lerror = true.
            end. 
            
            if valid-object(tenant:DefaultLobArea) then
            do:
                cErr[3]  = "DefaultLobArea cannot be defined on a super-tenant" .              
                lerror = true.
            end. 
             
            if tenant:DefaultAllocation > "" then
            do:
                cErr[4]  = "DefaultAllocation cannot be defined on a super-tenant" .              
                lerror = true.
            end.                  
        end.
        if lError then 
        do:
            validateError = new DataContextError(GetCreateError(tenant)).
            do i = 1 to extent(cErr):
                if cErr[i] > "" then
                    validateError:AddMessage("* " + cErr[i],?).
          
            end.
            undo, throw validateError.
        end.
        
	end method.    
	
	method public override FilteredContext CreateFilteredContext( pparent as character, pkey as character, pReq as IRequestInfo ):
        if pparent = "tenantGroups" then
        do:
            return new TenantGroupTenantQuery(this-object,pkey,pReq).          
        end.
        return super:CreateFilteredContext(pparent, pkey,pReq).

    end method.
	
	method override protected IDataAdminCollection CreateCollection(pparent as char,pcntxt as FilteredContext):     
        define variable cntxt as IDataAdminContext no-undo.
        case pparent:
            when "tenantGroups" then
                return new TenantGroupTenantSet(pcntxt).  
            otherwise 
                return super:CreateCollection(pparent,pcntxt).             
        end.        
    end method.
    
	 /* support many-to-many to tenants (tenants as child) */    
    method public override IDataAdminContext GetChild(pname as char):
        define variable i as integer no-undo.
        if pName = "tenantGroups" then
        do:
            if not valid-object(TenantGroupContext) then
            do:
                if valid-object(ContextFactory) then
                    TenantGroupContext = ContextFactory:TenantGroupContext.
            end.
            return TenantGroupContext.
        end.
        return super:GetChild(pname).
     
    end method.    
    
     method public override character  GetChildQuery(parentid as char,pcKeyValue as char).
        define variable cQuery as character no-undo.
        
        case parentid:
            when "tenantGroups" then
            do:
                cQuery = GetServerChildQuery(parentid,pcKeyValue) 
                       + " where ttTenant.Name = ttTenantGroupMember.TenantName". 
                cQuery = left-trim(cQuery).       
                entry(1,cQuery," ") = "preselect".         
                
                return cQuery. 
            end.        
        end.    
        return super:GetChildQuery(parentid,pcKeyValue). 
        
    end method.
    
    method public override character  GetServerChildQuery(parentid as char,pcKeyValue as char).
        case parentid:
            when "tenantGroups" then
            do:
                /* the left hand sisnde of the join is not transformed on server   
                   we manage the server relation in GetQueryRequest by defining a join in the request dataset()   */  
                return  "for each ttTenantGroupMember where ttTenantGroupMember.TenantGroupName "  
                            + " = "    
                            + quoter(pcKeyValue)
                            + ", each ttTenant".
             end.    
         end. 
         return super:GetserverChildQuery(parentid,pcKeyValue). 
       
    end method.
    
     method public override handle extent GetQueryHandles(pcParent as char):
        define variable h as handle extent 2 no-undo.
        if pcParent = "tenantGroups" then
        do: 
            h[1] = ContextFactory:TenantGroupMemberContext:TableHandle:default-buffer-handle.
            h[2] = TableHandle:default-buffer-handle.
            return h.
        end.
        else 
            return super:GetQueryHandles(pcParent). 
    end method.
    
	method public void CreateRow(tenant as ITenant):
	    define variable validateError as DataContextError no-undo.
       
	    temp-table ttTenant:tracking-changes = true.
	    if valid-object(Service) then
	       ValidateTenant(tenant).
	    
	    do on error undo, throw: 
	        Count = Count + 1.
	        create ttTenant.
            assign 
                ttTenant.Name = tenant:name
                ttTenant.Entity = tenant
                ttTenant.id = ?
                ttTenant.ExternalId  =  tenant:ExternalId
                ttTenant.Description =  tenant:Description
                ttTenant.Type        =  tenant:Type
                ttTenant.IsDataEnabled    =  tenant:IsDataEnabled
                ttTenant.IsAllocated =  tenant:IsAllocated. 
            if tenant:Type = "Regular" then
            do: 
                if valid-object(tenant:DefaultDataArea) then
                    ttTenant.DefaultDataAreaName  = tenant:DefaultDataArea:Name.
                if valid-object(tenant:DefaultIndexArea) then
                    ttTenant.DefaultIndexAreaName = tenant:DefaultIndexArea:Name.
                if valid-object(tenant:DefaultLobArea) then
                    ttTenant.DefaultLobAreaName   = tenant:DefaultLobArea:Name.
                ttTenant.DefaultAllocation    = tenant:DefaultAllocation.
            end.        
            OnRowCreated().      
            catch e as Error:  
                delete ttTenant.
                Count = Count - 1.
                undo, throw new DataContextError(GetCreateError(tenant),"Tenant",e).  
            end catch.  
        end.
        finally:
            temp-table ttTenant:tracking-changes = false.        		
        end finally.
    end method.
    
    method public override logical CanFind(name as character):
        return can-find(ttTenant where tttenant.name = name).            
    end.    
     
    method public override logical Find(name as character):
        find ttTenant where tttenant.name = name no-error.
        return avail tttenant.            
    end.    
    
    method public logical FindByExternalId(ExtId as character):
        find ttTenant where tttenant.ExternalId = ExtId no-error.
        return avail tttenant.            
    end.    
    
    method public logical CanFindByExternalId(ExtId as character):
        return can-find(ttTenant where tttenant.ExternalId = ExtId).
    end.    
    
    method public override logical CanFind(id as integer):
        return can-find(ttTenant where tttenant.Id = id).            
    end.    
     
    method public override logical Find(id as integer):
        find ttTenant where tttenant.Id = id no-error.
        return avail tttenant.            
    end.    
    
    method public IDataAdminElement FindTenantByExternalId(ExtId as character):
        if this-object:FindByExternalId(ExtId) then
            return CreateEntity(this-object).
        return ?.
    end method.
    
    method public IDataAdminElement GetTenantByExternalId(cKey as char).
        define variable msg as IFetchRequest no-undo.
        if not this-object:FindByExternalId(cKey) then
        do:
            msg = GetRequest(). 
            msg:SetTableQuery(Tablehandle:name,
               "for each ttTenant where ttTenant.Externalid = " + quoter(cKey)).
            FetchData(msg).   
        end.   
        return FindTenantByExternalId(cKey). 
    end method.
    
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):
        return new TenantSet(cntxt).
    end method.
    
    method protected override IDataAdminElement CreateEntity(req as IRequestInfo):
        return new Tenant(this-object,req).
    end method.
    
    method protected override IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
        return new Tenant(cntxt).
    end method.
    /*
    method public ISaveRequest GetCreateRequest():
        define variable hchanges as handle no-undo.
        define variable savemsg as ISaveRequest no-undo.
        SaveDataset = CreateDataset("domains").       
        hchanges = GetChanges(SaveDataset).
         
        savemsg = new SaveRequest(Name,Id,hchanges).
/*        mCreate = true.*/
        return savemsg.
    end method.
    
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
    
    /*
    /* Called from merge with the changes returned from server to keep track of 
       which partitions that will need to be refreshed. */        
    
    method private logical CreatePartionRefreshIds (pdsChanged as handle):
        define variable hQuery     as handle no-undo.
        define variable hBuffer    as handle no-undo.
        define variable hBefore    as handle no-undo.
        define variable lok        as logical no-undo.
        define variable lRefresh   as logical no-undo.
        define variable hPartition as handle no-undo.
        
        hbuffer = pdsChanged:get-buffer-handle ("tttenant"). 
       
        create query hQuery.
        
        hquery:add-buffer (hbuffer).
        hQuery:query-prepare ("for each ttTenant").
        hquery:query-open().
        hquery:get-first.
        do while hbuffer:avail:
            if hbuffer:row-state = row-created then
                lRefresh = true.
            else if hbuffer:row-state = row-modified then
            do:     
                hBefore = hbuffer:before-buffer.
                hbefore:find-by-rowid(hBuffer:before-rowid). 
                if hBuffer::isAllocated and hBefore::isAllocated = false then 
                   lRefresh = true.  
            end.            
            if lRefresh then 
            do:
                create ttPartitionIdRequest.
                ttPartitionIdRequest.PartitionId = hBuffer::Id.
                ttPartitionIdRequest.Tenantname = hBuffer::name.
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
      */
    /*
    method public logical NeedPartitionRefresh():
        return can-find(first ttPartitionIdRequest).        
    end method.     
    
    method private logical EmptyPartitionRefresh():
        empty temp-table ttPartitionIdRequest.        
    end method.     
      */
      /*
    method private void DeletePartitionsBeforeRequest ():
        define variable hQuery     as handle no-undo.
        define variable hBuffer    as handle no-undo.
        create query hQuery.
        
         /* now workaround the fact that fill cannot replace (even if it should? ) */
        hbuffer = GetChild("partitions"):Tablehandle:default-buffer-handle. 
        hquery:set-buffers (buffer  ttPartitionIdRequest:handle).
        hquery:add-buffer (hbuffer).
        hQuery:query-prepare ("for each ttPartitionIdRequest, each ttPartition of ttPartitionIdRequest").
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
      */
      /*
    method private IFetchRequest CreatePartitionRefreshRequest ():
        define variable tree as IContextTree no-undo.
        define variable msg  as IFetchRequest no-undo.
        tree = new ContextTree().  
        tree:Parse = true.   
        tree:SetHandle("requests",buffer ttPartitionIdRequest:handle).    
        GetChild("partitions"):AddTableTo(tree).         
        msg = new FetchRequest("Partition",Id,tree:GetReadHandle()).
   
        return msg.
   
    end method.    
    */
     
    
    method protected override char FindExpression(i as int):
        return "ttTenant.Id = " + quoter(i).
    end method.
    
    method protected override char FindExpression(c as char):
        return "ttTenant.Name = " + quoter(c).
    end method.
    
    method private void DeletePartitionAfterQuery():
        delete object mPartitionAfterQuery.
    end method.
    
    method private void CreatePartitionAfterQuery(pbufferHandle as handle):
        define variable hbuffer as handle no-undo.
        create query mPartitionAfterQuery.
        mPartitionAfterQuery:add-buffer(pbufferHandle).
    end method.
    
    /** called from merge to check if allocationstate of a table changed   */      
    method private logical PartitionsNeedRefresh(pcTenant as char):
        define variable hbuffer as handle no-undo.
        define variable hbefore as handle no-undo.
        hBuffer = mPartitionAfterQuery:get-buffer-handle (1).
        hbefore  = hBuffer:before-buffer.  
        /* check modified rows for allocation changes (new are refreshed since parent is refreshed) */
        mPartitionAfterQuery:query-prepare(
           "for each ttPartition where ttPartition.TenantName = " + quoter(pcTenant)
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
    
    method private logical RefreshPartitions (pdsChanged as handle):
        define variable hQuery     as handle no-undo.
        define variable hBuffer    as handle no-undo.
        define variable hBefore    as handle no-undo.
        define variable lok        as logical no-undo.
        define variable lTrack     as logical no-undo.
        define variable lRefresh   as logical no-undo.
        define variable hPartition as handle no-undo.
        define variable msg as IFetchRequest no-undo.
     
        hbuffer = pdsChanged:get-buffer-handle ("ttTenant"). 
        hPartition = pdsChanged:get-buffer-handle ("ttPartition"). 
        if valid-handle(hPartition) then
            CreatePartitionAfterQuery(hPartition).
        create query hQuery.
        
        hquery:add-buffer (hbuffer).
        hQuery:query-prepare ("for each ttTenant").
        hquery:query-open().
        hquery:get-first.
        loop:
        do while hbuffer:avail:
            lRefresh = false.
            if hBuffer:row-state = 0 then
            do:
               /* @todo remove no-error and throw something  */  
               find ttTenant where ttTenant.name = hbuffer::name no-error.
               if avail ttTenant then  
               do:
                   if ttTenant.isallocated <> hbuffer::IsAllocated then
                   do:
                       lTrack = temp-table ttTenant:tracking-changes.
                       temp-table ttTenant:tracking-changes = false.
                       assign ttTenant.isallocated = hbuffer::IsAllocated.
                       temp-table ttTenant:tracking-changes = lTrack.
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
    end method.
  
    method private IFetchRequest CreatePartitionRefreshRequest (pcGroup as char):
        define variable tree as IContextTree no-undo.
        define variable msg  as IFetchRequest no-undo.
        tree = new ContextTree().  
        tree:Parse = true.        
        GetChild("partitions"):AddTableTo(tree).         
        
        msg = new FetchRequest("Partition",Id,tree:GetReadHandle()).
        msg:SetTableQuery("ttPartition","for each ttPartition where ttPartition.TenantName = " + quoter(pcGroup)).
        return msg.
   
    end method.    
    
    method override public void DataRefreshed(presponse as IFetchResponse):
        
        if presponse:Entityname = "partition" 
        and not valid-handle(pResponse:DataHandle:get-buffer-handle(TableHandle:name)) then
            GetChild("partitions"):DataRefreshed(presponse).
        else
           super:DataRefreshed(presponse).
    end method.   
    
    /** refresh partitions for create 
       NewPartitionContext retrieved these */
    method override public void MergeChanges( pResponse as ISaveRequest ):
        RefreshPartitions(pResponse:DataHandle). 
        super:MergeChanges(pResponse).
   
    end method.
    
/*	method public void showtables():                              */
/*        define variable cc as character no-undo.               */
/*        for each ttTenant:                                     */
/*            cc = cc + ttTenant.Name                            */
/*            + " rowstate "  + string(buffer ttTenant:row-state)*/
/*            + chr(10).                                         */
/*        end.                                                   */
/*                                                               */
/*        if not session:batch-mode then                         */
/*        do:                                                    */
/*            message cc view-as alert-box.                      */
/*        end.                                                   */
/*    end method.                                                */
/*	                                                               */
end class.
