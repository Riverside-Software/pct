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
    File        : DocumentationWriter
    Purpose     : Generate a html documentation from xml-files. 
    Syntax      : 
    Description : 
    Author(s)   : Sebastian Düngel / Consultingwerk Ltd.
    Created     : Wed Oct 10 17:11:42 CEST 2012
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i}

USING Consultingwerk.*                           FROM PROPATH . 
USING Consultingwerk.Studio.ClassDocumentation.* FROM PROPATH .
USING Consultingwerk.Studio.SmartDox.*           FROM PROPATH .
USING Consultingwerk.Util.*                      FROM PROPATH .   
USING Progress.Lang.*                            FROM PROPATH .

CLASS Consultingwerk.Studio.ClassDocumentation.DocumentationWriter
    USE-WIDGET-POOL:

    { Consultingwerk/Studio/ClassDocumentation/dsClassDocumentation.i }
    { Consultingwerk/Studio/ClassDocumentation/eParameterComment.i }
    { Consultingwerk/Util/TempTables/ttFileNames.i }
    { Consultingwerk/Studio/ClassDocumentation/eTreeNode.i }

    DEFINE VARIABLE oParser AS ClassDocumentationParser NO-UNDO .
    DEFINE VARIABLE iAnchor AS INTEGER                  NO-UNDO .  
    
	/*------------------------------------------------------------------------------
		Purpose: Added the base class comments 																	  
		Notes:
	    @param TableName the table name from the class dopcumentation ds
		@param hDsBaseClass The baseclass dataset
		@param pcClassName The caller classname
		@param poParameter The global parameter object  																	  
	------------------------------------------------------------------------------*/
	METHOD PUBLIC VOID AddBaseClassCommentToClass (TableName      AS CHARACTER, 
	                                               hDsBaseClass   AS HANDLE, 
	                                               pcClassName    AS CHARACTER,
	                                               poParameter    AS IDocumentWriterParameter):   
		
		DEFINE VARIABLE hSourceBuffer              AS HANDLE    NO-UNDO.
		DEFINE VARIABLE hQuery                     AS HANDLE    NO-UNDO. 
		DEFINE VARIABLE hDestBuffer                AS HANDLE    NO-UNDO.
		DEFINE VARIABLE cFindToken                 AS CHARACTER NO-UNDO.
		DEFINE VARIABLE hParameterSourceBuffer     AS HANDLE    NO-UNDO. 
		DEFINE VARIABLE hParameterDestBuffer       AS HANDLE    NO-UNDO.
		DEFINE VARIABLE hParamQuery                AS HANDLE    NO-UNDO.
		DEFINE VARIABLE hDestQuery                 AS HANDLE    NO-UNDO.
		DEFINE VARIABLE cDestSignature             AS CHARACTER NO-UNDO.
		DEFINE VARIABLE cSrcSignature              AS CHARACTER NO-UNDO.
		DEFINE VARIABLE lAddProcedure              AS LOGICAL   NO-UNDO.
		DEFINE VARIABLE cShortClass                AS CHARACTER NO-UNDO.
		
		ASSIGN hSourceBuffer          = hDsBaseClass:GET-BUFFER-HANDLE (TableName)
		       hDestBuffer            = DATASET dsClassDocumentation:GET-BUFFER-HANDLE (TableName)
               hParameterSourceBuffer = hDsBaseClass:GET-BUFFER-HANDLE ("eParameter":U)
               hParameterDestBuffer   = DATASET dsClassDocumentation:GET-BUFFER-HANDLE ("eParameter":U)
		       cShortClass            = ENTRY (NUM-ENTRIES (pcClassName, ".":U), pcClassName, ".":U)
		       .
		
		/* Sebastian Düngel, Consultingwerk Ltd. 14.05.2013
           Fill base class parameter temptable*/
		CREATE QUERY hParamQuery.
        hParamQuery:SET-BUFFERS (hParameterSourceBuffer).
        hParamQuery:QUERY-PREPARE ("FOR EACH eParameter":U).
        hParamQuery:QUERY-OPEN ().
        
        hParamQuery:GET-FIRST (NO-LOCK) NO-ERROR.
        
        DO WHILE NOT hParamQuery:QUERY-OFF-END:

            hParameterDestBuffer:FIND-FIRST (SUBSTITUTE ("WHERE eParameter.GUID = '&1'":U, hParameterSourceBuffer::GUID)) NO-ERROR.
            
            IF NOT hParameterDestBuffer:AVAILABLE THEN DO:
                hParameterDestBuffer:BUFFER-CREATE ().
                hParameterDestBuffer:BUFFER-COPY (hParameterSourceBuffer).
            END. 
            
            hParamQuery:GET-NEXT (NO-LOCK).
        END.
		
		CREATE QUERY hQuery.
        hQuery:SET-BUFFERS (hSourceBuffer).
        hQuery:QUERY-PREPARE (SUBSTITUTE ("FOR EACH &1 WHERE &1.Modifier = 'Protected' OR &1.Modifier = 'Public'":U, TableName)).
        hQuery:QUERY-OPEN ().
        
        hQuery:GET-FIRST () NO-ERROR.
         
        DO WHILE NOT hQuery:QUERY-OFF-END:
            
            IF TableName <> "eProperty":U THEN DO ON ERROR UNDO, THROW: 
                               
                /* Sebastian Düngel, Consultingwerk Ltd. 15.05.2013
                   Normalizing the signature */
                CREATE QUERY hDestQuery.
                hDestQuery:SET-BUFFERS (hDestbuffer).
                hDestQuery:QUERY-PREPARE (SUBSTITUTE ("FOR EACH &1":U, TableName)).
                hDestQuery:QUERY-OPEN ().
                
                hDestQuery:GET-FIRST () NO-ERROR.
                
                ASSIGN lAddProcedure = TRUE.
                
                IF TableName = "eMethod":U THEN
                    ASSIGN cSrcSignature = ClassDocumentationHelper:SignatureParser (hSourceBuffer::Signature, hSourceBuffer::Modifier, hSourceBuffer::Returntype, poParameter).
                ELSE 
                    ASSIGN cSrcSignature = ClassDocumentationHelper:SignatureParser (hSourceBuffer::Signature, hSourceBuffer::Modifier, "":U, poParameter).
                
                DO WHILE NOT hDestQuery:QUERY-OFF-END:
                    
                    IF TableName = "eMethod":U THEN 
                        ASSIGN cDestSignature = ClassDocumentationHelper:SignatureParser (hDestBuffer::Signature, hDestBuffer::Modifier, hDestBuffer::Returntype, poParameter).
                    ELSE 
                        ASSIGN cDestSignature = ClassDocumentationHelper:SignatureParser (hDestBuffer::Signature, hDestBuffer::Modifier, "":U, poParameter).

                    IF cDestSignature = cSrcSignature THEN DO:
                        ASSIGN lAddProcedure = FALSE.
                        LEAVE.
                    END. 
                                        
                    hDestQuery:GET-NEXT (NO-LOCK).
                
                END. 
                
                IF lAddProcedure = FALSE THEN DO:
                    hDestbuffer::Inheritance = SUBSTITUTE ("Overrides &1":U, ClassDocumentationHelper:GetClassReferenceHyperlink (pcClassName,
                                                                                                                                 ClassDocumentationHelper:ShortSignatureParser (hDestbuffer::Signature, hDestbuffer::ReturnType), 
                                                                                                                                 poParameter)).
                END. 
                ELSE DO:
                    hDestBuffer:BUFFER-CREATE ().
                    hDestBuffer:BUFFER-COPY (hSourceBuffer).
                    hDestbuffer::Inheritance = SUBSTITUTE ("Inherited from &1":U, ClassDocumentationHelper:GetClassReferenceHyperlink (pcClassName, poParameter)).
                END. 

                FINALLY:
                    GarbageCollectorHelper:DeleteObject (hDestQuery) .		
                END FINALLY.
            END.
            ELSE DO:
            
                hDestbuffer:FIND-FIRST (SUBSTITUTE ("WHERE &1.name = '&2'":U, TableName, hSourceBuffer::Name)) NO-ERROR. 
            
                IF hDestbuffer:AVAILABLE THEN DO:              
                   hDestbuffer::Inheritance = SUBSTITUTE ("Overrides &1":U, ClassDocumentationHelper:GetClassReferenceHyperlink (pcClassName,
                                                                                                                                ClassDocumentationHelper:ShortSignatureParser (hDestbuffer::Name, hDestbuffer::DataType), 
                                                                                                                                poParameter)).
                END.
                ELSE DO:
                    hDestBuffer:BUFFER-CREATE ().
                    hDestBuffer:BUFFER-COPY (hSourceBuffer).
                    hDestbuffer::Inheritance = SUBSTITUTE ("Inherited from &1":U, ClassDocumentationHelper:GetClassReferenceHyperlink (pcClassName, poParameter)).
                END.
                
            END.
            
            
            
            hQuery:GET-NEXT (NO-LOCK).
        END.
		
		FINALLY:
            GarbageCollectorHelper:DeleteObject (hQuery) .
            GarbageCollectorHelper:DeleteObject (hParamQuery) . 		
        END FINALLY.
		
	END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Create a html file for the link overview. 
        Notes:   
        @param poParameter The paramter object contains the targetdir parameter.
        @param lcDocumentListContent The value contains the Links which generated into the html file.  
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID CreateDocumentList (poParameter AS IDocumentWriterParameter,
                                              lcDocumentListContent AS LONGCHAR):
        
        DEFINE VARIABLE lcDocumentListTemplate AS LONGCHAR NO-UNDO.
        
        FIX-CODEPAGE (lcDocumentListTemplate) = "utf-8":U . 
        
        COPY-LOB FILE SUBSTITUTE (poParameter:TemplateSourceDir + 
                                  "/DocumentList.template":U) TO lcDocumentListTemplate.
         
        ASSIGN lcDocumentListTemplate = REPLACE (lcDocumentListTemplate, "@PAGETITLE@":U, poParameter:DocumentationTitle)
               lcDocumentListTemplate = REPLACE (lcDocumentListTemplate, "@CONTENT@":U, lcDocumentListContent)
               lcDocumentListTemplate = REPLACE (lcDocumentListTemplate, "@TIMESTAMP@":U, STRING (NOW, "99.99.9999 hh:mm:ss":U))
               .
        
        COPY-LOB lcDocumentListTemplate TO FILE SUBSTITUTE ("&1/DocumentList.html":U, poParameter:TargetDir).

    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Copies the resource files to html output directory. 
        Notes:
        @param poParameter With the parameter object.   
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID CopyResources (poParameter AS IDocumentWriterParameter):
        
        DEFINE VARIABLE pcTargetDir AS CHARACTER NO-UNDO.
        
        IF poParameter:ResourceDir > "":U THEN DO:
            ASSIGN pcTargetDir = SUBSTITUTE ("&1/resources":U, poParameter:TargetDir).
        
            Consultingwerk.Util.FileHelper:CreateDirectory (pcTargetDir).       
            Consultingwerk.Util.FileHelper:CopyFiles (poParameter:ResourceDir, "*.*":U, pcTargetDir).
        END.
        
    END METHOD .

	/*------------------------------------------------------------------------------
		Purpose: Start the baseclass enrichment  																	  
		Notes:
		@param pcFilename The xml xml-classname
		@param pcBaseClass the bace class name
		@param poParameter the global parameter object  																	  
	------------------------------------------------------------------------------*/
	METHOD PUBLIC VOID EnrichDocumentationFromBaseClass (pcFilename  AS CHARACTER,
	                                                     pcBaseClass AS CHARACTE,
	                                                     poParameter AS IDocumentWriterParameter):
		
		DEFINE VARIABLE hDsBaseClass AS HANDLE NO-UNDO.
		
		CREATE DATASET hDsBaseClass.
		hDsBaseClass:CREATE-LIKE (DATASET dsClassDocumentation:HANDLE).
		
		IF NOT VALID-OBJECT (oParser) THEN  
		    oParser = NEW ClassDocumentationParser ().
		
		oParser:ParseClassDocumentation (pcFilename,
                                         INPUT-OUTPUT DATASET-HANDLE hDsBaseClass BY-REFERENCE).
        
        THIS-OBJECT:AddBaseClassCommentToClass ("eMethod":U, hDsBaseClass, pcBaseClass, poParameter).
        THIS-OBJECT:AddBaseClassCommentToClass ("eEvent":U, hDsBaseClass, pcBaseClass, poParameter).
        THIS-OBJECT:AddBaseClassCommentToClass ("eProperty":U, hDsBaseClass, pcBaseClass, poParameter).
		
		RETURN.
        
        FINALLY:
            GarbageCollectorHelper:DeleteObject (hDsBaseClass).
        END FINALLY.
        
	END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Start method to generate the documentation
        Notes:   This method is invoked by the start procedure 
                 Consultingwerk/Studio/ClassDocumentation/generate-class-reference.p
        @param poParameter The parameter object control the output.
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID GenerateDocumentation (poParameter AS IDocumentWriterParameter):
        
        DEFINE VARIABLE lcDocumentListContent      AS LONGCHAR                                           NO-UNDO.
        DEFINE VARIABLE lcDocumentContent          AS LONGCHAR                                           NO-UNDO.
        DEFINE VARIABLE lcDocumentTemplate         AS LONGCHAR                                           NO-UNDO.
        DEFINE VARIABLE lcDocumentDetailsTemplate  AS LONGCHAR                                           NO-UNDO.
        DEFINE VARIABLE cTargetFile                AS CHARACTER                                          NO-UNDO.
        DEFINE VARIABLE cFileName                  AS CHARACTER                                          NO-UNDO.
        DEFINE VARIABLE cCurrentFile               AS CHARACTER                                          NO-UNDO.
        DEFINE VARIABLE oCharacterList             AS Consultingwerk.Framework.Collections.CharacterList NO-UNDO.
        DEFINE VARIABLE iCount                     AS INTEGER                                            NO-UNDO.
        DEFINE VARIABLE iEnd                       AS INTEGER                                            NO-UNDO.
        DEFINE VARIABLE cBaseClass                 AS CHARACTER                                          NO-UNDO.
        DEFINE VARIABLE cFullClassName             AS CHARACTER                                          NO-UNDO.  
        
        DEFINE BUFFER bFileNames FOR ttFileNames.
        
        FIX-CODEPAGE (lcDocumentListContent) = "utf-8":U . 
        FIX-CODEPAGE (lcDocumentContent) = "utf-8":U . 
        FIX-CODEPAGE (lcDocumentTemplate) = "utf-8":U . 
        FIX-CODEPAGE (lcDocumentDetailsTemplate) = "utf-8":U . 
        
        Consultingwerk.Util.FileHelper:CreateDirectory (poParameter:TargetDir).       
        
        Consultingwerk.Util.FileHelper:GetFileList (poParameter:TargetDir,
                                                    "*.html":U,
                                                    OUTPUT TABLE ttFileNames BY-REFERENCE).

        FOR EACH ttFileNames ON ERROR UNDO, THROW:
            OS-DELETE VALUE (ttFileNames.FileName).                                 
        END.                                          
        
        EMPTY TEMP-TABLE ttFileNames.

        THIS-OBJECT:CopyResources (poParameter).
                
        Consultingwerk.Util.FileHelper:GetFileList (poParameter:SourceDir,
                                                    "*.xml":U,
                                                    OUTPUT TABLE ttFileNames BY-REFERENCE) .

        oParser = NEW ClassDocumentationParser () .
        
        FOR EACH ttFileNames ON ERROR UNDO, THROW:
            ASSIGN cCurrentFile = ttFileNames.FileName . 
            
            DATASET dsClassDocumentation:EMPTY-DATASET ().

            oParser:ParseClassDocumentation (ttFileNames.FileName,
                                             INPUT-OUTPUT DATASET dsClassDocumentation BY-REFERENCE) .

            FIND FIRST eUnit NO-LOCK .
            
            /* Mike Fechner, Consultingwerk Ltd. 24.03.2013
               In the ABL, every class inherits from Progress.Lang.Object
               unless specified otherwise */
            IF eUnit.ClassName <> "Progress.Lang.Object":U AND 
               eUnit.Inherits = "":U THEN 
                ASSIGN eUnit.Inherits = "Progress.Lang.Object":U .                
            
            ASSIGN cFullClassName = TRIM (SUBSTITUTE ("&1.&2":U, eUnit.PackageName, eUnit.ClassName))
                   oCharacterList = Consultingwerk.Studio.ClassDocumentation.BaseClassListProvider:GetBaseClassList (cFullClassName, poParameter:SourceDir) 
                   iEnd           = oCharacterList:COUNT
                   .
            /* Sebastian Düngel, Consultingwerk Ltd. 15.05.2013
               Load all base classes of the class */   
            DO iCount = 0 TO oCharacterList:COUNT - 1:

                ASSIGN cBaseClass = oCharacterList:GetValue (iEnd - iCount).
                
                FIND FIRST bFileNames WHERE bFileNames.FileName = SUBSTITUTE ("&1\&2.xml":U, poParameter:SourceDir, cBaseClass) NO-ERROR.
                
                IF AVAILABLE bFileNames THEN DO:
                    THIS-OBJECT:EnrichDocumentationFromBaseClass (bFileNames.FileName, cBaseClass, poParameter).
                END.    
            END. 
            ASSIGN cFileName         = REPLACE (ttFileNames.FileName, "~\":U, "/":U)
                   cFileName         = ENTRY (NUM-ENTRIES (cFileName, "/":U), cFileName, "/":U)
                   cFileName         = SUBSTRING (cFileName, 1, LENGTH (cFileName) - 4)
                   cTargetFile       = SUBSTITUTE ("&2.html":U, poParameter:TargetDir, cFileName)
                   lcDocumentContent = "":U
                   .
            /* Mike Fechner, Consultingwerk Ltd. 03.02.2013
               Direct string concatenation for building the document list to avoid 
               Out of stack space for SUBSTITUTE processing. (2922)
               which occured from the 105th file on */
            IF poParameter:GenerateTreeViewOverview = FALSE THEN
                ASSIGN lcDocumentListContent = lcDocumentListContent + THIS-OBJECT:GenerateDocumentList (cFileName, cTargetFile, poParameter) .
            ELSE
                THIS-OBJECT:GenerateTreeNodeTempTable (eUnit.ClassName, eUnit.IsInterface, eUnit.PackageName, poParameter). 
            
            COPY-LOB FILE SUBSTITUTE ("&1/Document.template":U, poParameter:TemplateSourceDir) TO lcDocumentTemplate.
                     
            ASSIGN lcDocumentTemplate = THIS-OBJECT:GenerateMethodOverview (lcDocumentTemplate, poParameter)
                   lcDocumentTemplate = THIS-OBJECT:GenerateConstructorOverview (lcDocumentTemplate, poParameter)
                   lcDocumentTemplate = THIS-OBJECT:GenerateEventOverview (lcDocumentTemplate, poParameter)
                   lcDocumentTemplate = THIS-OBJECT:GeneratePropertyOverview (lcDocumentTemplate, poParameter)
                   lcDocumentTemplate = THIS-OBJECT:GenerateInterfaceOverview (lcDocumentTemplate, poParameter)
                   lcDocumentTemplate = THIS-OBJECT:GenerateMethodDetails (lcDocumentTemplate, poParameter)
                   lcDocumentTemplate = THIS-OBJECT:GenerateConstructorDetails (lcDocumentTemplate, poParameter)
                   lcDocumentTemplate = THIS-OBJECT:GenerateEventDetails (lcDocumentTemplate, poParameter)
                   lcDocumentTemplate = THIS-OBJECT:GeneratePropertyDetails (lcDocumentTemplate, poParameter)
                   .

            ASSIGN lcDocumentTemplate = THIS-OBJECT:GenerateDocumentHeader (lcDocumentTemplate, poParameter).

            COPY-LOB lcDocumentTemplate TO FILE SUBSTITUTE ("&1/&2":U, poParameter:TargetDir, cTargetFile) .
        END.       
        
        IF poParameter:GenerateTreeViewOverview = TRUE THEN
            ASSIGN lcDocumentListContent = THIS-OBJECT:GenerateTreeviewOverview ().

        THIS-OBJECT:CreateDocumentList (poParameter, lcDocumentListContent).

        THIS-OBJECT:GeneratePackageFiles (poParameter).
                                                     
        THIS-OBJECT:GenerateIndexFile (poParameter).
             
        CATCH err AS Progress.Lang.Error :
            MESSAGE "Error while processing file:":U cCurrentFile . 	
        	
        	UNDO, THROW err .	
        END CATCH.             
                
    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Generates the document header
        Notes:   
        @param plcDocumentTemplate A LONGCHAR, that contains the content which manipulate to do.
        @param poParameter The paramter object contains the targetdir parameter.
        @return A LONGCHAR containes the manipulated content. 
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED LONGCHAR GenerateDocumentHeader (plcDocumentTemplate AS LONGCHAR, 
                                                      poParameter AS IDocumentWriterParameter):
                       
        DEFINE VARIABLE lcClassComment AS LONGCHAR             NO-UNDO.
        DEFINE VARIABLE cFullClassName AS CHARACTER            NO-UNDO.
        DEFINE VARIABLE plcParents     AS LONGCHAR             NO-UNDO.
          
        DEFINE VARIABLE cInherits AS CHARACTER NO-UNDO.
          
        FIX-CODEPAGE (lcClassComment) = "utf-8":U . 
        FIX-CODEPAGE (plcParents)     = "utf-8":U . 
          
        FIND FIRST eUnit.
        
        COPY-LOB eUnit.ClassComment TO lcClassComment.
        
        IF eUnit.Inherits > "":U THEN 
            ASSIGN cInherits = ClassDocumentationHelper:GetClassReferenceHyperlink (THIS-OBJECT:GetFullTypeName (eUnit.Inherits), poParameter) .
        
        ASSIGN
			cFullClassName      = TRIM (SUBSTITUTE ("&1.&2":U, eUnit.PackageName, eUnit.ClassName))
            plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@UNITHEADER@":U, ClassDocumentationHelper:UnitCommentFormater (ClassDocumentationHelper:CommentParser (lcClassComment, TABLE eParameterComment BY-REFERENCE)))
            plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@PAGETITLE@":U, poParameter:DocumentationTitle) 
            plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@PACKAGENAME@":U, eUnit.PackageName)
            plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@CLASSNAME@":U, eUnit.ClassName)
            plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@INHERITS@":U, cInherits)
            plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@INHERITS@":U, cInherits)
            plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@TIMESTAMP@":U, STRING (NOW, "99.99.9999 hh:mm:ss":U))
            .
        
        IF eUnit.IsFinal = TRUE THEN 
            ASSIGN plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@UNITFINAL@":U, "FINAL":U).
                
        IF eUnit.IsInterface = TRUE THEN 
            ASSIGN plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@PAGETYPE@":U, "Interface":U)
                   plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@PARENTCLASSES@":U, "")
                   .
        ELSE DO:
            ASSIGN plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@PAGETYPE@":U, "Class":U)
                   plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@PARENTCLASSES@":U, ClassDocumentationHelper:GenerateParentClassesHyperlinks (cFullClassName, poParameter))
                   .
        END.
        
        IF Consultingwerk.CharacterType:IsNullOrEmpty (eUnit.Inherits) THEN 
            ASSIGN 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@INHERITSTAGOPEN@":U, "<!--":U)
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@INHERITSTAGCLOSE@":U, "-->":U).
        ELSE
            ASSIGN 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@INHERITSTAGOPEN@":U, "":U)
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@INHERITSTAGCLOSE@":U, "":U).
         
        RETURN plcDocumentTemplate.
        
    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Generates the index file
        Notes:   
        @param poParameter poParameter The parameter object contains the targetdir parameter.
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID GenerateIndexFile (poParameter AS IDocumentWriterParameter):
        
        DEFINE VARIABLE lcIndexTemplate AS LONGCHAR  NO-UNDO.
        
        FIX-CODEPAGE (lcIndexTemplate) = "utf-8":U . 
        
        COPY-LOB FILE SUBSTITUTE ("&1/Index.template":U, poParameter:TemplateSourceDir) TO lcIndexTemplate.
        
        ASSIGN lcIndexTemplate = REPLACE (lcIndexTemplate, "@PAGETITLE@":U, poParameter:DocumentationTitle).
        
        COPY-LOB lcIndexTemplate TO FILE SUBSTITUTE ("&1/index.html":U, poParameter:TargetDir).

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Generates the method names into a html table.
        Notes: It's a overview of all methods in the class.
        @param plcDocumentTemplate A LONGCHAR, that contains the content which manipulate to do.
        @param poParameter poParameter The parameter object contains the targetdir parameter.
        @return A LONGCHAR containes the manipulated content. 
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED LONGCHAR GenerateMethodOverview (plcDocumentTemplate AS LONGCHAR,
                                                      poParameter         AS IDocumentWriterParameter):
        
        DEFINE VARIABLE lcResult  AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE lcComment AS LONGCHAR  NO-UNDO.
       
        FIX-CODEPAGE (lcResult) = "utf-8":U . 
        FIX-CODEPAGE (lcComment) = "utf-8":U . 
       
        IF NOT CAN-FIND (FIRST eMethod) THEN DO:
            ASSIGN 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@METHODCOMMENTTAGOPEN@":U, "<!--":U) 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@METHODCOMMENTTAGCLOSE@":U, "-->":U)
                .         
        END.
        ELSE
            ASSIGN 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@METHODCOMMENTTAGOPEN@":U, "":U) 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@METHODCOMMENTTAGCLOSE@":U, "":U)
                .       
          
        FOR EACH eMethod ON ERROR UNDO, THROW:
            COPY-LOB eMethod.MethodComment TO lcComment.
            
            ASSIGN lcResult = lcResult + THIS-OBJECT:ReplacePlaceholder (eMethod.MethodName,                /*Name            CHARACTER*/
                                                                         lcComment,                         /*Comment         LONGCHAR*/
                                                                         eMethod.Signature,                 /*Signatur        CHARACTER*/
                                                                         eMethod.Modifier,                  /*Modifier        CHARACTER*/
                                                                         eMethod.IsStatic,                  /*IsStatic        LOGICAL*/
                                                                         eMethod.ReturnType,                /*DataType        CHARACTER*/
                                                                         eMethod.IsAbstract,                /*IsAbstract      LOGICAL*/
                                                                         eMethod.IsFinal,                   /*IsFinal         LOGICAL*/
                                                                         "":U,                              /*DelegateName    CHARACTER*/
                                                                         "":U,                              /*SetModifier     CHARACTER*/
                                                                         "":U,                              /*GetModifier     CHARACTER*/
                                                                         "#":U + eMethod.GUID,              /*GUID            CHARACTER*/
                                                                         eMethod.Inheritance,               /*Inheritance     CHARCTER */
                                                                         "DocumentOverview.template":U,     /*TemplateName    CHARACTER*/    
                                                                         poParameter).
        END.      
        
        ASSIGN plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@OVERVIEWMETHODS@":U, lcResult). 

        RETURN plcDocumentTemplate.
        
    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Generates the constructor names into a html table.
        Notes: It's a overview of all constructors in the class.  
        @param plcDocumentTemplate A LONGCHAR, that contains the content which manipulate to do. 
        @param poParameter poParameter The parameter object contains the targetdir parameter.
        @return A LONGCHAR containes the manipulated content. 
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED LONGCHAR GenerateConstructorOverview (plcDocumentTemplate AS LONGCHAR,
                                                           poParameter         AS IDocumentWriterParameter):
        
        DEFINE VARIABLE lcResult    AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE lcComment   AS LONGCHAR  NO-UNDO.
            
        FIX-CODEPAGE (lcResult) = "utf-8":U . 
        FIX-CODEPAGE (lcComment) = "utf-8":U . 
            
        IF NOT CAN-FIND (FIRST eConstructor) THEN DO:
            ASSIGN 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@CONSTRUCTORCOMMENTTAGOPEN@":U, "<!--":U) 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@CONSTRUCTORCOMMENTTAGCLOSE@":U, "-->":U)
                .         
        END.
        ELSE
            ASSIGN 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@CONSTRUCTORCOMMENTTAGOPEN@":U, "":U) 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@CONSTRUCTORCOMMENTTAGCLOSE@":U, "":U)
                .       
        
        FOR EACH eConstructor ON ERROR UNDO, THROW:
            COPY-LOB eConstructor.ConstructorComment TO lcComment.
            
            ASSIGN lcResult = lcResult + THIS-OBJECT:ReplacePlaceholder ("CONSTRUCTOR":U,                                              /* Name            CHARACTER*/
                                                                         lcComment,                                                    /* Comment         LONGCHAR*/
                                                                         eConstructor.Signature,                                       /* Signatur        CHARACTER*/
                                                                         eConstructor.Modifier,                                        /* Modifier        CHARACTER*/
                                                                         (IF eConstructor.Modifier = "STATIC":U THEN TRUE ELSE FALSE), /* IsStatic        LOGICAL*/
                                                                         "":U,                                                         /* DataType        CHARACTER*/
                                                                         FALSE,                                                        /* IsAbstract      LOGICAL*/
                                                                         FALSE,                                                        /* IsFinal         LOGICAL*/
                                                                         "":U,                                                         /* DelegateName    CHARACTER*/
                                                                         "":U,                                                         /* SetModifier     CHARACTER*/
                                                                         "":U,                                                         /* GetModifier     CHARACTER*/
                                                                         "#":U + eConstructor.GUID,                                    /* GUID            CHARACTER*/
                                                                         "":U,                                                         /* Inheritance     CHARACTER*/ 
                                                                         "DocumentOverview.template":U,                                /* TemplateName    CHARACTER*/     
                                                                         poParameter).
        END.      
        
        ASSIGN plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@OVERVIEWCONSTRUCTORS@":U, lcResult). 
        
        RETURN plcDocumentTemplate.
        
    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Generates the event names into a html table.
        Notes: It's a overview of all events in the class.
        @param plcDocumentTemplate A LONGCHAR, that contains the content which manipulate to do. 
        @param poParameter poParameter The parameter object contains the targetdir parameter.
        @return A LONGCHAR containes the manipulated content. 
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED LONGCHAR GenerateEventOverview (plcDocumentTemplate AS LONGCHAR,
                                                     poParameter         AS IDocumentWriterParameter):
        
        DEFINE VARIABLE lcResult    AS LONGCHAR  NO-UNDO .
        DEFINE VARIABLE lcComment   AS LONGCHAR  NO-UNDO .

        FIX-CODEPAGE (lcResult) = "utf-8":U . 
        FIX-CODEPAGE (lcComment) = "utf-8":U . 
        
        IF NOT CAN-FIND (FIRST eEvent) THEN DO:
            ASSIGN 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@EVENTCOMMENTTAGOPEN@":U, "<!--":U) 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@EVENTCOMMENTTAGCLOSE@":U, "-->":U)
                .         
        END.
        ELSE
            ASSIGN 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@EVENTCOMMENTTAGOPEN@":U, "":U) 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@EVENTCOMMENTTAGCLOSE@":U, "":U)
                .  
        
        FOR EACH eEvent ON ERROR UNDO, THROW:
            COPY-LOB eEvent.EventComment TO lcComment.

            ASSIGN lcResult = lcResult + THIS-OBJECT:ReplacePlaceholder (eEvent.EventName,                  /*Name            CHARACTER*/
                                                                         lcComment,                         /*Comment         LONGCHAR*/
                                                                         eEvent.Signature,                  /*Signatur        CHARACTER*/
                                                                         eEvent.Modifier,                   /*Modifier        CHARACTER*/
                                                                         eEvent.IsStatic,                   /*IsStatic        LOGICAL*/
                                                                         "":U,                              /*Datatype        CHARACTER*/
                                                                         eEvent.IsAbstract,                 /*IsAbstract      LOGICAL*/
                                                                         FALSE,                             /*IsFinal         LOGICAL*/
                                                                         eEvent.DelegateName,               /*DelegateName    CHARACTER*/
                                                                         "":U,                              /*SetModifier     CHARACTER*/
                                                                         "":U,                              /*GetModifier     CHARACTER*/
                                                                         "#":U + eEvent.GUID,               /*GUID            CHARACTER*/
                                                                         eEvent.Inheritance,                /* Inheritance    CHARACTER*/ 
                                                                         "DocumentOverview.template":U,     /*TemplateName    CHARACTER*/     
                                                                         poParameter).
        END.      
        
        ASSIGN plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@OVERVIEWEVENTS@":U, lcResult). 
        
        RETURN plcDocumentTemplate.
        
    END METHOD .                                                                                              
    
	/*------------------------------------------------------------------------------
		Purpose: Generates the package files
		@param poParameter The parameter object contains the targetdir parameter. 																	  
		Notes:
	------------------------------------------------------------------------------*/
	METHOD PUBLIC VOID GeneratePackageFiles (poParameter AS IDocumentWriterParameter):
	    
	    DEFINE VARIABLE lcPackage            AS LONGCHAR  NO-UNDO.
	    DEFINE VARIABLE lcPackageClasses     AS LONGCHAR  NO-UNDO.
	    DEFINE VARIABLE lcPackageClassesFile AS LONGCHAR  NO-UNDO.
	    DEFINE VARIABLE lcPackageFile        AS LONGCHAR  NO-UNDO.
	    DEFINE VARIABLE cFileName            AS CHARACTER NO-UNDO.
	    DEFINE VARIABLE cPackagename         AS CHARACTER NO-UNDO.
	    DEFINE VARIABLE lcBodyContent        AS LONGCHAR  NO-UNDO.
	    DEFINE VARIABLE cPackageLink         AS CHARACTER NO-UNDO.
	    DEFINE VARIABLE cPackageFile         AS CHARACTER NO-UNDO.
	    DEFINE VARIABLE cClassFullNameLink   AS CHARACTER NO-UNDO.
	    DEFINE VARIABLE cClassName           AS CHARACTER NO-UNDO.
	    DEFINE VARIABLE cPackageFullName     AS CHARACTER NO-UNDO.
	    DEFINE VARIABLE lcComment            AS LONGCHAR  NO-UNDO.
	    DEFINE VARIABLE cCurrentFile         AS CHARACTER NO-UNDO.
	    DEFINE VARIABLE cType                AS CHARACTER NO-UNDO.
	    DEFINE VARIABLE iCount               AS INTEGER   NO-UNDO.
	    DEFINE VARIABLE cPackageTitle        AS CHARACTER NO-UNDO.
	    DEFINE VARIABLE lcPackageGroups      AS LONGCHAR  NO-UNDO.
	    DEFINE VARIABLE lcPackageGroup       AS LONGCHAR  NO-UNDO.
	    DEFINE VARIABLE lGroupExist          AS LOGICAL   NO-UNDO INIT FALSE.
	    DEFINE VARIABLE lcClassPurpose       AS LONGCHAR  NO-UNDO.
	    
	    DEFINE BUFFER bTreeNode   FOR eTreeNode.
	    DEFINE BUFFER bTreeNode2  FOR eTreeNode.
	    
	    FIX-CODEPAGE (lcPackage) = "utf-8":U .
	    FIX-CODEPAGE (lcBodyContent) = "utf-8":U .
	    FIX-CODEPAGE (lcPackageClasses) = "utf-8":U .
	    FIX-CODEPAGE (lcPackageClassesFile) = "utf-8":U .
	    FIX-CODEPAGE (lcComment) = "utf-8":U .
	    FIX-CODEPAGE (lcPackageGroup) = "utf-8":U .
	    FIX-CODEPAGE (lcClassPurpose) = "utf-8":U .
	   
	    FOR EACH bTreeNode WHERE bTreeNode.NodeType = "Package":U ON ERROR UNDO, THROW:
	        
            ASSIGN cPackageFile  = SUBSTITUTE ("&1/&2/package.html":U, REPLACE (bTreeNode.NodeParent, ".":U, "/":U), bTreeNode.NodeName)
                   lcBodyContent = "":U
                   .
            
            /* Sebastian Düngel, Consultingwerk Ltd. 14.10.2013
               Fix for the first namespace*/
            IF SUBSTRING (cPackageFile, 1, 1) = "/":U THEN
                    ASSIGN cPackageFile = SUBSTRING (cPackageFile, 2, LENGTH (cPackageFile)).
            
            FILE-INFO:FILE-NAME = cPackageFile.
            
            COPY-LOB FILE SUBSTITUTE ("&1/Package.template":U, poParameter:TemplateSourceDir) TO lcPackage.
            
            IF FILE-INFO:FULL-PATHNAME <> ? THEN DO:
                COPY-LOB FILE FILE-INFO:FULL-PATHNAME TO lcPackageFile.
                ASSIGN lcBodyContent = THIS-OBJECT:GetBodyFromPackage (lcPackageFile).
            END.
            
             /* Sebastian Düngel, Consultingwerk Ltd. 14.10.2013
                Fix for the first namespace*/
            IF bTreeNode.NodeParentFullname <> "":U THEN 
                ASSIGN cPackagename     = REPLACE (bTreeNode.NodeParentFullname, ".package.html":U , "":U)
                       cPackageFullName = SUBSTITUTE ("&1.&2":U, bTreeNode.NodeParent, bTreeNode.NodeName).
            ELSE 
                ASSIGN cPackagename     = REPLACE (bTreeNode.NodeName, ".package.html":U , "":U)
                       cPackageFullName = bTreeNode.NodeName
                       .
            
            ASSIGN lcPackage        = REPLACE (lcPackage, "@PACKAGE@":U, lcBodyContent)
                   lcPackage        = REPLACE (lcPackage, "@PAGETITLE@":U, poParameter:DocumentationTitle)
                   lcPackage        = REPLACE (lcPackage, "@TIMESTAMP@":U, STRING (NOW, "99.99.9999 hh:mm:ss":U))
                   lcPackage        = REPLACE (lcPackage, "@PACKAGENAME@":U, cPackagename)
                   lcPackage        = REPLACE (lcPackage, "@PARENTPACKAGENAME@":U, bTreeNode.NodeParent)
                   cFileName        = SUBSTITUTE ("&1/&2.package.html":U, poParameter:TargetDir, cPackagename)
                   cPackageLink     = SUBSTITUTE ("&1.package.html":U, cPackagename)
                   lcPackageGroups  = "":U
                   .
                   
            IF bTreeNode.NodeParent = "":U THEN 
                ASSIGN lcPackage        = REPLACE (lcPackage, "@PARENTPACKAGENAMEOPEN@":U, "<!--":U)
                       lcPackage        = REPLACE (lcPackage, "@PARENTPACKAGENAMECLOSE@":U, "-->":U)
                       .
            ELSE 
                ASSIGN lcPackage        = REPLACE (lcPackage, "@PARENTPACKAGENAMEOPEN@":U, "":U)
                       lcPackage        = REPLACE (lcPackage, "@PARENTPACKAGENAMECLOSE@":U, "":U)
                       . 
                   
            DO iCount = 1 TO 3:
                
                ASSIGN lGroupExist    = FALSE
                       lcPackageClasses = "":U
                       .
                
                CASE iCount:
                    WHEN 1 THEN 
                        ASSIGN cType = "Package":U
                               cPackageTitle = "Subpackages"{&TRAN}
                               .
                    WHEN 2 THEN 
                        ASSIGN cType = "Interface":U
                               cPackageTitle = "Interfaces"{&TRAN}
                               .
                    WHEN 3 THEN 
                        ASSIGN cType = "Class":U
                               cPackageTitle = "Classes"{&TRAN}
                               .
                END. 
                
                    
                FOR EACH bTreeNode2 WHERE bTreeNode2.NodeParent = cPackageFullName 
                                      AND bTreeNode2.NodeType = cType BY bTreeNode2.Order
                                          ON ERROR UNDO, THROW:
                    
                    ASSIGN lGroupExist = TRUE.
                    
                    IF bTreeNode2.NodeType <> "Package":U THEN DO:
                        
                        ASSIGN cCurrentFile = SUBSTITUTE ("&1/&2.&3.xml":U, poParameter:SourceDir, bTreeNode2.NodeParent, bTreeNode2.NodeName) . 
                        
                        DATASET dsClassDocumentation:EMPTY-DATASET ().
            
                        oParser:ParseClassDocumentation (cCurrentFile,
                                                         INPUT-OUTPUT DATASET dsClassDocumentation BY-REFERENCE) .
                        
                    END. 
                    
                    COPY-LOB FILE SUBSTITUTE ("&1/PackageItem.template":U, poParameter:TemplateSourceDir) TO lcPackageClassesFile.
                    
                    CASE bTreeNode2.NodeType:
                        WHEN "Class":U THEN DO:
                            ASSIGN lcPackageClassesFile = REPLACE (lcPackageClassesFile, "@CLASSTYPE@":U, "node_imgclass":U)
                                   cClassFullNameLink   = SUBSTITUTE ("&1.&2.html":U, bTreeNode2.NodeParentFullname, bTreeNode2.NodeName)
                                   cClassName           = SUBSTITUTE ("&1.&2":U, bTreeNode2.NodeParentFullname, bTreeNode2.NodeName)
                                   .
                        END.
                        WHEN "Interface":U THEN DO:
                            ASSIGN lcPackageClassesFile = REPLACE (lcPackageClassesFile, "@CLASSTYPE@":U, "node_imginterface":U)
                                   cClassFullNameLink   = SUBSTITUTE ("&1.&2.html":U, bTreeNode2.NodeParentFullname, bTreeNode2.NodeName)
                                   cClassName           = SUBSTITUTE ("&1.&2":U, bTreeNode2.NodeParentFullname, bTreeNode2.NodeName)
                                   .
                        END.
                        WHEN "Package":U THEN DO:
                            ASSIGN lcPackageClassesFile = REPLACE (lcPackageClassesFile, "@CLASSTYPE@":U, "node_imgpackage":U)
                                   cClassFullNameLink   = SUBSTITUTE ("&1.package.html":U, bTreeNode2.NodeParentFullname)
                                   cClassName           = bTreeNode2.NodeParentFullname
                                   .
                        END.
                    END CASE.
                    
                    FIND FIRST eUnit NO-LOCK NO-ERROR.
                    
                    IF AVAILABLE eUnit AND iCount > 1 THEN DO:
                        
                        COPY-LOB eUnit.ClassComment TO lcComment.
                        
                        ASSIGN lcClassPurpose       = ClassDocumentationHelper:GetUnitPurpose (lcComment)
                               lcPackageClassesFile = REPLACE (lcPackageClassesFile, "@CLASSPURPOSE@":U, lcClassPurpose)
                               .
                        
                    END.
                    
                    ASSIGN lcPackageClassesFile = REPLACE (lcPackageClassesFile, "@CLASSPURPOSE@":U, "":U)
                           lcPackageClassesFile = REPLACE (lcPackageClassesFile, "@CLASSNAME@":U, cClassName)
                           lcPackageClassesFile = REPLACE (lcPackageClassesFile, "@CLASSLINK@":U, cClassFullNameLink)
                           lcPackageClasses     = lcPackageClasses + lcPackageClassesFile
                           .
                    
                END.
                
                IF lGroupExist THEN DO:
                    
                    COPY-LOB FILE SUBSTITUTE ("&1/PackageGroup.template":U, poParameter:TemplateSourceDir) TO lcPackageGroup.
                    
                    ASSIGN lcPackageGroup  = REPLACE (lcPackageGroup, "@GROUPTITLE@":U, cPackageTitle)
                           lcPackageGroup  = REPLACE (lcPackageGroup, "@PACKAGEITEMS@":U, lcPackageClasses)
                           lcPackageGroups = lcPackageGroups + lcPackageGroup
                           .
                
                END. 
                
            END.
    
            ASSIGN lcPackage = REPLACE (lcPackage, "@PACKAGEGROUPS@":U, lcPackageGroups).
    
            COPY-LOB lcPackage TO FILE cFileName.
    
	    END.
	END METHOD.

	/*------------------------------------------------------------------------------
	    Purpose: Generates the package Links for the tree                                                                       
        Notes:
        @param pcFileName The source file for the package link
        @param poParameter The parameter object.
        @return The generated package link  																	  
	------------------------------------------------------------------------------*/
	METHOD PUBLIC CHARACTER GeneratePackageLinks (pcFileName   AS CHARACTER,
                                                  poParameter  AS IDocumentWriterParameter):
        
        DEFINE VARIABLE cPackageName AS CHARACTER NO-UNDO.
        
        ASSIGN cPackageName  = REPLACE (pcFileName, "/":U, ".":U).
                                             
		RETURN SUBSTITUTE ("&1/&2":U, poParameter:TargetDir, cPackageName).
		
	END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Generates the property names into a html table.
        Notes: It's a overview of all properties in the class.
        @param plcDocumentTemplate A LONGCHAR, that contains the content which manipulate to do. 
        @param poParameter poParameter The parameter object contains the targetdir parameter.
        @return A LONGCHAR containes the manipulated content. 
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED LONGCHAR GeneratePropertyOverview (plcDocumentTemplate AS LONGCHAR,
                                                        poParameter         AS IDocumentWriterParameter):
        
        DEFINE VARIABLE lcResult    AS LONGCHAR  NO-UNDO .
        DEFINE VARIABLE lcComment   AS LONGCHAR  NO-UNDO .
        
        FIX-CODEPAGE (lcResult) = "utf-8":U . 
        FIX-CODEPAGE (lcComment) = "utf-8":U . 
        
        IF NOT CAN-FIND (FIRST eProperty) THEN DO:
            ASSIGN
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@PROPERTYCOMMENTTAGOPEN@":U, "<!--":U)
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@PROPERTYCOMMENTTAGCLOSE@":U, "-->":U)
                .
        END.
        ELSE
            ASSIGN
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@PROPERTYCOMMENTTAGOPEN@":U, "":U)
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@PROPERTYCOMMENTTAGCLOSE@":U, "":U)
                .
        
        FOR EACH eProperty ON ERROR UNDO, THROW:
            COPY-LOB eProperty.PropertyComment TO lcComment.
            
            ASSIGN lcResult = lcResult + THIS-OBJECT:ReplacePlaceholder (eProperty.Name,                    /*Name            CHARACTER*/
                                                                         lcComment,                         /*Comment         LONGCHAR*/
                                                                         eProperty.Name,                    /*Signatur        CHARACTER*/
                                                                         eProperty.Modifier,                /*Modifier        CHARACTER*/
                                                                         eProperty.IsStatic,                /*IsStatic        LOGICAL*/
                                                                         eProperty.DataType,                /*Datatype        CHARACTER*/
                                                                         eProperty.IsAbstract,              /*IsAbstract      LOGICAL*/
                                                                         FALSE,                             /*IsFinal         LOGICAL*/
                                                                         "":U,                              /*DelegateName    CHARACTER*/
                                                                         eProperty.SetModifier,             /*SetModifier     CHARACTER*/
                                                                         eProperty.GetModifier,             /*GetModifier     CHARACTER*/
                                                                         "#":U + eProperty.GUID,            /*GUID            CHARACTER*/
                                                                         eProperty.Inheritance,             /* Inheritance    CHARACTER*/ 
                                                                         "DocumentOverview.template":U,     /*TemplateName    CHARACTER*/     
                                                                         poParameter).
        END.      
        
        ASSIGN plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@OVERVIEWPROPERTIES@":U, lcResult). 

        RETURN plcDocumentTemplate.
        
        
    END METHOD .
    
     /*------------------------------------------------------------------------------
        Purpose: Generates the interface names into a html table.
        Notes: It's a overview of all interfaces in the class.
        @param plcDocumentTemplate A LONGCHAR, that contains the content which manipulate to do. 
        @param poParameter poParameter The parameter object contains the targetdir parameter.
        @return A LONGCHAR containes the manipulated content. 
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED LONGCHAR GenerateInterfaceOverview (plcDocumentTemplate AS LONGCHAR,
                                                         poParameter         AS IDocumentWriterParameter):
        
        DEFINE VARIABLE lcResult              AS LONGCHAR  NO-UNDO INIT "":U.
        DEFINE VARIABLE lcComment             AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE lcInterfaceLinks      AS LONGCHAR  NO-UNDO.
        
        FIX-CODEPAGE (lcResult) = "utf-8":U . 
        FIX-CODEPAGE (lcComment) = "utf-8":U . 
        FIX-CODEPAGE (lcInterfaceLinks) = "utf-8":U . 
        
        IF NOT CAN-FIND (FIRST eInterfaces) THEN DO:
            ASSIGN 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@INTERFACECOMMENTTAGOPEN@":U, "<!--":U) 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@INTERFACECOMMENTTAGCLOSE@":U, "-->":U)
                .         
        END.
        ELSE
            ASSIGN 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@INTERFACECOMMENTTAGOPEN@":U, "":U) 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@INTERFACECOMMENTTAGCLOSE@":U, "":U)
                .  

        FOR EACH eInterfaces ON ERROR UNDO, THROW:
            ASSIGN lcInterfaceLinks = SUBSTITUTE ("&1, &2":U, lcInterfaceLinks, ClassDocumentationHelper:GetClassReferenceHyperlink (THIS-OBJECT:GetFullTypeName (eInterfaces.InterfaceName), poParameter))
                   lcResult = lcResult + THIS-OBJECT:ReplacePlaceholder (eInterfaces.InterfaceName,                                             /*Name            CHARACTER*/
                                                                         "":U,                                                                  /*Comment         LONGCHAR*/
                                                                         eInterfaces.InterfaceName,                                             /*Signatur        CHARACTER*/
                                                                         "":U,                                                                  /*Modifier        CHARACTER*/
                                                                         FALSE,                                                                 /*IsStatic        LOGICAL*/
                                                                         "":U,                                                                  /*DataType        CHARACTER*/
                                                                         FALSE,                                                                 /*IsAbstract      LOGICAL*/
                                                                         FALSE,                                                                 /*IsFinal         LOGICAL*/
                                                                         "":U,                                                                  /*DelegateName    CHARACTER*/
                                                                         "":U,                                                                  /*SetModifier     CHARACTER*/
                                                                         "":U,                                                                  /*GetModifier     CHARACTER*/
                                                                         THIS-OBJECT:GetFullTypeName (eInterfaces.InterfaceName) + ".html":U,   /*GUID            CHARACTER*/
                                                                         "",                                                                    /* Inheritance    CHARACTER*/ 
                                                                         "DocumentOverview.template":U,                                         /*TemplateName    CHARACTER*/     
                                                                         poParameter).
        END.
        
        ASSIGN lcInterfaceLinks = SUBSTRING (lcInterfaceLinks, 2)
               plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@OVERVIEWINTERFACES@":U, lcResult)
               plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@INTERFACELINKS@":U, lcInterfaceLinks)
               .
        
        RETURN plcDocumentTemplate.
        
    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Generates the methods details into a html table.
        Notes: It's a view how you can see all parameters and descriptions from a Method.
        @param plcDocumentTemplate A LONGCHAR, that contains the content which manipulate to do. 
        @param poParameter poParameter The parameter object contains the targetdir parameter.
        @return A LONGCHAR containes the manipulated content. 
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED LONGCHAR GenerateMethodDetails (plcDocumentTemplate AS LONGCHAR,
                                                     poParameter         AS IDocumentWriterParameter):
        
        DEFINE VARIABLE lcResult    AS LONGCHAR  NO-UNDO .
        DEFINE VARIABLE lcComment   AS LONGCHAR  NO-UNDO .
        
        FIX-CODEPAGE (lcResult) = "utf-8":U . 
        FIX-CODEPAGE (lcComment) = "utf-8":U . 

        IF NOT CAN-FIND (FIRST eMethod) THEN DO:
            ASSIGN
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@DETAILMETHODCOMMENTTAGOPEN@":U, "<!--":U)
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@DETAILMETHODCOMMENTTAGCLOSE@":U, "-->":U)
                .
        END.
        ELSE
            ASSIGN
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@DETAILMETHODCOMMENTTAGOPEN@":U, "":U)
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@DETAILMETHODCOMMENTTAGCLOSE@":U, "":U)
                .
        
        FOR EACH eMethod ON ERROR UNDO, THROW:
            COPY-LOB eMethod.MethodComment TO lcComment.
            
            ASSIGN lcResult = lcResult + THIS-OBJECT:ReplacePlaceholder (eMethod.MethodName,                /*Name            CHARACTER*/
                                                                         lcComment,                         /*Comment         LONGCHAR*/
                                                                         eMethod.Signature,                 /*Signatur        CHARACTER*/
                                                                         eMethod.Modifier,                  /*Modifier        CHARACTER*/
                                                                         eMethod.IsStatic,                  /*IsStatic        LOGICAL*/
                                                                         eMethod.ReturnType,                /*DataType        CHARACTER*/
                                                                         eMethod.IsAbstract,                /*IsAbstract      LOGICAL*/
                                                                         eMethod.IsFinal,                   /*IsFinal         LOGICAL*/ 
                                                                         "":U,                              /*DelegateName    CHARACTER*/
                                                                         "":U,                              /*SetModifier     CHARACTER*/
                                                                         "":U,                              /*GetModifier     CHARACTER*/
                                                                         eMethod.GUID,                      /*GUID            CHARACTER*/
                                                                         eMethod.Inheritance,               /* Inheritance    CHARACTER*/ 
                                                                         "DocumentDetails.template":U,      /*TemplateName    CHARACTER*/     
                                                                         poParameter).
        END.     

        ASSIGN plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@DETAILMETHODS@":U, lcResult). 
 
        RETURN plcDocumentTemplate.
        
    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Generates the methods details into a html table.
        Notes: It's a view how you can see all parameters and descriptions from a Method.
        @param plcDocumentTemplate A LONGCHAR, that contains the content which manipulate to do. 
        @param poParameter poParameter The parameter object contains the targetdir parameter.
        @return A LONGCHAR containes the manipulated content. 
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED LONGCHAR GenerateConstructorDetails (plcDocumentTemplate AS LONGCHAR,
                                                          poParameter         AS IDocumentWriterParameter):
        
        DEFINE VARIABLE lcResult    AS LONGCHAR  NO-UNDO .
        DEFINE VARIABLE lcComment   AS LONGCHAR  NO-UNDO .
        
        FIX-CODEPAGE (lcResult) = "utf-8":U . 
        FIX-CODEPAGE (lcComment) = "utf-8":U . 
        
        IF NOT CAN-FIND (FIRST eConstructor) THEN DO:
            ASSIGN 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@DETAILCONSTRUCTORCOMMENTTAGOPEN@":U, "<!--":U) 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@DETAILCONSTRUCTORCOMMENTTAGCLOSE@":U, "-->":U)
                .         
        END.
        ELSE
            ASSIGN 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@DETAILCONSTRUCTORCOMMENTTAGOPEN@":U, "":U) 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@DETAILCONSTRUCTORCOMMENTTAGCLOSE@":U, "":U)
                .  
        
        FOR EACH eConstructor ON ERROR UNDO, THROW:
            COPY-LOB eConstructor.ConstructorComment TO lcComment.
            
            ASSIGN lcResult = lcResult + THIS-OBJECT:ReplacePlaceholder ("CONSTRUCTOR":U,                                              /* Name            CHARACTER */
                                                                         lcComment,                                                    /* Comment         LONGCHAR */
                                                                         eConstructor.Signature,                                       /* Signatur        CHARACTER */
                                                                         eConstructor.Modifier,                                        /* Modifier        CHARACTER */
                                                                         (IF eConstructor.Modifier = "STATIC":U THEN TRUE ELSE FALSE), /* IsStatic        LOGICAL */
                                                                         "":U,                                                         /* DataType        CHARACTER */
                                                                         FALSE,                                                        /* IsAbstract      LOGICAL */
                                                                         FALSE,                                                        /* IsFinal         LOGICAL */
                                                                         "":U,                                                         /* DelegateName    CHARACTER */
                                                                         "":U,                                                         /* SetModifier     CHARACTER */
                                                                         "":U,                                                         /* GetModifier     CHARACTER */
                                                                         eConstructor.GUID,
                                                                         "":U,                                                         /* Inheritance     CHARACTER*/                                             /* GUID            CHARACTER */
                                                                         "DocumentDetails.template":U,                                 /* TemplateName    CHARACTER */     
                                                                         poParameter).
        END.      
        
        ASSIGN plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@DETAILCONSTRUCTORS@":U, lcResult). 
        
        RETURN plcDocumentTemplate.
        
    END METHOD .
    
     /*------------------------------------------------------------------------------
        Purpose: Generates the events details into a html table.
        Notes: It's a view how you can see all parameters and descriptions from an event.
        @param plcDocumentTemplate A LONGCHAR, that contains the content which manipulate to do. 
        @param poParameter poParameter The parameter object contains the targetdir parameter.
        @return A LONGCHAR containes the manipulated content. 
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED LONGCHAR GenerateEventDetails (plcDocumentTemplate AS LONGCHAR,
                                                    poParameter         AS IDocumentWriterParameter):
        
        DEFINE VARIABLE lcResult    AS LONGCHAR  NO-UNDO .
        DEFINE VARIABLE lcComment   AS LONGCHAR  NO-UNDO .

        FIX-CODEPAGE (lcResult) = "utf-8":U . 
        FIX-CODEPAGE (lcComment) = "utf-8":U . 
        
        IF NOT CAN-FIND (FIRST eEvent) THEN DO:
            ASSIGN 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@DETAILEVENTCOMMENTTAGOPEN@":U, "<!--":U) 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@DETAILEVENTCOMMENTTAGCLOSE@":U, "-->":U)
                .         
        END.
        ELSE
            ASSIGN 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@DETAILEVENTCOMMENTTAGOPEN@":U, "":U) 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@DETAILEVENTCOMMENTTAGCLOSE@":U, "":U)
                .  
        
        FOR EACH eEvent ON ERROR UNDO, THROW:
            COPY-LOB eEvent.EventComment TO lcComment.
            
            ASSIGN lcResult = lcResult + THIS-OBJECT:ReplacePlaceholder (eEvent.EventName,                  /*Name            CHARACTER*/
                                                                         lcComment,                         /*Comment         LONGCHAR*/
                                                                         eEvent.Signature,                  /*Signatur        CHARACTER*/
                                                                         eEvent.Modifier,                   /*Modifier        CHARACTER*/
                                                                         eEvent.IsStatic,                   /*IsStatic        LOGICAL*/
                                                                         "":U,                              /*DataType        CHARACTER*/
                                                                         eEvent.IsAbstract,                 /*IsAbstract      LOGICAL*/
                                                                         FALSE,                             /*IsAbstract      LOGICAL*/
                                                                         eEvent.DelegateName,               /*DelegateName    CHARACTER*/
                                                                         "":U,                              /*SetModifier     CHARACTER*/
                                                                         "":U,                              /*GetModifier     CHARACTER*/
                                                                         eEvent.GUID,                       /*GUID            CHARACTER*/
                                                                         eEvent.Inheritance,                /*Inheritance      CHARACTER*/ 
                                                                         "DocumentDetails.template":U,      /*TemplateName    CHARACTER*/     
                                                                         poParameter).
        END.      
        
        ASSIGN plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@DETAILEVENTS@":U, lcResult). 
        
        RETURN plcDocumentTemplate.
        
    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Generates the properties details into a html table.
        Notes: It's a view how you can see all parameters and descriptions from a properties.
        @param plcDocumentTemplate A LONGCHAR, that contains the content which manipulate to do. 
        @param poParameter poParameter The parameter object contains the targetdir parameter.
        @return A LONGCHAR containes the manipulated content. 
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED LONGCHAR GeneratePropertyDetails (plcDocumentTemplate AS LONGCHAR,
                                                       poParameter         AS IDocumentWriterParameter):
        
        DEFINE VARIABLE lcResult             AS LONGCHAR  NO-UNDO .
        DEFINE VARIABLE lcComment            AS LONGCHAR  NO-UNDO .
        
        FIX-CODEPAGE (lcResult) = "utf-8":U . 
        FIX-CODEPAGE (lcComment) = "utf-8":U . 

        IF NOT CAN-FIND (FIRST eProperty) THEN DO:
            ASSIGN 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@DETAILPROPERTYCOMMENTTAGOPEN@":U, "<!--":U) 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@DETAILPROPERTYCOMMENTTAGCLOSE@":U, "-->":U)
                .         
        END.
        ELSE
            ASSIGN 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@DETAILPROPERTYCOMMENTTAGOPEN@":U, "":U) 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@DETAILPROPERTYCOMMENTTAGCLOSE@":U, "":U)
                .          
        
        FOR EACH eProperty ON ERROR UNDO, THROW:
            COPY-LOB eProperty.PropertyComment TO lcComment.
            
            ASSIGN lcResult = lcResult + THIS-OBJECT:ReplacePlaceholder (eProperty.Name,                    /*Name            CHARACTER*/
                                                                         lcComment,                         /*Comment         LONGCHAR*/
                                                                         eProperty.Name,                    /*Signatur        CHARACTER*/
                                                                         eProperty.Modifier,                /*Modifier        CHARACTER*/
                                                                         eProperty.IsStatic,                /*IsStatic        LOGICAL*/
                                                                         eProperty.DataType,                /*DataType        CHARACTER*/
                                                                         eProperty.IsAbstract,              /*IsAbstract      LOGICAL*/
                                                                         FALSE,                             /*IsFinal         LOGICAL*/
                                                                         "":U,                              /*DelegateName    CHARACTER*/
                                                                         eProperty.SetModifier,             /*SetModifier     CHARACTER*/
                                                                         eProperty.GetModifier,             /*GetModifier     CHARACTER*/
                                                                         eProperty.GUID,                    /*GUID            CHARACTER*/
                                                                         eProperty.Inheritance,             /* Inheritance      CHARACTER*/ 
                                                                         "DocumentDetails.template":U,      /*TemplateName    CHARACTER*/     
                                                                         poParameter).
        END.      
        
        ASSIGN plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@DETAILPROPERTIES@":U, lcResult). 
        
        RETURN plcDocumentTemplate.
        
    END METHOD .

	/*------------------------------------------------------------------------------
		Purpose: Start the generating Treeview
        Notes: Get Treeview list of all classes.  
        @return get the generated Treeview.															  
	------------------------------------------------------------------------------*/
	METHOD PROTECTED LONGCHAR GenerateTreeviewOverview ():
		
		DEFINE VARIABLE lcResult       AS LONGCHAR  NO-UNDO.
        
		FIX-CODEPAGE (lcResult) = "utf-8":U . 

		FOR EACH eTreeNode WHERE eTreeNode.NodeParent = "":U ON ERROR UNDO, THROW:
            /* Sebastian Düngel, Consultingwerk Ltd. 17.04.2013
               Create string without Substitute method then the
               Substitute function get a Stackoverflow error */   
            ASSIGN lcResult = "<table class='parent_node'>":U + 
                                  "<tr>":U +
                                      "<td valign='top'>":U +
                                          "<div class='node_root'></div>":U +
                                      "</td>":U +
                                      "<td>":U +
                                          "<div>":U +
                                              "<table class='hide'>":U +
                                                  "<tr>":U +
                                                      "<td>":U +
                                                          "<div class='node_imgroot'></div>":U +
                                                      "</td>":U +
                                                      "<td>":U +
                                                          "<a name='":U + eTreeNode.NodeName + "' href='":U + eTreeNode.NodeName + ".package.html' target='DocumentDetails' class='' style='font-weight: normal;'>":U + eTreeNode.NodeName + "</a>":U +
                                                      "</td>":U +
                                                  "</tr>":U + 
                                              "</table>":U +
                                          "</div>":U +
                                          THIS-OBJECT:GenerateTreeviewOverviewNodes (eTreeNode.NodeName, eTreeNode.NodeParent, INPUT-OUTPUT lcResult) +            
                                      "</td>":U +
                                  "</tr>":U +
                              "</table>":U
                              .
            
            RETURN lcResult.
		END.
	END METHOD.
	
	/*------------------------------------------------------------------------------
        Purpose: Generate the treeview overview nodes
        Notes: A recursive function to generate the treeview nodes
        @param NodeName The gerated Nodename.
        @param NodeParent The parent node name from the node
        @param lcResult The generated recursive result 
        @return the generated result.                                                             
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED LONGCHAR GenerateTreeviewOverviewNodes (NodeName              AS CHARACTER,
                                                             NodeParent            AS CHARACTER,
                                                             INPUT-OUTPUT lcResult AS LONGCHAR):
        DEFINE VARIABLE lcNode          AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE lcNodes         AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE cHrefLink       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cImgClass       AS CHARACTER NO-UNDO. 
        DEFINE VARIABLE cClassFullName  AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cLink           AS CHARACTER NO-UNDO. 
        DEFINE VARIABLE cTreeNodesQuery AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cImgNode        AS CHARACTER NO-UNDO.
        DEFINE VARIABLE hQuery          AS HANDLE    NO-UNDO.
        DEFINE VARIABLE hBuffer         AS HANDLE    NO-UNDO.
        DEFINE VARIABLE cNodeParent     AS CHARACTER NO-UNDO.
        
        DEFINE BUFFER bTreeNode FOR eTreeNode.
        DEFINE QUERY  qTreeNodes FOR bTreeNode.
        
        FIX-CODEPAGE (lcNode)  = "utf-8":U. 
        FIX-CODEPAGE (lcNodes) = "utf-8":U. 
        
        IF NodeParent = "":U THEN
            ASSIGN cNodeParent = NodeName.
         ELSE
            ASSIGN cNodeParent = SUBSTITUTE ("&1.&2":U, NodeParent, NodeName). 
            
        OPEN QUERY qTreeNodes FOR EACH bTreeNode WHERE bTreeNode.NodeParent = cNodeParent 
            BY bTreeNode.Order BY bTreeNode.NodeName.
         
        GET FIRST qTreeNodes NO-LOCK.
        
        DO WHILE NOT QUERY qTreeNodes:QUERY-OFF-END ON ERROR UNDO, THROW:                    
            
            ASSIGN cClassFullName = SUBSTITUTE ("&1.&2":U, bTreeNode.NodeParentFullname, bTreeNode.NodeName).
            
            CASE bTreeNode.NodeType:
                WHEN "Package":U THEN DO:
                    ASSIGN cImgClass = "node_imgpackage":U
                           cLink     = SUBSTITUTE ("&1.package.html":U, bTreeNode.NodeParentFullname)
                           cImgNode  = "node_root":U.
                           .
                END.
                WHEN "Class":U THEN DO:
                    ASSIGN cImgClass = "node_imgclass":U
                           cLink     = SUBSTITUTE ("&1.html":U, cClassFullName)
                           cImgNode  = "node":U.
                           .
                END.
                WHEN "Interface":U THEN DO:
                    ASSIGN cImgClass = "node_imginterface":U
                           cLink     = SUBSTITUTE ("&1.html":U, cClassFullName)
                           cImgNode  = "node":U.
                           . 
                END.
            END CASE.
                   
            /* Sebastian Düngel, Consultingwerk Ltd. 17.04.2013
               Create string without Substitute method then the
               Substitute function get a Stackoverflow error */ 
            ASSIGN lcNode  = "<table class='child_node parent":U + REPLACE (bTreeNode.NodeParent, ".":U, "":U) + " ":U + bTreeNode.NodeParentFullname + "'>":U +
                                              "<tr>":U +
                                                  "<td valign='top'>":U +
                                                      "<div class='":U + cImgNode + "'></div>":U +
                                                  "</td>":U +
                                                  "<td>":U +
                                                      "<div>":U +
                                                          "<table>":U +
                                                              "<tr>":U +
                                                                  "<td>":U +
                                                                      "<div class='":U + cImgClass  + "'></div>":U +
                                                                  "</td>":U +
                                                                  "<td>":U +
                                                                      "<a name='":U + REPLACE (bTreeNode.NodeParent, ".":U, "":U) + bTreeNode.NodeName + "' href='":U + cLink + "' target='DocumentDetails' class='' style='font-weight: normal;'>":U + bTreeNode.NodeName + "</a>":U +
                                                                  "</td>":U +
                                                              "</tr>":U +
                                                          "</table>":U +
                                                      "</div>":U +
                                                      THIS-OBJECT:GenerateTreeviewOverviewNodes (bTreeNode.NodeName, bTreeNode.NodeParent, lcResult) +
                                                  "</td>":U +
                                              "</tr>":U +
                                         "</table>":U
                                         .
            
            ASSIGN lcNodes = lcNodes + lcNode.
            
            GET NEXT qTreeNodes NO-LOCK.            
        END.
        
        RETURN lcResult + lcNodes.
        
    END METHOD.
	
	/*------------------------------------------------------------------------------
        Purpose: Generate the Nodes Temp-Table for a tree view
        Notes:  
        @param pcClassName The class name.
        @param lIsInterface Is the class a interface 
        @param pcPackagename The class package name.
        @param poParameter The parameter object.                                                                 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID GenerateTreeNodeTempTable (pcClassName   AS CHARACTER,
                                                  lIsInterface  AS LOGICAL,
                                                  pcPackagename AS CHARACTER,
                                                  poParameter    AS IDocumentWriterParameter):
                                                      
        DEFINE VARIABLE iCount         AS INTEGER NO-UNDO.
        DEFINE VARIABLE cParentpackage AS CHARACTER NO-UNDO INIT "":U.
        DEFINE VARIABLE cPackageLink   AS CHARACTER NO-UNDO INIT "":U.
        DEFINE VARIABLE cPackageFile   AS CHARACTER NO-UNDO INIT "":U.
        
        DEFINE BUFFER bTreeNode FOR eTreeNode.
        
        DO iCount = 1 TO NUM-ENTRIES (pcPackagename, ".":U) ON ERROR UNDO, THROW:
            
            IF iCount > 1 THEN DO:
                IF cParentpackage <> "":U THEN 
                    ASSIGN cParentpackage = SUBSTITUTE ("&1.&2":U, cParentpackage, ENTRY (iCount - 1, pcPackagename, ".":U)).
                ELSE 
                    ASSIGN cParentpackage = ENTRY (iCount - 1, pcPackagename, ".":U).
                     
                FIND FIRST bTreeNode WHERE bTreeNode.NodeParent = cParentpackage
                                        AND bTreeNode.NodeName = ENTRY (iCount, pcPackagename, ".":U) NO-LOCK NO-ERROR.
            
            END. 
            ELSE
                FIND FIRST bTreeNode WHERE bTreeNode.NodeParent = "":U
                                        AND bTreeNode.NodeName = ENTRY (iCount, pcPackagename, ".":U) NO-LOCK NO-ERROR.
            
            IF NOT AVAILABLE bTreeNode THEN DO: 
                
                CREATE eTreeNode.
                
                ASSIGN eTreeNode.NodeName = ENTRY (iCount, pcPackagename, ".":U)
                       eTreeNode.Order    = 0
                       eTreeNode.NodeType = "Package":U
                       .

                ASSIGN cPackageFile = SUBSTITUTE ("&1/&2/package.html":U, REPLACE (cParentpackage, ".":U, "/":U), eTreeNode.NodeName).
                
                /* Sebastian Düngel, Consultingwerk Ltd. 27.06.2013
                   Fix for the first namespace*/
                IF SUBSTRING (cPackageFile, 1, 1) = "/":U THEN 
                    ASSIGN cPackageFile = SUBSTRING (cPackageFile, 2, LENGTH (cPackageFile)).
                
                ASSIGN eTreenode.PackageLink = THIS-OBJECT:GeneratePackageLinks (cPackageFile, poParameter).
                       
                IF iCount > 1 THEN 
                    ASSIGN eTreeNode.NodeParentFullname = pcPackagename
                           eTreeNode.NodeParent         = cParentpackage
                           .
                ELSE 
                    ASSIGN eTreeNode.NodeParentFullname = "":U
                           eTreeNode.NodeParent         = "":U
                           .
            END.
                       
            IF iCount = NUM-ENTRIES (pcPackagename, ".":U) THEN DO:
                CREATE eTreeNode.
                ASSIGN eTreeNode.NodeName           = pcClassName
                       eTreeNode.NodeParentFullname = pcPackagename
                       eTreeNode.Order              = 1
                       eTreeNode.NodeType           = "Class":U
                       .
                
                IF cParentpackage <> "":U THEN 
                    ASSIGN eTreeNode.NodeParent = SUBSTITUTE ("&1.&2":U, cParentpackage, ENTRY (iCount, pcPackagename, ".":U)).
                ELSE 
                    ASSIGN eTreeNode.NodeParent = ENTRY (iCount, pcPackagename, ".":U).
                
                IF lIsInterface = TRUE THEN 
                    ASSIGN eTreeNode.NodeType = "Interface":U.
            END.

        END.
         
    END METHOD.

	/*------------------------------------------------------------------------------
		Purpose: Gets the content of the body of a package.html file 																	  
		Notes:
		@param lcPackageContent The the package content.
		@return The content of the body of a package.html file   																	  
	------------------------------------------------------------------------------*/
	METHOD PUBLIC LONGCHAR GetBodyFromPackage (lcPackageContent AS LONGCHAR):
		
		DEFINE VARIABLE lcResult  AS LONGCHAR NO-UNDO.
		DEFINE VARIABLE iStartPos AS INTEGER NO-UNDO.
		DEFINE VARIABLE iEndPos   AS INTEGER NO-UNDO.
		DEFINE VARIABLE iLength   AS INTEGER NO-UNDO.
		
		ASSIGN iStartPos = INDEX (lcPackageContent, "<BODY":U)
		       iEndPos   = INDEX (lcPackageContent, "</BODY>":U)
		       .

		IF iEndPos < iStartPos THEN 
		    RETURN "":U.
		ELSE 
		    ASSIGN iLength = iEndPos - iStartPos.
		
		IF iStartPos = 0 THEN 
		  RETURN "":U.
		
		ASSIGN  iStartPos = INDEX (lcPackageContent, ">":U, iStartPos) + 1
		        lcResult = SUBSTRING (lcPackageContent, iStartPos, iLength).
		
		RETURN lcResult.
		
	END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns the fully qualified type name from a type name
        Notes:   
        @param pcTypeName The typename value. 
        @return A LONGCHAR, return the fulltypename
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER GetFullTypeName (pcTypeName AS CHARACTER):
        
        RETURN ClassDocumentationHelper:GetFullTypeName (pcTypeName, TABLE eUsing BY-REFERENCE).
        
    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Replaces the Placeholders in a LONGCHAR value 
        Notes:   
        @param pcName The CHARACTER value replace the keyword "@NAME@"
        @param plcComment The LONGCHAR value replace the keyword "@COMMENT@"
        @param pcSignature The LONGCHAR value replace the keyword "@SIGNATURE@"
        @param pcModifier The CHARACTER value replace the keyword "@MODIFIER@"
        @param plIsStatic The LOGICAL value replace the keyword "@ISSTATIC@"
        @param pcDataType The CHARACTER value replace the keyword "@DATATYPE@"
        @param plIsAbstract The LOGICAL value replace the keyword "@ISABSTRACT@"
        @param plIsFinal The LOGICAL value replace the keyword "@ISFINAL@"
        @param pcDelegateName The CHARACTER value replace the keyword "@DELEGATENAME@"
        @param pcSetModifier The CHARACTER value replace the keyword "@SETMODIFIER@"
        @param pcGetModifier The CHARACTER value replace the keyword "@GETMODIFIER@"
        @param pcGuid The CHARACTER value replace the keyword "@GUID@"
        @param pcInheritance The Inherited comment "@INHERITANCE@"
        @param pcTemplateName The template name which be loaded and manipulated. 
        @param poParameter The parameter object.
        @return Return the manipulated template
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED LONGCHAR ReplacePlaceholder (pcName          AS CHARACTER, 
                                                  plcComment      AS LONGCHAR,
                                                  pcSignature     AS CHARACTER,
                                                  pcModifier      AS CHARACTER,
                                                  plIsStatic      AS LOGICAL,
                                                  pcDataType      AS CHARACTER,
                                                  plIsAbstract    AS LOGICAL,
                                                  plIsFinal       AS LOGICAL,
                                                  pcDelegateName  AS CHARACTER,
                                                  pcSetModifier   AS CHARACTER,
                                                  pcGetModifier   AS CHARACTER,
                                                  pcGuid          AS CHARACTER,
                                                  pcInheritance   AS CHARACTER,
                                                  pcTemplateName  AS CHARACTER,
                                                  poParameter     AS IDocumentWriterParameter):
        
        DEFINE VARIABLE lcDocumentTemplate          AS LONGCHAR            NO-UNDO.
        DEFINE VARIABLE cResult                     AS LONGCHAR            NO-UNDO.
        DEFINE VARIABLE cParameterResult            AS LONGCHAR            NO-UNDO.
        DEFINE VARIABLE cParameter                  AS CHARACTER           NO-UNDO.
        DEFINE VARIABLE lcComment                   AS LONGCHAR            NO-UNDO.
        DEFINE VARIABLE cAnchor                     AS CHARACTER           NO-UNDO.
   
        FIX-CODEPAGE (lcDocumentTemplate) = "utf-8":U . 
        FIX-CODEPAGE (cResult) = "utf-8":U . 
        FIX-CODEPAGE (cParameterResult) = "utf-8":U . 
        FIX-CODEPAGE (lcComment) = "utf-8":U . 
   
        IF NOT DataTypeHelper:IsAblDataType (pcDataType) AND pcDataType <> "":U THEN 
            ASSIGN pcDataType =  THIS-OBJECT:GetFullTypeName (pcDataType).
        
        COPY-LOB FILE SUBSTITUTE ("&1/&2":U,
                                  poParameter:TemplateSourceDir, 
                                  pcTemplateName) TO lcDocumentTemplate.

        ASSIGN cResult = REPLACE (lcDocumentTemplate, "@NAME@":U, pcName)      
               cResult = REPLACE (cResult, "@SIGNATURE@":U, ClassDocumentationHelper:SignatureParser (pcSignature, pcModifier, pcDataType, poParameter))
               cResult = REPLACE (cResult, "@PURPOSE@":U, ClassDocumentationHelper:GetSummaryComment (plcComment))
               cResult = REPLACE (cResult, "@COMMENT@":U, ClassDocumentationHelper:CommentFormater (ClassDocumentationHelper:CommentParser (plcComment, TABLE eParameterComment BY-REFERENCE)))
               cResult = REPLACE (cResult, "@MODIFIER@":U, pcModifier)
               cResult = REPLACE (cResult, "@SHORTMODIFIER@":U, ClassDocumentationHelper:GetShortModifier (pcModifier))
               cResult = REPLACE (cResult, "@ISSTATIC@":U, STRING (plIsStatic))
               cResult = REPLACE (cResult, "@STATIC@":U, IF plIsStatic = YES THEN "STATIC":U ELSE "":U)
               cResult = REPLACE (cResult, "@ISABSTRACT@":U, STRING (plIsAbstract))
               cResult = REPLACE (cResult, "@ABSTRACT@":U, IF plIsAbstract = YES THEN "ABSTRACT":U ELSE "":U)
               cResult = REPLACE (cResult, "@ISFINAL@":U, STRING (plIsFinal))
               cResult = REPLACE (cResult, "@FINAL@":U, IF plIsFinal = YES THEN "FINAL":U ELSE "":U)
               cResult = REPLACE (cResult, "@DELEGATENAME@":U, pcDelegateName)
               cResult = REPLACE (cResult, "@SETMODIFIER@":U, pcSetModifier)
               cResult = REPLACE (cResult, "@GETMODIFIER@":U, pcGetModifier)
               cResult = REPLACE (cResult, "@DATATYPE@":U, pcDataType)
               cResult = REPLACE (cResult, "@SHORTSIGNATURE@":U, ClassDocumentationHelper:SignatureParser (pcSignature, "":U, pcDataType, poParameter))
               cResult = REPLACE (cResult, "@LINKDATATYPE@":U, ClassDocumentationHelper:GetClassReferenceHyperlink (pcDataType, poParameter))
               cAnchor = STRING (MD5-DIGEST (ClassDocumentationHelper:SignatureParser (pcSignature, "":U, pcDataType, poParameter)))
               cResult = REPLACE (cResult, "@ANCHOR@":U, cAnchor)
               cResult = REPLACE (cResult, "@GUID@":U, pcGuid)
               cResult = REPLACE (cResult, "@INHERITANCE@":U, pcInheritance)
               .
                
        FOR EACH eParameter WHERE eParameter.ParentGUID = pcGuid ON ERROR UNDO, THROW:
            
            COPY-LOB FILE SUBSTITUTE ("&1/DocumentDetailsParameter.template":U,
                                      poParameter:TemplateSourceDir) TO cParameterResult.
                 
            ASSIGN cParameterResult = REPLACE (cParameterResult, "@PARAMETERSEQUENCE@":U, STRING (eParameter.Sequence))
                   cParameterResult = REPLACE (cParameterResult, "@PARAMETERNAME@":U, STRING (eParameter.Name))
                   cParameterResult = REPLACE (cParameterResult, "@PARAMETERDATATYPE@":U, SUBSTITUTE ("&1 &2":U, STRING (eParameter.DataType), ClassDocumentationHelper:GenericTypesParser (eParameter.DataType, poParameter)))
                   cParameterResult = REPLACE (cParameterResult, "@PARAMETERPOSITION@":U, STRING (eParameter.Position))
                   cParameterResult = REPLACE (cParameterResult, "@PARAMETERMODE@":U, STRING (eParameter.Mode))
                   .
            
            ASSIGN cParameterResult = REPLACE (cParameterResult, "@PARAMETERFULLDATATYPE@":U, ClassDocumentationHelper:GetClassReferenceHyperlink (THIS-OBJECT:GetFullTypeName (eParameter.DataType), poParameter))
                   cParameterResult = REPLACE (cParameterResult, "@GENERICTYPES@":U, ClassDocumentationHelper:GenericTypesParser (THIS-OBJECT:GetFullTypeName (eParameter.DataType), poParameter)).
            
            FIND eParameterComment WHERE eParameterComment.Name = eParameter.Name NO-ERROR.
                        
            IF AVAILABLE eParameterComment THEN DO:
                
                COPY-LOB eParameterComment.Comment TO lcComment.
                ASSIGN cParameterResult = REPLACE (cParameterResult, "@PARAMETERCOMMENT@":U, STRING (lcComment)).
            
            END.
            ELSE 
                ASSIGN cParameterResult = REPLACE (cParameterResult, "@PARAMETERCOMMENT@":U, "":U).
            
            ASSIGN  cParameter = cParameter + cParameterResult.
        END.
        
        IF Consultingwerk.CharacterType:IsNullOrEmpty (cParameter) THEN DO:
            ASSIGN 
                cResult = REPLACE (cResult, "@PARAMETERCOMMENTTAGOPEN@":U, "<!--":U) 
                cResult = REPLACE (cResult, "@PARAMETERCOMMENTTAGCLOSED@":U, "-->":U)
                .  
        END.
        ELSE DO:
           ASSIGN 
                cResult = REPLACE (cResult, "@PARAMETERCOMMENTTAGOPEN@":U, "":U) 
                cResult = REPLACE (cResult, "@PARAMETERCOMMENTTAGCLOSED@":U, "":U)
                .     
        END. 

        COPY-LOB FILE SUBSTITUTE ("&1/DocumentDetailsReturn.template":U,
                                  poParameter:TemplateSourceDir) TO cParameterResult.
        
        IF NOT pcDataType = "":U THEN DO:
            
            ASSIGN cParameter = cParameter + REPLACE (cParameterResult, "@PARAMETERMODE@":U, "RETURN":U)
                   cParameter = REPLACE (cParameter, "@PARAMETERNAME@":U, "Returns":U)
                   cParameter = REPLACE (cParameter, "@PARAMETERFULLDATATYPE@":U, SUBSTITUTE ("&1 &2":U, ClassDocumentationHelper:GetClassReferenceHyperlink (THIS-OBJECT:GetFullTypeName (pcDataType), poParameter), ClassDocumentationHelper:GenericTypesParser (pcDataType, poParameter)))
                   cParameter = REPLACE (cParameter, "@GENERICTYPES@":U, ClassDocumentationHelper:GenericTypesParser (THIS-OBJECT:GetFullTypeName (pcDataType), poParameter)).
                   .

            FIND eParameterComment WHERE eParameterComment.Name = "RETURN":U NO-ERROR.

            IF AVAILABLE eParameterComment THEN DO:
                COPY-LOB eParameterComment.Comment TO lcComment.
                ASSIGN cParameter = REPLACE (cParameter, "@PARAMETERCOMMENT@":U, lcComment).
            END.
            ELSE
                ASSIGN cParameter = REPLACE (cParameter, "@PARAMETERCOMMENT@":U, "":U).
        
        END. 

        ASSIGN cResult = REPLACE(cResult, "@PARAMETERS@":U, cParameter).
               
        RETURN cResult.

    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Generate the document list
        Notes: The List is a overview of all classes.  
        @param pcClass A CHRACTER value which show a link caption.
        @param pcHref A CHARCTER link value to the html class reference
        @param poParameter The parameter object.
        @return Return the generated html LONGCHAR
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED LONGCHAR GenerateDocumentList (pcClass     AS CHARACTER, 
                                                    pcHref      AS CHARACTER,
                                                    poParameter AS IDocumentWriterParameter):
        
        DEFINE VARIABLE lcDocumentItemTemplate       AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE lcResult                     AS LONGCHAR NO-UNDO.
        
        FIX-CODEPAGE (lcDocumentItemTemplate) = "utf-8":U . 
        FIX-CODEPAGE (lcResult) = "utf-8":U . 
        
        COPY-LOB FILE SUBSTITUTE ("&1/DocumentListItem.template":U, poParameter:TemplateSourceDir) TO lcDocumentItemTemplate.
                                            
        ASSIGN lcResult = REPLACE (lcDocumentItemTemplate, "@CLASSNAME@":U, pcClass)
               lcResult = REPLACE (lcResult, "@HREF@":U, pcHref)
               .
               
        FIND FIRST eUnit.
        
        IF eUnit.IsInterface = TRUE THEN  
            ASSIGN lcResult = REPLACE (lcResult, "@PAGETYPE@":U, "interface":U).
        ELSE
            ASSIGN lcResult = REPLACE (lcResult, "@PAGETYPE@":U, "class":U).
               
        RETURN lcResult.
       
    END METHOD .

    
END CLASS.
