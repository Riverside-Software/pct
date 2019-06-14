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
 * Describes a parameter which will be passed to a progress procedure within a temp-table
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 * @version $Revision$
 */
public class RunParameter {
    private String name = null;
    private String value = null;

    public RunParameter() {
        // Empty constructor for Ant reflection
    }

    public RunParameter(String name, String value) {
        this.name = name;
        this.value = value;
    }

    /**
     * Parameter name
     * 
     * @param name String
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * Parameter value
     * 
     * @param value String
     */
    public void setValue(String value) {
        this.value = value;
    }

    /**
     * Returns parameter name
     * 
     * @return Parameter name
     */
    public String getName() {
        return this.name;
    }

    /**
     * Returns parameter value
     * 
     * @return Parameter value
     */
    public String getValue() {
        return this.value;
    }

    public boolean validate() {
        if (this.value == null)
            this.value = "";
        return (this.name != null);
    }
}
