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

DEFINE VARIABLE cDir AS CHARACTER NO-UNDO.
DEFINE VARIABLE cTables AS CHARACTER NO-UNDO.
DEFINE VARIABLE cEncoding AS CHARACTER NO-UNDO.

ASSIGN cDir    = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'destDir')
       cTables = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'tables')
       cEncoding = DYNAMIC-FUNCTION('getParameter' IN SOURCE-PROCEDURE, INPUT 'encoding').

RUN prodict/dump_d.p (cTables, cDir, cEncoding).
RETURN RETURN-VALUE.