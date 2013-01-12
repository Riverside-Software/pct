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
 
using OpenEdge.DataAdmin.DataSource.AdministratorSource from propath.
using OpenEdge.DataAdmin.DataSource.IDataSource from propath.
using OpenEdge.DataAdmin.DataSource.TableDataSource from propath.
using OpenEdge.DataAdmin.DataSource.FieldDataSource from propath.
using OpenEdge.DataAdmin.DataSource.IndexDataSource from propath.
using OpenEdge.DataAdmin.DataSource.SequenceDataSource from propath.
using OpenEdge.DataAdmin.DataSource.SequenceValueDataSource from propath.
using OpenEdge.DataAdmin.DataSource.PartitionDataSource from propath.
using OpenEdge.DataAdmin.DataSource.TablePartitionDataSource from propath.
using OpenEdge.DataAdmin.DataSource.FieldPartitionDataSource from propath.
using OpenEdge.DataAdmin.DataSource.IndexPartitionDataSource from propath.
using OpenEdge.DataAdmin.DataSource.TablePermissionDataSource from propath.
using OpenEdge.DataAdmin.DataSource.FieldPermissionDataSource from propath.
using OpenEdge.DataAdmin.DataSource.SecurityOptionsSource from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Message.ITableRequest from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.DataAccess.FileData inherits DataAccess  : 
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
    
 
        
    method public override ISaveRequest SaveData(pChanges as ISaveRequest):    
        define variable hDs     as handle  no-undo.
        define variable i       as integer no-undo.
        define variable hBuffer as handle  no-undo.
        define variable tableDataSource as TableDataSource no-undo.
        define variable tablePermissionDataSource as TablePermissionDataSource no-undo.
        define variable fieldPermissionDataSource as FieldPermissionDataSource no-undo.
        define variable sequenceDataSource as SequenceDataSource no-undo.
        define variable partitionDataSource as IDataSource no-undo.
        define variable sequenceValueDataSource as IDataSource no-undo.
        define variable adminSource as AdministratorSource  no-undo.
        define variable secOptionsSource as SecurityOptionsSource  no-undo.
                    
        hDs = pChanges:DataHandle.
        DatasetHandle = hDs.
        SetUrl(pChanges:url). 
        
        if pChanges:EntityName = "Administrator" then
        do:
            adminSource = new AdministratorSource().
            hBuffer = pChanges:DataHandle:get-buffer-handle ("ttAdministrator").
            adminSource:Save(hBuffer).              
        end.              
        else if pChanges:EntityName = "SecurityOptions" then
        do:
            secOptionsSource = new SecurityOptionsSource().
            hBuffer = pChanges:DataHandle:get-buffer-handle ("ttSecurityOptions").
            secOptionsSource:Save(hBuffer).              
        end.     
        else do transaction on error undo, throw:
            
            do i = 1 to hDs:num-buffers:
                hBuffer = hDs:get-buffer-handle(i).
                if hbuffer:name = "ttTable" then
                do:
                    tableDataSource = new TableDataSource(Url).
                    tableDataSource:Url = URL.
                    tableDatasource:Save(hbuffer).
                end.
                else if hbuffer:name = "ttTablePermission" then
                do:
                    tablePermissionDataSource = new TablePermissionDataSource().
                    tablePermissionDataSource:Url = URL.
                    tablePermissionDataSource:Save(hbuffer).
                end.
                else if hbuffer:name = "ttFieldPermission" then
                do:
                    fieldPermissionDataSource = new FieldPermissionDataSource().
                    fieldPermissionDataSource:Url = URL.
                    fieldPermissionDataSource:Save(hbuffer).
                end.
                else if hbuffer:name = "ttSequence" then
                do:
                     sequenceDataSource = new SequenceDataSource(Url).
                     sequenceDataSource:Url = URL.                     
                     sequenceDataSource:Save(hbuffer).                  
                end.    
                else if hbuffer:name = "ttSequenceValue" then
                do:
                     sequenceValueDataSource = new SequenceValueDataSource().
                     sequenceValueDataSource:Url = URL.                     
                     sequenceValueDataSource:Save(hbuffer).                  
                end.    
                else do:
                    if hbuffer:name = "ttPartition" then
                    do:
                        partitionDataSource = new PartitionDataSource().                   
                        partitionDataSource :Url = URL.                     
                        partitionDataSource :Save(hbuffer).
                    end.
                end.       
            end.
        end.
        return pChanges.     
    end method.       
     
    method public void FillData(msg as IFetchRequest):
        define variable hBuffer as handle no-undo.
        define variable cQuery as character no-undo.
        define variable lChangesOnly as logical no-undo.
        define variable i as integer no-undo.
      
        define variable adminSource as AdministratorSource  no-undo.
        define variable secoptionsSource as SecurityOptionsSource  no-undo.
        define variable tableDataSource as IDataSource no-undo.
        define variable tablePermissionDataSource as IDataSource no-undo.
        define variable fieldPermissionDataSource as IDataSource no-undo.
        define variable sequenceDataSource as IDataSource no-undo.
        define variable sequenceValueDataSource as IDataSource no-undo.
        define variable fieldDataSource as IDataSource no-undo.
        define variable indexDataSource as IDataSource no-undo.     
        
        define variable tableRequest as ITableRequest no-undo.     
         
             
        if msg:EntityName = "Administrator" then
        do:
            adminSource = new AdministratorSource().
            hBuffer = msg:DataHandle:get-buffer-handle ("ttAdministrator").
            adminSource:Fill(hBuffer).              
        end.
        else if msg:EntityName = "SecurityOptions" then
        do:
            secoptionsSource = new SecurityOptionsSource().
            hBuffer = msg:DataHandle:get-buffer-handle ("ttSecurityOptions").
            secoptionsSource:Fill(hBuffer).              
        end.                        
        else do: 
            hBuffer = msg:DataHandle:get-buffer-handle ("ttTablechange").
            SetUrl(msg:url). 
            if valid-handle(hBuffer) then
            do:
                msg:DataHandle:get-buffer-handle ("ttTablechange"):fill-mode = "no-fill".
                msg:DataHandle:get-buffer-handle ("ttIndexchange"):fill-mode = "no-fill".
                msg:DataHandle:get-buffer-handle ("ttFieldchange"):fill-mode = "no-fill".
                msg:DataHandle:get-buffer-handle ("ttSequencechange"):fill-mode = "no-fill".
                msg:DataHandle:get-buffer-handle ("ttPartition"):fill-mode = "no-fill".
                lChangesOnly = true.
            end.
            
            hBuffer = msg:DataHandle:get-buffer-handle ("ttSchema").
            if valid-handle(hBuffer) then
            do:
               DeactivateChildRelations(hBuffer). 
               FillSchema(hBuffer).
            end.     
             
            hBuffer = msg:DataHandle:get-buffer-handle("ttTable").          
            if valid-handle(hBuffer) then
            do:
               if lChangesOnly then
               do:
                   tableDataSource = new TableDataSource(msg:DataHandle:get-buffer-handle ("ttTablechange")).
                   PrepareSource(tableDataSource,hBuffer,"").            
               end.
               else do:
                   tableDataSource =  new TableDataSource().
                   tableRequest = msg:GetTableRequest("ttTable").
                   if valid-object(tableRequest) then 
                       PrepareSource(tableDataSource,hBuffer,tableRequest).   
                   else  
                       PrepareSource(tableDataSource,hBuffer,"").   
               end.
            end.   
            
            hBuffer = msg:DataHandle:get-buffer-handle("ttField").          
            if valid-handle(hBuffer) then
            do:
               if lChangesOnly then
               do:
                   fieldDataSource = new FieldDataSource(msg:DataHandle:get-buffer-handle ("ttFieldchange")).   
                   mfieldrel = hbuffer:parent-relation.
                   mFieldRel:active = false.         
                   PrepareSource(fieldDataSource,hBuffer,"").
               end.
               else do:
                   fieldDataSource = new FieldDataSource().
                   cQuery = msg:GetTableQuery("ttField").  
                   PrepareSource(fieldDataSource,hBuffer,cQuery).       
               end. 
            end.
            
            hBuffer = msg:DataHandle:get-buffer-handle("ttIndex").          
            if valid-handle(hBuffer) then
            do:
               if lChangesOnly then
               do:
                   indexDataSource = new IndexDataSource(msg:DataHandle:get-buffer-handle ("ttIndexchange")).   
                   mindexrel = hbuffer:parent-relation.
                   mindexRel:active = false.      
                   PrepareSource(indexDataSource,hBuffer,"").   
               end.
               else do:
                   indexDataSource = new IndexDataSource().   
                   cQuery = msg:GetTableQuery("ttIndex").      
                   PrepareSource(indexDataSource,hBuffer,cQuery).   
               end.    
            end.   
            
            hBuffer = msg:DataHandle:get-buffer-handle("ttSequence").          
            if valid-handle(hBuffer) then
            do:
                
                cQuery = msg:GetTableQuery("ttSequence"). 
                if lChangesOnly then
                do:
                    sequenceDataSource = new SequenceDataSource(msg:DataHandle:get-buffer-handle ("ttSequencechange")).
                    PrepareSource(sequenceDataSource,hBuffer,"").
                end.
                else do:
                     sequenceDataSource = new SequenceDataSource().
                     tableRequest = msg:GetTableRequest("ttSequence").
                     if valid-object(tableRequest) then 
                         PrepareSource(sequenceDataSource,hBuffer,tableRequest).   
                     else  
                         PrepareSource(sequenceDataSource,hBuffer,"").            
                end. 
            end.
            hBuffer = msg:DataHandle:get-buffer-handle("ttTablePermission").           
            if valid-handle(hBuffer) then
            do:
                tablePermissionDataSource = new TablePermissionDataSource().
                cQuery = msg:GetTableQuery("ttTablePermission"). 
                PrepareSource(TablePermissionDataSource,hBuffer,cQuery,"Append").
            end. 
            
            hBuffer = msg:DataHandle:get-buffer-handle("ttFieldPermission").          
            if valid-handle(hBuffer) then
            do:
                fieldPermissionDataSource = new FieldPermissionDataSource(). 
    /*            cQuery = msg:GetTableQuery("ttFieldPermission").*/
                mindexrel = hbuffer:parent-relation.
                mindexRel:active = false.         
                PrepareSource(FieldPermissionDataSource,hBuffer,"","Append").
            end. 
            
            msg:DataHandle:Fill().
            if valid-object(tableDataSource) and tableDataSource:NumRecords <> ? then 
                msg:SetTableTotal("ttTable",tableDataSource:NumRecords).
            if valid-object(sequenceDataSource) and sequenceDataSource:NumRecords <> ? then 
                msg:SetTableTotal("ttSequence",sequenceDataSource:NumRecords).
           
            if lChangesOnly then 
            do:
                
                hBuffer = msg:DataHandle:get-buffer-handle ("ttPartition").
                if valid-handle(hbuffer) then
                do:
                    do i = 1 to msg:DataHandle:num-buffers:
                        msg:DataHandle:get-buffer-handle(i):fill-mode = "no-fill".
                    end. 
                    FillPartitions(hBuffer,msg,"ttTablechange").
                    FillPartitions(hBuffer,msg,"ttFieldChange").
                    FillPartitions(hBuffer,msg,"ttIndexChange").
                end.
            end.
            
            hBuffer = msg:DataHandle:get-buffer-handle ("ttSchema").
            if valid-handle(hBuffer) then
            do:
                ActivateChildRelations(hBuffer). 
            end. 
            if valid-handle(mfieldRel) then
                mfieldrel:active = true. 
            if valid-handle(mindexRel) then
                mindexrel:active = true. 
            
            
            
        end. /* else (not administrator)*/
        finally: /* no GC when set-callabck is used */                        
            delete object adminSource no-error.
            delete object tableDataSource no-error.
            delete object tablePermissionDataSource no-error.
            delete object fieldPermissionDataSource no-error.
            delete object sequenceDataSource no-error.
            delete object sequenceValueDataSource no-error.
            delete object fieldDataSource no-error.
            delete object indexDataSource no-error.         
        end finally.    
      
    end method. 
     
	 
    method protected void FillSchema(phbuffer as handle):
        phBuffer:set-callback("Before-fill","BeforeSchema").
    end method.  
     
    method public void BeforeSchema(dataset-handle hds):
        define variable hbuffer as handle no-undo.
        define variable lok as logical no-undo.
        hbuffer = hds:get-buffer-handle ("ttSchema").
        lok = hbuffer:find-unique("where ttSchema.Name = 'PUB'") no-error.
        if not lok  then
        do:
            hbuffer:buffer-create().
            hbuffer::name = "PUB".
        end.
        hBuffer::tablesurl = url + "/schemas/" + WebUtil:UrlEncode("PUB") + "/tables".
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
   
    method protected void FillPartitions(phPartition as handle,msg as IFetchRequest,pcChanges as char):
        define variable partitionSource as PartitionDataSource no-undo.
        define variable hChanges as handle no-undo.
        hChanges = msg:DataHandle:get-buffer-handle (pcChanges).
        case pcchanges:
            when "ttTablechange" then
                 partitionSource = new TablePartitionDataSource(hChanges).
            when "ttFieldChange" then
                 partitionSource = new FieldPartitionDataSource(hChanges).
            when "ttIndexChange" then
                 partitionSource = new IndexPartitionDataSource(hChanges).
        
        end.
        partitionSource:Url = Url.
        partitionSource:FillMode = "Merge".
        partitionSource:Prepare(phPartition).
        msg:DataHandle:Fill().
        finally: /*is not garbage collected if set-callback is used */
            delete object partitionSource.              
        end finally.
    end method.    
 
end class.
