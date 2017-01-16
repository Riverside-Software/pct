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
    File        : ErrorHelper
    Purpose     : Various support routines for structured error handling
    Syntax      : Static methods only, private constructor to disallow 
                  instance creation
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Sat Jul 04 13:29:48 CEST 2009
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{ Consultingwerk/products.i }

USING Consultingwerk.Exceptions.*            FROM PROPATH . 
USING Consultingwerk.Framework.*             FROM PROPATH .
USING Consultingwerk.Framework.Collections.* FROM PROPATH .
USING Consultingwerk.Util.*                  FROM PROPATH .
USING Consultingwerk.Util.Forms.*            FROM PROPATH . 
USING Progress.Lang.*                        FROM PROPATH .

CLASS Consultingwerk.Util.ErrorHelper: 

    /*------------------------------------------------------------------------------
        Purpose: Private default constructor. 
        Notes:   There's no need to create instances of the helper classes                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE ErrorHelper ():
        SUPER ().
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Returns the current ABL stack trace
        Notes:   Throws an AppError to receive the stack trace, works also when 
                 SESSION:ERROR-STATUS-TRACE is generally set to FALSE
        @return The current ABL Stacktrace 
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC STATIC PROPERTY CurrentStacktrace AS CHARACTER NO-UNDO 
    GET():
       
        DEFINE VARIABLE cStacktrace        AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lCurrentErrorStack AS LOGICAL NO-UNDO.
        DEFINE VARIABLE iIndex AS INTEGER NO-UNDO.
       
        ASSIGN lCurrentErrorStack         = SESSION:ERROR-STACK-TRACE 
               SESSION:ERROR-STACK-TRACE  = TRUE .
       
        DO ON ERROR UNDO, THROW:
            UNDO, THROW NEW AppError () .     
            
            CATCH err AS Progress.Lang.Error:
                ASSIGN cStacktrace = err:CallStack .    
            END CATCH.
        END.
       
        ASSIGN iIndex = R-INDEX (cStacktrace, CHR (10)) .
           
        IF iIndex > 1 THEN 
            ASSIGN cStacktrace = SUBSTRING (cStacktrace, 1, iIndex - 1) .
        
        RETURN cStacktrace .
       
        FINALLY:
            ASSIGN SESSION:ERROR-STACK-TRACE = lCurrentErrorStack .    
        END FINALLY.
        
    END GET.

    /*------------------------------------------------------------------------------
        Purpose: Allows to control if the ShowErrorMessage methods are allowed 
                 to show an error message using a GUI for .NET Form                                                                      
        Notes:   When set to FALSE the message is delegated to the ShowErrorMessageBox
                 methods
    ------------------------------------------------------------------------------*/        
    DEFINE PUBLIC STATIC PROPERTY ErrorMessageDialogAllowed AS LOGICAL INITIAL TRUE NO-UNDO 
    GET.
    SET.
    
    /*------------------------------------------------------------------------------
        Purpose: The type name of the Form to be used as the ErrorMessageForm                                                                       
        Notes:   The type needs to implement the 
                 Consultingwerk.Util.Forms.IErrorMessageForm interface
    ------------------------------------------------------------------------------*/        
    DEFINE PUBLIC STATIC PROPERTY ErrorMessageFormType AS CHARACTER NO-UNDO 
         INIT "Consultingwerk.Windows.Util.Forms.ErrorMessageForm":U 
    GET.
    SET. 

     /*------------------------------------------------------------------------------
        Purpose: Allows to control if Table And Field information should be suppressed
                 with messages generated by the backend.                                                                        
        Notes:                                                                        
    ------------------------------------------------------------------------------*/    
    DEFINE PUBLIC STATIC PROPERTY SuppressTableAndFieldInfo AS LOGICAL INITIAL FALSE NO-UNDO 
    GET.
    SET.    

     /*------------------------------------------------------------------------------
        Purpose: Adds an ADM2 style formatted error message to an existing error 
                 message string
        Notes:                                                                        
        @param pcMessage The existing message text
        @param pcText The text of the additional message
        @param pcField The field that the message belongs to
        @param pcTable The table that the message belongs to
        @return The resulting message text
    ------------------------------------------------------------------------------*/    
    METHOD PUBLIC STATIC CHARACTER AddErrorMessage (pcMessage AS CHARACTER, 
                                                    pcText AS CHARACTER,
                                                    pcField AS CHARACTER,
                                                    pcTable AS CHARACTER):
        
        DEFINE VARIABLE iMsg     AS INTEGER   NO-UNDO.
        DEFINE VARIABLE iMsgCnt  AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cMessage AS CHARACTER NO-UNDO.
  
        /* If one or more "raw" messages were passed (i.e., they are already in
           the delimited formatted created below), then these were returned from
           an AppServer object or other remote object. Just append them to any local
           messages. */
 
        IF pcText NE ? AND INDEX(pcText, CHR(4)) NE 0 THEN
          ASSIGN pcMessage = pcMessage +
            (IF pcMessage NE "":U THEN CHR(3) ELSE "":U) + pcText.
      
        ELSE DO:
            /* If there's no message passed, this means that a Progress ERROR-STATUS
               was detected, so we add a row for each of those messages. */
       
            iMsgCnt = IF pcText = ? THEN ERROR-STATUS:NUM-MESSAGES ELSE 1.
                 
            DO iMsg = 1 TO iMsgCnt:
              IF pcText = ? THEN
              DO:
              /* When logging ERROR-STATUS messages, remove any which directly 
                 reference the BUFFER-FIELD attribute; these errors are side-effects
                 of other assignment errors which should be reported to the user
                 instead. */
                cMessage = ERROR-STATUS:GET-MESSAGE(iMsg).
                IF INDEX(cMessage, "BUFFER-FIELD":U) NE 0 THEN NEXT.
              END. /* END DO IF pcText = ? */
              
              ASSIGN pcMessage = pcMessage +
                     (IF pcMessage NE "":U THEN CHR(3) ELSE "":U) +
                     (IF pcText = ? THEN cMessage ELSE pcText)
                     + CHR(4) + (IF pcField = ? THEN "":U ELSE pcField)
                     + CHR(4) + (IF pcTable = ? THEN "":U ELSE pcTable).
            END.   /* END DO iMsg */
        END.     /* END ELSE DO */
  
          RETURN pcMessage .

    END METHOD.

     /*------------------------------------------------------------------------------
        Purpose: Returns a single CHARACTER string composed of the error-strings 
                 of all records (from all tables in the given Dataset instance)                                                              
        Notes:      
        @param phDataset The handle of the dataset to return the error strings from
        @return The string composed of the error-strings of all records                                                                   
    ------------------------------------------------------------------------------*/     
    METHOD PUBLIC STATIC CHARACTER DatasetErrorStrings (phDataset AS HANDLE):
        
        DEFINE VARIABLE cErrorStrings AS CHARACTER NO-UNDO.
        
        DEFINE VARIABLE iBuffer       AS INTEGER NO-UNDO.
        DEFINE VARIABLE hBeforeQuery  AS HANDLE  NO-UNDO.
        DEFINE VARIABLE hBeforeTable  AS HANDLE  NO-UNDO.
        DEFINE VARIABLE hBeforeBuffer AS HANDLE  NO-UNDO.
    
        CREATE QUERY hBeforeQuery.
    
        DO iBuffer = 1 TO phDataset:NUM-BUFFERS:
           hBeforeTable = phDataset:GET-BUFFER-HANDLE(iBuffer):TABLE-HANDLE:BEFORE-TABLE.
           IF NOT VALID-HANDLE(hBeforeTable) OR NOT hBeforeTable:HAS-RECORDS THEN
               NEXT.
               
           hBeforeBuffer = phDataset:GET-BUFFER-HANDLE(iBuffer):BEFORE-BUFFER.
           hBeforeQuery:SET-BUFFERS (hBeforeBuffer).
           hBeforeQuery:QUERY-PREPARE (SUBSTITUTE ("FOR EACH &1":U, hBeforeBuffer:NAME)).
           hBeforeQuery:QUERY-OPEN ().
           hBeforeQuery:GET-FIRST ().
         
           DO WHILE hBeforeQuery:QUERY-OFF-END = FALSE.
               IF hBeforeBuffer:ERROR OR hBeforeBuffer:REJECTED THEN
               DO:
                   IF hBeforeBuffer:ERROR-STRING > "":U THEN
                   DO:
                       cErrorStrings = AddErrorMessage (cErrorStrings,
                                                        hBeforeBuffer:ERROR-STRING,
                                                        "":U,
                                                        phDataset:GET-BUFFER-HANDLE(iBuffer):TABLE-HANDLE:NAME).
                   END.
               END. 
               hBeforeQuery:GET-NEXT() .
           END.
        END.
                
        RETURN cErrorStrings .
        
        FINALLY:
            DELETE OBJECT hBeforeQuery.
        END FINALLY.            
    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns the Typename of the error object                                                                        
        Notes:   Required as .NET Exceptions don't have an ABL Class 
                 (GetClass() returns ?)         
        @param e The Error (Progress error of .NET Exception) to return the type name for
        @return The type name (class name) of the error object
    ------------------------------------------------------------------------------*/    
    METHOD PUBLIC STATIC CHARACTER ErrorTypeName (e AS Progress.Lang.Error):

&IF DEFINED (DotNetAccessible) NE 0 &THEN       
        IF TYPE-OF (e, System.Exception) THEN 
            RETURN CAST(e, System.Exception):GetType():ToString() .
        ELSE 
&ENDIF
            RETURN e:GetClass():TypeName .    
              
    END METHOD.

     /*------------------------------------------------------------------------------
        Purpose: Returns a single CHARACTER string composed of the messages 
                 Contained in the Progress.Lang.Error object                                                                        
        Notes:    
        @param poError The Progress.Lang.Error to format
        @return A string containing all formatted messages from the Error object                                                                  
    ------------------------------------------------------------------------------*/    
    METHOD PUBLIC STATIC CHARACTER FormattedErrorMessages (poError AS Progress.Lang.Error):
        
        DEFINE VARIABLE iMessage   AS INTEGER        NO-UNDO.
        DEFINE VARIABLE cReturn    AS CHARACTER      NO-UNDO.
        DEFINE VARIABLE cMessage   AS CHARACTER      NO-UNDO.
        DEFINE VARIABLE cEntry     AS CHARACTER      NO-UNDO.
        DEFINE VARIABLE cFormatted AS CHARACTER      NO-UNDO.
        DEFINE VARIABLE iError     AS INTEGER        NO-UNDO.
        DEFINE VARIABLE oSoapFault AS SoapFaultError NO-UNDO .  
        
        DO iError = 1 TO poError:NumMessages:

            ASSIGN cMessage = poError:GetMessage(iError).
            
            /* Mike Fechner, Consultingwerk Ltd. 04.07.2009
               Formatting of ADM2 Style error messages */
            IF INDEX(cMessage, CHR(4)) > 0 THEN DO: 
                DO iMessage = 1 TO NUM-ENTRIES(cMessage, CHR(3)):
                    ASSIGN cEntry     = ENTRY(iMessage, cMessage, CHR(3))
                           cFormatted = ENTRY(1, cEntry, CHR(4)).                     
                    
                    /* Mike Fechner, Consultingwerk Ltd. 06.11.2009
                       Ability to suppress Table and Field Info with Dataset Error Messages */                    
                    IF ErrorHelper:SuppressTableAndFieldInfo = FALSE THEN DO:
                        IF NUM-ENTRIES(cEntry, CHR(4)) > 1 AND ENTRY(2, cEntry, CHR(4)) > "":U THEN
                            ASSIGN cFormatted = cFormatted + "~n  ":U + "Field: "{&TRAN} + ENTRY(2, cEntry, CHR(4)) .
                        IF NUM-ENTRIES(cEntry, CHR(4)) > 2 AND ENTRY(3, cEntry, CHR(4)) > "":U THEN
                            ASSIGN cFormatted = cFormatted + "~n  ":U + "Table: "{&TRAN} + ENTRY(3, cEntry, CHR(4)) .
                    END.
                        
                    ASSIGN cFormatted = cFormatted + "~n":U .                        
                END.
            
                ASSIGN cMessage = cFormatted .                
            END.
            
            cReturn = cReturn + 
                       (IF iError > 1 THEN "~n":U ELSE "":U) + 
                       cMessage .  
        END.
        
        /* Mike Fechner, Consultingwerk Ltd. 21.10.2011
           Output SOAP-FAULT */
        IF TYPE-OF (poError, Progress.Lang.SoapFaultError) THEN DO:
            oSoapFault = CAST (poError, Progress.Lang.SoapFaultError) .
            
            IF VALID-HANDLE (oSoapFault:SoapFault) THEN 
                cReturn = SUBSTITUTE ("&1~n~nSOAP fault: &2~nFault detail: &3~nFault code: &4~nFault Actor: &5"{&TRAN},
                                      cReturn, 
                                      oSoapFault:SoapFault:SOAP-FAULT-STRING,
                                      oSoapFault:SoapFault:SOAP-FAULT-DETAIL,
                                      oSoapFault:SoapFault:SOAP-FAULT-CODE,
                                      oSoapFault:SoapFault:SOAP-FAULT-ACTOR) .  
        END.
        
        RETURN cReturn .

    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Returns a single CHARACTER string composed of the messages 
                 Contained in the Progress.Lang.Error object, including the stack 
                 trace and the text of inner exceptions when present                                                                        
        Notes:   Useful when logging complex error objects to a file 
        @param poError The Progress.Lang.Error to format
        @return A string containing all formatted messages from the Error object                                                                  
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC CHARACTER FormattedErrorMessagesExt (poError AS Progress.Lang.Error):
		
        DEFINE VARIABLE cReturn     AS CHARACTER           NO-UNDO .
        DEFINE VARIABLE iIndent     AS INTEGER             NO-UNDO .
        
        DEFINE VARIABLE cType       AS CHARACTER           NO-UNDO .
        DEFINE VARIABLE cMessage    AS CHARACTER           NO-UNDO .
        DEFINE VARIABLE cStacktrace AS CHARACTER           NO-UNDO .
        DEFINE VARIABLE cPattern    AS CHARACTER           NO-UNDO INIT "An &1 has occured:"{&TRAN} .
        
        DEFINE VARIABLE oError      AS Progress.Lang.Error NO-UNDO . 
        
        oError = poError .
        
        DO WHILE VALID-OBJECT (oError) ON ERROR UNDO, THROW:
        
            ASSIGN cType       = ErrorHelper:ErrorTypeName (oError)
                   cMessage    = ErrorHelper:FormattedErrorMessages (oError)
                   cStacktrace = ErrorHelper:StackTrace (oError) 
                .

            IF cType > "":U THEN 
                cReturn = cReturn + 
                          StringHelper:Indent (SUBSTITUTE (cPattern, cType), 
                                               iIndent * 5) +
                          Consultingwerk.Environment:NewLine . 
            
            IF cMessage > "":U THEN 
                cReturn = cReturn + 
                          StringHelper:Indent (cMessage, 
                                               iIndent * 5) +
                          Consultingwerk.Environment:NewLine . 

            IF cStacktrace > "":U THEN 
                cReturn = cReturn + 
                          StringHelper:Indent (cStacktrace, 
                                               iIndent * 5) +
                          Consultingwerk.Environment:NewLine . 
            

            IF TYPE-OF (oError, ISupportsInnerException) THEN DO:
                ASSIGN oError   = CAST (oError, ISupportsInnerException):InnerException 
                       iIndent  = iIndent + 1 
                       cPattern = "Caused by an &1:"{&TRAN} . 
            END.
            ELSE 
                oError = ? . 
        END.
        
        RETURN cReturn .

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Display Error Message                                                                        
        Notes:   Stacktrack will be displayed when FrameworkSettings:DebugMode = TRUE           
        @param e The Error object to visualize
        @param pcTitle The title for the message message (dialog)
    ------------------------------------------------------------------------------*/    
    METHOD PUBLIC STATIC VOID ShowErrorMessage (e AS Progress.Lang.Error, 
                                                pcTitle AS CHARACTER):
        

        ErrorHelper:ShowErrorMessageBox (e, pcTitle) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Display Error Message                                                                        
        Notes:   Error Type (Class) will be used a default title    
        @param e The Error object to visualize
    ------------------------------------------------------------------------------*/    
    METHOD PUBLIC STATIC VOID ShowErrorMessage (e AS Progress.Lang.Error):
    
        DEFINE VARIABLE cTitle AS CHARACTER NO-UNDO.
                                
        ErrorHelper:ShowErrorMessageBox (e) .
                
    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Display Error Message as an alert-box (to be used in functions 
                 and non-void methods due to WAIT-FOR limitations)                                                                      
        Notes:   Stacktrack will be displayed when FrameworkSettings:DebugMode = TRUE    
        @param e The Error object to visualize
        @param pcTitle The title for the message message (dialog)
    ------------------------------------------------------------------------------*/    
    METHOD PUBLIC STATIC VOID ShowErrorMessageBox (e AS Progress.Lang.Error, 
                                                   pcTitle AS CHARACTER):
        
        DEFINE VARIABLE cErrorString AS CHARACTER NO-UNDO.
        
        ASSIGN cErrorString = ErrorHelper:FormattedErrorMessages (e) .
        
        IF TYPE-OF (e, Progress.Lang.AppError) AND CAST (e, Progress.Lang.AppError):ReturnValue > "":U THEN 
            ASSIGN cErrorString = cErrorString + (IF cErrorString > "":U THEN "~n~n":U ELSE "":U) +
                                  CAST (e, Progress.Lang.AppError):ReturnValue .

        /* Mike Fechner, Consultingwerk Ltd. 14.07.2009
           If no error string was given, use the error class name as fall back */                   
        IF cErrorString > "":U THEN .
        ELSE cErrorString = ErrorHelper:ErrorTypeName(e) .

        MESSAGE cErrorString SKIP(2) 
                ErrorHelper:StackTrace (e)
           VIEW-AS ALERT-BOX ERROR TITLE pcTitle . 

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Display Error Message as an alert-box (to be used in functions 
                 and non-void methods due to WAIT-FOR limitations)                                                                        
        Notes:   Error Type (Class) will be used a default title               
        @param e The Error object to visualize
    ------------------------------------------------------------------------------*/    
    METHOD PUBLIC STATIC VOID ShowErrorMessageBox (e AS Progress.Lang.Error):

        DEFINE VARIABLE cTitle AS CHARACTER NO-UNDO.
    
        ASSIGN cTitle = ErrorHelper:ErrorTypeName(e) . 
    
        ErrorHelper:ShowErrorMessageBox (e, cTitle) .
                
    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Reformats the Error Stack Trace (most current code block first, 
                 not last as provided by the CallStack attribute                                                                        
        Notes:    
        @param e The error object to return the formatted stacktrace for
        @return The formatted stack trace                                                                    
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR StackTrace (e AS Progress.Lang.Error):

        DEFINE VARIABLE i       AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cReturn AS CHARACTER NO-UNDO.

        IF e:CallStack > "":U THEN DO:
            DO i = NUM-ENTRIES(e:CallStack, CHR(10)) TO 1 BY -1.  
                ASSIGN cReturn = cReturn + ENTRY(i, e:CallStack, CHR(10)) + CHR(10). 
            END.
        END.    
        ELSE 
            cReturn =  "Stacktrace not provided (-errorstack missing)."{&TRAN} + CHR(10) .        

&IF DEFINED (DotNetAccessible) NE 0 &THEN       
        IF TYPE-OF(e, System.Exception) THEN 
            ASSIGN cReturn = cReturn + CHR(10) +
                             ".NET Stack Trace:"{&TRAN} + CHR(10) + 
                             CAST(e, System.Exception):StackTrace .             
&ENDIF
        RETURN TRIM(cReturn, CHR(10)) .             

    END METHOD.

 END CLASS.
