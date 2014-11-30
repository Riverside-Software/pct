CLASS rssw.pct.AbstractLoadDataCallback IMPLEMENTS rssw.pct.ILoadDataCallback:
    METHOD PUBLIC VOID initialize(tableName as character): END METHOD.
    METHOD PUBLIC VOID onError(msg AS CHARACTER): END METHOD.
    METHOD PUBLIC VOID beforePurge(): END METHOD.
    METHOD PUBLIC VOID afterPurge(delCount AS INTEGER): END METHOD.
    METHOD PUBLIC VOID beforeSequenceValuesBackup(): END METHOD.
    METHOD PUBLIC VOID afterSequenceValuesBackup(): END METHOD.
    METHOD PUBLIC VOID beforeLoad(file AS CHARACTER): END METHOD.
    METHOD PUBLIC VOID afterLoad(file AS CHARACTER, logger AS rssw.pct.LoadDataLogger): END METHOD.
END CLASS.