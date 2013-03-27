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
    File        : CharacterType
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd. 
    Created     : Sat Jun 02 10:58:12 CEST 2012
    Notes       : This file is also included under a commercial license
                  in Consultingwerk development tools. Our customers should
                  be using the version that was shipped with our development
                  tools as that may be a more recent version of the file.
                  
                  Note: This file contains just a subset of the methods
                  contained in our commercial version
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.


USING Consultingwerk.* FROM PROPATH .  
USING Progress.Lang.* FROM PROPATH .

CLASS Consultingwerk.CharacterType: 

    /*------------------------------------------------------------------------------
        Purpose: Disallow instance creation
        Notes:   
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE CharacterType ():
        SUPER ().
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Verifies if the passed in character string is not unknown value
                 or empty 
        Notes:   
        @param pcCharacter The character to compare
        @return True when the passed in character value is not ? or Empty 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LOGICAL IsNotNullOrEmpty (pcCharacter AS CHARACTER):
        
        RETURN pcCharacter > "":U.

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Verifies if the passed in character string is the unknown value
                 or empty 
        Notes:   
        @param pcCharacter The character to compare
        @return True when the passed in character value is ? or Empty 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LOGICAL IsNullOrEmpty (pcCharacter AS CHARACTER):
        
        RETURN pcCharacter = ? OR pcCharacter = "":U.

    END METHOD .

END CLASS.
