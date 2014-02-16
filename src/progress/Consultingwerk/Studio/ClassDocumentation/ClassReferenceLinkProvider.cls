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
    File        : ClassReferenceLinkProvider
    Purpose     : Provides hyperlinks to related class references
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Mon Feb 04 18:14:52 CET 2013
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Studio.ClassDocumentation.* FROM PROPATH .  
USING Progress.Lang.*                            FROM PROPATH .

CLASS Consultingwerk.Studio.ClassDocumentation.ClassReferenceLinkProvider 
    IMPLEMENTS IClassReferenceLinkProvider: 

    /*------------------------------------------------------------------------------
        Purpose: Provides customizable functionaltity to return hyperlinks to 
                 the class reference for a specific class 
        Notes:   May result in a link to MSDN, the Infragistics reference, etc.
                 When this methods returns a link, it is expected that the link will 
                 be opened in a new browser window
        @param pcClassName The name of the class to provide a hyperlink for 
        @return The hyperlink to the class reference page or ? when the class is part of the SmartDox generated ABL class reference  
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER GetClassReferenceLink (pcClassName AS CHARACTER):

        DEFINE VARIABLE cAssembly AS CHARACTER NO-UNDO.
        
        /* Mike Fechner, Consultingwerk Ltd. 14.03.2013
           Remove array indicators when creating link to .NET class reference */
        IF pcClassName BEGINS "System.":U OR pcClassName BEGINS "Infragistics.":U THEN 
            ASSIGN pcClassName = REPLACE (pcClassName, "[]":U, "":U) .
		
		/* Microsoft MSDN */
		IF pcClassName BEGINS "System.":U THEN 
		    RETURN SUBSTITUTE ("http://msdn.microsoft.com/en-us/library/&1(v=vs.80).aspx":U,
		                       LC (pcClassName)) . 
		
		/* Infragistics .NET Controls */
		IF pcClassName BEGINS "Infragistics.":U THEN DO:
		    IF NUM-ENTRIES (pcClassName, ".":U) > 3 THEN 
		        ASSIGN cAssembly = ENTRY (3, pcClassName, ".":U) + ".":U . 

            /* note: double tilde to return tilde */
            RETURN SUBSTITUTE ("http://help.infragistics.com/Doc/WinForms/2013.1/CLR4.0/?page=Infragistics4.Win.&1v13.1~~&2.html":U,
                               cAssembly,
                               pcClassName) .
		END.
		
		RETURN ? .

	END METHOD .

END CLASS.
