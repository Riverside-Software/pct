 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 
 /*------------------------------------------------------------------------
    Purpose     : Manages meta schema  (table, field, index and sequence )
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Fri Feb 19 12:47:44 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using OpenEdge.DataAdmin.DataAccess.DataAccess from propath.
 
using OpenEdge.DataAdmin.DataSource.IDataSource from propath.
using OpenEdge.DataAdmin.DataSource.AllTableDataSource from propath.

using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Message.ITableRequest from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.DataAccess.AllFileData inherits DataAccess  : 
    define private variable Url as character no-undo.
    define private variable AreaURL as character no-undo.
    define variable mfieldrel as handle no-undo.
    define variable mindexrel as handle no-undo.
    
    
    method protected override void SetUrl(pcUrl as char):
        Url = pcUrl.
        AreaURL = pcURL + "/areas/".
    end method.
   
	method public override void FetchData(msg as IFetchRequest):  
	    FillData(msg).
    end method.  
    
    method public void FillData(msg as IFetchRequest):
        define variable hBuffer as handle no-undo.
        define variable cQuery as character no-undo.
        define variable alltableDataSource as IDataSource no-undo.
        define variable tableRequest as ITableRequest no-undo.     
        hBuffer = msg:DataHandle:get-buffer-handle("ttTable").          
        if valid-handle(hBuffer) then
        do:
            alltableDataSource =  new AllTableDataSource().
            tableRequest = msg:GetTableRequest("ttTable").
            if valid-object(tableRequest) then 
                 PrepareSource(alltableDataSource,hBuffer,tableRequest).   
            else  
                 PrepareSource(alltableDataSource,hBuffer,"").   
        end.
        msg:DataHandle:Fill().
        if valid-object(alltableDataSource) and alltableDataSource:NumRecords <> ? then 
                msg:SetTableTotal("ttTable",alltableDataSource:NumRecords).
           
        finally: /* no GC when set-callabck is used */                        
            delete object alltableDataSource no-error.
        end finally.    
      
    end method. 
     
 
    method protected void PrepareSource(src as IDataSource,phbuffer as handle,pcQuery as char,pcFillMode as char):     
        src:FillMode = pcFillMode.
        src:Url = Url.
        src:Prepare(phBuffer,pcQuery,"").
    end method.     
    
    method protected void PrepareSource(src as IDataSource,phBuffer as handle,req as ITableRequest):     
        src:FillMode = "Replace".
        src:Url = Url.
        src:Prepare(phBuffer,req).
    end method.    
    
    method protected void PrepareSource(src as IDataSource,phbuffer as handle,pcQuery as char):     
         this-object:PrepareSource(src,phbuffer,pcquery,"Replace").
    end method.      
     
end class.
