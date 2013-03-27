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
    File        : InvalidHandleException
    Purpose     : An error object thrown to signal an invalid widget handle
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Thu Apr 28 13:09:05 CEST 2011
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

CLASS Consultingwerk.Exceptions.InvalidHandleException INHERITS Exception: 

    /*------------------------------------------------------------------------------
        Purpose: Returns the optional description of the invalid handle                                                                       
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY HandleDescription AS CHARACTER NO-UNDO INIT ?
    GET.
    PROTECTED SET. 

    /*------------------------------------------------------------------------------
        Purpose: Default constructor of the InvalidHandleException class                                                                       
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidHandleException ():
        
        SUPER ("Invalid handle.", 0) .
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the InvalidHandleException class                                                                      
        Notes:                                                                        
        @param pcDescription The Description of the invalid handle to be used in the error message
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidHandleException (pcDescription AS CHARACTER):
        
        SUPER (SUBSTITUTE ("Invalid &1 handle.", pcDescription), 0) .
        
        THIS-OBJECT:HandleDescription = pcDescription .
        
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
        Purpose: Default constructor of the InvalidHandleException class                                                                      
        Notes:                                                                        
        @param poInnerException The reference to the original error
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidHandleException (poInnerException AS Error):
        
        SUPER (poInnerException, 
               "Invalid handle.", 0) .
        
    END CONSTRUCTOR.
        
    /*------------------------------------------------------------------------------
        Purpose: Constructor of the InvalidHandleException class                                                                      
        Notes:                                                                        
        @param poInnerException The reference to the original error
        @param pcDescription The Description of the invalid handle to be used in the error message
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidHandleException (poInnerException AS Error,
                                               pcDescription AS CHARACTER):
        
        SUPER (poInnerException, 
               SUBSTITUTE ("Invalid &1 handle.", pcDescription), 
               0) .
        
        THIS-OBJECT:HandleDescription = pcDescription .
        
    END CONSTRUCTOR.

END CLASS.