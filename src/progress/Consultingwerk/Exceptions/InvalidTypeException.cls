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
    File        : InvalidTypeException
    Purpose     : An error object thrown to signal invalid types
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Thu Apr 28 14:04:34 CEST 2011
    Notes       : This file is also included under a commercial license
                  in Consultingwerk development tools. Our customers should
                  be using the version that was shipped with our development
                  tools as that may be a more recent version of the file.
                  
                  Note: This file contains just a subset of the methods
                  contained in our commercial version
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING Consultingwerk.Exceptions.Exception.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS Consultingwerk.Exceptions.InvalidTypeException INHERITS Exception: 

    /*------------------------------------------------------------------------------
        Purpose: Returns the (WIDGET-)TYPE that was expected by the code raising this
                 error                                                                      
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY ExpectedType AS CHARACTER NO-UNDO 
    GET.
    PROTECTED SET. 

    /*------------------------------------------------------------------------------
        Purpose: Returns the (WIDGET-)TYPE that was received by the code raising this
                 error                                                                      
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY Type AS CHARACTER NO-UNDO 
    GET.
    PROTECTED SET. 

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the InvalidTypeException class                                                                       
        Notes:                                                  
        @param pcExpectedType The expected type
        @param pcType The current type                      
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidTypeException (pcExpectedType AS CHARACTER,
                                             pcType AS CHARACTER):
        
        SUPER (SUBSTITUTE ("Type &1 should be &2.", pcType, pcExpectedType), 0).
        
        ASSIGN THIS-OBJECT:ExpectedType = pcExpectedType 
               THIS-OBJECT:Type         = pcType
               . 
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the InvalidTypeException class                                                                    
        Notes:                                                  
        @param poInnerException The reference to the original error
        @param pcExpectedType The expected type
        @param pcType The current type                    
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidTypeException (poInnerException AS Error,
                                             pcExpectedType AS CHARACTER,
                                             pcType AS CHARACTER):
        
        SUPER (poInnerException,
               SUBSTITUTE ("Type &1 should be &2.", 
                           pcType, 
                           pcExpectedType), 
               0).
        
        ASSIGN THIS-OBJECT:ExpectedType = pcExpectedType 
               THIS-OBJECT:Type         = pcType
               . 
        
    END CONSTRUCTOR.

END CLASS.
