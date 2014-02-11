/*************************************************************/
/* Copyright (c) 2010-2012 by Progress Software Corporation. */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : TenantGroupDataSource
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Dec 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataSource.DataSource from propath.
using OpenEdge.DataAdmin.DataAccess.DataAccessError from propath. 
using OpenEdge.DataAdmin.DataAccess.DataMapper from propath. 
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath. 
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath. 
routine-level on error undo, throw.

class OpenEdge.DataAdmin.DataSource.TenantGroupDataSource inherits DataSource: 
   
    define buffer b_dataArea  for dictdb._Area.
    define buffer b_indexArea for dictdb._Area.
    define buffer b_LobArea   for dictdb._Area.
     
    define protected variable BaseExpression as char no-undo
       init "each _Partition-Set where _Partition-Set._PSet-type = '1' and _Partition-Set._Object-type = '1'".
        

    define protected property FieldMap as char no-undo 
        init "Id,_PSetid,ObjectType,_Object-Type,ObjectNumber,_Object-Number,Name,_PSet-name,TableName,_file._file-name,SchemaName,_file._owner,Description,_PSet-description,DefaultDataAreaName,b_dataarea._Area-name,DefaultIndexAreaName,b_indexarea._Area-name,DefaultLobAreaName,b_lobarea._Area-name,DefaultAllocation,_PSet-Allocation-default,IsAllocated,_PSet-attributes[1]"
        get.
        
    define private property mAreaQuery as character no-undo  
         get(): 
         return " each b_dataArea outer-join no-lock   where b_dataArea._area-number = _Partition-Set._PSet-DataArea-default,"
              + " each b_indexArea outer-join no-lock  where b_indexArea._area-number = _Partition-Set._PSet-IndexArea-default,"
              + " each b_LobArea outer-join no-lock   where b_LobArea._area-number = _Partition-Set._PSet-LobArea-default".   
    end.
    
    constructor public TenantGroupDataSource ( ):        
        this-object (FieldMap).
    end constructor.
    
 	constructor public TenantGroupDataSource (pfieldmap as char ):	    
		super ("_Partition-Set,_File,b_dataArea,b_indexArea,b_LobArea","dictdb._Partition-Set,dictdb._File,dictdb._Area,dictdb._Area,dictdb._Area", pFieldMap). 
		BaseQuery = "for " + BaseExpression + " no-lock,"
                    + " each _File where _File._file-number = _Partition-Set._Object-number no-lock, " + mAreaQuery .
    end constructor.
    
    method public override logical Prepare(phBuffer as handle,pcTargetQuery as char,pcJoin as char):
        phBuffer:set-callback("After-Row-fill","AfterTenantGroupRow").
        super:Prepare(phBuffer,pcTargetQuery,pcJoin).
     
    end method.
    
    /** tenantgroup requires control of order , so this is not supported  */
    method public override logical Save(phbuffer as handle):
         undo, throw new UnsupportedOperationError("Save without state for " + this-object:GetClass():TypeName).
    end method.
    
     /**  refresh row-state 0  isallocated  */
    method public override logical Refresh(phbuffer as handle):
        define variable hQuery  as handle no-undo.
        create query hquery.
        hquery:add-buffer(phBuffer).
        hQuery:query-prepare("for each ttTenantGroup where row-state(ttTenantGroup) = 0 ").
        hquery:query-open().       
        hquery:get-first.   
        do while phbuffer:avail:
            /** @todo - remove no-error and throw something 
               also check if exclusive and validate is needed 
              (this was done late before ship) */ 
            find dictdb._Partition-Set
                         where dictdb._Partition-Set._PSet-Name = phbuffer::Name exclusive no-wait
                         no-error.
            if avail dictdb._Partition-Set then
            do:            
                validate dictdb._Partition-Set.
                phBuffer::IsAllocated =   dictdb._Partition-Set._Pset-attributes[1]. 
            end.
            hquery:get-next.   
        end.
    end method.
    
    /** Save changes of specified state 
         @param buffer the temp-table buffer handle with data
         @param state  the row-state to save (row-created, row-deleted or row-modified) 
                      ? = all */
    method public override logical Save(phBuffer as handle, pistate as int):
        define variable hBeforeBuff as handle    no-undo.
        define variable lnew        as logical   no-undo. 
        define variable hquery      as handle    no-undo.
        define variable iType       as integer   no-undo.
        define variable cType       as character no-undo.
        define variable hDataset    as handle no-undo.
        define variable cAccess     as character no-undo.
        define variable cMsg        as character no-undo.
        define buffer bdetail for dictdb._Partition-set-detail.
        
        if piState = ? then
            undo, throw new IllegalArgumentError("TenantGroupDataSource save does not support unknown value in state paramter." ).
        
        if piState < 1 or pistate > 3 then
            undo, throw new IllegalArgumentError("Invalid state " + string(piState) + " passed to save." ).
       
        create query hquery.
        hBeforeBuff = phBuffer:before-buffer.
        
        hquery:add-buffer(hBeforeBuff).
        hQuery:query-prepare("for each ttTenantGroupCopy where row-state(ttTenantGroupCopy) = " + string(pistate)).   
        hquery:query-open().
        
        do transaction on error undo, throw:
            do while true:
                
                hquery:get-next.
                if not hBeforebuff:avail then 
                    leave.
            
                if hBeforeBuff:row-state = row-deleted then 
                do:
                    find dictdb._Partition-Set
                         where dictdb._Partition-Set._PSet-Name = hBEforeBuff::Name exclusive no-wait.
                    
                    for each dictdb._Partition-Set-Detail of dictdb._Partition-Set no-lock:
                        
                        find bDetail where rowid(bDetail) = rowid(dictdb._Partition-Set-Detail) exclusive no-wait.
                        delete bDetail.
                    end.    
                     
                    delete dictdb._Partition-Set.
                
                end.
                else do:
            
                    phBuffer:find-by-rowid (hBeforeBuff:after-rowid).
                    
                    if hBeforeBuff:row-state = row-created then 
                    do:
                        if phBuffer::TableName  = "" or phBuffer::TableName = ? then
                            undo, throw new DataAccessError("Cannot save TenantGroup with no Table").
                        find dictdb._file where dictdb._file._file-name = phBuffer::TableName no-lock no-error.
                        if not avail dictdb._file then 
                            undo, throw new DataAccessError("Table " + quoter(phBuffer::TableName) + " does not exist.").
                   
                        create dictdb._Partition-Set.
                   
                    end. 
                    else do:
                        find dictdb._Partition-Set
                             where dictdb._Partition-Set._PSet-Name = hBeforeBuff::Name exclusive no-wait.
                      
                        /* allocated only makes sense when not new */
                        if dictdb._Partition-Set._Pset-attributes[1] <> phBuffer::isAllocated 
                        and phBuffer::isAllocated = true then 
                        do:
                             dictdb._Partition-Set._Pset-attributes[1] = phBuffer::isAllocated.                    
                             RefreshPartitionState(phBuffer::name,phBuffer:dataset).
                        end. 
                    end.
                    
                    if phbuffer::DefaultDataAreaName > "" then
                    do on error undo, throw:
                        find b_dataarea where b_dataarea._area-name = phbuffer::DefaultDataAreaName
                            no-lock.
                        catch e as Progress.Lang.Error :
                             cmsg = "DefaultDataArea " + quoter(phbuffer::DefaultDataAreaName) + " does not exist".    
                             undo, throw new DataAccessError(cMsg).
                        end.        
                    end.
                    else 
                        undo, throw new DataAccessError("DefaultDataArea cannot be set to blank or unknown.").    
                        
                    if phbuffer::DefaultIndexAreaName > "" then
                    do on error undo, throw:
                        find b_indexarea where b_indexarea._area-name = phbuffer::DefaultIndexAreaName
                            no-lock. 
                        catch e as Progress.Lang.Error :
                            cmsg = "DefaultIndexArea " + quoter(phbuffer::DefaultIndexAreaName) + " does not exist".    
                            undo, throw new DataAccessError(cMsg).
                        end.            
                    end.
                    else 
                        undo, throw new DataAccessError("DefaultIndexArea cannot be set to blank or unknown.").    
                            
                    if phbuffer::DefaultLobAreaName > "" then
                    do on error undo, throw:
                        find b_lobarea where b_lobarea._area-name = phbuffer::DefaultLobAreaName
                            no-lock. 
                         catch e as Progress.Lang.Error :
                             cmsg = "DefaultLobArea " + quoter(phbuffer::DefaultLobAreaName) + " does not exist".    
                             undo, throw new DataAccessError(cMsg).
                         end.        
                    end.
                    else 
                        undo, throw new DataAccessError("DefaultLobArea cannot be set to blank or unknown.").    
                 
                    /* rename a group  
                    if  dictdb._Partition-Set._PSet-Name <> phBuffer::Name then 
                        dictdb._Partition-Set._PSet-Name = phBuffer::Name.*/                                       
                 
                    assign
                        dictdb._Partition-Set._PSet-Name = phBuffer::Name
                        dictdb._Partition-Set._PSet-Description = phBuffer::Description
                        dictdb._Partition-Set._PSet-DataArea-default =  b_dataarea._area-number 
                        dictdb._Partition-Set._PSet-IndexArea-default = b_indexarea._area-number 
                        dictdb._Partition-Set._PSet-LobArea-default =  b_lobarea._area-number 
                        dictdb._Partition-Set._PSet-Allocation-default  = phBuffer::DefaultAllocation  
                    /* TODO   - save-row-changes? */
                        hdataset = phBuffer:dataset.
                    /* must set object number last */    
                    if hBeforeBuff:row-state = row-created then 
                    do:
                       assign
                            dictdb._Partition-Set._Object-Type = 1
                            dictdb._Partition-Set._PSet-Type = 1
                            dictdb._Partition-Set._Object-Number = dictdb._file._file-number.
                        phBuffer::id =  dictdb._Partition-Set._PSetid.
                        phBuffer::Objecttype   =  dictdb._Partition-Set._Object-type.
                        phBuffer::Objectnumber =  dictdb._Partition-Set._Object-number.
                             
                    end. 
                    
                    /* ensure partitions are created */
                    validate dictdb._Partition-Set.
                
                    AfterTenantGroupRow (dataset-handle hdataset  by-reference).
                end. /* else (not delete) */
            end. /* do while true */ 
            catch e2 as DataAccessError :
                undo, throw e2. 
            end catch.
            catch e as Progress.Lang.Error :
               
                undo, throw new DataAccessError(
                    new DataMapper("Partition Group,_Partition-Set,Group,PSet,Area,b_dataarea,Area,b_indexarea,Area,b_lobarea",FieldMap),
                                   e ). 
            end catch.
        end. /*trans */
        return true.
        finally:
            delete object hQuery no-error.    		
        end finally.        
    end method.    
    
     /* set allocated in partitions that were changed . The TenantGroupcontext 
       will do a new request, but it does this before the changes are merged so
       partitions with pending updates will not be refreshed due to the
       protection in dataRefreshed */ 
    method public void RefreshPartitionState(pcTenantGroup as char,hds as handle):
        define variable hQuery as handle no-undo.
        define variable hBuffer as handle no-undo.
        hBuffer = hds:get-buffer-handle ("ttPartition").
        if valid-handle(hBuffer) then
        do:
            create query hquery.
            hquery:add-buffer(hBuffer).
            hQuery:query-prepare("for each ttPartition where ttPartition.TenantGroupName = " + quoter(pcTenantGroup)).
            hquery:query-open().       
            hquery:get-first.
            do while(hBuffer:avail):
                hBuffer::AllocationState = "Allocated".  
                hquery:get-next.
            end.    
        end.   
        finally:
           delete object hquery no-error.
        end finally. 
    end method. 
    
    
    method public void AfterTenantGroupRow(dataset-handle hds):
        define variable hbuffer as handle no-undo.
        define variable TenantGroupUrl as character no-undo.
        
        assign
            hBuffer   = hds:get-buffer-handle("ttTenantGroup")
            TenantGroupUrl = "/tenantgroups/" + WebUtil:UrlEncode(hBuffer::Name) 
            hBuffer::Url  = url + TenantGroupUrl
            hBuffer::DeallocateUrl = hBuffer::Url + "/deallocate"
            hBuffer::PartitionsUrl = hBuffer::Url + "/partitions".
              
    end method.    
    
    method public override character ColumnSource (pcColumn as char):
        define variable cColumn as character no-undo.
        ccolumn = super:ColumnSource(pccolumn).
        if ccolumn <> pccolumn then
            return ccolumn.
        /* data types does not match - for access permissions 
           Attach maps with MapNoArea to avoid finding the area fields */
        if pccolumn = "ttTenantGroup.DefaultDataAreaName" then
        do:
            return "_Partition-Set._PSet-DataArea-default".      
        end.
        if pccolumn = "ttTenantGroup.DefaultIndexAreaName" then
        do:
            return "_Partition-Set._PSet-IndexArea-default".      
        end.
        else if pccolumn = "ttTenantGroup.DefaultLobAreaName" then
        do:
            return "_Partition-Set._PSet-LobArea-default".      
        end.       
        return pccolumn.
    end method.     
    
 /*   method public override logical Attach(bufferHandle as handle).
        FieldMapping = FieldMapNoArea.
        return super:Attach(bufferHandle).
    end method.*/             
    
end class.