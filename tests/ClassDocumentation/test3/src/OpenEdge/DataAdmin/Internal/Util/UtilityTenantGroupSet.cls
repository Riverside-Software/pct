/*************************************************************/
/* Copyright (c) 2012 by Progress Software Corporation.      */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : TenantGroup collection for dump/load when 
                  GroupSelection = "list" and UseGroupSelection= true
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Wed May 10
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

using OpenEdge.DataAdmin.DataAdminCollection.
using OpenEdge.DataAdmin.ITenantGroupSet.
using OpenEdge.DataAdmin.ITenantGroup.
using OpenEdge.DataAdmin.Binding.IDataAdminContext.
using OpenEdge.DataAdmin.Binding.UtilityTenantGroupContext.
using OpenEdge.DataAdmin.Util.IDataAdminUtility.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Internal.Util.UtilityTenantGroupSet inherits DataAdminCollection implements ITenantGroupSet: 
	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	define private variable xNotImplemented as character no-undo
	   init "Method &1 is not implemented.".
		
	constructor public UtilityTenantGroupSet ( util as IDataAdminUtility ):
		super ().
		 
	end constructor.

	constructor public UtilityTenantGroupSet ( input contxt as  IDataAdminContext ):
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
        define variable grp as ITenantGroup no-undo. 
        AssertNotNull(pOBJ,"TenantGroup").
        grp = cast(pobj,ITenantGroup).
        this-object:Add(grp).
        catch e as Progress.Lang.Error :
            undo, throw e.
      /* @todo throw illegal argument on  class cast error and  
        undo, throw new IllegalArgumentError("Cannot Add " + pobj:GetClass():ToString() + " to ITenantSet.").   */
        end catch.
    end method.
    
	method public logical Add( pTenantGroup as ITenantGroup ):
		AssertNotNull(pTenantGroup,"TenantGroup").
		context:CreateRow(pTenantGroup).
	end method.

	method override public logical Contains( pobj as Object ):
		define variable grp as ITenantGroup no-undo. 
        grp = cast(pobj,ITenantGroup).
		return Contains(grp).
		catch e as Error :
        	return false.	
        end catch.
	end method.

	method public logical Contains(ptntgrp as ITenantGroup ):
	    define variable grp as ITenantGroup no-undo. 
	    if CanFind(ptntgrp:name) then
	    do: 
	        grp = this-object:Find(ptntgrp:name).
	        return grp:Service = ptntgrp:Service.     
        end.
        return false.	
	end method.

	method override protected IDataAdminContext CreateLocalContext(  ):
		  undo, throw new Progress.Lang.AppError(GetNotImplementedText()).
	end method.
    
    method public logical CanFind( input pTenantGroupName as character ):
        return Context:CanFind(pTenantGroupName).    
    end method.

    method public logical CanFind( input pTenantGroupid as integer ):
        return Context:CanFind(pTenantGroupid).    
    end method.
	
 	method public ITenantGroup Find( pTenantGroupName as character ):
		return cast(Context:FindEntity(pTenantGroupName),ITenantGroup ).    
	end method.

	method public ITenantGroup Find( pTenantGroupid as integer ):
        return cast(Context:FindEntity(pTenantGroupid),ITenantGroup ).    
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
        define variable grp as ITenantGroup no-undo. 
        AssertNotNull(obj,"TenantGroup").
        grp = cast(obj,ITenantGroup).
        return Remove(grp).
    end method.
    
	method public logical Remove(  pgrp as  ITenantGroup ):
        AssertNotNull(pgrp,"TenantGroup").
		if Contains(pgrp) then
     		return Context:Delete(pgrp:name).
        return false.   
	end method.

end class.