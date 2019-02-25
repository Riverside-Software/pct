CLASS CompileCallback INHERITS rssw.pct.AbstractCompileCallback:

    METHOD PUBLIC OVERRIDE VOID initialize(hSrcProc AS HANDLE):
        OUTPUT TO "src/initialize.txt".
        PUT UNFORMATTED "Initialize".
    END METHOD.

    METHOD PUBLIC OVERRIDE VOID beforeCompile(hSrcProc AS HANDLE, ipInFile AS CHARACTER, ipInDir AS CHARACTER):
        OUTPUT TO "src/beforeCompile.txt".
        PUT UNFORMATTED "Before Compile".
    END METHOD.

    METHOD PUBLIC OVERRIDE VOID afterCompile(hSrcProc AS HANDLE, ipInFile AS CHARACTER, ipInDir AS CHARACTER):
        OUTPUT TO "src/afterCompile.txt".
        PUT UNFORMATTED "After Compile".
    END METHOD.

END CLASS.
