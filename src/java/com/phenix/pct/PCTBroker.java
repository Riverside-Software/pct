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
 * Abstract class managing AdminServer tasks
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */

public abstract class PCTBroker extends PCT {
    protected static final String UPDATE = "update";
    protected static final String CREATE = "create";
    protected static final String DELETE = "delete";

    protected static final String UBROKER_PROPERTIES = "ubroker.properties";
    protected static final String CONMGR_PROPERTIES = "conmgr.properties";

    protected static final String MERGE_CLASS = "com.progress.common.property.MergeProperties";

    protected static final String UNKNOWN_ATTR = "Unknown attribute";

    protected String action = null;
    protected String name = null;
    protected String file = null;
    protected String uid = "none";

    /**
     * Action type to handle. Must be create|update|delete
     * 
     * @param action String - Must be create|update|delete
     */
    public void setAction(String action) {
        this.action = action;
    }

    /**
     * Properties file to update. If this method is not called, falls back to default file depending
     * on action, ie $DLC/properties/ubroker.properties for appservers or
     * $DLC/properties/conmgr.properties for databases
     * 
     * @param file File
     */
    public void setFile(String file) {
        this.file = file;
    }

    /**
     * Set broker name. No default value.
     * 
     * @param name String
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * Set unique identifier for broker. Default value is none.
     * 
     * @param uid String auto|none|uid
     */
    public void setUID(String uid) {
        this.uid = uid;
    }
}
