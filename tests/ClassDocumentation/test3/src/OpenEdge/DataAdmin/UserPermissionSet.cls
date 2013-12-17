/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : UserPermissionSet
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.
using Progress.Lang.* from propath.  
using OpenEdge.DataAdmin.* from propath. 
using OpenEdge.DataAdmin.Binding.* from propath.
using OpenEdge.DataAdmin.Binding.Query.FilteredContext from propath.

using OpenEdge.DataAdmin.DataAccess.* from propath.
using OpenEdge.DataAdmin.Error.* from propath.

class OpenEdge.DataAdmin.UserPermissionSet inherits DataAdminCollection implements IUserPermissionSet: 
      
    constructor UserPermissionSet(cntxt as IDataAdminContext):
        super(cntxt).
    end constructor. 
    
    constructor UserPermissionSet(cntxt as FilteredContext):
        super(cntxt).  
    end constructor.       
    
    /* no use of DataAdminCollection empty constructor */
    method protected override IDataAdminContext CreateLocalContext():
        return ?.
    end.  
    
    method public override logical Contains(obj as Object):
        return Contains(cast(obj,IUser)).   
        catch e as Progress.Lang.Error :
            return false.   
        end catch.
    end method.
   
    method public logical Contains(userImpl as IUserPermission):
        if userImpl:ContextId <> ContextId then 
            return false.
        if not CanFind(userImpl:Id) then
            return false.
        return userImpl:Equals(this-object:Find(userImpl:Id)).      
    end method.  
     
    method public IUserPermission Find(pkey as char):
        return cast(Context:FindEntity(pkey),IUserPermission). 
    end method.     
    
    method public logical CanFind(pkey as char):
        return Context:CanFind(pkey).
    end method.   
         
    method override void PrepareExport():
/*        buffer ttUser:handle:buffer-field("URL"):serialize-hidden = true.*/
    end method.    
     
    method override void PrepareExportTree():
/*       buffer ttUser:handle:buffer-field("PartitionsURL"):serialize-hidden = true.*/
    end method.      
      
    method override void PrepareExportList():
 
/*        buffer ttTenant:handle:buffer-field("Type"):serialize-hidden = true.                */
/*/*        buffer ttTenant:handle:buffer-field("Description"):serialize-hidden = true.*/     */
/*        buffer ttTenant:handle:buffer-field("DefaultDataAreaName"):serialize-hidden = true. */
/*        buffer ttTenant:handle:buffer-field("DefaultIndexAreaName"):serialize-hidden = true.*/
/*        buffer ttTenant:handle:buffer-field("DefaultLobAreaName"):serialize-hidden = true.  */
/*        buffer ttTenant:handle:buffer-field("DefaultDataAreaUrl"):serialize-hidden = true.  */
/*        buffer ttTenant:handle:buffer-field("DefaultIndexAreaUrl"):serialize-hidden = true. */
/*        buffer ttTenant:handle:buffer-field("DefaultLobAreaUrl"):serialize-hidden = true.   */
/*        buffer ttTenant:handle:buffer-field("PartitionsURL"):serialize-hidden = true.       */
/*        buffer ttTenant:handle:buffer-field("UsersURL"):serialize-hidden = true.            */
/*        buffer ttTenant:handle:buffer-field("IsLocked"):serialize-hidden = true.            */

    end method.    
    

end class.
