INTERFACE rssw.pct.ILoadDataCallback:
    METHOD PUBLIC VOID beforePurge().
    METHOD PUBLIC VOID afterPurge().
    METHOD PUBLIC VOID beforeLoad(file AS CHARACTER).
    METHOD PUBLIC VOID afterLoad(file AS CHARACTER, logger AS rssw.pct.LoadDataLogger).
END INTERFACE.