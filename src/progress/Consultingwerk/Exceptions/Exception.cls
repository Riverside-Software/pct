/**********************************************************************
 * Copyright 2012 Consultingwerk Ltd.                                 *
 *                                                                    *
 * Licensed under the Apache License, Version 2.0 (the "License");    *
 * you may not use this file except in compliance with the License.   *
 * You may obtain a copy of the License at                            *
 *                                                                    *
 *     http://www.apache.org/licenses/LICENSE-2.0                     *
 *                                                                    *
 * Unless required by applicable law or agreed to in writing,         *
 * software distributed under the License is distributed on an        * 
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,       *
 * either express or implied. See the License for the specific        *
 * language governing permissions and limitations under the License.  *
 *                                                                    *
 **********************************************************************/
/*------------------------------------------------------------------------
    File        : Exception
    Purpose     : Common base error class, implementing inner exception
                  handling / access, returning the Error instance 
                  that caused the current exception.
    Syntax      :                  
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Wed Feb 20 20:19:00 CET 2008
    Notes       : This file is also included under a commercial license
                  in Consultingwerk development tools. Our customers should
                  be using the version that was shipped with our development
                  tools as that may be a more recent version of the file.
                  
                  Note: This file contains just a subset of the methods
                  contained in our commercial version
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW .

{Consultingwerk/products.i}

USING Progress.Lang.* FROM PROPATH .

CLASS Consultingwerk.Exceptions.Exception 
    INHERITS AppError
    IMPLEMENTS Consultingwerk.Exceptions.ISupportsInnerException: 

    /*------------------------------------------------------------------------------
        Purpose: Returns the Error instance that caused the current exception.
        Notes:                          
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY InnerException AS Error
    GET.
    PROTECTED SET.
        
    /*------------------------------------------------------------------------------
        Purpose: Constructor of the Exception class
        Notes:                          
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC Exception ():
    
        SUPER ().        
    
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the Exception class
        Notes:                          
        @param pcErrorString The error message associated with this Exception object
        @param piMessageNumber The error message number associated with this Exception object
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC Exception (pcErrorMessage AS CHARACTER,
                                  piMessageNumber AS INTEGER):        
    
        SUPER (pcErrorMessage, piMessageNumber).
    
        IF pcErrorMessage > "":U AND THIS-OBJECT:NumMessages = 0 THEN 
            THIS-OBJECT:AddMessage (pcErrorMessage, piMessageNumber) .
    
    END CONSTRUCTOR.
                                              
    /*------------------------------------------------------------------------------
        Purpose: Constructor of the Exception class
        Notes:                          
        @param pcErrorString The error message associated with this Exception object
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC Exception (pcErrorString AS CHARACTER):        
        
        SUPER (pcErrorString).
    
    END CONSTRUCTOR.                                      

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the Exception class
        Notes:                          
        @param poInnerException The reference to the original error
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC Exception (poInnerException AS Error):
    
        SUPER ().        
        
        THIS-OBJECT:InnerException = poInnerException .
    
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the Exception class
        Notes:                          
        @param poInnerException The reference to the original error
        @param pcErrorString The error message associated with this Exception object
        @param piMessageNumber The error message number associated with this Exception object
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC Exception (poInnerException AS Error,
                                  pcErrorMessage AS CHARACTER,
                                  piMessageNumber AS INTEGER):        
        
        SUPER (pcErrorMessage, piMessageNumber).
        
        IF pcErrorMessage > "":U AND THIS-OBJECT:NumMessages = 0 THEN 
            THIS-OBJECT:AddMessage (pcErrorMessage, piMessageNumber) .        
        
        THIS-OBJECT:InnerException = poInnerException .
        
    END CONSTRUCTOR.
                                       
    /*------------------------------------------------------------------------------
        Purpose: Constructor of the Exception class
        Notes:                          
        @param poInnerException The reference to the original error
        @param pcErrorString The error message associated with this Exception object
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC Exception (poInnerException AS Error,
                                  pcErrorString AS CHARACTER):        
        
        SUPER (pcErrorString).
        
        THIS-OBJECT:InnerException = poInnerException .
        
    END CONSTRUCTOR.                                      

END CLASS.
