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
    File        : InvalidReferenceException
    Purpose     : An error object thrown to signal an invalid widget handle
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Fri Jan 20 07:17:13 CEST 2012
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i}

USING Consultingwerk.Exceptions.* FROM PROPATH .
USING Progress.Lang.*             FROM PROPATH .

CLASS Consultingwerk.Exceptions.InvalidReferenceException INHERITS Exception: 

    /*------------------------------------------------------------------------------
        Purpose: Returns the optional description of the invalid handle                                                                       
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY ReferenceDescription AS CHARACTER NO-UNDO INIT ?
    GET.
    PROTECTED SET. 

    /*------------------------------------------------------------------------------
        Purpose: Default constructor of the InvalidReferenceException class                                                                       
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidReferenceException ():
        
        SUPER ("Invalid object reference."{&TRAN}, 0) .
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the InvalidReferenceException class                                                                      
        Notes:                                                                        
        @param pcDescription The Description of the invalid handle to be used in the error message
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidReferenceException (pcDescription AS CHARACTER):
        
        SUPER (SUBSTITUTE ("Invalid &1 object reference."{&TRAN}, pcDescription), 0) .
        
        THIS-OBJECT:ReferenceDescription = pcDescription .
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Default constructor of the InvalidReferenceException class                                                                       
        Notes:        
        @param poInnerException The reference to the original error
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidReferenceException (poInnerException AS Error):
        
        SUPER (poInnerException, 
               "Invalid object reference."{&TRAN}, 
               0) .
        
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
        Purpose: Constructor of the InvalidReferenceException class                                                                      
        Notes:                                                                        
        @param poInnerException The reference to the original error
        @param pcDescription The Description of the invalid handle to be used in the error message
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidReferenceException (poInnerException AS Error,
                                                  pcDescription AS CHARACTER):
        
        SUPER (poInnerException, SUBSTITUTE ("Invalid &1 object reference."{&TRAN}, pcDescription), 0) .
        
        THIS-OBJECT:ReferenceDescription = pcDescription .
        
    END CONSTRUCTOR.
    
END CLASS.
