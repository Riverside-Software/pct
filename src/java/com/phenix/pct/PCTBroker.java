/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) The Apache Software Foundation.  All rights
 * reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution, if
 *    any, must include the following acknowlegement:
 *       "This product includes software developed by the
 *        Apache Software Foundation (http://www.apache.org/)."
 *    Alternately, this acknowlegement may appear in the software itself,
 *    if and wherever such third-party acknowlegements normally appear.
 *
 * 4. The names "Ant" and "Apache Software
 *    Foundation" must not be used to endorse or promote products derived
 *    from this software without prior written permission. For written
 *    permission, please contact apache@apache.org.
 *
 * 5. Products derived from this software may not be called "Apache"
 *    nor may "Apache" appear in their names without prior written
 *    permission of the Apache Group.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE APACHE SOFTWARE FOUNDATION OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation.  For more
 * information on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 */
package com.phenix.pct;

import org.apache.tools.ant.BuildException;

/**
 * Abstract class managing AdminServer tasks
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET </a>
 * @version $Revision$
 */

public abstract class PCTBroker extends PCT {
    private final static String UPDATE = "update";
    private final static String CREATE = "create";
    private final static String DELETE = "delete";
    
    protected final static String UBROKER_PROPERTIES = "ubroker.properties";
    protected final static String CONMGR_PROPERTIES = "conmgr.properties";
    
    protected final static String MERGE_CLASS = "com.progress.common.property.MergeProperties";
    
    protected String action = null;
    protected String name = null;
    protected String file = null;
    protected String UID = null;
    
    public abstract void execute() throws BuildException;

    /**
     * Action type to handle. Must be create|update|delete
     * 
     * @param action String - Must be create|update|delete
     */
    public void setAction(String action) {
        if ((!action.equalsIgnoreCase(UPDATE)) && (!action.equalsIgnoreCase(CREATE)) && (!action.equalsIgnoreCase(DELETE))) {
            throw new BuildException("Unknown action : " + action);
        }
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
     * 
     * @param name
     */
    public void setName(String name) {
        this.name = name;
    }
    
    /**
     * 
     * @param uid String auto|none|uid
     */
    public void setUID(String uid) {
        this.UID = uid;
    }
}
