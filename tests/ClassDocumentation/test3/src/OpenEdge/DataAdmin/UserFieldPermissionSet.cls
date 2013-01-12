/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : UserFieldPermissionSet 
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : 
    Notes       : 
  ----------------------------------------------------------------------*/
routine-level on error undo, throw.

using Progress.Lang.* from propath.  
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.DataAdminCollection from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.ISchema from propath.
using OpenEdge.DataAdmin.IUserFieldPermission from propath.
using OpenEdge.DataAdmin.UserFieldPermission from propath.
using OpenEdge.DataAdmin.IUserFieldPermissionSet from propath.
using OpenEdge.DataAdmin.Core.JSONLoader from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.FieldPermissionContext from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.
 

class OpenEdge.DataAdmin.UserFieldPermissionSet inherits DataAdminCollection implements IUserFieldPermissionSet: 
      
    constructor UserFieldPermissionSet(cntx as IDataAdminContext):
        super(cntx).     
    end constructor.   
         
    method protected override IDataAdminContext CreateLocalContext():
        return ?.
    end.      
     
    method public logical CanFind(fieldname as char):
        return Context:CanFind(fieldname).
    end method.
    
    method public IUserFieldPermission Find(fieldname as char):
        return cast(Context:FindEntity(fieldname),IUserFieldPermission). 
    end method.
        
    method public override void ImportTree(pcFile as char). 
        define variable reader as JSONLoader no-undo.        
        reader = new JSONLoader().
        reader:LoadFromFile(this-object,pcfile,"Replace").  
    end method. 
    
    method public override logical Contains(obj as Object):
        define variable perm as IUserFieldPermission no-undo. 
        perm = cast(obj,IUserFieldPermission).
        return contains(perm).
        catch e as Progress.Lang.Error :
            return false.   
        end catch.
    end method.

    method public logical Contains(fieldperm as IUserFieldPermission):
        if fieldperm:ContextId <> ContextId then 
            return false.
        if not CanFind(fieldperm:name) then 
            return false.  
        return fieldperm:Equals(this-object:Find(fieldperm:name)). 
    end method. 
   
    method override protected void PrepareExport(  ):
    end method.

    method override protected void PrepareExportTree(  ):
    end method.
    
    method override protected void PrepareExportList(  ):
    end method.
   
end class.
