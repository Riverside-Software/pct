 
 /*------------------------------------------------------------------------
    File        : RestService
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Tue Jan 31 12:15:20 EST 2012
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.DataAdminService.
using OpenEdge.DataAdmin.ITableSet.
using OpenEdge.DataAdmin.IRequestInfo.
 

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Rest.RestService inherits DataAdminService: 
	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
 
		
	constructor public RestService (  ):
		super ().
		
	end constructor.

		
	constructor public RestService ( input path as character, input name as character ):
		super (input path, input name).
		
	end constructor.

		
	constructor public RestService ( input name as character ):
		super (input name).
		
	end constructor.
    
    method public ITableSet GetAllTables():
        return cast(ContextFactory:AllTableContext:GetCollection(),ITableSet).
    end method.
    
    method public ITableSet GetAllTables(filter as char):
        return cast(ContextFactory:AllTableContext:GetCollection(filter),ITableSet).
    end method.
    
    method public ITableSet GetAllTables(pRequestInfo as IRequestInfo):
        return cast(ContextFactory:AllTableContext:GetCollection(prequestInfo),ITableSet).
    end method.
    
    
end class.