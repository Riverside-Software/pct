/*************************************************************/
/* Copyright (c) 2011,2012 by Progress Software Corporation. */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    File        : Connection
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Wed Jun 01 21:18:09 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
 
using Progress.Lang.* from propath.
using Progress.Json.ObjectModel.JSONObject from propath.
using OpenEdge.DataAdmin.DataAdminService.

class OpenEdge.DataAdmin.Rest.Connection: 
    
	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	define public property DatabaseUser as char no-undo get. private set.
    define public property TenantName   as char no-undo get. private set.
	define public property TenantType   as char no-undo get. private set.
    define public property DomainName   as char no-undo get. private set.
    define public property IsMultiTenancyEnabled as logical no-undo get. private set.
    define public property IsSecurityAdministrator   as logical no-undo get. private set.
    define public property Name            as char no-undo get. private set.
    define public property URL             as char no-undo get. private set.
    define public property ProgressVersion as char no-undo get. private set. 
    define public property DatabaseVersion as char no-undo get. private set. 
    define public property Version         as int  no-undo 
       init 2
       get. 
    
    define variable ans as logical no-undo.
    
	define temp-table ttProp no-undo
	      field name as char 
	      field propvalue as char.
	      	
	constructor public Connection ( service as DataAdminService ):
        assign
            URL = service:URL
            Name = service:Name
            DatabaseUser = userid(Name)
            DatabaseVersion = dbVersion("dictdb")
            ProgressVersion = proversion
            TenantName = tenant-name(Name)
            DomainName = if num-entries(DatabaseUser,"@") > 1 
                         then entry(2,DatabaseUser,"@")
                         else "".
        /* TenantName = "" if not multi-tenant */                 
        if TenantName > "" then       
        do:                     
            isMultiTenancyEnabled = yes.
            TenantType = service:GetTenant(TenantName):Type.
        end.   
        
        RUN "prodict/_dctadmn.p" (DatabaseUser,OUTPUT ans).
        
        assign IsSecurityAdministrator = ans. 
        
        init().   
    end constructor.

    method private void init(): 
        AddProp("areas").
        AddProp("administrators").
        AddProp("tenantcounts").
        AddProp("creategroupscript","scripts/CreateGroupScript").
        AddProp("createtenantscript","scripts/CreateTenantScript").
        AddProp("datasecurity").
        AddProp("definitions").
        AddProp("domains").
        AddProp("authenticationsystems").
        AddProp("groups","tenantgroups").
        AddProp("permissions").
        AddProp("sequences").
        AddProp("schemas").
        AddProp("securitysummary").
        AddProp("securityoptions").
        AddProp("sequencevaluewriter","utilities/SequenceValueWriter").
        AddProp("tables").
        AddProp("tenants").
        AddProp("userpermissions").
        AddProp("users").
        AddProp("tabledatawriter","utilities/TableDataWriter").
        AddProp("tabledatareader","utilities/TableDataReader").
     
    end method.
    
    method private void AddProp(pcName as char, pcValue as char): 
        create ttProp.
        ttProp.name = pcname + "_url".
        ttProp.propvalue = pcValue.
    end method.
    
    method private void AddProp(pcName as char): 
        this-object:AddProp(pcname,pcname).
    end method.
    
    method public void ExportNormalized (pcfile as char):
        define variable jsonroot as JsonObject no-undo.    
        jsonroot  = GetJsonObject().
        jsonroot:WriteFile(pcfile, TRUE).
    end method.
    
    method protected JsonObject GetJsonObject():
        define variable jsonRoot  as JsonObject no-undo.    
        define variable cname as character no-undo.
        jsonRoot   = new JsonObject().   
        jsonRoot:Add("connection",GetJsonProperties()). 
        return Jsonroot.
    end method.
    
    method protected JsonObject GetJsonProperties():
        define variable json  as JsonObject no-undo.    
        define variable jsonfields  as JsonObject no-undo.    
        json   = new JsonObject(). 
        json:Add("version",this-object:Version).  
        json:Add("progressVersion",ProgressVersion).  
        json:Add("databaseVersion",DatabaseVersion).  
        json:Add("databaseUser",DatabaseUser).  
        json:Add("isMultiTenancyEnabled",IsMultiTenancyEnabled).    
        json:Add("tenantName",TenantName).  
        json:Add("tenantType",TenantType).  
        json:Add("domainName",DomainName).
        json:Add("isSecurityAdministrator",IsSecurityAdministrator).    
        for each ttProp by name:
            json:Add(ttProp.Name,URL + "/" + ttProp.propvalue).  
        end.    
        return json.
    end method.

end class.