/*************************************************************/
/* Copyright (c) 2012 by Progress Software Corporation.      */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : Tenant collection for dump/load when 
                  TenantSelection = "list" and UseGroupSelection= false
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Wed May 09 19:18:08 EDT 2012
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

using OpenEdge.DataAdmin.DataAdminCollection.
using OpenEdge.DataAdmin.ITenantSet.
using OpenEdge.DataAdmin.ITenant.
using OpenEdge.DataAdmin.Binding.IDataAdminContext.
using OpenEdge.DataAdmin.Binding.UtilityTenantContext.
using OpenEdge.DataAdmin.Util.IDataAdminUtility.
using OpenEdge.DataAdmin.Error.IllegalArgumentError.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Internal.Util.UtilityTenantSet inherits DataAdminCollection implements ITenantSet: 
	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	define private variable xNotImplemented as character no-undo
	   init "Method &1 is not implemented.".
		
	constructor public UtilityTenantSet ( util as IDataAdminUtility ):
		super ().
		 
	end constructor.

	constructor public UtilityTenantSet ( input contxt as  IDataAdminContext ):
		super (input contxt).
	end constructor.
     
    method public char GetNotImplementedText():
        define variable cCaller as character no-undo.
        cCaller  =  entry(2,program-name(2)," ") + ":" + entry(1,program-name(2)," ").        
        
        /*
        cCaller = program-name(2).
        entry(2,cCaller," ") =  entry(2,cCaller," ") + " " + "is".  
        entry(1,cCaller," ") =  entry(1,cCaller," ") + " " + "in".  
        */
        return substitute(xNotImplemented,cCaller). 
    end method.    
    
	method public override logical Add(pobj as Object):
	    define variable tnt as ITenant no-undo. 
        AssertNotNull(pOBJ,"Tenant").
        tnt = cast(pobj,ITenant).
        this-object:Add(tnt).
        catch e as Progress.Lang.Error :
         	undo, throw e.
      /* @todo throw illegal argument on  class cast error and  
       	undo, throw new IllegalArgumentError("Cannot Add " + pobj:GetClass():ToString() + " to ITenantSet.").	*/
        end catch.
    end method.
	
	method public logical Add( ptenant as ITenant ):
	    AssertNotNull(ptenant,"Tenant").
		context:CreateRow(ptenant).
	end method.

	method override public logical Contains( obj as Object ):
		define variable tnt as ITenant no-undo. 
        tnt = cast(obj,ITenant).
		return Contains(tnt).
		catch e as Error :
        	return false.	
        end catch.
	end method.

	method public logical Contains(ptnt as ITenant ):
	    define variable tnt as ITenant no-undo. 
	    if CanFind(ptnt:name) then
	    do: 
	        tnt = this-object:Find(ptnt:name).
	        return tnt:Service = ptnt:Service.     
        end.
        return false.	
	end method.

	method override protected IDataAdminContext CreateLocalContext(  ):
		  undo, throw new Progress.Lang.AppError(GetNotImplementedText()).
	end method.
    
    method public logical CanFind( input ptenantName as character ):
        return Context:CanFind(ptenantName).    
    end method.

    method public logical CanFind( input ptenantid as integer ):
        return Context:CanFind(ptenantid).    
    end method.
	
	method public logical CanFindByExternalId( input pExtId as character ):
        return cast(Context,UtilityTenantContext):CanFindTenantByExternalId(pextid).
    end method.
	
	method public ITenant Find( ptenantName as character ):
		return cast(Context:FindEntity(ptenantName),ITenant ).    
	end method.

	method public ITenant Find( ptenantid as integer ):
        return cast(Context:FindEntity(ptenantid),ITenant ).    
	end method.

	method public ITenant FindByExternalId( pextId as character ):
		define variable tnt as ITenant no-undo.
		return cast(cast(Context,UtilityTenantContext):FindEntityByExternalId(pextid),ITenant). 
	end method.

	method override protected void PrepareExport(  ):
		undo, throw new AppError(GetNotImplementedText()).
	end method.

	method override protected void PrepareExportList(  ):
		undo, throw new AppError(GetNotImplementedText()).
	end method.

	method override protected void PrepareExportTree(  ):
		undo, throw new AppError(GetNotImplementedText()).
	end method.
    
    method public override logical Remove(  obj as  Object):
        define variable tnt as ITenant no-undo. 
        AssertNotNull(obj,"Tenant").
        tnt = cast(obj,ITenant).
        return Remove(tnt).
        catch e as Error :
        	return false.	
        end catch.
    end method.
    
	method public logical Remove(  tnt as  ITenant ):
	    AssertNotNull(tnt,"Tenant").
		if Contains(tnt) then
     		return Context:Delete(tnt:name).
        return false.   
	end method.

end class.