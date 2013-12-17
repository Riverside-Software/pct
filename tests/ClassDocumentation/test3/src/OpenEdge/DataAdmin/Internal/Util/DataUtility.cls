/*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation.      */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : DataUtility
    Purpose     : Client side common wrapper for data admin dump/load of sequences 
                  and tables
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Apr 28 
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.ITableSet from propath.
using OpenEdge.DataAdmin.ITenantSet from propath.
using OpenEdge.DataAdmin.ITenantGroupSet from propath.
using OpenEdge.DataAdmin.IDataAdminService from propath.

using OpenEdge.DataAdmin.Binding.DataFileContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminModel from propath.
using OpenEdge.DataAdmin.Util.IDataAdminUtility from propath.
using OpenEdge.DataAdmin.IDataAdminCollection  from propath.
using OpenEdge.DataAdmin.Message.UtilityRequest from propath.
using OpenEdge.DataAdmin.Message.IUtilityRequest from propath.
using OpenEdge.DataAdmin.Message.IUtilityResponse from propath.
using OpenEdge.DataAdmin.Message.ITableResponse from propath.
using OpenEdge.DataAdmin.Util.IDataUtility from propath.
using OpenEdge.DataAdmin.Internal.Util.UtilityTenantSet from propath.
using OpenEdge.DataAdmin.Binding.UtilityTenantContext from propath. 
routine-level on error undo, throw.

class OpenEdge.DataAdmin.Internal.Util.DataUtility abstract implements IDataUtility, IDataAdminUtility : 
    {daschema/utilityoptions.i}
    {daschema/tenantdata.i}
    {daschema/tabledata.i}
    {daschema/groupdata.i}
        
    define protected dataset dsoption serialize-name "root" for ttUtilityOptions, ttTenantData, ttTableData, ttGroupData .

    /** IDataAdminUtility */
    define public property Name           as char   no-undo get. set.
    define public property LogStatus      as logical no-undo get. set.
    /** optional status log type */
/*    define public property LogType        as char no-undo get. set.*/
    define public property StatusFileName as character  no-undo get. set.
    define public property StatusInterval as integer  no-undo get. set.
    define public property TaskName       as char  no-undo get. set.
    
    /** IDataUtility */

/*    define public property FileName       as char no-undo get. set.*/
    define public property Directory      as char no-undo get. set.
    define public property Service        as IDataAdminService  no-undo get.    
   
    define public property TenantSelection      as char   no-undo init "all" get. set.   
    
    define private property TenantDataContext as IDataAdminModel  no-undo       
        get():
            if not valid-object(TenantDataContext) then 
            do: 
                TenantDataContext = CreateTenantContext().
                TenantDataContext:RowCreated:subscribe(TenantAdded).
                TenantDataContext:RowDeleted:subscribe(TenantDeleted).
            end.
            return TenantDataContext.
        end. 
        private set.
    
    define public property Tenants              as ITenantSet   no-undo 
        get():
            if not valid-object(Tenants) then
            do: 
               Tenants =  cast(TenantDataContext:GetCollection(),ITenantSet).
            end.
            return Tenants.
        end. 
        private set.
    
    constructor public DataUtility (cname as char  ):
		super ().
		create ttUtilityOptions.
		this-object:Name = cname.
		
    end constructor.

    method protected void Serialize():
       assign 
           ttUtilityOptions.Name =  this-object:Name
           ttUtilityOptions.LogStatus =  this-object:LogStatus
/* not in use   ttUtilityOptions.LogType =  this-object:LogType */
           ttUtilityOptions.StatusFileName =  this-object:StatusFileName
           ttUtilityOptions.StatusInterval =  this-object:StatusInterval 
           ttUtilityOptions.TaskName =  this-object:TaskName
           ttUtilityOptions.Directory =  this-object:Directory
           ttUtilityOptions.TenantSelection =  this-object:TenantSelection
        
            .
           
    end.     
    
    method private void TenantAdded():
        TenantSelection = "list".
    end.    
    
    method private void TenantDeleted():
        if tenants:COUNT = 0 then
           TenantSelection = "all".
    end.    
    
    method private UtilityTenantContext CreateTenantContext():
        return new UtilityTenantContext(dataset dsoption:handle).
    end method.
    
    method protected void Deserialize():
         assign 
            this-object:Name =  ttUtilityOptions.Name
            this-object:LogStatus =  ttUtilityOptions.LogStatus
/* not in use   this-object:LogType =  ttUtilityOptions.LogType*/
            this-object:StatusFileName =  ttUtilityOptions.StatusFileName
            this-object:StatusInterval =  ttUtilityOptions.StatusInterval 
            this-object:TaskName =  ttUtilityOptions.TaskName
            this-object:Directory =  ttUtilityOptions.Directory
            this-object:TenantSelection =  ttUtilityOptions.TenantSelection
         
            .
    end.     
    
    method protected handle GetDataset():
        return dataset dsoption:handle.      
    end method.      
   
    method public IUtilityRequest GetRequest().
        define variable hDs as handle no-undo.
        Serialize().  
        hDs = GetDataset().
        return new UtilityRequest(this-object:Name,hDs).
    end method. 
    
    /** stub  */ 
    method public void SetResponse(resp as IUtilityResponse):
    end method. 
    
    method public void ImportOptions(pcFile as char):
        find ttUtilityOptions.
        /* no name in json */
        delete ttUtilityOptions. 
        dataset dsoption:read-json ("file",pcfile,"replace").
        find ttUtilityOptions.
        ttUtilityOptions.name = this-object:Name.
        Deserialize().
    end.     
     
    method public void ExportOptions(pcFile as char):
        Serialize().
        dataset dsoption:write-json ("file",pcfile,yes).      
        find ttUtilityOptions. 
    end.     

end class.