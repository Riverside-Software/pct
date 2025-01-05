/**
 * Copyright 2005-2025 Riverside Software
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

/**
 * Alias object for external DB connections (i.e. when not using DbConnection object)
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class DBAlias {
    private String name = null;
    private String db = null;
    private boolean noError = false;

    /**
     * Alias name
     * @param name String
     */
    public void setName(String name) {
        this.name = name;
    }

    public void setTargetDb(String db) {
        this.db = db;
    }

    public void setValue(String value) {
        this.db = value;
    }

    /**
     * If alias should be declared with NO-ERROR
     * @param noError "true|false|on|off|yes|no"
     */
    public void setNoError(boolean noError) {
        this.noError = noError;
    }

    /**
     * If alias should be declared with NO-ERROR
     * @return boolean
     */
    public boolean getNoError() {
        return this.noError;
    }

    /**
     * Alias name
     * @return String
     */
    public String getName() {
        return this.name;
    }

    public String getValue() {
        return db;
    }

    protected String getBgRunString() {
        return name + "|" + db + "|" + (noError ? 1 : 0);
    }
}
