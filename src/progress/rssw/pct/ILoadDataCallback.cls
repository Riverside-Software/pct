INTERFACE rssw.pct.ILoadDataCallback:
    METHOD PUBLIC VOID initialize(tableName as character).
    METHOD PUBLIC VOID onError(msg as character).
    METHOD PUBLIC VOID beforePurge().
    METHOD PUBLIC VOID afterPurge(delCount as integer).
    METHOD PUBLIC VOID beforeSequenceValuesBackup().
    METHOD PUBLIC VOID afterSequenceValuesBackup().
    METHOD PUBLIC VOID beforeLoad(file AS CHARACTER).
    METHOD PUBLIC VOID afterLoad(file AS CHARACTER, logger AS rssw.pct.LoadDataLogger).
END INTERFACE.