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
    File        : FrameworkSettings
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Thu May 07 10:15:20 CEST 2009
    Notes       : This class should only contain static members.
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW . 

{ Consultingwerk/products.i }

USING Consultingwerk.Framework.*            FROM PROPATH .
USING Consultingwerk.Framework.Exceptions.* FROM PROPATH .
USING Consultingwerk.OERA.*                 FROM PROPATH .
USING Consultingwerk.Util.*                 FROM PROPATH . 
USING Progress.Lang.*                       FROM PROPATH .
&IF DEFINED (DotNetAccessible) NE 0 &THEN 
USING System.Windows.Forms.*                FROM ASSEMBLY .
&ENDIF

CLASS Consultingwerk.Framework.FrameworkSettings   : 
    

    /*------------------------------------------------------------------------------
        Purpose: Gets/Sets if various debug messages (i.e. Stack Trace information) 
                 should be displayed                                                                        
        Notes:   Set to TRUE by default if SESSION:PARAM contains DebugMode                                                                        
    ------------------------------------------------------------------------------*/            
    DEFINE PUBLIC STATIC PROPERTY DebugMode AS LOGICAL NO-UNDO INIT FALSE 
    GET.
    SET.
    
    /*------------------------------------------------------------------------------
        Purpose:  Gets or sets the instance of the framework default service container 
        Notes:      
    ------------------------------------------------------------------------------*/    
    DEFINE PUBLIC STATIC PROPERTY ServiceContainer AS Consultingwerk.Framework.IServiceContainer NO-UNDO 
    GET ():
        IF NOT VALID-OBJECT (FrameworkSettings:ServiceContainer) THEN 
            
            FrameworkSettings:ServiceContainer = NEW ServiceContainer () . 

        RETURN FrameworkSettings:ServiceContainer . 
    END GET.
    SET. 

    /*------------------------------------------------------------------------------
        Purpose: Return the session startup propath  
        Notes:   The session startup propath may be updated using the 
                 StoreStartupPropath method. This property is also set in the
                 Constructror of the FrameworkSettings static class  
    ------------------------------------------------------------------------------*/
	DEFINE PUBLIC STATIC PROPERTY StartupPropath AS CHARACTER NO-UNDO 
	GET.
	PRIVATE SET. 

    /*------------------------------------------------------------------------------
        Purpose: Initialze SessionServiceManager as default AppServerServiceManager
                 implementation.                                                                        
        Notes:                                                                        
    ------------------------------------------------------------------------------*/        
    CONSTRUCTOR STATIC FrameworkSettings ():
  
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Stores the current prpoath in the StartupPropath property 
        Notes:   
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID StoreStartupPropath ():
		
		ASSIGN FrameworkSettings:StartupPropath = PROPATH . 

	END METHOD .

END CLASS.
