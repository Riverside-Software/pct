/**
 * Copyright 2005-2017 Riverside Software
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

import java.util.ArrayList;
import java.util.Collection;

public class MSSHolder extends SchemaHolder {
    private boolean caseSensitive;

    public boolean validate() {
        return true;
    }

    public Collection<RunParameter> getParameters() {
        Collection<RunParameter> c = new ArrayList<>();
        c.add(new RunParameter("SchemaHolderName", this.getDbName()));
        c.add(new RunParameter("Collation", this.getCollation()));
        c.add(new RunParameter("Codepage", this.getCodepage()));
        c.add(new RunParameter("CaseSensitive", Boolean.toString(this.caseSensitive)));
        c.add(new RunParameter("UserName", this.getUsername()));
        c.add(new RunParameter("Password", this.getPassword()));

        return c;
    }

    public String getProcedure() {
        return "pct/mssHolder.p";
    }

    public boolean isCaseSensitive() {
        return caseSensitive;
    }

    public void setCaseSensitive(boolean caseSensitive) {
        this.caseSensitive = caseSensitive;
    }
}
