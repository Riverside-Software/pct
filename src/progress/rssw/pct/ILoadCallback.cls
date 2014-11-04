INTERFACE rssw.pct.ILoadCallback:
    METHOD PUBLIC VOID beforeUnfreeze().
    METHOD PUBLIC VOID beforeFileList().
    METHOD PUBLIC VOID beforeFile(file AS CHARACTER).
    METHOD PUBLIC VOID afterFile(file AS CHARACTER, logger AS rssw.pct.LoadLogger).
    METHOD PUBLIC VOID afterFileList().
    METHOD PUBLIC VOID beforeRefreeze().
    METHOD PUBLIC VOID afterRefreeze().
END INTERFACE.