
/*------------------------------------------------------------------------
    File        : IContextWriter:  
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

interface OpenEdge.DataAdmin.Binding.IContextWriter:  
    method public void WriteContext(name as char).
    method public void WriteList(name as char,cList as char).
    method public void WriteJoin(name as char,cParent as char,cFieldPairs as char). 
   
    method public void WriteHandle(name as char,h as handle).
    method public void WriteHandle(name as char, h as handle,filter as char).
    method public void WriteBuffer(name as char, h as handle, rid as rowid). 
    
    method public handle GetWriteDataset().
    method public handle GetReadDataset().
    
     
end interface.
