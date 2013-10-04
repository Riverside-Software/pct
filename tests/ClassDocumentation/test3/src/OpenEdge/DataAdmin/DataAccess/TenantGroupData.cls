 /*************************************************************/
 /* Copyright (c) 2010 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : DomainData
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : Domain-name is case sensitive 
  ----------------------------------------------------------------------*/
 
routine-level on error undo, throw.

using OpenEdge.DataAdmin.DataAccess.DataAccess from propath.
using OpenEdge.DataAdmin.DataAccess.DataAccessError from propath.
using OpenEdge.DataAdmin.DataAccess.IDataAccess from propath.

using OpenEdge.DataAdmin.DataSource.IDataSource from propath.
using OpenEdge.DataAdmin.DataSource.TenantGroupDataSource from propath.
using OpenEdge.DataAdmin.DataSource.TenantGroupMemberDataSource from propath.
using OpenEdge.DataAdmin.DataSource.PartitionDataSource from propath.
using OpenEdge.DataAdmin.DataSource.IndexPartitionDataSource from propath.
using OpenEdge.DataAdmin.DataSource.FieldPartitionDataSource from propath.
using OpenEdge.DataAdmin.DataSource.DatabaseInfo from propath.

using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Message.ITableRequest from propath.


using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

class OpenEdge.DataAdmin.DataAccess.TenantGroupData inherits DataAccess implements IDataAccess : 
        
    define private variable Url as character no-undo.
    
    define public property BaseQuery as character no-undo
        get():
            undo, throw new UnsupportedOperationError("BaseQuery in GroupData").
        end get.     
        set.

    /** @todo remove and use dataaccess dynamic new ?
        NOTE: As of current not all datasources are prepared to save(buffer,row-state)
              which these need to do, so don't add new ones without fixing them */
    method protected override IDataSource CreateSaveSource(pcName as char):
        case pcName: 
            when "ttTenantGroup" then
                return new TenantGroupDataSource().
            when "ttPartition" then
                return new PartitionDataSource().
            when "ttTenantGroupMember" then
                return new TenantGroupMemberDataSource().
           otherwise 
               return super:CreateSaveSource(pcname).   
        end case.
    end method.
    
     method protected override void SaveBuffers(phDataset as handle):
         define variable datasource as IDataSource no-undo.
         define variable hbuffer    as handle no-undo.
         super:SaveBuffers(phDataset).
         hbuffer = phDataset:get-buffer-handle ("ttTenantGroup").
         if valid-handle(hbuffer) then
         do:
             datasource = GetSaveSource("ttTenantGroup").
             datasource:Refresh(hBuffer).
         end.  
    end method.    
    method protected override void SetUrl(pcUrl as char):
        Url = pcurl.
    end method.       
   
    method public override void FetchData(msg as IFetchRequest):
        define variable hBuffer as handle no-undo.
        define variable hChild as handle no-undo.
        define variable hParent as handle no-undo.
        define variable cQuery as character no-undo.
        define variable cJoin  as character no-undo.
        define variable cBase  as character no-undo.
        define variable i as integer no-undo.
        define variable groupSource as IDataSource no-undo.
        define variable partitionSource as IDataSource no-undo.
        define variable indexPartitionSource as IDataSource no-undo.
        define variable fieldPartitionSource as IDataSource no-undo.
        define variable tenantGroupMemberSource as IDataSource no-undo.
        define variable tableRequest as ITableRequest no-undo.     
        define variable lFillafter as logical no-undo.  
        DatasetHandle = msg:DataHandle.
        Url = msg:Url. 
        do i = 1 to DatasetHandle:num-buffers:
            hBuffer = DatasetHandle:get-buffer-handle(i).
            hbuffer:fill-mode = "no-fill".
        end.     
       
        do i = 1 to DatasetHandle:num-buffers:
            hBuffer = DatasetHandle:get-buffer-handle(i).
            cQuery = "".
            cBase = "".
            if hbuffer:name = "ttTenantGroup" then
            do:
                if not valid-handle(hBuffer:parent-relation) then 
                do:
                    groupSource = new TenantGroupDataSource().
                    groupSource:FillMode = "Replace".
                    groupSource:Url = Url.
                    tableRequest = msg:GetTableRequest("ttTenantGroup").
                
                    if valid-object(tableRequest) then 
                        groupSource:Prepare(hBuffer,tableRequest).         
                    else
                        groupSource:Prepare(hBuffer).            
                    
                
                    DatasetHandle:Fill().
                    if groupSource:NumRecords <> ? then 
                        msg:SetTableTotal("ttTenantGroup",groupSource:NumRecords).
                
                    hbuffer:fill-mode = "no-fill".
                    hParent = hBuffer.
                end.
                else do:
                    if not lfillafter then
                    do:
                       undo, throw new UnsupportedOperationError(
                          "TenantGroupData is not prepared to handle "
                          + substr(hBuffer:parent-relation:parent-buffer:name,3) 
                          + " as parent of " + substr(hBuffer:name,3)).
                    end.
                    hbuffer:fill-mode = "replace".
                end.    
                 
            end.
            else if hbuffer:name = "ttPartition" then
            do:
                hBuffer:parent-relation:active  = false. 
               
                cJoin = "where _StorageObject._object-type = ttTenantGroup.objectType "        
                     + " and _StorageObject._object-number = ttTenantGroup.ObjectNumber "
                     + " and _StorageObject._PartitionId = ttTenantGroup.Id ".
                partitionSource = new PartitionDataSource(hParent,
                                                    "for each ttTenantGroup,"
                                                   + " each _storageObject " + cjoin + " no-lock").
                partitionSource:FillMode = "Append".
                partitionSource:Url = Url.
                partitionSource:Prepare(hBuffer,cQuery,"").
                DatasetHandle:Fill().
                
       
                indexPartitionSource = new IndexPartitionDataSource(hParent,
                             "_file._File-number = ttTenantGroup.ObjectNumber",
                             "_StorageObject._PartitionId = ttTenantGroup.Id"  ).
                indexPartitionSource:FillMode = "Append".
                indexPartitionSource:Url = Url.
                indexPartitionSource:Prepare(hBuffer,cQuery,"").
                DatasetHandle:Fill().
                
                
                fieldPartitionSource = new FieldPartitionDataSource(hParent,
                             "_file._File-number = ttTenantGroup.ObjectNumber",
                             "_StorageObject._PartitionId = ttTenantGroup.Id"  ).
                fieldPartitionSource:FillMode = "Append".
                fieldPartitionSource:Url = Url.
                fieldPartitionSource:Prepare(hBuffer,cQuery,"").
                DatasetHandle:Fill().
                
                
                hbuffer:fill-mode = "no-fill".                                    
            end.
            else if hbuffer:name = "ttTenantGroupMember" then
            do:  
                if valid-handle(hBuffer:parent-relation) then 
                do: 
                    hBuffer:parent-relation:active  = false. 
                   
                    cBase = "for each ttTenantGroup,"
                          + " each _Partition-Set where _Partition-Set._PSet-name = ttTenantGroup.name no-lock,"
                          + " each _Partition-Set-Detail"
                          + " where _Partition-Set-Detail._object-type = ttTenantGroup.objectType "        
                            + " and _Partition-Set-Detail._object-number = ttTenantGroup.ObjectNumber "
                            + " and _Partition-Set-Detail._PSetId = ttTenantGroup.Id no-lock,"
                         + " each _Tenant where _Tenant._Tenantid = _Partition-Set-Detail._Tenantid no-lock".
           
                    tenantGroupMemberSource = new TenantGroupMemberDataSource(hParent,cBase).
                    tenantGroupMemberSource:FillMode = "Append".
                    tenantGroupMemberSource:Url = Url.
                    tenantGroupMemberSource:Prepare(hBuffer,cQuery,"").
                    DatasetHandle:Fill().
                    hbuffer:fill-mode = "no-fill".                                    
                end.
                else do:
                    hChild = DatasetHandle:get-buffer-handle ("ttTenantGroup"). 
                    /* Attach the group so that the detail can benefit from the mapping */                    
                    groupSource = new TenantGroupDataSource().
                    groupSource:FillMode = "Replace".
                    groupSource:Url = Url.
                    groupSource:Prepare(hChild).            
                                                                              /* first and last ...*/
                    tenantGroupMemberSource = new TenantGroupMemberDataSource("_Tenant","_Partition-set").
                    tenantGroupMemberSource:FillMode = "Append".
                    tenantGroupMemberSource:Url = Url.
                    /* the joined query is passed with TenantGroupptable*/
                    tableRequest = msg:GetTableRequest("ttTenantGroup").
                   
                    if valid-object(tableRequest) then 
                        tenantGroupMemberSource:Prepare(hBuffer,tableRequest).         
                    else
                        tenantGroupMemberSource:Prepare(hBuffer).            
                    lfillafter = true.                                                   
                end.              
            end.    
        end.
        if lFillAfter then 
        do:
            
            DatasetHandle:Fill().
            
        end.       
        finally:
            delete object groupSource no-error.		
            delete object partitionSource no-error.     
            delete object indexPartitionSource no-error.     
            delete object fieldPartitionSource no-error.     
            delete object tenantGroupMemberSource no-error.     
        end finally.
            
    end method. 
 
end class.
