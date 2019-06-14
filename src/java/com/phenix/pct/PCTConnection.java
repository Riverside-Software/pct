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

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.ExecTask;
import org.apache.tools.ant.types.DataType;

import java.io.File;

import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Object to add a database connection to a PCTRun task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class PCTConnection extends DataType {
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
    private Boolean singleUser = null;
    private Boolean readOnly = null;
    private Map<String, PCTAlias> aliases = null;

    /**
     * Database physical name (<CODE>-db</CODE> parameter)
     * 
     * @param dbName String
     */
    public void setDbName(String dbName) {
        if (isReference())
            throw new BuildException("You must not specify dbName attribute when using refid");
        this.dbName = dbName;
    }

    /**
     * Database directory
     * 
     * @param dbDir File
     */
    public void setDbDir(File dbDir) {
        if (isReference())
            throw new BuildException("You must not specify dbDir attribute when using refid");
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
     * created object but with undefined attributes. If your method is called addConfigured then the
     * object's attribute are set. See http://ant.apache.org/manual/develop.html#nested-elements
     * 
     * @param alias Instance of PCTAlias
     */
    public void addConfiguredPCTAlias(PCTAlias alias) {
        addConfiguredAlias(alias);
    }

    public void addConfiguredAlias(PCTAlias alias) {
        if (this.aliases == null) {
            aliases = new HashMap<>();
        }

        if (aliases.put(alias.getName(), alias) != null)
            throw new BuildException(MessageFormat.format(
                    Messages.getString("PCTConnection.0"), alias.getName())); //$NON-NLS-1$
    }

    protected PCTConnection getRef() {
        return (PCTConnection) getCheckedRef();
    }

    /**
     * Checks if aliases defined
     * 
     * @return True if aliases defined for this database connection
     */
    public boolean hasAliases() {
        boolean refAliases = (isReference() ? getRef().hasAliases() : false);
        return (refAliases || (aliases == null ? false : (aliases.size() > 0)));
    }

    /**
     * Checks if an alias is defined
     * 
     * @param aliasName String
     * @return True if alias defined for this database connection
     */
    public boolean hasNamedAlias(String aliasName) {
        boolean refAliases = (isReference() ? getRef().hasNamedAlias(aliasName) : false);
        return (refAliases || (aliases == null ? false : (aliases.containsKey(aliasName))));
    }

    /**
     * Returns an ordered list of connection parameters
     * 
     * @return List of String
     * @throws BuildException Something went wrong (dbName or paramFile not defined)
     */
    public List<String> getConnectParametersList() {
        List<String> list = new ArrayList<>();
        if (isReference()) {
            list = getRef().getConnectParametersList();
        } else if ((dbName == null) && (paramFile == null)) {
            throw new BuildException(Messages.getString("PCTConnection.1")); //$NON-NLS-1$
        }

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

        if (protocol != null) {
            list.add("-N"); //$NON-NLS-1$
            list.add(protocol);
        }

        if (dbPort != null) {
            list.add("-S"); //$NON-NLS-1$
            list.add(dbPort);
        }

        if (logicalName != null) {
            list.add("-ld"); //$NON-NLS-1$
            list.add(logicalName);
        }

        if (singleUser != null) {
            if (singleUser) {
                list.add("-1"); //$NON-NLS-1$    
            }
            else {
                list.remove("-1");
         }
        }
       

        if (cacheFile != null) {
            list.add("-cache"); //$NON-NLS-1$
            list.add(cacheFile.getAbsolutePath());
        }

        if (dataService != null) {
            list.add("-DataService"); //$NON-NLS-1$
            list.add(dataService);
        }

        if (dbType != null) {
            list.add("-dt"); //$NON-NLS-1$
            list.add(dbType);
        }

        if (hostName != null) {
            list.add("-H"); //$NON-NLS-1$
            list.add(hostName);
        }

        if (readOnly != null ) {
            if (readOnly) {
                list.add("-RO");
            }
            else
            {
                list.remove("-RO");
            }
        }


        if ((userName != null) && (userName.trim().length() > 0)) {
            list.add("-U"); //$NON-NLS-1$
            list.add(userName);
            if ((password != null) && (password.trim().length() > 0)) {
                list.add("-P"); //$NON-NLS-1$
                list.add(password);
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
        StringBuilder sb = new StringBuilder();
        for (String str : getConnectParametersList()) {
            String s = PCTRun.escapeString(str);
            sb.append((s.indexOf(' ') == -1 ? s : "'" + s + "'")).append(' '); //$NON-NLS-1$ //$NON-NLS-2$
        }
        return sb.toString();
    }

    /**
     * Returns a string which could be used to connect a database from a background worker Pipe
     * separated list, first entry is connection string, followed by aliases. Aliases are comma
     * separated list, first entry is alias name, second is 1 if NO-ERROR, 0 w/o no-error
     * 
     * @return Connection string
     */
    public String createBackgroundConnectString() {
        StringBuilder sb = new StringBuilder(createConnectString());
        if (hasAliases()) {
            for (PCTAlias alias : getAliases()) {
                sb.append('|').append(alias.getName()).append(',')
                        .append(alias.getNoError() ? '1' : '0');
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
    public void createArguments(ExecTask task) {
        for (String str : getConnectParametersList()) {
            task.createArg().setValue(str);
        }
    }

    /**
     * Returns defined aliases for a database connection
     * 
     * @return Collection
     */
    public Collection<PCTAlias> getAliases() {
        Map<String, PCTAlias> map = new HashMap<>();
        if (aliases != null) {
            for (String str : aliases.keySet()) {
                map.put(str, aliases.get(str));
            }
        }
        if (isReference()) {
            for (PCTAlias alias : getRef().getAliases()) {
                map.put(alias.getName(), alias);
            }
        }

        return map.values();
    }

    /**
     * Returns database name
     * 
     * @return String
     */
    public String getDbName() {
        if (isReference())
            return getRef().getDbName();
        else if (logicalName != null) {
            return logicalName;
        } else {
            return dbName;
        }
    }

}