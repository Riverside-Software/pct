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
    File        : Consultingwerk/Studio/generate-class-reference.p
    Purpose     : Executes the ClassDocumentationWriter to generate 
                  html class reference documentation  

    Syntax      : Parameters passed using <Parameter name="" value="" /> 
                  properties of the ANT/PCT PCTRun task:
                      
                  <Parameter name="TargetDir" value="html"/>
                  <Parameter name="SourceDir" value="classdoc"/>
                  <Parameter name="TemplateSourceDir" value="Consultingwerk/Studio/ClassDocumentation/Templates"/>

    Description : 

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Mon Dec 17 13:35:22 UTC 2012
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE oParser AS Consultingwerk.Studio.ClassDocumentation.DocumentationWriter NO-UNDO . 

{ Consultingwerk/Studio/ClassDocumentation/dsClassDocumentation.i }
{ Consultingwerk/Util/TempTables/ttFileNames.i }

DEFINE VARIABLE oDoc               AS Consultingwerk.Studio.ClassDocumentation.DocumentationWriter      NO-UNDO.
DEFINE VARIABLE oParamter          AS Consultingwerk.Studio.ClassDocumentation.IDocumentWriterParameter NO-UNDO.

DEFINE VARIABLE cTargetDir         AS CHARACTER                                                         NO-UNDO.
DEFINE VARIABLE cSourceDir         AS CHARACTER                                                         NO-UNDO.
DEFINE VARIABLE cTemplateSourceDir AS CHARACTER                                                         NO-UNDO.

/* ***************************  Main Block  *************************** */

ASSIGN cTargetDir         = DYNAMIC-FUNCTION("getParameter":U IN SOURCE-PROCEDURE, INPUT "TargetDir")
       cSourceDir         = DYNAMIC-FUNCTION("getParameter":U IN SOURCE-PROCEDURE, INPUT "SourceDir")
       cTemplateSourceDir = DYNAMIC-FUNCTION("getParameter":U IN SOURCE-PROCEDURE, INPUT "TemplateSourceDir") .

oParamter = NEW Consultingwerk.Studio.ClassDocumentation.DocumentWriterParameter ().

ASSIGN oParamter:DocumentationTitle  = "SmartComponent Library" .

FILE-INFO:FILE-NAME = cTargetDir .
IF FILE-INFO:FULL-PATHNAME > "":U THEN 
    ASSIGN oParamter:TargetDir = FILE-INFO:FULL-PATHNAME .
ELSE 
    UNDO, THROW NEW Consultingwerk.Exceptions.InvalidParameterValueException ("TargetDir":U, 
                                                                              cTargetDir,
                                                                              "Consultingwerk.Studio.ClassDocumentation.DocumentWriterParameter":U) .

FILE-INFO:FILE-NAME = cSourceDir .
IF FILE-INFO:FULL-PATHNAME > "":U THEN 
    ASSIGN oParamter:SourceDir = FILE-INFO:FULL-PATHNAME .
ELSE 
    UNDO, THROW NEW Consultingwerk.Exceptions.InvalidParameterValueException ("SourceDir":U, 
                                                                              cSourceDir,
                                                                              "Consultingwerk.Studio.ClassDocumentation.DocumentWriterParameter":U) .

FILE-INFO:FILE-NAME = cTemplateSourceDir .
IF FILE-INFO:FULL-PATHNAME > "":U THEN 
    ASSIGN oParamter:TemplateSourceDir = FILE-INFO:FULL-PATHNAME .
ELSE 
    UNDO, THROW NEW Consultingwerk.Exceptions.InvalidParameterValueException ("TemplateSourceDir":U, 
                                                                              cTemplateSourceDir,
                                                                              "Consultingwerk.Studio.ClassDocumentation.DocumentWriterParameter":U) .

oDoc = NEW Consultingwerk.Studio.ClassDocumentation.DocumentationWriter ().
oDoc:GenerateDocumentation (oParamter).

RETURN "0":U . 
