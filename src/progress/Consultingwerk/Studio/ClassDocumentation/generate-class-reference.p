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
    File        : Consultingwerk/Studio/ClassDocumentation/generate-class-reference.p
    Purpose     : Executes the ClassDocumentationWriter to generate 
                  html class reference documentation  

    Syntax      : Parameters passed using <Parameter name="" value="" /> 
                  properties of the ANT/PCT PCTRun task:
                      
                  <Parameter name="TargetDir" value="html"/>
                  <Parameter name="SourceDir" value="classdoc"/>
                  <Parameter name="TemplateSourceDir" value="Consultingwerk/Studio/ClassDocumentation/Templates"/>
                  <Parameter name="ResourceDir" value="resources"/>
                  <Parameter name="Services" value="Consultingwerk/Studio/SmartDox/services.xml"/>

    Description : 

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Mon Dec 17 13:35:22 UTC 2012
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Framework.*                 FROM PROPATH . 
USING Consultingwerk.Studio.ClassDocumentation.* FROM PROPATH . 
USING Consultingwerk.Util.*                      FROM PROPATH . 

DEFINE VARIABLE oDoc                         AS Consultingwerk.Studio.ClassDocumentation.DocumentationWriter      NO-UNDO .
DEFINE VARIABLE oParameter                   AS Consultingwerk.Studio.ClassDocumentation.IDocumentWriterParameter NO-UNDO .

DEFINE VARIABLE oServiceLoader               AS ServiceLoader                                                     NO-UNDO .

DEFINE VARIABLE cTargetDir                   AS CHARACTER                                                         NO-UNDO .
DEFINE VARIABLE cSourceDir                   AS CHARACTER                                                         NO-UNDO .
DEFINE VARIABLE cTemplateSourceDir           AS CHARACTER                                                         NO-UNDO .
DEFINE VARIABLE cResourceDir                 AS CHARACTER                                                         NO-UNDO.
DEFINE VARIABLE cServices                    AS CHARACTER                                                         NO-UNDO .
DEFINE VARIABLE cTitle                       AS CHARACTER                                                         NO-UNDO .
DEFINE VARIABLE lPreloadClasses              AS LOGICAL                                                           NO-UNDO .
DEFINE VARIABLE lGenerateTreeViewOverview    AS LOGICAL                                                           NO-UNDO .

DEFINE SHARED VARIABLE pctVerbose AS LOGICAL NO-UNDO.

/* ***************************  Main Block  *************************** */

SESSION:ERROR-STACK-TRACE = TRUE . 

ASSIGN cTargetDir                = DYNAMIC-FUNCTION("getParameter":U IN SOURCE-PROCEDURE, INPUT "TargetDir":U)
       cSourceDir                = DYNAMIC-FUNCTION("getParameter":U IN SOURCE-PROCEDURE, INPUT "SourceDir":U)
       cTemplateSourceDir        = DYNAMIC-FUNCTION("getParameter":U IN SOURCE-PROCEDURE, INPUT "TemplateSourceDir":U) 
       cResourceDir              = DYNAMIC-FUNCTION("getParameter":U IN SOURCE-PROCEDURE, INPUT "ResourceDir":U)
       cServices                 = DYNAMIC-FUNCTION("getParameter":U IN SOURCE-PROCEDURE, INPUT "Services":U)
       lGenerateTreeViewOverview = DYNAMIC-FUNCTION("getParameter":U IN SOURCE-PROCEDURE, INPUT "GenerateTreeViewOverview":U)
       cTitle                    = DYNAMIC-FUNCTION("getParameter":U IN SOURCE-PROCEDURE, INPUT "Title":U)
       lPreloadClasses           = DataTypeHelper:ToLogical (DYNAMIC-FUNCTION("getParameter":U IN SOURCE-PROCEDURE, INPUT "PreloadClasses":U))
       
       ClassDocumentationHelper:PctLibrary = SOURCE-PROCEDURE 
       .

IF pctVerbose THEN MESSAGE "Source Directory:":U cSourceDir.
IF pctVerbose THEN MESSAGE "Target Directory:":U cTargetDir.
IF pctVerbose THEN MESSAGE "Template Source: ":U cTemplateSourceDir. 
IF pctVerbose THEN MESSAGE "Resource Source: ":U cResourceDir. 
IF pctVerbose THEN MESSAGE "Custom Services: ":U cServices. 
IF pctVerbose THEN MESSAGE "GenerateTreeViewOverview: ":U lGenerateTreeViewOverview. 

oParameter = NEW Consultingwerk.Studio.ClassDocumentation.DocumentWriterParameter ().

IF cServices > "":U THEN DO ON ERROR UNDO, THROW:
    oServiceLoader = NEW ServiceLoader () .    
    oServiceLoader:Load (cServices) .
    
    DELETE OBJECT oServiceLoader .     
END.

ASSIGN oParameter:DocumentationTitle       = cTitle
       oParameter:GenerateTreeViewOverview = lGenerateTreeViewOverview 
       .

FILE-INFO:FILE-NAME = cTargetDir .
IF FILE-INFO:FULL-PATHNAME > "":U THEN 
    ASSIGN oParameter:TargetDir = FILE-INFO:FULL-PATHNAME .
ELSE 
    UNDO, THROW NEW Consultingwerk.Exceptions.InvalidParameterValueException ("TargetDir":U, 
                                                                              cTargetDir,
                                                                              "Consultingwerk.Studio.ClassDocumentation.DocumentWriterParameter":U) .

FILE-INFO:FILE-NAME = cSourceDir .
IF FILE-INFO:FULL-PATHNAME > "":U THEN 
    ASSIGN oParameter:SourceDir = FILE-INFO:FULL-PATHNAME .
ELSE 
    UNDO, THROW NEW Consultingwerk.Exceptions.InvalidParameterValueException ("SourceDir":U, 
                                                                              cSourceDir,
                                                                              "Consultingwerk.Studio.ClassDocumentation.DocumentWriterParameter":U) .

FILE-INFO:FILE-NAME = cTemplateSourceDir .
IF FILE-INFO:FULL-PATHNAME > "":U THEN 
    ASSIGN oParameter:TemplateSourceDir = FILE-INFO:FULL-PATHNAME .
ELSE 
    UNDO, THROW NEW Consultingwerk.Exceptions.InvalidParameterValueException ("TemplateSourceDir":U, 
                                                                              cTemplateSourceDir,
                                                                              "Consultingwerk.Studio.ClassDocumentation.DocumentWriterParameter":U) .

IF cResourceDir > "":U THEN DO:
    FILE-INFO:FILE-NAME = cResourceDir .
    IF FILE-INFO:FULL-PATHNAME > "":U THEN 
        ASSIGN oParameter:ResourceDir = FILE-INFO:FULL-PATHNAME .
    ELSE 
        UNDO, THROW NEW Consultingwerk.Exceptions.InvalidParameterValueException ("ResourceDir":U, 
                                                                                  cResourceDir,
                                                                                  "Consultingwerk.Studio.ClassDocumentation.DocumentWriterParameter":U) .
END.

/* Mike Fechner, Consultingwerk Ltd. 25.03.2013
   Prevent AVM crash during documentation generation */
IF lPreloadClasses THEN 
    Consultingwerk.Studio.ClassDocumentation.BaseClassListProvider:PreloadClasses (".":U).

oDoc = NEW Consultingwerk.Studio.ClassDocumentation.DocumentationWriter ().
oDoc:GenerateDocumentation (oParameter).

RETURN "0":U . 

CATCH err AS Progress.Lang.Error :
    MESSAGE Consultingwerk.Util.ErrorHelper:FormattedErrorMessagesExt (err) . 
END CATCH.
