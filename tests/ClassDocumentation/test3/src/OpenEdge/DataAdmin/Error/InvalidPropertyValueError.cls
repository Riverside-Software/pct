/*************************************************************/
/* Copyright (c) 2011 by progress Software Corporation.      */
/*                                                           */
/* all rights reserved.  no part of this program or document */
/* may be  reproduced in  any form  or by  any means without */
/* permission in writing from progress Software Corporation. */
/*************************************************************/ 
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

class OpenEdge.DataAdmin.Error.InvalidPropertyValueError inherits ValidationError: 

	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	constructor public InvalidPropertyValueError (cEntity as char, cKey as char,cProp as char, cValue as char, cValid as char):
        super(cEntity,cKey,cProp + " value " + DispValue(cValue),ShowIsNotValid(cValid)).                 
    end.
    
    constructor public InvalidPropertyValueError (cProp as char, cValue as char, cValid as char):
        super(cProp + " value " + DispValue(cValue),ShowIsNotValid(cValid)).                 
    end.
   		
	/* <cProp> value "<Value>" is not valid  */	
	constructor public InvalidPropertyValueError (centity as char, cKey as char,cProp as char, cValue as char ):
	    this-object(cEntity,cKey,cProp,cValue,"").    
	end constructor.
    
   
    method private char ShowIsNotValid(cValidValues as char):
        define variable cText as character no-undo.
        define variable cOperator as character no-undo.
        define variable i as integer no-undo.
        
        cText = "is not valid".
        
        if cValidValues > "" then 
        do:
            cText = cText + ". The expected value is ".
            do i = 1 to num-entries(cValidValues):
                if i > 1 then 
                do:
                    if i = num-entries(cValidValues) then 
                        cOperator = " or ".
                    else 
                        coperator = ", ".
                end.                        
                cText = cText + cOperator + DispValue(entry(i,cValidValues)).             
            end.
        end.  
        return cText. 
    end method.

end class.