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
    File        : Consultingwerk/Studio/SmartDox/generate-class-documentation.p
    Purpose     : Executes the ClassReferenceWriter to generate the
                  xml class reference documentation  for the Class Browser

    Syntax      : Parameters passed using <Parameter name="" value="" /> 
                  properties of the ANT/PCT PCTRun task:
                      
                  <Parameter name="SourceDir" value="classdoc"/>
                  <Parameter name="TargetFile" value="ABL.xml"/>
                  <Parameter name="Verbose" value="yes"/>
                  
    Description : 

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Thu Jan 03 13:35:22 UTC 2013
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE oDoc               AS Consultingwerk.Studio.SmartDox.ClassReferenceWriter NO-UNDO.
DEFINE VARIABLE oParameter         AS Consultingwerk.Studio.SmartDox.ISmartDoxParameter   NO-UNDO.

DEFINE VARIABLE cTargetFile        AS CHARACTER                                           NO-UNDO.
DEFINE VARIABLE cSourceDir         AS CHARACTER                                           NO-UNDO.
DEFINE VARIABLE lVerbose           AS LOGICAL                                             NO-UNDO.

DEFINE VARIABLE i                  AS INTEGER                                             NO-UNDO.

DEFINE SHARED VARIABLE pctVerbose AS LOGICAL NO-UNDO
.
/* ***************************  Main Block  *************************** */

SESSION:ERROR-STACK-TRACE = TRUE . 

ASSIGN cTargetFile        = DYNAMIC-FUNCTION("getParameter":U IN SOURCE-PROCEDURE, "TargetFile":U)
       cSourceDir         = DYNAMIC-FUNCTION("getParameter":U IN SOURCE-PROCEDURE, "SourceDir":U).

IF pctVerbose THEN MESSAGE "Source Directory:":U cSourceDir .
IF pctVerbose THEN MESSAGE "Target File:     ":U cTargetFile .

oParameter = NEW Consultingwerk.Studio.SmartDox.SmartDoxParameter ().
oParameter:TargetFile = cTargetFile .

FILE-INFO:FILE-NAME = cSourceDir .
IF FILE-INFO:FULL-PATHNAME > "":U THEN 
    ASSIGN oParameter:SourceDir = FILE-INFO:FULL-PATHNAME .
ELSE 
    UNDO, THROW NEW Consultingwerk.Exceptions.InvalidParameterValueException ("SourceDir":U, 
                                                                              cSourceDir,
                                                                              "Consultingwerk.Studio.ClassDocumentation.DocumentWriterParameter":U) .

oDoc = NEW Consultingwerk.Studio.SmartDox.ClassReferenceWriter ().
oDoc:Verbose = pctVerbose . 
oDoc:GenerateClassReference (oParameter).

RETURN "0":U . 

CATCH err AS Progress.Lang.Error :
	DO i = 1 TO err:NumMessages:
	
	   MESSAGE err:GetMessage (i) .
	END.

    IF err:CallStack > "":U THEN 
        MESSAGE err:CallStack . 
END CATCH.
