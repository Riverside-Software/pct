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
    File        : InvalidValueException
    Purpose     : An error object thrown to signal invalid (parameter) values
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Mon Apr 25 23:20:48 CEST 2011
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i}

USING Consultingwerk.Exceptions.* FROM PROPATH .
USING Progress.Lang.*             FROM PROPATH .

CLASS Consultingwerk.Exceptions.InvalidValueException 
    INHERITS Exception: 

    /*------------------------------------------------------------------------------
        Purpose: Returns the Descriotion for the Value that caused this InvalidValueException                                                                     
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY Description AS CHARACTER NO-UNDO 
    GET.
    PROTECTED SET. 

    /*------------------------------------------------------------------------------
        Purpose: Returns the Value that caused this InvalidValueException                                                                     
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY Value AS CHARACTER NO-UNDO 
    GET.
    PROTECTED SET. 

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the InvalidValueException class                                                                        
        Notes:          
        @param pcValue The invalid value                                                              
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidValueException (pcValue AS CHARACTER):
        
        SUPER (SUBSTITUTE ("Invalid Value ~"&1~".", pcValue), 0).

        THIS-OBJECT:Value = pcValue . 
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the InvalidValueException class                                                                      
        Notes:          
        @param pcValue The invalid value    
        @param pcDescription The descrition of the invalid value                                                          
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidValueException (pcValue AS CHARACTER,
                                              pcDescription AS CHARACTER):
        
        SUPER (SUBSTITUTE ("Invalid Value ~"&1~" for &2.", pcValue, pcDescription), 0).

        THIS-OBJECT:Value = pcValue .
        THIS-OBJECT:Description = pcDescription . 
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the InvalidValueException class                                                                      
        Notes:          
        @param poInnerException The reference to the original error
        @param pcValue The invalid value  
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidValueException (poInnerException AS Error, 
                                              pcValue AS CHARACTER):
        
        SUPER (poInnerException,
               SUBSTITUTE ("Invalid Value ~"&1~".", pcValue), 
               0).

        THIS-OBJECT:Value = pcValue . 
        
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
        Purpose: Constructor for the InvalidValueException class                                                                      
        Notes:          
        @param poInnerException The reference to the original error
        @param pcValue The invalid value  
        @param pcDescription The descrition of the invalid value                                                          
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidValueException (poInnerException AS Error, 
                                              pcValue AS CHARACTER,
                                              pcDescription AS CHARACTER):
        
        SUPER (poInnerException,
               SUBSTITUTE ("Invalid Value ~"&1~" for &2.", pcValue, pcDescription), 
               0).

        THIS-OBJECT:Value = pcValue . 
        THIS-OBJECT:Description = pcDescription . 
        
    END CONSTRUCTOR.    
    
END CLASS.