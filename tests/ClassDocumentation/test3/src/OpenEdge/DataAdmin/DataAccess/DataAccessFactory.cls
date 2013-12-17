 /*************************************************************/
 /* Copyright (c) 2010 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    Purpose     : Factory for DataAccess objects
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Fri Aug 06 09:11:08 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAccess.* from propath.
using OpenEdge.DataAdmin.Error.* from propath.

class OpenEdge.DataAdmin.DataAccess.DataAccessFactory: 
    define variable ServiceName as character no-undo.
    
    define  temp-table ttDA no-undo 
        field Name as char
/*        field databaseName as char*/
        field Dao as Object
        index idxname as unique name.
                  

	define public property KeepAlive as logical no-undo 
/*	init true*/
	get.
	set. 

    /*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/	
	constructor DataAccessFactory ( name as char):
		super ().	
        this-object:ServiceName =  name. 
	end constructor.
        
    method public IDataAccess GetDataAccess(name as char):
        define variable da as IDataAccess no-undo.
        if KeepAlive then      
            find ttDa where  ttDa.name         = name no-error.
        
        if KeepAlive = false or not avail ttDa then 
        do: 
            create alias dictdb for database value(ServiceName).
            if name = "Permission" then
                da = new MetaData().            
            else if name = "TenantGroupMember" then
                da = new TenantGroupMemberData().              
            else if name = "TenantGroup" then
                da = new TenantGroupData().    
            else if name = "AllTable" then
                da = new AllFileData().              
            else if name = "Schema" 
                 or name = "Table" 
                 or name = "Index" 
                 or name = "Field" 
                 or name = "DataSecurity"
                 or name = "Administrator"
                 or name = "SecurityOptions"    
                 or name = "TablePermission" then 
                da = new FileData().    
            else if name = "UserPermission" 
                 or name = "UserTablePermission" then 
                da = new UserData().    
            else if name = "SchemaChanges" then 
                da = new FileDataChanges().
            else if name = "AuthenticationSystem" then 
                da = new AuthenticationSystemData().
            else if name = "Sequence" then 
                da = new FileData().            
            else if name = "SequenceValue" then 
                da = new SequenceValueData().            
            else 
            do on error undo, throw:
                name = caps(substr(name,1,1)) + lc(substr(name,2)).
                da = dynamic-new "OpenEdge.DataAdmin.DataAccess." + name + "Data" (). 
             
                catch e as Progress.Lang.Error :
                     undo, throw new UnsupportedOperationError("DataAccessFactory cannot provide DataAccess for " + quoter(name) + "."
                                      + "~n" + e:GetMessage(1)).
                end catch.
            end.
            if KeepAlive then
            do:
                create ttDa.
                assign ttDa.name         = name 
                       ttDA.Dao          = da.
            end.
        end. 
        else 
            da = cast(ttDA.Dao,IDataAccess).
     
        return da.  
    end method.    
    
    
     
end class.
