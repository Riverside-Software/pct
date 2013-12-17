 
 /*------------------------------------------------------------------------
    File        : LoadDefinitions
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Fri Oct 15 21:09:39 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.* from propath.
using OpenEdge.DataAdmin.Binding.DataDefinitionOptions from propath.
using OpenEdge.DataAdmin.Binding.DataDefinitionLoader from propath.
using OpenEdge.DataAdmin.Message.ISaveRequest from propath.
using OpenEdge.DataAdmin.Error.UnsupportedOperationError from propath.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Message.LoadDefinitions inherits DataDefinitionOptions 
                                                 implements ISaveRequest: 
    define public property DataHandle as handle no-undo 
        get.
        set. 
    
    define public property Url as character no-undo 
        get.
        set. 
    
    define public property ContextId as character no-undo 
        get.
        private set.
    
    define public property SerializeName as character no-undo 
       init "definitions"
       get.
        
      /* identifier for the service adapter (directly to data access) */
    define public property EntityName as character no-undo 
        init "SchemaChanges"
        get.
      
	constructor public LoadDefinitions (  ):
		super (new DataDefinitionLoader()).
	end constructor.
    
     method public handle SerializeMessage():  
       undo, throw new UnsupportedOperationError("SerializeMessage in FetchDefinitions").
    end.
    
    
end class.