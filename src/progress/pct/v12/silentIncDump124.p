/**
 * Copyright 2005-2019 Riverside Software
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE h AS HANDLE NO-UNDO.

RUN pct/v12/dump_inc124.p PERSISTENT SET h .

RUN setFileName IN h (DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'DFFileName')).
RUN setCodePage IN h (DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'CodePage')).
RUN setIndexMode IN h (INTEGER(DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'IndexMode'))).
RUN setRenameFilename IN h(DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'RenameFile')).
RUN setDebugMode IN h (INTEGER(DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'DebugMode'))).
RUN setRemoveEmptyDFfile IN h (DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'removeEmptyDFfile') EQ "true").
RUN setDumpSection IN h (DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'dumpSection') EQ "true").
RUN setSilent IN h(yes).
RUN doDumpIncr IN h.
DELETE PROCEDURE h. 

CATCH e AS Progress.Lang.AppError :
    MESSAGE e:ReturnValue.  
END CATCH.
