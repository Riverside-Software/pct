 
 /*------------------------------------------------------------------------
    File        : AllTableContext
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Tue Jan 31 12:48:02 EST 2012
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.Binding.TableContext.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Binding.AllTableContext inherits TableContext: 

	 	
	constructor public AllTableContext ( input pScope as OpenEdge.DataAdmin.Binding.Factory.ISchemaScope ):
		super ("AllTable",pScope).
	end constructor.

	constructor public AllTableContext (  ):
		super ("AllTable").
		
	end constructor.

	method override protected handle CreateDataset( ):
		return CreateDataSet("").

	end method.
end class.