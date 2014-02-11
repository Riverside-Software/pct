 
 /*------------------------------------------------------------------------
    File        : IListIterator
    Purpose     : An iterator for lists that can traverse the list in 
                  both directions
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     :  
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.Object from propath.

interface OpenEdge.DataAdmin.Lang.Collections.IListIterator:  
  method public logical HasNext().
  method public Object Next().
  method public integer NextIndex().
  method public logical Remove ().
  method public logical HasPrevious().
  method public Object Previous().   
  method public integer PreviousIndex().
 /* method public void set(o as Object).     */
end interface.

 