ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Progress.Lang.*.
USING OpenEdge.DataAdmin.Binding.IDataDefinitionLoader FROM PROPATH. 

CLASS rssw.pct.LoadLogger INHERITS rssw.pct.AbstractLoadLogger:
  DEFINE PUBLIC PROPERTY numErrors AS INTEGER NO-UNDO INITIAL 0 GET. PRIVATE SET.
  DEFINE PUBLIC PROPERTY numWarnings AS INTEGER NO-UNDO INITIAL 0 GET. PRIVATE SET.
  DEFINE VARIABLE errors AS LONGCHAR NO-UNDO.
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

    THIS-OBJECT:numErrors = THIS-OBJECT:numErrors + 1.
    DO zz = 1 TO pError:NumMessages:
        THIS-OBJECT:AddError(pError:GetMessage(zz)).
    END.

  END METHOD.

  METHOD PUBLIC OVERRIDE VOID AddError( pcText as char ) :
    THIS-OBJECT:numErrors = THIS-OBJECT:numErrors + 1.
    MESSAGE pcText.
    errors = errors + pcText + "~n".
  END METHOD.
    
  METHOD PUBLIC OVERRIDE VOID AddPhase2Error( pcText as char ) :
    THIS-OBJECT:numErrors = THIS-OBJECT:numErrors + 1.
    MESSAGE pcText.
    errors = errors + pcText + "~n".
  END METHOD.
    
  METHOD PUBLIC OVERRIDE VOID AddWarning( pcText as char ) :
    THIS-OBJECT:numWarnings = THIS-OBJECT:numWarnings + 1.
    MESSAGE pcText.
    warnings = warnings + pcText + "~n".
  END METHOD.

END CLASS.
