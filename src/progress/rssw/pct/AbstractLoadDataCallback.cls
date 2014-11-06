CLASS rssw.pct.AbstractLoadDataCallback IMPLEMENTS rssw.pct.ILoadDataCallback:
    METHOD PUBLIC VOID beforePurge(): END METHOD.
    METHOD PUBLIC VOID afterPurge(): END METHOD.
    METHOD PUBLIC VOID beforeLoad(file AS CHARACTER): END METHOD.
    METHOD PUBLIC VOID afterLoad(file AS CHARACTER, logger AS rssw.pct.LoadDataLogger): END METHOD.
END CLASS.