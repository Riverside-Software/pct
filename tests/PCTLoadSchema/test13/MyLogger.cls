CLASS MyLogger INHERITS rssw.pct.AbstractLoadCallback:

    METHOD PUBLIC OVERRIDE VOID afterFile(file AS CHARACTER, logger AS rssw.pct.LoadLogger):
            COPY-LOB FROM logger:getErrors() TO FILE "myerrors.txt".
        IF (logger:numErrors > 0) THEN
            COPY-LOB FROM logger:getErrors() TO FILE "myerrors.txt".
    END METHOD.
        
END CLASS.
