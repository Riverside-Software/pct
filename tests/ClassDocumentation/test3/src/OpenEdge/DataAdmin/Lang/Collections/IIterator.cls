/*------------------------------------------------------------------------
    File        : IIterator
    Purpose     : traverses a collection forward 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.

interface OpenEdge.DataAdmin.Lang.Collections.IIterator:  
  method public logical HasNext().
  method public Object Next().
  method public logical Remove(). 
end interface.

 