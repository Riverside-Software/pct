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
    File        : Consultingwerk/Studio/SmartDox/validate-parameter-reference.p
    Purpose     : Executes the ParameterCommentValidator to check the comments
                  validation from @param and @return

    Syntax      :

    Description : 

    Author(s)   : Sebastian Düngel / Consultingwerk Ltd.
    Created     : Wed Feb 06 09:39:06 CET 2013
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE oParameterValidator AS Consultingwerk.Studio.SmartDox.ParameterCommentValidator             NO-UNDO.
DEFINE VARIABLE oParameter          AS Consultingwerk.Studio.SmartDox.IParameterCommentValidatorParameter   NO-UNDO.

DEFINE VARIABLE cSourceDir          AS CHARACTER                                                            NO-UNDO.
DEFINE VARIABLE cExportFile         AS CHARACTER                                                            NO-UNDO.

DEFINE VARIABLE i                   AS INTEGER                                                              NO-UNDO.

/* ***************************  Main Block  *************************** */

ASSIGN cSourceDir         = DYNAMIC-FUNCTION("getParameter":U IN SOURCE-PROCEDURE, INPUT "SourceDir":U)
       cExportFile        = DYNAMIC-FUNCTION("getParameter":U IN SOURCE-PROCEDURE, INPUT "ExportFile":U)
       .
       
MESSAGE "Source Directory:":U cSourceDir .

oParameter = NEW Consultingwerk.Studio.SmartDox.ParameterCommentValidatorParameter ().

FILE-INFO:FILE-NAME = cSourceDir .
IF FILE-INFO:FULL-PATHNAME > "":U THEN 
    ASSIGN oParameter:SourceDir = FILE-INFO:FULL-PATHNAME .
ELSE 
    UNDO, THROW NEW Consultingwerk.Exceptions.InvalidParameterValueException ("SourceDir":U, 
                                                                              cSourceDir,
                                                                              "Consultingwerk.Studio.SmartDox.ParameterCommentValidatorParameter":U) .


oParameterValidator = NEW Consultingwerk.Studio.SmartDox.ParameterCommentValidator ().
oParameterValidator:Verbose = yes. 
oParameterValidator:CommentValidatorStart (oParameter).

IF cExportFile > "":U THEN 
    oParameterValidator:ExportToFile (cExportFile).
    

RETURN "0":U . 

CATCH err AS Progress.Lang.Error :
    DO i = 1 TO err:NumMessages:
    
       MESSAGE err:GetMessage (i) .
    END.
END CATCH.
