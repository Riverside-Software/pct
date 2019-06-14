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
package com.phenix.pct;

public class ProgressV117 extends ProgressV114 {

    @Override
    public String getDumpUsersProcedure() {
        return "pct/v11/dmpUsers117.p";
    }

    @Override
    public String getLoadUsersProcedure() {
        return "pct/v11/loadUsers117.p";
    }

    @Override
    public String getLoadSingleTableDataProcedure() {
        return "pct/v11/loadData2-117.p";
    }

}
