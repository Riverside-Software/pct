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
    File        : IServiceContainerDebugging
    Purpose     : Interface that describes the required methods for 
                  debugging features of the ServiceContainer framework
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Fri Jun 07 08:28:54 CEST 2013
    Notes       : 
  ----------------------------------------------------------------------*/

USING Consultingwerk.Framework.* FROM PROPATH .  
USING Progress.Lang.*            FROM PROPATH.

INTERFACE Consultingwerk.Framework.IServiceContainerDebugging:  
  
    { Consultingwerk/Framework/ttServiceTable.i }  
  
    /*------------------------------------------------------------------------------
        Purpose: Returns the service instances as a ttServiceTable output 
        Notes:   See Consultingwerk/Framework/ttServiceTable.i   
        @param ttServiceTable OUTPUT TABLE The temp-table with the service definitions
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC VOID GetServiceTable (OUTPUT TABLE ttServiceTable).

END INTERFACE.
