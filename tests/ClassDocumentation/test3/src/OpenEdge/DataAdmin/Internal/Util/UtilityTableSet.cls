/*************************************************************/
/* Copyright (c) 2012 by Progress Software Corporation.      */
/*                                                           */
/* All rights reserved.  No part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from Progress Software Corporation. */
/*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : Table collection for dump/load when TableSelection = "list"
                  and UseGroupSelection= false. 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Wed May 10 
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

using OpenEdge.DataAdmin.DataAdminCollection.
using OpenEdge.DataAdmin.ISchema.
using OpenEdge.DataAdmin.ITableSet.
using OpenEdge.DataAdmin.ITable.

using OpenEdge.DataAdmin.Binding.IDataAdminContext.
using OpenEdge.DataAdmin.Binding.UtilityTableContext.
using OpenEdge.DataAdmin.Util.IDataAdminUtility.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Internal.Util.UtilityTableSet inherits DataAdminCollection implements ITableSet: 
	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	define private variable xNotImplemented as character no-undo
	   init "Method &1 is not implemented.".
	
	/** currently only PUB supported */
    define public property Schema as ISchema no-undo 
        get():
            return cast(Context,UtilityTableContext):getSchema().
        end.    
   	
	constructor public UtilityTableSet ( util as IDataAdminUtility ):
		super ().
	end constructor.

	constructor public UtilityTableSet ( input contxt as  IDataAdminContext ):
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
        define variable tbl as ITable no-undo. 
        AssertNotNull(pOBJ,"Table").
        tbl = cast(pobj,ITable).
        this-object:Add(tbl).
        catch e as Progress.Lang.Error :
            undo, throw e.
      /* @todo throw illegal argument on  class cast error and  
        undo, throw new IllegalArgumentError("Cannot Add " + pobj:GetClass():ToString() + " to ITableSet.").   */
        end catch.
    end method.
    
	method public logical Add( pTable as ITable ):
		AssertNotNull(pTable,"Table").
        context:CreateRow(pTable).
	end method.

	method override public logical Contains( obj as Object ):
		define variable tnt as ITable no-undo. 
        tnt = cast(obj,ITable).
		return Contains(tnt).
		catch e as Error :
        	return false.	
        end catch.
	end method.

	method public logical Contains(ptnt as ITable ):
	    define variable tnt as ITable no-undo. 
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
    
    method public logical CanFind( input pTableName as character ):
        return Context:CanFind(pTableName).    
    end method.
	
	method public ITable Find( pTableName as character ):
		return cast(Context:FindEntity(pTableName),ITable ).    
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
        define variable tbl as ITable no-undo. 
        AssertNotNull(obj,"Table").
        tbl = cast(obj,ITable).
        return Remove(tbl).
    end method.
    
	method public logical Remove(  ptbl as  ITable ):
	    AssertNotNull(ptbl,"Table").
		if Contains(ptbl) then
     		return Context:Delete(ptbl:name).
     	return false.	
	end method.
    
    define public property ForceAllocation as char no-undo 
        get. 
        private set(force as char):
            undo, throw new AppError(GetNotImplementedText()).
        end.
     
    method public void ImportTree(pcfile as char,pcCollections as char):        
        undo, throw new AppError(GetNotImplementedText()).
    end method.     
    
end class.