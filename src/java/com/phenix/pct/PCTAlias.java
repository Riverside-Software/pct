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

/**
 * Alias object for PCTConnection
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTAlias {
    private String name = null;
    private boolean noError = false;

    /**
     * Alias name
     * @param name String
     */
    public void setName(String name) {
        this.name = name;
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
}
