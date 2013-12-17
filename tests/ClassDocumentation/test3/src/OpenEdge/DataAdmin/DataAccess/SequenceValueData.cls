 /*************************************************************/
 /* Copyright (c) 2011-2012 by progress Software Corporation  */
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
    Notes       : Domain-name is case sensitive 
  ----------------------------------------------------------------------*/
 
routine-level on error undo, throw.

using OpenEdge.DataAdmin.DataAccess.DataAccess from propath.
using OpenEdge.DataAdmin.DataAccess.DataAccessError from propath.
using OpenEdge.DataAdmin.DataAccess.IDataAccess from propath.
using OpenEdge.DataAdmin.DataSource.SequenceDataSource from propath.
using OpenEdge.DataAdmin.DataSource.TenantDataSource from propath.
using OpenEdge.DataAdmin.DataSource.SequenceValueDataSource from propath.
using OpenEdge.DataAdmin.DataSource.IDataSource from propath.
using OpenEdge.DataAdmin.DataSource.UserDataSource from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Message.ITableRequest from propath.
using OpenEdge.DataAdmin.Lang.QueryString from propath.
using OpenEdge.DataAdmin.Lang.IQueryMap from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

class OpenEdge.DataAdmin.DataAccess.SequenceValueData inherits DataAccess implements IDataAccess,IQueryMap: 
    
 
    define private variable Url as character no-undo.
    define variable cMsg as character no-undo. 
    define public property BaseQuery as character no-undo
        get.     
        set.
   
    method public override ISaveRequest SaveData(pChanges as ISaveRequest): 
        define variable hBuffer as handle no-undo.
        define variable datasource as IDataSource no-undo.
        do transaction on error undo, throw:
            hBuffer = pChanges:DataHandle:get-buffer-handle ("ttSequenceValue") no-error.
            if valid-handle(hBuffer) then
            do:
/*                DataSource = new SequenceValueDataSource().*/
                dataSource:Url = pChanges:Url.
                dataSource:Save(hBuffer).
            end.
        end.
     
        return pChanges.
    end method.      
 
    method public override void FetchData(msg as IFetchRequest):
        Url = msg:url.
        DatasetHandle = msg:DataHandle.       
        FillData(msg).
    end method.
    
    method public void FillData(msg as IFetchRequest):
        define variable i as integer no-undo.
        define variable hBuffer as handle no-undo.
        define variable hTenantBuffer as handle no-undo.
        define variable hSequenceBuffer as handle no-undo.
        define variable cQuery as character no-undo.
        define variable seqvalDatasource as IDataSource no-undo.
        define variable seqDatasource as SequenceDataSource no-undo.
        define variable tntDatasource as TenantDataSource no-undo.
        define variable tableRequest as ITableRequest no-undo.
        hBuffer = msg:DataHandle:get-buffer-handle ("ttSequenceValue") no-error.
      
        if valid-handle(hBuffer) then
        do:   
            hTenantBuffer =   msg:DataHandle:get-buffer-handle ("ttTenant") no-error.
            if valid-handle(hTenantbuffer) then
            do:          
                cquery = msg:GetTableQuery("ttTenant"). 
                tntDatasource = new TenantDataSource().
                tntDatasource:FillMode = "Append".
                tntDatasource:Prepare(hTenantBuffer, cquery,"").
                seqvalDatasource = new SequenceValueDataSource("tenant",tntDatasource:QueryString).
            end.
            else do:    
                hSequenceBuffer = msg:DataHandle:get-buffer-handle ("ttSequence") no-error.
                seqDatasource = new SequenceDataSource().
                seqDatasource:FillMode = "Append".
                tableRequest = msg:GetTableRequest("ttSequence").
                if valid-object(tableRequest) then 
                    seqDatasource:Prepare(hSequenceBuffer,tableRequest).         
                else
                    seqDatasource:Prepare(hSequenceBuffer).      
                
                seqvalDatasource = new SequenceValueDataSource("sequence",seqDatasource:QueryString).
            end.
            seqvalDatasource:Url = msg:Url.
            seqvalDatasource:FillMode = "Append".
            tableRequest = msg:GetTableRequest("ttSequenceValue").            
            if valid-object(tableRequest) then 
                seqvalDatasource:Prepare(hBuffer,tableRequest).         
            else
                seqvalDatasource:Prepare(hBuffer).      
            
        end.     
        msg:DataHandle:Fill() no-error.
        if error-status:error then 
        do:
           undo, throw new IllegalArgumentError(error-status:get-message(1)). 
        end.
        
        if valid-object(seqvalDatasource:FillError) then    
            undo, throw seqvalDatasource:FillError.   
                                                       
        if seqvalDatasource:NumRecords <> ? then 
            msg:SetTableTotal("ttSequenceValue",seqvalDatasource:NumRecords).
        if valid-object(tntDatasource) and tntDatasource:NumRecords <> ? then 
            msg:SetTableTotal("ttTenant",tntDatasource:NumRecords).
        if valid-object(seqDatasource) and seqDatasource:NumRecords <> ? then 
            msg:SetTableTotal("ttSequence",seqDatasource:NumRecords).
        
        /* is not garbage collected if set-callback is used */
        finally:
            delete object seqDatasource no-error.
            delete object seqvalDatasource no-error.
            delete object tntDatasource no-error.    		
        end finally.
        
    end method.                                                                           
 
        
end class.
