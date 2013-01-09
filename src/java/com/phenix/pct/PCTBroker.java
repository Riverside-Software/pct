/*
 * Copyright  2000-2004 The Apache Software Foundation
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

import org.apache.tools.ant.BuildException;

/**
 * Abstract class managing AdminServer tasks
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 * @version $Revision$
 */

public abstract class PCTBroker extends PCT {
    protected final static String UPDATE = "update";
    protected final static String CREATE = "create";
    protected final static String DELETE = "delete";
    
    protected final static String UBROKER_PROPERTIES = "ubroker.properties";
    protected final static String CONMGR_PROPERTIES = "conmgr.properties";
    
    protected final static String MERGE_CLASS = "com.progress.common.property.MergeProperties";
    
    protected String action = null;
    protected String name = null;
    protected String file = null;
    protected String UID = "none";
    
    public abstract void execute() throws BuildException;

    /**
     * Action type to handle. Must be create|update|delete
     * 
     * @param action String - Must be create|update|delete
     */
    public void setAction(String action) {
        this.action = action;
    }

    /**
     * Properties file to update. If this method is not called, falls back to default
     * file depending on action, ie $DLC/properties/ubroker.properties for appservers 
     * or $DLC/properties/conmgr.properties for databases
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
        this.UID = uid;
    }
}
