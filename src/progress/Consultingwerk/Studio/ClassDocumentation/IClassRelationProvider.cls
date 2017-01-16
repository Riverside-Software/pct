/**********************************************************************
 * Copyright (C) 2006-2014 by Consultingwerk Ltd. ("CW") -            *
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
    File        : IClassRelationProvider
    Purpose     : Interface for classes providing information about 
                  relations between classes
    Syntax      : 
    Description : 
    Author(s)   : cInterface
    Created     : Wed Jul 02 22:57:16 CEST 2014
    Notes       : 
  ----------------------------------------------------------------------*/

USING Consultingwerk.Framework.Collections.*     FROM PROPATH . 
USING Consultingwerk.Studio.ClassDocumentation.* FROM PROPATH .  
USING Progress.Lang.*                            FROM PROPATH .

INTERFACE Consultingwerk.Studio.ClassDocumentation.IClassRelationProvider:  
  
    /*------------------------------------------------------------------------------
        Purpose: Returns the List of Child Classes of the given parent class
        Notes:   Returns direct and indirect child classes
        @param pcParentClass The name of the parent class
        @return The CharacterList of Child Classes
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CharacterList GetChildClasses (pcParentClass AS CHARACTER) .
  
    /*------------------------------------------------------------------------------
        Purpose: Returns the List of Classes implementing the given interface
        Notes:   Returns direct and indirect child classes
        @param pcInterfaceName The name of the interface 
        @return The CharacterList of Child Classes
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CharacterList GetImplementingClasses (pcInterfaceName AS CHARACTER) .  
  
END INTERFACE.