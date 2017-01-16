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
    File        : ExtendedClassReferenceLinkProvider
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Thu Feb 14 19:41:49 CET 2013
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Studio.ClassDocumentation.* FROM PROPATH .
USING Consultingwerk.Studio.SmartDox.*           FROM PROPATH . 
USING Progress.Lang.*                            FROM PROPATH .

CLASS Consultingwerk.Studio.SmartDox.ExtendedClassReferenceLinkProvider 
    INHERITS ClassReferenceLinkProvider: 
	
	{Consultingwerk/Studio/OpenEdgeDocs/ttClassDocumentation.i}
	
	DEFINE VARIABLE cOpenEdgeBaseLink    AS CHARACTER NO-UNDO.
	DEFINE VARIABLE cOpenEdgeDocFileName AS CHARACTER NO-UNDO.
	
	/*------------------------------------------------------------------------------
		Purpose: Constructor for the ExtendedClassReferenceLinkProvider class 																	  
		Notes:  																	  
	------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC ExtendedClassReferenceLinkProvider ():
		SUPER ().
		
        ASSIGN cOpenEdgeDocFileName = DYNAMIC-FUNCTION("getParameter":U IN ClassDocumentationHelper:PctLibrary, "OpenEdgeDocFileName":U)
               cOpenEdgeBaseLink    = DYNAMIC-FUNCTION("getParameter":U IN ClassDocumentationHelper:PctLibrary, "OpenEdgeBaseLink":U) 
               .                

		IF cOpenEdgeDocFileName > "":U THEN 
		    TEMP-TABLE ttClassDocumentation:READ-XML ("file":U, 
		                                              cOpenEdgeDocFileName,
		                                              "empty":U,
		                                              ?,
		                                              ?) .

	END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Provides customizable functionaltity to return hyperlinks to 
                 the class reference for a specific class 
        Notes:   May result in a link to MSDN, the Infragistics reference, etc.
                 When this methods returns a link, it is expected that the link will 
                 be opened in a new browser window
        @param pcClassName The name of the class to provide a hyperlink for 
        @return The hyperlink to the class reference page or ? when the class is part of the SmartDox generated ABL class reference  
    ------------------------------------------------------------------------------*/
	METHOD OVERRIDE PUBLIC CHARACTER GetClassReferenceLink (pcClassName AS CHARACTER):
		
		DEFINE VARIABLE lcLink AS CHARACTER NO-UNDO.
		
		ASSIGN lcLink = SUPER:GetClassReferenceLink (pcClassName).

        IF lcLink > "":U THEN   
            RETURN lcLink . 

        IF pcClassName BEGINS "Progress.":U THEN DO:
            
            FIND ttClassDocumentation WHERE ttClassDocumentation.ClassName = pcClassName NO-ERROR . 
            
            IF AVAILABLE ttClassDocumentation THEN 
                RETURN SUBSTITUTE ("&1&2":U,
                                   cOpenEdgeBaseLink,
                                   ttClassDocumentation.FileName) .
        END.
        ELSE IF pcClassName BEGINS "com.joanju.":U OR 
                pcClassName BEGINS "org.prorefactor.":U THEN 
                
            RETURN SUBSTITUTE ("http://www.joanju.com/analyst/javadoc/index.html?&1.html":U,
                               REPLACE (pcClassName, ".":U, "/":U)) .

        RETURN ? . 

	END METHOD.

END CLASS.
