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
    File        : DocumentWriterParameters
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Sebastian Düngel / Consultingwerk Ltd.
    Created     : Wed Oct 10 23:03:08 CEST 2012
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Studio.ClassDocumentation.* FROM PROPATH .  
USING Progress.Lang.*                            FROM PROPATH .

CLASS Consultingwerk.Studio.ClassDocumentation.DocumentWriterParameter 
    IMPLEMENTS IDocumentWriterParameter:
        
    /*------------------------------------------------------------------------------
        Purpose: Proprty flags set the document title of the HTML-Files.
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY DocumentationTitle AS CHARACTER NO-UNDO 
    GET.
    SET. 

    /*------------------------------------------------------------------------------
        Purpose: Property flags set the source directory, where the HTML-Files are generated.
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY SourceDir AS CHARACTER NO-UNDO 
    GET.
    SET. 

    /*------------------------------------------------------------------------------
        Purpose: Property flags set the targetdirectory, which the XML-files to use. 
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY TargetDir AS CHARACTER NO-UNDO 
    GET.
    SET.
    
    /*------------------------------------------------------------------------------
        Purpose: Property flags set the sourcedirectory, which describe the HTML layout.  
        Notes:   Detail.template, Index.template, Menu.template
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY TemplateSourceDir AS CHARACTER NO-UNDO 
    GET.
    SET.

    /*------------------------------------------------------------------------------
        Purpose: Gets and sets the name of the resource directory, which contains image- and js-files.  
        Notes:
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY ResourceDir AS CHARACTER NO-UNDO 
    GET.
    SET.
    
    /*------------------------------------------------------------------------------
        Purpose: Property flag sets and gets how generate the documentlist.
        Notes:
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY GenerateTreeViewOverview AS LOGICAL NO-UNDO 
    GET.
    SET.

END CLASS.
