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

define variable srcDir    as character no-undo.
define variable tableList as character no-undo.

assign srcDir    = dynamic-function('getParameter' in source-procedure, input 'srcDir')
       tableList = dynamic-function('getParameter' in source-procedure, input 'tables').
if (dynamic-function('getParameter' in source-procedure, input 'callbackClass') > "") then do:
    message "Callbacks are only supported on 11.3+".
end.

run prodict/load_d.p (tableList, srcDir + '/'). 

return "0":U.
