/*************************************************************/
/* Copyright (c) 2012 by Progress Software Corporation.      */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/
/*------------------------------------------------------------------------
    File        : TableDataCommand.cls
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : rkumar
    Created     : 2012
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
 
using OpenEdge.DataAdmin.Message.IUtilityRequest  from propath.
using OpenEdge.DataAdmin.Message.IUtilityResponse from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath. 
using OpenEdge.DataAdmin.ServerCommand.IServerCommand from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.ForbiddenOperationError from propath.
using OpenEdge.DataAdmin.Error.DataAdminError from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Binding.TableDataMonitor from propath.
using OpenEdge.DataAdmin.Binding.ITableDataMonitor from propath.
using OpenEdge.DataAdmin.Core.FileUtil from propath.
using OpenEdge.DataAdmin.DataSource.DatabaseInfo from propath. 

routine-level on error undo, throw.

class OpenEdge.DataAdmin.ServerCommand.TableDataCommand abstract  implements IServerCommand: 
    /*------------------------------------------------------------------------------
            Purpose:                                                                      
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    {daschema/utilityoptions.i REFERENCE-ONLY}
    {daschema/tabledata.i REFERENCE-ONLY}
    {daschema/tenantdata.i REFERENCE-ONLY}
    {daschema/groupdata.i REFERENCE-ONLY}
    
    define private property GROUP_TABLES     as char init "group"  no-undo get. 
    define private property TENANT_TABLES    as char init "tenant" no-undo get. 
    define private property SHARED_TABLES    as char init "shared" no-undo get. 
    define private property LIST_SELECTION   as char init "list"   no-undo get. 
    define private property ALL_SELECTION    as char init "all"    no-undo get. 
    define private property TENANT_SELECTION as char init "tenant" no-undo get. 
    define private property SHARED_SELECTION as char init "shared" no-undo get. 
  
    
    /** the following temp-tables are all passed to Dump_d and load_d SetTable, 
        which expect the two fields databasename and name to be present. 
        They are also passed to the ITableDataMonitor Add*Tables, which expects 
        the databasename, schemaname, name and dumpname to be present in all tables and 
        the tenantgroupname to be present in the group table 
        It uses a dynamic query so the tt name and signature in general is irrelevant  */
    define temp-table ttNonMTTable no-undo
        field databasename as char 
        field schemaname as char 
        field name as char
        field dumpName as char
        field canExport as log
        field canImport as log
        index idxname as primary unique databasename name.
    
    define temp-table ttNoGroupTable no-undo
        field databasename as char 
        field schemaname as char 
        field name as char
        field dumpName as char
        field canExport as log
        field canImport as log
        index idxname as primary unique databasename name.
       
    define temp-table ttGroupTable no-undo
        field tenantgroupname as char
        field schemaname as char 
        field databasename as char
        field name as char
        field dumpName as char
        field canExport as log
        field canImport as log
        index idxname as primary unique databasename name.
    
    define temp-table ttProcessedGroup no-undo
        field name as char   
        index idxname as primary unique name.
    
    define protected abstract property IsLoad as logical no-undo get.  
    
    define protected property ProcedureHandle as handle no-undo get. set.
    
    /** subclasses have HookMonitor */
    define private property Monitor as ITableDataMonitor no-undo get. set.
    
    define protected property AnyGroupExists as logical no-undo
        init ? 
        get().
           if AnyGroupExists = ? then
           do:
               AnyGroupExists = can-find(first dictdb._Partition-Set). 
           end.     
           return AnyGroupExists.
        end.   
        private set.
    
    define property TenantOnly as logical no-undo 
        init ?
        get():
            if not avail ttUtilityOptions then 
                 undo, throw new AppError("TenantOnly property has no data.",?).
            return ttUtilityOptions.TableSelection = TENANT_SELECTION.
        end.
         
    define property SharedOnly as logical no-undo 
        init ?
        get():
            if not avail ttUtilityOptions then 
                 undo, throw new AppError("SharedOnly property has no data.",?).
            return ttUtilityOptions.TableSelection = SHARED_SELECTION.
        end.
        private set.

    define property PreRun as logical no-undo get. set.
    
    define private property FileUtil as FileUtil no-undo 
        get():
            if not valid-object(FileUtil) then
                FileUtil = new FileUtil().
            return FileUtil.     
        end. 
        set.
        
     define protected property DatabaseInfo as DatabaseInfo no-undo 
        get():
            if not valid-object(DatabaseInfo) then
                DatabaseInfo = new DatabaseInfo().
            return DatabaseInfo.     
        end. 
        set.
    
    define private variable mResponse as IUtilityResponse no-undo.
    
            
    constructor public TableDataCommand (databasename as char):
        super ().   
    end constructor.
   
    /** Start the procedure persistent */
    method abstract protected handle StartProcedure(): 
    
    /** Hook after start procedure and set of common properties
        It is a bit strict to enforce this, but all subclasses will
        need to set stuff  */
    method abstract protected void HookProcedure(): 
        
    /** call the execution procedure in the persistent procedure */ 
    method abstract protected void DoCommand(): 
    
    
    method public void Execute(prequest as IUtilityRequest):
        define variable hBuffer as handle no-undo.
        
        BindTables(pRequest:DataHandle).
        
        find ttUtilityOptions no-error.
    
        if ambiguous ttUtilityOptions then 
            undo, throw new IllegalArgumentError("More than one option record passed to Utility Command"). 
        if not avail ttUtilityOptions then 
            undo, throw new IllegalArgumentError("No option record passed to Utility Command"). 
         
        /** we support <value> for table selection to be consistent with dump_d and load_d 
            which must have brackets since the list also can have tables. 
            (we do not pass this on to the procedure) */ 
        if ttUtilityOptions.TableSelection begins "<" then 
            ttUtilityOptions.TableSelection = substr(ttUtilityOptions.TableSelection,2,length(ttUtilityOptions.TableSelection) - 2).
          
        /* Create the tt for all selected tables if not list (in which case we already have the tables) and 
           create the list of selected shared tables to pass to monitor and procedure handle.
           Do this befoe validate since it checks if table has records */
        if ttUtilityOptions.useGroupSelection eq false then 
            PrepareTableList().
        ValidateOptions(). 
        
        ProcedureHandle = StartProcedure().
        
        run setSilent in ProcedureHandle(true).
        run setUseDefaultLocation in ProcedureHandle(true).
        
        /* let procedure use default if not set */
        if ttUtilityOptions.SkipGroups = false and ttUtilityOptions.GroupDirectory > "" then
            run setGroupDirName in ProcedureHandle(ttUtilityOptions.GroupDirectory).
            
        run setNoLobs in ProcedureHandle(ttUtilityOptions.NoLobs).
        
        /* let procedure use default if not set */
        if ttUtilityOptions.NoLobs = false and ttUtilityOptions.LobDirectory > "" then
            run setLobDirName in ProcedureHandle(ttUtilityOptions.LobDirectory).
        
        HookProcedure().
                
        if ttUtilityOptions.LogStatus 
        or ttUtilityOptions.ValidateOnly  
        or isLoad = true /* always validate on load */
        or (IsLoad = false and ttUtilityOptions.OverwriteFiles = false) then
        do:
            assign
                Monitor = New TableDataMonitor()  
                Monitor:FileName = ttUtilityOptions.StatusFileName
                Monitor:TaskName = ttUtilityOptions.TaskName
                Monitor:NoLobs   = ttUtilityOptions.NoLobs 
                Monitor:Interval = ttUtilityOptions.StatusInterval 
                Monitor:ConnectionUrl = prequest:Url
                Monitor:CheckFiles = ttUtilityOptions.ValidateOnly or (IsLoad = false and ttUtilityOptions.OverwriteFiles = false)
                Monitor:IsLoad = this-object:IsLoad.
                /*  not in use  
                Monitor:LogType = ttUtilityOptions.LogType.*/
            
            hBuffer = pRequest:DataHandle:get-buffer-handle ("ttFilestatus").
            Monitor:BindFiles(hBuffer:table-handle).
            
            run setMonitor in ProcedureHandle (Monitor).
            PreRun = true.
            DoExecute(prequest).
            PreRun = false.
            
            if IsLoad = false and ttUtilityOptions.ValidateOnly = false and ttUtilityOptions.OverwriteFiles = false then
            do:
                if Monitor:AnyFileExists then
                     undo, throw new UnsupportedoperationError("One or more of the files already exists. Set OverwriteFiles to true to overwrite existing files." ). 
            end.
        end.
        
        if not ttUtilityOptions.ValidateOnly then
        do:
            if valid-object(Monitor) then
                Monitor:Export().
            
            DoExecute(prequest).
            
            if valid-object(Monitor) then
                Monitor:IsComplete = true.
        end.
        /* as of current we just use the same message as response */
        mResponse = cast(prequest,IUtilityResponse).
        catch e as Progress.Lang.Error :
            if valid-object(Monitor) then
        	do:
        	    Monitor:AnyError = true.
        	    Monitor:ErrorMessage = e:GetMessage(1).	
            end.
            undo, throw e.
        end catch.
        
        finally:          
            if valid-object(Monitor) then
                Monitor:EndTask().
            delete procedure ProcedureHandle no-error.		
        end finally.
    end.    
    
    method protected void ValidateOptions():
        define variable lMustExist as logical no-undo.
        define variable cMsg       as character no-undo.
         
        ttUtilityOptions.Directory = FileUtil:GetValidDirectory(ttUtilityOptions.Directory,true). 
        if ttUtilityOptions.useGroupSelection eq false then 
        do: 
            
            if isLoad 
            and ttUtilityOptions.NoLobs = false 
            and ttUtilityOptions.UseDefaultLocation
            and (ttUtilityOptions.TableSelection = ALL_SELECTION
                 or ttUtilityOptions.TableSelection = SHARED_SELECTION
                 or (ttUtilityOptions.TableSelection = LIST_SELECTION
                     and temp-table ttNonMTTable:has-records
                    ) 
                ) then
            do:
                FileUtil:GetValidDirectory(ttUtilityOptions.Directory,ttUtilityOptions.LobDirectory,true).       
            end.
            
            if lookup(ttUtilityOptions.TableSelection,ALL_SELECTION + "," + SHARED_SELECTION + "," + TENANT_SELECTION + "," + LIST_SELECTION) EQ 0 then
                undo, throw new IllegalArgumentError("TableSelection " + quoter(ttUtilityOptions.TableSelection) + " passed to Utility Command.").
            if lookup(ttUtilityOptions.TenantSelection,ALL_SELECTION + "," + LIST_SELECTION) EQ 0 then
                undo, throw new IllegalArgumentError("TenantSelection " + quoter(ttUtilityOptions.TenantSelection) + " passed to Utility Command.").
        end.
        else do:
            if not DatabaseInfo:IsMultiTenant then 
                undo, throw new IllegalArgumentError("UseGroupSelection is only supported in a multi-tenant database.").           
            if lookup(ttUtilityOptions.GroupSelection,ALL_SELECTION + "," + LIST_SELECTION) EQ 0 then
                undo, throw new IllegalArgumentError("GroupSelection " + quoter(ttUtilityOptions.GroupSelection) + " passed to Utility Command.").
            
            if not DatabaseInfo:IsMultiTenant then 
            do:           
                if ttUtilityOptions.TableSelection = TENANT_SELECTION then
                    undo, throw new IllegalArgumentError("Table selection ""tenant"" is only supported in a multi-tenant database.").
                /** set to shared if all */
                if ttUtilityOptions.TableSelection = ALL_SELECTION then 
                    ttUtilityOptions.TableSelection = SHARED_SELECTION.
                    
            end.     
        end.
        
        if ttUtilityOptions.UseDefaultLocation and not ttUtilityOptions.SkipGroups then
        do:
            if ttUtilityOptions.GroupDirectory begins "/" 
            or ttUtilityOptions.GroupDirectory begins "~\" 
            or index(ttUtilityOptions.GroupDirectory,":") <> 0 then
            do:
                undo, throw new IllegalArgumentError("Group directory " + quoter(ttUtilityOptions.GroupDirectory) + " is not a valid sub directory.").
            end.        
        end.
        
        if ttUtilityOptions.UseDefaultLocation and not ttUtilityOptions.NoLobs then
        do: 
            if ttUtilityOptions.LobDirectory begins "/" 
            or ttUtilityOptions.LobDirectory begins "~\" 
            or index(ttUtilityOptions.LobDirectory,":") <> 0 then
            do:
                undo, throw new IllegalArgumentError("Lob directory " + quoter(ttUtilityOptions.LobDirectory) + " is not a valid sub directory.").
            end.        
        end.
        /*
        if ttUtilityOptions.logStatus then
        do:
            if ttUtilityOptions.StatusFileName = "" or ttUtilityOptions.StatusFileName = ? then
                undo, throw new IllegalArgumentError("LogStatus is true, but StatusFileName is not specified."). 
        end.
        */    
    end method.
        
    method public void DoExecute(prequest as IUtilityRequest):     
        /* empty the tt that keeps track of processed groups  */
        empty temp-table ttProcessedGroup.  
        /* dump using tables and tenants selections */
        if ttUtilityOptions.useGroupSelection eq false then 
        do: 
            if temp-table ttNonMTTable:has-records then
            do:
                DoCommand(SHARED_TABLES,"",table ttNonMTTable by-reference).    
            end.
            
            if not SharedOnly then
            do:
                if ttUtilityOptions.TenantSelection EQ ALL_SELECTION then
                    ForAllTenants().
                else  
                    ForEachTenant().
            end.   
        end.
        else do:
            if ttUtilityOptions.GroupSelection = ALL_SELECTION then
                ForAllGroups().
            else if ttUtilityOptions.GroupSelection = LIST_SELECTION then
                ForEachGroup().
        end.    
    end method.    
    
    /** call the execution procedure in the persistent procedure 
        or just pass the tables to the monitor if PreRun */ 
    method protected void DoCommand(pcType as char, pcTenant as char,table-handle phTbl): 
        if PreRun then 
        do:  
            if valid-object(Monitor) then
            do:
                case pcType:
                    when TENANT_TABLES then
                        Monitor:AddTenantTables(ttUtilityOptions.Directory,pcTenant,table-handle phTbl by-reference).
                    when GROUP_TABLES then
                        Monitor:AddGroupTables(ttUtilityOptions.Directory,ttUtilityOptions.GroupDirectory,table-handle phTbl by-reference).
                    when SHARED_TABLES then
                        Monitor:AddSharedTables(ttUtilityOptions.Directory,table-handle phTbl by-reference).
                    otherwise 
                        undo, throw new IllegalArgumentError("Type " + quoter(pctype) + " passed to DoCommand"). 
                end.
            end.           
        end.
        else do on error undo, throw:
            run setTable in ProcedureHandle(table-handle phTbl by-reference).
            DoCommand().
        
            catch e as Progress.Lang.Error :
                handleError(e). 
            end catch.
      
        end.
               
    end method.
    
    method private void BindTables(pDataHandle as handle): 
        define variable hUtil     as handle no-undo.
        define variable hTable    as handle no-undo.
        define variable hTenant   as handle no-undo.
        define variable hGroup    as handle no-undo.
        hutil   = pDataHandle:get-buffer-handle("ttUtilityOptions").
        hTable  = pDataHandle:get-buffer-handle("ttTableData").
        hTenant = pDataHandle:get-buffer-handle("ttTenantData").
        hGroup  = pDataHandle:get-buffer-handle("ttGroupData").
        
        if valid-handle(hutil) then
        do:
            hUtil = HUtil:table-handle.
            BindUtility(table-handle hUtil bind).
        end.
        else 
            undo, throw new IllegalArgumentError("No option table passed to Utility Command"). 
        
        if valid-handle(hTable) then
        do:
            hTable = hTable:table-handle.
            BindTable(table-handle hTable bind).
        end.
        if valid-handle(hTenant) then
        do:
            hTenant = hTenant:table-handle.
            BindTenant(table-handle hTenant bind).
        end.
        if valid-handle(hGroup) then
        do:
            hGroup = hGroup:table-handle.
            BindGroup(table-handle hGroup bind).
        end.
    end method.
       
    method private void BindUtility(table ttUtilityOptions bind):
    end method.
    
    method private void BindTable(table ttTableData bind):
    end method. 

    method private void BindTenant(table ttTenantData bind):
    end method.
        
    method private void BindGroup(table ttGroupData bind):
    end method.
              
    method private void ForAllTenants(  ):
        /* skip super tenants */
        for each dictdb._tenant where dictdb._tenant._tenantid >= 0 no-lock
        on error undo, throw:
            DoTenant(dictdb._tenant._tenant-name ).               
        end.
    end method.
    
    method protected void DoTenant(pcTenant as char):
        define variable TableList   as character no-undo.
        define variable cDir        as character no-undo.
        define variable lDoTenant   as logical no-undo.
       
        if not PreRun then
            run setEffectiveTenant in Procedurehandle(pcTenant).
        
        SplitTableList(pcTenant).
        
        if temp-table ttNoGroupTable:has-records then
        do:
            lDoTenant = true.
            if IsLoad and ttUtilityOptions.UseDefaultLocation then
            do:
                /** if ignore missing directories just skip tenant instead of throwing error */ 
                if ttUtilityOptions.IgnoreMissingDirectories then
                do:     
                    /** pass false to avoid throw of error of dir does notexist 
                        */
                    cDir = FileUtil:GetValidDirectory(ttUtilityOptions.Directory,pcTenant,false).  
                    /* set dump to false if dir does not exist instead of throw */
                    if not FileUtil:IsValidDirectory(cDir) then
                        lDoTenant = false.
                end.
                else /* pass yes to throw error if dir does not exist */
                    cDir = FileUtil:GetValidDirectory(ttUtilityOptions.Directory,pcTenant,true).  
                
                if lDoTenant and ttUtilityOptions.NoLobs = false then  
                    FileUtil:GetValidDirectory(cDir,ttUtilityOptions.LobDirectory,true).           
            end.
            if lDoTenant then
                DoCommand(TENANT_TABLES,pcTenant,table ttNoGroupTable by-reference).   
        end.
            
        if not SkipGroups and temp-table ttGroupTable:has-records then
        do:
            for each ttGroupTable on error undo, throw:
                find ttProcessedGroup 
                     where ttProcessedGroup.name = ttGroupTable.tenantgroupname no-error. 
                if avail ttProcessedGroup then
                do:
                    delete ttGroupTable.
                end.    
                else do:
                    if IsLoad and ttUtilityOptions.UseDefaultLocation then
                    do:
                       /** check if dir exists 
                           throws error if parent, table or lob dir does not exist
                           returns false if ignore missing directories is true 
                           and table group directory does not exist.
                            */ 
                        if not ValidGroupDirectory(ttGroupTable.tenantgroupname) then
                            delete ttGroupTable.
                    end.
                    create ttProcessedGroup.
                    ttProcessedGroup.name = ttGroupTable.tenantgroupname. 
                end.    
            end.
            if temp-table ttGroupTable:has-records then
                DoCommand(GROUP_TABLES,ttUtilityOptions.GroupDirectory,table ttGroupTable by-reference).   
        end.     
    end method.
    
    method private void ForEachTenant( ):
        for each ttTenantData on error undo, throw:
            DoTenant(ttTenantData.Name).               
        end.    
    end method.
    
    /* dump all groups - all for super - only the logged in tenant's groups for non-super */ 
    method private void ForAllGroups( ):
        empty temp-table ttGroupTable.
        
        define variable lsuper   as logical no-undo.
        define variable iTenant  as int no-undo.
        define variable lCreate  as logical no-undo.
        iTenant = tenant-id("dictdb").
        lSuper = iTenant < 0.
        for each DICTDB._Partition-Set where dictdb._Partition-Set._PSet-Type = 1 no-lock,
            each dictdb._Partition-Set-Detail 
                where dictdb._Partition-Set-Detail._PSetId = dictdb._Partition-Set._PsetId
                  and dictdb._Partition-Set-Detail._object-type   =  dictdb._Partition-Set._object-type
                  and dictdb._Partition-Set-Detail._object-number =  dictdb._Partition-Set._object-number
                  and (lsuper or dictdb._Partition-Set-Detail._TenantId = iTenant)
                  no-lock,
            each dictdb._Tenant where dictdb._Tenant._tenantId = dictdb._Partition-Set-Detail._TenantId
            no-lock,
            each dictdb._file where dictdb._file._file-number = dictdb._Partition-Set-Detail._object-number
        
            no-lock
        break by dictdb._Tenant._tenant-name
        on error undo, throw:
            if not SkipSecuredTable(DICTDB._File._file-name) then 
            do: 
                find ttProcessedGroup where ttProcessedGroup.name = dictdb._Partition-Set._Pset-name no-error.
                if not avail ttProcessedGroup then
                do:
                    if IsLoad and ttUtilityOptions.UseDefaultLocation then
                        lCreate = ValidGroupDirectory(dictdb._Partition-Set._Pset-name).
                    else
                        lCreate = true.
                        
                    if lCreate then
                    do:
                        create ttGroupTable.
                        assign ttGroupTable.databasename = ldbname ("dictdb")
                               ttGroupTable.schemaname = dictdb._file._owner
                               ttGroupTable.name = dictdb._file._file-name
                               ttGroupTable.DumpName =  if dictdb._file._dump-name > "" 
                                                        then dictdb._file._dump-name
                                                        else dictdb._file._file-name 
                               ttGroupTable.CanImport = can-do(dictdb._File._Can-create,userid("dictdb"))
                                                        and
                                                        can-do(dictdb._File._Can-load,userid("dictdb"))
    
                               ttGroupTable.CanExport = can-do(dictdb._File._Can-read,userid("dictdb"))
                                                        and
                                                        can-do(dictdb._File._Can-dump,userid("dictdb"))
                               ttGroupTable.tenantgroupname = dictdb._Partition-Set._Pset-name.
                    end.
                    create ttProcessedGroup.
                    assign ttProcessedGroup.name = dictdb._Partition-Set._Pset-name.
                end.
            end. /* not skip */
            if last-of(dictdb._Tenant._tenant-name) then
            do:
                if temp-table ttGroupTable:has-records then
                do on error undo, throw:
                    if not Prerun then 
                        run setEffectiveTenant in Procedurehandle(dictdb._Tenant._tenant-name).
                    DoCommand(GROUP_TABLES,ttUtilityOptions.groupdirectory, table ttGroupTable by-reference).
                    finally:
                        empty temp-table ttGroupTable.
                    end finally.
                end.
            end.
        end.
    end method.
    
    method private void ForEachGroup():
        define variable lsuper   as logical no-undo.
        define variable iTenant  as integer no-undo.
        define variable lCreate  as logical no-undo.
        
        iTenant = tenant-id("dictdb"). 
        lsuper = iTenant < 0.
         
        /** check if the non-super tenant belongs in all of the selected groups */          
        if not lsuper then 
        do:
           for each ttGroupData,
               each DICTDB._Partition-Set where dictdb._Partition-Set._PSet-Name = ttGroupData.Name 
               no-lock on error undo,throw :
                  if not can-find(dictdb._Partition-Set-Detail 
                                  where dictdb._Partition-Set-Detail._PSetId = dictdb._Partition-Set._PsetId
                                    and dictdb._Partition-Set-Detail._object-type   =  dictdb._Partition-Set._object-type
                                    and dictdb._Partition-Set-Detail._object-number =  dictdb._Partition-Set._object-number
                                    and dictdb._Partition-Set-Detail._tenantid = itenant) then
                      undo, throw new ForbiddenOperationError("TenantGroup  " + quoter(ttGroupData.Name) + " cannot be accessed by the current tenant."). 
           end.    
        end.    
        
        empty temp-table ttGroupTable.
        for each ttGroupData,
            each DICTDB._Partition-Set where dictdb._Partition-Set._PSet-Name = ttGroupData.Name no-lock,
            each dictdb._Partition-Set-Detail 
                where dictdb._Partition-Set-Detail._PSetId = dictdb._Partition-Set._PsetId
                  and dictdb._Partition-Set-Detail._object-type   =  dictdb._Partition-Set._object-type
                  and dictdb._Partition-Set-Detail._object-number =  dictdb._Partition-Set._object-number
                  and (lsuper or dictdb._Partition-Set-Detail._TenantId = iTenant)
                no-lock,
            each dictdb._Tenant where dictdb._Tenant._tenantId = dictdb._Partition-Set-Detail._TenantId
            no-lock,
            each dictdb._file where dictdb._file._file-number = dictdb._Partition-Set-Detail._object-number
            no-lock
        break by dictdb._Tenant._tenant-name
        on error undo, throw:
            if not SkipSecuredTable(DICTDB._File._file-name) then 
            do:
                find ttProcessedGroup where ttProcessedGroup.name = dictdb._Partition-Set._Pset-name no-error.
                if not avail ttProcessedGroup then
                do:
                    if IsLoad and ttUtilityOptions.UseDefaultLocation then
                        lCreate = ValidGroupDirectory(dictdb._Partition-Set._Pset-name).
                    else
                        lCreate = true.
                    if lCreate then 
                    do:    
                        create ttGroupTable.
                        assign ttGroupTable.databasename = ldbname ("dictdb")
                               ttGroupTable.schemaname = dictdb._file._owner
                               ttGroupTable.name = dictdb._file._file-name
                               ttGroupTable.DumpName =  if dictdb._file._dump-name > "" 
                                                        then dictdb._file._dump-name
                                                        else dictdb._file._file-name 
                               ttGroupTable.CanImport = can-do(dictdb._File._Can-create,userid("dictdb"))
                                                        and
                                                        can-do(dictdb._File._Can-load,userid("dictdb"))
        
                               ttGroupTable.CanExport = can-do(dictdb._File._Can-read,userid("dictdb"))
                                                        and
                                                        can-do(dictdb._File._Can-dump,userid("dictdb"))
                               ttGroupTable.tenantgroupname = dictdb._Partition-Set._Pset-name.
                    end.    
                    create ttProcessedGroup.
                    assign ttProcessedGroup.name = dictdb._Partition-Set._Pset-name.
                end.
            end.
            if last-of(dictdb._Tenant._tenant-name) then
            do:
                if temp-table ttGroupTable:has-records then
                do on error undo, throw:
                    if not PreRun then 
                        run setEffectiveTenant in Procedurehandle(dictdb._Tenant._tenant-name).
                    DoCommand(GROUP_TABLES,ttUtilityOptions.groupdirectory, table ttGroupTable by-reference).
                    finally:
                        empty temp-table ttGroupTable.
                    end finally.
                end.
            end.
        end.
    end method.
   
    /** duplicates logic for ALL_SELECTION in dump_d.p and load_d.p 
        creates or keeps TableData that represents all selected tables 
        creates ttNonMTTable for all of these that are shared tables  */ 
    method private void PrepareTableList():
        empty temp-table ttNonMTTable.
        find first DICTDB._Db where DICTDB._db._db-local = true no-lock.  
        if ttUtilityOptions.TableSelection <> LIST_SELECTION then 
        do:  
            /* should be empty - just in case*/
            empty temp-table ttTableData.
            for each DICTDB._File WHERE DICTDB._File._File-number > 0
                                    AND   DICTDB._File._Db-recid = RECID(_Db)
                                    AND   (if TenantOnly  then _file-attributes[1] = true 
                                           else if SharedOnly then _file-attributes[1] <> true
                                           else true)
                                    AND   NOT DICTDB._File._Hidden
                                    no-lock on error undo, throw:
              
                IF INTEGER(DBVERSION("DICTDB")) > 8 
                AND DICTDB._File._Tbl-Type <> "V"     
                AND (DICTDB._File._Owner <> "PUB" AND DICTDB._File._Owner <> "_FOREIGN") THEN 
                    NEXT.
                
                if SkipSecuredTable(DICTDB._File._file-name) then 
                    next.
                
                create ttTableData. 
                ttTableData.Name = DICTDB._File._File-name.
                
                /* non mt tables must be passed to set table only once
                   - not for each tenant, so create list here 
                     the tt tables used for mt will be recreated for each tenant  */
                if dictdb._file._file-attributes[1] = false then
                do:
                    create ttNonMTTable.
                    assign ttNonMTTable.databasename = ldbname ("dictdb")
                           ttNonMTTable.schemaname = dictdb._file._owner
                           ttNonMTTable.name = dictdb._file._file-name
                           ttNonMTTable.dumpName = if dictdb._file._dump-name > "" 
                                                   then dictdb._file._dump-name
                                                   else dictdb._file._file-name
                           ttNonMTTable.CanImport = can-do(dictdb._File._Can-create,userid("dictdb"))
                                                    and
                                                    can-do(dictdb._File._Can-load,userid("dictdb"))
                           ttNonMTTable.CanExport = can-do(dictdb._File._Can-read,userid("dictdb"))
                                                    and
                                                    can-do(dictdb._File._Can-dump,userid("dictdb"))
                                                   . 
                end.
            end.   
        end.
        else 
        do:
            for each ttTableData on error undo, throw:
                find DICTDB._File of DICTDB._Db where DICTDB._File._File-name = ttTableData.Name
                                                      AND (DICTDB._File._Owner = "PUB" OR DICTDB._File._Owner = "_FOREIGN")
                                                      no-lock.
                 
                if SkipSecuredTable(DICTDB._File._file-name) then 
                    next.
                
                /* non mt tables must be passed to set table only once
                       - not for each tenant, so create list here 
                         the tt tables used for mt will be recreated for each tenant  */
                if dictdb._file._file-attributes[1] = false then
                do:    
                    create ttNonMTTable.
                    assign ttNonMTTable.databasename = ldbname ("dictdb")
                           ttNonMTTable.schemaname = dictdb._file._owner
                           ttNonMTTable.name = dictdb._file._file-name 
                           ttNonMTTable.dumpName = if dictdb._file._dump-name > "" 
                                                   then dictdb._file._dump-name
                                                   else dictdb._file._file-name
                           ttNonMTTable.CanImport = can-do(dictdb._File._Can-create,userid("dictdb"))
                                                    and
                                                    can-do(dictdb._File._Can-load,userid("dictdb"))
                           ttNonMTTable.CanExport = can-do(dictdb._File._Can-read,userid("dictdb"))
                                                    and
                                                    can-do(dictdb._File._Can-dump,userid("dictdb"))
                          . 
                end.
            end.         
        end.  
    end method.
    
    /** splits the tenants MT table selection in group and no group tables */
    method private void SplitTableList(pcTenant as char):
        empty temp-table ttGroupTable.
        empty temp-table ttNoGroupTable.
        
        find dictdb._tenant where dictdb._tenant._tenant-name = pcTenant no-lock.
        
        for each dictdb._Partition-Set-Detail 
                           where dictdb._Partition-Set-Detail._object-type = 1         
                             and dictdb._Partition-Set-Detail._Tenantid = dictdb._tenant._tenantid 
                             no-lock
                             on error undo, throw:
            find dictdb._file where  dictdb._file._file-number = dictdb._Partition-Set-Detail._object-number
            no-lock.
            
            if can-find(ttTableData where ttTableData.Name = dictdb._file._file-name) then
            do:
                find dictdb._Partition-Set
                       where dictdb._Partition-Set._object-type = dictdb._Partition-Set-Detail._object-type
                         and dictdb._Partition-Set._object-number = dictdb._Partition-Set-Detail._object-number
                         and dictdb._Partition-Set._PSetId = dictdb._Partition-Set-Detail._PSetId
                         and dictdb._Partition-Set._PSet-Type = 1
                         no-lock.
               create ttGroupTable.
               assign 
                   ttGroupTable.databasename = ldbname("DICTDB")
                   ttGroupTable.schemaname = dictdb._file._owner
                         
                   ttGroupTable.Name =  dictdb._file._file-name
                   ttGroupTable.dumpName = if dictdb._file._dump-name > "" 
                                            then dictdb._file._dump-name
                                            else dictdb._file._file-name 
                   ttGroupTable.CanImport = can-do(dictdb._File._Can-create,userid("dictdb"))
                                            and
                                            can-do(dictdb._File._Can-load,userid("dictdb"))
                   ttGroupTable.CanExport = can-do(dictdb._File._Can-read,userid("dictdb"))
                                            and
                                            can-do(dictdb._File._Can-dump,userid("dictdb"))
                   ttGroupTable.tenantgroupname = dictdb._Partition-Set._Pset-name.
            end.
        end.
        
        find first DICTDB._Db where DICTDB._db._db-local = true no-lock.  
        for each ttTableData on error undo, throw:
            if not can-find(ttGroupTable 
                         where  ttGroupTable.databasename = ldbname("DICTDB")
                           and  ttGroupTable.Name = ttTableData.Name) then
            do:
                find DICTDB._File of DICTDB._Db where DICTDB._File._File-name = ttTableData.Name
                                                     AND (DICTDB._File._Owner = "PUB" OR DICTDB._File._Owner = "_FOREIGN")
                                                     no-lock.
                if dictdb._file._file-attributes[1] then
                do:    
                    create ttNoGroupTable.
                    assign 
                        ttNoGroupTable.databasename = ldbname("DICTDB")
                        ttNoGroupTable.schemaname   = dictdb._file._owner
                        ttNoGroupTable.Name         = ttTableData.Name
                        ttNoGroupTable.Dumpname     = if dictdb._file._dump-name > "" 
                                                      then dictdb._file._dump-name
                                                      else dictdb._file._file-name
                        ttNoGroupTable.CanImport    = can-do(dictdb._File._Can-create,userid("dictdb"))
                                                      and
                                                      can-do(dictdb._File._Can-load,userid("dictdb"))
                        ttNoGroupTable.CanExport    = can-do(dictdb._File._Can-read,userid("dictdb"))
                                                      and
                                                      can-do(dictdb._File._Can-dump,userid("dictdb"))
                                                     
                     .
                end.
            end.
        end.
    end method.
    
       /** Return true if the table is to be skipped due to security. 
           Throws error if secured and SkipSecuredTables is false, unless ValidateOnly */
    method private logical SkipSecuredTable(pcfilename as char): 
        if not avail(dictdb._file) or dictdb._file._file-name <> pcfilename then
            find DICTDB._File of DICTDB._Db where DICTDB._File._File-name = pcfilename
                                             AND (DICTDB._File._Owner = "PUB" OR DICTDB._File._Owner = "_FOREIGN")
                                             no-lock.
        
        if IsLoad then
        do:
            /* TODO {prodict/dump/dtrigchk.i &OK = answer} */
            if not can-do(dictdb._File._Can-create,userid("dictdb"))
            or not can-do(dictdb._File._Can-load,userid("dictdb")) then
            do:
                if ttUtilityOptions.SkipSecuredTables then
                    return true.
                else if not ttUtilityOptions.ValidateOnly then
                    undo, throw CreatePermissionError(dictdb._File._file-name).
            end.    
        end.
        else do:    
             /* TODO  {prodict/dump/ltrigchk.i &OK = answer} */
            if not can-do(dictdb._File._Can-read,userid("dictdb"))
            or not can-do(dictdb._File._Can-dump,userid("dictdb")) then
            do:
                if ttUtilityOptions.SkipSecuredTables then
                    return true.
                else if not ttUtilityOptions.ValidateOnly then
                    undo, throw CreatePermissionError(dictdb._File._file-name).
            end.    
        end.
        return false.
    end method.
    
    /* validate group dir - as of current the parent ("groups") is validated each time this is called... */
    method private logical ValidGroupDirectory(pGroupName as char):
        define variable cDir as character no-undo.
        cDir = FileUtil:GetValidDirectory(ttUtilityOptions.Directory,ttUtilityOptions.GroupDirectory,true).            
        
        if ttUtilityOptions.IgnoreMissingDirectories then
        do:     
            /** pass false to avoid check and throw of error and check after instead */
            cDir = FileUtil:GetValidDirectory(cDir,pGroupName,false).  
            if not FileUtil:IsValidDirectory(cDir) then
                return false.
        end.
        else
            cDir = FileUtil:GetValidDirectory(cDir,pGroupName,true).
        
        if ttUtilityOptions.NoLobs = false then  
            FileUtil:GetValidDirectory(cDir,ttUtilityOptions.LobDirectory,true). 
        return true.    
    end method.
             
    method private void HandleError(e as error):
        if e:GetMessageNum(1) = 15984 then
        do: 
            undo, throw new ForbiddenOperationError("Table data for other tenants can only be accessed by a super-tenant.", e). 
        end.       
        undo,throw e.
    end. 
    
    method protected Error CreatePermissionError(pcTable as char):
        return new ForbiddenOperationError(substitute("You do not have privileges to &1 the &2 table. Change the table selection or set SkipSecuredTables to true to complete the &1.",
                                           if IsLoad then "load" else "dump",
                                           pcTable)). 
    end. 
    
    method public IUtilityResponse GetResponse():
        return mResponse.
    end method.
          
end class.