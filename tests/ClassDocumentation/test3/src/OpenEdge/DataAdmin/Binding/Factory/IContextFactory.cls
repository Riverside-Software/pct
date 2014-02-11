
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
using OpenEdge.DataAdmin.Binding.Factory.* from propath.

interface OpenEdge.DataAdmin.Binding.Factory.IContextFactory
                    inherits IAreaScope,
                             IMultiTenantScope, 
                             ISchemaScope, 
                             IIdentityScope:  
                                 
end interface.