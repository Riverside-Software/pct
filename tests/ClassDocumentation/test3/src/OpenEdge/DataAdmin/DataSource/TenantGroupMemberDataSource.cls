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
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Lang.QueryString from propath. 


routine-level on error undo, throw.

class OpenEdge.DataAdmin.DataSource.TenantGroupMemberDataSource inherits DataSource: 
    define private variable msave as logical no-undo.   
    define private variable lKeepQuery as logical no-undo.     
	define private variable mMap as char no-undo 
	    init 
"ObjectType,_Partition-Set-Detail._Object-Type,~
ObjectNumber,_Partition-Set-Detail._Object-Number,~
TenantGroupId,_Partition-Set-Detail._PSetid,~
TenantId,_Partition-Set-Detail._Tenantid,~
TenantName,_Tenant._Tenant-name,~
TenantDescription,_Tenant._Tenant-Description,~
TenantGroupName,_Partition-Set._Pset-Name,~
TenantGroupDescription,_Partition-Set._Pset-Description". 
    
    define protected property FileGroup as char no-undo
        get():
            return "".
        end.
    
    define protected property TenantEqDetail as char no-undo
        get():
            return "_Tenant._Tenantid = _Partition-Set-Detail._Tenantid".               
        end.
       
    define protected property GroupEqDetail as char no-undo
        get():
           return " _Partition-Set._object-type = _Partition-Set-Detail._object-type "        
                  + " and _Partition-Set._object-number = _Partition-Set-Detail._object-number "
                  + " and _Partition-Set._PSetId = _Partition-Set-Detail._PSetId".
        end.
               
    constructor public TenantGroupMemberDataSource (pcFirstTable as char,pcLastTable as char):
        super (pcFirstTable + ",_Partition-Set-Detail," + pcLastTable,
               "dictdb." + pcFirstTable + ",dictdb._Partition-Set-Detail,dictdb." + pcLastTable, 
               mMap). 
        
        BaseQuery = "for each " + pcFirstTable + " no-lock,"
                  + " each _Partition-Set-Detail where &1 no-lock,"
                  + " each " + pcLastTable + " where &2 no-lock".
                     
        if pcFirstTable = "_Tenant" then 
            BaseQuery = substitute(BaseQuery,TenantEqDetail,GroupEqDetail).
        else 
            BaseQuery = substitute(BaseQuery,GroupEqDetail,TenantEqDetail).
     
       
    end constructor.
    
 	constructor public TenantGroupMemberDataSource ( ):
 	    this-object("_Partition-Set","_Tenant"). 
    end constructor.
    
    constructor public TenantGroupMemberDataSource (hTempSource as handle,cQuery as char) :
        super(hTempSource,"_Partition-set,_Partition-Set-Detail,_Tenant","dictdb._Partition-set,dictdb._Partition-Set-Detail,dictdb._Tenant",
                         mMap). 
        BaseQuery = cQuery.    
    end constructor.
    
    method public override logical Prepare(phBuffer as handle,pcTargetQuery as char,pcJoin as char):
        define variable oQueryString as class QueryString.
        define variable lOk          as logical    no-undo.
        define variable hParentRel   as handle     no-undo.
        define variable cQuery       as character no-undo.
        
        DataBuffer = phBuffer.    
        
        phBuffer:set-callback("After-Row-fill","AfterRow").
        
        CreateQuery().    
        hParentRel = ParentRelation.
        /* fieldmapping is set from constructor */
        DataBuffer:attach-data-source(DataSourceHandle:handle,FieldMapping) .
        
/*        hParentRel = ParentRelation.*/
        
        if pcTargetQuery > "" or pcJoin > '' or valid-handle(hParentRel) then
        do:
            oQueryString = new QueryString(pcTargetQuery,this-object).
           
            if pcJoin > '' then
            do:    
                oQueryString:addExpression(pcJoin).
            end.
            /* Data-Sources are defined with queries in the constructor in the event that
               there is a join involved. Add and transform the fill-where-string for the dependent 
               tables so that Progress can identify the related when filling the temp-tables.
              (columnValue ensures parent reference is NOT transformed) */
            else if valid-handle(hParentRel) and hParentRel:active and not hParentRel:reposition then
                oQueryString:addExpression(DataSourceHandle:fill-where-string).
            cQuery = oQueryString:BuildQueryString(Tables).
         
            lok = QueryHandle:query-prepare (cQuery).
            
            delete object oQueryString. 
     
        end.
        else
            lok = Prepare().
       
        return lOk.
         
        catch e as Progress.Lang.Error :
        	 
        	undo, throw new IllegalArgumentError(e:GetMessage(1)).
       
        end catch.
    end method. 

    /** Save all  
         @param buffer the temp-table buffer handle with data */
    method public override logical Save(bufferHandle as handle):
        return this-object:Save(bufferHandle,?).  
    end method.  
    
    /** Save changes of specified state 
         @param buffer the temp-table buffer handle with data
         @param state  the row-state to save (row-created, row-deleted or row-modified)
                       ? - save all  */
    method public override logical Save(phBuffer as handle,piState as int):
        define variable hBeforeBuff as handle    no-undo.
        define variable lnew        as logical   no-undo. 
        define variable hquery      as handle    no-undo.
        define variable iType       as integer   no-undo.
        define variable cType       as character no-undo.
        define variable hDataset    as handle no-undo.
        define variable cAccess     as character no-undo.
        define variable lSaved      as logical no-undo.
        
        if piState < 1 or pistate > 3 then
            undo, throw new IllegalArgumentError("Invalid state " + string(piState) + " passed to save." ).
        
        create query hquery.
        hBeforeBuff = phBuffer:before-buffer.
        
        hquery:add-buffer(hBeforeBuff).
        hQuery:query-prepare("for each ttTenantGroupMemberCopy"
                               + (if piState <> ? 
                                  then " where row-state(ttTenantGroupMemberCopy) = " + string(piState)
                                  else "")   
                             ).    
        hquery:query-open().
        
        do transaction on error undo, throw:
            do while true:
                
                hquery:get-next.
                if not hBeforebuff:avail then 
                    leave.
                
                
                if hBeforeBuff:row-state = row-deleted then 
                do:
                    find dictdb._Tenant where dictdb._Tenant._Tenant-name = hBeforeBuff::TenantName no-lock.
                    find dictdb._Partition-Set where dictdb._Partition-Set._PSet-Name = hBeforeBuff::TenantGroupName no-lock.    
                    
                    find dictdb._Partition-Set-Detail
                         where dictdb._Partition-Set-Detail._PSetId = dictdb._Partition-Set._PSetId
                           and dictdb._Partition-Set-Detail._Object-Type = dictdb._Partition-Set._Object-Type
                           and dictdb._Partition-Set-Detail._Object-number = dictdb._Partition-Set._Object-number
                           and dictdb._Partition-Set-Detail._TenantId = dictdb._Tenant._TenantId exclusive-lock no-wait. 
                
                    delete dictdb._Partition-Set-Detail.
                    
                end.    
                   
                 /* not in use
                eslse if mod
                
                 assign 
                   dictdb._Partition-Set-Detail._Permissions = phBuffer::Permissions.
             
                */
            
                else if hBeforeBuff:row-state = row-created then 
                do:                
                    phBuffer:find-by-rowid (hBeforeBuff:after-rowid).
                
                    find dictdb._Tenant where dictdb._Tenant._Tenant-name = phBuffer::TenantName no-lock.
                    find dictdb._Partition-Set where dictdb._Partition-Set._PSet-Name = phBuffer::TenantGroupName no-lock.    
   
                    
                    create dictdb._Partition-Set-Detail.
                    assign
                        dictdb._Partition-Set-Detail._Object-Type = dictdb._Partition-Set._Object-Type
                        dictdb._Partition-Set-Detail._Object-number = dictdb._Partition-Set._Object-number
                        dictdb._Partition-Set-Detail._PSetId = dictdb._Partition-Set._PSetId
                        dictdb._Partition-Set-Detail._TenantId = dictdb._Tenant._TenantId
                        dictdb._Partition-Set-Detail._Permissions = 0
                        phBuffer::TenantGroupName = dictdb._Partition-Set._PSet-name
                        phBuffer::ObjectType = dictdb._Partition-Set-Detail._Object-Type
                        phBuffer::ObjectNumber =  dictdb._Partition-Set-Detail._Object-number
                        phBuffer::TenantGroupId = dictdb._Partition-Set-Detail._PSetId
                        /* somewhat questionable - only for json */
                        phBuffer::TenantDescription = dictdb._Tenant._Tenant-Description
                        .
                        
                    
                    hdataset = phBuffer:dataset.
                    mSave = true.
                    AfterRow (dataset-handle hdataset by-reference).
                end. 
                 
                lSaved = true.
            end. 
            
            catch e as Progress.Lang.Error :
                undo, throw new DataAccessError(
                    new DataMapper("Partition Group,_Partition-Set,Tenant,_Tenant",FieldMapping),
                    e). 
            end catch.
        end.
        return lSaved. 
        finally:
           delete object hQuery no-error. 		
        end finally.       
    end method.    
    
    method public override void AfterRow(dataset-handle hds):
        define variable hbuffer as handle no-undo.
        define variable TenantGroupUrl as character no-undo.   
        define variable hGroup as handle no-undo.
        define variable iSource as integer no-undo.
        hBuffer   = hds:get-buffer-handle("ttTenantGroupMember").     
        
        find dictdb._file where _file._file-number = hBuffer::ObjectNumber no-lock.        
        assign
            hBuffer::TableName = dictdb._file._File-name
            hBuffer::SchemaName = dictdb._file._owner
            TenantGroupUrl          = "/tenantgroups/" + WebUtil:UrlEncode(hBuffer::TenantGroupname)  
            hBuffer::TenantGroupUrl = url + TenantGroupUrl 
            hBuffer::TenantUrl         = url + "/tenants/" + WebUtil:UrlEncode(hBuffer::TenantName)  
            hBuffer::Url               = url + TenantGroupUrl + "/tenantgroupmembers/" + WebUtil:UrlEncode(hBuffer::TenantName).    
    
    end method.                 
    
    method public override character ColumnSource (pcColumn as char):
        define variable cout as character no-undo.
        if pcColumn = "ttTenantGroupMember.TenantName" then 
        do:
            return "_tenant._tenant-name".
        end.
        else
        if pcColumn = "ttTenantGroupMember.TenantGroupName" then 
        do:
            return "_Partition-Set._PSet-name".    
        end.
        else
            return super:ColumnSource(pcColumn).
    
    end method.  
 
end class.