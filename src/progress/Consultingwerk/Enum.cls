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
    File        : Enum
    Purpose     : Abstract base type for Enum classes
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Wed Aug 25 10:30:24 CEST 2010
    Notes       : http://blog.consultingwerk.de/consultingwerkblog/2010/08/a-pattern-for-enums
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Progress.Lang.*.

CLASS Consultingwerk.Enum ABSTRACT: 

    /*------------------------------------------------------------------------------
        Purpose: Returns the character label associated with an enum member instance                                                                       
        Notes:   Instance member
    ------------------------------------------------------------------------------*/
    DEFINE PROTECTED PROPERTY Label AS CHARACTER NO-UNDO
    GET.
    SET.
    
    /*------------------------------------------------------------------------------
        Purpose: Returns the integer value associated with an enum member instance 
        Notes:   Instance member
    ------------------------------------------------------------------------------*/    
    DEFINE PUBLIC PROPERTY Value AS INTEGER NO-UNDO 
    GET.
    PROTECTED SET. 

    /*------------------------------------------------------------------------------
        Purpose: Compares this Enum member to another member of this Enum by Value                                                                        
        Notes:   Returns FALSE when the passed in object reference is not of this
                 Enum type  
        @param poParam The object to compare by value and type with the current enum member
        @return Logical value indicating if the two compared enum members are euqally
    ------------------------------------------------------------------------------*/
    METHOD OVERRIDE PUBLIC LOGICAL Equals (INPUT poParam AS Progress.Lang.Object):
        
        /* Mike Fechner, Consultingwerk Ltd. 24.03.2011
           When poParam is invalid, Euquals returns FALSE */
        IF (NOT VALID-OBJECT (poParam)) OR (NOT poParam:GetClass() = THIS-OBJECT:GetClass()) THEN 
            RETURN FALSE . 
        
        RETURN CAST (poParam, Consultingwerk.Enum):Value = THIS-OBJECT:Value .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns a CHARACTER representation (human readable) of the 
                 Enum member                                                                      
        Notes:          
        @return The CHARACTER representation of the enum member, identically to the Label property                                                              
    ------------------------------------------------------------------------------*/
    METHOD OVERRIDE PUBLIC CHARACTER ToString ():
        
        RETURN THIS-OBJECT:Label .

    END METHOD.

END CLASS.