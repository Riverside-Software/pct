CLASS CompileCallback INHERITS rssw.pct.AbstractCompileCallback:

    METHOD PUBLIC OVERRIDE INTEGER beforeCompile(hSrcProc AS HANDLE, ipInFile AS CHARACTER, ipInDir AS CHARACTER):
        IF ipInFile BEGINS 'excl' THEN
            RETURN 1.
        ELSE
            RETURN 0.
    END METHOD.

END CLASS.
