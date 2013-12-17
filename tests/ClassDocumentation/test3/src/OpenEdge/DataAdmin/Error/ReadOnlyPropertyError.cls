 
 /*------------------------------------------------------------------------
    File        : ReadOnlyPropertyError
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : hdaniels
    Created     : Tue Aug 24 00:19:34 EDT 2010
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.DataAdmin.Error.ValidationError.

routine-level on error undo, throw.

class OpenEdge.DataAdmin.Error.ReadOnlyPropertyError inherits ValidationError: 

	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	constructor public ReadOnlyPropertyError (cEntity as char, cKey as char, cProp as char):
		super (cEntity,cKey,cProp,"is read only").	 
	end constructor.
    
    constructor public ReadOnlyPropertyError (cEntity as char, cKey as char, cProp as char, cReason as char):
        super (cEntity,cKey,cProp,"is read only. " + creason).   
    end constructor.


end class.