CLASS CompileCallback INHERITS rssw.pct.AbstractCompileCallback:

    METHOD PUBLIC OVERRIDE VOID initialize(hSrcProc AS HANDLE):
        OUTPUT TO "src/initialize.txt".
        PUT UNFORMATTED SUBSTITUTE("Initialize#&1", hSrcProc:FILE-NAME).
    END METHOD.

    METHOD PUBLIC OVERRIDE VOID beforeCompile(hSrcProc AS HANDLE, ipInFile AS CHARACTER, ipInDir AS CHARACTER):
        DEFINE VARIABLE PartOfPath AS CHARACTER NO-UNDO.
        PartOfPath = getRelativePath(ipInDir).
        OUTPUT TO "src/beforeCompile.txt".
        PUT UNFORMATTED SUBSTITUTE("Before Compile#&1#&2#&3", hSrcProc:FILE-NAME, ipInFile, PartOfPath).
        END METHOD.

    METHOD PUBLIC OVERRIDE VOID afterCompile(hSrcProc AS HANDLE, ipInFile AS CHARACTER, ipInDir AS CHARACTER):
        DEFINE VARIABLE PartOfPath AS CHARACTER NO-UNDO.
        PartOfPath = getRelativePath(ipInDir).
        OUTPUT TO "src/afterCompile.txt".
        PUT UNFORMATTED SUBSTITUTE("After Compile#&1#&2#&3", hSrcProc:FILE-NAME, ipInFile, PartOfPath).
    END METHOD.

    METHOD PRIVATE CHARACTER getRelativePath(AbsPath AS CHARACTER):
        DEFINE VARIABLE PartOfPath AS CHARACTER NO-UNDO.
        DEFINE VARIABLE BeginIndex AS INTEGER NO-UNDO.
        PartOfPath = REPLACE(AbsPath, "~\", "/").
        BeginIndex = INDEX(PartOfPath, "/tests/").
        PartOfPath = SUBSTRING(PartOfPath, BeginIndex).
        RETURN PartOfPath.
    END METHOD.

END CLASS.
