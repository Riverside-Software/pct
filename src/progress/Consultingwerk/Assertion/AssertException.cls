/**********************************************************************
 * Copyright (C) 2006-2013 by Consultingwerk Ltd. ("CW") -            *
 * www.consultingwerk.de and other contributors as listed             *
 * below.  All Rights Reserved.                                       *
 *                                                                    *
 *  Software is distributed on an "AS IS", WITHOUT WARRANTY OF ANY    *
 *   KIND, either express or implied.                                 *
 *                                                                    *
 *  Contributors:                                                     *
 *                                                                    *
 **********************************************************************/
/*------------------------------------------------------------------------
    File        : AssertException
    Purpose     : Error class for assertions
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Mon Mar 25 14:48:55 CET 2013
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Exceptions.Exception.


USING Consultingwerk.Assertion.* FROM PROPATH .  
USING Progress.Lang.* FROM PROPATH .

CLASS Consultingwerk.Assertion.AssertException INHERITS Exception: 

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the AssertException class
        Notes:                          
        @param poInnerException The reference to the original error
        @param pcErrorString The error message associated with this Exception object
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC AssertException (poInnerException AS Progress.Lang.Error, 
	                                    pcErrorString AS CHARACTER):
		SUPER (poInnerException, pcErrorString).
		
	END CONSTRUCTOR.
	
    /*------------------------------------------------------------------------------
        Purpose: Constructor of the AssertException class
        Notes:                          
        @param poInnerException The reference to the original error
        @param pcErrorMessage The error message associated with this Exception object
        @param piMessageNumber The error message number associated with this Exception object
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC AssertException (poInnerException AS Progress.Lang.Error, 
	                                    pcErrorMessage AS CHARACTER, 
	                                    piMessageNumber AS INTEGER):
		SUPER (poInnerException, pcErrorMessage, piMessageNumber).
		
	END CONSTRUCTOR.
	
    /*------------------------------------------------------------------------------
        Purpose: Constructor of the AssertException class
        Notes:                          
        @param poInnerException The reference to the original error
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC AssertException (poInnerException AS Progress.Lang.Error):
		SUPER (poInnerException).
		
	END CONSTRUCTOR.
	
    /*------------------------------------------------------------------------------
        Purpose: Constructor of the AssertException class
        Notes:                          
        @param pcErrorString The error message associated with this Exception object
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC AssertException (pcErrorString AS CHARACTER):
		SUPER (pcErrorString).
		
	END CONSTRUCTOR.
	
    /*------------------------------------------------------------------------------
        Purpose: Constructor of the AssertException class
        Notes:                          
        @param pcErrorMessage The error message associated with this Exception object
        @param piMessageNumber The error message number associated with this Exception object
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC AssertException (pcErrorMessage AS CHARACTER, 
	                                    piMessageNumber AS INTEGER):
	                                        
		SUPER (pcErrorMessage, piMessageNumber).
		
	END CONSTRUCTOR.
	
    /*------------------------------------------------------------------------------
        Purpose: Constructor of the AssertException class
        Notes:                          
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC AssertException ():
		SUPER ().
		
	END CONSTRUCTOR.

END CLASS.
