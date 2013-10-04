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
using OpenEdge.DataAdmin.DataAccess.IDataAccess from propath.
using OpenEdge.DataAdmin.DataSource.IDataSource from propath.
using OpenEdge.DataAdmin.DataSource.DomainDataSource from propath.
using OpenEdge.DataAdmin.DataSource.UserDataSource from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Message.ITableRequest from propath.

class OpenEdge.DataAdmin.DataAccess.DomainData inherits DataAccess implements IDataAccess : 
    
 
    define private variable Url as character no-undo.
 
  define public property BaseQuery as character no-undo
        get():
           return "for each b_domain no-lock, each b_tenant no-lock outer-join where b_tenant._tenant-name = b_Domain._tenant-name".
        end get.     
        set.
   
    
    method public override ISaveRequest SaveData(pChanges as ISaveRequest): 
        define variable hDomain as handle no-undo.
        define variable hUser   as handle no-undo. 
        define variable domainSource as IDataSource no-undo.
        define variable userSource as IDataSource no-undo.
         
        do transaction on error undo, throw:
            hDomain = pChanges:DataHandle:get-buffer-handle ("ttDomain") no-error.
            if valid-handle(hdomain) then
            do:
                domainSource = new DomainDataSource().
                domainSource:Url = pChanges:Url.
                domainSource:Save(hDomain).
            end.
            hUser = pChanges:DataHandle:get-buffer-handle ("ttUser") no-error.
            if valid-handle(hUser) then
            do:   
                userSource = new UserDataSource().  
                userSource:Url = Url.
                userSource:Save(hUser).
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
        define variable hBuffer as handle no-undo.
        define variable domainSource as IDataSource no-undo.
        define variable userSource as IDataSource no-undo.
        define variable tableRequest as ITableRequest no-undo.     
         
        hBuffer = msg:DataHandle:get-buffer-handle ("ttDomain") no-error.
        if valid-handle(hBuffer) then
        do:    
            domainSource = new DomainDataSource().
            domainSource:FillMode = "Replace".
            domainSource:Url = Url.
            tableRequest = msg:GetTableRequest("ttDomain").
            if valid-object(tableRequest) then 
                domainSource:Prepare(hBuffer,tableRequest).         
            else
                domainSource:Prepare(hBuffer).           
        end.     
        hBuffer = msg:DataHandle:get-buffer-handle ("ttUser") no-error.
        if valid-handle(hBuffer) then
        do:    
            userSource = new UserDataSource().
            userSource:FillMode = "Replace".
            userSource:Url = Url.
            userSource:Prepare(hBuffer,msg:GetTableQuery("ttUser"),"").          
        end.     
        msg:DataHandle:Fill().
        if valid-object(domainSource) and domainSource:NumRecords <> ? then 
            msg:SetTableTotal("ttDomain",domainSource:NumRecords).
        finally:
            delete object domainSource no-error.		
            delete object userSource no-error.        
        end finally.    
    end method.                                                                           
 
end class.
