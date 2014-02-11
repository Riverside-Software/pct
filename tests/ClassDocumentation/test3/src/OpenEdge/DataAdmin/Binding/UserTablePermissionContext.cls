 /*************************************************************/
 /* Copyright (c) 2011 by progress Software Corporation       */
 /*                                                           */
 /* all rights reserved.  no part of this program or document */
 /* may be  reproduced in  any form  or by  any means without */
 /* permission in writing from progress Software Corporation. */
 /*************************************************************/
 /*------------------------------------------------------------------------
    File        : UserTablePermissionContext
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :   2011
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.UserTablePermissionSet from propath.
using OpenEdge.DataAdmin.UserTablePermission  from propath.
using OpenEdge.DataAdmin.Binding.DataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.UserFieldPermissionContext from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath.
using OpenEdge.DataAdmin.Binding.ContextTree from propath.

 
/*using OpenEdge.DataAdmin.Binding.FieldPermissionContext from propath.*/
using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath.
using OpenEdge.DataAdmin.Binding.Factory.IServiceContextFactory from propath.
using OpenEdge.DataAdmin.Message.IFetchRequest from propath.
using OpenEdge.DataAdmin.Message.FetchRequest from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Message.SaveRequest from propath.

using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

class OpenEdge.DataAdmin.Binding.UserTablePermissionContext inherits DataAdminContext implements IDataAdminContext: 
    
    {daschema/usertablepermission.i}
     
    define private dataset dsTablePermission serialize-name "root" for ttUserTablePermission.  
    
    define variable mLastSavedTable as handle no-undo.
     
    define public override property DatasetHandle as handle no-undo 
        get():
            if not valid-handle(DatasetHandle) then
                DatasetHandle = CreateDataset().
            return  DatasetHandle.   
        end get.
        private set.
        
	define public override property TableHandle as handle no-undo 
    	get():
    		return temp-table ttUserTablePermission:handle.
    	end get.
    
    define public override property KeyFields as character  no-undo  
        get():
            return "UserRef,Name". 
        end.   
    
    define public override property Count as integer init ? no-undo  
        get(): 
            define buffer bPerm for ttUserTablePermission.
            if Count = ? then
            do:
                Count = 0.
                for each bPerm:
                    Count = Count + 1.
                end. 
            end.    
            return Count.
        end.
        protected set.
    
    constructor public UserTablePermissionContext (pScope as IServiceContextFactory):
        define variable cntxt as IDataAdminContext no-undo.
        super ("UserTablePermission",pScope).
        cntxt = pScope:GetUserFieldPermissionContext().
        cntxt:Lazy = false.
        AddChild(cntxt).  
    end constructor.
    
	method public override void CopyTable(cntxt as IDataAdminContext).
        undo, throw new UnsupportedOperationError("Copy UserTablePermission").
    end method. 
     
    method public override void CreateRow(entity as IDataAdminElement):
        undo, throw new UnsupportedOperationError("Create UserTablePermission row").
    end method. 
	
    method public override character GetJoinFields(parentid as char):
        case parentid:
            when "userPermissions" then 
                return "Id,UserRef".
        end.
    end.
      
	method public override logical CanFind(name as character):
        undo, throw new UnsupportedOperationError("CanFind of UserTablePermission with single key.").    end.    
    
    method public  logical CanFind(pUser as char,pname as character):
        return can-find(ttUserTablePermission 
                       where ttUserTablePermission.UserRef = pUser
                       and ttUserTablePermission.name = pname).            
    end.    
         
    method public override logical Find(name as character):
          undo, throw new UnsupportedOperationError("Find of UserTablePermission with single key.").
    end.   
    
    method public logical Find(pUser as char,pname as character):
        find ttUserTablePermission where ttUserTablePermission.UserRef = pUser
                                   and   ttUserTablePermission.name = pname no-error.
        return avail ttUserTablePermission.            
    end.    
      
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):     
        return new UserTablePermissionSet(cntxt). 
    end method.
    
    method protected override IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
        return new UserTablePermission(cntxt). 
    end method. 
end class.
