/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) 2002 The Apache Software Foundation.  All rights
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
import org.apache.tools.ant.taskdefs.ExecTask;

import java.io.File;

import java.util.Vector;


public class PCTConnection {
    private String dbName = null;
    private String dbPort = null;
    private String protocol = null;
    private String logicalName = null;
    private String dataService = null;
    private String dbType = null;
    private String hostName = null;
    private String userName = null;
    private String password = null;
    private File cacheFile = null;
    private File dbDir = null;
    private boolean singleUser = false;
    private boolean readOnly = false;
    private Vector aliases = null;

    /**
     * Database physical name (<CODE>-db</CODE> parameter)
     * @param dbName
     */
    public void setDbName(String dbName) {
        this.dbName = dbName;
    }

    /**
     * Database directory
     * @param dbDir
     */
    public void setDbDir(File dbDir) {
        this.dbDir = dbDir;
    }

    /**
     * Port name or number (<CODE>-S</CODE> parameter)
     * @param dbPort
     */
    public void setDbPort(String dbPort) {
        this.dbPort = dbPort;
    }

    /**
     * Protocol to use (<CODE>-N</CODE> parameter)
     * @param protocol "AS400SNA|TCP"
     */
    public void setProtocol(String protocol) {
        this.protocol = protocol;
    }

    /**
     * Logical name to use (<CODE>-ld</CODE> parameter)
     * @param logicalName
     */
    public void setLogicalName(String logicalName) {
        this.logicalName = logicalName;
    }

    /**
     * Name of the schema cache file (<CODE>-cache</CODE> parameter)
     * @param cacheFile
     */
    public void setCacheFile(File cacheFile) {
        this.cacheFile = cacheFile;
    }

    /**
     * Name of the nameserver to connect to a dataserver (<CODE>-DataService</CODE> parameter)
     * @param dataService
     */
    public void setDataService(String dataService) {
        this.dataService = dataService;
    }

    /**
     * Database type (ORACLE, SQLSERVER or nothing) (<CODE>-dt</CODE> parameter)
     * @param dbType
     */
    public void setDbType(String dbType) {
        this.dbType = dbType;
    }

    /**
     * Host where to access database (<CODE>-H</CODE> parameter)
     * @param hostName
     */
    public void setHostName(String hostName) {
        this.hostName = hostName;
    }

    /**
     * Username needed to access database (<CODE>-U</CODE> parameter)
     * @param userName
     */
    public void setUserName(String userName) {
        this.userName = userName;
    }

    /**
     * Password needed to access database (<CODE>-P</CODE> parameter)
     * @param password
     */
    public void setPassword(String password) {
        this.password = password;
    }

    /**
     * If true, opens the database in read-only mode
     * @param readOnly true|false|on|off|yes|no
     */
    public void setReadOnly(boolean readOnly) {
        this.readOnly = readOnly;
    }

    /**
     * If true, opens the database in single-user mode
     * @param singleUser true|false|on|off|yes|no
     */
    public void setSingleUser(boolean singleUser) {
        this.singleUser = singleUser;
    }

    /**
     * Adds an alias to the current DB connection
     * @param alias Instance of PCTAlias
     */
    public void addPCTAlias(PCTAlias alias) {
        if (this.aliases == null) {
            aliases = new Vector();
        }

        aliases.add(alias);
    }

    /**
     *
     * @return True if aliases defined for this DB connection
     */
    public boolean hasAliases() {
        if (aliases == null) {
            return false;
        } else {
            return (aliases.size() > 0);
        }
    }

    /**
     * Populates a command line with the needed arguments to connect to the specified database
     * @param cmdLine Command line to populate
     */
    public void createArguments(ExecTask task) throws BuildException {
        if (this.dbName == null) {
            throw new BuildException("Database name not defined");
        }

        task.createArg().setValue("-db");

        if ((this.dbDir == null) || (this.hostName != null)) {
            task.createArg().setValue(this.dbName);
        } else {
            task.createArg().setValue(this.dbDir.toString() + File.separatorChar + this.dbName);
        }

        if (this.protocol != null) {
            task.createArg().setValue("-N");
            task.createArg().setValue(this.protocol);
        }

        if (this.dbPort != null) {
            task.createArg().setValue("-S");
            task.createArg().setValue(this.dbPort);
        }

        if (this.logicalName != null) {
            task.createArg().setValue("-ld");
            task.createArg().setValue(this.logicalName);
        }

        if (this.singleUser) {
            task.createArg().setValue("-1");
        }

        if (this.cacheFile != null) {
            task.createArg().setValue("-cache");
            task.createArg().setValue(this.cacheFile.getAbsolutePath());
        }

        if (this.dataService != null) {
            task.createArg().setValue("-DataService");
            task.createArg().setValue(this.dataService);
        }

        if (this.dbType != null) {
            task.createArg().setValue("-dt");
            task.createArg().setValue(this.dbType);
        }

        if (this.hostName != null) {
            task.createArg().setValue("-H");
            task.createArg().setValue(this.hostName);
        }

        if (this.readOnly) {
            task.createArg().setValue("-RO");
        }

        if ((this.userName != null) && (this.password != null)) {
            task.createArg().setValue("-U");
            task.createArg().setValue(this.userName);
            task.createArg().setValue("-P");
            task.createArg().setValue(this.password);
        }
    }

    /**
     * Creates Progress code to define aliases
     */
    public Vector getAliases() {
        return aliases;
    }

    public String getDbName() {
        return this.dbName;
    }
}
