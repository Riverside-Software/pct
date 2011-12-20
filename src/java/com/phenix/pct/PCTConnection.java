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

import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * Object to add a database connection to a PCTRun task
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET </a>
 * @version $Revision$
 */
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
    private File paramFile = null;
    private boolean singleUser = false;
    private boolean readOnly = false;
    private Map aliases = null;

    /**
     * Database physical name (<CODE>-db</CODE> parameter)
     * 
     * @param dbName String
     */
    public void setDbName(String dbName) {
        this.dbName = dbName;
    }

    /**
     * Database directory
     * 
     * @param dbDir File
     */
    public void setDbDir(File dbDir) {
        this.dbDir = dbDir;
    }

    /**
     * Port name or number (<CODE>-S</CODE> parameter)
     * 
     * @param dbPort String
     */
    public void setDbPort(String dbPort) {
        this.dbPort = dbPort;
    }

    /**
     * Protocol to use (<CODE>-N</CODE> parameter)
     * 
     * @param protocol "AS400SNA|TCP"
     */
    public void setProtocol(String protocol) {
        this.protocol = protocol;
    }

    /**
     * Logical name to use (<CODE>-ld</CODE> parameter)
     * 
     * @param logicalName String
     */
    public void setLogicalName(String logicalName) {
        this.logicalName = logicalName;
    }

    /**
     * Name of the schema cache file (<CODE>-cache</CODE> parameter)
     * 
     * @param cacheFile File
     */
    public void setCacheFile(File cacheFile) {
        this.cacheFile = cacheFile;
    }

    /**
     * Name of the nameserver to connect to a dataserver (<CODE>-DataService</CODE> parameter)
     * 
     * @param dataService String
     */
    public void setDataService(String dataService) {
        this.dataService = dataService;
    }

    /**
     * Database type (ORACLE, SQLSERVER or nothing) (<CODE>-dt</CODE> parameter)
     * 
     * @param dbType String
     */
    public void setDbType(String dbType) {
        this.dbType = dbType;
    }

    /**
     * Host where to access database (<CODE>-H</CODE> parameter)
     * 
     * @param hostName String
     */
    public void setHostName(String hostName) {
        this.hostName = hostName;
    }

    /**
     * Username needed to access database (<CODE>-U</CODE> parameter)
     * 
     * @param userName String
     */
    public void setUserName(String userName) {
        this.userName = userName;
    }

    /**
     * Password needed to access database (<CODE>-P</CODE> parameter)
     * 
     * @param password String
     */
    public void setPassword(String password) {
        this.password = password;
    }

    /**
     * Parameter file (-pf attribute)
     * 
     * @param paramFile File
     */
    public void setParamFile(File paramFile) {
        this.paramFile = paramFile;
    }

    /**
     * If true, opens the database in read-only mode
     * 
     * @param readOnly true|false|on|off|yes|no
     */
    public void setReadOnly(boolean readOnly) {
        this.readOnly = readOnly;
    }

    /**
     * If true, opens the database in single-user mode
     * 
     * @param singleUser true|false|on|off|yes|no
     */
    public void setSingleUser(boolean singleUser) {
        this.singleUser = singleUser;
    }

    /**
     * Adds an alias to the current DB connection.
     * 
     * The previous method's name (addPCTAlias) was changed when I switched from Vector to HashMap
     * as a container for PCTAlias. When using addPCTAlias, you enter the method with a newly
     * created object but with undefined attributes. If you method is called addConfigured then the
     * object's attribute are set. See http://ant.apache.org/manual/develop.html#nested-elements
     * 
     * @param alias Instance of PCTAlias
     */
    public void addConfiguredPCTAlias(PCTAlias alias) {
        if (this.aliases == null) {
            aliases = new HashMap();
        }

        if (aliases.put(alias.getName(), alias) != null)
            throw new BuildException(MessageFormat.format(
                    Messages.getString("PCTConnection.0"), new Object[]{alias.getName()})); //$NON-NLS-1$
    }

    /**
     * Checks if aliases defined
     * 
     * @return True if aliases defined for this database connection
     */
    public boolean hasAliases() {
        if (aliases == null) {
            return false;
        } else {
            return (aliases.size() > 0);
        }
    }

    /**
     * Checks if an alias is defined
     * 
     * @param aliasName String
     * @return True if alias defined for this database connection
     */
    public boolean hasNamedAlias(String aliasName) {
        if (aliases == null) {
            return false;
        }

        return aliases.containsKey(aliasName);
    }

    /**
     * Returns an ordered list of connection parameters
     * 
     * @return List of String
     * @throws BuildException Something went wrong (dbName or paramFile not defined)
     */
    public List getConnectParametersList() {
        if ((dbName == null) && (paramFile == null)) {
            throw new BuildException(Messages.getString("PCTConnection.1")); //$NON-NLS-1$
        }

        List list = new ArrayList();
        if (dbName != null) {
            list.add("-db"); //$NON-NLS-1$

            if ((dbDir == null) || (hostName != null)) {
                list.add(dbName);
            } else {
                list.add(dbDir.toString() + File.separatorChar + dbName);
            }
        }

        if (paramFile != null) {
            list.add("-pf"); //$NON-NLS-1$
            list.add(paramFile.getAbsolutePath());
        }

        if (this.protocol != null) {
            list.add("-N"); //$NON-NLS-1$
            list.add(this.protocol);
        }

        if (this.dbPort != null) {
            list.add("-S"); //$NON-NLS-1$
            list.add(this.dbPort);
        }

        if (this.logicalName != null) {
            list.add("-ld"); //$NON-NLS-1$
            list.add(this.logicalName);
        }

        if (this.singleUser) {
            list.add("-1"); //$NON-NLS-1$
        }

        if (this.cacheFile != null) {
            list.add("-cache"); //$NON-NLS-1$
            list.add(this.cacheFile.getAbsolutePath());
        }

        if (this.dataService != null) {
            list.add("-DataService"); //$NON-NLS-1$
            list.add(this.dataService);
        }

        if (this.dbType != null) {
            list.add("-dt"); //$NON-NLS-1$
            list.add(this.dbType);
        }

        if (this.hostName != null) {
            list.add("-H"); //$NON-NLS-1$
            list.add(this.hostName);
        }

        if (this.readOnly) {
            list.add("-RO"); //$NON-NLS-1$
        }

        if (this.userName != null) {
            list.add("-U"); //$NON-NLS-1$
            list.add(this.userName);
            if(this.password != null) {
              list.add("-P"); //$NON-NLS-1$
              list.add(this.password);
            }
        }

        return list;

    }
    /**
     * Returns a string which could be used by a CONNECT statement or directly in a _progres or
     * prowin32 command line
     * 
     * @return Connection string
     * @throws BuildException If DB name or parameter file not defined
     */
    public String createConnectString() {
        List list = getConnectParametersList();
        StringBuffer sb = new StringBuffer();
        for (Iterator i = list.iterator(); i.hasNext();) {
            String s = PCTRun.escapeString((String) i.next());
            sb.append((s.indexOf(' ') == -1 ? s : "'" + s + "'")).append(' '); //$NON-NLS-1$ //$NON-NLS-2$
        }
        return sb.toString();
    }

    /**
     * Returns a string which could be used to connect a database from a background worker
     * Pipe separated list, first entry is connection string, followed by aliases.
     * Aliases are comma separated list, first entry is alias name, second is 1 if NO-ERROR, 0 w/o no-error
     * 
     * @return Connection string
     * @throws BuildException
     */
    public String createBackgroundConnectString() {
        StringBuffer sb = new StringBuffer(createConnectString());
        if (hasAliases()) {
            for (Iterator iter = getAliases().iterator(); iter.hasNext(); ) {
                PCTAlias alias = (PCTAlias) iter.next();
                sb.append('|').append(alias.getName()).append(',').append(alias.getNoError() ? '1' : '0');
            }
        }

        return sb.toString();
    }

    /**
     * Populates a command line with the needed arguments to connect to the specified database
     * 
     * @param task Exec task to populate
     * @throws BuildException Something went wrong
     */
    public void createArguments(ExecTask task) throws BuildException {
        List list = getConnectParametersList();
        for (Iterator i = list.iterator(); i.hasNext();) {
            task.createArg().setValue((String) i.next());
        }
    }

    /**
     * Returns defined aliases for a database connection
     * 
     * @return Collection
     */
    public Collection getAliases() {
        return (aliases == null ? null : aliases.values());
    }

    /**
     * Returns database name
     * 
     * @return String
     */
    public String getDbName() {
        if (this.logicalName != null) {
            return this.logicalName;
        } else {
            return this.dbName;
        }
    }
}