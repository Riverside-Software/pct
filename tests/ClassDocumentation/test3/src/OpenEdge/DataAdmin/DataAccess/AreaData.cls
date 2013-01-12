/*************************************************************/
/* Copyright (c) 2010 by progress Software Corporation       */
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

using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Message.ITableRequest from propath.

using OpenEdge.DataAdmin.DataAccess.IDataAccess from propath.
using OpenEdge.DataAdmin.DataAccess.DataAccess  from propath.

using OpenEdge.DataAdmin.DataSource.IDataSource from propath.
using OpenEdge.DataAdmin.DataSource.AreaDataSource from propath.
using OpenEdge.DataAdmin.DataSource.ExtentDataSource from propath.
using OpenEdge.DataAdmin.Lang.QueryString  from propath.
using OpenEdge.DataAdmin.Lang.IQueryMap  from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

class OpenEdge.DataAdmin.DataAccess.AreaData inherits DataAccess implements IDataAccess, IQueryMap: 
     
    define buffer b_Area for dictdb._Area.  
 
    define data-source dArea for dictdb._Area.
    define data-source dExtent for dictdb._AreaExtent.

    define private variable URL     as character no-undo.
     
    define public property BaseQuery as character no-undo
        get():
           return "for each _Area no-lock".
        end get.     
        set.
    
    method protected override void SetUrl(pcurl as character):
        url =  pcurl + "/areas/".
    end method.
            
    method public override void FetchData(pmsg as IFetchRequest):
        FillData(pmsg).
    end method.
    
    method public override ISaveRequest SaveData(pChanges as ISaveRequest): 
        define variable hArea   as handle no-undo.
        define variable hExtent as handle no-undo.
        define variable extentSource as ExtentDataSource no-undo.
        hArea   = pChanges:DataHandle:get-buffer-handle ("ttArea").
        hExtent = pChanges:DataHandle:get-buffer-handle ("ttExtent").
        extentSource = new ExtentDataSource().
        extentSource:Url = URL.
        extentSource:Save(hArea,hExtent).
        return pChanges.
    end method.     
    
    method public void FillData(pmsg as IFetchRequest):
        define variable hBuffer as handle no-undo.
        define variable cQueryString as character no-undo.
        define variable areaSource   as IDataSource no-undo.
        define variable extentSource as IDataSource no-undo.
        define variable tblRequest   as ITableRequest no-undo.
            
        hBuffer = pmsg:DataHandle:get-buffer-handle ("ttArea").
        if valid-handle(hBuffer) then
        do:            
            areaSource = new AreaDataSource().
            tblRequest = pmsg:GetTableRequest("ttArea").
            if valid-object(tblRequest) then
            do: 
                PrepareSource(areaSource,hBuffer,tblRequest,pmsg:url).
            end. 
            else do:
                PrepareSource(areaSource,hBuffer,"",pmsg:url).
            end.    
        end.   
        
        hBuffer = pmsg:DataHandle:get-buffer-handle("ttExtent").          
        if valid-handle(hBuffer) then
        do:
            extentSource = new ExtentDataSource().
            cQueryString = pmsg:GetTableQuery("ttExtent"). 
            PrepareSource(extentSource,hBuffer,cQueryString,pmsg:url).     
        end.   
        pmsg:DataHandle:Fill().
        
        if valid-object(areaSource) and areaSource:NumRecords <> ? then 
            pmsg:SetTableTotal("ttArea",areaSource:NumRecords).
       
        finally:
            delete object areaSource no-error.
            delete object extentSource no-error.		
        end finally.
       
    end method. 
   
        
    method private handle CreateDataSource():
        define variable  h as  handle       no-undo.
        create data-source h.

    end method.
    
    method protected void PrepareSource(ds as IDataSource,phbuffer as handle,pcQuery as char,pcURL as char):     
        ds:FillMode = "Replace".
        ds:Url = pcURL.
        ds:Prepare(phBuffer,pcQuery,"").
    end method.      
    
    method protected void PrepareSource(ds as IDataSource,phBuffer as handle,pReq as ITableRequest,pcURL as char):     
        ds:FillMode = "Replace".
        ds:Url = pcURL.
        ds:Prepare(phBuffer,pReq).
    end method.      
     
end class.
