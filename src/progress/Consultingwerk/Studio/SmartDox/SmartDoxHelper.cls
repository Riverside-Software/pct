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
    File        : SmartDoxHelper
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Sebastian Düngel / Consultingwerk Ltd.
    Created     : Mon Oct 15 07:15:41 CEST 2012
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Studio.ClassDocumentation.* FROM PROPATH .
USING Consultingwerk.Studio.SmartDox.*           FROM PROPATH .  
USING Progress.Lang.*                            FROM PROPATH .

CLASS Consultingwerk.Studio.SmartDox.SmartDoxHelper:

    { Consultingwerk/Studio/ClassDocumentation/eParameterComment.i &ACCESS=STATIC }
    { Consultingwerk/Studio/ClassDocumentation/eUsing.i &ACCESS=STATIC }

    /*------------------------------------------------------------------------------
        Purpose: Disallow instance creation                                                                       
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE SmartDoxHelper ():
        SUPER ().
        
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
        Purpose: Generate and formated the paramter comments 
        Notes:   
        @param eParameterComment The parameter Temp-Table
        @return The formated longchar values
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR GenerateParameterComments (TABLE eParameterComment):
        
        DEFINE VARIABLE cReturn   AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE lcComment AS LONGCHAR NO-UNDO.
        
        IF AVAILABLE (eParameterComment) THEN DO:
            
            COPY-LOB eParameterComment.Comment TO lcComment.
        
            FOR EACH eParameterComment:
                
                ASSIGN cReturn = cReturn + SUBSTITUTE ("<p><b>&1: </b>&2</p>&3":U, eParameterComment.Name, lcComment, CHR (10)).
            
            END.
            
        END.
        
        RETURN cReturn.
        
    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Remove all not usability comment lines.
        Notes:
        @param pcComment A longchar value which formated from the RemoveCommentLines
        @return The formated longchar value
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR RemoveCommentLines (pcComment AS LONGCHAR):
        
        DEFINE VARIABLE iCount      AS INTEGER   NO-UNDO.
        DEFINE VARIABLE lcLine      AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE cResultTemp AS CHARACTER NO-UNDO.

        DO iCount = 1 TO NUM-ENTRIES (pcComment, CHR (10)) ON ERROR UNDO, THROW:
            
            ASSIGN lcLine = TRIM (ENTRY (iCount, pcComment, CHR (10))).

            IF NOT lcLine BEGINS "*":U AND
               NOT lcLine BEGINS "/**":U AND
               NOT lcLine BEGINS "---":U AND
               NOT lcLine BEGINS "/*-":U AND
               NOT lcLine BEGINS "@return":U AND
               NOT lcLine BEGINS "@param":U THEN DO:
                cResultTemp = cResultTemp + SUBSTITUTE ("&1&2":U, RIGHT-TRIM (ENTRY (iCount, pcComment, CHR (10))), CHR (10)).
            END.
            
            IF lcLine BEGINS "---":U THEN 
                RETURN cResultTemp.
            
        END.
        RETURN cResultTemp.
        
    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Replace all space characters with &nbsp;
        Notes:   
        @param plcString A longchar value which replace all space characters
        @return The formated string value with the replaced space character
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC LONGCHAR ReplaceBlank (plcString AS LONGCHAR):
	    
		DEFINE VARIABLE cResult AS LONGCHAR NO-UNDO.
        
		ASSIGN cResult = REPLACE (plcString, " ":U, "&nbsp;":U).
		
		RETURN cResult .

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Parse a longchar and replace values. 
        Notes:   
        @param pcSignature A longchar value which formated from the commentparser.
        @param eUsing The Using TempTable.
        @return The formated longchar value
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR SignatureParser (pcSignature AS LONGCHAR, 
                                                   TABLE eUsing):
        
        DEFINE VARIABLE cResult      AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iCount       AS INTEGER   NO-UNDO.
        DEFINE VARIABLE iIndex       AS INTEGER   NO-UNDO.
        DEFINE VARIABLE iParamStart  AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cParamTemp   AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cParam       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cSingleParam AS CHARACTER NO-UNDO.
        
        ASSIGN iIndex  = INDEX (pcSignature, ")":U)
               cResult = SUBSTRING (pcSignature, 1, iIndex)
               cResult = REPLACE (cResult, "INPUT:":U, "":U)
               cResult = REPLACE (cResult, "OUTPUT:":U, "":U)
               cResult = REPLACE (cResult, "INPUT-OUTPUT:":U, "":U)
               cResult = REPLACE (cResult, "()":U, "":U)
               .   

        IF INDEX (cResult, "(":U) > 0 THEN DO: 
            
            ASSIGN iParamStart = INDEX (cResult, "(":U) 
                   cParamTemp  = SUBSTRING (cResult, iParamStart + 1)
                   cParamTemp  = REPLACE (cParamTemp, ")":U, "":U)
                   .
            
            DO iCount = 1 TO NUM-ENTRIES (cParamTemp, ",":U):
              
                ASSIGN cSingleParam = ENTRY (iCount, cParamTemp, ",":U).
                
                /* Sebastian Düngel, Consultingwerk Ltd. 19.10.2012
                   Exception: The normaly handle datatype is in classbrowser a widget-handle datatype. */
                IF cSingleParam = "handle":U THEN 
                    ASSIGN cSingleParam = "widget-handle":U.
                          
                ASSIGN cParam = SUBSTITUTE ("&1,&2":U, cParam, ClassDocumentationHelper:GetFullTypeName (cSingleParam, TABLE eUsing)).
                          
            END.
            
            ASSIGN cParam = SUBSTRING (cParam, 2). 
                  
            ASSIGN cResult = SUBSTRING (cResult, 1, iParamStart)
                   cResult = SUBSTITUTE ("&1&2)":U, cResult, cParam)
                   .
        END. 
        
        RETURN cResult.

    END METHOD .
   
END CLASS.
