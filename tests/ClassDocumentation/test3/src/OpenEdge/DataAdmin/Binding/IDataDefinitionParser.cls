
/*------------------------------------------------------------------------
    File        : IDataDefinitionParser
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Sun Oct 03 00:55:26 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.

interface OpenEdge.DataAdmin.Binding.IDataDefinitionParser:  
    /* only read mt info */
    define public property MultiTenantOnly as logical no-undo get. set. 
    
/*    define public property MultiTenantChangesOnly as logical no-undo get. set.*/
    define public property Error as AppError no-undo get.
 
    define public property URL as character no-undo get. set.     
    
end interface.