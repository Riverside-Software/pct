 /*************************************************************/
 /* Copyright (c) 2010 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : TenantGroupMemberData
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : Domain-name is case sensitive 
  ----------------------------------------------------------------------*/
 
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.DataAccess.DataAccess from propath.
using OpenEdge.DataAdmin.DataAccess.DataAccessError from propath.
using OpenEdge.DataAdmin.DataAccess.IDataAccess from propath.

using OpenEdge.DataAdmin.DataSource.IDataSource from propath.
 
using OpenEdge.DataAdmin.DataSource.TenantGroupMemberDataSource from propath.
 
using OpenEdge.DataAdmin.DataSource.DatabaseInfo from propath.

using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.

using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.
using OpenEdge.DataAdmin.Error.IllegalArgumentError from propath.

class OpenEdge.DataAdmin.DataAccess.TenantGroupMemberData inherits DataAccess implements IDataAccess : 
        
    define private variable Url as character no-undo.
    
    define public property BaseQuery as character no-undo
        get():
            undo, throw new UnsupportedOperationError("BaseQuery in TenantGroupMemberData").
        end get.     
        set.
           
    method public override ISaveRequest SaveData(phChanges as ISaveRequest): 
           undo, throw new UnsupportedOperationError("SaveData in TenantGroupMemberData").
    end method.     
          
    method public override void FetchData(msg as IFetchRequest):
        define variable datasource as IDataSource no-undo.
        define variable hBuffer as handle no-undo.
        define variable cQuery as character no-undo.
        define variable i as integer no-undo.
        DatasetHandle = msg:DataHandle.
        Url = msg:Url. 
        hBuffer = DatasetHandle:get-buffer-handle("ttTenantGroupMember").
        datasource = new TenantGroupMemberDataSource().      
        cQuery = msg:GetTableQuery(hBuffer:name).
        datasource:FillMode = "Append".
        datasource:Url = Url.
        datasource:Prepare(hBuffer,cQuery,"").
        
        DatasetHandle:Fill().
        catch e as Progress.Lang.Error :
/*            undo, throw e. invalid-handle.. */
            undo, throw new AppError(e:GetMessage(1)).
/*        	undo, throw new IllegalArgumentError(e:GetMessage(1)).	*/
        end catch.
        /* is not garbage collected if set-callback is used */
        finally:
            delete object datasource no-error.		
        end finally.      
  
    end method. 
                                                                                                                                                                                              
 
end class.
