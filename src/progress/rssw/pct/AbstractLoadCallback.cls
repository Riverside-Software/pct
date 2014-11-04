CLASS rssw.pct.AbstractLoadCallback IMPLEMENTS rssw.pct.ILoadCallback:
    METHOD PUBLIC VOID beforeUnfreeze(): END METHOD.
    METHOD PUBLIC VOID beforeFileList(): END METHOD.
    METHOD PUBLIC VOID beforeFile(file AS CHARACTER): END METHOD.
    METHOD PUBLIC VOID afterFile(file AS CHARACTER, logger AS rssw.pct.LoadLogger): END METHOD.
    METHOD PUBLIC VOID afterFileList(): END METHOD.
    METHOD PUBLIC VOID beforeRefreeze(): END METHOD.
    METHOD PUBLIC VOID afterRefreeze(): END METHOD.
END CLASS.