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

import java.io.File;

/**
 * Describes an OUTPUT parameter which will be passed to a progress procedure. Value is written in a
 * property
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 * @since 0.14
 */
public class OutputParameter {
    private String propertyName = null;
    private File tempFile = null;
    private String progressVar = null;

    /**
     * Parameter name
     * 
     * @param name String
     */
    public void setName(String name) {
        this.propertyName = name;
    }

    /**
     * Returns parameter name
     * 
     * @return Parameter name
     */
    public String getName() {
        return this.propertyName;
    }

    /**
     * Temporary file where output parameter will be written. ANT reads this file to fill the
     * property
     */
    protected void setTempFileName(File file) {
        this.tempFile = file;
    }

    protected File getTempFileName() {
        return this.tempFile;
    }

    /**
     * Variable name in pctinit procedure
     */
    protected void setProgressVar(String progressVar) {
        this.progressVar = progressVar;
    }

    protected String getProgressVar() {
        return this.progressVar;
    }

    /**
     * An OutputParameter equals another one if propertyName are equals
     */
    @Override
    public boolean equals(Object obj) {
        if (!(obj instanceof OutputParameter))
            return false;
        if (propertyName == null)
            return false;

        return propertyName.equals(((OutputParameter) obj).getName());
    }

    /**
     * PropertyName hashCode
     */
    @Override
    public int hashCode() {
        return propertyName.hashCode();
    }
}
