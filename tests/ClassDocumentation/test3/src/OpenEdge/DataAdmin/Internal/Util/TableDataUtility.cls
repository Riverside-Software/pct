/*************************************************************/
/* Copyright (c) 2011,2012 by Progress Software Corporation. */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/
 /*------------------------------------------------------------------------
    File        : TableDataUtility
    Purpose     : common for dump and load of tables tenant data in .d 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Progress.Lang.*.
using OpenEdge.DataAdmin.Internal.Util.DataUtility.
using OpenEdge.DataAdmin.Util.ITableDataUtility.
using OpenEdge.DataAdmin.ITenantGroupSet.
using OpenEdge.DataAdmin.ITableSet.
using OpenEdge.DataAdmin.IDataFileList.

using OpenEdge.DataAdmin.Binding.IContextTree.
using OpenEdge.DataAdmin.Binding.ContextTree.
using OpenEdge.DataAdmin.Binding.DataFileContext.
using OpenEdge.DataAdmin.Binding.IDataAdminModel.
using OpenEdge.DataAdmin.Binding.UtilityTableContext.
using OpenEdge.DataAdmin.Binding.UtilityTenantGroupContext.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Message.IUtilityResponse.
/**
    Utility for Dump and Load of .d files 
    Supports only UseDefaultLocation 
*/
class OpenEdge.DataAdmin.Internal.Util.TableDataUtility abstract inherits DataUtility implements ITableDataUtility: 
    
    define public property ValidateOnly         as logical no-undo get. set.  
    define public property NoLobs               as logical no-undo get. set.
/*    define public property TenantDirectory      as char no-undo get. set.*/
/*    define public property TenantLobDirectory      as char no-undo get. set.*/
    define public property LobDirectory         as char no-undo init "lobs" get. set.
    define public property GroupDirectory       as char no-undo init "groups" get. set. 
/*    define public property GroupLobDirectory    as char no-undo get. set.*/
   
    define public property UseDefaultLocation as logical init yes  no-undo 
        get. 
        set(pDef as logical):
            if not pDef then 
                undo, throw new OpenEdge.DataAdmin.Error.UnsupportedOperationError("The dump and load utilities currently only support default directory.").
        end.  

    define public property TableSelection       as char init "all" no-undo get. set.               
    define public property GroupSelection       as char init "all" no-undo get. set.
    define public property UseGroupSelection    as logical   no-undo 
        get. 
        set.
    
    define public property SkipGroups           as logical   no-undo get. set.   
    
     /** Set to yes to skip secured tables  */
    define public property SkipSecuredTables    as logical   no-undo get. set.   
    
    define private property TenantGroupDataContext as IDataAdminModel  no-undo       
        get():
            if not valid-object(TenantGroupDataContext) then 
            do:
                TenantGroupDataContext = CreateTenantGroupContext().
                TenantGroupDataContext:RowCreated:subscribe(TenantGroupAdded).
                TenantGroupDataContext:RowDeleted:subscribe(TenantGroupDeleted).
            end.
            return TenantGroupDataContext.
        end. 
        private set.
    
    define private property TableDataContext as IDataAdminModel  no-undo       
        get():
            if not valid-object(TableDataContext) then 
            do:
               TableDataContext = CreateTableContext().
               TableDataContext:RowCreated:subscribe(TableAdded).
               TableDataContext:RowDeleted:subscribe(TableDeleted).
            end.
            return TableDataContext.
        end. 
        private set.
    
    define public property TenantGroups         as ITenantGroupSet   no-undo 
        get(): 
            if not valid-object(TenantGroups) then 
               TenantGroups =  cast(TenantGroupDataContext:GetCollection(),ITenantGroupSet).
            return TenantGroups.
        end. 
        private set.
           
    define public property Tables         as ITableSet   no-undo 
        get(): 
            if not valid-object(Tables) then 
               Tables =  cast(TableDataContext:GetCollection(),ITableSet).
            return Tables.
        end. 
        private set.
        
    define protected property DataFileContext as DataFileContext get. set.
    
	define public property Files                as IDataFileList     no-undo 
	    get():
	        if not valid-object(Files) then
	            Files = cast(DataFileContext:GetCollection(),IDataFileList).
	        return Files.
	    end. 
	    private set.   
    
    define public property ProblemFiles as IDataFileList     no-undo 
        get():
            if not valid-object(ProblemFiles) then
               ProblemFiles = cast(DataFileContext:GetCollection(GetValidateQuery()),IDataFileList).        
            return ProblemFiles. 
        end. 
        private set.   
    
	constructor public TableDataUtility ( pname as char ):
        super (pname).
		DataFileContext = new DataFileContext().
	end constructor.
    
    method protected abstract char GetValidateQuery().
    
    method private UtilityTenantGroupContext CreateTenantGroupContext():
        return new UtilityTenantGroupContext(dataset dsoption:handle).
    end method.
    
    method private UtilityTableContext CreateTableContext():
        return new UtilityTableContext(dataset dsoption:handle).
    end method.
        
    method override protected handle GetDataset():
        if valid-object(DataFileContext) then
        do:
            define variable contexttree as IContextTree no-undo.
            define variable hcopy as handle no-undo.
            define variable hdataset as handle no-undo.
            contexttree = new ContextTree().
            contextTree:SetHandle("UtilityOptions",temp-table ttUtilityOptions:default-buffer-handle).
            contextTree:SetHandle("Tables",temp-table ttTableData:default-buffer-handle).
            contextTree:SetHandle("Tenants",temp-table ttTenantData:default-buffer-handle).
            contextTree:SetHandle("Groups",temp-table ttGroupData:default-buffer-handle).
            DataFileContext:AddTableTo(contextTree).
            return contextTree:GetReadHandle().
        end.
        else 
            return super:GetDataset().       
    end method.      
    
    /** TODO: move to override in subclass that has ttFilestatus) */ 
    method public override void SetResponse(resp as IUtilityResponse):
        define variable h as handle no-undo.
        /*
        define variable tbl as ITableResponse no-undo.
        tbl = resp:GetTableResponse("ttfilestatus").
        */
        if valid-handle(resp:DataHandle) then 
        do: 
            h = resp:DataHandle:get-buffer-handle("ttFilestatus").
            DataFileContext:DataRefreshed(resp).
            if resp:DataHandle <> super:GetDataset() then
                delete object resp:DataHandle.   
        end.            
    end method. 
    
    method protected override void Serialize():
        /* assigns fields for super class */
        super:Serialize().
        assign 
            ttUtilityOptions.ValidateOnly       = this-object:ValidateOnly 
            ttUtilityOptions.NoLobs             = this-object:NoLobs
            ttUtilityOptions.LobDirectory       = this-object:LobDirectory
            ttUtilityOptions.GroupDirectory     = this-object:GroupDirectory
            ttUtilityOptions.UseDefaultLocation = this-object:UseDefaultLocation
            ttUtilityOptions.TableSelection     = this-object:TableSelection
            ttUtilityOptions.GroupSelection     = this-object:GroupSelection  
            ttUtilityOptions.UseGroupSelection  = this-object:UseGroupSelection  
            ttUtilityOptions.SkipGroups         = this-object:SkipGroups  
            ttUtilityOptions.SkipSecuredTables  = this-object:SkipSecuredTables  
            .
    end.     
    
    method protected override void Deserialize():
        /* assigns fields for super class */
        super:Deserialize().
        assign 
            this-object:ValidateOnly       = ttUtilityOptions.ValidateOnly
            this-object:NoLobs             = ttUtilityOptions.NoLobs  
            this-object:LobDirectory       = ttUtilityOptions.LobDirectory  
            this-object:GroupDirectory     = ttUtilityOptions.GroupDirectory  
            this-object:UseDefaultLocation = ttUtilityOptions.UseDefaultLocation  
            this-object:TableSelection     = ttUtilityOptions.TableSelection 
            this-object:GroupSelection     = ttUtilityOptions.GroupSelection   
            this-object:UseGroupSelection  = ttUtilityOptions.UseGroupSelection 
            this-object:SkipGroups         = ttUtilityOptions.SkipGroups 
            this-object:SkipSecuredTables  = ttUtilityOptions.SkipSecuredTables 
            .
    end.     
    
    method private void TableAdded():
        TableSelection = "list".
    end.    
    
    method private void TableDeleted():
        if Tables:Count = 0 then
           TableSelection = "all".
    end.    
    
    method private void TenantGroupAdded():
        GroupSelection = "list".
        UseGroupSelection = true.
    end.    
    
    method private void TenantGroupDeleted():
        if TenantGroups:Count = 0 then
        do:
            GroupSelection = "all".
            UseGroupSelection = false.
        end.   
    end.    
    
end class.