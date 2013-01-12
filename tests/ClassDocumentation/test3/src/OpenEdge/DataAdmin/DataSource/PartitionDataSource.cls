/*************************************************************/
 /* Copyright (c) 2011,2012 by progress Software Corporation. */
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
using Progress.Database.DBConfig from propath. 
using Progress.Database.Storage from propath. 
using OpenEdge.DataAdmin.DataSource.DataSource from propath.
using OpenEdge.DataAdmin.Lang.QueryString from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

using OpenEdge.DataAdmin.DataAccess.DataAccessError from propath.
using OpenEdge.DataAdmin.DataAccess.DataMapper from propath.
using OpenEdge.DataAdmin.ServerCommand.DeallocateCommand from propath.
using OpenEdge.DataAdmin.Message.DeallocateRequest from propath.

using OpenEdge.DataAdmin.DataAccess.DataMapper from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.

class OpenEdge.DataAdmin.DataSource.PartitionDataSource inherits DataSource: 
   
    /* these could have been properties with getters that just returned data based on URl,
       but they are used in rowafter event and while the getters are very fast, overrided getters 
       are still 20 times slower than variables/props with no overrides. We're talking milliseconds, but 
       enough to substantially reduce throughput for this datasource, which may need to read a lot of records  */ 
    define protected variable AreaUrl as char no-undo init "/areas/".
    define protected variable TenantURL as character no-undo init "/tenants/".
    define protected variable GroupURL as character no-undo init "/tenantgroups/".
    define private variable mSaving as logical no-undo.
    
    define private variable mSimulation as logical no-undo.
    
    define private variable mRefreshQuery as handle no-undo.
   
    define protected property DBConfig as DBConfig no-undo
        get():
            if not valid-object(DBConfig) then        
                DBConfig = new DBConfig(ldbname("dictdb")).
            return DBConfig.
        end.
        private set.
    
    /******** cannot run this with active trans/locks 
    define protected property DeallocateCommand as DeallocateCommand  no-undo
        get():
            if not valid-object(DeallocateCommand) then        
                DeallocateCommand = new DeallocateCommand(ldbname("dictdb")).
            return DeallocateCommand.
        end.
        private set.
    *****/
    
    define protected property ValidAllocationList as char  no-undo
         get():
             return "Delayed,None,Allocated".
         end. 
    
    define temp-table ttState no-undo
        field ObjectState as char.
     
    define protected property StorageMap as char no-undo
       init "ttPartition.trowid,rowid(_StorageObject),ttPartition.Parentid,_StorageObject._partitionid"
       get.
   
    define protected property StorageFileMap as char no-undo
        init "ttPartition.TableName,_File._File-name,ttPartition.SchemaName,_file._owner" 
        get. 
   
    define protected property StorageTenantMap as char no-undo
        init "ttPartition.TenantName,_Tenant._Tenant-Name,ttPartition.TenantId,_Tenant._TenantId" 
        get. 
    
    define protected property StorageGroupMap as char no-undo
        init "TenantGroupName,_Partition-Set._PSet-Name,TenantGroupId,_Partition-Set._PSetid" 
        get. 
        
    define protected property StorageAreaMap as char no-undo
        init "ttPartition.AreaName,_Area._Area-Name" 
        get. 
   
    define protected property FindFirstTenant as char no-undo
        get():
            return  "first _tenant where _tenant._tenantid = _StorageObject._partitionid no-lock".
        end.
    
    define protected property FindFirstArea as char no-undo
        get():
            return "first _area where _area._area-number = _StorageObject._area-number no-lock".
        end.
        
    define protected property FindFirstTenantAndArea as char no-undo
        get():
            return FindFirstTenant + ", " 
                +  FindFirstArea.       
        end.
    
    define protected property FindFirstGroup as char no-undo
        get():
            return   "first _Partition-Set"  
                     + " where _Partition-Set._object-type = _StorageObject._Object-type"
                     + " and _Partition-Set._object-number = _StorageObject._Object-Number"
                     + " and _Partition-Set._PSetid = _StorageObject._PartitionId no-lock".   
       end.
    
    define protected property FindFirstGroupAndArea as char no-undo
        get():
            return FindFirstGroup + ", " 
                +  FindFirstArea.       
        end.
    
    constructor public PartitionDataSource () :
        super("_StorageObject","dictdb._StorageObject",StorageMap). 
        BaseQuery = "for each _StorageObject no-lock".
    end constructor.
    
    constructor public PartitionDataSource (hTempSource as handle,cQuery as char) :
        super(hTempSource,"_StorageObject","dictdb._StorageObject",StorageMap). 
        BaseQuery = cQuery.    
    end constructor.
    
    constructor protected PartitionDataSource (pcTables  as char,
                                               pcPhysicalTables as char,
                                               pcMapping     as char) :
        super(pcTables + ",_StorageObject",pcPhysicalTables + ",dictdb._StorageObject",pcMapping + "," + StorageMap). 
    end constructor.
    
    constructor protected PartitionDataSource (pcTables  as char,
                                               pcPhysicalTables as char,
                                               pcMapping     as char,
                                               plSimulation as log) :
        super(pcTables,pcPhysicalTables,pcMapping).
        if plSimulation then 
        do:    
             mSimulation = true.
        end.                                           
    end constructor.
    
    constructor protected PartitionDataSource (pcTables  as char,
                                               pcPhysicalTables as char,
                                               pcMapping     as char,
                                               pcBaseQuery   as char) :
        super(pcTables,pcPhysicalTables,pcMapping).
        BaseQuery = pcBaseQuery. 
    end constructor.
    
    
    constructor public PartitionDataSource (hTempSource as handle,
                                   pcTables  as char,
                                   pcPhysicalTables as char,
                                   pcMapping     as char) :
        super(hTempSource,pcTables + ",_StorageObject",pcPhysicalTables + ",dictdb._StorageObject",pcMapping + "," + StorageMap). 
    end constructor.
    
    method protected override void AfterSetUrl():
        TenantUrl =  "/tenants/".
        GroupUrl = "/tenantgroups/".
        AreaURL = "/areas/".
        if Url > "" then
        do:
            GroupUrl = Url + GroupUrl.
            TenantUrl = Url + TenantUrl.
            AreaURL = Url + AreaURL.
        end.
    end method. 
    
    method public override logical Prepare(phBuffer as handle,pcTargetQuery as char,pcJoin as char):
        define variable oQueryString as class QueryString.
        define variable lOk          as logical    no-undo.
        define variable hParentRel   as handle     no-undo.
        define variable cQuery       as character no-undo.
        define variable cMap         as character no-undo.
        define variable lAddTables   as logical no-undo.
        
        DataBuffer = phBuffer.    
        
        phBuffer:set-callback("After-Row-fill","AfterPartitionRow").      
        
        CreateQuery().    
        hParentRel = ParentRelation.
        /* fieldmapping is set from constructor */
        DataBuffer:attach-data-source(DataSourceHandle:handle,FieldMapping) .
       
/*        hParentRel = ParentRelation.*/
        
        if pcTargetQuery > "" or pcJoin > '' or valid-handle(hParentRel) then
        do:
            oQueryString = new QueryString(pcTargetQuery,this-object).
            /* fieldmapping is set from constructor */
            cMap = FieldMapping.
            lOk  = AddUniqueOrNone("_tenant",oQueryString). 
            if lok = false then
                return false. 
            if lok = ? and lookup("_Tenant",Tables) = 0 then
            do:
                lAddTables = true.
                Tables = Tables + ",_Tenant".
                PhysicalTables = PhysicalTables + ",dictdb._Tenant".
                BaseQuery = BaseQuery + ", " + FindFirstTenant.
                cMap = cMap + "," + StorageTenantMap.
            end.
            lOk = AddUniqueOrNone("_Partition-Set",oQueryString).
            if lok = false then
                return false. 
            if lok = ? and lookup("_Partition-Set",Tables) = 0 then
            do:
                lAddTables  = true.
                Tables = Tables + ",_Partition-Set".
                PhysicalTables = PhysicalTables + ",dictdb._Partition-Set".
                BaseQuery = BaseQuery + ", " + FindFirstGroup.
                cMap = cMap + "," + StorageGroupMap.
            end.
            lOk  = AddUniqueOrNone("_Area",oQueryString). 
            if lok = false then
                return false. 
            if lok = ? and lookup("_Area",Tables) = 0 then
            do:
                lAddTables  = true.
                Tables = Tables + ",_Area".
                PhysicalTables = PhysicalTables + ",dictdb._Area".
                BaseQuery = BaseQuery + ", " + FindFirstArea.
                cMap = cMap + "," + StorageAreaMap.
            end.
            if lAddTables then
            do:
                CreateQuery().    
                DataBuffer:attach-data-source(DataSourceHandle,cMap) .
            end.
                
/*            AddObjectStateExpression(oQueryString).*/
            if pcJoin > '' then
            do:
                Tables = Tables + ",_Partition-Set,_Area".
                PhysicalTables = PhysicalTables + ",dictdb._Partition-Set,dictdb._Area".
                BaseQuery = BaseQuery + "," + FindFirstGroupAndArea.
                CreateQuery().    
                /* fieldmapping is set from constructor */
                DataBuffer:attach-data-source(DataSourceHandle ,
                   FieldMapping + "," + StorageGroupMap + "," + StorageAreaMap) .
               
                hParentRel:Active = true.
                
                oQueryString:addExpression(pcJoin).
                
            end.
            /* Data-Sources are defined with queries in the constructor in the event that
               there is a join involved. Add and transform the fill-where-string for the dependent 
               tables so that Progress can identify the related when filling the temp-tables.
              (columnValue ensures parent reference is NOT transformed) */
            else if valid-handle(hParentRel) and hParentRel:active and not hParentRel:reposition then
                oQueryString:addExpression(DataSourceHandle:fill-where-string).
       
            cQuery = oQueryString:BuildQueryString(Tables).
            
/*           message            */
/*            pcTargetQuery skip*/
/*            cQuery skip       */
/*           view-as alert-box. */
/*              oQueryString:showdata() .*/

            lok = QueryHandle:query-prepare (cQuery).
 
            delete object oQueryString. 
        end.
        else
            lok = Prepare().
            
        return lOk.
    end method. 
    
    /** Save all  
         @param buffer the temp-table buffer handle with data */
    method public override logical Save(bufferHandle as handle):
        this-object:Save(bufferHandle,?).
    end method. 
    
     
    /** Save changes of specified state 
         @param buffer the temp-table buffer handle with data
         @param state  the row-state to save (row-created, row-deleted or row-modified) 
                      ? = all */
    method public override logical Save(phbuffer as handle,piState as int):
        define variable cdealloctable as longchar no-undo.
        define variable hDataset as handle no-undo.
        define variable hBeforeBuff as handle    no-undo.
        define variable hquery      as handle    no-undo.
        define variable iType       as integer   no-undo.
        define variable cType       as character no-undo.
        define variable cName       as character no-undo.
        define variable dbRecid     as recid     no-undo.
        define variable iTenantid   as integer no-undo.
        define variable iObjectid   as integer no-undo.
        define variable iTypeId     as integer no-undo.
        define variable partition   as Storage no-undo.
      
        define buffer btenant for dictdb._tenant.
        define buffer barea for dictdb._area.
        define buffer bfile for dictdb._file.
        define buffer bfield for dictdb._field.
        define buffer bindex for dictdb._index.
        
        if piState < 1 or pistate > 3 then
            undo, throw new IllegalArgumentError("Invalid state " + string(piState) + " passed to save." ).
        mSaving = true. 
        /** create query to refresh index and fields to be returned to client when 
            allocationstate of the table changes  
            (the table is updated after the field and index  partitions ) */      
        CreateRefreshQuery(phBuffer).
        create query hquery.
        hBeforeBuff = phBuffer:before-buffer.
        hquery:add-buffer(hBeforeBuff).
        /* the sort order was added for dealloc, whihc ended uo being not supported and may not be neccesary */
        /* partitions for a new tenant are marked as created on client 
           and will thus be available here. 
           We mainly use the state to ensure that this is called after 
           tenant update when the tenant is new and before when the tenant is not
           */
        hQuery:query-prepare("for each ttPartitionCopy "
                              + (if piState <> ? 
                                 then " where row-state(ttPartitionCopy) = " + string(piState)
                                 else "")   
                                 /* as of current tables are allocated on client in tenant or group Allocate
                                    so we need to save index and field before table since they cannot be changed
                                    once the table is allocated */
                              + " by ttPartitionCopy.TableName by ttPartitionCopy.ObjectType").    
        hquery:query-open().
        DBConfig:LockWait = FALSE.
       
        /* This is not likely to be the transacton at runtime. 
           The DataAccess will typically define the transaction for all sources */
        do transaction on error undo, throw:
            do while true:
                hquery:get-next.          
                if not hBeforebuff:avail then 
                    leave.
                    
                phBuffer:find-by-rowid (hBeforeBuff:after-rowid).
                
                if phBuffer:row-state = row-deleted then 
                    undo, throw new IllegalArgumentError("Partitions with state 'deleted' passed to data source.").
                
                /* Note we do not really support create, but as of current 
                   partitions may be marked as created in some cases on client
                   (when the parent tenant or group is new). 
                   In which case we use Name to find group or tenant - 
                   since create is called after parent rename has taken place 
                   (piState = ? potentially saved from some other object than 
                    tenant or tenantgroup? in whihc case parent rename is not 
                    applicable) */   
                if piState = row-created or piState = ? then 
                do: 
                    if phBuffer::Tenantname > "" then
                    do:  
                       find btenant where btenant._tenant-name = phBuffer::Tenantname no-lock. 
                       assign cType = "T"
                              cName = btenant._tenant-name. 
                    end.
                    else if phBuffer::TenantGroupName > "" then
                    do:
                       find  dictdb._Partition-Set where dictdb._Partition-Set._Pset-Name = phBuffer::TenantGroupName no-lock. 
                       assign cType = "G"
                              cName = dictdb._Partition-Set._PSet-name. 
                    end.
                    else 
                        undo, throw new IllegalArgumentError("Non multi-tenant partitions cannot be modified.").
                end.
                /* if modified use the id - If the tenant name is modified 
                   it is already corrected in the partition TT, but the parent is 
                   updated after its children so it is not reflected in the DB  */
                else if piState = row-modified then
                do:
                    if phBuffer::Tenantname > "" then
                    do:  
                       find btenant where btenant._tenantid = phBuffer::ParentId no-lock. 
                       assign cType = "T"
                              cName = btenant._tenant-name. 
                    end.
                    else if phBuffer::TenantGroupName > "" then
                    do:                       
                      /* The first call to DatabaseInfo may call the constructor which
                         has a find that will give error 7254 */
                       dbRecid = DatabaseInfo:DatabaseRecid. 
                       find dictdb._file where dictdb._file._db-recid = dbRecid
                                         and   dictdb._file._file-name = phBuffer::TableName 
                                         and   dictdb._file._owner = phBuffer::SchemaName no-lock. 
                  
                  
                       find dictdb._Partition-Set where dictdb._Partition-Set._PsetId = phBuffer::ParentId 
                                                    and dictdb._Partition-Set._Object-type = 1
                                                    and dictdb._Partition-Set._Object-number = dictdb._file._file-number   
                                                      no-lock. 
                       assign cType = "G"
                              cName = dictdb._Partition-Set._PSet-name. 
                    end.
                end. 
                
                /* @TODO replace with check on returned Storage when OE00221047 is fixed  */    
                if cType = "T" then 
                do:
                    dbRecid = DatabaseInfo:DatabaseRecid. 
                    find dictdb._file where dictdb._file._db-recid = dbRecid
                                        and   dictdb._file._file-name = phBuffer::TableName 
                                        and   dictdb._file._owner = phBuffer::SchemaName no-lock. 
                     
                    if can-find(dictdb._Partition-Set-Detail 
                                 where dictdb._Partition-Set-Detail._tenantid = btenant._tenantid
                                   and dictdb._Partition-Set-Detail._Object-type = 1
                                   and dictdb._Partition-Set-Detail._Object-number = dictdb._file._file-number) then
                    do: 
                        undo, throw new DataAccessError(GetName(phBuffer) + " does not exist. The " + quoter(phBuffer::TableName) + " table is in a group for this tenant.").
                    end.
                end.
                      
                if phBuffer::ObjectType = "table" then 
                    partition = DBConfig:GetTable(phBuffer::TableName,cName,cType) .
                else if phBuffer::ObjectType = "index" then 
                    partition = DBConfig:GetIndex(phBuffer::TableName,phBuffer::IndexName,cName,cType) .
                else if phBuffer::ObjectType = "field" then 
                    partition = DBConfig:GetLob(phBuffer::TableName,phBuffer::FieldName,cName,cType) .
    
                if phBuffer::Areaname <> hBeforeBuff::Areaname then 
                do:
                    if phBuffer::Areaname > "" then
                    do:
                        find barea where barea._area-name = phBuffer::Areaname no-lock no-error.
                        if not avail barea then
                        do:
                            undo, throw new DataAccessError(GetName(phBuffer) + " has invalid Area " + quoter(phBuffer::Areaname) + ".", ?). 
                        end.
                         
                        if partition:AllocationArea <> phBuffer::Areaname then
                        do:
                            partition:AllocationArea = phBuffer::Areaname.
                        end.
                    end.    
                    else do:
                        if partition:AllocationArea > "" then
                            undo, throw new DataAccessError("Cannot change " + GetName(phBuffer) + " to have no Area.", ?). 
                    end.    
                end.
                
                /* this must be done after area since setting it to allocated will prevent 
                   area from being changed 
                   AllocationState is read only for   */              
                if phBuffer::ObjectType = "Table" 
                and phBuffer::AllocationState <> hBeforeBuff::AllocationState
                and phBuffer::AllocationState <> partition:AllocationState  then
                do:                                         
                    if lookup(phBuffer::AllocationState,ValidAllocationList) = 0 then
                       undo, throw new DataAccessError(GetName(phBuffer) + " has invalid AllocationState " + quoter(phBuffer::AllocationState) + ".", ?). 
                
                    if partition:AllocationState = "Allocated" then
                    do:
                        undo, throw new DataAccessError(GetName(phBuffer) 
                               +  " AllocationState cannot be set to " + phBuffer::AllocationState 
                               +  ". " + GetName(phBuffer) + " is already Allocated." ). 
                    end.                                
                    else do:
                        partition:AllocationState = phBuffer::AllocationState. 
                       /** refresh index and fields to be returned to client with allocationstate
                           (table is done last) */      
                        RefreshAllocationState(phBuffer::TableName,phBuffer::AllocationState).                 
                    end. 
                end.

                if phBuffer::BufferPool <> partition:ObjectLevelBufferPool then
                do: 
                    if lookup(phBuffer::BufferPool,"Alternate,Primary") = 0 then
                        undo, throw new DataAccessError(GetName(phBuffer) + " has invalid BufferPool " + quoter(phBuffer::BufferPool) + ".", ?). 
                    partition:ObjectLevelBufferPool = phBuffer::BufferPool.                     
                end.
                
                /* we're not reading partition on save in AfterPartitionRow */
                phBuffer::CanAssignAlternateBufferPool = partition:CanAssignAlternateBufferPool.    
                hdataset = phBuffer:dataset.
                
                AfterPartitionRow(dataset-handle hdataset  by-reference).
               
            end.
            
            catch e2 as DataAccessError:
                undo, throw e2.            		
            end catch.
            
            catch e as Progress.Lang.Error :
                undo, throw new DataAccessError(
                    new DataMapper("Tenant,bTenant,Partition Group,_Partition-Set,Table,bFile,Area,barea,Area,b_indexarea,Area,b_fieldarea",
                    FieldMapping), e). 
            end catch.
        end. /* transaction (most likely sub-trans ) */      
        finally:
           delete object hQuery no-error. 
           DeleteRefreshQuery().
           mSaving = false. 		
        end finally. 
    end method.      
    
    /** called from save to refresh index and fields to be returned to client when 
        allocationstate of the table changed  (they are updated before the table partitions ) */      
    method private void RefreshAllocationState(pcTable as char,pcState as char):
        define variable hbuffer as handle no-undo.
        hBuffer = mRefreshQuery:get-buffer-handle (1).  
        mRefreshQuery:query-prepare("for each ttPartition where ttPartition.TableName = " 
                                     + quoter(pcTable) 
                                     + " and ttPartition.ObjectType <> 'Table'").
        mRefreshQuery:query-open().
        mRefreshQuery:get-first.
        do while hBuffer:avail:
            hBuffer::AllocationState = pcState.
            mRefreshQuery:get-next.
        end.    
    end method.
    
    method private void DeleteRefreshQuery():
        define variable hbuffer as handle no-undo.
        hBuffer = mRefreshQuery:get-buffer-handle (1).  
        delete object hBuffer no-error.
        delete object mRefreshQuery.
    end method.
    
    method private void CreateRefreshQuery(pbufferHandle as handle):
        define variable hbuffer as handle no-undo.
        create query mRefreshQuery.
        create buffer hBuffer for table pbufferHandle.    
        mRefreshQuery:add-buffer(hBuffer).
    end method.
  
    /**** the utility command cannot be run with active transactions 
    method private void DeallocatePartition(pcTable as char,pctype as char, pcKey as char ):
        define variable msg as DeallocateRequest no-undo.
        msg = new DeallocateRequest(). 
        msg:Type = if pctype = "T" then  "tenant"
                   else   "group".
                    
        msg:Name = pcKey.
        msg:TableName = pctable. 
        DeallocateCommand:Execute(msg). 
    end method.   
    ************/
   
    method public void AfterPartitionRow(dataset-handle hds):
        define buffer bTenant for dictdb._tenant.
        define buffer bArea for dictdb._area.      
        
        define variable hbuffer as handle    no-undo.
        define variable iSource as integer no-undo.
        define variable hStorage as handle no-undo.
        define variable partition   as Storage no-undo.
        define variable cType as character no-undo.
        define variable cName as character no-undo.
        define variable lNotMT as logical no-undo.             
        define variable iState as integer no-undo.
        define variable dbRecid as recid no-undo.
        hBuffer = hds:get-buffer-handle("ttPartition") .
        DBConfig:LockWait = FALSE.
         
        if not mSaving then
        do:
            iSource = lookup("_StorageObject",Tables).
            hStorage = DataSourceHandle:get-source-buffer(iSource).
          
             /* this case is likely eliminated? */
            if hBuffer::TableName = "" then
            do:
                if hStorage::_object-type = 1 then
                    find dictdb._file where dictdb._file._file-number = hStorage::_object-number no-lock.
                
                else if hStorage::_object-type = 2 then
                do:
                    find dictdb._Index where dictdb._Index._idx-num = hStorage::_object-number no-lock.
                    find dictdb._file of _index no-lock.
                    hBuffer::IndexName = dictdb._Index._index-name.
                end.
                else if hStorage::_object-type = 3 then
                do:
                    /* NO INDEX on _field._Fld-stlen ! 
                       use association object and find _file and then _field of _file */
                    find dictdb._file where dictdb._file._file-number = hStorage::_Object-associate no-lock. 
                    find dictdb._field of dictdb._file where dictdb._field._Fld-stlen = hStorage::_object-number no-lock.
                     
                    hBuffer::FieldName = dictdb._field._field-name.
                end.
                hBuffer::TableName = dictdb._file._file-name. 
                hBuffer::SchemaName = dictdb._file._owner.
            end.        
                          
            if hBuffer::IndexName <> "" then
            do:
                hBuffer::ObjectType = "Index".   
                /* 11.?.?
                if hStorage::_collationid > 0 then 
                do:
                    find dictdb._collation where dictdb._collation._coll-Sequence = hStorage::_collationid no-error.
                    if avail dictdb._collation then
                        hBuffer::Collation =  dictdb._collation._Coll-Name. 
                end.
                */
            end.
            else if hBuffer::FieldName <> "" then
                hBuffer::ObjectType = "Field".   
            else
                hBuffer::ObjectType = "Table".   
            
            if hStorage::_partitionid >= 0  then
            do:
                if hStorage::_partitionid = 0 then
                do:
                    /* The first call to DatabaseInfo may call the constructor which
                       has a find that will give error 7254 */
                    dbRecid = DatabaseInfo:DatabaseRecid.
                    find dictdb._file where dictdb._file._db-recid = dbRecid
                                      and   dictdb._file._file-name = hBuffer::TableName 
                                      and   dictdb._file._owner = hBuffer::SchemaName no-lock. 
                    lNotMT = dictdb._file._file-attributes[1] = false.
                end.
                /* if the table is shared we do not consider it belonging to the default tenant. */
                if lNotMt = false then
                do:
                    if (hBuffer::TenantName = "" or hBuffer::TenantName = ?) then
                    do:
                        find btenant where btenant._tenantid = hStorage::_partitionid no-lock. 
                        hBuffer::TenantName = btenant._tenant-name.
                        hBuffer::TenantId   = btenant._tenantid.
                        hBuffer::TenantGroupName = ?.  /* avoid unique index error */
                    end.
                    cType = "T".
                    cName = hBuffer::TenantName.
                end.             
            end. 
            else if hStorage::_partitionid < 0 then
            do:
                if (hBuffer::TenantGroupName = "" or hBuffer::TenantGroupName = ?) and hStorage::_partitionid < 0 then
                do:
                    /* The first call to DatabaseInfo may call the constructor which
                       has a find that will give error 7254 */
                    dbRecid = DatabaseInfo:DatabaseRecid.
                    find dictdb._file where dictdb._file._db-recid = dbRecid 
                                      and   dictdb._file._file-name = hBuffer::TableName 
                                      and   dictdb._file._owner = hBuffer::SchemaName no-lock. 
                     
                    find dictdb._Partition-Set where dictdb._Partition-Set._Object-type = 1 
                                               and   dictdb._Partition-Set._Object-Number = dictdb._file._File-number 
                                               and   dictdb._Partition-Set._PSetId = hStorage::_partitionid no-lock. 
                    hBuffer::TenantGroupName = dictdb._Partition-Set._PSet-name. 
                    hBuffer::TenantGroupId  = dictdb._Partition-Set._PSetid. 
                    
                    hBuffer::TenantName = ?.  /* avoid unique index error */
                end.
                cType = "G".
                cName = hBuffer::TenantGroupName.
            end.
            
            if lNotMT then
            do:             
                if hBuffer::ObjectType = "table" then 
                    partition = DBConfig:GetTable(hBuffer::TableName) .
                
                else if hBuffer::ObjectType = "index" then 
                    partition = DBConfig:GetIndex(hBuffer::TableName,hBuffer::IndexName).
                else if hBuffer::ObjectType = "field" then 
                    partition = DBConfig:GetLob(hBuffer::TableName,hBuffer::FieldName).
                
                /*
                hBuffer::AllocationState = partition:AllocationState.
                hBuffer::AreaName = partition:AllocationArea.
                */
                
                if hStorage::_area-number <> 0 then
                do:
                    find barea where barea._area-number = hStorage::_area-number no-lock.
                    hBuffer::Areaname = barea._Area-name.
                    hBuffer::AllocationState = "Allocated".                             
                end.   
                else /* this is not possible - all non MT tables have an area */
                    hBuffer::AllocationState = "None".                             
                
                hBuffer::BufferPool = partition:ObjectLevelBufferPool.  
                hBuffer::CanAssignAlternateBufferPool = partition:CanAssignAlternateBufferPool.
                
                delete object partition no-error.
            end.
            else  
            do:
                
                if hBuffer::ObjectType = "table" then 
                    partition = DBConfig:GetTable(hBuffer::TableName,cName,cType) .
                else if hBuffer::ObjectType = "index" then 
                    partition = DBConfig:GetIndex(hBuffer::TableName,hBuffer::IndexName,cName,cType) .
                else if hBuffer::ObjectType = "field" then 
                    partition = DBConfig:GetLob(hBuffer::TableName,hBuffer::FieldName,cName,cType) .
                 
                hBuffer::AllocationState = partition:AllocationState.
                hBuffer::BufferPool = partition:ObjectLevelBufferPool.  
                hBuffer::AreaName = partition:AllocationArea.
                hBuffer::CanAssignAlternateBufferPool = partition:CanAssignAlternateBufferPool.
                delete object partition no-error.  
            end.
        end. /* not msaving */
        
        if hBuffer::AreaName > "" then
            hBuffer::AreaUrl    = AreaURL + WebUtil:UrlEncode(hBuffer::AreaName).
        
        if hBuffer::TenantName > "" then
        do:
            hBuffer::TenantUrl  = TenantURL + WebUtil:UrlEncode(hBuffer::TenantName).
            if  hBuffer::ObjectType = "table" 
            and hBuffer::AllocationState = "Allocated" then
                hBuffer::DeallocateUrl = hBuffer::TenantUrl + "/partitions/" + WebUtil:UrlEncode(hBuffer::TableName) + "/deallocate".
        end.
        if hBuffer::TenantGroupName > "" then
            hBuffer::TenantGroupUrl  = GroupUrl + WebUtil:UrlEncode(hBuffer::TenantGroupName).
        /* NOTE - this needs to be deprecated, rowids are reused when partions are moved to 
           group - but carefully as runtime fill in theory could depend on it */          
        hBuffer::trowid = ? .
   
        catch e as Progress.Lang.Error :
            undo, throw new DataAccessError(e:getmessage(1),?). 
        end catch.
       
    end method. 
    
    method protected override character FindTableJoinValues(pTable as char,pFind as char):
        case pTable:
            when "_tenant" then
                return FindTenantJoin(pFind).
            when "_Partition-Set" then
                return FindTenantGroupJoin(pFind).    
            when "_area" then
                return FindAreaJoin(pFind).
/*            when "ttObjectType" then         */
/*                return FindObjectType(pFind).*/
        end case.
    end method.
    
       /* throw standard progress error if non found */
    method private character FindTenantJoin(pFind as char):
        buffer dictdb._tenant:find-unique(pFind).
        return "_StorageObject._PartitionId = " + quoter(dictdb._Tenant._Tenantid).
    end method.
    
    /* throw standard progress error if non found */
    method private character FindTenantGroupJoin(pFind as char):
        buffer dictdb._Partition-Set:find-unique(pFind).
        return "_StorageObject._PartitionId = " + quoter(dictdb._Partition-Set._PSetId).
    end method.
   
    /* throw standard progress error if non found */
    method private character FindAreaJoin(pFind as char):
        buffer dictdb._area:find-unique(pFind).
        return "_StorageObject._Area-number = " + quoter(dictdb._Area._Area-number).
    end method. 
    
    /* convert allocationstate char to bitmap expression required in the db */
    method public override character ColumnExpression(pcColumn as char,pcOperator as char,pcValue as char):
        define variable cField as character no-undo
             init "get-bits(_StorageObject._Object-State,2,2)". 
        
             
        if pccolumn = "_StorageObject.AllocationState" then
        do:
           if lookup(pcOperator,"EQ,=,NE,<>") = 0 then
               undo, throw new IllegalArgumentError("Invalid Partition query expression: " + quoter('AllocationState ' + pcOperator + ' ' + quoter(pcValue,"'") + ' ')).
        
            case pcValue:
                when "Delayed" then
                    pcValue = "2".
                when "None" then
                    pcValue = "1".
                when "Allocated" then
                    pcValue = "0".
                otherwise
                    undo, throw new IllegalArgumentError("Invalid AllocationState in query: " + quoter(pcValue)).
            end.            
            return "(" + cfield + " " + pcOperator + " " + pcValue + ")".
        end.        
        return ?.   
    end. 
    
    /* convert allocation to bitmap in the db */
    method public override character ColumnSortSource(pcColumn as char):
        if pcColumn = "_StorageObject.AllocationState" then
        do:
            return   "(if get-bits(_StorageObject._Object-State,2,2) = 0 then 'Allocated'" 
                   + " else if get-bits(_StorageObject._Object-State,2,2) = 1 then 'None'"
                   + " else 'Delayed')". 
        end.  
        return super:ColumnSortSource(pcColumn).  
    end method. 
    
    /* This is the call back for the QueryString parsing. There is currently no mapping, but we override it in 
       order to return the ttPartition's parent keys to the Query. This allows us to extract the expression later.
       Because it is added as parent (i.e _tenant) we can also extract the actual query fields without these.        
       
       NOTE: check subclasses override 
   
    */
    method public override character ColumnSource (pcColumn as char):
        if pcColumn = "ttPartition.AreaNumber" then
            return "_StorageObject._Area-Number".
       
        /* assign the table - deal with state expression in ColumnExpression */
        if pcColumn = "ttPartition.AllocationState" then 
        do:
            return "_StorageObject.AllocationState".
        end.
  
        if pcColumn = "ttPartition.TenantName" then 
        do:
            return "_Tenant._Tenant-name".    
        end.
        
        if pcColumn = "ttPartition.TenantGroupName" then 
        do:
            return "_Partition-Set._PSet-name".    
        end.
        
        if pcColumn = "ttPartition.TableName" then 
        do:
            return "_File._file-name".    
        end.
        
        if pcColumn = "ttPartition.IndexName" then 
        do:
            return "_Index._index-name".    
        end.
        
        if pcColumn = "ttPartition.FieldName" then 
        do:
            return "_Field._Field-name".    
        end.
  
        return super:ColumnSource(pcColumn).
   
    end method.  
    
    method private character Getstate(phbuffer as handle):
        return if phbuffer:row-state = row-created then "Created"
               else if phbuffer:row-state = row-modified then "Modified"
               else if phbuffer:row-state = row-deleted then "Deleted" 
               else "unchanged".
    end.    
        
    method private character GetName (phbuffer as handle):
         define variable cName as character no-undo.
         define variable ckey as character no-undo.
         define variable cTenant as character no-undo.
         define variable cGroup as character no-undo.
         ckey = phBuffer::Tablename. 
         cTenant = phbuffer::Tenantname.
         cGroup = phbuffer::TenantGroupName.
         if cTenant = ? or cTenant = "" then
            
         if phbuffer::ObjectType = "field" then
             cKey = cKey + " " + phBuffer::Fieldname.
         else if phbuffer::ObjectType = "index" then
             cKey = cKey + " " + phBuffer::Indexname.  
        
         cName = "Partition for " + phbuffer::ObjectType + " " + quoter(cKey) 
              + if cTenant > "" then " Tenant " + quoter(cTenant)
                else " Group " + quoter(cGroup).
         
         return if cName = ? then "<unknown>" else cName.    
    end method.    
    
    method protected char GetMappingForJoin(pcTables as char):
        return right-trim(
               (if lookup("_tenant",pcTables) <> 0
                then StorageTenantMap + "," 
                else "")
             + (if lookup("_Partition-set",pcTables) <> 0
                then StorageGroupMap + "," 
                else "")
             + (if lookup("_Area",pcTables) <> 0
                then StorageAreaMap + "," 
                else ""),",").         
    end.    
    
    
        
end class.