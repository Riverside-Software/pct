 /*************************************************************/
 /* Copyright (c) 2011,2012 by progress Software Corporation. */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : DeallocateUtility
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Tue Jul 12 17:00:21 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/

routine-level on error undo, throw.

using Progress.Lang.*.
using OpenEdge.DataAdmin.ITenant from propath.
using OpenEdge.DataAdmin.ITable from propath.
using OpenEdge.DataAdmin.ITenantGroup from propath.
using OpenEdge.DataAdmin.Util.IDataAdminUtility from propath.
using OpenEdge.DataAdmin.Util.IDeallocateUtility from propath.
using OpenEdge.DataAdmin.Message.IUtilityRequest from propath.
using OpenEdge.DataAdmin.Message.IUtilityResponse from propath.
using OpenEdge.DataAdmin.Message.DeallocateRequest from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.ReadOnlyPropertyError from propath.
using OpenEdge.DataAdmin.Error.UnknownValueError  from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.

class OpenEdge.DataAdmin.Util.DeallocateUtility implements IDeallocateUtility : 
    define private variable mtype as character no-undo. 
    define private variable mReadOnly as logical no-undo. 
    
    define private property ReadOnlyReason as char no-undo 
        get():
            if mtype = "group" then
              return "TenantGroup was passed to constructor.".
            else
              return "Tenant and Table were passed to constructor.".
        end.  
        
     /* IDeallocateUtility */
    define public property Tenant as ITenant no-undo 
        get.  
        set(ptnt as ITenant):
            if mReadonly then
                undo ,throw new ReadOnlyPropertyError("DeallocateUtility","","Tenant",ReadOnlyReason). 
            Tenant = ptnt.
            if valid-object(ptnt) then
                 SetType("tenant").
        end. 
     
    define public property Table as ITable no-undo  
        get.  
        set(ptbl as ITable):
            if mReadonly then
                undo ,throw new ReadOnlyPropertyError("DeallocateUtility","","Table",ReadOnlyReason). 
    
            this-object:Table = ptbl.
        end. 
     
    define public property TenantGroup as ITenantGroup no-undo  
        get.  
        set(pGroup as ITenantGroup):
            if mReadonly then
                undo ,throw new ReadOnlyPropertyError("DeallocateUtility","","TenantGroup",ReadOnlyReason). 
            
            this-object:TenantGroup = pGroup.
            if valid-object(pGroup) then
            do:
                this-object:Table = pGroup:Table.
                SetType("group").
            end.          
        end. 
       
    /* IDataAdminUtility */
    define public property Name as character no-undo init "Deallocate" get. set.
    define public property TaskName as character no-undo get. set.
   
    define public property LogStatus      as logical no-undo 
        get. 
        set(log as logical):
            if log then 
               undo, throw new OpenEdge.DataAdmin.Error.UnsupportedOperationError("Status log is not supported for deallocate utility.").
        end.
   /*   
     /** optional status log type */
      define public property LogType        as char no-undo  
         get. 
         set(log as char):
             if log > ""  then 
                undo, throw new OpenEdge.DataAdmin.Error.UnsupportedOperationError("Status log is not supported for deallocate utility.").
         end.
   */
        
    define public property StatusFileName as character  no-undo 
        get. 
        set(pfile as char):
            if pfile > "" then 
               undo, throw new OpenEdge.DataAdmin.Error.UnsupportedOperationError("Status log is not supported for deallocate utility.").
        end.
     
    define public property StatusInterval      as integer no-undo 
        get. 
        set(ptime as integer):
            if ptime < 0 then 
               undo, throw new OpenEdge.DataAdmin.Error.UnsupportedOperationError("Status log is not supported for deallocate utility.").
        end.
 

    /*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	
	constructor public DeallocateUtility (pGroup as ITenantGroup  ):
        super ().
        this-object:TenantGroup = pGroup.
        mReadOnly = true.
    end constructor.
		
	constructor public DeallocateUtility (pTenant as ITenant, ptable as ITable  ):
		super ().
		this-object:Tenant = pTenant.
		this-object:Table = pTable.
	    mReadOnly = true.
    end constructor.
    
    constructor public DeallocateUtility (  ):
        super ().
    end method.    
    
    method public IUtilityRequest GetRequest():
        define variable msg as DeallocateRequest no-undo.
           case mtype:
            when "group" then
            do:
                AssertNotNull(this-object:TenantGroup,"TenantGroup").
                /* check if table matches group - this indicates that the Table property was set after
                   the group so we throw an error to make it clear that we're not deallocating this table */
   
                if this-object:Table <> TenantGroup:Table then 
                    undo, throw new OpenEdge.DataAdmin.Error.IllegalArgumentError("The DeallocateUtility Table is not the same as the TenantGroup:Table. It is not necessary to set the Table when deallocating a group.").
            end. 
            when "tenant" then
            do:
                AssertNotNull(this-object:Tenant,"Tenant").
                AssertNotNull(this-object:Table,"Table").
            end.
            otherwise 
                undo, throw new OpenEdge.DataAdmin.Error.IllegalArgumentError("The DeallocateUtility is in an invalid state. The Tenant and Table or TenantGroup property must be specified.").
        end.       
        
        assign 
            msg = new DeallocateRequest()
            msg:TableName = Table:name
            msg:Type = mtype
            msg:Name = if mtype = "tenant" then Tenant:name
                       else TenantGroup:name.
        return msg.
    end method.    
    
    method private void setType(cType as char):
         case cType:
             when "group" then
             do:
                Tenant = ?.
             end.    
             when "tenant" then
             do:
                TenantGroup = ?.
             end.    
         end.    
         mtype = cType. 
            
    end method.     
    
    method public void ImportOptions(cfile as char):
        undo, throw new OpenEdge.DataAdmin.Error.UnsupportedOperationError("ImportOptions is not supported for deallocate utility.").
    end method.
    
    method protected void AssertNotNull(o as Object, arg as char):
        if not valid-object(o) then 
            ThrowNull(arg).
    end method. 
    
    method protected void ThrowNull(arg as char):
        undo, throw new IllegalArgumentError("Cannot execute DeallocateUtility with unknown " + arg).
    end method. 
    
    method public void SetResponse(resp as IUtilityResponse):
    end method. 
    
    
end class.