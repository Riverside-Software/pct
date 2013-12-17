
/*------------------------------------------------------------------------
    File        : IDataMapper
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Mon Aug 23 21:18:14 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

interface OpenEdge.DataAdmin.DataAccess.IDataMapper:  
    define public property ReturnBlankWhenNotFound as logical no-undo 
        get.
        set. 
    method public character GetSourceColumn(name as char).
    method public character GetTargetColumn(name as char).
    method public character GetSourceTable(name as char).
    method public character GetTargetTable(name as char).
        
end interface.