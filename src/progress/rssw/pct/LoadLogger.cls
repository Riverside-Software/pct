/**
 * Copyright 2005-2019 Riverside Software
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Progress.Lang.*.
USING OpenEdge.DataAdmin.Binding.IDataDefinitionLoader FROM PROPATH. 

CLASS rssw.pct.LoadLogger INHERITS rssw.pct.AbstractLoadLogger:
  DEFINE PUBLIC PROPERTY numErrors   AS INTEGER NO-UNDO INITIAL 0 GET. PRIVATE SET.
  DEFINE PUBLIC PROPERTY numWarnings AS INTEGER NO-UNDO INITIAL 0 GET. PRIVATE SET.
  DEFINE VARIABLE errors   AS LONGCHAR NO-UNDO.
  DEFINE VARIABLE warnings AS LONGCHAR NO-UNDO.

  CONSTRUCTOR PUBLIC LoadLogger():
    THIS-OBJECT:IsReader = FALSE.
  END CONSTRUCTOR.

  METHOD PUBLIC LONGCHAR getErrors ():
    RETURN errors.
  END METHOD.

  METHOD PUBLIC LONGCHAR getWarnings ():
    RETURN warnings.
  END METHOD.

  METHOD PUBLIC OVERRIDE VOID AddError( pError as Error) :
    DEFINE VARIABLE zz AS INTEGER NO-UNDO.

    DO zz = 1 TO pError:NumMessages:
        THIS-OBJECT:AddError(pError:GetMessage(zz)).
    END.

  END METHOD.

  METHOD PUBLIC OVERRIDE VOID AddError( pcText as character ):
    /* Yup, this message is hard-coded in prodict/dump/_lodsddl.p */
    IF (pcText EQ 'Input file is empty or invalid.') THEN DO:
      AddWarning(pcText).
      RETURN.
    END.
    THIS-OBJECT:numErrors = THIS-OBJECT:numErrors + 1.
    MESSAGE pcText.
    ASSIGN errors = errors + pcText + "~n".

  END METHOD.
    
  METHOD PUBLIC OVERRIDE VOID AddPhase2Error( pcText as character ) :
    THIS-OBJECT:numErrors = THIS-OBJECT:numErrors + 1.
    MESSAGE pcText.
    errors = errors + pcText + "~n".
  END METHOD.
    
  METHOD PUBLIC OVERRIDE VOID AddWarning( pcText as character ) :
    THIS-OBJECT:numWarnings = THIS-OBJECT:numWarnings + 1.
    MESSAGE pcText.
    warnings = warnings + pcText + "~n".
  END METHOD.

END CLASS.
