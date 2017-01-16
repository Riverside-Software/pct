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
    File        : ServiceLoader
    Purpose     : Automates loading of services into the ServiceContainer
    Syntax      : 
    Description : Temp-Table Structure in Consultingwerk/Framework/ttServiceLoader.i
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Mon Nov 07 23:14:29 CET 2011
    Notes       : The ServiceTypeName field in the temp-table / xml document
                  may contain a comma-delimited list of interface/class names.
                  In that case a single service instance will be registerd 
                  using multiple interfaces 
                  Sample XML structure:
                  <ttServiceLoader xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                    <ttServiceLoaderRow>
                      <Order>1</Order>
                      <ServiceTypeName>Consultingwerk.Framework.IAuthenticationService</ServiceTypeName>
                      <ServiceClassName>Consultingwerk.SmartFramework.Authentication.AuthenticationService</ServiceClassName>
                      <Disabled>false</Disabled>
                    </ttServiceLoaderRow>
                  </ttServiceLoader>                        
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Exceptions.* FROM PROPATH .
USING Consultingwerk.Framework.*  FROM PROPATH .
USING Progress.Lang.*             FROM PROPATH .

CLASS Consultingwerk.Framework.ServiceLoader:

    {Consultingwerk/Framework/ttServiceLoader.i}

    /*------------------------------------------------------------------------------
        Purpose: Returns the reference to the ServiceContainer used by this ServiceLoader                                                                      
        Notes:                                          
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY ServiceContainer AS IServiceContainer NO-UNDO 
    GET.
    PROTECTED SET. 

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the ServiceLoader class                                                                      
        Notes:   Uses FrameworkSettings:ServiceContainer as the default ServiceContainer                                          
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC ServiceLoader ():
        
        THIS-OBJECT (FrameworkSettings:ServiceContainer) .
        
    END CONSTRUCTOR.
     
    /*------------------------------------------------------------------------------
        Purpose: Constructor for the ServiceLoader class                                                                      
        Notes:                                          
        @param poServiceContainer The ServiceContainer to work with                              
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC ServiceLoader (poServiceContainer AS IServiceContainer):
        SUPER ().
        
        THIS-OBJECT:ServiceContainer = poServiceContainer .
        
    END CONSTRUCTOR.
     
    /*------------------------------------------------------------------------------
        Purpose: Loads and registers services from a XML file                                                                      
        Notes:                                          
        @param pcFileName An XML Document containing the service definitions                             
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID Load (pcFileName AS CHARACTER):
        
        FILE-INFO:FILE-NAME = pcFileName . 
        IF FILE-INFO:FULL-PATHNAME = ? THEN 
            UNDO, THROW NEW InvalidParameterValueException ("pcFileName":U,
                                                            pcFileName,
                                                            "Consultingwerk.Framework.ServiceLoader":U) .
            
        TEMP-TABLE ttServiceLoader:READ-XML ("FILE":U,
                                             FILE-INFO:FULL-PATHNAME, 
                                             "EMPTY":U,
                                             ?,
                                             ?) .

        THIS-OBJECT:Load (TEMP-TABLE ttServiceLoader:HANDLE) .
                                             
        FINALLY:
            EMPTY TEMP-TABLE ttServiceLoader .     
        END FINALLY.                                             
        
    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Loads and registers services from a temp-table                                            
        Notes:                                          
        @param phTableHandle The handle to a temp-table containing the service definitions                             
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID Load (phTableHandle AS HANDLE):
        
        DEFINE VARIABLE hBuffer    AS HANDLE               NO-UNDO .
        DEFINE VARIABLE hQuery     AS HANDLE               NO-UNDO .
        DEFINE VARIABLE cInterface AS CHARACTER            NO-UNDO .
        DEFINE VARIABLE cClassName AS CHARACTER            NO-UNDO .
        DEFINE VARIABLE oClass     AS Progress.Lang.Class  NO-UNDO .
        DEFINE VARIABLE oService   AS Progress.Lang.Object NO-UNDO .
        DEFINE VARIABLE i          AS INTEGER              NO-UNDO .
        
        Consultingwerk.Assertion.HandleAssert:WidgetType (phTableHandle, 
                                                          Consultingwerk.WidgetTypeEnum:TempTable) .
        
        ASSIGN hBuffer = phTableHandle:DEFAULT-BUFFER-HANDLE 
               hQuery  = Consultingwerk.Util.QueryHelper:CreatePreparedQuery (hBuffer).
        
        serviceLoop:
        DO WHILE NOT hQuery:QUERY-OFF-END ON ERROR UNDO, THROW:
    
            /* Mike Fechner, Consultingwerk Ltd. 07.01.2013
               Ability to temporarily disable loading of services by using the 
               <disabled>yes</disabled> Tag */
            IF hBuffer::Disabled = TRUE THEN 
                NEXT serviceLoop . 
    
            IF hBuffer::RequiredDatabases > "":U THEN DO ON ERROR UNDO, THROW:
                DO i = 1 TO NUM-ENTRIES (hBuffer::RequiredDatabases) ON ERROR UNDO, THROW:
                    IF NOT CONNECTED (ENTRY (i, hBuffer::RequiredDatabases)) THEN 
                        NEXT serviceLoop . 
                END.
            END.
    
            ASSIGN cClassName = hBuffer::ServiceClassName .
                   
            oService = DYNAMIC-NEW (cClassName) () .    
        
            /* Mike Fechner, Consultingwerk Ltd. 11.01.2012
               Support for registering a single service instance for
               multiple interfaces using a comma-delimited list */
            DO i = 1 TO NUM-ENTRIES (hBuffer::ServiceTypeName) ON ERROR UNDO, THROW:
    
                ASSIGN cInterface = ENTRY (i, hBuffer::ServiceTypeName)
                       oClass     = Progress.Lang.Class:GetClass (cInterface) . 
        
                THIS-OBJECT:ServiceContainer:AddService (oClass, oService) .
            END.
                        
            FINALLY:
                hQuery:GET-NEXT ().            
            END FINALLY.
        END.
        
    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Loads and registers services from an XML file  
        Notes:   
        @param pcFileName An XML Document containing the service definitions                             
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID LoadFromFile (pcFileName AS CHARACTER):
		
		DEFINE VARIABLE oLoader AS ServiceLoader NO-UNDO . 
		
		oLoader = NEW ServiceLoader ().
		oLoader:Load (pcFileName) .
		
		FINALLY:
            DELETE OBJECT oLoader . 		
        END FINALLY.

	END METHOD .

END CLASS.
