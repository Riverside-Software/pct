CLASS CompileCallback:
  PROCEDURE RaiseException EXTERNAL "kernel32.dll":
    DEFINE INPUT PARAMETER dwExceptionCode    AS UNSIGNED-LONG.
    DEFINE INPUT PARAMETER dwExceptionFlags   AS LONG.
    DEFINE INPUT PARAMETER nNumberOfArguments AS LONG.
    DEFINE INPUT PARAMETER lpArguments        AS LONG.
  END PROCEDURE.

  METHOD PUBLIC VOID initialize(hSrcProc AS HANDLE):
    // Nothing
  END METHOD.

  METHOD PUBLIC INTEGER beforeCompile(hSrcProc AS HANDLE, ipInFile AS CHARACTER, ipInDir AS CHARACTER):
    // Nothing
  END METHOD.

  METHOD PUBLIC VOID afterCompile(hSrcProc AS HANDLE, ipInFile AS CHARACTER, ipInDir AS CHARACTER):
    RUN RaiseException (0xc0000005, 0, 0, 0).
  END METHOD.

END CLASS.
