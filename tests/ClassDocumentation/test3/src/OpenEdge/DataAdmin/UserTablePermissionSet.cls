/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : UserTablePermissionSet 
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
using OpenEdge.DataAdmin.Core.JSONLoader from propath.

using OpenEdge.DataAdmin.ISchema from propath.
using OpenEdge.DataAdmin.IUserTablePermission from propath.
using OpenEdge.DataAdmin.IUserTablePermissionSet from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.PermissionContext from propath.
using OpenEdge.DataAdmin.Binding.UserTablePermissionContext from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.

class OpenEdge.DataAdmin.UserTablePermissionSet inherits DataAdminCollection implements IUserTablePermissionSet : 
      
    define public property Schema as ISchema no-undo 
       get():
           if valid-object(Service) then
               return Service:GetSchema().
           return this-object:Schema.
       end.           
   
    constructor UserTablePermissionSet(cntx as IDataAdminContext):
        super(cntx).     
    end constructor.   
         
    method protected override IDataAdminContext CreateLocalContext():
        return ?.
    end.      
     
    method public logical CanFind(tablename as char):
           return Context:CanFind(tablename).
    end method.
    
    method public IUserTablePermission Find(tablename as char):
        return cast(Context:FindEntity(tablename),IUserTablePermission). 
    end method.
    
    method public override logical Contains(obj as Object):
        define variable perm as IUserTablePermission no-undo. 
        perm = cast(obj,IUserTablePermission).
        return contains(perm).
        catch e as Progress.Lang.Error: 
            return false.   
        end catch.
    end method.

    method public logical Contains(tableImp as IUserTablePermission):
        if tableImp:ContextId <> ContextId then 
            return false.
        if not CanFind(tableImp:name) then
            return false.
        return tableImp:Equals(this-object:Find(tableImp:name)).      
    end method. 
    
    method public void ExportNormalized(pcfilename as char):         
        this-object:Context:ExportNormalized(pcfilename).
    end method.
    
    method override protected void PrepareExport(  ):
    end method.

    method override protected void PrepareExportTree(  ):
    end method.
    
    method override protected void PrepareExportList(  ):
    end method.
   
end class.
