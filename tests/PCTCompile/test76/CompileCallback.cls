CLASS CompileCallback INHERITS rssw.pct.AbstractCompileCallback:

    METHOD PUBLIC OVERRIDE VOID initialize(hSrcProc AS HANDLE):
        OUTPUT TO "src/initialize.txt".
        PUT UNFORMATTED SUBSTITUTE("Initialize#&1", hSrcProc:FILE-NAME).
    END METHOD.

    METHOD PUBLIC OVERRIDE INTEGER beforeCompile(hSrcProc AS HANDLE, ipInFile AS CHARACTER, ipInDir AS CHARACTER):
        OUTPUT TO "src/beforeCompile.txt".
        PUT UNFORMATTED SUBSTITUTE("Before Compile#&1#&2#&3", hSrcProc:FILE-NAME, ipInFile, ipInDir).
        RETURN 0.
    END METHOD.

    METHOD PUBLIC OVERRIDE VOID afterCompile(hSrcProc AS HANDLE, ipInFile AS CHARACTER, ipInDir AS CHARACTER):
        OUTPUT TO "src/afterCompile.txt".
        PUT UNFORMATTED SUBSTITUTE("After Compile#&1#&2#&3", hSrcProc:FILE-NAME, ipInFile, ipInDir).
    END METHOD.

END CLASS.
