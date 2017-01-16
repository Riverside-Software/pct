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
    File        : DataTypeHelper
    Purpose     : 
    Syntax      : Static methods only, private constructor to disallow 
                  instance creation
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Wed Dec 01 16:49:22 CET 2010
    Notes       : This file is also included under a commercial license
                  in Consultingwerk development tools. Our customers should
                  be using the version that was shipped with our development
                  tools as that may be a more recent version of the file.
                  
                  Note: This file contains just a subset of the methods
                  contained in our commercial version
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{ Consultingwerk/products.i }

USING Consultingwerk.*            FROM PROPATH . 
USING Consultingwerk.Exceptions.* FROM PROPATH .
USING Progress.Lang.*             FROM PROPATH .

CLASS Consultingwerk.Util.DataTypeHelper: 

    /*------------------------------------------------------------------------------
        Purpose: Disallow instance creation                                                                        
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE DataTypeHelper ():
        SUPER ().
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Returns true when the passed in data type name is an ABL primitive type
        Notes:   
        @param pcDataType An Character value that should be tested for a valid ABL data type
        @return True when the passed in data type name is an ABL primitive type
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LOGICAL IsAblDataType (pcDataType AS CHARACTER):
        
        IF LOOKUP (pcDataType, Consultingwerk.Const:ABL_DATA_TYPES) > 0 THEN 
            RETURN TRUE . 
        ELSE 
            RETURN FALSE . 

    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Converts common string representations to a logical value (true/false/?)                                                                        
        Notes:                                                                        
        @param pcValue The CHARACTER expression to parse
        @return The equivalent LOGICAL value                                                           
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LOGICAL ToLogical (pcValue AS CHARACTER):

        IF pcValue = "TRUE":U OR pcValue = "YES":U OR pcValue = "1":U OR pcValue = "JA":U OR pcValue = "WAHR":U OR pcValue = "+":U THEN
            RETURN TRUE  .

        IF pcValue = "FALSE":U OR pcValue = "NO":U OR pcValue = "0":U OR pcValue = "NEIN":U OR pcValue = "FALSCH":U OR pcValue = "-":U THEN
            RETURN FALSE  .

        RETURN ? .

    END METHOD.

END CLASS.