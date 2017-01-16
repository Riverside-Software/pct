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
    File        : ServiceAlreadyRegisteredException
    Purpose     : Error thrown from ServiceContainer:AddService when the 
                  service type is already registered with the Service Container
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Mon Apr 01 23:38:24 CEST 2013
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Exceptions.Exception.


USING Consultingwerk.Framework.Exceptions.* FROM PROPATH .  
USING Progress.Lang.* FROM PROPATH .

CLASS Consultingwerk.Framework.Exceptions.ServiceAlreadyRegisteredException 
    INHERITS Exception: 

    /*------------------------------------------------------------------------------
        Purpose: Returns the reference to the class or interface of the service that 
                 cannot be added   
        Notes:   
    ------------------------------------------------------------------------------*/
	DEFINE PUBLIC PROPERTY ServiceClass AS Progress.Lang.Class NO-UNDO 
	GET.
	PRIVATE SET. 

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the ServiceAlreadyRegisteredException class
        Notes:   
        @param poServiceClass The reference to the Class or interface of the service that cannot be added
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC ServiceAlreadyRegisteredException (poServiceClass AS Progress.Lang.Class):
		SUPER (SUBSTITUTE ("Unable to add the service for ~"&1~" to this service container. The specified type is already registered.", 
		                   poServiceClass:TypeName), 
		       0) .
		
		THIS-OBJECT:ServiceClass = poServiceClass .
		
	END CONSTRUCTOR.

END CLASS.
