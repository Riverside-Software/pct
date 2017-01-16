/**********************************************************************
 * Copyright 2013 Consultingwerk Ltd.                                 *
 *                                                                    *
 * Licensed under the Apache License, Version 2.0 (the "License");    *
 * you may not use this file except in compliance with the License.   *
 * You may obtain a copy of the License at                            *
 *                                                                    *
 *     http://www.apache.org/licenses/LICENSE-2.0                     *
 *                                                                    *
 * Unless required by applicable law or agreed to in writing,         *
 * software distributed under the License is distributed on an        * 
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,       *
 * either express or implied. See the License for the specific        *
 * language governing permissions and limitations under the License.  *
 *                                                                    *
 **********************************************************************/
/*------------------------------------------------------------------------
    File        : ParameterCommentValidator
    Purpose     : Validates missing parameter comments in class files
    Syntax      : 
    Description : 
    Author(s)   : Sebastian Düngel / Consultingwerk Ltd. 
    Created     : Wed Feb 06 09:18:55 CET 2013
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Studio.ClassDocumentation.* FROM PROPATH .
USING Consultingwerk.Studio.SmartDox.*           FROM PROPATH .
USING Consultingwerk.Util.*                      FROM PROPATH . 
USING Progress.Lang.*                            FROM PROPATH .

CLASS Consultingwerk.Studio.SmartDox.ParameterCommentValidator: 
    
    { Consultingwerk/Studio/SmartDox/ttMissingParameter.i }
    { Consultingwerk/Studio/ClassDocumentation/dsClassDocumentation.i }
    { Consultingwerk/Studio/ClassDocumentation/eParameterComment.i}
    { Consultingwerk/Util/TempTables/ttFileNames.i }
    
    DEFINE VARIABLE oParser AS ClassDocumentationParser NO-UNDO . 
    
    /*------------------------------------------------------------------------------
        Purpose: Gets and sets if verbose messages should be generated 
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY Verbose AS LOGICAL INITIAL FALSE NO-UNDO 
    GET.
    SET. 
    
    /*------------------------------------------------------------------------------
        Purpose: Create a temptable row
        Notes:   
        @param pcParameterScope The paramter scope 
        @param pcSourceType The source type
        @param pcSourceName The source name (fulltypename from class)
        @param pcMethodName The method name
        @param pcMethodModifier The method modifiere
        @param pcParameterName The parameter name
        @param plMissingComment Is the comment missing in the comment of is the parameter commented but missing in code
        @param pcParameterComment is only a comment available without parameter
    ------------------------------------------------------------------------------*/
	METHOD PROTECTED VOID AddTempTableRow (pcParameterScope   AS CHARACTER,
	                                       pcSourceType       AS CHARACTER,
	                                       pcSourceName       AS CHARACTER,
	                                       pcMethodName       AS CHARACTER,
	                                       pcMethodModifier   AS CHARACTER,
	                                       pcParameterName    AS CHARACTER,
	                                       plMissingComment   AS LOGICAL,
	                                       pcParameterComment AS CHARACTER):
		
		DEFINE BUFFER ttMissingParameter FOR ttMissingParameter . 
		
		IF NOT CAN-FIND (ttMissingParameter WHERE ttMissingParameter.SourceName     = pcSourceName 
                                              AND ttMissingParameter.MethodName     = pcMethodName
                                              AND ttMissingParameter.ParameterName  = pcParameterName) THEN DO:
            CREATE ttMissingParameter.

            ASSIGN ttMissingParameter.ParameterScope   = pcParameterScope
                   ttMissingParameter.SourceType       = pcSourceType
                   ttMissingParameter.SourceName       = pcSourceName
                   ttMissingParameter.MethodName       = pcMethodName
                   ttMissingParameter.MethodModifier   = pcMethodModifier
                   ttMissingParameter.ParameterName    = pcParameterName
                   ttMissingParameter.MissingComment   = plMissingComment
                   ttMissingParameter.ParameterComment = pcParameterComment
                   .
         END.

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Create all missing method parameter
        Notes:   
        @param pcSourceType The eUnit Source type
        @param pcSourceName The eUnit source name
    ------------------------------------------------------------------------------*/
	METHOD PROTECTED VOID CreateMissingMethodParameter (pcSourceType AS CHARACTER,
	                                                    pcSourceName AS CHARACTER):
	                                                        
        DEFINE VARIABLE lcComment       AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE lcSiganture     AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE lMissingComment AS LOGICAL  NO-UNDO.
        	    
        FOR EACH eMethod ON ERROR UNDO, THROW:
            COPY-LOB eMethod.MethodComment TO lcComment.
            
            THIS-OBJECT:LogMissingParameterComment (lcComment,
                                                    "METHOD":U,
                                                    pcSourceType, 
                                                    pcSourceName,
                                                    REPLACE (ClassDocumentationHelper:ShortSignatureParser(eMethod.Signature, "":U), "  ":U, " ":U),
                                                    eMethod.Modifier,
                                                    eMethod.GUID).
             
            THIS-OBJECT:LogMissingParameter (lcComment,
                                             "METHOD":U,
                                             pcSourceType, 
                                             pcSourceName,
                                             REPLACE (ClassDocumentationHelper:ShortSignatureParser(eMethod.Signature, "":U), "  ":U, " ":U),
                                             eMethod.Modifier,
                                             eMethod.GUID).
            
            THIS-OBJECT:LogMissingReturns (lcComment,
                                           "METHOD":U,
                                           pcSourceType, 
                                           pcSourceName,
                                           REPLACE (ClassDocumentationHelper:ShortSignatureParser(eMethod.Signature, "":U), "  ":U, " ":U),
                                           eMethod.Modifier,
                                           eMethod.ReturnType).
        END. 

	END METHOD.
	
	/*------------------------------------------------------------------------------
        Purpose: Create all missing constructor parameter
        Notes:   
        @param pcSourceType The eUnit Source type
        @param pcSourceName The eUnit source name
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID CreateMissingConstructorParameter (pcSourceType AS CHARACTER,
                                                             pcSourceName AS CHARACTER):
                                                            
        DEFINE VARIABLE lcComment       AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE lcSiganture     AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE lMissingComment AS LOGICAL  NO-UNDO.
                
        FOR EACH eConstructor ON ERROR UNDO, THROW:
            COPY-LOB eConstructor.ConstructorComment TO lcComment.
            
            THIS-OBJECT:LogMissingParameterComment (lcComment,
                                                    "CONSTRUCTOR":U,
                                                    pcSourceType, 
                                                    pcSourceName,
                                                    ClassDocumentationHelper:ShortSignatureParser(eConstructor.Signature, "":U),
                                                    eConstructor.Modifier,
                                                    eConstructor.GUID).
            
            THIS-OBJECT:LogMissingParameter (lcComment,
                                             "CONSTRUCTOR":U,
                                             pcSourceType, 
                                             pcSourceName,
                                             ClassDocumentationHelper:ShortSignatureParser(eConstructor.Signature, "":U),
                                             eConstructor.Modifier,
                                             eConstructor.GUID).
        END. 
        
    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Create all missing event parameter
        Notes:   
        @param pcSourceType The eUnit Source type
        @param pcSourceName The eUnit source name
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID CreateMissingEventParameter (pcSourceType AS CHARACTER,
                                                       pcSourceName AS CHARACTER):
                                                            
        DEFINE VARIABLE lcComment       AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE lcSiganture     AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE lMissingComment AS LOGICAL  NO-UNDO.
                
        FOR EACH eEvent ON ERROR UNDO, THROW:
            COPY-LOB eEvent.EventComment TO lcComment.
            
            
            THIS-OBJECT:LogMissingParameterComment (lcComment,
                                                    "CONSTRUCTOR":U,
                                                    pcSourceType, 
                                                    pcSourceName,
                                                    eEvent.EventName,
                                                    eEvent.Modifier,
                                                    eEvent.GUID).
             
            THIS-OBJECT:LogMissingParameter (lcComment,
                                             "CONSTRUCTOR":U,
                                             pcSourceType, 
                                             pcSourceName,
                                             eEvent.EventName,
                                             eEvent.Modifier,
                                             eEvent.GUID).
        END. 

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Start the parameter validation
        Notes:   This method is invoked by the start procedure 
                 Consultingwerk/Studio/SmartDox/generate-parameter-reference.p
        @param poParameter A Consultingwerk.Studio.SmartDox.IParameterCommentValidatorParameter parameter object
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID CommentValidatorStart (poParameter AS IParameterCommentValidatorParameter):
        DEFINE VARIABLE lok         AS LOGICAL   NO-UNDO.
        DEFINE VARIABLE lcComment   AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE cSourceType AS CHARACTER NO-UNDO.  
        DEFINE VARIABLE cSourceName AS CHARACTER NO-UNDO.

        IF THIS-OBJECT:Verbose THEN 
            MESSAGE "[ParamterCommentValidator] Getting list of files":U .
        
        Consultingwerk.Util.FileHelper:GetFileList (poParameter:SourceDir,
                                                    "*.xml":U,
                                                    OUTPUT TABLE ttFileNames BY-REFERENCE) .
        
        IF THIS-OBJECT:Verbose THEN 
            MESSAGE "[ParamterCommentValidator] Done":U  .
        
        oParser = NEW ClassDocumentationParser () .
        
        FOR EACH ttFileNames ON ERROR UNDO, THROW:
            IF THIS-OBJECT:Verbose THEN 
                MESSAGE "[ParamterCommentValidator]":U ttFileNames.FileName.

            DATASET dsClassDocumentation:EMPTY-DATASET ().
            oParser:ParseClassDocumentation (ttFileNames.FileName,
                                             INPUT-OUTPUT DATASET dsClassDocumentation BY-REFERENCE).

            FIND FIRST eUnit.
            
            IF eUnit.IsInterface = TRUE THEN 
                ASSIGN cSourceType = "INTERFACE":U.
            ELSE 
                ASSIGN cSourceType = "CLASS":U.
            
            ASSIGN cSourceName = SUBSTITUTE ("&1.&2":U, eUnit.PackageName, eUnit.ClassName).
            
            THIS-OBJECT:CreateMissingMethodParameter (cSourceType, cSourceName).
            THIS-OBJECT:CreateMissingConstructorParameter (cSourceType, cSourceName).
            THIS-OBJECT:CreateMissingEventParameter (cSourceType, cSourceName).
        END. 
        
    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns the Temp-Table with the results of the validator 
        Notes:   
        @param ttMissingParameter OUTPUT TABLE The Temp-Table with the results of the validator
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC VOID GetResult (OUTPUT TABLE ttMissingParameter):
		
		/* noop */

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Log all parameters without descriptions 
        Notes:   
        @param plcComment the comment value
        @param pcParameterScope the method scope
        @param pcSourceType the source type (fulltypename)
        @param pcSourceName the source name
        @param pcMethodName the name from th emethod
        @param pcMethodModifier the modiefiere from the method
        @param pcGUID the parent GUID 
    ------------------------------------------------------------------------------*/
	METHOD PROTECTED VOID LogMissingParameterComment (plcComment        AS LONGCHAR,
	                                                  pcParameterScope  AS CHARACTER,
	                                                  pcSourceType      AS CHARACTER,
	                                                  pcSourceName      AS CHARACTER, 
	                                                  pcMethodName      AS CHARACTER,
	                                                  pcMethodModifier  AS CHARACTER,
	                                                  pcGUID            AS CHARACTER):
	                                                  
	    DEFINE VARIABLE iCount           AS INTEGER    NO-UNDO.
	    DEFINE VARIABLE lcLine           AS LONGCHAR   NO-UNDO.
	    DEFINE VARIABLE lcTempLine       AS LONGCHAR   NO-UNDO.
	    DEFINE VARIABLE lMissingComment  AS LOGICAL    NO-UNDO.
	   	
	   	FOR EACH eParameter WHERE eParameter.ParentGUID = pcGUID ON ERROR UNDO, THROW:
	   	    
	   	    ASSIGN lMissingComment = TRUE .
	   	       
            DO iCount = 1 TO NUM-ENTRIES (plcComment, CHR (10)) ON ERROR UNDO, THROW:
                ASSIGN lcLine = TRIM (ENTRY (iCount, plcComment, CHR (10))).
                  
                IF lcLine BEGINS "@param":U THEN DO:
                    ASSIGN lcTempLine = TRIM (SUBSTRING (lcLine, INDEX (lcLine, "@param":U) + 6)).
                    
                    ASSIGN lcTempLine = ENTRY (1, lcTempLine, " ":U).
                    
                    IF lcTempLine = eParameter.Name THEN DO:
                        ASSIGN lMissingComment = ? .
                        LEAVE.
                    END. 
                END.
                
            END.
            
            IF lMissingComment <> ? THEN DO:
                THIS-OBJECT:AddTempTableRow (pcParameterScope,
                                             pcSourceType,
                                             pcSourceName,
                                             pcMethodName,
                                             pcMethodModifier,
                                             eParameter.Name,
                                             lMissingComment,
                                             "":U).
            END.
        END.

	END METHOD .    
    
    /*------------------------------------------------------------------------------
        Purpose: Log all comment lines without parameters 
        Notes:
        @param plcComment the comment value
        @param pcParameterScope the method scope
        @param pcSourceType the source type (fulltypename)
        @param pcSourceName the source name
        @param pcMethodName the name from th emethod
        @param pcMethodModifier the modiefiere from the method
        @param pcGUID the parent GUID 
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID LogMissingParameter (plcComment        AS LONGCHAR,
                                               pcParameterScope  AS CHARACTER,
                                               pcSourceType      AS CHARACTER,
                                               pcSourceName      AS CHARACTER, 
                                               pcMethodName      AS CHARACTER,
                                               pcMethodModifier  AS CHARACTER,
                                               pcGUID            AS CHARACTER):
                                                    
        DEFINE VARIABLE iCount             AS INTEGER    NO-UNDO.
        DEFINE VARIABLE lcLine             AS LONGCHAR   NO-UNDO.
        DEFINE VARIABLE lcTempLine         AS LONGCHAR   NO-UNDO.
        DEFINE VARIABLE lMissingParameter  AS LOGICAL    NO-UNDO.
        DEFINE VARIABLE cTempParameter     AS CHARACTER  NO-UNDO.
        DEFINE VARIABLE cParameter         AS CHARACTER  NO-UNDO.
           
        DO iCount = 1 TO NUM-ENTRIES (plcComment, CHR (10)) ON ERROR UNDO, THROW:
            
            ASSIGN lcLine            = TRIM (ENTRY (iCount, plcComment, CHR (10)))
                   lMissingParameter = FALSE
                   .
                   
            IF lcLine BEGINS "@param":U THEN DO:
                ASSIGN lcTempLine = TRIM (SUBSTRING (lcLine, INDEX (lcLine, "@param":U) + 6)).

                ASSIGN lcTempLine = ENTRY (1, lcTempLine, " ":U).

                FOR EACH eParameter WHERE eParameter.ParentGUID = pcGUID ON ERROR UNDO, THROW:
                    IF lcTempLine = eParameter.Name THEN DO:
                        ASSIGN lMissingParameter = ? .
                        LEAVE.
                    END.
                END.
                
                IF lMissingParameter <> ? THEN DO:
                    THIS-OBJECT:AddTempTableRow (pcParameterScope,
                                                 pcSourceType,
                                                 pcSourceName,
                                                 pcMethodName,
                                                 pcMethodModifier,
                                                 STRING (lcTempLine),
                                                 lMissingParameter,
                                                 STRING (lcLine)).
                END.
            END.
        END.
        
    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Write the TempTable to the xml file 
        Notes:   
        @param pcTargetFile set the output into targetfile
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC VOID ExportToFile (pcTargetFile AS CHARACTER):
		
		TEMP-TABLE ttMissingParameter:WRITE-XML ("FILE":U, pcTargetFile, TRUE).

	END METHOD .    

    /*------------------------------------------------------------------------------
        Purpose: Log all missing returns comments
        Notes:   
        @param plcComment the comment value
        @param pcParameterScope the method scope
        @param pcSourceType the source type (fulltypename)
        @param pcSourceName the source name
        @param pcMethodName the name from th emethod
        @param pcMethodModifier the modiefiere from the method
        @param pcReturnType the returntype from th emethod
    ------------------------------------------------------------------------------*/
	METHOD PROTECTED VOID LogMissingReturns (plcComment        AS LONGCHAR,
                                             pcParameterScope  AS CHARACTER,
                                             pcSourceType      AS CHARACTER,
                                             pcSourceName      AS CHARACTER, 
                                             pcMethodName      AS CHARACTER,
                                             pcMethodModifier  AS CHARACTER,
	                                         pcReturnType      AS CHARACTER):
	                                             
	    DEFINE VARIABLE iCount                      AS INTEGER    NO-UNDO.
	    DEFINE VARIABLE lcLine                      AS LONGCHAR   NO-UNDO.
	    DEFINE VARIABLE lMissingParameter           AS LOGICAL    NO-UNDO INIT ? .
        DEFINE VARIABLE lcTempLine                  AS LONGCHAR   NO-UNDO.
        DEFINE VARIABLE lExistReturnCommentLine     AS LOGICAL    NO-UNDO INIT FALSE.
	    
        DO iCount = 1 TO NUM-ENTRIES (plcComment, CHR (10)) ON ERROR UNDO, THROW:
           ASSIGN lcLine            = TRIM (ENTRY (iCount, plcComment, CHR (10)))
                  .
           
           IF lcLine BEGINS "@return":U THEN DO:
               ASSIGN lExistReturnCommentLine = TRUE. 
               IF pcReturnType = "":U THEN DO:
                    ASSIGN lMissingParameter = FALSE.
                    LEAVE.
               END.
           END.
        END. 		

        IF lMissingParameter <> ? THEN DO:
            /* Sebastian Düngel, Consultingwerk Ltd. 10.04.2013
               Logged all @return commentline, when the mehtod has not an returntype*/
            THIS-OBJECT:AddTempTableRow (pcParameterScope,
                                         pcSourceType,
                                         pcSourceName,
                                         pcMethodName,
                                         pcMethodModifier,
                                         "@RETURN":U,
                                         FALSE,
                                         STRING (lcLine)).
        END.                                  
        ELSE DO:
            /* Sebastian Düngel, Consultingwerk Ltd. 10.04.2013
               Logged all missing Returntypes without description*/
            IF pcReturnType <> "":U AND lExistReturnCommentLine = FALSE THEN DO:
                THIS-OBJECT:AddTempTableRow (pcParameterScope,
                                             pcSourceType,
                                             pcSourceName,
                                             pcMethodName,
                                             pcMethodModifier,
                                             "@RETURN":U,
                                             TRUE,
                                             "":U).
            END. 
        END. 
            
            
	END METHOD .

END CLASS.
