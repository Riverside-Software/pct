 /*************************************************************/
 /* Copyright (c) 2012 by Progress Software Corporation.      */
 /*                                                           */
 /* All rights reserved.  No part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from Progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : TableDataMonitor
    Purpose     : Status monitoring of dump and load
    Syntax      : 
    Description : 
    Author(s)   : rkumar
    Created     : Tue Mar 20 17:19:55 IST 2012
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Progress.Lang.*.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Binding.ITableDataMonitor from propath.
using OpenEdge.DataAdmin.Lang.WebUtil from propath.
using OpenEdge.DataAdmin.Core.DataFileInfo from propath.
using OpenEdge.DataAdmin.Core.FileUtil from propath.

class OpenEdge.DataAdmin.Binding.TableDataMonitor implements ITableDataMonitor : 
    
    {daschema/statussummary.i}
    {daschema/filestatus.i REFERENCE-ONLY} 
        
    define dataset dsstatus serialize-name "root" for ttStatusSummary , ttFileStatus.
    
    define private property GROUP_TABLES     as char init "group" no-undo get. 
    define private property TENANT_TABLES    as char init "tenant" no-undo get. 
    define private property SHARED_TABLES    as char init "shared" no-undo get. 
 
             
    define public property FileName as character no-undo 
        get. 
        set.   
                
    define public property TaskName as character no-undo 
        get():
            return ttStatusSummary.TaskName.
        end. 
        set(pTask as char):
            ttStatusSummary.TaskName = pTask. 
        end.    
        
    define public property LogTime as datetime-tz  no-undo 
        get():
            return ttStatusSummary.LogTime.
        end. 
         
    define public property StartTime as datetime-tz  no-undo 
        get():
            return ttStatusSummary.StartTime.
        end. 
        
    define public property EndTime as datetime-tz  no-undo 
        get():
            return ttStatusSummary.EndTime.
        end. 
        
    define public property NumSharedTables as integer no-undo 
        get():
            return ttStatusSummary.NumSharedTables.
        end. 
     
    define public property NumTenantTables as integer no-undo 
        get():
            return ttStatusSummary.NumTenantTables.
        end. 
    
    define public property NumGroupTables as integer no-undo 
        get():
            return ttStatusSummary.NumGroupTables.
        end. 
    
    define public property NumProcessedSharedTables as integer no-undo 
        get():
            return ttStatusSummary.NumProcessedSharedTables.
        end. 
     
    define public property NumProcessedTenantTables as integer no-undo 
        get():
            return ttStatusSummary.NumProcessedTenantTables.
        end. 
    
    define public property NumProcessedGroupTables as integer no-undo 
        get():
            return ttStatusSummary.NumProcessedGroupTables.
        end. 
    
    define public property NoLobs as logical no-undo 
        get():
            return ttStatusSummary.NoLobs.
        end. 
        set(pnolobs as log):
           ttStatusSummary.NoLobs = pnolobs. 
        end.    
        
    define public property AnyError as logical no-undo 
        get():
            return ttStatusSummary.AnyError.
        end. 
        set(plerror  as log):
           ttStatusSummary.AnyError = plerror. 
        end.
        
    define public property ErrorMessage as char no-undo 
        get():
            return ttStatusSummary.ErrorMessage.
        end. 
        set(pMsg as char):
           AnyError = pmsg > "". 
           ttStatusSummary.ErrorMessage = pMsg. 
        end.    
       
    define public property Interval as int no-undo 
        get. 
        set.    
    
    define public property IsComplete as log no-undo 
        get():
            return ttStatusSummary.IsComplete.
        end. 
        set(pComp as log):
            ttStatusSummary.IsComplete = pcomp. 
        end.    
    
    define public property LogType as char no-undo 
        get. 
        set.
    
    define public property Cancel as logical no-undo 
        get.
        set. 
    
    define public property IsLoad as logical no-undo 
        get.
        set. 
    
    define public property ConnectionUrl as character no-undo 
        get.
        set. 
            
    define public property Slash as character no-undo 
        init "/"
        get. 
        set. 
    
    define public property CheckFiles as logical  no-undo 
        get. 
        set. 
    
    define private variable LastDump as datetime-tz no-undo init now.
    
    define private variable RowCount as int no-undo .
    
    define private property WebUtil as WebUtil no-undo 
        get():
            if not valid-object(WebUtil) then
                WebUtil = new WebUtil().
            return WebUtil.     
        end. 
        set.
    
    define private property FileUtil as FileUtil no-undo 
        get():
            if not valid-object(FileUtil) then
                FileUtil = new FileUtil().
            return FileUtil.     
        end. 
        set.
    
    define private property DataFileInfo as DataFileInfo no-undo 
        get():
            if not valid-object(DataFileInfo) then
                DataFileInfo = new DataFileInfo().
            return DataFileInfo.     
        end. 
        set.
    
    define public property AnyFileExists as logical  no-undo 
        get():
            return can-find(first ttFileStatus where ttFileStatus.IsAvailable = true). 
        end.
    
    /*------------------------------------------------------------------------------
            Purpose:                                                                      
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
        
    constructor public TableDataMonitor (  ):
        super ().
        create ttStatusSummary.
        ttStatusSummary.StartTime = now.
    end constructor.
    
    method public void BindFiles(pHdl as handle).
        BindFiles(table-handle phdl bind).
    end method.    
    
    method protected void BindFiles(table ttFileStatus bind).
    end method.    
    
    method public character CheckPath(pcPath as char):
        define variable cSlash as character no-undo init "/".
        if index(pcPath,"~\") > 0 then 
            cSlash = "~\".
        if pcPath = "" then pcPath = ".".
        return right-trim(pcPath,cSlash) + cSlash. 
    end method.
    
    method public void AddSharedTables(pcPath as char, table-handle phTempTable):
        AddTables(CheckPath(pcPath), SHARED_TABLES, "",table-handle phTempTable).
    end method.
    
    method public void AddGroupTables(pcPath as char, pcGroupdir as char, table-handle phTempTable):
        AddTables(pcPath, GROUP_TABLES, pcGroupdir, table-handle phTempTable).
    end method.
    
    method public void AddTenantTables(pcPath as char, pcTenant as char,table-handle phTempTable):
        AddTables(pcPath, TENANT_TABLES, pcTenant, table-handle phTempTable).
    end method.
    
    /**  */
    method protected void AddTables(pcPath as char, pcType as char, pcTenantorSubdir as char, table-handle phTempTable):
        define variable hQ as handle no-undo.
        define variable hBuffer as handle no-undo.
        define variable h as handle no-undo.
        define variable cSlash as character no-undo init "/".
        define variable cfile as character no-undo.
         
        pcPath = CheckPath(pcPath).
        if index(pcPath,"~\") > 0 then 
            cSlash = "~\".
        
        /* checked by command    
        if not FileUtil:IsValidDirectory(pcPath) then
            undo, throw new AppError("Directory" + pcPath + " does not exist").
        */
        
        if pcTenantorSubdir > "" then
            pcPath = pcPath + pcTenantorSubdir + cSlash.
        
        create query hq.
        hBuffer = phTempTable:default-buffer-handle.
        hq:add-buffer(hBuffer).
        hq:query-prepare("for each " + phTempTable:name
                          + " by " + phTempTable:name + ".databasename " 
                          + " by " + phTempTable:name + ".name "). 
        hq:query-open().
        hq:get-first ().
        
        do while hBuffer:avail:
            create ttFileStatus.
            assign 
                ttFileStatus.TableName  = hBuffer::name
                ttFileStatus.CanExport  = hBuffer::CanExport 
                ttFileStatus.CanImport  = hBuffer::CanImport
                ttFileStatus.TableUrl   = ConnectionUrl + "/schemas/" + hBuffer::schemaname + "/tables/" + WebUtil:UrlEncode(ttFileStatus.TableName)       
                ttFilestatus.Type       = pcType
                ttFileStatus.TenantName = pcTenantOrSubdir 
                        when pctype = TENANT_TABLES        
                ttFileStatus.TenantUrl  = ConnectionUrl + "/tenants/" + WebUtil:UrlEncode(ttFileStatus.TenantName) 
                        when pctype = TENANT_TABLES        
                ttFileStatus.TenantGroupName = hBuffer::tenantgroupname 
                        when pctype = GROUP_TABLES        
                ttFileStatus.TenantGroupUrl = ConnectionUrl + "/tenantgroups/" + WebUtil:UrlEncode(ttFileStatus.TenantGroupName) 
                        when pctype = GROUP_TABLES       
                ttFileStatus.FileName = pcPath
                                      + (if pctype = GROUP_TABLES then ttFileStatus.TenantGroupName + cSlash else "")
                                      + hBuffer::dumpname  + ".d" 
                ttFileStatus.TableSequence = Rowcount + 1
                Rowcount = Rowcount + 1
                ttStatusSummary.NumGroupTables = ttStatusSummary.NumGroupTables + 1 
                        when pctype = GROUP_TABLES
                ttStatusSummary.NumSharedTables = ttStatusSummary.NumSharedTables + 1 
                        when pctype = SHARED_TABLES
                ttStatusSummary.NumTenantTables = ttStatusSummary.NumTenantTables + 1 
                        when pctype = TENANT_TABLES
                .
            
            if IsLoad then
            do on error undo, throw:
                DataFileInfo:ReadTrailer(ttFileStatus.FileName).
                ttFileStatus.ExpectedNumRows = DataFileInfo:NumRecords.
                ttFileStatus.IsAvailable = true.
                catch e as Progress.Lang.Error:
                    if e:GetMessageNum(1) = 293 then
                        ttFileStatus.IsAvailable = false.
                end catch.
            end.
            else if CheckFiles then
            do:
                ttFileStatus.IsAvailable = search(ttFileStatus.FileName) <> ?.
            end.                         
            hq:get-next.
        end.
        catch e as Progress.Lang.Error :
        	undo, throw new IllegalArgumentError("Parameters Path: " + quoter(pcPath) 
        	                                    + " Type: " + quoter(pcType) 
        	                                    + " TenantOrSubdir: " + quoter(pcTenantorSubdir)
        	                                    + " passed to AddTable caused error: ~n" 
        	                                    + e:GetMessage(1),e).	
        end catch.  
        finally:
            delete object Hq.    		
        end finally.
    end.       
     
    method public void Export():
        lastDump = now.    
        ttStatusSummary.LogTime = now.
        if this-object:FileName > "" then
            dataset dsstatus:write-json ("file",this-object:FileName,yes).   
        find first ttStatusSummary.
    end.
     
    /* the actual file name used in the dump may differ, since the we 
       dump logic may change slashes and possibly also differences with relative 
       name and full path (?)  so we pass both owner and file at start */ 
    method public void StartTable(ptable as char, ptype as character,powner as char,pfile as char):
        case pType:
            when TENANT_TABLES then
               find ttFileStatus where ttFileStatus.tablename = ptable
                                   and ttFileStatus.Type   = ptype
                                   and ttFileStatus.tenantname = pOwner 
                                   .
            when GROUP_TABLES then
               find ttFileStatus where ttFileStatus.tablename = ptable
                                   and ttFileStatus.Type      = ptype
                                   and ttFileStatus.tenantgroupname = pOwner 
                                    .
            when SHARED_TABLES then
               find ttFileStatus where ttFileStatus.tablename = ptable
                                   and ttFileStatus.Type   = ptype
                                     .
            otherwise 
                undo, throw new IllegalArgumentError("type " + quoter(ptype) + " passed to StartTable()").   
 
        end.    
        assign 
            ttFileStatus.filename = pfile
            ttFileStatus.startTime = now.
        
        if now - lastdump > Interval then 
           this-object:Export().
        
        catch e as Progress.Lang.Error :
            undo, throw new IllegalArgumentError("StartTable cannot find " + quoter(ptype) + " table " + quoter(ptable),e).   
        end catch.

        /* set isCompleted and endTime */
    end.       
      
    method public void EndTable(pname as character):
        EndTable(pname,?).
    end.         

    method public void EndTable(pname as character,pinumrows as int64):
        if not avail ttFileStatus
        or ttFileStatus.filename <> pName then 
        do:
            find ttFileStatus where ttFileStatus.filename = pname.
        end.      
        ttFileStatus.endTime = now.
        if piNumrows = ? then 
            ttFileStatus.isComplete =  not ttFileStatus.anyerror.
        else if ttFileStatus.ExpectedNumRows <> ? then
        do:                          
            if piNumrows = ttFileStatus.ExpectedNumRows then 
                ttFileStatus.isComplete = true.
            else if piNumrows lt ttFileStatus.ExpectedNumRows then 
                 ttFileStatus.isComplete = not ttFileStatus.Bailed.
            else ttFileStatus.isComplete = ?.   
        end.
        else ttFileStatus.isComplete = not ttFileStatus.Bailed.
        
        if pinumrows <> ? then
            ttFileStatus.ProcessedNumRows = pinumrows.
        case ttFileStatus.Type:
            when TENANT_TABLES then
               ttStatusSummary.NumProcessedTenantTables = ttStatusSummary.NumProcessedTenantTables + 1. 
            when GROUP_TABLES then
               ttStatusSummary.NumProcessedGroupTables = ttStatusSummary.NumProcessedGroupTables + 1. 
            when SHARED_TABLES then
               ttStatusSummary.NumProcessedSharedTables = ttStatusSummary.NumProcessedSharedTables + 1. 
        end.     
        if now - lastdump > Interval then 
           this-object:Export().
        
        catch e as Progress.Lang.Error :
            undo, throw new IllegalArgumentError("EndTable for " + quoter(pname) + " caused error: " + e:GetMessage(1),e).   
        end catch.
     
    end method.
    
    /** set expected num rows   */
    method public void SetTableExpectedNumRows(pname as character,pinum as int64).
        if not avail ttFileStatus
        or ttFileStatus.filename <> pName then 
        do:
            find ttFileStatus where ttFileStatus.filename = pname.
        end.      
        ttFileStatus.ExpectedNumRows = pinum.
        if now - lastdump > Interval then 
           this-object:Export().
        catch e as Progress.Lang.Error :
            undo, throw new IllegalArgumentError("AddTableExpectedNumRows does not understand " + quoter(pname),e).   
        end catch.
    
    end method.
    
    method public logical CountRow(pname as character): 
        if not avail ttFileStatus
        or ttFileStatus.filename <> pName then 
        do:
            find ttFileStatus where ttFileStatus.filename = pname.
        end.      
        ttFileStatus.ProcessedNumRows = ttFileStatus.ProcessedNumRows + 1.
        if now - lastdump > Interval then 
           this-object:Export().
        catch e as Progress.Lang.Error :
            undo, throw new IllegalArgumentError("CountRow does not understand " + quoter(pname),e).   
        end catch.
        
    end.     
    
    method public logical SetTableBailed(pname as character): 
        if not avail ttFileStatus
        or ttFileStatus.filename <> pName then 
        do:
            find ttFileStatus where ttFileStatus.filename = pname.
        end.      
        ttFileStatus.Bailed = true.
        if now - lastdump > Interval then 
           this-object:Export().
        catch e as Progress.Lang.Error :
            undo, throw new IllegalArgumentError("CountRow does not understand " + quoter(pname),e).   
        end catch.
        
    end.     
    
    /** called with any error, currently only use to keep track of any  */
    method public void AddTableError(pname as character,e as Error).
        AddTableError(pname,e:GetMessage(1)). 
    end.
    
     /** called with any error, currently only use to keep track of any  */
    method public void AddTableError(pname as character,msg as char).
        if not avail ttFileStatus
        or ttFileStatus.filename <> pName then 
        do:
            find ttFileStatus where ttFileStatus.filename = pname.
        end.      
        ttFileStatus.AnyError = true. 
        ttStatusSummary.AnyError = true.
        ttFileStatus.ErrorMessage = msg.
        if now - lastdump > Interval then 
           this-object:Export().
        catch e as Progress.Lang.Error :
            undo, throw new IllegalArgumentError("AddTableError does not understand " + quoter(pname),e).   
        end catch.
    end.
    
    method public void EndTask( ):
        ttStatusSummary.EndTime = now.       
        this-object:Export().
    end method.
    
end class.