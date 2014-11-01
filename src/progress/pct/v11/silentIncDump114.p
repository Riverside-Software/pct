ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE h AS HANDLE NO-UNDO.

RUN pct/v11/dump_inc114.p PERSISTENT SET h .

RUN setFileName IN h (DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'DFFileName')).
RUN setCodePage IN h (DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'CodePage')).
RUN setIndexMode IN h (INTEGER(DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'IndexMode'))).
RUN setRenameFilename IN h(DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'RenameFile')).
RUN setDebugMode IN h (INTEGER(DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'DebugMode'))).
RUN setRemoveEmptyDFfile IN h (DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'removeEmptyDFfile') EQ "true").
RUN setSilent IN h(yes).
RUN doDumpIncr IN h.
DELETE PROCEDURE h. 

CATCH e AS Progress.Lang.AppError :
    MESSAGE e:ReturnValue.  
END CATCH.
