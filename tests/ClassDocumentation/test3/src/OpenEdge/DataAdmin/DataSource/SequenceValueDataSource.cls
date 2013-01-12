 /*************************************************************/
  /* Copyright (c) 2011 by progress Software Corporation.      */
  /*                                                           */
  /* all rights reserved.  no part of this program or document */
  /* may be  reproduced in  any form  or by  any means without */
  /* permission in writing from progress Software Corporation. */
  /*************************************************************/
 /*------------------------------------------------------------------------
    File        : SequenceValuesDataSource
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sat Sep 04 02:01:56 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using Progress.Database.DBConfig from propath. 
 
using OpenEdge.DataAdmin.DataSource.TenantDataSource from propath.
 
using OpenEdge.DataAdmin.Lang.QueryString from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.OperationError from propath.
using OpenEdge.DataAdmin.DataAccess.DataAccessError from propath.
using OpenEdge.DataAdmin.DataAccess.DataMapper from propath.
routine-level on error undo, throw.

class OpenEdge.DataAdmin.DataSource.SequenceValueDataSource inherits TenantDataSource: 
   
    /* these could have been properties with getters that just returned data based on URl,
       but they are used in rowafter event and while the getters are very fast, overrided getters 
       are still 20 times slower than variables/props with no overrides. We're talking milliseconds, but 
       enough to substantially reduce throughput for this datasource, which may need to read a lot of records  */ 
  
    define protected variable TenantURL as character no-undo  .
    define protected variable SequenceURL as character no-undo  .
    define private variable mSaving as logical no-undo.
    define private property SequenceExpression as char no-undo
        get():
            return "_sequence._Seq-attributes[1] = 'true'".
        end.
    
    define private property TenantExpression as char no-undo
        get():
            return "_tenant._Tenant-Type <> '2'".
        end.
    
    define protected property DBConfig as DBConfig no-undo
        get():
            if not valid-object(DBConfig) then        
                DBConfig = new DBConfig(ldbname("dictdb")).
            return DBConfig.
        end.
        private set.
    
    define temp-table ttState no-undo
        field ObjectState as char.
     
    define protected property mMap as char no-undo
        init "TenantName,_Tenant-name,TenantId,_Tenantid,SequenceName,_Seq-name,SchemaName,_Seq-owner"
        get.
   
    constructor public SequenceValueDataSource () :
        super(mMap).  
        PhysicalTables = PhysicalTables + ",dictdb._sequence".
        Tables = Tables + ",_sequence".
    end method. 
   
    constructor public SequenceValueDataSource (pcTable as char,pBaseQuery as char) :
        define variable iLock as integer no-undo.
        define variable qstr as QueryString no-undo.
        this-object(). 
        /* order does not matter there is no join between the two tables */
        if pctable = "tenant" then
        do:
            BaseQuery = pBaseQuery + ", each _sequence where " + SequenceExpression + " no-lock".   
            qstr = new QueryString("where " + TenantExpression,BaseQuery). 
            BaseQuery = qstr:BuildQueryString(Tables).
            delete object qstr.
        end.    
        else if pctable = "sequence" then
        do:
            pBaseQuery = trim(pBaseQuery).
            entry(1,pBaseQuery," ") = "".
            BaseQuery = BaseQuery + ", " + pBaseQuery.         
            BaseQuery = trim(BaseQuery).
            qstr = new QueryString("where " + SequenceExpression,BaseQuery). 
            BaseQuery = qstr:BuildQueryString(Tables).
            delete object qstr.
            qstr = new QueryString("where " + TenantExpression,BaseQuery). 
            BaseQuery = qstr:BuildQueryString(Tables).
            delete object qstr.
        end.    
       
         
    end constructor.
    
    /* TenantDataSource overrides this to set permission from FieldMapArea
       so we override it here to keep our setting (could need improvement...) */
    method public override logical Attach(bufferHandle as handle).
        FieldMapNoArea = FieldMapping .
        return super:Attach(bufferHandle).
    end method.
    
    method override protected void AfterSetUrl(): 
        TenantURL = url + "/tenants/".
        SequenceURL = url + "/schemas/PUB/sequences/".
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
    method public override logical Save(bufferHandle as handle,piState as int):
/*        CreateSaveSource("").*/
        mSaving = true. 
        SaveValues(bufferHandle,piState).
        finally:
            mSaving = false.
        end finally.
    end method.             
                                       
    /** Save changes of specified state 
         @param buffer the temp-table buffer handle with data
         @param state  the row-state to save (row-created, row-deleted or row-modified)
                       ? - save all  */                                                  
    method protected void SaveValues(phbuffer as handle,piState as int):
        define variable hDataset as handle no-undo.
        define variable hBeforeBuff as handle    no-undo.
         
        define variable hquery      as handle    no-undo.
       
        define buffer btenant for dictdb._tenant.
        define buffer bsequence for dictdb._sequence.
        
        if piState <= 0 or pistate > 3 then
            undo, throw new IllegalArgumentError("Invalid state " + string(piState) + " passed to save." ).
        
        create query hquery.
        hBeforeBuff = phBuffer:before-buffer.
        hquery:add-buffer(hBeforeBuff).
        hQuery:query-prepare("for each ttSequenceValueCopy"
                              + (if piState <> ? 
                                 then " where row-state(ttSequenceValueCopy) = " + string(piState)
                                 else "")  
                             ).    
        hquery:query-open().
      
        do transaction on error undo, throw:
            do while true:
                hquery:get-next.          
                if not hBeforebuff:avail then 
                    leave.
                phBuffer:find-by-rowid (hBeforeBuff:after-rowid).
                find btenant where btenant._tenantid = phBuffer::TenantId no-lock. 
                /* create is not supported - just in case the UI does create for new  
                (@ todo  remove and give error ) - 
                commenting below code for create- cannot identify create since piState is always ? 
                else if piState = row-created then 
                do:
                    find btenant where btenant._tenant-name = phBuffer::TenantName no-lock. 
                end. */
                
                find bsequence where bsequence._seq-owner = phBuffer::SchemaName 
                                 and bsequence._seq-name = phBuffer::SequenceName 
                no-lock.
               
                phBuffer:find-by-rowid(hBeforebuff:after-rowid).
                if btenant._Tenant-type NE 2 THEN
                   dynamic-current-value(hBeforebuff::SequenceName, "DICTDB",btenant._tenantid) = phbuffer::CurrentValue.  
                
                hdataset = phBuffer:dataset. 
                 
                AfterRow(dataset-handle hdataset  by-reference).
               
            end.
            
            catch e2 as DataAccessError:
                undo, throw e2.            		
            end catch.
            
            catch e as Progress.Lang.Error :
                undo, throw new DataAccessError(
                    new DataMapper("Tenant,bTenant,Sequence,_Sequence",
                    FieldMapping), e). 
            end catch.
        end. /* transaction */
        finally:
           delete object hQuery no-error. 		
        end finally.     
    end method.      
    
    method public override void AfterRow(dataset-handle hds):
        define buffer bTenant for dictdb._tenant.
        
        define variable hbuffer as handle    no-undo.
        define buffer bArea for dictdb._area.      
        define variable iSource as integer no-undo.
        define variable hStorage as handle no-undo.
      
        define variable cType as character no-undo.
        define variable cName as character no-undo.
        define variable rid as recid no-undo.
        define variable lNotMT as logical no-undo.             
        define variable iState as integer no-undo.
        
        
        hBuffer = hds:get-buffer-handle("ttSequenceValue") .
        
        if not mSaving then
        do:
            if hBuffer::TenantName > "" then
                hBuffer::TenantUrl  = TenantURL + WebUtil:UrlEncode(hBuffer::TenantName).
        
            if hBuffer::SequenceName > "" then
                hBuffer::SequenceUrl  = SequenceURL + WebUtil:UrlEncode(hBuffer::SequenceName).
       
            if get-effective-tenant-name("dictdb") <> hBuffer::Tenantname then
            do:
                find btenant where btenant._tenant-name = hBuffer::Tenantname no-lock. 
                if btenant._Tenant-type NE 2 THEN 
                do on error undo, throw:
                   hBuffer::CurrentValue = dynamic-current-value(hbuffer::SequenceName, "DICTDB",btenant._tenantid).   
                   
                   catch e as Progress.Lang.Error :
                  	  if not valid-object(FillError) then 
                  	  
                  	      FillError = new UnsupportedOperationError(e:GetMessage(1),e). 
               
                      undo, return error .
                   end catch.      
                end. 
                else
                    hBuffer::CurrentValue = ?.                     
            end.    
            else 
                hBuffer::CurrentValue = DYNAMIC-CURRENT-VALUE(hbuffer::SequenceName, "DICTDB").   
      
            
        end.
        
    end method.
    
 
end class.