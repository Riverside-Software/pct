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
using OpenEdge.DataAdmin.DataAccess.DataAccess from propath.
using OpenEdge.DataAdmin.DataAccess.DataAccessError from propath.
using OpenEdge.DataAdmin.DataAccess.DataMapper from propath.

using OpenEdge.DataAdmin.DataSource.TenantDataSource from propath.

using OpenEdge.DataAdmin.DataSource.UserDataSource from propath.
using OpenEdge.DataAdmin.DataSource.DomainDataSource from propath.
using OpenEdge.DataAdmin.DataSource.PartitionDataSource from propath.
using OpenEdge.DataAdmin.DataSource.TenantGroupMemberDataSource from propath.
using OpenEdge.DataAdmin.DataSource.SequenceValueDataSource from propath.
using OpenEdge.DataAdmin.DataSource.TenantDataSource from propath.
using OpenEdge.DataAdmin.DataSource.IDataSource from propath.

using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Message.ITableRequest from propath.

class OpenEdge.DataAdmin.DataAccess.TenantData inherits DataAccess : 
   
    define buffer b_dataArea  for dictdb._Area.
    define buffer b_indexArea for dictdb._Area.
    define buffer b_LobArea   for dictdb._Area.
    define query qTenant for dictdb._tenant,b_dataArea,b_indexArea,b_LobArea.  
    define data-source dTenant for query qTenant.
    define protected property FieldMap as char no-undo 
        init "Id,_Tenantid,Name,_Tenant-name,Description,_Tenant-Description,ExternalId,_Tenant-Extid,IsDataEnabled,_Tenant-attributes[1],isAllocated,_Tenant-attributes[2],DefaultAllocation,_Tenant-Allocation-default,DefaultDataAreaName,b_dataarea._Area-name,DefaultIndexAreaName,b_indexarea._Area-name,DefaultLobAreaName,b_lobarea._Area-name"
        get.
    
    define private variable RequestURL      as character no-undo. 
    define private variable TenantURL      as character no-undo.
    define private variable areaURL  as character no-undo.
    define private variable areasURL as character no-undo.
    
        
    /* temporary  */
    define public property BaseQuery as character no-undo
        get():
            return "for each _Tenant no-lock," 
                +  " each b_dataArea no-lock outer-join where b_dataArea._area-number = _tenant._Tenant-DataArea-default,"
                +  " each b_indexArea no-lock outer-join where b_indexArea._area-number = _tenant._Tenant-IndexArea-default,"
                +  " each b_LobArea no-lock outer-join where b_LobArea._area-number = _tenant._Tenant-LobArea-default".
        end get.     
        set.
    
    /** @todo remove and use dataaccess dynamic new ?
        NOTE: As of current not all datasources are prepared to save(buffer,row-state)
              which these need to do, so don't add new ones without fixing them */
    method protected override IDataSource CreateSaveSource(pcName as char):
        case pcName: 
           when "ttTenant" then
               return New TenantDataSource().
           when "ttDomain" then
               return New DomainDataSource().
           when "ttUser" then
               return new UserDataSource().
           when "ttPartition" then
               return new PartitionDataSource().
           when "ttTenantGroupMember" then
               return new TenantGroupMemberDataSource().
           when "ttSequenceValue" then
               return new SequenceValueDataSource() .
           otherwise 
               return super:CreateSaveSource(pcname).   
        end case.
    end method.
    
    method protected override void SaveBuffers(phDataset as handle):
         define variable datasource as IDataSource no-undo.
         define variable hbuffer    as handle no-undo.
         super:SaveBuffers(phDataset).
         hbuffer = phDataset:get-buffer-handle ("ttTenant").
         if valid-handle(hbuffer) then
         do:
             datasource = GetSaveSource("ttTenant").
             datasource:Refresh(hBuffer).
         end.  
    end method.    
        
    method protected override void SetUrl(pcUrl as char):
        RequestURL = pcUrl.
        Tenanturl =  pcurl + "/tenants/".
        areaURL = pcurl + "/areas/".
        areasURL = pcurl + "/areas".
    end method.
        
    method public override void FetchData(msg as IFetchRequest):
        SetUrl(msg:url).
        DatasetHandle = msg:DataHandle.       
        FillData(msg).
    end method.
    
    method public void FillData(msg as IFetchRequest):
        define variable hBuffer as handle no-undo.
        define variable hTenantBuffer as handle no-undo.
        define variable detailSource as IDataSource no-undo.
        
        define variable tenantSource as IDataSource no-undo.
        define variable tableRequest as ITableRequest no-undo.     
         
        hBuffer = msg:DataHandle:get-buffer-handle ("ttTenantGroupMember").
        if valid-handle(hBuffer) then
        do:
             if valid-handle(hBuffer:parent-relation) then
             do:
             
                 detailSource = new TenantGroupMemberDataSource().
                 detailSource:FillMode = "Replace".
                 detailSource:Url = RequestURL.
                 tableRequest = msg:GetTableRequest("ttTenantGroupMember").
                  
                 if valid-object(tableRequest) then 
                     detailSource:Prepare(hBuffer,tableRequest).         
                 else
                     detailSource:Prepare(hBuffer).            
                 
             end.
             else do:
                 hTenantBuffer = msg:DataHandle:get-buffer-handle ("ttTenant").
                 if valid-handle(hTenantBuffer) then
                 do:
                     /* used to map in detail, so start first */
                     tenantSource = New TenantDataSource().   
                     tenantSource:FillMode = "Replace".
                     tenantSource:Url = RequestURL.
                     /* tenant critera is added to parent detail */
                     tenantSource:Prepare(hTenantBuffer).      
                     detailSource = new TenantGroupMemberDataSource().
                     detailSource:FillMode = "Append".
                     detailSource:Url = RequestURL.
                     
                     /* get tenant critera (join with detail) and add to parent detail */
                     tableRequest = msg:GetTableRequest("ttTenant").
                     
                     if valid-object(tableRequest) then 
                         detailSource:Prepare(hBuffer,tableRequest).         
                     else
                         detailSource:Prepare(hBuffer).            
                 
                 end.
             end.      
        end.
        if not valid-object(tenantSource) then
        do:
            hBuffer = msg:DataHandle:get-buffer-handle ("ttTenant").
            if valid-handle(hBuffer) then
            do:
      
                tenantSource = New TenantDataSource().   
                tenantSource:FillMode = "Replace".
                tenantSource:Url = RequestURL.
                tableRequest = msg:GetTableRequest("ttTenant").
      
                if valid-object(tableRequest) then 
                    tenantSource:Prepare(hBuffer,tableRequest).         
                else
                    tenantSource:Prepare(hBuffer).            
            end.             
        end.
        msg:DataHandle:Fill().
        if tenantSource:NumRecords <> ? then 
            msg:SetTableTotal("ttTenant",tenantSource:NumRecords).
        
        finally: /* no GC - due to callback*/
            delete object detailSource no-error.   
            delete object tenantSource no-error.	     		
        end finally. 
    end method. 
end class.
