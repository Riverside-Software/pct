/*************************************************************/
/* Copyright (c) 2012 by Progress Software Corporation.      */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Fri Dec 17 05:15:41 EST 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.*.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.ITenant from propath.
using OpenEdge.DataAdmin.ITable from propath.
using OpenEdge.DataAdmin.ITenantGroup from propath.
using OpenEdge.DataAdmin.IDataAdminService from propath.
using OpenEdge.DataAdmin.Binding.DataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.

class OpenEdge.DataAdmin.Binding.UtilityContext abstract inherits DataAdminContext: 
    define public override property DatasetHandle as handle no-undo 
        get.
        private set.
    
    define public override property TableHandle as handle no-undo 
        get.
        private set.
        
    define public override property KeyFields as character  no-undo  
        get():
            return TableHandle:default-buffer-handle:keys. 
        end.   
        
    define public abstract override property Count as integer  no-undo  
        get.
        protected set.      
	
	constructor public UtilityContext (ds as handle,pcname as char):
		define variable cTablename as character no-undo.
		super ("Utility" + pcname).	
		DatasetHandle = ds.		
		cTablename = if pcName = "TenantGroup" then "ttGroupData" 
		             else "tt" + pcname + "Data". 
		TableHandle = ds:get-buffer-handle (cTableName):table-handle.
	    Bind(TableHandle).	
		catch e as Progress.Lang.Error :
        	if not valid-handle(TableHandle) then 
        	    undo, throw new IllegalArgumentError("Invalid dataset or table name passed to UtilityContext",e).	
        end catch.
	end constructor.
	
	method protected abstract void AssignRow(entity as IDataAdminElement,pBuffer as handle):
	method protected abstract void Bind(pHdl as handle).
	
	method public override character GetJoinFields(parentid as char):
        return "".
    end.
    
    method public override void CopyTable(cntxt as IDataAdminContext).
        undo, throw new UnsupportedOperationError("Copy Utility context").
    end method. 
    
    method public override void CreateRow(entity as IDataAdminElement):
        define variable hBuffer as handle no-undo.
        define variable start as int no-undo.
        start = Count.  
        if TargetService = ? then 
            TargetService = entity:Service.
        else if TargetService <> entity:Service then 
            undo, throw new IllegalArgumentError("The entity " + entity:GetClass():ToString() + " Service does not match the Utility Service.").
        
        hBuffer = TableHandle:default-buffer-handle.
        hBuffer:buffer-create.
        if Count = ? then Count = 1.
        else Count = Count + 1. 
        AssignRow(entity,hBuffer).
        OnRowCreated().      
        catch e as Progress.Lang.Error :
        	Count = start.  	
        	undo, throw e.
        end catch.
    end method. 
       
    method public override logical CanFind(pname as character):
        define variable hBuffer as handle no-undo.
        create buffer hbuffer for table TableHandle.    
        hbuffer:find-unique ("where name = " + quoter(pname)) no-error.
        return hbuffer:available.
        finally:
            delete object hbuffer no-error.		
        end finally.
    end.    
    
    method public override logical Find(pname as character):
        TableHandle:default-buffer-handle:find-unique ("where name = " + quoter(pname)) no-error.
        return TableHandle:default-buffer-handle:available.
    end.  
    
    /** override to not touch tracking changes 
      @todo add check for before table in dataadmincontext */
    method protected override logical Remove(): 
        OnBeforeDelete().
        TableHandle:default-buffer-handle:buffer-delete().
        Count = Count - 1.
        OnRowDeleted().
        return true.                             
    end method.
    
end class.