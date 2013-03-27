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
    File        : BufferAssert
    Purpose     : Provides generic methods for validating of BUFFER object handles
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Wed Jul 20 00:41:51 CEST 2011
    Notes       : This file is also included under a commercial license
                  in Consultingwerk development tools. Our customers should
                  be using the version that was shipped with our development
                  tools as that may be a more recent version of the file.
                  
                  Note: This file contains just a subset of the methods
                  contained in our commercial version
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.*            FROM PROPATH . 
USING Consultingwerk.Assertion.*  FROM PROPATH .
USING Consultingwerk.Exceptions.* FROM PROPATH .
USING Progress.Lang.*             FROM PROPATH .

CLASS Consultingwerk.Assertion.BufferAssert: 
    
    /*------------------------------------------------------------------------------
        Purpose: Disallow instance creation.                                                                       
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE BufferAssert ():
        SUPER ().
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Verifies that the passed in buffer handle has a field with the 
                 given name                                                                       
        Notes:   Verifies that a valid buffer is passed in first.
        @param phBuffer The Buffer handle to test
        @param pcFieldName The name of the buffer field                                                                  
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID HasField (phBuffer AS HANDLE,
                                        pcFieldName AS CHARACTER):
        
        IF NOT Consultingwerk.Util.BufferHelper:HasField (phBuffer, 
                                                          pcFieldName) THEN
                                                          
            UNDO, THROW NEW Exception (SUBSTITUTE ("The buffer &1 has no field named &2.",
                                                   phBuffer:NAME, pcFieldName), 
                                       0) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Verifies the a record is available in that Buffer                                                                        
        Notes:   Verifies that a valid buffer is passed in first.                                                      
        @param phBuffer The handle of the Buffer to verify                  
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID IsAvailable (phBuffer AS HANDLE):
        
        HandleAssert:WidgetType (phBuffer, WidgetTypeEnum:Buffer) .

        IF NOT phBuffer:AVAILABLE THEN 
            UNDO, THROW NEW Exception (SUBSTITUTE ("No record is available in buffer &1.",
                                                   phBuffer:NAME),
                                       0) .  
    END METHOD.

	/*------------------------------------------------------------------------------
		Purpose: Verifies that the passed in buffer handle belongs to a ProDataset 
		         member buffer  																	  
		Notes:  				
		@param phBuffer The Buffer handle to verify													  
	------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID IsDatasetBuffer (phBuffer AS HANDLE):
		
        HandleAssert:WidgetType (phBuffer, WidgetTypeEnum:Buffer) .

        IF NOT VALID-HANDLE (phBuffer:DATASET) THEN 
            UNDO, THROW NEW Exception (SUBSTITUTE ("The Buffer &1 is not member of a ProDataset.", 
                                                   phBuffer:NAME),
                                       0) .
        
	END METHOD.

END CLASS.