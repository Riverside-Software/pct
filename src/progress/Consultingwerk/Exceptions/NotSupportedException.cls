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
    File        : NotSupportedException
    Purpose     : General purpose error class for methods that are not
                  supported
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwer Ltd.
    Created     : Mon Apr 25 00:04:42 CET 2011
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW .

{Consultingwerk/products.i}

USING Consultingwerk.Exceptions.* FROM PROPATH .
USING Progress.Lang.*             FROM PROPATH .

CLASS Consultingwerk.Exceptions.NotSupportedException 
    INHERITS Exception: 
    
    /*------------------------------------------------------------------------------
        Purpose: Returns the class name that caused this NotSupportedException 
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY ClassName AS CHARACTER NO-UNDO 
    GET.
    PRIVATE SET. 

    /*------------------------------------------------------------------------------
        Purpose: Returns the method name that caused this NotSupportedException 
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY MethodName AS CHARACTER NO-UNDO 
    GET.
    PRIVATE SET. 
    
    /*------------------------------------------------------------------------------
        Purpose: Constructor of the NotSupportedException class                                                                       
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC NotSupportedException ():
        SUPER ("This method is not supported."{&TRAN}, 0).
    
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the NotSupportedException class                                                                       
        Notes:
        @param poInnerException The reference to the original error
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC NotSupportedException (poInnerException AS Error):
        
        SUPER (poInnerException,
               "This method is not supported."{&TRAN}, 
               0).
    
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the NotSupportedException class                                                                     
        Notes:
        @param pcMethodName The name of the method that is not implemented
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC NotSupportedException (pcMethodName AS CHARACTER):
        
        SUPER (SUBSTITUTE("The method &1 is not supported."{&TRAN}, 
                          pcMethodName), 0).

        ASSIGN THIS-OBJECT:MethodName = pcMethodName .
           
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the NotSupportedException class                                                                     
        Notes:
        @param poInnerException The reference to the original error
        @param pcMethodName The name of the method that is not implemented
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC NotSupportedException (poInnerException AS Error,
                                              pcMethodName AS CHARACTER):
        
        SUPER (poInnerException,
               SUBSTITUTE("The method &1 is not supported."{&TRAN}, 
                          pcMethodName), 
               0).

        ASSIGN THIS-OBJECT:MethodName = pcMethodName .
           
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the NotSupportedException class                                                                      
        Notes:                                                                        
        @param pcMethodName The name of the method that is not implemented
        @param pcClassName The name of the class that caused this NotSupportedException
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC NotSupportedException (pcMethodName AS CHARACTER,
                                              pcClassName  AS CHARACTER):
                                                    
        THIS-OBJECT (pcMethodName, pcClassName, ?) .
           
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the NotSupportedException class                                                                      
        Notes:                                                                        
        @param pcMethodName The name of the method that is not implemented
        @param pcClassName The name of the class that caused this NotSupportedException
        @param pcErrorMessage An Additional Custom Error Message
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC NotSupportedException (pcMethodName   AS CHARACTER,
                                              pcClassName    AS CHARACTER,
                                              pcErrorMessage AS CHARACTER):
                                                    
        SUPER (SUBSTITUTE("The method &1 of class &2 is not supported."{&TRAN}, 
                          pcMethodName, pcClassName), 0).

        IF pcErrorMessage > "":U THEN 
            THIS-OBJECT:AddMessage (pcErrorMessage, 0) .

        ASSIGN THIS-OBJECT:ClassName  = pcClassName
               THIS-OBJECT:MethodName = pcMethodName .
           
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
        Purpose: Constructor of the NotSupportedException class                                                                      
        Notes:                                                                        
        @param poInnerException The reference to the original error
        @param pcMethodName The name of the method that is not implemented
        @param pcClassName The name of the class that caused this NotSupportedException
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC NotSupportedException (poInnerException AS Error,
                                              pcMethodName AS CHARACTER,
                                              pcClassName  AS CHARACTER):
                                 
        THIS-OBJECT (poInnerException, pcMethodName, pcClassName, ?) .                   
           
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the NotSupportedException class                                                                      
        Notes:                                                                        
        @param poInnerException The reference to the original error
        @param pcMethodName The name of the method that is not implemented
        @param pcClassName The name of the class that caused this NotSupportedException
        @param pcErrorMessage An Additional Custom Error Message
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC NotSupportedException (poInnerException AS Error,
                                              pcMethodName     AS CHARACTER,
                                              pcClassName      AS CHARACTER,
                                              pcErrorMessage   AS CHARACTER):
                                                    
        SUPER (poInnerException,
               SUBSTITUTE("The method &1 of class &2 is not supported."{&TRAN}, 
                          pcMethodName, pcClassName), 
               0).

        IF pcErrorMessage > "":U THEN 
            THIS-OBJECT:AddMessage (pcErrorMessage, 0) .

        ASSIGN THIS-OBJECT:ClassName  = pcClassName
               THIS-OBJECT:MethodName = pcMethodName .
           
    END CONSTRUCTOR.
    
END CLASS.
