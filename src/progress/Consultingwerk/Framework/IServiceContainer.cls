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
    File        : IServiceContainer
    Purpose     : Provides a container for services. 
    Syntax      : 
    Description : General purpose interface to manage services by type / class
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Thu Dec 23 13:01:38 CET 2010
    Notes       : see System.ComponentModel.Design.IServiceContainer
                  http://msdn.microsoft.com/en-us/library/system.componentmodel.design.iservicecontainer.aspx
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

INTERFACE Consultingwerk.Framework.IServiceContainer:  
  
    /*------------------------------------------------------------------------------
        Purpose: Adds the specified service to the service container.                                                                      
        Notes:
        @param poClass The reference to the class or interface of the service to add
        @param poObject An instance of the service type to add. This object must implement or inherit from the type indicated by the serviceType parameter
        @return The reference to the service that was added (poObject). This allows fluid style usage of this routine                                                                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC Progress.Lang.Object AddService (poClass AS Progress.Lang.Class,
                                                   poObject AS Progress.Lang.Object).

    /*------------------------------------------------------------------------------
        Purpose: Gets the service object of the specified type.                                                                        
        Notes:          
        @param poClass The reference to the class or interface of the service to return
        @return The reference to the instance of the service of ? when the service is not registered with the service container 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC Progress.Lang.Object GetService (poClass AS Progress.Lang.Class).

    /*------------------------------------------------------------------------------
        Purpose: Removes the specified service type from the service container.                                                                        
        Notes:          
        @param poClass The reference to the class or interface of the service to remove from the service container.
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID RemoveService (poClass AS Progress.Lang.Class).

END INTERFACE.