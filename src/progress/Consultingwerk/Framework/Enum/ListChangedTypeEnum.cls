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
    File        : ListChangedTypeEnum
    Purpose     : Describes the possible values for the type of modification
                  that occured to an item of a List
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Thu Jan 19 21:55:49 CET 2012
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Enum                    FROM PROPATH .
USING Consultingwerk.Framework.Collections.* FROM PROPATH .
USING Consultingwerk.Framework.Enum.*        FROM PROPATH . 
USING Progress.Lang.*                        FROM PROPATH .

CLASS Consultingwerk.Framework.Enum.ListChangedTypeEnum 
    INHERITS Consultingwerk.Enum: 

    /*------------------------------------------------------------------------------
        Purpose: An Item was added to the List                                                                    
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    {Consultingwerk/EnumMember.i ListItemAdded 1 ListChangedTypeEnum}  

    /*------------------------------------------------------------------------------
        Purpose: An Item was removed from the List                                                                      
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    {Consultingwerk/EnumMember.i ListItemRemoved 2 ListChangedTypeEnum}  

    /*------------------------------------------------------------------------------
        Purpose: The an Item has changed 
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    {Consultingwerk/EnumMember.i ListItemChanged 3 ListChangedTypeEnum}  

    /*------------------------------------------------------------------------------
        Purpose: The List was cleared                                                                     
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    {Consultingwerk/EnumMember.i ListCleared 4 ListChangedTypeEnum}  


    /*------------------------------------------------------------------------------
        Purpose: Private Constructor for the enum member instances                                                                     
        Notes:    
        @param piValue The internal (numeric) representation of the Enumeration member
        @param pcLabel The text label of the Enumaration member
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE ListChangedTypeEnum (piValue AS INTEGER, pcLabel AS CHARACTER):
        SUPER ().
        
        ASSIGN THIS-OBJECT:Value = piValue
               THIS-OBJECT:Label = pcLabel . 
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Returns a CharacterList with the names of the Enum members 
        Notes:   
        @return The CharacterList with the names of the Enum members
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CharacterList GetNames ():
        
        DEFINE VARIABLE oReturn AS CharacterList NO-UNDO . 
        
        RETURN NEW CharacterList ('{&EnumMembers}':U).

    END METHOD .
    
    {Consultingwerk/EnumFromString.i Consultingwerk.Framework.Enum.ListChangedTypeEnum}
        
END CLASS.
    