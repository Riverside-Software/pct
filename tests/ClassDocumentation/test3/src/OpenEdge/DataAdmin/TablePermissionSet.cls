/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation       */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 /*------------------------------------------------------------------------
    File        : TablePermissionSet
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
using OpenEdge.DataAdmin.ITablePermissionSet from propath.
using OpenEdge.DataAdmin.TablePermission from propath.
using OpenEdge.DataAdmin.Core.JSONLoader from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.TablePermissionContext from propath.
using OpenEdge.DataAdmin.Binding.IContextTree from propath.

 
class OpenEdge.DataAdmin.TablePermissionSet inherits DataAdminCollection implements ITablePermissionSet : 
      
    
    constructor TablePermissionSet(cntx as IDataAdminContext):
        super(cntx).     
    end constructor.   
         
    method protected override IDataAdminContext CreateLocalContext():
        return ?.
    end.      
     
    method public logical CanFind(tablename as char):
           return Context:CanFind(tablename).
    end method.
    
    method public ITablePermission Find(tablename as char):
        return cast(Context:FindEntity(tablename),ITablePermission).
    end method.
    
    method public override void ImportTree(pcFile as char). 
        define variable reader as JSONLoader no-undo.        
        reader = new JSONLoader().
        reader:LoadFromFile(this-object,pcfile,"Replace").  
    end method. 
    
    method public override logical Contains(obj as Object):
        return contains(cast(obj,ITablePermission)).
        catch e as Progress.Lang.Error :
        	return false.	
        end catch.
    end method.

    method public logical Contains(tableImp as ITablePermission):
        if tableImp:ContextId <> ContextId then 
            return false.
        if not CanFind(tableImp:name) then
            return false.  
        return true. 
    end method. 
   
    method override protected void PrepareExport(  ):
    end method.

    method override protected void PrepareExportTree(  ):
    end method.
    
    method override protected void PrepareExportList(  ):
    end method.
   
end class.
