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
    File        : ClassReference
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Sebastian Düngel / Consultingwerk Ltd.
    Created     : Fri Oct 12 18:28:26 CEST 2012
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Studio.ClassDocumentation.* FROM PROPATH .
USING Consultingwerk.Studio.SmartDox.*           FROM PROPATH .
USING Consultingwerk.Util.*                      FROM PROPATH . 
USING Progress.Lang.*                            FROM PROPATH .

CLASS Consultingwerk.Studio.SmartDox.ClassReferenceWriter: 
    
    { Consultingwerk/Studio/ClassDocumentation/dsClassDocumentation.i }
    { Consultingwerk/Studio/ClassDocumentation/eParameterComment.i}
    { Consultingwerk/Util/TempTables/ttFileNames.i }
    
    DEFINE VARIABLE oParser    AS ClassDocumentationParser NO-UNDO . 
    DEFINE VARIABLE hSAXWriter AS HANDLE                   NO-UNDO .
    
    /*------------------------------------------------------------------------------
        Purpose: Gets and sets if verbose messages should be generated 
        Notes:   
    ------------------------------------------------------------------------------*/
	DEFINE PUBLIC PROPERTY Verbose AS LOGICAL INITIAL FALSE NO-UNDO 
	GET.
	SET. 

    /*------------------------------------------------------------------------------
        Purpose: Generates the xml class reference file for OEA.
        Notes:   
        @param poParameter The ISmartDoxParameter instance with the arguments for that routine
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC VOID GenerateClassReference (poParameter AS ISmartDoxParameter):

        DEFINE VARIABLE lok         AS LOGICAL  NO-UNDO.
        DEFINE VARIABLE lcComment   AS LONGCHAR NO-UNDO.  

        IF THIS-OBJECT:Verbose THEN 
            MESSAGE "[ClassReferenceWriter] Getting list of files":U  .
		
		Consultingwerk.Util.FileHelper:GetFileList (poParameter:SourceDir,
                                                    "*.xml":U,
                                                    OUTPUT TABLE ttFileNames BY-REFERENCE) .

        IF THIS-OBJECT:Verbose THEN 
            MESSAGE "[ClassReferenceWriter] Done":U  .
        
        CREATE SAX-WRITER hSAXWriter.
        hSAXWriter:FORMATTED = TRUE.

        lok = hSAXWriter:SET-OUTPUT-DESTINATION ("file":U, poParameter:TargetFile).

        oParser = NEW ClassDocumentationParser () .
        
        lOK = hSAXWriter:START-DOCUMENT ().
        
        hSAXWriter:START-ELEMENT ("root":U).
        hSAXWriter:START-ELEMENT ("elements":U).
        
        THIS-OBJECT:GenerateHeader ().
        
        FOR EACH ttFileNames:
            IF THIS-OBJECT:Verbose THEN 
                MESSAGE "[ClassReferenceWriter]":U ttFileNames.FileName .
            
            oParser:ParseClassDocumentation (ttFileNames.FileName,
                                             INPUT-OUTPUT DATASET dsClassDocumentation BY-REFERENCE) .
            FIND FIRST eUnit.
           
            hSAXWriter:START-ELEMENT ("element":U).
            hSAXWriter:INSERT-ATTRIBUTE ("type":U, "class":U).
            hSAXWriter:INSERT-ATTRIBUTE ("name":U, SUBSTITUTE ("&1.&2":U, eUnit.PackageName, eUnit.ClassName)).
           
            COPY-LOB eUnit.ClassComment TO lcComment.
           
            hSAXWriter:START-ELEMENT ("summary":U).
            
            ASSIGN lcComment = SmartDoxHelper:RemoveCommentLines (lcComment)
                   lcComment  = ClassDocumentationHelper:ReplaceSpecialCharacters (lcComment)
                   lcComment = REPLACE (lcComment, CHR (10), "<br>":U)
                   lcComment = SmartDoxHelper:ReplaceBlank(lcComment)
                   .
            
            hSAXWriter:WRITE-CHARACTERS (lcComment). 
            hSAXWriter:END-ELEMENT ("summary":U).

            hSAXWriter:END-ELEMENT ("element":U).
           
            THIS-OBJECT:GenerateMethods ().
            THIS-OBJECT:GenerateEvents ().
            THIS-OBJECT:GenerateProperties ().
            THIS-OBJECT:GenerateConstructors ().
        END.
        
        hSAXWriter:END-ELEMENT ("elements":U).
        hSAXWriter:END-ELEMENT ("root":U).
     
        lOK = hSAXWriter:END-DOCUMENT ().
        
        FINALLY:
            GarbageCollectorHelper:DeleteObject (hSAXWriter) .        
        END FINALLY.
        
    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Generates the Header Block for the ylass reference xml file
        Notes:   
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID GenerateHeader ():
        
        hSAXWriter:START-ELEMENT ("element":U).
        hSAXWriter:INSERT-ATTRIBUTE ("type":U, "library":U).
        hSAXWriter:INSERT-ATTRIBUTE ("name":U, "ABL":U).
        
        hSAXWriter:START-ELEMENT ("summary":U).
        hSAXWriter:WRITE-CHARACTERS ("SmartComponent Library":U).
        hSAXWriter:END-ELEMENT ("summary":U).
        
        hSAXWriter:END-ELEMENT ("element":U).
        
    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Generates the method member for the class reference xml file
        Notes:   
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID GenerateMethods ():
        
         DEFINE VARIABLE cFullTypeName AS CHARACTER NO-UNDO.
         DEFINE VARIABLE lcSignatur    AS LONGCHAR  NO-UNDO.
         DEFINE VARIABLE lcComment     AS LONGCHAR  NO-UNDO.
         
         FOR EACH eMethod:
             
                COPY-LOB eMethod.MethodComment TO lcComment.
                
                /* Sebastian Düngel, Consultingwerk Ltd. 03.05.2013
                   Only fill the ParamterComment Temptable */
                ClassDocumentationHelper:CommentParser (lcComment, TABLE eParameterComment BY-REFERENCE).
                
                ASSIGN
                    lcSignatur = SmartDoxHelper:SignatureParser (eMethod.Signature, TABLE eUsing)
                    lcComment  = SmartDoxHelper:RemoveCommentLines (lcComment)
                    lcComment  = ClassDocumentationHelper:ReplaceSpecialCharacters (lcComment)
                    lcComment = REPLACE (lcComment, CHR (10), "<br>":U)
                    lcComment  = lcComment + SmartDoxHelper:GenerateParameterComments (TABLE eParameterComment BY-REFERENCE)
                    lcComment  = SmartDoxHelper:ReplaceBlank (lcComment)
                    .
                
                hSAXWriter:START-ELEMENT ("element":U).
                hSAXWriter:INSERT-ATTRIBUTE ("name":U, SUBSTITUTE ("&1.&2.&3":U, eUnit.PackageName, eUnit.ClassName, lcSignatur)).
                hSAXWriter:INSERT-ATTRIBUTE ("type":U, "method":U).
                
                hSAXWriter:START-ELEMENT ("summary":U).
                
                hSAXWriter:WRITE-CHARACTERS (lcComment).
                hSAXWriter:END-ELEMENT ("summary":U).
                hSAXWriter:END-ELEMENT ("element":U).
         END.

    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Generates the property member for the class reference xml file
        Notes:   
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID GenerateProperties ():
        
         DEFINE VARIABLE cFullTypeName AS CHARACTER NO-UNDO.
         DEFINE VARIABLE lcSignatur    AS LONGCHAR  NO-UNDO.
         DEFINE VARIABLE lcComment     AS LONGCHAR  NO-UNDO.
         
         FOR EACH eProperty:
                
                COPY-LOB eProperty.PropertyComment TO lcComment.
                
                /* Sebastian Düngel, Consultingwerk Ltd. 03.05.2013
                   Only fill the ParamterComment Temptable */
                ClassDocumentationHelper:CommentParser (lcComment, TABLE eParameterComment BY-REFERENCE).
                
                ASSIGN
                    lcSignatur = eProperty.Name
                    lcComment  = SmartDoxHelper:RemoveCommentLines (lcComment)
                    lcComment  = ClassDocumentationHelper:ReplaceSpecialCharacters (lcComment)
                    lcComment = REPLACE (lcComment, CHR (10), "<br>":U)
                    lcComment  = lcComment + SmartDoxHelper:GenerateParameterComments (TABLE eParameterComment BY-REFERENCE)
                    lcComment  = SmartDoxHelper:ReplaceBlank (lcComment)
                    .
                
                hSAXWriter:START-ELEMENT ("element":U).
                hSAXWriter:INSERT-ATTRIBUTE ("name":U, SUBSTITUTE ("&1.&2.&3":U, eUnit.PackageName, eUnit.ClassName, lcSignatur)).
                hSAXWriter:INSERT-ATTRIBUTE ("type":U, "property":U).
                
                hSAXWriter:START-ELEMENT ("summary":U).
                
                hSAXWriter:WRITE-CHARACTERS (lcComment).
                hSAXWriter:END-ELEMENT ("summary":U).
                hSAXWriter:END-ELEMENT ("element":U).
                
         END.

    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Generates the event member for the class reference xml file
        Notes:   
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID GenerateEvents ():
        
         DEFINE VARIABLE cFullTypeName AS CHARACTER NO-UNDO.
         DEFINE VARIABLE lcSignatur    AS LONGCHAR  NO-UNDO.
         DEFINE VARIABLE lcComment     AS LONGCHAR  NO-UNDO.
         
         FOR EACH eEvent:
             
                COPY-LOB eEvent.EventComment TO lcComment.
                
                /* Sebastian Düngel, Consultingwerk Ltd. 03.05.2013
                   Only fill the ParamterComment Temptable */
                ClassDocumentationHelper:CommentParser (lcComment, TABLE eParameterComment BY-REFERENCE).
                
                ASSIGN
                    lcSignatur = eEvent.EventName
                    lcComment  = SmartDoxHelper:RemoveCommentLines (lcComment)
                    lcComment  = ClassDocumentationHelper:ReplaceSpecialCharacters (lcComment)
                    lcComment = REPLACE (lcComment, CHR (10), "<br>":U)
                    lcComment  = lcComment + SmartDoxHelper:GenerateParameterComments (TABLE eParameterComment BY-REFERENCE)
                    lcComment  = SmartDoxHelper:ReplaceBlank (lcComment)
 
                    .
                
                hSAXWriter:START-ELEMENT ("element":U).
                hSAXWriter:INSERT-ATTRIBUTE ("name":U, SUBSTITUTE ("&1.&2.&3":U, eUnit.PackageName, eUnit.ClassName, lcSignatur)).
                hSAXWriter:INSERT-ATTRIBUTE ("type":U, "event":U).
                
                hSAXWriter:START-ELEMENT ("summary":U).
                
                hSAXWriter:WRITE-CHARACTERS (lcComment).
                hSAXWriter:END-ELEMENT ("summary":U).
                hSAXWriter:END-ELEMENT ("element":U).
                
         END.

    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Generates the construktor member for the class reference xml file
        Notes:   
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID GenerateConstructors ():
        
         DEFINE VARIABLE cFullTypeName AS CHARACTER NO-UNDO.
         DEFINE VARIABLE lcSignatur    AS LONGCHAR  NO-UNDO.
         DEFINE VARIABLE lcComment     AS LONGCHAR  NO-UNDO.
         
         FOR EACH eConstructor:
             
                COPY-LOB eConstructor.ConstructorComment TO lcComment.
                
                /* Sebastian Düngel, Consultingwerk Ltd. 03.05.2013
                   Only fill the ParamterComment Temptable */
                ClassDocumentationHelper:CommentParser (lcComment, TABLE eParameterComment BY-REFERENCE).
                
                ASSIGN
                    lcSignatur = SmartDoxHelper:SignatureParser (eConstructor.Signature, TABLE eUsing)
                    lcComment  = SmartDoxHelper:RemoveCommentLines (lcComment)
                    lcComment  = ClassDocumentationHelper:ReplaceSpecialCharacters (lcComment)
                    lcComment = REPLACE (lcComment, CHR (10), "<br>":U)
                    lcComment  = lcComment + SmartDoxHelper:GenerateParameterComments (TABLE eParameterComment BY-REFERENCE)
                    lcComment  = SmartDoxHelper:ReplaceBlank (lcComment)
                    .
                
                hSAXWriter:START-ELEMENT ("element":U).
                hSAXWriter:INSERT-ATTRIBUTE ("name":U, SUBSTITUTE ("&1.&2.&3":U, eUnit.PackageName, eUnit.ClassName, lcSignatur)).
                hSAXWriter:INSERT-ATTRIBUTE ("type":U, "method":U).
                
                hSAXWriter:START-ELEMENT ("summary":U).
                
                hSAXWriter:WRITE-CHARACTERS (lcComment).
                hSAXWriter:END-ELEMENT ("summary":U).
                hSAXWriter:END-ELEMENT ("element":U).
                
         END.

    END METHOD .
    
END CLASS.
