/**********************************************************************
 * Copyright 2013 Consultingwerk Ltd.                                 *
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
    File        : HandleAssert
    Purpose     : Static class that provide standarized validation routines
                  for (WIDGET-)HANDLE parameters.
    Syntax      : Static methods only, private constructor to disallow 
                  instance creation 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Thu Apr 28 13:05:38 CEST 2011
    Notes       : This file is also included under a commercial license
                  in Consultingwerk development tools. Our customers should
                  be using the version that was shipped with our development
                  tools as that may be a more recent version of the file.
                  
                  Note: This file contains just a subset of the methods
                  contained in our commercial version
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Exceptions.* .
USING Progress.Lang.*.

CLASS Consultingwerk.Assertion.HandleAssert: 
    
    /*------------------------------------------------------------------------------
        Purpose: Disallow instance creation                                                                       
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE HandleAssert ():
        SUPER ().
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Validates a (WIDGET-)HANDLE and raises an InvalidHandleException
                 when the widget is invalid                                                                      
        Notes:                              
        @param phHandle The (WIDGET-)HANDLE to validate                                          
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID ValidHandle (phHandle AS HANDLE):
        
        IF NOT VALID-HANDLE (phHandle) THEN 
            UNDO, THROW NEW InvalidHandleException () .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates a (WIDGET-)HANDLE and raises an InvalidHandleException
                 when the widget is invalid                                                                   
        Notes:                              
        @param phHandle The (WIDGET-)HANDLE to validate
        @param pcHandleDesc The optional description of the HANDLE used in the InvalidHandleException                                                                        
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID ValidHandle (phHandle AS HANDLE, pcHandleDesc AS CHARACTER):
        
        IF NOT VALID-HANDLE (phHandle) THEN 
            UNDO, THROW NEW InvalidHandleException (pcHandleDesc) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates the type of the given widget                                                                       
        Notes:                                                                  
        @param phHandle The (WIDGET-)HANDLE to validate
        @param pcType The expected Widget TYPE      
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID WidgetType (phHandle AS HANDLE, pcType AS CHARACTER):
        
        ValidHandle (phHandle) .
        
        IF phHandle:TYPE <> pcType THEN 
            UNDO, THROW NEW InvalidTypeException (pcType, phHandle:TYPE) .

    END METHOD.

END CLASS.
