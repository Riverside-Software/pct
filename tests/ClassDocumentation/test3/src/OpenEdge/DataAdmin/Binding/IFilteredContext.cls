
/*------------------------------------------------------------------------
    File        : IFilteredContext
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Wed Aug 18 21:04:08 EDT 2010
    Notes       : FilteredContext is unique per instance and filters the 
                  underlying data to match the instance.
                  It should probably inherit IDataAdminContext.  
                  It has an abstract implementation that also implements 
                  IDataAdminContext instead and ensures that the collections
                  and entitites does not need to know the difference  
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.IRequestInfo from propath.
interface OpenEdge.DataAdmin.Binding.IFilteredContext:  
    define public property Filter as character  no-undo  get. 
    define public property RequestInfo as IRequestInfo no-undo get. set.
end interface.
