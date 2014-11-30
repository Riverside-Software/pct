ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Progress.Lang.*.
USING OpenEdge.DataAdmin.Binding.IDataDefinitionLoader FROM PROPATH. 

CLASS rssw.pct.AbstractLoadLogger IMPLEMENTS IDataDefinitionLoader ABSTRACT:
  DEFINE PUBLIC PROPERTY IsReader AS LOGICAL  NO-UNDO INIT TRUE GET. PROTECTED SET.
  DEFINE PUBLIC PROPERTY Error    AS AppError NO-UNDO GET. PRIVATE SET.
  DEFINE PUBLIC PROPERTY Warning  AS AppError NO-UNDO GET. PRIVATE SET.
  DEFINE PUBLIC PROPERTY AddingChildToNewTable AS LOGICAL NO-UNDO GET. SET. 

  METHOD PUBLIC LOGICAL EXTENT CurrentTableAttributes():

  END METHOD.

  METHOD PUBLIC VOID AddError( pError as Error):

  END METHOD.

  METHOD PUBLIC VOID AddError( pcText as char ) :

  END METHOD.

  METHOD PUBLIC VOID AddPhase2Error( pcText as char ):

  END METHOD.

  METHOD PUBLIC VOID AddWarning( pcText as char ) :

  END METHOD.

  METHOD PUBLIC VOID AddTable(pcAction as char, h as handle, piArea as int):

  END METHOD.

  METHOD PUBLIC VOID AddSequence(pcAction as char, h as handle):

  END METHOD.

  METHOD PUBLIC VOID AddIndex(pcAction as char, pcTable as char, h as handle, piArea as int):

  END METHOD.

  METHOD PUBLIC VOID AddIndex(pcAction as char, pcTable as char, h as handle, piArea as int, piPrimary as log):

  END METHOD.
  
  METHOD PUBLIC VOID AddField(pcAction as char, pcTable as char, h as handle, piArea as int):

  END METHOD.
    
  METHOD PUBLIC LOGICAL IsNewTable(pcTable as char):
    RETURN TRUE.
  END METHOD. 
    
  METHOD PUBLIC VOID RenameTable(pcname as char,pcNewname as char):

  END METHOD.

  METHOD PUBLIC VOID RenameField(pcTable as char, pcname as char,pcNewname as char):

  END METHOD.

  METHOD PUBLIC VOID RenameIndex(pcTable as char, pcname as char,pcNewname as char):

  END METHOD.

  METHOD PUBLIC VOID RenameSequence(pcname as char,pcNewname as char):

  END METHOD. 

  METHOD PUBLIC CHAR TableOldName(pcNewname as char):

  END METHOD.

  METHOD PUBLIC CHAR FieldOldName(pcTable as char, pcNewname as char):

  END METHOD.

  METHOD PUBLIC CHAR IndexOldName(pcTable as char, pcNewname as char):

  END METHOD.

  METHOD PUBLIC CHAR SequenceOldName(pcNewname as char):

  END METHOD.

  METHOD PUBLIC CHAR FieldNewName(pcTable as char, pcOldname as char):

  END METHOD.

  METHOD PUBLIC CHAR IndexNewName(pcTable as char, pcOldname as char):

  END METHOD.

  METHOD PUBLIC CHAR TableNewName(pcOldname as char):

  END METHOD.

  METHOD PUBLIC CHAR SequenceNewName(pcOldname as char):

  END METHOD.

  METHOD PUBLIC AppError RemoveWarning ():
    RETURN ?.
  END METHOD. 

  METHOD PUBLIC AppError RemoveError ():
    RETURN ?.
  END METHOD.

  METHOD PUBLIC CHAR RemoveErrorMessages ():
    RETURN "".
  END METHOD.

  METHOD PUBLIC CHAR RemoveWarningMessages ():
    RETURN "".
  END METHOD.

END CLASS.
