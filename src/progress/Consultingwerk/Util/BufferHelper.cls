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
    File        : BufferHelper
    Purpose     : 
    Syntax      : Static methods only, private constructor to disallow 
                  instance creation
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Wed Sep 30 14:43:37 CEST 2009
    Notes       : This file is also included under a commercial license
                  in Consultingwerk development tools. Our customers should
                  be using the version that was shipped with our development
                  tools as that may be a more recent version of the file.
                  
                  Note: This file contains just a subset of the methods
                  contained in our commercial version
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i}

USING Consultingwerk.*      FROM PROPATH .
USING Consultingwerk.Exceptions.* FROM PROPATH . 
USING Consultingwerk.Util.* FROM PROPATH . 
USING Progress.Lang.*       FROM PROPATH .

CLASS Consultingwerk.Util.BufferHelper: 

    /*------------------------------------------------------------------------------
        Purpose: Private default constructor. 
        Notes:   There's no need to create instances of the helper classes                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE BufferHelper ():
        SUPER ().
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Tests if the passed in buffer handle has a field with the 
                 given name                                                                       
        Notes:   Verifies that a valid buffer is passed in first.
        @param phBuffer The Buffer handle to test
        @param pcFieldName The name of the buffer field                                                                  
        @return Logical value indicating if the field exists
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LOGICAL HasField (phBuffer AS HANDLE,
                                           pcFieldName AS CHARACTER):
        
        DEFINE VARIABLE hField AS HANDLE NO-UNDO.
        
        Consultingwerk.Assertion.HandleAssert:ValidHandle (phBuffer, "BUFFER":U) .

        hField = phBuffer:BUFFER-FIELD (pcFieldName) NO-ERROR .
        
        RETURN VALID-HANDLE (hField) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Assigns buffer field values from SAX-ATTRIBUTES
        Notes:   
        @param phBuffer The handle to the buffer to assign the field values to
        @param phSaxAttributes The handle of the SAX-ATTRIBUTES widget
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID ParseSaxAttributesToBuffer (phBuffer AS HANDLE,
                                                          phSaxAttributes AS HANDLE):
        
        DEFINE VARIABLE i      AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cName  AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cValue AS CHARACTER NO-UNDO.
        
        Consultingwerk.Assertion.HandleAssert:WidgetType (phBuffer, WidgetTypeEnum:Buffer) .
        Consultingwerk.Assertion.HandleAssert:WidgetType (phSaxAttributes, WidgetTypeEnum:SaxAttributes) .

        DO i = 1 TO phSaxAttributes:NUM-ITEMS:
            ASSIGN cName  = phSaxAttributes:GET-QNAME-BY-INDEX (i)
                   cValue = phSaxAttributes:GET-VALUE-BY-INDEX (i) . 
            
            Consultingwerk.Assertion.BufferAssert:HasField (phBuffer, cName) .
            
            ASSIGN phBuffer:BUFFER-FIELD (cName):BUFFER-VALUE = cValue .  
        END.

    END METHOD .

END CLASS.
