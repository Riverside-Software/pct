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
    File        : DocumentationWriter
    Purpose     : Generate a html documentation from xml-files. 
    Syntax      : 
    Description : 
    Author(s)   : Sebastian Düngel / Consultingwerk Ltd.
    Created     : Wed Oct 10 17:11:42 CEST 2012
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Studio.ClassDocumentation.* FROM PROPATH .
USING Consultingwerk.Studio.SmartDox.*           FROM PROPATH .
USING Consultingwerk.Util.*                      FROM PROPATH .   
USING Progress.Lang.*                            FROM PROPATH .


CLASS Consultingwerk.Studio.ClassDocumentation.DocumentationWriter:

    { Consultingwerk/Studio/ClassDocumentation/dsClassDocumentation.i }
    { Consultingwerk/Studio/ClassDocumentation/eParameterComment.i }
    { Consultingwerk/Util/TempTables/ttFileNames.i }

    DEFINE VARIABLE oParser AS ClassDocumentationParser NO-UNDO . 
    
    /*------------------------------------------------------------------------------
        Purpose: Create a html file for the link overview. 
        Notes:   
        @param poParameter The paramter object contains the targetdir parameter.
        @param lcDocumentListContent The value contains the Links which generated into the html file.  
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID CreateDocumentList (poParameter AS Consultingwerk.Studio.ClassDocumentation.IDocumentWriterParameter,
                                            lcDocumentListContent AS LONGCHAR):
        
        DEFINE VARIABLE lcDocumentListTemplate AS LONGCHAR NO-UNDO.
        
        COPY-LOB FILE SUBSTITUTE (poParameter:TemplateSourceDir + 
                                  "\DocumentList.template":U) TO lcDocumentListTemplate.
        
        ASSIGN lcDocumentListTemplate = REPLACE (lcDocumentListTemplate, "@PAGETITLE@":U, poParameter:DocumentationTitle)
               lcDocumentListTemplate = REPLACE (lcDocumentListTemplate, "@CONTENT@":U, lcDocumentListContent)
               .
       
        COPY-LOB lcDocumentListTemplate TO FILE SUBSTITUTE ("&1\DocumentList.html":U, poParameter:TargetDir).

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Start method which generate the documentation.
        Notes:    
        @param poParamter With the parameter object can you control the output.
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID GenerateDocumentation (poParameter AS Consultingwerk.Studio.ClassDocumentation.IDocumentWriterParameter):
        
        DEFINE VARIABLE lcDocumentListContent      AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE lcDocumentContent          AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE lcDocumentTemplate         AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE lcDocumentDetailsTemplate  AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE cTargetFile                AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cFileName                  AS CHARACTER NO-UNDO.
        
        
        Consultingwerk.Util.FileHelper:GetFileList (poParameter:TargetDir,
                                                   "*.html":U,
                                                   OUTPUT TABLE ttFileNames BY-REFERENCE).
        FOR EACH ttFileNames:
            OS-DELETE VALUE (ttFileNames.FileName).                                 
        END.                                          
        
        EMPTY TEMP-TABLE ttFileNames.
        
        Consultingwerk.Util.FileHelper:GetFileList (poParameter:SourceDir,
                                            "*.xml":U,
                                            OUTPUT TABLE ttFileNames BY-REFERENCE) .

        oParser = NEW ClassDocumentationParser () .
        
        FOR EACH ttFileNames:
            
            DATASET dsClassDocumentation:EMPTY-DATASET ().

            oParser:ParseClassDocumentation (ttFileNames.FileName,
                                             INPUT-OUTPUT DATASET dsClassDocumentation BY-REFERENCE) .

            ASSIGN cFileName      = ENTRY (NUM-ENTRIES (ttFileNames.FileName, "\":U), ttFileNames.FileName, "\":U)
                   cFileName      = SUBSTRING (cFileName, 1, LENGTH (cFileName) - 4)
                   cTargetFile    = SUBSTITUTE ("&2.html":U, poParameter:TargetDir, cFileName)
                   lcDocumentContent = "":U
                   .

            ASSIGN lcDocumentListContent = SUBSTITUTE (lcDocumentListContent +
                                                       GenerateDocumentList (cFileName, cTargetFile, poParameter)).
            
            COPY-LOB FILE SUBSTITUTE ("&1\Document.template":U, poParameter:TemplateSourceDir) TO lcDocumentTemplate.
                     
            ASSIGN lcDocumentTemplate = GenerateMethodOverview (lcDocumentTemplate, poParameter)
                   lcDocumentTemplate = GenerateConstructorOverview (lcDocumentTemplate, poParameter)
                   lcDocumentTemplate = GenerateEventOverview (lcDocumentTemplate, poParameter)
                   lcDocumentTemplate = GeneratePropertyOverview (lcDocumentTemplate, poParameter)
                   lcDocumentTemplate = GenerateInterfaceOverview (lcDocumentTemplate, poParameter)
                   
                   lcDocumentTemplate = GenerateMethodDetails (lcDocumentTemplate, poParameter)
                   lcDocumentTemplate = GenerateConstructorDetails (lcDocumentTemplate, poParameter)
                   lcDocumentTemplate = GenerateEventDetails (lcDocumentTemplate, poParameter)
                   lcDocumentTemplate = GeneratePropertyDetails (lcDocumentTemplate, poParameter)
                   .
            
            
            ASSIGN lcDocumentTemplate = GenerateDocumentHeader (lcDocumentTemplate, poParameter).
                   
            COPY-LOB lcDocumentTemplate TO FILE SUBSTITUTE ("&1\&2":U, poParameter:TargetDir, cTargetFile) .

        END.

        CreateDocumentList (poParameter, lcDocumentListContent).
                                                     
        GenerateIndexFile (poParameter).
                
    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Generate the document header
        Notes:   
        @param plcDocumentTemplate A LONGCHAR, that contains the content which manipulate to do.
        @param poParameter The paramter object contains the targetdir parameter.
        @return A LONGCHAR containes the manipulated content. 
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE LONGCHAR GenerateDocumentHeader (plcDocumentTemplate AS LONGCHAR, 
                                                    poParameter AS Consultingwerk.Studio.ClassDocumentation.IDocumentWriterParameter):
                       
          DEFINE VARIABLE lcClassComment AS LONGCHAR  NO-UNDO.
          
          FIND FIRST eUnit.
            COPY-LOB eUnit.ClassComment TO lcClassComment.

            ASSIGN
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@UNITHEADER@":U, ClassDocumentationHelper:CommentParser (lcClassComment, TABLE eParameterComment BY-REFERENCE))
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@PAGETITLE@":U, poParameter:DocumentationTitle) 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@PACKAGENAME@":U, eUnit.PackageName)
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@CLASSNAME@":U, eUnit.ClassName)
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@INHERITS@":U, GetFullTypeName(eUnit.Inherits))
                .
            
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
        Purpose: Generate the index file
        Notes:   
        @param poParameter poParameter The parameter object contains the targetdir parameter.
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID GenerateIndexFile (poParameter AS Consultingwerk.Studio.ClassDocumentation.IDocumentWriterParameter):
        
        DEFINE VARIABLE lcIndexTemplate AS LONGCHAR  NO-UNDO.
        
        COPY-LOB FILE SUBSTITUTE ("&1\Index.template":U, poParameter:TemplateSourceDir) TO lcIndexTemplate.
        
        ASSIGN lcIndexTemplate = REPLACE (lcIndexTemplate, "@PAGETITLE@":U, poParameter:DocumentationTitle).
        
        COPY-LOB lcIndexTemplate TO FILE SUBSTITUTE ("&1\index.html", poParameter:TargetDir).

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Generate the method names into a html table.
        Notes: It's a overview of all methods in the class.
        @param plcDocumentTemplate A LONGCHAR, that contains the content which manipulate to do. 
        @param poParameter poParameter The parameter object contains the targetdir parameter.
        @return A LONGCHAR containes the manipulated content. 
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE LONGCHAR GenerateMethodOverview (plcDocumentTemplate AS LONGCHAR,
                                                    poParameter         AS Consultingwerk.Studio.ClassDocumentation.IDocumentWriterParameter):
        
        DEFINE VARIABLE lcResult  AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE lcComment AS LONGCHAR  NO-UNDO.
       
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
          
        FOR EACH eMethod:
            COPY-LOB eMethod.MethodComment TO lcComment.
            
            ASSIGN lcResult = lcResult + ReplacePlaceholder (eMethod.MethodName,                /*Name            CHARACTER*/
                                                             lcComment,                         /*Comment         LONGCHAR*/
                                                             eMethod.Signature,                 /*Signatur        CHARACTER*/
                                                             eMethod.Modifier,                  /*Modifier        CHARACTER*/
                                                             eMethod.IsStatic,                  /*IsStatic        LOGICAL*/
                                                             eMethod.ReturnType,                /*ReturnType      CHARACTER*/
                                                             FALSE,                             /*IsAbstract      LOGICAL*/
                                                             "":U,                              /*DelegateName    CHARACTER*/
                                                             "":U,                              /*SetModifier     CHARACTER*/
                                                             "":U,                              /*GetModifier     CHARACTER*/
                                                             "":U,                              /*DataType        CHARACTER*/
                                                             "#":U + eMethod.GUID,              /*GUID            CHARACTER*/
                                                             "DocumentOverview.template":U,     /*TemplateName    CHARACTER*/    
                                                             poParameter).
        END.      
        
        ASSIGN plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@OVERVIEWMETHODS@":U, lcResult). 

        RETURN plcDocumentTemplate.
        
    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Generate the constructor names into a html table.
        Notes: It's a overview of all constructors in the class.  
        @param plcDocumentTemplate A LONGCHAR, that contains the content which manipulate to do. 
        @param poParameter poParameter The parameter object contains the targetdir parameter.
        @return A LONGCHAR containes the manipulated content. 
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE LONGCHAR GenerateConstructorOverview (plcDocumentTemplate AS LONGCHAR,
                                                         poParameter         AS Consultingwerk.Studio.ClassDocumentation.IDocumentWriterParameter):
        
        DEFINE VARIABLE lcResult    AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE lcComment   AS LONGCHAR  NO-UNDO.
            
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
        
        FOR EACH eConstructor:
            COPY-LOB eConstructor.ConstructorComment TO lcComment.
            
            ASSIGN lcResult = lcResult + ReplacePlaceholder ("CONSTRUCTOR":U,                   /*Name            CHARACTER*/
                                                             lcComment,                         /*Comment         LONGCHAR*/
                                                             eConstructor.Signature,            /*Signatur        CHARACTER*/
                                                             eConstructor.Modifier,             /*Modifier        CHARACTER*/
                                                             eConstructor.IsStatic,             /*IsStatic        LOGICAL*/
                                                             "":U,                              /*ReturnType      CHARACTER*/
                                                             FALSE,                             /*IsAbstract      LOGICAL*/
                                                             "":U,                              /*DelegateName    CHARACTER*/
                                                             "":U,                              /*SetModifier     CHARACTER*/
                                                             "":U,                              /*GetModifier     CHARACTER*/
                                                             "":U,                              /*DataType        CHARACTER*/
                                                             "#":U + eConstructor.GUID,         /*GUID            CHARACTER*/
                                                             "DocumentOverview.template":U,     /*TemplateName    CHARACTER*/     
                                                             poParameter).
        END.      
        
        ASSIGN plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@OVERVIEWCONSTRUCTORS@":U, lcResult). 
        
        RETURN plcDocumentTemplate.
        
    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Generate the event names into a html table.
        Notes: It's a overview of all events in the class.
        @param plcDocumentTemplate A LONGCHAR, that contains the content which manipulate to do. 
        @param poParameter poParameter The parameter object contains the targetdir parameter.
        @return A LONGCHAR containes the manipulated content. 
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE LONGCHAR GenerateEventOverview (plcDocumentTemplate AS LONGCHAR,
                                                   poParameter         AS Consultingwerk.Studio.ClassDocumentation.IDocumentWriterParameter):
        
        DEFINE VARIABLE lcResult    AS LONGCHAR  NO-UNDO INIT "":U.
        DEFINE VARIABLE lcComment   AS LONGCHAR  NO-UNDO.
        
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
        
        FOR EACH eEvent:
            COPY-LOB eEvent.EventComment TO lcComment.

            ASSIGN lcResult = lcResult + ReplacePlaceholder (eEvent.EventName,                  /*Name            CHARACTER*/
                                                             lcComment,                         /*Comment         LONGCHAR*/
                                                             eEvent.Signature,                  /*Signatur        CHARACTER*/
                                                             eEvent.Modifier,                   /*Modifier        CHARACTER*/
                                                             eEvent.IsStatic,                   /*IsStatic        LOGICAL*/
                                                             "":U,                              /*ReturnType      CHARACTER*/
                                                             eEvent.IsAbstract,                 /*IsAbstract      LOGICAL*/
                                                             eEvent.DelegateName,               /*DelegateName    CHARACTER*/
                                                             "":U,                              /*SetModifier     CHARACTER*/
                                                             "":U,                              /*GetModifier     CHARACTER*/
                                                             "":U,                              /*DataType        CHARACTER*/
                                                             "#":U + eEvent.GUID,               /*GUID            CHARACTER*/
                                                             "DocumentOverview.template":U,     /*TemplateName    CHARACTER*/     
                                                             poParameter).
        END.      
        
        ASSIGN plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@OVERVIEWEVENTS@":U, lcResult). 
        
        RETURN plcDocumentTemplate.
        
    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Generate the property names into a html table.
        Notes: It's a overview of all properties in the class.
        @param plcDocumentTemplate A LONGCHAR, that contains the content which manipulate to do. 
        @param poParameter poParameter The parameter object contains the targetdir parameter.
        @return A LONGCHAR containes the manipulated content. 
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE LONGCHAR GeneratePropertyOverview (plcDocumentTemplate AS LONGCHAR,
                                                      poParameter         AS Consultingwerk.Studio.ClassDocumentation.IDocumentWriterParameter):
        
        DEFINE VARIABLE lcResult    AS LONGCHAR  NO-UNDO INIT "":U.
        DEFINE VARIABLE lcComment   AS LONGCHAR  NO-UNDO.
        
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
        
        FOR EACH eProperty:
            COPY-LOB eProperty.PropertyComment TO lcComment.
            
            ASSIGN lcResult = lcResult + ReplacePlaceholder (eProperty.Name,                    /*Name            CHARACTER*/
                                                             lcComment,                         /*Comment         LONGCHAR*/
                                                             eProperty.Name,                    /*Signatur        CHARACTER*/
                                                             eProperty.Modifier,                /*Modifier        CHARACTER*/
                                                             eProperty.IsStatic,                /*IsStatic        LOGICAL*/
                                                             "":U,                              /*ReturnType      CHARACTER*/
                                                             eProperty.IsAbstract,              /*IsAbstract      LOGICAL*/
                                                             "":U,                              /*DelegateName    CHARACTER*/
                                                             eProperty.SetModifier,             /*SetModifier     CHARACTER*/
                                                             eProperty.GetModifier,             /*GetModifier     CHARACTER*/
                                                             eProperty.DataType,                /*DataType        CHARACTER*/
                                                             "#" + eProperty.GUID,              /*GUID            CHARACTER*/
                                                             "DocumentOverview.template":U,     /*TemplateName    CHARACTER*/     
                                                             poParameter).
        END.      
        
        ASSIGN plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@OVERVIEWPROPERTIES@":U, lcResult). 

        RETURN plcDocumentTemplate.
        
        
    END METHOD .
    
     /*------------------------------------------------------------------------------
        Purpose: Generate the interface names into a html table.
        Notes: It's a overview of all interfaces in the class.
        @param plcDocumentTemplate A LONGCHAR, that contains the content which manipulate to do. 
        @param poParameter poParameter The parameter object contains the targetdir parameter.
        @return A LONGCHAR containes the manipulated content. 
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE LONGCHAR GenerateInterfaceOverview (plcDocumentTemplate AS LONGCHAR,
                                                       poParameter         AS Consultingwerk.Studio.ClassDocumentation.IDocumentWriterParameter):
        
        DEFINE VARIABLE lcResult    AS LONGCHAR  NO-UNDO INIT "":U.
        DEFINE VARIABLE lcComment   AS LONGCHAR  NO-UNDO.
        
        IF NOT CAN-FIND (FIRST eInterfaces) THEN DO:
            ASSIGN 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@INTERFACECOMMENTTAGOPEN@":U, "<!--":U) 
                plcDocumentTemplate = REPLACE(plcDocumentTemplate, "@INTERFACECOMMENTTAGCLOSE@":U, "-->":U)
                .         
        END.
        ELSE
            ASSIGN 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@INTERFACECOMMENTTAGOPEN@":U, "":U) 
                plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@INTERFACECOMMENTTAGCLOSE@":U, "":U)
                .  

        FOR EACH eInterfaces:

            ASSIGN lcResult = lcResult + ReplacePlaceholder (eInterfaces.InterfaceName,                                             /*Name            CHARACTER*/
                                                             "":U,                                                                  /*Comment         LONGCHAR*/
                                                             eInterfaces.InterfaceName,                                             /*Signatur        CHARACTER*/
                                                             "":U,                                                                  /*Modifier        CHARACTER*/
                                                             FALSE,                                                                 /*IsStatic        LOGICAL*/
                                                             "":U,                                                                  /*ReturnType      CHARACTER*/
                                                             FALSE,                                                                 /*IsAbstract      LOGICAL*/
                                                             "":U,                                                                  /*DelegateName    CHARACTER*/
                                                             "":U,                                                                  /*SetModifier     CHARACTER*/
                                                             "":U,                                                                  /*GetModifier     CHARACTER*/
                                                             "":U,                                                                  /*DataType        CHARACTER*/
                                                             THIS-OBJECT:GetFullTypeName (eInterfaces.InterfaceName) + ".html":U,   /*GUID            CHARACTER*/
                                                             "DocumentOverview.template":U,                                         /*TemplateName    CHARACTER*/     
                                                             poParameter).
        END.
        
        ASSIGN plcDocumentTemplate = REPLACE(plcDocumentTemplate, "@OVERVIEWINTERFACES@":U, lcResult).
        
        RETURN plcDocumentTemplate.
        
    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Generate the methods details into a html table.
        Notes: It's a view how you can see all parameters and descriptions from a Method.
        @param plcDocumentTemplate A LONGCHAR, that contains the content which manipulate to do. 
        @param poParameter poParameter The parameter object contains the targetdir parameter.
        @return A LONGCHAR containes the manipulated content. 
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE LONGCHAR GenerateMethodDetails (plcDocumentTemplate AS LONGCHAR,
                                                   poParameter         AS Consultingwerk.Studio.ClassDocumentation.IDocumentWriterParameter):
        
        DEFINE VARIABLE lcResult    AS LONGCHAR  NO-UNDO INIT "":U.
        DEFINE VARIABLE lcComment   AS LONGCHAR  NO-UNDO.
        

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
        
        FOR EACH eMethod:
            COPY-LOB eMethod.MethodComment TO lcComment.
            
            ASSIGN lcResult = lcResult + ReplacePlaceholder (eMethod.MethodName,                /*Name            CHARACTER*/
                                                             lcComment,                         /*Comment         LONGCHAR*/
                                                             eMethod.Signature,                 /*Signatur        CHARACTER*/
                                                             eMethod.Modifier,                  /*Modifier        CHARACTER*/
                                                             eMethod.IsStatic,                  /*IsStatic        LOGICAL*/
                                                             eMethod.ReturnType,                /*ReturnType      CHARACTER*/
                                                             FALSE,                             /*IsAbstract      LOGICAL*/
                                                             "":U,                              /*DelegateName    CHARACTER*/
                                                             "":U,                              /*SetModifier     CHARACTER*/
                                                             "":U,                              /*GetModifier     CHARACTER*/
                                                             "":U,                              /*DataType        CHARACTER*/
                                                             eMethod.GUID,                      /*GUID            CHARACTER*/
                                                             "DocumentDetails.template":U,      /*TemplateName    CHARACTER*/     
                                                             poParameter).
        END.     

        ASSIGN plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@DETAILMETHODS@":U, lcResult). 
 
        RETURN plcDocumentTemplate.
        
    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Generate the methods details into a html table.
        Notes: It's a view how you can see all parameters and descriptions from a Method.
        @param plcDocumentTemplate A LONGCHAR, that contains the content which manipulate to do. 
        @param poParameter poParameter The parameter object contains the targetdir parameter.
        @return A LONGCHAR containes the manipulated content. 
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE LONGCHAR GenerateConstructorDetails (plcDocumentTemplate AS LONGCHAR,
                                                        poParameter         AS Consultingwerk.Studio.ClassDocumentation.IDocumentWriterParameter):
        
        DEFINE VARIABLE lcResult    AS LONGCHAR  NO-UNDO INIT "":U.
        DEFINE VARIABLE lcComment   AS LONGCHAR  NO-UNDO.
        
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
        
        FOR EACH eConstructor:
            COPY-LOB eConstructor.ConstructorComment TO lcComment.
            
            ASSIGN lcResult = lcResult + ReplacePlaceholder ("CONSTRUCTOR":U,                   /*Name            CHARACTER*/
                                                             lcComment,                         /*Comment         LONGCHAR*/
                                                             eConstructor.Signature,            /*Signatur        CHARACTER*/
                                                             eConstructor.Modifier,             /*Modifier        CHARACTER*/
                                                             eConstructor.IsStatic,             /*IsStatic        LOGICAL*/
                                                             "":U,                              /*ReturnType      CHARACTER*/
                                                             FALSE,                             /*IsAbstract      LOGICAL*/
                                                             "":U,                              /*DelegateName    CHARACTER*/
                                                             "":U,                              /*SetModifier     CHARACTER*/
                                                             "":U,                              /*GetModifier     CHARACTER*/
                                                             "":U,                              /*DataType        CHARACTER*/
                                                             eConstructor.GUID,                 /*GUID            CHARACTER*/
                                                             "DocumentDetails.template":U,     /*TemplateName    CHARACTER*/     
                                                             poParameter).
        END.      
        
        ASSIGN plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@DETAILCONSTRUCTORS@":U, lcResult). 
        
        RETURN plcDocumentTemplate.
        
    END METHOD .
    
     /*------------------------------------------------------------------------------
        Purpose: Generate the events details into a html table.
        Notes: It's a view how you can see all parameters and descriptions from an event.
        @param plcDocumentTemplate A LONGCHAR, that contains the content which manipulate to do. 
        @param poParameter poParameter The parameter object contains the targetdir parameter.
        @return A LONGCHAR containes the manipulated content. 
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE LONGCHAR GenerateEventDetails (plcDocumentTemplate AS LONGCHAR,
                                                   poParameter         AS Consultingwerk.Studio.ClassDocumentation.IDocumentWriterParameter):
        
        DEFINE VARIABLE lcResult    AS LONGCHAR  NO-UNDO INIT "":U.
        DEFINE VARIABLE lcComment   AS LONGCHAR  NO-UNDO.
        
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
        
        FOR EACH eEvent:
            COPY-LOB eEvent.EventComment TO lcComment.
            
            ASSIGN lcResult = lcResult + ReplacePlaceholder (eEvent.EventName,                  /*Name            CHARACTER*/
                                                             lcComment,                         /*Comment         LONGCHAR*/
                                                             eEvent.Signature,                  /*Signatur        CHARACTER*/
                                                             eEvent.Modifier,                   /*Modifier        CHARACTER*/
                                                             eEvent.IsStatic,                   /*IsStatic        LOGICAL*/
                                                             "":U,                              /*ReturnType      CHARACTER*/
                                                             eEvent.IsAbstract,                 /*IsAbstract      LOGICAL*/
                                                             eEvent.DelegateName,               /*DelegateName    CHARACTER*/
                                                             "":U,                              /*SetModifier     CHARACTER*/
                                                             "":U,                              /*GetModifier     CHARACTER*/
                                                             "":U,                              /*DataType        CHARACTER*/
                                                             eEvent.GUID,                       /*GUID            CHARACTER*/
                                                             "DocumentDetails.template":U,     /*TemplateName    CHARACTER*/     
                                                             poParameter).
        END.      
        
        ASSIGN plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@DETAILEVENTS@":U, lcResult). 
        
        RETURN plcDocumentTemplate.
        
    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Generate the properties details into a html table.
        Notes: It's a view how you can see all parameters and descriptions from a properties.
        @param plcDocumentTemplate A LONGCHAR, that contains the content which manipulate to do. 
        @param poParameter poParameter The parameter object contains the targetdir parameter.
        @return A LONGCHAR containes the manipulated content. 
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE LONGCHAR GeneratePropertyDetails (plcDocumentTemplate AS LONGCHAR,
                                                     poParameter         AS Consultingwerk.Studio.ClassDocumentation.IDocumentWriterParameter):
        
        DEFINE VARIABLE lcResult             AS LONGCHAR  NO-UNDO INIT "":U.
        DEFINE VARIABLE lcComment            AS LONGCHAR  NO-UNDO.
        
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
        
        FOR EACH eProperty:
            COPY-LOB eProperty.PropertyComment TO lcComment.

            ASSIGN lcResult = lcResult + ReplacePlaceholder (eProperty.Name,                    /*Name            CHARACTER*/
                                                             lcComment,                         /*Comment         LONGCHAR*/
                                                             eProperty.Name,                    /*Signatur        CHARACTER*/
                                                             eProperty.Modifier,                /*Modifier        CHARACTER*/
                                                             eProperty.IsStatic,                /*IsStatic        LOGICAL*/
                                                             "":U,                              /*ReturnType      CHARACTER*/
                                                             eProperty.IsAbstract,              /*IsAbstract      LOGICAL*/
                                                             "":U,                              /*DelegateName    CHARACTER*/
                                                             eProperty.SetModifier,             /*SetModifier     CHARACTER*/
                                                             eProperty.GetModifier,             /*GetModifier     CHARACTER*/
                                                             eProperty.DataType,                /*DataType        CHARACTER*/
                                                             eProperty.GUID,                    /*GUID            CHARACTER*/
                                                             "DocumentDetails.template":U,     /*TemplateName    CHARACTER*/     
                                                             poParameter).
        END.      
        
        ASSIGN plcDocumentTemplate = REPLACE (plcDocumentTemplate, "@DETAILPROPERTIES@":U, lcResult). 
        
        RETURN plcDocumentTemplate.
        
    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Get the fulltypename from a typename.
        Notes:   
        @param pcTypeName The typename value. 
        @return A LONGCHAR, return the fulltypename
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER GetFullTypeName (pcTypeName AS CHARACTER):
        
        RETURN ClassDocumentationHelper:GetFullTypeName (pcTypeName, TABLE eUsing BY-REFERENCE).
        
    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Replace the Placeholders in a LONGCHAR value 
        Notes:   
        @param pcName The CHARACTER value replace the keyword "@NAME@"
        @param plcComment The LONGCHAR value replace the keyword "@COMMENT@"
        @param pcModifier The CHARACTER value replace the keyword "@MODIFIER@"
        @param plIsStatic The LOGICAL value replace the keyword "@ISSTATIC@"
        @param pcReturnType The CHARACTER value replace the keyword "@RETURNTYPE@"
        @param plIsAbstract The LOGICAL value replace the keyword "@ISABSTRACT@"
        @param pcDelegateName The CHARACTER value replace the keyword "@DELEGATENAME@"
        @param pcSetModifier The CHARACTER value replace the keyword "@SETMODIFIER@"
        @param pcGetModifier The CHARACTER value replace the keyword "@GETMODIFIER@"
        @param pcDataType The CHARACTER value replace the keyword "@DATATYPE@"
        @param pcGuid The CHARACTER value replace the keyword "@GUID@"
        @param pcTemplateName The template name which be loaded and manipulated. 
        @param poParameter The parameter object.
        @return Return the manipulated template
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE LONGCHAR ReplacePlaceholder (pcName          AS CHARACTER, 
                                                plcComment      AS LONGCHAR,
                                                pcSignature     AS CHARACTER,
                                                pcModifier      AS CHARACTER,
                                                plIsStatic      AS LOGICAL,
                                                pcReturnType    AS CHARACTER,
                                                plIsAbstract    AS LOGICAL,
                                                pcDelegateName  AS CHARACTER,
                                                pcSetModifier   AS CHARACTER,
                                                pcGetModifier   AS CHARACTER,
                                                pcDataType      AS CHARACTER,
                                                pcGuid          AS CHARACTER,
                                                pcTemplateName  AS CHARACTER,
                                                poParameter     AS Consultingwerk.Studio.ClassDocumentation.IDocumentWriterParameter):
        
        DEFINE VARIABLE lcDocumentTemplate          AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE cResult                     AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE cParameterResult            AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE cParameter                  AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lcComment                   AS LONGCHAR  NO-UNDO.
   
        IF NOT DataTypeHelper:IsAblDataType (pcDataType) AND pcDataType <> "":U THEN 
            ASSIGN pcDataType =  THIS-OBJECT:GetFullTypeName (pcDataType).
         
        IF NOT DataTypeHelper:IsAblDataType (pcReturnType) AND pcReturnType <> "":U THEN 
            ASSIGN pcReturnType = THIS-OBJECT:GetFullTypeName (pcReturnType).       
        
        COPY-LOB FILE SUBSTITUTE ("&1\&2":U,
                                  poParameter:TemplateSourceDir, 
                                  pcTemplateName) TO lcDocumentTemplate.

        ASSIGN cResult = REPLACE (lcDocumentTemplate, "@NAME@":U, pcName)      
               cResult = REPLACE (cResult, "@SIGNATURE@":U, ClassDocumentationHelper:SignatureParser (pcSignature, pcModifier, pcReturnType))
               cResult = REPLACE (cResult, "@SHORTSIGNATURE@":U, ClassDocumentationHelper:ShortSignatureParser (pcSignature, pcReturnType))
               cResult = REPLACE (cResult, "@PURPOSE@":U, ClassDocumentationHelper:GetPurpose (plcComment))
               cResult = REPLACE (cResult, "@COMMENT@":U, ClassDocumentationHelper:CommentParser (plcComment, TABLE eParameterComment BY-REFERENCE))
               cResult = REPLACE (cResult, "@MODIFIER@":U, pcModifier)
               cResult = REPLACE (cResult, "@SHORTMODIFIER@":U, ClassDocumentationHelper:GetShortModifier (pcModifier))
               cResult = REPLACE (cResult, "@ISSTATIC@":U, STRING (plIsStatic))
               cResult = REPLACE (cResult, "@RETURNTYPE@":U, pcReturnType)
               cResult = REPLACE (cResult, "@ISABSTRACT@":U, STRING (plIsAbstract))
               cResult = REPLACE (cResult, "@DELEGATENAME@":U, pcDelegateName)
               cResult = REPLACE (cResult, "@SETMODIFIER@":U, pcSetModifier)
               cResult = REPLACE (cResult, "@GETMODIFIER@":U, pcGetModifier)
               cResult = REPLACE (cResult, "@DATATYPE@":U, pcDataType)
               cResult = REPLACE (cResult, "@GUID@":U, pcGuid)
               .
                           
        FOR EACH eParameter WHERE eParameter.ParentGUID = pcGuid:
            
            COPY-LOB FILE SUBSTITUTE ("&1\DocumentDetailsParameter.template":U,
                                      poParameter:TemplateSourceDir) TO cParameterResult.
                 
            ASSIGN cParameterResult = REPLACE (cParameterResult, "@PARAMETERSEQUENCE@":U, STRING (eParameter.Sequence))
                   cParameterResult = REPLACE (cParameterResult, "@PARAMETERNAME@":U, STRING (eParameter.Name))
                   cParameterResult = REPLACE (cParameterResult, "@PARAMETERDATATYPE@":U, STRING (eParameter.DataType))
                   cParameterResult = REPLACE (cParameterResult, "@PARAMETERPOSITION@":U, STRING (eParameter.Position))
                   cParameterResult = REPLACE (cParameterResult, "@PARAMETERMODE@":U, STRING (eParameter.Mode))
                   .
            
            ASSIGN FILE-INFO:FILENAME = SUBSTITUTE ("&1\&2.xml", poParameter:SourceDir, THIS-OBJECT:GetFullTypeName (eParameter.DataType)).
                        
            IF FILE-INFO:FULL-PATHNAME = ? THEN
                ASSIGN cParameterResult = REPLACE (cParameterResult, "@PARAMETERFULLDATATYPE@":U, THIS-OBJECT:GetFullTypeName (eParameter.DataType)).
            ELSE 
                ASSIGN cParameterResult = REPLACE (cParameterResult, "@PARAMETERFULLDATATYPE@":U, SUBSTITUTE ("<a href='&1.html'>&1<a>", THIS-OBJECT:GetFullTypeName (eParameter.DataType))).
                
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

        COPY-LOB FILE SUBSTITUTE ("&1\DocumentDetailsParameter.template":U,
                                  poParameter:TemplateSourceDir) TO cParameterResult.
        
        IF NOT pcReturnType = "":U THEN DO:
            
            ASSIGN cParameter = cParameter + REPLACE (cParameterResult, "@PARAMETERMODE@":U, "RETURN":U)
                   cParameter = REPLACE (cParameter, "@PARAMETERNAME@":U, "<b>Return</b>")
                   cParameter = REPLACE (cParameter, "@PARAMETERFULLDATATYPE@":U, pcReturnType)
                   .

            FIND eParameterComment WHERE eParameterComment.Name = "@RETURN":U NO-ERROR.

            IF AVAILABLE eParameterComment THEN DO:
                COPY-LOB eParameterComment.Comment TO lcComment.
                ASSIGN cParameter = REPLACE (cParameter, "@PARAMETERCOMMENT@":U, lcComment).
            END.
            ELSE
                ASSIGN cParameter = REPLACE (cParameter, "@PARAMETERCOMMENT@":U, "":U).
        
        END. 

        cResult = (REPLACE(cResult, "@PARAMETERS@":U, cParameter)).

        RETURN cResult.

    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Generate the document list
        Notes: The List is a overview of all classes.  
        @param pcClass A CHRACTER value which show a link caption.
        @param pcHref A CHARCTER link value to the html class reference
        @param The parameter object.
        @return Return the generated html LONGCHAR
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE LONGCHAR GenerateDocumentList (pcClass     AS CHARACTER, 
                                                  pcHref      AS CHARACTER,
                                                  poParameter AS Consultingwerk.Studio.ClassDocumentation.IDocumentWriterParameter):
        
        DEFINE VARIABLE lcDocumentItemTemplate       AS LONGCHAR  NO-UNDO.
        DEFINE VARIABLE cResult                      AS LONGCHAR NO-UNDO.
        
        COPY-LOB FILE SUBSTITUTE ("&1\DocumentListItem.template":U, poParameter:TemplateSourceDir) TO lcDocumentItemTemplate.
                                            
        ASSIGN cResult = SUBSTITUTE (REPLACE (lcDocumentItemTemplate, "@CLASSNAME@":U, pcClass))
               cResult = SUBSTITUTE (REPLACE (cResult, "@HREF@":U, pcHref)).
               
        RETURN cResult.
       
    END METHOD .

END CLASS.
