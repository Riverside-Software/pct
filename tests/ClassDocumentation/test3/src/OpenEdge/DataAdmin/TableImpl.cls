/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     :  
    Syntax      : 
    Description : 
    @Author(s)   : hdaniels
    Created     : Fri Jun 11 23:11:32 EDT 2010
    Notes       : inheriting from AbstractSchemaElement adds 50% on construct
                  consider removing if performance becomes an issue 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
 
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.Entity from propath.
using OpenEdge.DataAdmin.AbstractSchemaElement from propath.
using OpenEdge.DataAdmin.ISchemaElement from propath.
using OpenEdge.DataAdmin.ISchema from propath.
using OpenEdge.DataAdmin.IIndexSet from propath.
using OpenEdge.DataAdmin.IFieldSet from propath.
using OpenEdge.DataAdmin.ITable from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.

using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.
using OpenEdge.DataAdmin.Error.IllegalOperationError from propath.
using OpenEdge.DataAdmin.Binding.TableContext from propath.
 

class OpenEdge.DataAdmin.TableImpl final inherits AbstractSchemaElement implements ITable: 
  
    define public override property ObjectType as character no-undo 
        get():
            return "Table". 
        end.
        private set.
        
    define public property IsMultiTenant as logical no-undo  
        get():
            if valid-handle(mBuffer) then
                return mBuffer::IsMultiTenant.
            return IsMultiTenant.
        end.    
        set(plMulti as log):
            if IsMultiTenant and not plMulti then
                undo, throw new AppError("Cannot set IsMultiTenant to false.").
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                mdefaultbuffer::IsMultiTenant = plMulti.
            end.
            IsMultiTenant = plMulti.    
            /* this need to change if support of create */
            SetKeepDefaultTrue(). 
        end.     
         
    define public property KeepDefaultArea as logical no-undo  
        get():
            if valid-handle(mBuffer) then
               return mBuffer::KeepDefaultArea.
            return KeepDefaultArea.
        end.    
        set(plKeep as log):
            define variable hBefore as handle no-undo.
            if not IsMultiTenant then
                undo, throw new AppError("Cannot set KeepDefaultArea to true unless IsMultiTenant is also true"). 
   
            if not plKeep then
                undo, throw new AppError("Cannot set KeepDefaultArea to false.").
            
            /* support of create will  require some logic to allow setting to false
            if KeepDefaultArea and not plKeep then 
            do:
                hBefore = mbuffer:before-buffer.
                if hBefore:avail and hBefore::KeepDefaultArea then
                   undo, throw new AppError("Cannot set KeepDefaultArea to false.").
            end.
            */
            if valid-handle(mBuffer) then
            do:
                mDefaultBuffer:find-by-rowid(mBuffer:rowid).  
                hBefore = mbuffer:before-buffer.
                mdefaultbuffer::KeepDefaultArea = plKeep.
               
            end.
            
            KeepDefaultArea = plKeep.    
        end.     
    
    /** Returns a set of the table's LOBs */ 
    define public property LOBFields as IFieldSet no-undo     
        get():
            if not valid-object(LOBfields) then
                LOBFields = cast(Context:GetChildCollection(name,"lobFields"),IFieldSet).
            return LOBFields.
        end.
        protected set.
     
        
    /** collection of all indexes in the table */ 
    define public property Indexes as IIndexSet no-undo   
        get():
            if not valid-object(Indexes) then
                Indexes = cast(Context:GetChildCollection(name,"indexes"),IIndexSet).
            return Indexes.     
        end.
        protected set.
     
    method public override void Export():
        Export("table.json").
    end method.          
    
   /*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
 
    
	constructor public TableImpl ( cntxt as IDataAdmincontext ):
		super (cntxt).
	end constructor.
	
	constructor public TableImpl ( cntxt as IDataAdmincontext,pReq as IRequestInfo ):
        super (cntxt,pReq).
    end constructor.
    
	
    /** Allocate all delayed partitions for all tenants
        Does not allocate group partitions  
        @return true if any partition was allocated  */
     
    method public logical Allocate():
        return Allocate("Delayed").
    end method.    
    
    /** Allocate tenant partitions for table   
        Does not allocate partitions belonging to a tenantgroup  
        @param AllocationState Specify state of partitions to allocate - All, Delayed or None 
        @return true if any partition was allocated 
        @throw IllegalArgumentError  */     
    method public logical Allocate(pcMode as char).
       
        define variable lok as logical no-undo.
        if IsMultiTenant = false then
            undo, throw new IllegalOperationError("Table is not multi-tenant enabled.").          
        
        if lookup(pcMode,"All,Delayed,None") = 0 then 
            undo, throw new IllegalArgumentError (
                               "Parameter value " + quoter(pcMode) + " passed to allocate method. " 
                              + "Valid values are " 
                              + quoter("Delayed") 
                              + "," + quoter("All")
                              + " or " + quoter("None") + ".").                      
       
         
        return Partitions:AllocateTenants(pcMode).
            
    end method.
    
    /* No local context needed - not   used to create    */ 
    method protected  override IDataAdminContext CreateLocalContext():
        return ?.
    end method.
    
    /* @TODO remove  - use inherited */
    method public override void Export(cFile as char):
        define variable htbl as handle no-undo.
        if not valid-handle(mDefaultBuffer) then
        do:
            undo, throw new UnsupportedOperationError("Export of new table").
        end.
        create temp-table htbl.
        htbl:create-like(mDefaultBuffer).
        htbl:temp-table-prepare ("ttTable").
        htbl:default-buffer-handle:buffer-copy (mBuffer).
        htbl:default-buffer-handle:serialize-name = "table".     
        htbl:default-buffer-handle:write-json ("File",cFile,yes).   
    end method.
    
    /* @TODO remove  - use inherited */
    method public override void Import(cFile as char):
        if not valid-handle(mDefaultBuffer) then
        do:
            undo, throw new UnsupportedOperationError("Import to new Table that is not in a collection or service").
        end.
            
        mDefaultBuffer:serialize-name = "table". 
        mDefaultBuffer:table-handle:tracking-changes = true.
        if not mDefaultBuffer:read-json ("File",cFile,"replace") then 
            undo, throw new IllegalArgumentError(error-status:get-message(1)).
                           
    end method.  
    
    /* workaround for mutual property ref requirement */ 
    method private void setKeepDefaultTrue():
        KeepDefaultArea = true.
    end.
    
 end class.