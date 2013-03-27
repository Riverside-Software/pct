/**********************************************************************
 * Copyright 2012 Consultingwerk Ltd.                                 *
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
    File        : ClassDocumentationHelper
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Thu May 10 15:55:13 CEST 2012
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Studio.ClassDocumentation.* FROM PROPATH .

CLASS Consultingwerk.Studio.ClassDocumentation.ClassDocumentationHelper: 

    { Consultingwerk/Studio/ClassDocumentation/eUsing.i &ACCESS=STATIC }
    { Consultingwerk/Studio/ClassDocumentation/eParameterComment.i &ACCESS=STATIC }

    /*------------------------------------------------------------------------------
        Purpose: Disallow instance creation                                                                        
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE ClassDocumentationHelper ():
        SUPER ().
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose:                                                                        
        Notes:                                                                        
        @param pcTypeName The type name to be located
        @param ttUsing TABLE The ttUsing containing the USING Statements of the current compile unit
        @return The full type name                                                                     
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER GetFullTypeName (pcTypeName AS CHARACTER,
                                                    TABLE eUsing):
        
        DEFINE VARIABLE cLookup AS CHARACTER           NO-UNDO .
        DEFINE VARIABLE oClass  AS Progress.Lang.Class NO-UNDO .     
        DEFINE VARIABLE oType   AS System.Type         NO-UNDO .
           
        DO ON ERROR UNDO, THROW: 
            
            IF NUM-ENTRIES (pcTypeName, ".":U) > 1 THEN 
                RETURN pcTypeName . 
                
            FOR EACH eUsing:
                /* propath ? */
                IF eUsing.Type <> "ASSEMBLY":U THEN DO:
             
                    IF ENTRY (NUM-ENTRIES (eUsing.Name, ".":U), eUsing.Name, ".":U) = "*":U THEN DO:
                        ASSIGN cLookup = eUsing.Name
                               ENTRY (NUM-ENTRIES (cLookup, ".":U), cLookup, ".":U) = pcTypeName .                     
                        
                        
                            ASSIGN oClass = Progress.Lang.Class:GetClass (cLookup) NO-ERROR . 
                        
                            
                        IF VALID-OBJECT (oClass) THEN 
                            RETURN cLookup .                     
                    END.
                    ELSE 
                        IF ENTRY (NUM-ENTRIES (eUsing.Name, ".":U), eUsing.Name, ".":U) = pcTypeName THEN 
                            RETURN eUsing.Name .
                END.
    
                /* .NET type */
                IF eUsing.Type <> "PROPATH":U THEN DO:            
                            
                    IF ENTRY (NUM-ENTRIES (eUsing.Name, ".":U), eUsing.Name, ".":U) = "*":U THEN DO:
                        ASSIGN cLookup = eUsing.Name 
                               ENTRY (NUM-ENTRIES (cLookup, ".":U), cLookup, ".":U) = pcTypeName .                     
                        
                        ASSIGN oType = Progress.Util.TypeHelper:GetType (cLookup) NO-ERROR . 
                        
                        IF VALID-OBJECT (oType) THEN 
                            RETURN cLookup .                     
                    END.
                    ELSE 
                        IF ENTRY (NUM-ENTRIES (eUsing.Name, ".":U), eUsing.Name, ".":U) = pcTypeName THEN 
                            RETURN eUsing.Name .
                END.
            END.     
                    
        CATCH ple AS Progress.Lang.Error :
            MESSAGE ple:GetMessage (1)
                VIEW-AS ALERT-BOX.
        END CATCH.
        END.
        /* We should only get here, when we didn't succeed finding an 
           ABL or .NET type */
        RETURN pcTypeName . 

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Return the pupose from the comment. 
        Notes:   
        @param plcComment Comment String 
        @return 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR GetPurpose (plcComment AS LONGCHAR):
        
        DEFINE VARIABLE cResult     AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE iCount      AS INTEGER  NO-UNDO.
        DEFINE VARIABLE lcLine      AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE lTrigger    AS LOGICAL  NO-UNDO INIT FALSE.
                
        DO iCount = 1 TO NUM-ENTRIES (plcComment, CHR (10)) ON ERROR UNDO, THROW:
            
            ASSIGN lcLine = TRIM (ENTRY (iCount, plcComment, CHR (10))).
            
            IF lcLine BEGINS "Purpose:":U THEN DO:
                ASSIGN lTrigger = TRUE
                       cResult  = TRIM (REPLACE (lcLine, "Purpose:":U, "":U))
                       .
            END.
            ELSE  
                IF lTrigger = TRUE AND lcLine BEGINS "Notes:":U THEN 
                    RETURN cResult.
                ELSE 
                    ASSIGN cResult = SUBSTITUTE ("&1&2&3":U, cResult, CHR (10), lcLine).
            
        END.
        
        RETURN "":U.

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Return the ShortModifier
        Notes:   
        @param pcLongModifiere The modifier longname
        @return A shortmodifier
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER GetShortModifier (pcLongModifiere AS CHARACTER):
        
        DEFINE VARIABLE cResult AS CHARACTER NO-UNDO.
        
        CASE pcLongModifiere:
            WHEN "PUBLIC":U THEN 
               ASSIGN cResult = "+":U.
            WHEN "PRIVATE":U THEN 
               ASSIGN cResult = "-":U.
            WHEN "PROTECTED":U THEN 
               ASSIGN cResult = "#":U.
        END. 
    
        RETURN cResult.

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Parse a longchar and replace values.
        Notes:   
        @param pcSignature The CHARCATER value which do you want to parse.
        @param pcModifiere THE CHARACTER value set the modifiere in the signature
        @param pcReturnType THE CHARACTER value set the ReturnTyp in the signature
        @return Return the manipulated signature
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER SignatureParser (pcSignature AS CHARACTER, 
                                                    pcModifiere AS CHARACTER, 
                                                    pcReturnType AS CHARACTER):
        
        DEFINE VARIABLE cResult AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iCount  AS INTEGER   NO-UNDO.
        DEFINE VARIABLE iIndex  AS INTEGER   NO-UNDO.
        
        ASSIGN cResult = REPLACE (pcSignature, "(":U, " (":U)
               cResult = REPLACE (cResult, ",":U, ", ":U)
               iIndex  = INDEX (cResult, ")":U)
               .
        
        IF iIndex > 0 THEN     
            ASSIGN  cResult = SUBSTRING (cResult, 1, iIndex).
       
        ASSIGN cResult = SUBSTITUTE ("&1 &2 &3":U, pcModifiere, pcReturnType, cResult).
               
        RETURN cResult.

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Parse a longchar and replace values.
        Notes:   
        @param pcSignature The CHARCATER value which do you want to parse.
        @param pcReturnType THE CHARACTER value set the ReturnTyp in the signature
        @return Return the manipulated signature
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER ShortSignatureParser (pcSignature AS CHARACTER, 
                                                         pcReturnType AS CHARACTER):
        
        DEFINE VARIABLE cResult AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iCount  AS INTEGER   NO-UNDO.
        DEFINE VARIABLE iIndex  AS INTEGER   NO-UNDO.
        DEFINE VARIABLE iParamStart  AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cParamTemp   AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cParam       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cSingleParam AS CHARACTER NO-UNDO.
        
        ASSIGN cResult = REPLACE (pcSignature, "(":U, " (":U)
               cResult = REPLACE (cResult, ",":U, ", ":U)
               iIndex  = INDEX (cResult, ")":U)
               .
        
        IF iIndex > 0 THEN        
            ASSIGN cResult = SUBSTRING (cResult, 1, iIndex).
               
        ASSIGN cResult = REPLACE (cResult, "INPUT:":U, "":U)
               cResult = REPLACE (cResult, "INPUT-":U, "":U)
               cResult = REPLACE (cResult, "OUTPUT:":U, "":U)
               cResult = REPLACE (cResult, "INPUT-OUTPUT:":U, "":U)
               .

        IF INDEX (cResult, "(":U) > 0 THEN DO: 
            
            ASSIGN iParamStart = INDEX (cResult, "(":U) 
                   cParamTemp  = SUBSTRING (cResult, iParamStart + 1)
                   cParamTemp  = REPLACE (cParamTemp, ")":U, "":U)
                   .
            
            DO iCount = 1 TO NUM-ENTRIES (cParamTemp, ",":U):
              
                ASSIGN cSingleParam = ENTRY (iCount, cParamTemp, ",":U).
                
                IF cParam = "System.Object" THEN          
                    ASSIGN cParam = SUBSTITUTE ("&1, &2":U, cParam, cSingleParam).
                ELSE 
                    ASSIGN cParam = SUBSTITUTE ("&1, &2":U, cParam, ENTRY (NUM-ENTRIES (cSingleParam, "."), cSingleParam, ".")).
                          
            END.
            
            ASSIGN cParam = SUBSTRING (cParam, 2). 
                  
            ASSIGN cResult = SUBSTRING (cResult, 1, iParamStart)
                   cResult = SUBSTITUTE ("&1&2)":U, cResult, TRIM (cParam))
                   .

        END. 
   
        RETURN cResult.

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Parse a longchar and replace values. 
        Notes:   
        @param pcComment A longchar value which formated from the commentparser.
        @return The formated longchar value
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR CommentParser (pcComment AS LONGCHAR, 
                                                 TABLE eParameterComment):
        
        DEFINE VARIABLE cResult     AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cResultTemp AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iCount      AS INTEGER   NO-UNDO.
        DEFINE VARIABLE lcLine      AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE cName       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iIndex      AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cComment    AS LONGCHAR  NO-UNDO.

        EMPTY TEMP-TABLE eParameterComment.
        
        ParamLoop: 
        DO iCount = 1 TO NUM-ENTRIES (pcComment, CHR (10)) ON ERROR UNDO, THROW:

            ASSIGN lcLine = TRIM (ENTRY (iCount, pcComment, CHR (10))).
              
            IF NOT lcLine BEGINS "@param":U AND 
               NOT lcLine BEGINS "@return":U AND
               NOT lcLine BEGINS "/*-":U AND
               NOT lcLine BEGINS "---":U THEN 
             
                ASSIGN cResultTemp = cResultTemp + SUBSTITUTE ("&1&2":U, RIGHT-TRIM (ENTRY (iCount, pcComment, CHR (10))), CHR (10)).
          
            ELSE DO:
                IF lcLine BEGINS "@param":U THEN DO:
        
                    IF NUM-ENTRIES (lcLine, " ":U) > 1 THEN 
                        ASSIGN cName = TRIM (STRING (ENTRY (2, lcLine, " ":U))).
                    ELSE
                        NEXT ParamLoop.  
                  
                    IF Consultingwerk.CharacterType:IsNullOrEmpty (cName) THEN 
                        NEXT ParamLoop.
                      
                    IF CAN-FIND (eParameterComment WHERE eParameterComment.Name = cName) THEN
                        NEXT ParamLoop.
    
                    CREATE eParameterComment.    
                    ASSIGN iIndex                    = INDEX (lcLine, cName)
                           cComment                  = TRIM (SUBSTRING (STRING (lcLine), iIndex + LENGTH (cName)))
                           eParameterComment.Name    = cName
                           eParameterComment.Comment = cComment
                           .
                END.
                ELSE IF lcLine BEGINS "@return":U THEN DO:
                    CREATE eParameterComment.
                    ASSIGN /* Sebastian Düngel, Consultingwerk Ltd. 12.10.2012
                              @RETURN is not a valid identifier */
                           eParameterComment.Name = "RETURN":U
                           iIndex   = INDEX (lcLine, "@return":U)
                           eParameterComment.Comment = TRIM (SUBSTRING (STRING (lcLine), iIndex + LENGTH ("@return":U)))
                               .
                END.
            END.  
        END.
            
        ASSIGN cResult = REPLACE (cResultTemp, CHR (10), "<br>":U).
        
        RETURN cResult.
        
    END METHOD .
    
END CLASS.
