
/*------------------------------------------------------------------------
    File        : IServerContextFactory
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Tue Sep 13 18:03:56 EDT 2011
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Binding.IDataAdminContext from propath.
using OpenEdge.DataAdmin.Binding.SchemaChanges from propath.
using OpenEdge.DataAdmin.Binding.PermissionContext from propath.
using OpenEdge.DataAdmin.Binding.UserTablePermissionContext from propath.
using OpenEdge.DataAdmin.Binding.UserFieldPermissionContext from propath.

using OpenEdge.DataAdmin.Binding.Factory.* from propath.

interface OpenEdge.DataAdmin.Binding.Factory.IServiceContextFactory inherits IContextFactory,  ISecurityScope: 
                            
    define public property PermissionContext as PermissionContext no-undo get.  
     
    method public IDataAdminContext GetLocalContext(pname as char):   
    method public IDataAdminContext GetContextBySerializeName(pname as char):
      
    method public UserTablePermissionContext GetUserTablePermissionContext().  
    method public UserFieldPermissionContext GetUserFieldPermissionContext().  
     
    method public SchemaChanges GetSchemaDefinitionContext(pcfile as char).
end interface.