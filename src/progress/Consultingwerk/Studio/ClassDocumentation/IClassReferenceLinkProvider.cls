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
    File        : IClassLinkProvider
    Purpose     : Provides hyperlinks to related class references
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Mon Feb 04 18:10:02 CET 2013
    Notes       : 
  ----------------------------------------------------------------------*/

USING Consultingwerk.Studio.ClassDocumentation.* FROM PROPATH .  
USING Progress.Lang.*                            FROM PROPATH .

INTERFACE Consultingwerk.Studio.ClassDocumentation.IClassReferenceLinkProvider:  
  
    /*------------------------------------------------------------------------------
        Purpose: Provides customizable functionaltity to return hyperlinks to 
                 the class reference for a specific class 
        Notes:   May result in a link to MSDN, the Infragistics reference, etc.
                 When this methods returns a link, it is expected that the link will 
                 be opened in a new browser window
        @param pcClassName The name of the class to provide a hyperlink for 
        @return The hyperlink to the class reference page or ? when the class is part of the SmartDox generated ABL class reference  
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC CHARACTER GetClassReferenceLink (pcClassName AS CHARACTER).

END INTERFACE.