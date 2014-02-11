 /*------------------------------------------------------------------------
    File        : ListIterator
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Wed Jan 02 23:38:28 EST 2008
    Notes       : 
  ----------------------------------------------------------------------*/

routine-level on error undo, throw.
using Progress.Lang.Object from propath.
using OpenEdge.DataAdmin.Lang.Collections.ICollection from propath.
using OpenEdge.DataAdmin.Lang.Collections.IListIterator from propath.
using OpenEdge.DataAdmin.Lang.Collections.Iterator from propath. 

class OpenEdge.DataAdmin.Lang.Collections.ListIterator inherits Iterator implements IListIterator:

    constructor public ListIterator (tt as handle, objField as char, seqField as char):
        super (tt,objfield, seqField).               
    end constructor. 
    
    constructor public ListIterator (poCol as ICollection,tt as handle, objField as char, seqField as char,querystring as char):
        super (tt,objfield, seqField, querystring).               
    end constructor. 
      
    method public logical HasPrevious(  ):
        define variable offend as logical no-undo.
        if QueryHandle:query-off-end then 
        do:
            QueryHandle:reposition-backward(1).
            offend = QueryHandle:query-off-end.
            QueryHandle:reposition-forward(1).
            return not offend. 
        end. 
        else 
            return QueryHandle:current-result-row > 1.       
    end method.        
    
    method public Object Previous(  ):
        QueryHandle:get-prev().
          return if BufferHandle:avail then ObjectFieldHandle:buffer-value() else ?. 
    end method.
    
    method public integer PreviousIndex(  ):
        if QueryHandle:query-off-end = false then 
            return QueryHandle:current-result-row - 1.
    end method.
    
    method public integer NextIndex(  ):
        if QueryHandle:query-off-end = false then 
            return max(QueryHandle:current-result-row + 1,
                        QueryHandle:num-results).
        else if HasNext() then
            return 1.
    end method.
    
end class.