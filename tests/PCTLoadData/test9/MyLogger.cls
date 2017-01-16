CLASS MyLogger INHERITS rssw.pct.BackupDataCallback:

    METHOD PUBLIC OVERRIDE VOID afterLoad(file AS CHARACTER, logger AS rssw.pct.LoadDataLogger):
        IF logger:anyError THEN COPY-LOB FROM logger:getErrors() to FILE "myerrors.txt".
        super:afterLoad(file, logger).
    END METHOD.
        
END CLASS.
