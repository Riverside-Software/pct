INTERFACE rssw.pct.IMainCallback:
    METHOD PUBLIC VOID initialize().
    METHOD PUBLIC VOID beforeRun().
    METHOD PUBLIC VOID afterRun(retVal AS INTEGER).
    METHOD PUBLIC VOID log(msg AS CHARACTER).
END INTERFACE.