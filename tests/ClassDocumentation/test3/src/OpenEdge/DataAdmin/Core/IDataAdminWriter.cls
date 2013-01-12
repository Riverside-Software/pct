
/*------------------------------------------------------------------------
    File        : IDataAdminWriter
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Mon Aug 16 20:18:09 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath. 
using OpenEdge.DataAdmin.*  from propath.
using OpenEdge.DataAdmin.Binding.*  from propath.

interface OpenEdge.DataAdmin.Core.IDataAdminWriter:  
    /*
    method public void WriteChild(pcChildname as char,pcParentName as char,pcFieldPairs as char).  
    method public void WriteChild(serializable as IDataAdminSerializable,pcParentName as char,pcFieldPairs as char).
    /* can be removed when interface inheritance is added (assuming IDataAdminSerializable is anchor) */
    method public void WriteChild(coll as IDataAdminCollection,pcParentName as char,pcFieldPairs as char).
    /* can be removed when interface inheritance is added (assuming IDataAdminSerializable is anchor) */
    method public void WriteChild(coll as DataAdminCollection,pcParentName as char,pcFieldPairs as char).
    method public void WriteContext(cntxt as IDataAdminContext).
    method public void WriteContextList(cntxt as IDataAdminContext,fieldList as char).
    method public void WriteContextRow(cntxt as IDataAdminContext, ikey as int).
    method public void WriteContextRow(cntxt as IDataAdminContext, ckey as char).
    */
end interface.
