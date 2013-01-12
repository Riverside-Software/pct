/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : FieldPermissionSet
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
using OpenEdge.DataAdmin.ITablePermission from propath.
using OpenEdge.DataAdmin.IFieldPermission from propath.
using OpenEdge.DataAdmin.FieldPermission from propath.
using OpenEdge.DataAdmin.IFieldPermissionSet from propath.
using OpenEdge.DataAdmin.Core.JSONLoader from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.FieldPermissionContext from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.

 
class OpenEdge.DataAdmin.FieldPermissionSet inherits DataAdminCollection implements IFieldPermissionSet : 
      
    constructor FieldPermissionSet(cntx as IDataAdminContext):
        super(cntx).     
    end constructor.   
         
    method protected override IDataAdminContext CreateLocalContext():
        return ?.
    end.      
     
    method public logical CanFind(fieldname as char):
           return Context:CanFind(fieldname).
    end method.
    
    method public IFieldPermission Find(tablename as char):
        return cast(Context:FindEntity(tablename),IFieldPermission). 
    end method.
        
    method public override void ImportTree(pcFile as char). 
        define variable reader as JSONLoader no-undo.        
        reader = new JSONLoader().
        reader:LoadFromFile(this-object,pcfile,"Replace").  
    end method. 
    
    method public override logical Contains(obj as Object):
        define variable fldperm as IFieldPermission no-undo. 
        fldperm = cast(obj,IFieldPermission).
        return contains(fldperm).
        catch e as Progress.Lang.Error :
            return false.   
        end catch.
    end method.

    method public logical Contains(fieldperm as IFieldPermission):
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
