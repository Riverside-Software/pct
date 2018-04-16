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
    File        : ClassDocumentationHelper
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Thu May 10 15:55:13 CEST 2012
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.*                           FROM PROPATH . 
USING Consultingwerk.Studio.ClassDocumentation.* FROM PROPATH .

{Consultingwerk/products.i}

CLASS Consultingwerk.Studio.ClassDocumentation.ClassDocumentationHelper: 

    { Consultingwerk/Studio/ClassDocumentation/eUsing.i &ACCESS=STATIC }
    { Consultingwerk/Studio/ClassDocumentation/eParameterComment.i &ACCESS=STATIC }

    /*------------------------------------------------------------------------------
        Purpose: Gets and sets the procedure handle to the PCT Library procedure
                 that contains the getParameter function 
        Notes:   
    ------------------------------------------------------------------------------*/
	DEFINE PUBLIC STATIC PROPERTY PctLibrary AS HANDLE NO-UNDO 
	GET.
	SET. 

    /*------------------------------------------------------------------------------
        Purpose: Disallow instance creation                                                                        
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE ClassDocumentationHelper ():
        SUPER ().
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Analyse the comment of weblinks and create an link tag
        Notes:   
        @param pcComment The comment string 
        @return A Longchar 
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC LONGCHAR GenerateCommentLinks (pcComment AS LONGCHAR):
	    DEFINE VARIABLE iPos      AS INTEGER   NO-UNDO INIT 1.
	    DEFINE VARIABLE iLinkEnd  AS INTEGER   NO-UNDO.
	    DEFINE VARIABLE cLink     AS CHARACTER NO-UNDO.
	    DEFINE VARIABLE cTagLink  AS CHARACTER NO-UNDO.
	    DEFINE VARIABLE cQuotes   AS CHARACTER NO-UNDO.
	    
	    REPEAT ON ERROR UNDO, THROW:
            ASSIGN iPos = INDEX (pcComment, "http://":U, iPos).
            
            IF iPos = 0 THEN LEAVE.

            ASSIGN iLinkEnd  = INDEX (pcComment, " ":U, iPos) - iPos
                   cQuotes   = SUBSTRING (pcComment, iLinkEnd + iPos - 1, 1)
	               . 
           
            IF cQuotes = "'":U OR cQuotes = '"':U THEN DO:
                iPos = iPos + iLinkEnd.
                NEXT. 
            END. 
            
            IF iLinkEnd <= 0 THEN 
                LEAVE.
           	       
            ASSIGN cLink     = SUBSTRING (pcComment, ipos, iLinkEnd)
                   cTagLink  = SUBSTITUTE ("<a href='&1' target='_blank'>&1</a>":U, cLink)
                   pcComment = SUBSTITUTE ("&1&2&3":U, SUBSTRING (pcComment, 1, iPos - 1), cTagLink, SUBSTRING (pcComment, iPos + iLinkEnd))
                   iPos      = iPos + LENGTH (cTagLink).
                   .

	    END. 
	    
        RETURN pcComment.
	END METHOD .

	/*------------------------------------------------------------------------------
		Purpose: Get the generic type reference list																	  
		Notes:
		@param pcReturnType THE CHARACTER value set the ReturnTyp in the signature
		@param poParameter The parameter object 
		@return a generic type html reference list  																	  
	------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC LONGCHAR GenericTypesParser (pcReturnType AS CHARACTER,
	                                                  poParameter AS IDocumentWriterParameter):
		
		DEFINE VARIABLE iIndex          AS INTEGER  NO-UNDO.
		DEFINE VARIABLE GenericTypeList AS LONGCHAR NO-UNDO.
		DEFINE VARIABLE iEntries        AS INTEGER  NO-UNDO.
		DEFINE VARIABLE iCount          AS INTEGER  NO-UNDO.
		
		FIX-CODEPAGE (GenericTypeList) = "utf-8":U.
		
		ASSIGN iIndex = INDEX (pcReturnType, "<":U) . 

        IF iIndex > 0 THEN DO:
            ASSIGN pcReturnType = SUBSTRING (pcReturnType, iIndex)
                   pcReturnType = TRIM (pcReturnType, "<>":U)
                   iEntries     = NUM-ENTRIES (pcReturnType)
                   .
            
            DO iCount = 1 TO iEntries:
                ASSIGN GenericTypeList = SUBSTITUTE ("&1,":U, 
                                                     GetClassReferenceHyperlink (ENTRY (iCount, pcReturnType), TRUE, poParameter)).
            END. 
            
            ASSIGN GenericTypeList = TRIM (GenericTypeList, ",":U)
                   GenericTypeList =  "&lt":U + GenericTypeList + "&gt":U
                   .
            
        END.

        RETURN GenericTypeList.
	END METHOD.

    /*------------------------------------------------------------------------------
        Purpose:                                                                        
        Notes:                                                                        
        @param pcTypeName The type name to be located
        @param eUsing TABLE The ttUsing containing the USING Statements of the current compile unit
        @return The full type name                                                                     
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER GetFullTypeName (pcTypeName AS CHARACTER,
                                                    TABLE eUsing):
        
        DEFINE VARIABLE cLookup AS CHARACTER           NO-UNDO .
        DEFINE VARIABLE oClass  AS Progress.Lang.Class NO-UNDO .     
&IF DEFINED (DotNetAccessible) NE 0 &THEN
        DEFINE VARIABLE oType   AS System.Type         NO-UNDO .
&ENDIF           
          
        IF Consultingwerk.Util.DataTypeHelper:IsAblDataType (pcTypeName) THEN 
            RETURN pcTypeName .    
         
        DO ON ERROR UNDO, THROW: 
            
            IF NUM-ENTRIES (pcTypeName, ".":U) > 1 THEN 
                RETURN pcTypeName . 
                
            FOR EACH eUsing ON ERROR UNDO, THROW:
                
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
    
&IF DEFINED (DotNetAccessible) NE 0 &THEN    
                /* .NET type */
                IF eUsing.Type <> "PROPATH":U THEN DO:            
                            
                    IF ENTRY (NUM-ENTRIES (eUsing.Name, ".":U), eUsing.Name, ".":U) = "*":U THEN DO:
                        ASSIGN cLookup = eUsing.Name 
                               ENTRY (NUM-ENTRIES (cLookup, ".":U), cLookup, ".":U) = pcTypeName .                     
                        
                        ASSIGN oType = Progress.Util.TypeHelper:GetType (cLookup) . 
                        
                        IF VALID-OBJECT (oType) THEN 
                            RETURN cLookup .                     
                    END.
                    ELSE 
                        IF ENTRY (NUM-ENTRIES (eUsing.Name, ".":U), eUsing.Name, ".":U) = pcTypeName THEN 
                            RETURN eUsing.Name .
                END.
&ENDIF                
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
        Purpose: Generates parent hyperlinks in a html div constainer
        Notes:   
        @param plcClasses The comma seperate parent class list
        @param poParameter The paramter object 
        @return A LONGCHAR with a formated ClassesHyperlinks 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR GenerateParentClassesHyperlinks (plcClasses  AS CHARACTER,
                                                                   poParameter AS IDocumentWriterParameter):
        
        DEFINE VARIABLE iCount         AS INTEGER                                            NO-UNDO.
        DEFINE VARIABLE iEnd           AS INTEGER                                            NO-UNDO.
        DEFINE VARIABLE cReturn        AS LONGCHAR                                           NO-UNDO.
        DEFINE VARIABLE cClassType     AS CHARACTER                                          NO-UNDO.
        DEFINE VARIABLE cClassLink     AS CHARACTER                                          NO-UNDO.
        DEFINE VARIABLE cClass         AS CHARACTER                                          NO-UNDO.
        DEFINE VARIABLE oCharacterList AS Consultingwerk.Framework.Collections.CharacterList NO-UNDO.
        DEFINE VARIABLE iLeftValue     AS INTEGER                                            NO-UNDO.

        FIX-CODEPAGE (cReturn) = "utf-8":U.
        
        ASSIGN oCharacterList = Consultingwerk.Studio.ClassDocumentation.BaseClassListProvider:GetBaseClassList (plcClasses, poParameter:SourceDir) 
               iEnd = oCharacterList:COUNT.
        
        DO iCount = 0 TO oCharacterList:COUNT - 1:
            IF iCount = 0 THEN
                ASSIGN cClassType =  "parentclassnode_first":U.
            ELSE
                ASSIGN cClassType =  "parentclassnode":U.
                            
            IF iCount > 1 THEN 
                ASSIGN iLeftValue = iCount * 2.
            ELSE
                ASSIGN iLeftValue = iCount.
            
            IF iCount > 0 THEN
                ASSIGN
                       cClass     = oCharacterList:GetValue (iEnd - iCount)
                       cClassLink = GetClassReferenceHyperlink (cClass, TRUE, poParameter)
                       cReturn    = cReturn + SUBSTITUTE ("<div style='padding-left:&1em; height:16px' class='parentclassesitem'>
                                                            <table>
                                                                <tr>
                                                                    <td>
                                                                        <div class='&2'></div>
                                                                    </td>
                                                                    <td>
                                                                    &3
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                       </div>":U,
                                                       iLeftValue,
                                                       cClassType,
                                                       cClassLink)
                   .
            ELSE
                ASSIGN
                       cClass     = oCharacterList:GetValue (iEnd - iCount)
                       cClassLink = GetClassReferenceHyperlink (cClass, TRUE, poParameter)
                       cReturn    = cReturn + SUBSTITUTE ("<div style='padding-left:&1em; height:12px' class='parentclassesitem'>
                                                            <table style='border-spacing:0px'>
                                                                <tr>
                                                                    <td>
                                                                    &2
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                       </div>":U,
                                                       iLeftValue,
                                                       cClassLink)
                   .
        END.
        
        /* Sebastian Düngel, Consultingwerk Ltd. 10.04.2013
           Added the caller class*/
        ASSIGN cClassLink = GetClassReferenceHyperlink (plcClasses, TRUE, poParameter)
               cReturn    = cReturn + SUBSTITUTE ("<div style='padding-left:&1em; height:16px' class='parentclassesitem'>
                                                                <table>
                                                                    <tr>
                                                                        <td>
                                                                            <div class='parentclassnode'></div>
                                                                        </td>
                                                                        <td>
                                                                        &2
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                           </div>":U,
                                                           iLeftValue + 2,
                                                           cClassLink)
               .     
        
        ASSIGN cReturn = SUBSTITUTE ("<div class='parentclasses'>&1</div><br>":U, cReturn).

        RETURN cReturn.
    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns a comment for the summary overview. 
        Notes:   
        @param plcComment Comment String 
        @return Get the display summary comment
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR GetSummaryComment (plcComment AS LONGCHAR):
        
        DEFINE VARIABLE oCommentParser AS ICommentBuilder NO-UNDO.
        
        ASSIGN plcComment = ReplaceSpecialCharacters(plcComment).
        
        oCommentParser = {Consultingwerk/get-service.i 
                            Consultingwerk.Studio.ClassDocumentation.ICommentBuilder 
                            "NEW Consultingwerk.Studio.ClassDocumentation.CommentBuilder ()"} .  
        
        IF VALID-OBJECT (oCommentParser) THEN
            RETURN oCommentParser:SummaryComment (plcComment).
        
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
        Purpose: Get the class reference hyperlink 
        Notes:   
        @param cClass The fulltypename from the reference
        @param lWithLink returns the returnvalue with or without link
        @param poParameter The parameter object
        @return A valid HTML a tag 
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC CHARACTER GetClassReferenceHyperlink (cClass      AS CHARACTER, 
	                                                           lWithLink   AS LOGICAL,
	                                                           poParameter AS IDocumentWriterParameter):
	                                                               
        DEFINE VARIABLE oLinkProvider AS IClassReferenceLinkProvider NO-UNDO.
        DEFINE VARIABLE cLink         AS CHARACTER                   NO-UNDO.
        
        oLinkProvider = {Consultingwerk/get-service.i Consultingwerk.Studio.ClassDocumentation.IClassReferenceLinkProvider "NEW Consultingwerk.Studio.ClassDocumentation.ClassReferenceLinkProvider()"} .
        
        ASSIGN cLink = oLinkProvider:GetClassReferenceLink (cClass).
        
        IF NOT lWithLink THEN
            RETURN cClass. 
        
        IF cLink = ? THEN DO:
            ASSIGN FILE-INFO:FILENAME = SUBSTITUTE ("&1\&2.xml":U, poParameter:SourceDir, cClass).
                        
            IF FILE-INFO:FULL-PATHNAME = ? THEN
                RETURN cClass.
            ELSE 
                RETURN SUBSTITUTE ("<a href='&1.html'>&1</a>":U, cClass).
        END.
        ELSE
            RETURN SUBSTITUTE ("<a href='&1' target='_blank'>&2</a>":U, cLink, cClass).
    

	END METHOD .
	
	/*------------------------------------------------------------------------------
        Purpose: Build the Method / Property / Events reference hyperlink 
        Notes:   
        @param cClass The fulltypename from the reference
        @param cMethod The Method / Property / Events signature or name
        @param lWithLink returns the returnvalue with or without link
        @param poParameter The parameter object
        @return A valid HTML a tag 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER GetClassReferenceHyperlink (cClass      AS CHARACTER,
                                                               cMethod     AS CHARACTER,
                                                               lWithLink   AS LOGICAL,
                                                               poParameter AS IDocumentWriterParameter):
                                                                   
        DEFINE VARIABLE oLinkProvider AS IClassReferenceLinkProvider NO-UNDO.
        DEFINE VARIABLE cLink         AS CHARACTER                   NO-UNDO.
        
        oLinkProvider = {Consultingwerk/get-service.i Consultingwerk.Studio.ClassDocumentation.IClassReferenceLinkProvider "NEW Consultingwerk.Studio.ClassDocumentation.ClassReferenceLinkProvider()"} .
        
        ASSIGN cLink = oLinkProvider:GetClassReferenceLink (cClass).
        
        
        
        IF NOT lWithLink THEN
            RETURN cClass.
        
        IF cLink = ? THEN DO:
            ASSIGN FILE-INFO:FILENAME = SUBSTITUTE ("&1\&2.xml":U, poParameter:SourceDir, cClass).
                        
            IF FILE-INFO:FULL-PATHNAME = ? THEN
                RETURN SUBSTITUTE ("&1:&2":U, cClass, cMethod).
            ELSE 
                RETURN SUBSTITUTE ("<a href='&1.html#&2'>&1:&2</a>":U, cClass, cMethod).
        END.
        ELSE
            RETURN SUBSTITUTE ("<a href='&1' target='_blank'>&2</a>":U, cLink, cClass).
    
    END METHOD .

	/*------------------------------------------------------------------------------
		Purpose: Get the purpose comment form the unit   																	  
		Notes:
		@param pcComment A longcharvalue with the purpose comment.
		@return A longchar value																  
	------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC LONGCHAR GetUnitPurpose (pcComment AS LONGCHAR):
		
		DEFINE VARIABLE lcContent AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE oCommentParser AS ICommentBuilder NO-UNDO.
                
        FIX-CODEPAGE (lcContent) = "utf-8":U . 
        
        oCommentParser = {Consultingwerk/get-service.i 
                          Consultingwerk.Studio.ClassDocumentation.ICommentBuilder 
                          "NEW Consultingwerk.Studio.ClassDocumentation.CommentBuilder ()"} . 
        
        IF VALID-OBJECT (oCommentParser) THEN DO:
            ASSIGN lcContent = oCommentParser:GetUnitPurpose (pcComment).
        END.  
        
        RETURN lcContent.
                
	END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Custom Right-Trim Method that does also trim TAB  
        Notes:   
        @param plcString The LONGCHAR value to right-trim 
        @return The right-trimed LONGCHAR value
    ------------------------------------------------------------------------------*/
	METHOD PRIVATE STATIC LONGCHAR RightTrim (plcString AS LONGCHAR):
		
		DEFINE VARIABLE cChar AS CHARACTER NO-UNDO.
		
		REPEAT ON ERROR UNDO, THROW:
		    IF LENGTH (plcString) > 1 THEN . 
		    ELSE LEAVE . 
		    
		    ASSIGN cChar = SUBSTRING (plcString, LENGTH (plcString), 1) .
		    
		    IF cChar = CHR(32) OR cChar = CHR(9) THEN 
		        ASSIGN plcString = SUBSTRING (plcString, 1, LENGTH (plcString) - 1) . 
		    ELSE 
		        LEAVE . 
		END.
		
		RETURN plcString.

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Parse a longchar and replace values.
        Notes:   
        @param pcSignature The CHARACTER value which do you want to parse.
        @param pcModifier The CHARACTER value set the modifiere in the signature
        @param pcReturnType The CHARACTER value set the ReturnTyp in the signature
        @param pcDelegateType The CHARACTER value set the DelegateType
        @param plWithLink generated the the signature with an Anchor Link
        @param plWithReturnLink generate the signature with or without return type link
        @param poParameter The parameter object
        @return Return the manipulated signature
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER SignatureParser (pcSignature  AS CHARACTER, 
                                                    pcModifier  AS CHARACTER, 
                                                    pcReturnType AS CHARACTER,
                                                    pcDelegateType   AS CHARACTER,
                                                    plWithLink       AS LOGICAL,
                                                    plWithReturnLink AS LOGICAL,
                                                    poParameter  AS IDocumentWriterParameter):
        
        DEFINE VARIABLE cResult      AS CHARACTER NO-UNDO .
        DEFINE VARIABLE iIndex       AS INTEGER   NO-UNDO .
        DEFINE VARIABLE cTempReturn  AS CHARACTER NO-UNDO .
        DEFINE VARIABLE cSignature   AS CHARACTER NO-UNDO .
                                                                                
        IF iIndex > 0 THEN
            ASSIGN  cResult = SUBSTRING (cResult, 1, iIndex).

        IF INDEX (pcReturnType, "<":U) > 0 THEN
             ASSIGN cTempReturn = SUBSTRING (pcReturnType, 1 , INDEX (pcReturnType, "<":U))
                    cTempReturn = TRIM (cTempReturn, "<>":U)
                    .
         ELSE
            ASSIGN cTempReturn = pcReturnType.
            
        IF pcDelegateType = "":U THEN DO:
            IF plWithLink = TRUE THEN
                ASSIGN cResult = SUBSTITUTE ("&1 &2 <a href='#@ANCHOR@'>&3 &4</a>":U, pcModifier, GetClassReferenceHyperlink (cTempReturn, plWithReturnLink, poParameter), GenericTypesParser (pcReturnType, poParameter), ShortSignatureParser (pcSignature, pcReturnType)).
            ELSE 
                ASSIGN cResult = SUBSTITUTE ("&1 &2 &3 &4":U, pcModifier, GetClassReferenceHyperlink (cTempReturn, plWithReturnLink, poParameter), GenericTypesParser (pcReturnType, poParameter), ShortSignatureParser (pcSignature, pcReturnType)).
        END.
        ELSE DO:
            ASSIGN cSignature = ShortSignatureParser (pcSignature, pcReturnType)
                   cSignature = TRIM (pcSignature, "()":U)
                   .
                    
            IF plWithLink = TRUE THEN
                ASSIGN cResult = SUBSTITUTE ("&1 &2 <a href='#@ANCHOR@'>&3 &4</a> DELEGATE &5":U, pcModifier, GetClassReferenceHyperlink (cTempReturn, plWithReturnLink, poParameter), GenericTypesParser (pcReturnType, poParameter), cSignature, GetClassReferenceHyperlink (pcDelegateType, plWithReturnLink, poParameter)).
            ELSE 
                ASSIGN cResult = SUBSTITUTE ("&1 &2 &3 &4 DELEGATE &5":U, pcModifier, GetClassReferenceHyperlink (cTempReturn, plWithReturnLink, poParameter), GenericTypesParser (pcReturnType, poParameter), cSignature, GetClassReferenceHyperlink (pcDelegateType, plWithReturnLink, poParameter)). 
        END. 

        RETURN cResult.

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Parse a longchar and replace values.
        Notes:   
        @param pcSignature The CHARCATER value which do you want to parse.
        @param pcReturnType THE CHARACTER value set the ReturnTyp in the signature
        @return Return the manipulated signature
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER ShortSignatureParser (pcSignature  AS CHARACTER, 
                                                         pcReturnType AS CHARACTER):
        
        DEFINE VARIABLE cResult      AS CHARACTER NO-UNDO .
        DEFINE VARIABLE iCount       AS INTEGER   NO-UNDO .
        DEFINE VARIABLE iIndex       AS INTEGER   NO-UNDO .
        DEFINE VARIABLE iParamStart  AS INTEGER   NO-UNDO .
        DEFINE VARIABLE cParamTemp   AS CHARACTER NO-UNDO .
        DEFINE VARIABLE cParam       AS CHARACTER NO-UNDO .
        DEFINE VARIABLE cSingleParam AS CHARACTER NO-UNDO .
        DEFINE VARIABLE cTypes       AS CHARACTER NO-UNDO .
        DEFINE VARIABLE cType        AS CHARACTER NO-UNDO .
        DEFINE VARIABLE cParameter   AS CHARACTER NO-UNDO .
        DEFINE VARIABLE i            AS INTEGER   NO-UNDO .

        ASSIGN iIndex = INDEX (pcSignature, "(":U) . 

        IF iIndex > 0 THEN DO:
            
            ASSIGN cTypes     = Consultingwerk.Const:ABL_DATA_TYPES + ",DATASET,TABLE":U
                   cParameter = SUBSTRING (pcSignature, iIndex) .
            
            DO i = 1 TO NUM-ENTRIES (cTypes):
                ASSIGN cType = ENTRY (i, cTypes) .
                
                IF INDEX (cParameter, cType) = 0 THEN     
                    ASSIGN cParameter = REPLACE (REPLACE (cParameter, 
                                                          ":":U + ENTRY (i, cTypes) + ",":U,
                                                          ":":U + ENTRY (i, cTypes) + ",":U), 
                                                 ":":U + ENTRY (i, cTypes) + ")":U,
                                                 ":":U + ENTRY (i, cTypes) + ")":U).
            END . 
            
            ASSIGN SUBSTRING (pcSignature, iIndex) = cParameter . 

        END.        
        
        ASSIGN cResult = REPLACE (REPLACE (pcSignature, "(":U, " (":U), 
                                  ",":U, 
                                  ", ":U)
               iIndex  = INDEX (cResult, ")":U)
               .
        
        IF iIndex > 0 THEN        
            ASSIGN cResult = SUBSTRING (cResult, 1, iIndex).
               
        ASSIGN cResult = REPLACE (REPLACE (REPLACE (REPLACE (cResult, 
                                                             "INPUT:":U, 
                                                             "":U), 
                                                    "INPUT-":U, 
                                                    "":U), 
                                           "OUTPUT:":U, 
                                           "":U), 
                                 "INPUT-OUTPUT:":U, 
                                 "":U) .

        IF INDEX (cResult, "(":U) > 0 THEN DO: 
            
            ASSIGN iParamStart = INDEX (cResult, "(":U) 
                   cParamTemp  = REPLACE (SUBSTRING (cResult, iParamStart + 1), 
                                          ")":U, 
                                          "":U)
                   .
            
            DO iCount = 1 TO NUM-ENTRIES (cParamTemp, ",":U):
              
                ASSIGN cSingleParam = ENTRY (iCount, cParamTemp, ",":U).
                
                IF cParam = "System.Object":U THEN          
                    ASSIGN cParam = SUBSTITUTE ("&1, &2":U, TRIM (cParam), TRIM (cSingleParam)).
                ELSE 
                    /* Mike Fechner, Consultingwerk Ltd. 06.02.2013
                       SMARTDOX-49: Nesting ENTRY in SUBSTITUTE may fail on 10.2B 
                       http://knowledgebase.progress.com/articles/Article/P138807
                       http://knowledgebase.progress.com/articles/Article/000035493 */
                    ASSIGN cParam = SUBSTITUTE ("&1, &2":U, 
                                                TRIM(cParam), 
                                                TRIM (ENTRY (NUM-ENTRIES (cSingleParam, ".":U), 
                                                             cSingleParam, 
                                                             ".":U))).
            END.
            
            ASSIGN cParam = SUBSTRING (cParam, 2). 
            
            ASSIGN cResult = SUBSTRING (cResult, 1, iParamStart) + TRIM (cParam) + ")":U . 
        END. 
        
        RETURN cResult.

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Format the comment. 
        Notes:   
        @param pcComment A longchar value which formated from the GetFormateComment.
        @return The formated longchar value
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR CommentFormater (pcComment AS LONGCHAR):
        
        DEFINE VARIABLE lcContent AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE oCommentParser AS ICommentBuilder NO-UNDO.
                
        FIX-CODEPAGE (lcContent) = "utf-8":U . 
        
        oCommentParser = {Consultingwerk/get-service.i 
                          Consultingwerk.Studio.ClassDocumentation.ICommentBuilder 
                          "NEW Consultingwerk.Studio.ClassDocumentation.CommentBuilder ()"} . 
        
        IF VALID-OBJECT (oCommentParser) THEN DO:
            ASSIGN lcContent = oCommentParser:CommentFormater (pcComment).
        END.
        
        ASSIGN lcContent = GenerateCommentLinks (lcContent).  
        
        RETURN lcContent.             
            
    END.
    
    /*------------------------------------------------------------------------------
        Purpose: Format the Unit comment. 
        Notes:   
        @param pcComment A longchar value which formated from the GetFormateComment.
        @return The formated longchar value
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR UnitCommentFormater (pcComment AS LONGCHAR):
        
        DEFINE VARIABLE lcContent AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE oCommentParser AS ICommentBuilder NO-UNDO.
                
        FIX-CODEPAGE (lcContent) = "utf-8":U . 
        
        oCommentParser = {Consultingwerk/get-service.i 
                          Consultingwerk.Studio.ClassDocumentation.ICommentBuilder 
                          "NEW Consultingwerk.Studio.ClassDocumentation.CommentBuilder ()"} . 
        
        IF VALID-OBJECT (oCommentParser) THEN DO:
            ASSIGN lcContent = oCommentParser:UnitCommentFormater (pcComment).
        END.
        
        ASSIGN lcContent = GenerateCommentLinks (lcContent).  
        
        RETURN lcContent.
    END.
    
     /*------------------------------------------------------------------------------
        Purpose: Removes all special characters by replacing them with proper XML markup
        Notes:   
        @param plcString A longchar value in which to remove/replaced special characters
        @return The longchar without the removed/replaced special characters
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR ReplaceSpecialCharacters (plcString AS LONGCHAR):
        
        DEFINE VARIABLE cString AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE iLength AS INTEGER NO-UNDO.
        DEFINE VARIABLE i       AS INTEGER NO-UNDO INIT 1.
        DEFINE VARIABLE iValue  AS INTEGER NO-UNDO.
        DEFINE VARIABLE cChar   AS CHARACTER NO-UNDO CASE-SENSITIVE.
        
        FIX-CODEPAGE (cString) = "utf-8":U . 
        
        ASSIGN cString = plcString.
        
        DO WHILE i < LENGTH (plcString):
            
            i = i + 1 .

            ASSIGN cChar  = STRING (SUBSTRING (cString, i, 1))
                   iValue = ASC (cChar, "UTF-16":U) .  
            
            IF iValue > 128 THEN 
                cString = REPLACE (cString, cChar, SUBSTITUTE ("&&#&1;":U, iValue)) .
        END.
        
        ASSIGN cString = REPLACE (cString, "<":U, "&lt;":U)
               cString = REPLACE (cString, ">":U, "&gt;":U) .
        
        RETURN cString.
        
    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Build the comment. 
        Notes:   
        @param pcComment A longchar value which formated from the commentparser.
        @param eParameterComment The Temptable with the generated Input and return paramters.
        @return The formated longchar value
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR CommentParser (pcComment AS LONGCHAR, 
                                                 TABLE eParameterComment):
        
        DEFINE VARIABLE lcResult       AS LONGCHAR        NO-UNDO.
        DEFINE VARIABLE oCommentParser AS ICommentBuilder NO-UNDO.
        
        FIX-CODEPAGE (lcResult) = "utf-8":U . 

        EMPTY TEMP-TABLE eParameterComment.

        ASSIGN pcComment = ReplaceSpecialCharacters (pcComment).
        
        oCommentParser = {Consultingwerk/get-service.i 
                            Consultingwerk.Studio.ClassDocumentation.ICommentBuilder 
                            "NEW Consultingwerk.Studio.ClassDocumentation.CommentBuilder ()"} .  
        
        IF VALID-OBJECT (oCommentParser) THEN DO:
            oCommentParser:FillDetailParameterTemptable (pcComment, TABLE eParameterComment BY-REFERENCE).
            ASSIGN lcResult = oCommentParser:ParseComment (pcComment).
        END.
        
        RETURN lcResult.
        
    END METHOD .
    
END CLASS.
