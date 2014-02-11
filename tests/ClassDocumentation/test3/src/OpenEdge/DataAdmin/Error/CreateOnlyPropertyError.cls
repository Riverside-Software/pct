/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation.      */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
 

using Progress.Lang.*.
using OpenEdge.DataAdmin.Error.ReadOnlyPropertyError.

routine-level on error undo, throw.

/** read only error that explains the property cannot be edited once created */
class OpenEdge.DataAdmin.Error.CreateOnlyPropertyError inherits ReadOnlyPropertyError: 

	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	
    constructor public CreateOnlyPropertyError (cEntity as char, cKey as char, cProp as char ):
        super (cEntity,cKey,cProp,
         "The property cannot be edited after the " + cEntity + " has been created").   
    end constructor.


end class.