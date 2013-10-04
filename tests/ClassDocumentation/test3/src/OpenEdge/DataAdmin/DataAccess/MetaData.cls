 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : MetaData 
    Purpose     : Information about classes and their properties based on 
                  datasource mapping                    
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : Currently used for permissions, based on permissions 
                  in the database 
  ----------------------------------------------------------------------*/
 
routine-level on error undo, throw.

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAccess.IDataAccess from propath.
using OpenEdge.DataAdmin.DataAccess.DataAccess from propath.


using OpenEdge.DataAdmin.DataSource.DataSource from propath.
using OpenEdge.DataAdmin.DataSource.IDataSource from propath.
 
using OpenEdge.DataAdmin.DataSource.DatabaseInfo from propath.
 
using OpenEdge.DataAdmin.DataSource.PermissionDataSource from propath.
using OpenEdge.DataAdmin.DataSource.PropertyPermissionDataSource from propath.
 
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.DataAccess.DataAccessError from propath.

class OpenEdge.DataAdmin.DataAccess.MetaData inherits DataAccess implements IDataAccess : 
 
    define temp-table ttMap no-undo
        field TargetTable as char 
        field TargetField as char 
        field SourceTable as char 
        
        field SourceField as char 
      index trg  as primary unique  TargetTable  TargetField
      index src SourceTable  SourceField.
   
    define private variable TenantURL as character no-undo.
    
    define private variable mStart as integer no-undo.
    define private variable mSingle as logical no-undo.
    define private variable domainsURL     as character no-undo.
    define private variable  URL     as character no-undo.
    
    
    define public property BaseQuery as character no-undo
        get.     
        set.
    
    method public override void FetchData(msg as IFetchRequest):
        Url = msg:url.
        DatasetHandle = msg:DataHandle.       
        FillData(msg).
    end method.
    
    method public void FillData(msg as IFetchRequest):
        define variable hBuffer as handle no-undo.
        
        case msg:EntityName:
          
            when "Permission" then
            do:
                FillPermission(msg).
            end.
         
        end case.   
      
    end method.    
    
    method private void  FillPermission(msg  as IFetchRequest):
        define variable hPermission as handle no-undo.
        define variable hFieldPermission as handle no-undo.
        define variable tablePerm        as PermissionDataSource no-undo.
        define variable fieldPerm        as PropertyPermissionDataSource no-undo.
        
        define variable i                as integer no-undo.
        define variable hMapBuffer       as handle no-undo.
        define variable mapsrc           as DataSource no-undo.
        define variable hFieldRel        as handle no-undo.
        define variable cTableWhere      as character no-undo.
        define variable hBuffer          as handle no-undo.
        define variable iStart           as integer no-undo.
        
        /* the assumption is that usertable and userfield is first, so we 
           add to start */
        hPermission = msg:DataHandle:get-buffer-handle ("ttUserTablePermission").
        
        if valid-handle(hPermission) then
        do:
            tablePerm = new PermissionDataSource().
            iStart = 1.
        end.
        
        hFieldPermission = msg:DataHandle:get-buffer-handle ("ttUserFieldPermission").
        if valid-handle(hFieldPermission) then
        do:
            hFieldRel = hFieldPermission:parent-relation.  
            hFieldRel:active = false.
            fieldPerm = new PropertyPermissionDataSource(buffer ttMap:handle,
                                  "_File._file-name = ttMap.SourceTable",
                                  "_Field._field-name = ttMap.SourceField").
            
            iStart = iStart + 1. 
        end.
        iStart = iStart + 1. 
        /* The rest of the tables are only used for mapping  */
        do i = iStart to msg:DataHandle:num-buffers:
            hBuffer = msg:DataHandle:get-buffer-handle(i).
            hBuffer:fill-mode = "no-fill".
        end.
        
        do i = iStart to msg:DataHandle:num-buffers:
            hBuffer = msg:DataHandle:get-buffer-handle(i).
            mapsrc = GetSource(hBuffer).
            tablePerm:TableMap = hBuffer:name + "," + mapsrc:Table.
            cTableWhere = "for each ttUserTablePermission where ttUserTablePermission.name = " + quoter(hBuffer:name).
            PrepareDataSource(tablePerm,hPermission,cTableWhere,"Append").
            PrepareDataSource(fieldPerm,hFieldPermission,"","Append").          
            CreateMapOrField(hBuffer,hFieldPermission,mapsrc). 
            DatasetHandle:Fill().                      
        end.  
           
        if valid-handle(hPermission) then
            hPermission:detach-data-source ().
        if valid-handle(hFieldPermission) then
            hFieldPermission:detach-data-source ().
/*        if valid-handle(hTablerel) then*/
/*              hTablerel:active = true. */
        if valid-handle(hFieldRel) then
             hFieldRel:active = true.              
        
        finally:
            delete object fieldPerm no-error.
            delete object tablePerm no-error.           		
        end finally.
               
    end method.  
    
    /* create a map table to use to rename the tablename and fieldname in after row events or 
       or just create the tt from the buffer for unmapped fields */   
    method private void CreateMapOrField (phBuffer as handle,phFieldBuffer as handle,pdatasrc as DataSource):
        define variable i            as integer no-undo.  
        define variable cField       as character no-undo.
        define variable cMap         as character no-undo.       
        define variable cSourceField as character no-undo.
        define variable datasrc      as DataSource no-undo.       
        define variable dbinfo       as DatabaseInfo no-undo.
        
        empty temp-table ttMap.
            
        do i = 1 to phbuffer:num-fields:             
             
             cField  = phbuffer:name + "." + phbuffer:buffer-field(i):name.          
             cSourceField = pdatasrc:ColumnSource(cField). 
                 
             if cSourceField <> cField and (csourcefield begins "rowid(") = false then
             do:
                 
                 create ttMap.
                 assign 
                     ttMap.TargetTable = phbuffer:name 
                     ttMap.TargetField = phbuffer:buffer-field(i):name
                     ttMap.SourceTable = entry(1,cSourceField,".") 
                     ttMap.SourceField = entry(2,cSourceField,".")
                     /* remove array from name */
                     ttMap.SourceField = entry(1,ttMap.SourceField,"[").
                  
           
             end.
             else do:
                 phFieldBuffer:buffer-create().
                 assign 
                     phFieldBuffer::Tablename = phbuffer:name
                     phFieldBuffer::name = phbuffer:buffer-field(i):name.  
                 
                 /* ttSequencevalue is only accessible for super-tenant.  
                    this is for ttSequenceValue.CurrentValue, which is the only 
                    unmapped field, but the logic does in principle apply to any 
                    unmapped field so we don't check for the field name  */  
                 if phbuffer:name = "ttSequenceValue" then
                 do:
                     dbinfo = new DatabaseInfo().                   
                     assign
                         phFieldBuffer::canRead = dbinfo:IsUserSuperTenant
                         phFieldBuffer::canWrite = dbinfo:IsUserSuperTenant.
                 end.    
                 else
                     phFieldBuffer::canRead = true.                  
             end.    
        end.  /*  do i = 1 to phbuffer:num-fields */       
    end method. 
    
    method private DataSource GetSource(phBuffer as handle):
        define variable src as DataSource no-undo.
        define variable cName as character no-undo.
        
        cName = substr(phbuffer:name,3) + "DataSource".    
        cName = "OpenEdge.DataAdmin.DataSource." + cName.
        src = dynamic-new cName().
        src:Attach(phBuffer).
        return src.
    end method.
    
    method protected logical PrepareDataSource(ds as IDataSource,phbuffer as handle,pcQuery as char,pcMode as char):      
        ds:FillMode = pcMode.
        ds:Url = Url.
        return ds:Prepare(phBuffer,pcQuery,"").
    end method.     
 
        
end class.
