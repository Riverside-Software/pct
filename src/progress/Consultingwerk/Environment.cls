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
    File        : Environment
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Wed Jan 09 23:02:13 CET 2013
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.* FROM PROPATH .  
USING Progress.Lang.*  FROM PROPATH .

{Consultingwerk/products.i}

CLASS Consultingwerk.Environment: 

    /*------------------------------------------------------------------------------
        Purpose: Returns the NewLine character on the current platform
        Notes:   
    ------------------------------------------------------------------------------*/
	DEFINE PUBLIC STATIC PROPERTY NewLine AS CHARACTER NO-UNDO 
	GET.
	PRIVATE SET. 

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the Environment class
        Notes:   
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR STATIC Environment ():
		
&IF DEFINED (DotNetAccessible) NE 0 &THEN
        ASSIGN Consultingwerk.Environment:NewLine = System.Environment:NewLine .
&ELSE
        ASSIGN Consultingwerk.Environment:NewLine = "~n":U .  
&ENDIF		
		
	END CONSTRUCTOR.

END CLASS.
