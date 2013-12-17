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
using OpenEdge.DataAdmin.DataSource.AuthenticationSystemDataSource from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Message.ITableRequest from propath.


class OpenEdge.DataAdmin.DataAccess.AuthenticationSystemData inherits DataAccess implements IDataAccess : 
   
    define private variable Url as character no-undo.
 
    define public property BaseQuery as character no-undo
        get():
           return "".
        end get.     
        set.
    
    method protected override void SetUrl(pcUrl as char):
        Url = pcUrl. 
    end method.
    
     
    method public override void FetchData(msg as IFetchRequest):
        define variable hBuffer as handle no-undo.
        define variable authenticationSystemDataSource as IDataSource no-undo.
        define variable tableRequest as ITableRequest no-undo.
        SetUrl(msg:url).
        DatasetHandle = msg:DataHandle.       
        
        hBuffer = msg:DataHandle:get-buffer-handle ("ttAuthenticationSystem").
        if valid-handle(hBuffer) then
        do:
            authenticationSystemDataSource = new AuthenticationSystemDataSource().
            authenticationSystemDataSource:FillMode = "Replace".
            authenticationSystemDataSource:Url = Url.
            tableRequest= msg:GetTableRequest("ttAuthenticationSystem").
            if valid-object(tableRequest) then 
                authenticationSystemDataSource:Prepare(hBuffer,tableRequest). 
            else 
                authenticationSystemDataSource:Prepare(hBuffer). 
        end.
          
        msg:DataHandle:Fill().
        if valid-object(authenticationSystemDataSource) and authenticationSystemDataSource:NumRecords <> ? then
            msg:SetTableTotal("ttAuthenticationSystem",authenticationSystemDataSource:NumRecords).
        finally:
            delete object authenticationSystemDataSource no-error.		
        end finally.
            
    end method. 
    
     method public override ISaveRequest SaveData(phChanges as ISaveRequest): 
        define variable hBuffer as handle no-undo.
        define variable authenticationSystemDataSource as IDataSource no-undo.
 
        SetUrl(phChanges:url).
        DatasetHandle = phChanges:DataHandle.              
        hBuffer = phChanges:DataHandle:get-buffer-handle ("ttAuthenticationSystem").
        if valid-handle(hBuffer) then
        do:
            authenticationSystemDataSource = new AuthenticationSystemDataSource().
            authenticationSystemDataSource:Url = Url.
            authenticationSystemDataSource:Save(hBuffer).
        end.     
        return phChanges.
            
    end method. 
    
 
        
end class.
