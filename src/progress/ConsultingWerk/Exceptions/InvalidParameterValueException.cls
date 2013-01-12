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
    File        : InvalidParameterValueException
    Purpose     : An error object thrown to signal invalid parameter values 
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwer Ltd.
    Created     : Sun Feb 17 09:48:56 CET 2008
    Notes       : This file is also included under a commercial license
                  in Consultingwerk development tools. Our customers should
                  be using the version that was shipped with our development
                  tools as that may be a more recent version of the file.
                  
                  Note: This file contains just a subset of the methods
                  contained in our commercial version
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW .

{Consultingwerk/products.i}

USING Consultingwerk.Exceptions.* FROM PROPATH .
USING Progress.Lang.*             FROM PROPATH .

CLASS Consultingwerk.Exceptions.InvalidParameterValueException 
    INHERITS Exception: 
    
    /*------------------------------------------------------------------------------
        Purpose: Returns the name of the invalid parameter
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY ParameterName AS CHARACTER 
    GET.
    PRIVATE SET.
    
    /*------------------------------------------------------------------------------
        Purpose: Returns the value of the invalid parameter
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY ParameterValue AS CHARACTER 
    GET.
    PRIVATE SET.

    /*------------------------------------------------------------------------------
        Purpose: Returns the class name that caused the InvalidParameterException
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY ClassName AS CHARACTER 
    GET.
    PRIVATE SET.    
    
    /*------------------------------------------------------------------------------
        Purpose: Constructor of the InvalidParameterException class
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidParameterValueException ():

        SUPER ("The parameter value is invalid.", 0).
    
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the InvalidParameterException class
        Notes:                                                                        
        @param poInnerException The reference to the original error
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidParameterValueException (poInnerException AS Error):

        SUPER (poInnerException,
               "The parameter value is invalid.", 
               0).
    
    END CONSTRUCTOR.

    
    /*------------------------------------------------------------------------------
        Purpose: Constructor of the InvalidParameterException class
        Notes:                                                                        
        @param pcParamerterName The name of the invalid parameter
        @param pcValue The invalid parameter name
        @param pcClassName The name of the class that caused the InvalidParameterException
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidParameterValueException (pcParameterName AS CHARACTER,
                                                       pcValue         AS CHARACTER,
                                                       pcClassName     AS CHARACTER ):

        SUPER (SUBSTITUTE("The parameter value '&2' for &1 in &3 is invalid.", 
                          pcParameterName, pcValue, pcClassName), 0).
           
        ASSIGN ParameterName  = pcParameterName
               ParameterValue = pcValue 
               ClassName      = pcClassName .           
           
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
        Purpose: Constructor of the InvalidParameterException class
        Notes:                                                                        
        @param poInnerException The reference to the original error
        @param pcParamerterName The name of the invalid parameter
        @param pcValue The invalid parameter name
        @param pcClassName The name of the class that caused the InvalidParameterException
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidParameterValueException (poInnerException AS Error,
                                                       pcParameterName  AS CHARACTER,
                                                       pcValue          AS CHARACTER,
                                                       pcClassName      AS CHARACTER ):

        SUPER (SUBSTITUTE("The parameter value '&2' for &1 in &3 is invalid.", 
                          pcParameterName, pcValue, pcClassName), 0).
           
        ASSIGN ParameterName  = pcParameterName
               ParameterValue = pcValue 
               ClassName      = pcClassName .           
           
    END CONSTRUCTOR.

END CLASS.
