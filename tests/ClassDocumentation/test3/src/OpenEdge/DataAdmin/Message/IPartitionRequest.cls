
/*------------------------------------------------------------------------
    File        : IPartitionRequest
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Thu Oct 14 21:33:26 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

interface OpenEdge.DataAdmin.Message.IPartitionRequest:  
    define public property ForceAllocateDelayed as logical no-undo get. set.    
    define public property ForceAllocateNone    as logical no-undo get. set.   
end interface.