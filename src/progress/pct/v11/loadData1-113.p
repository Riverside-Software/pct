/**
 * Copyright 2005-2018 Riverside Software
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

using Progress.Lang.Class.

define variable srcDir    as character no-undo.
define variable tableList as character no-undo.
define variable h         as handle    no-undo.
define variable logger    as rssw.pct.LoadDataLogger.
define variable callback    as rssw.pct.ILoadDataCallback.
define variable callbackCls as character no-undo.
define variable iErrPerc    as integer   no-undo.

assign srcDir    = dynamic-function('getParameter' in source-procedure, input 'srcDir')
       tableList = dynamic-function('getParameter' in source-procedure, input 'tables')
       iErrPerc  = dynamic-function('getParameter' IN source-procedure, input 'errorPercentage').

assign callbackCls = dynamic-function('getParameter' in source-procedure, input 'callbackClass').
if (callbackCls > "") then do:
    callback = cast(Class:GetClass(callbackCls):new(), rssw.pct.ILoadDataCallback).
    callback:initialize(tableList).
end.

if valid-object(callback) then callback:beforeLoad(srcDir).

logger = new rssw.pct.LoadDataLogger().
run prodict/load_d.p persistent set h (tableList, srcDir + '/').
run setAcceptableErrorPercentage in h (iErrPerc).
run setMonitor in h (logger).
run setSilent in h (dynamic-function('getParameter' in source-procedure, input 'silent') EQ '1').
run doLoad in h.
delete procedure h.

if valid-object(callback) then callback:afterLoad(srcDir, logger).

/* If process failed, return error code */
if logger:loadException or logger:bailed then do:
  return '1'.
end.

return "0":U.
