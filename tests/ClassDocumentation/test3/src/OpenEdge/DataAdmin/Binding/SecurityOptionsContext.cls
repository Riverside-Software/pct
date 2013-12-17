 
 /*------------------------------------------------------------------------
    File        : SecurityOptionsContext
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : rkumar
    Created     : Thu Nov 24 17:58:48 IST 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.SecurityOptions from propath.
using OpenEdge.DataAdmin.DataAdminService from propath.
using OpenEdge.DataAdmin.IDataAdminElement from propath.
using OpenEdge.DataAdmin.IDataAdminCollection from propath.
using OpenEdge.DataAdmin.Binding.DataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
 
using OpenEdge.DataAdmin.Binding.ServiceAdapter from propath.
using OpenEdge.DataAdmin.Binding.Factory.IContextScope from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

class OpenEdge.DataAdmin.Binding.SecurityOptionsContext inherits DataAdminContext: 
    {daschema/securityoptions.i}
    
    define dataset dsSecOpt for ttSecurityOptions.
    
    define public override property DatasetHandle as handle no-undo 
        get():
            return dataset dsSecOpt:handle.
        end get.
    
    define public override property TableHandle as handle no-undo 
        get():
           return temp-table ttSecurityOptions:handle.
        end.
        private set.
        
    define public override property KeyFields as character  no-undo  
        get():
            return TableHandle:default-buffer-handle:keys. 
        end.   
        
    define public override property Count as integer init ? no-undo  
        get():         
            return 1.
        end.
        protected set.      
        
    constructor public SecurityOptionsContext (pscope as IContextScope):
        super ("SecurityOptions",pScope).    
    end constructor.
    
    
    method public override character GetJoinFields(parentid as char):
        return "".
    end.
    
    method public override void CopyTable(cntxt as IDataAdminContext).
        undo, throw new UnsupportedOperationError("Copy SecurityOptions context. There is only one keyless instance").
    end method. 
     
    method public override void CreateRow(entity as IDataAdminElement):
        undo, throw new UnsupportedOperationError("Create SecurityOptions context row. There is only one row").
    end method. 
    
 /*   method public override logical CanFind(name as character):
        return can-find(ttSecurityOptions where ttSecurityOptions.name = name).
    end.   
     
    method public override logical Find(name as character):
        find ttSecurityOptions where ttSecurityOptions.name = name no-error.
        return avail ttSecurityOptions.
    end.    */
    
    method protected override IDataAdminCollection CreateCollection(cntxt as IDataAdminContext):     
        undo, throw new UnsupportedOperationError("CreateCollection in Dummy context. There is only one keyless instance").
    end method.
    
    method protected override IDataAdminElement CreateEntity(cntxt as IDataAdminContext):
        return new SecurityOptions(this-object).
    end method.  
        
end class.