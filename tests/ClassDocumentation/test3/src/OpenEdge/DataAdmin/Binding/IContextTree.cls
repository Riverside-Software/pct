
/*------------------------------------------------------------------------
    File        : IContextTree:  
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Mon Aug 16 20:18:09 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath. 
using OpenEdge.DataAdmin.* from propath.
using OpenEdge.DataAdmin.Binding.* from propath.

interface OpenEdge.DataAdmin.Binding.IContextTree:  
    define public property Parse as logical no-undo 
    get.
    set. 
    method public void SetName(name as char).
    method public void SetList(name as char,cList as char).
    method public void SetJoin(cParent as char,name as char,cFieldPairs as char). 
    method public void SetRepositionJoin(cParent as char,name as char,cFieldPairs as char).     method public void SetFilter(name as char,cFilter as char). 
    method public void SetHandle(name as char,h as handle).
    method public void SetHandle(name as char, h as handle,filter as char).
    method public void SetHandle(name as char, h as handle, rid as rowid). 
    
    method public handle GetReadHandle().
    method public handle GetWriteHandle().
    
     
end interface.
