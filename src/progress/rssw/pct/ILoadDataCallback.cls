/**
 * Copyright 2005-2023 Riverside Software
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

interface rssw.pct.ILoadDataCallback:
  method public void initialize(tableName as character).
  method public void onError(msg as character).
  method public void beforePurge().
  method public void afterPurge(delCount as integer).
  method public void beforeSequenceValuesBackup().
  method public void afterSequenceValuesBackup().
  method public void beforeLoad(file as character).
  method public void afterLoad(file as character, logger as rssw.pct.LoadDataLogger).
end interface.
