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

CLASS rssw.pct.AbstractLoadDataCallback IMPLEMENTS rssw.pct.ILoadDataCallback:
    METHOD PUBLIC VOID initialize(tableName as character): END METHOD.
    METHOD PUBLIC VOID onError(msg AS CHARACTER): END METHOD.
    METHOD PUBLIC VOID beforePurge(): END METHOD.
    METHOD PUBLIC VOID afterPurge(delCount AS INTEGER): END METHOD.
    METHOD PUBLIC VOID beforeSequenceValuesBackup(): END METHOD.
    METHOD PUBLIC VOID afterSequenceValuesBackup(): END METHOD.
    METHOD PUBLIC VOID beforeLoad(file AS CHARACTER): END METHOD.
    METHOD PUBLIC VOID afterLoad(file AS CHARACTER, logger AS rssw.pct.LoadDataLogger): END METHOD.
END CLASS.