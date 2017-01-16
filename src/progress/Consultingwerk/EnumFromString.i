&IF 1=0 &THEN
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
    File        : EnumFromString.i
    Purpose     : Default method to turn a CHARACTER Value into an 
                  Enum member reference

    Syntax      : {Consultingwerk/EnumFromString.i EnumPackage.EnumClassName} 
        
    Description : 

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Tue Feb 12 16:17:11 CEST 2013
    Notes       :
  ----------------------------------------------------------------------*/
&ENDIF

&IF NOT PROVERSION BEGINS "10.2":U &THEN
    /*------------------------------------------------------------------------------
        Purpose: Returns the reference to the Enum member with the given name
        Notes:   Only supported from OpenEdge 11.0 on 
        @param pcMemberName The name of the Enum member to return
        @return The reference to the Enum member 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC {1} FromString (pcMemberName AS CHARACTER):
        
        RETURN DYNAMIC-PROPERTY ("{1}":U, pcMemberName) .
        
        /* Error handling, when invalid member name was passed in */
        CATCH err AS Progress.Lang.Error:
            RETURN ? .  
        END CATCH.

    END METHOD .
&ENDIF
