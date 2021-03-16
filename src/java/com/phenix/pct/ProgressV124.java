/**
 * Copyright 2005-2021 Riverside Software
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
package com.phenix.pct;

public class ProgressV124 extends ProgressV121 {
    @Override
    public String getIncrementalProcedure() {
        return "pct/v12/silentIncDump124.p";
    }

    @Override
    public String getDumpUsersProcedure() {
        return "pct/v12/dmpUsers124.p";
    }

    @Override
    public String getLoadSingleTableDataProcedure() {
        return "pct/v12/loadData2-124.p";
    }

    @Override
    public String getLoadUsersProcedure() {
        return "pct/v12/loadUsers124.p";
    }

    @Override
    public String getLoadSchemaProcedure() {
        return "pct/v12/loadSch124.p";
    }
}
