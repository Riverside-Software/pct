/*************************************************************/
/* Copyright (c) 2010-2012 by progress Software Corporation  */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
   File        : PartitionData 
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : hdaniels
   Created     :  
   Notes       : The partitions are indexed from object and not from 
                 tenant or area so we always access through the objects.
              -  If the filter has a unique tenant and/or area expression  
                 these key values are added to the storageobject in the fill query.
              -  If the filter has a non-unique tenant and/or area expression  
                 the buffers with queries are added to the fill query.                  
 ----------------------------------------------------------------------*/
 
routine-level on error undo, throw.

using Progress.Lang.Error from propath.
using Progress.Lang.SysError from propath.
using OpenEdge.DataAdmin.Error.DataError from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.DataAccess.DataAccess from propath.
using OpenEdge.DataAdmin.DataAccess.DataAccessError from propath.
using OpenEdge.DataAdmin.DataAccess.IDataAccess from propath.
using OpenEdge.DataAdmin.DataSource.PartitionDataSource from propath.
using OpenEdge.DataAdmin.DataSource.TenantDataSource from propath.
using OpenEdge.DataAdmin.DataSource.TenantGroupDataSource from propath.
using OpenEdge.DataAdmin.DataSource.AreaDataSource from propath.
using OpenEdge.DataAdmin.DataSource.TablePartitionDataSource from propath.
using OpenEdge.DataAdmin.DataSource.IndexPartitionDataSource from propath.
using OpenEdge.DataAdmin.DataSource.FieldPartitionDataSource from propath.
using OpenEdge.DataAdmin.DataSource.NewTablePartitionDataSource from propath.
using OpenEdge.DataAdmin.DataSource.NewIndexPartitionDataSource from propath.
using OpenEdge.DataAdmin.DataSource.NewFieldPartitionDataSource from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.ITableRequest from propath.
using OpenEdge.DataAdmin.Lang.IQueryMap from propath.
using OpenEdge.DataAdmin.Lang.QueryString from propath.

class OpenEdge.DataAdmin.DataAccess.PartitionData inherits DataAccess implements IDataAccess, IQueryMap: 
    
/*    define buffer b_Area      for dictdb._Area.  */
/*    define buffer b_Tenant    for dictdb._Tenant.*/
/*    define buffer b_LobArea   for dictdb._Area.  */
/*    define buffer b_dataArea  for dictdb._Area.  */
/*    define buffer b_indexArea for dictdb._Area.  */

   define temp-table ttobjecttype no-undo
        field name as char
     /*   field typeno as int  1 2 or 3 .. */
        index idxtype as unique name.
        
    
   define private variable mUrl as character no-undo.    
   
    /*
   define protected property StateEnum as PartitionStateEnum no-undo
       get():
           if not valid-object(StateEnum) then        
              StateEnum = new PartitionStateEnum().
           return StateEnum.
       end.
       private set.
*/
    /*    define query dsextent for dictdb._areaextent,b_Area.*/
    /*    define data-source dsExtent for query dsextent.     */
    define private variable TenantURL as character no-undo.
    define private variable AreaURL   as character no-undo.
    
    define public property BaseQuery as character no-undo
        get.
        set.
    
    method public override ISaveRequest SaveData(pChanges as ISaveRequest): 
         define variable hDs as handle no-undo.
         define variable hBuffer as handle no-undo.
         define variable partitionSource as PartitionDataSource no-undo.
         partitionSource = GetSource(). 
         hds = pChanges:DataHandle.
         do transaction on error undo, throw:
             hBuffer = hDs:get-buffer-handle("ttPartition").
             partitionSource:Save(hBuffer).
         end.
         return pChanges.     
    end method.   
    
    method private PartitionDataSource GetSource():
        define variable partitionSource as PartitionDataSource no-undo.
        partitionSource = new  PartitionDataSource( ).
        partitionSource:Url = mUrl.
        return partitionsource.
    end.
    
    method private TablePartitionDataSource GetTableSource():
        define variable partitionSource as TablePartitionDataSource no-undo.
        partitionSource = new  TablePartitionDataSource().
        partitionSource:Url = mUrl.
        return partitionsource.
    end.
    
     method private PartitionDataSource GetTableJoinSource(pcJoinTables as char, pcJoinPhysTables as char,pcJoinQueries as char ):
        define variable partitionSource as PartitionDataSource no-undo.
        partitionSource = new TablePartitionDataSource(pcJoinTables,pcJoinPhysTables,pcJoinQueries).
        partitionSource:Url = mUrl.
        return partitionsource.
    end.
    
    method private PartitionDataSource GetIndexJoinSource(pcJoinTables as char, pcJoinPhysTables as char,pcJoinQueries as char ):
        define variable partitionSource as PartitionDataSource no-undo.
        partitionSource = new IndexPartitionDataSource(pcJoinTables,pcJoinPhysTables,pcJoinQueries).
        partitionSource:Url = mUrl.
        return partitionsource.
    end.
    
    method private PartitionDataSource GetFieldJoinSource(pcJoinTables as char, pcJoinPhysTables as char,pcJoinQueries as char ):
        define variable partitionSource as PartitionDataSource no-undo.
        partitionSource = new FieldPartitionDataSource(pcJoinTables,pcJoinPhysTables,pcJoinQueries).
        partitionSource:Url = mUrl.
        return partitionsource.
    end.
    
    method private PartitionDataSource GetNewTableSource():
        define variable partitionSource as PartitionDataSource no-undo.
        partitionSource = new  NewTablePartitionDataSource().
        partitionSource:Url = mUrl.
        return partitionsource.
    end.
       
    method private IndexPartitionDataSource GetIndexSource():
        define variable partitionSource as IndexPartitionDataSource no-undo.
        partitionSource = new  IndexPartitionDataSource().
        partitionSource:Url = mUrl.
        return partitionsource.
    end.
    
    method private PartitionDataSource GetNewIndexSource():
        define variable partitionSource as PartitionDataSource no-undo.
        partitionSource = new  NewIndexPartitionDataSource().
        partitionSource:Url = mUrl.
        return partitionsource.
    end.
    
    method private FieldPartitionDataSource GetFieldSource():
        define variable partitionSource as FieldPartitionDataSource no-undo.
        partitionSource = new  FieldPartitionDataSource().
        partitionSource:Url = mUrl.
        return partitionsource.
    end.
    
    method private PartitionDataSource GetNewFieldSource():
        define variable partitionSource as PartitionDataSource no-undo.
        partitionSource = new  NewFieldPartitionDataSource().
        partitionSource:Url = mUrl.
        return partitionsource.
    end.
    
     
    method protected override void SetUrl(pcUrl as char):
        if pcUrl > "" then
            mUrl = pcUrl.
        TenantUrl =  pcurl + "/tenants/".
        AreaURL = pcurl + "/areas/".
    end method.
    
    method public override void FetchData(msg as IFetchRequest):
        SetUrl(msg:Url).
        DatasetHandle = msg:DataHandle. 
        FillData(msg).
    end method.
    
    method protected void FillData(pMsg as IFetchRequest):
        define variable hBuffer as handle no-undo.  
        hBuffer = DatasetHandle:get-buffer-handle("ttPartitionIdRequest").
        if valid-handle(hBuffer) then
            FillPartitionIdRequest(hBuffer,pMsg). 
        else do:               
            hBuffer = DatasetHandle:get-buffer-handle("ttTablePartitionRequest").
            if valid-handle(hBuffer) then
                FillTablePartitionRequest(hBuffer).
            else do: 
                hBuffer = DatasetHandle:get-buffer-handle("ttGroupNameRequest").
                if valid-handle(hBuffer) then
                    FillGroupNameRequest(hBuffer).
                else 
                    FillPartitions(pmsg).
            end.
        end.        
    end method. 
     
    method private void FillPartitions(pMsg as IFetchRequest): 
        define variable hBuffer as handle  no-undo. 
        define variable lok     as logical no-undo .
        define variable lindexsearch     as logical no-undo .
        define variable lfieldsearch as logical no-undo .
        define variable lfileonly as logical no-undo .
        define variable queryStr     as QueryString no-undo.
        define variable cObjectType  as character no-undo .
        define variable tblPartitionSource as PartitionDataSource no-undo.
        define variable idxPartitionSource as PartitionDataSource no-undo.
        define variable fldPartitionSource as PartitionDataSource no-undo.
        define variable filter as character no-undo.
        define variable lSimulation as logical no-undo.
        define variable tableRequest as ITableRequest no-undo.
        define variable iRecords as integer no-undo.
        
        define variable hTenant     as handle no-undo.
        define variable hArea       as handle no-undo.
        define variable hGroup      as handle no-undo.
        define variable tntSource   as TenantDataSource no-undo. 
        define variable grpSource   as TenantGroupDataSource no-undo. 
        define variable areaSource  as AreaDataSource no-undo. 
        define variable cJoinTables as character no-undo. 
        define variable cJoinPhysicalTables as character no-undo. 
        define variable cJoinQueries as character no-undo. 
        define variable cQmode       as character no-undo.
        define variable lJoin        as logical no-undo.
        
        tableRequest = pMsg:GetTableRequest("ttPartition").
        if not valid-object(tableRequest) then 
            undo , throw new IllegalArgumentError("The request message does not have a partition table").
        filter = tableRequest:QueryString.
        /* RequestTyp NEW is special case for new tenant or group */
        lSimulation = pmsg:GetTableRequestType("ttPartition") = "NEW". 
        hBuffer = DatasetHandle:get-buffer-handle("ttPartition").
        hBuffer:fill-mode = "merge".
         
        /*   check for index and field  
         Note that ObjectType = "Table" is for table only 
         while TableName is applied to both indexes, tables and fields 
        */ 
        if filter > "" then
        do:
            queryStr = new QueryString(filter,this-object).
            cObjectType = CheckQueryObjectType(queryStr). 
            case cObjectType: 
                when ? then
                    undo, throw new IllegalArgumentError("Ambiguous or invalid ObjectType expression in partition request:" + quoter(filter) + ".").
                when "Table" then
                    lfileonly = true.
                when "Index" then 
                    lindexsearch = true.
                when "Field" then 
                    lfieldsearch = true.
                when "" then
                do:                                                                                          
                    lindexsearch = CheckQuery(queryStr,"_index").
                    lfieldsearch = CheckQuery(queryStr,"_field").
                end.
            end.
            
            hTenant = pmsg:DataHandle:get-buffer-handle ("ttTenant").
            if valid-handle(hTenant) then
            do:
                tntSource = new TenantDataSource().
                tntSource:FillMode = "Replace".
                /* the partition source will add query on tenant  */
                tntSource:Prepare(hTenant,"","").
                assign
                    cJoinTables = entry(1,tntSource:tables)
                    cJoinPhysicalTables = entry(1,tntSource:PhysicalTables)
                    cJoinQueries = trim(entry(1,tntSource:BaseQuery)) 
                    /* remove for or preselect */
                    cQmode = entry(1,cJoinQueries," ")      
                    cJoinQueries = left-trim(substr(cJoinQueries,length(cQmode) + 1))
                    lJoin = true. 
            end.
            
            hGroup = pmsg:DataHandle:get-buffer-handle ("ttTenantGroup").
            if valid-handle(hGroup) then
            do:
                grpSource = new TenantGroupDataSource().
                grpSource:FillMode = "Replace".
                /* the partition source will add query on tenantgroup  */
                grpSource:Prepare(hGroup,"","").
                assign
                    cJoinTables = (if lJoin then cJoinTables + "," else "")
                                + entry(1,grpSource:tables)
                    cJoinPhysicalTables = (if lJoin then cJoinPhysicalTables + "," else "")
                                        + entry(1,grpSource:PhysicalTables)
                    cJoinQueries = (if lJoin then cJoinQueries + ", " else "")
                                 +  trim(entry(1,grpSource:BaseQuery)) 
                    /* remove for or preselect */
                    cQmode = entry(1,cJoinQueries," ")      
                    cJoinQueries = left-trim(substr(cJoinQueries,length(cQmode) + 1))
                    lJoin = true. 
            end.
            
            hArea = pmsg:DataHandle:get-buffer-handle ("ttArea").
            if valid-handle(hArea) then
            do:
                areaSource = new AreaDataSource().
                areaSource:FillMode = "Replace".
                /* the partition source will add query on area  */
                areaSource:Prepare(hArea,"","").
                assign
                    cJoinTables = (if lJoin then cJoinTables + "," else "")
                                + entry(1,areaSource:tables)
                    cJoinPhysicalTables = (if lJoin then cJoinPhysicalTables + "," else "")
                                        + entry(1,areaSource:PhysicalTables)
                    cJoinQueries = (if lJoin then cJoinQueries + ", " else "")
                                 +  trim(entry(1,areaSource:BaseQuery)) 
                    /* remove for or preselect */
                    cQmode = entry(1,cJoinQueries," ")      
                    cJoinQueries = left-trim(substr(cJoinQueries,length(cQmode) + 1))
                    lJoin = true. 
            end.
        end.
        
        if lindexSearch or not lfileOnly then
        do: 
            if not lsimulation then 
            do:
                if lJoin then 
                    idxPartitionSource = GetIndexJoinSource(cJoinTables,cJoinPhysicalTables,cJoinQueries).  
                else 
                    idxPartitionSource = GetIndexSource().  
            end.
            else
                idxPartitionSource = GetNewIndexSource().  
        end.    
        if lFieldSearch or not lfileOnly then
        do: 
            if not lsimulation then 
            do:
                if lJoin then 
                    fldPartitionSource = GetFieldJoinSource(cJoinTables,cJoinPhysicalTables,cJoinQueries).  
                else 
                    fldPartitionSource = GetFieldSource().  
            end.
            else
                fldPartitionSource = GetNewFieldSource().  
        end.    
        
        
        
        /* these can be true also if there is an OR with other tables */
        if lindexsearch or lfieldsearch then
        do:
           if valid-object(tableRequest) and tableRequest:PageSize > 0 then
               undo, throw new UnsupportedoperationError("Batching is only supported for table partion requests.").  
          
           /* this is somewhat restrictive, but it difficult to 
              decide what a "tablename begins 'a' or fieldname begins 'a'" 
              requestwould mean since the file and index are children 
              of table... Partitions are either for index, lob or table
               */
           if lindexsearch and lfieldsearch then
               undo, throw new UnsupportedOperationError("PartitionData filter request on both indexes and fields."). 
           
           if lindexsearch then
               FillIndexPartitions(idxPartitionSource,hbuffer,filter,lsimulation).
           if lfieldsearch then
               FillFieldPartitions(fldPartitionsource,hbuffer,filter,lsimulation).
        end.
        else do:
            if not lsimulation then 
            do:
                if lJoin then 
                    tblPartitionSource = GetTableJoinSource(cJoinTables,cJoinPhysicalTables,cJoinQueries).  
                else 
                    tblPartitionSource = GetTableSource().  
            end.
            else
                tblPartitionSource = GetNewTableSource().  
            
            iRecords = FillTablePartitions(tblPartitionSource,hbuffer,tableRequest,lsimulation).
            
            if iRecords <> ? then
            do: 
                if not lfileonly then
                    undo, throw new UnsupportedoperationError("Batching is only supported for table partion requests.").  
                pMsg:SetTableTotal("ttPartition",iRecords).
            end.
            if not lfileonly then
            do:
                FillIndexPartitions(idxPartitionSource,hbuffer,filter,lsimulation).
                FillFieldPartitions(fldPartitionsource,hbuffer,filter,lsimulation).
            end.
        end.
        finally:
            delete object tblPartitionSource no-error.		
            delete object idxPartitionSource no-error.      
            delete object fldPartitionSource no-error.      
            delete object tntSource no-error.
            delete object grpSource no-error.
            delete object areaSource no-error.
        end finally.
    end method.
     
    method private void FillPartitionIdRequest(phPartitionIdBuffer as handle,pMsg as IFetchRequest): 
        define variable partitionSource as PartitionDataSource no-undo.
        define variable hBuffer as handle no-undo.
        define variable filter as char no-undo.
        define variable tableRequest as ITableRequest no-undo.
        
        tableRequest = pMsg:GetTableRequest("ttPartition").
        if not valid-object(tableRequest) then 
            undo , throw new IllegalArgumentError("The request message does not have a partition table").
        
        filter = tableRequest:QueryString.
        
        partitionSource = new  PartitionDataSource(phPartitionIdBuffer,
                              "for each ttPartitionIdRequest, "
                            + " each _StorageObject where _StorageObject._PartitionId = ttPartitionIdRequest.PartitionId no-lock" ).
        partitionSource:Url = mUrl.
        phPartitionIdBuffer:fill-mode = "no-fill".
        hBuffer = DatasetHandle:get-buffer-handle("ttPartition").
        partitionSource:FillMode = "Append".
        partitionSource:Prepare(hBuffer,filter,""). 
        DatasetHandle:Fill().     
        /* is not garbage collected if set-callback is used */
        delete object partitionSource.
    end method.
    
    method private void FillTablePartitionRequest(phTableRequestBuffer as handle): 
        define variable hBuffer as handle no-undo.
        define variable cJoin   as character no-undo.
        define variable partitionSource as PartitionDataSource no-undo.
        
        phTableRequestBuffer:fill-mode = "no-fill".
        hBuffer = DatasetHandle:get-buffer-handle("ttPartition"). 
        cJoin = "_file._file-name = ttTablePartitionRequest.TableName".
        
        partitionSource = new TablePartitionDataSource(phTableRequestBuffer,cjoin).
        partitionSource:FillMode = "Append".
        partitionSource:Url = mUrl.
        partitionSource:Prepare(hBuffer,"","").
        DatasetHandle:Fill().
        /* is not garbage collected if set-callback is used */
        delete object partitionSource.
    
        partitionSource = new IndexPartitionDataSource(phTableRequestBuffer,cjoin). 
        partitionSource:FillMode = "Append".
        partitionSource:Url = mUrl.
        partitionSource:Prepare(hBuffer,"","").
        DatasetHandle:Fill().
         /* is not garbage collected if set-callback is used */
        delete object partitionSource.
        
        partitionSource = new FieldPartitionDataSource(phTableRequestBuffer,cjoin).
        partitionSource:FillMode = "Append".
        partitionSource:Url = mUrl.
        partitionSource:Prepare(hBuffer,"","").
        DatasetHandle:Fill().
         /* is not garbage collected if set-callback is used */
        delete object partitionSource.
   
        /* @TODO seems wrong ?? */     
        hbuffer:fill-mode = "no-fill".          
    end method.
           
    method private void FillGroupNameRequest(phBuffer as handle): 
        define variable hBuffer as handle no-undo.
        define variable cJoin   as character no-undo.
        define variable partitionSource as PartitionDataSource no-undo.
        
        phBuffer:fill-mode = "no-fill".
        
        hBuffer = DatasetHandle:get-buffer-handle("ttPartition"). 
        cJoin = "where _StorageObject._object-type = ttGroupNameRequest.objectType "        
             + " and _StorageObject._object-number = ttGroupNameRequest.ObjectNumber "
             + " and _StorageObject._PartitionId = ttGroupNameRequest.Id ".
        partitionSource = new PartitionDataSource(phBuffer,
                                            "for each ttGroupNameRequest, each _storageObject " + cjoin + " no-lock").
        partitionSource:FillMode = "Append".
        partitionSource:Url = mUrl.
        partitionSource:Prepare(hBuffer,"","").
        DatasetHandle:Fill().
        /* is not garbage collected if set-callback is used */
            delete object partitionSource.
   
            partitionSource = new IndexPartitionDataSource(phBuffer,
                         "_file._File-number = ttGroupNameRequest.ObjectNumber",
                     "_StorageObject._PartitionId = ttGroupNameRequest.Id"  ).
        partitionSource:FillMode = "Append".
        partitionSource:Url = mUrl.
        partitionSource:Prepare(hBuffer,"","").
        DatasetHandle:Fill().
        /* is not garbage collected if set-callback is used */
            delete object partitionSource.
   
            partitionSource = new FieldPartitionDataSource(phBuffer,
                         "_file._File-number = ttGroupNameRequest.ObjectNumber",
                     "_StorageObject._PartitionId = ttGroupNameRequest.Id"  ).
        partitionSource:FillMode = "Append".
        partitionSource:Url = mUrl.
        partitionSource:Prepare(hBuffer,"","").
        DatasetHandle:Fill().
         /* is not garbage collected if set-callback is used */
        delete object partitionSource.
        hbuffer:fill-mode = "no-fill".          
    end method.
    
    /* This is the call back for the QueryString parsing. There is currently no mapping, but we override it in 
       order to return the ttPartition's parent keys to the Query. This allows us to extract the expression later.
       Because it is added as parent (i.e _tenant) we can also extract the actual query fields without these.        
    */
    method public override character ColumnSource (pcColumn as char):
        if pcColumn = "ttPartition.ObjectType" then 
        do:
            /* table index or field */
            return "ttobjecttype.name".    
        end.
        return pccolumn.     
   
    end method.     

   
    /* returns blank if no type reference in query 
               ? if not unique (ambiguous or not found)
                Table, Index or Field   */
    method private character CheckQueryObjectType(pQueryStr as QueryString):
        define variable cTypeQuery as char no-undo.       
        define variable cType        as char no-undo.    
        define variable ipos         as integer no-undo. 
        cTypeQuery = pQueryStr:BuildFindString("ttobjecttype").
        if cTypeQuery > "" then
        do:
            cType = FindObjectType(cTypeQuery).
            if ctype = ? then
                return ?.
            return ctype.
        end.
        return "".

    end method.

    method private logical CheckQuery(pQueryStr as QueryString,pcTable as char):
        define variable cParentQuery as char no-undo.     
        cParentQuery = pQueryStr:BuildParsedQueryString(pcTable).
        return index(cParentQuery," where ") <> 0.
    end.
    
    method private character FindObjectType(pFind as char):
        define variable lok as logical no-undo. 
        if not can-find(first ttObjectType) then
        do:
            create ttobjecttype.
            ttobjecttype.name = "Table".
            create ttobjecttype.
            ttobjecttype.name = "Index".       
            create ttobjecttype.
            ttobjecttype.name = "Field".
        end.       
        lok = buffer ttobjecttype:find-unique(pFind) no-error.
        if lok then  
           return ttobjecttype.name.
        return ?.   
    end method.
    
    method private integer FillTablePartitions(psrc as PartitionDataSource,phBuffer as handle,preq as ITableRequest,plsim as log): 
        define variable lok as logical no-undo.
        psrc:FillMode = "Append".
        if valid-object(preq) then 
            lok = psrc:Prepare(phBuffer,preq).  
        else
            lok = psrc:Prepare(phBuffer,"","").
        if lok then 
        do on error undo, throw:       
            DatasetHandle:Fill() .
            if valid-object(preq) then
                return psrc:NumRecords. 
            return ?.  
            catch e as Progress.Lang.Error :
            	undo, throw new DataAccessError(e).	
            end catch.
        end.
                  
    end method.
      
    method private logical FillIndexPartitions(psrc as PartitionDataSource,phBuffer as handle,filter as char,plsim as log): 
        define variable lok as logical no-undo.
        psrc:FillMode = "Append".
        lok = psrc:Prepare(phBuffer,filter,"").
        if lok then        
        do on error undo, throw:       
            DatasetHandle:Fill().
            catch e as Progress.Lang.Error :
                undo, throw new DataAccessError(e). 
            end catch.
        end.    
        return lok.
    end method.
    
    method private logical FillFieldPartitions(psrc as PartitionDataSource,phBuffer as handle,filter as char,plsim as log): 
        define variable lok as logical no-undo.
        psrc:FillMode = "Append".
        lok = psrc:Prepare(phBuffer,filter,"").
        if lok then        
        do on error undo, throw:       
            DatasetHandle:Fill(). 
            catch e as Progress.Lang.Error :
                undo, throw new DataAccessError(e). 
            end catch.
        end.
        return lok.    
    end method.
 
end class.
