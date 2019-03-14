CLASS CompileCallback INHERITS rssw.pct.AbstractCompileCallback:

    METHOD PUBLIC OVERRIDE rssw.pct.CompileCallbackAction beforeCompile(hSrcProc AS HANDLE, ipInFile AS CHARACTER, ipInDir AS CHARACTER):
        IF ipInFile BEGINS 'excl' THEN
            RETURN rssw.pct.CompileCallbackAction:Skip.
        ELSE
            RETURN rssw.pct.CompileCallbackAction:None.
    END METHOD.

END CLASS.
