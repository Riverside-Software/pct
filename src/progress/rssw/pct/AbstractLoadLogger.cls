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

CLASS rssw.pct.AbstractLoadLogger IMPLEMENTS IDataDefinitionLoader ABSTRACT:
  DEFINE PUBLIC PROPERTY IsReader AS LOGICAL  NO-UNDO INITIAL TRUE GET. PROTECTED SET.
  DEFINE PUBLIC PROPERTY Error    AS AppError NO-UNDO GET. PRIVATE SET.
  DEFINE PUBLIC PROPERTY Warning  AS AppError NO-UNDO GET. PRIVATE SET.
  DEFINE PUBLIC PROPERTY AddingChildToNewTable AS LOGICAL NO-UNDO GET. SET. 

  METHOD PUBLIC LOGICAL EXTENT CurrentTableAttributes():

  END METHOD.

  METHOD PUBLIC VOID AddError( pError as Error):

  END METHOD.

  METHOD PUBLIC VOID AddError( pcText as character ) :

  END METHOD.

  METHOD PUBLIC VOID AddPhase2Error( pcText as character ):

  END METHOD.

  METHOD PUBLIC VOID AddWarning( pcText as character ) :

  END METHOD.

  METHOD PUBLIC VOID AddTable(pcAction as character, h as handle, piArea as integer):

  END METHOD.

  METHOD PUBLIC VOID AddSequence(pcAction as character, h as handle):

  END METHOD.

  METHOD PUBLIC VOID AddIndex(pcAction as character, pcTable as character, h as handle, piArea as integer):

  END METHOD.

  METHOD PUBLIC VOID AddIndex(pcAction as character, pcTable as character, h as handle, piArea as integer, piPrimary as logical):

  END METHOD.
  
  METHOD PUBLIC VOID AddField(pcAction as character, pcTable as character, h as handle, piArea as integer):

  END METHOD.
    
  METHOD PUBLIC LOGICAL IsNewTable(pcTable as character):
    RETURN TRUE.
  END METHOD. 
    
  METHOD PUBLIC VOID RenameTable(pcname as character,pcNewname as character):

  END METHOD.

  METHOD PUBLIC VOID RenameField(pcTable as character, pcname as character,pcNewname as character):

  END METHOD.

  METHOD PUBLIC VOID RenameIndex(pcTable as character, pcname as character,pcNewname as character):

  END METHOD.

  METHOD PUBLIC VOID RenameSequence(pcname as character,pcNewname as character):

  END METHOD. 

  METHOD PUBLIC CHARACTER TableOldName(pcNewname as character):

  END METHOD.

  METHOD PUBLIC CHARACTER FieldOldName(pcTable as character, pcNewname as character):

  END METHOD.

  METHOD PUBLIC CHARACTER IndexOldName(pcTable as character, pcNewname as character):

  END METHOD.

  METHOD PUBLIC CHARACTER SequenceOldName(pcNewname as character):

  END METHOD.

  METHOD PUBLIC CHARACTER FieldNewName(pcTable as character, pcOldname as character):

  END METHOD.

  METHOD PUBLIC CHARACTER IndexNewName(pcTable as character, pcOldname as character):

  END METHOD.

  METHOD PUBLIC CHARACTER TableNewName(pcOldname as character):

  END METHOD.

  METHOD PUBLIC CHARACTER SequenceNewName(pcOldname as character):

  END METHOD.

  METHOD PUBLIC AppError RemoveWarning ():
    RETURN ?.
  END METHOD. 

  METHOD PUBLIC AppError RemoveError ():
    RETURN ?.
  END METHOD.

  METHOD PUBLIC CHARACTER RemoveErrorMessages ():
    RETURN "".
  END METHOD.

  METHOD PUBLIC CHARACTER RemoveWarningMessages ():
    RETURN "".
  END METHOD.

END CLASS.
