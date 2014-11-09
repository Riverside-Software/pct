CLASS MyLogger INHERITS rssw.pct.AbstractLoadDataCallback:

    METHOD PUBLIC OVERRIDE VOID afterPurge(delCount AS INTEGER) :
    
    END METHOD.
    
    METHOD PUBLIC OVERRIDE VOID afterLoad(file AS CHARACTER, logger AS rssw.pct.LoadDataLogger):
        IF logger:anyError THEN COPY-LOB FROM logger:getErrors() to FILE "myerrors.txt". 
    END METHOD.
        
END CLASS.
