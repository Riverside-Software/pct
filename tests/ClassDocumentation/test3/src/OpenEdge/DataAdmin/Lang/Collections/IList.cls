/*------------------------------------------------------------------------
    File        : IList
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : based  
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

interface OpenEdge.DataAdmin.Lang.Collections.IList:  
    method public logical Add(o as Object).
/* no generics - sub interfaces implements these 
  -  method public Object Get(i as int).*/
   
    /* Returns the index in this list of the specified extent */
    method public integer IndexOf(o as Object). 
end interface.