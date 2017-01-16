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
    File        : EventArgsAssert
    Purpose     : Provides generic methods for validating of EventArgs object references
    Syntax      : 
    Description : Routines in this class typically raise an error condition
                  when the condition is not met.
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Sun Jul 03 09:28:36 CEST 2011
    Notes       : Static methods, throw error on failed test.
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i}

USING Consultingwerk.Assertion.* FROM PROPATH . 
USING Progress.Lang.*            FROM PROPATH .

CLASS Consultingwerk.Assertion.EventArgsAssert: 

    /*------------------------------------------------------------------------------
        Purpose: Disallow instance creation                                                                       
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE EventArgsAssert ():
        SUPER ().
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Validates if the passed in Consultingwerk.EventArgs provides a valid reference                                                                      
        Notes:     
        Throws:  Consultingwerk.Assertion.AssertException                                                                   
        @param e The reference to a Consultingwerk.EventArgs derived object
        @param pcEventName The name of the event that should be raised to include in the error message
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID IsValid (e AS Consultingwerk.EventArgs,
                                       pcEventName AS CHARACTER):
        
        IF NOT VALID-OBJECT (e) THEN 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Unable to raise the &1 Event with no valid event argument."{&TRAN}, 
                                                         pcEventName), 
                                             0) .
    END METHOD.

&IF DEFINED (DotNetAccessible) NE 0 &THEN
    /*------------------------------------------------------------------------------
        Purpose: Validates if the passed in System.EventArgs provides a valid reference                                                                   
        Notes:                                                                        
        Throws:  Consultingwerk.Assertion.AssertException                                                                   
        @param e The reference to a System.EventArgs derived object
        @param pcEventName The name of the event that should be raised to include in the error message
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID IsValid (e AS System.EventArgs,
                                       pcEventName AS CHARACTER):
        
        IF NOT VALID-OBJECT (e) THEN 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Unable to raise the &1 Event with no valid event argument."{&TRAN}, 
                                                         pcEventName), 
                                             0) .
    END METHOD.
&ENDIF

END CLASS.
