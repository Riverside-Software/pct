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
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.types.Commandline;
import org.apache.tools.ant.types.Path;

public class GenericExecuteOptions implements IRunAttributes {
    private final Task parent;

    private Collection<PCTConnection> dbConnList = null;
    private Collection<DBConnectionSet> dbConnSet = null;
    private Collection<DBAlias> aliases = null;
    private List<PCTRunOption> options = null;
    private List<RunParameter> runParameters = null;
    private List<OutputParameter> outputParameters = null;
    private Path propath = null;

    private int debugReady = -1;
    private boolean graphMode = false;
    private boolean debugPCT = false;
    private boolean compileUnderscore = false;
    private boolean batchMode = true;
    private boolean failOnError = true;
    private boolean quickRequest = true;
    private String dateFormat = null;
    private String cpStream = null;
    private String cpInternal = null;
    private String cpColl = null;
    private String cpCase = null;
    private String parameter = null;
    private String numsep = null;
    private String numdec = null;
    private String procedure = null;
    private File paramFile = null;
    private int inputChars = 0;
    private int dirSize = 0;
    private int centuryYearOffset = 0;
    private int token = 0;
    private int maximumMemory = 0;
    private int stackSize = 0;
    private int ttBufferSize = 0;
    private int messageBufferSize = 0;
    private File iniFile = null;
    private String resultProperty = null;
    private File tempDir = null;
    private File baseDir = null;
    private boolean verbose = false;
    private boolean relativePaths = false;
    private Profiler profiler = null;
    private File assemblies = null;
    private String mainCallback = null;
    private boolean noErrorOnQuit = false;
    private boolean superInit = true;
    private File output;
    private String xCodeSessionKey = null;

    public GenericExecuteOptions(Task parent) {
        this.parent = parent;
    }

    // *********************
    // IRunAttribute methods

    @Override
    public void addDBConnection(PCTConnection dbConn) {
        if (dbConnList == null) {
            dbConnList = new ArrayList<>();
        }
        dbConnList.add(dbConn);
    }

    @Override
    public void addDBConnectionSet(DBConnectionSet set) {
        if (this.dbConnSet == null)
            this.dbConnSet = new ArrayList<>();

        dbConnSet.add(set);
    }

    @Override
    public void addDBAlias(DBAlias alias) {
        if (aliases == null) {
            aliases = new ArrayList<>();
        }
        aliases.add(alias);
    }

    @Override
    public void addOption(PCTRunOption option) {
        if (options == null) {
            options = new ArrayList<>();
        }
        options.add(option);
    }

    @Override
    public void addParameter(RunParameter param) {
        if (runParameters == null) {
            runParameters = new ArrayList<>();
        }
        runParameters.add(param);
    }

    @Override
    public void addOutputParameter(OutputParameter param) {
        if (outputParameters == null) {
            outputParameters = new ArrayList<>();
        }
        outputParameters.add(param);
    }

    @Override
    public void addPropath(Path propath) {
        createPropath().append(propath);
    }

    @Override
    public void setParamFile(File pf) {
        paramFile = pf;
    }

    @Override
    public void setNumSep(String numsep) {
        this.numsep = numsep;
    }

    @Override
    public void setNumDec(String numdec) {
        this.numdec = numdec;
    }

    @Override
    public void setParameter(String param) {
        this.parameter = param;
    }

    @Override
    public void setDebugPCT(boolean debugPCT) {
        this.debugPCT = debugPCT;
    }

    @Override
    public void setCompileUnderscore(boolean compUnderscore) {
        this.compileUnderscore = compUnderscore;
    }

    @Override
    public void setDirSize(int dirSize) {
        this.dirSize = dirSize;
    }

    @Override
    public void setGraphicalMode(boolean graphMode) {
        this.graphMode = graphMode;
    }

    @Override
    public void setIniFile(File iniFile) {
        if ((iniFile != null) && !iniFile.exists()) {
            parent.log("Unable to find INI file " + iniFile.getAbsolutePath() + " - Skipping attribute");
            return;
        }
        this.iniFile = iniFile;
    }

    @Override
    public void setCpStream(String cpStream) {
        this.cpStream = cpStream;
    }

    @Override
    public void setCpInternal(String cpInternal) {
        this.cpInternal = cpInternal;
    }

    @Override
    public void setCpColl(String cpColl) {
        this.cpColl = cpColl;
    }

    @Override
    public void setCpCase(String cpCase) {
        this.cpCase = cpCase;
    }

    @Override
    public void setInputChars(int inputChars) {
        this.inputChars = inputChars;
    }

    @Override
    public void setDateFormat(String dateFormat) {
        this.dateFormat = dateFormat;
    }

    @Override
    public void setCenturyYearOffset(int centuryYearOffset) {
        this.centuryYearOffset = centuryYearOffset;
    }

    @Override
    public void setToken(int token) {
        this.token = token;
    }

    @Override
    public void setMaximumMemory(int maximumMemory) {
        this.maximumMemory = maximumMemory;
    }

    @Override
    public void setStackSize(int stackSize) {
        this.stackSize = stackSize;
    }

    @Override
    public void setTTBufferSize(int ttBufferSize) {
        this.ttBufferSize = ttBufferSize;
    }

    @Override
    public void setMsgBufferSize(int msgBufSize) {
        this.messageBufferSize = msgBufSize;
    }

    @Override
    public void setDebugReady(int debugReady) {
        this.debugReady = debugReady;
    }

    @Override
    public void setTempDir(File tempDir) {
        this.tempDir = tempDir;
    }

    @Override
    public void setBaseDir(File baseDir) {
        this.baseDir = baseDir;
    }

    @Override
    public void setResultProperty(String resultProperty) {
        this.resultProperty = resultProperty;
    }

    @Override
    public void setRelativePaths(boolean relativePaths) {
        this.relativePaths = relativePaths;
    }

    @Override
    public void addProfiler(Profiler profiler) {
        if (this.profiler != null) {
            throw new BuildException("Only one Profiler node can be defined");
        }
        this.profiler = profiler;
    }

    @Override
    public void setFailOnError(boolean failOnError) {
        this.failOnError = failOnError;
    }

    @Override
    public void setQuickRequest(boolean quickRequest) {
        this.quickRequest = quickRequest;
    }

    @Override
    public void setAssemblies(String assemblies) {
        if ((assemblies == null) || (assemblies.trim().length() == 0)) {
            return;
        }
        File file = parent.getProject().resolveFile(assemblies);
        if (!file.exists()) {
            parent.log("Unable to find assemblies file " + file.getAbsolutePath() + " - Skipping attribute");
            return;
        }

        this.assemblies = file;
    }

    @Override
    public void setProcedure(String procedure) {
        this.procedure = procedure;
    }

    @Override
    public void setMainCallback(String mainCallback) {
        this.mainCallback = mainCallback;
    }

    @Override
    public void setNoErrorOnQuit(boolean noErrorOnQuit) {
        this.noErrorOnQuit = noErrorOnQuit;
    }

    @Override
    public void setSuperInit(boolean superInit) {
        this.superInit = superInit;
    }

    @Override
    public void setOutput(File output) {
        this.output = output;
    }

    @Override
    public void setXCodeSessionKey(String xCodeSessionKey) {
        this.xCodeSessionKey = xCodeSessionKey;
    }

    // End of IRunAttribute methods
    // ****************************

    public Collection<PCTConnection> getDbConnList() {
        return dbConnList;
    }

    public List<RunParameter> getRunParameters() {
        return runParameters;
    }

    public Path getPropath() {
        return propath;
    }

    public int getDebugReady() {
        return debugReady;
    }

    public boolean isGraphMode() {
        return graphMode;
    }

    public boolean isDebugPCT() {
        return debugPCT;
    }

    public boolean isCompileUnderscore() {
        return compileUnderscore;
    }

    public boolean isBatchMode() {
        return batchMode;
    }

    public String getCpStream() {
        return cpStream;
    }

    public String getCpInternal() {
        return cpInternal;
    }

    public String getCpCase() {
        return cpCase;
    }
    
    public String getCpColl() {
        return cpColl;
    }

    public String getParameter() {
        return parameter;
    }

    public String getNumsep() {
        return numsep;
    }

    public String getNumdec() {
        return numdec;
    }

    public int getInputChars() {
        return inputChars;
    }

    public int getDirSize() {
        return dirSize;
    }

    public String getDateFormat() {
        return dateFormat;
    }

    public int getCenturyYearOffset() {
        return centuryYearOffset;
    }

    public int getToken() {
        return token;
    }

    public int getMaximumMemory() {
        return maximumMemory;
    }

    public int getStackSize() {
        return stackSize;
    }

    public int getTtBufferSize() {
        return ttBufferSize;
    }

    public int getMessageBufferSize() {
        return messageBufferSize;
    }

    public File getIniFile() {
        return iniFile;
    }

    public String getResultProperty() {
        return resultProperty;
    }

    public File getTempDir() {
        return tempDir;
    }

    public File getBaseDir() {
        return baseDir;
    }

    public String getProcedure() {
        return procedure;
    }

    public File getAssemblies() {
        return assemblies;
    }

    public boolean isVerbose() {
        return verbose;
    }

    public Profiler getProfiler() {
        return profiler;
    }

    public void setBatchMode(boolean batchMode) {
        this.batchMode = batchMode;
    }

    public File getOutput() {
        return output;
    }

    public String getXCodeSessionKey() {
        return xCodeSessionKey;
    }

    protected List<String> getCmdLineParameters() {
        List<String> list = new ArrayList<>();

        // Parameter file
        if (paramFile != null) {
            list.add("-pf"); //$NON-NLS-1$
            list.add(paramFile.getAbsolutePath());
        }

        // Batch mode
        if (batchMode) {
            list.add("-b"); //$NON-NLS-1$
        }

        // Quick request
        if (quickRequest) {
            list.add("-q"); //$NON-NLS-1$
        }

        // DebugReady
        if (debugReady != -1) {
            list.add("-debugReady"); //$NON-NLS-1$
            list.add(Integer.toString(debugReady));
        }

        // Inifile
        if (iniFile != null) {
            list.add("-basekey"); //$NON-NLS-1$
            list.add("INI"); //$NON-NLS-1$
            list.add("-ininame"); //$NON-NLS-1$
            list.add(Commandline.quoteArgument(iniFile.getAbsolutePath()));
        }

        // Max length of a line
        if (inputChars != 0) {
            list.add("-inp"); //$NON-NLS-1$
            list.add(Integer.toString(inputChars));
        }

        // Stream code page
        if (cpStream != null) {
            list.add("-cpstream"); //$NON-NLS-1$
            list.add(cpStream);
        }

        // Internal code page
        if (cpInternal != null) {
            list.add("-cpinternal"); //$NON-NLS-1$
            list.add(cpInternal);
        }

        // Collation table
        if (cpColl != null) {
            list.add("-cpcoll"); //$NON-NLS-1$
            list.add(cpColl);
        }

        // Case table
        if (cpCase != null) {
            list.add("-cpcase"); //$NON-NLS-1$
            list.add(cpCase);
        }

        // Directory size
        if (dirSize != 0) {
            list.add("-D"); //$NON-NLS-1$
            list.add(Integer.toString(dirSize));
        }

        if (centuryYearOffset != 0) {
            list.add("-yy"); //$NON-NLS-1$
            list.add(Integer.toString(centuryYearOffset));
        }

        if (maximumMemory != 0) {
            list.add("-mmax"); //$NON-NLS-1$
            list.add(Integer.toString(maximumMemory));
        }

        if (stackSize != 0) {
            list.add("-s"); //$NON-NLS-1$
            list.add(Integer.toString(stackSize));
        }

        if (token != 0) {
            list.add("-tok"); //$NON-NLS-1$
            list.add(Integer.toString(token));
        }

        if (messageBufferSize != 0) {
            list.add("-Mm"); //$NON-NLS-1$
            list.add(Integer.toString(messageBufferSize));
        }

        if (compileUnderscore) {
            list.add("-zn"); //$NON-NLS-1$
        }

        if (ttBufferSize != 0) {
            list.add("-Bt"); //$NON-NLS-1$
            list.add(Integer.toString(ttBufferSize));
        }

        if (numsep != null) {
            int tmpSep = 0;
            try {
                tmpSep = Integer.parseInt(numsep);
            } catch (NumberFormatException nfe) {
                if (numsep.length() == 1)
                    tmpSep = numsep.charAt(0);
                else
                    throw new BuildException(MessageFormat.format(Messages.getString("PCTRun.4"), //$NON-NLS-1$
                            "numsep"), nfe); //$NON-NLS-1$
            }
            list.add("-numsep"); //$NON-NLS-1$
            list.add(Integer.toString(tmpSep));
        }

        if (numdec != null) {
            int tmpDec = 0;
            try {
                tmpDec = Integer.parseInt(numdec);
            } catch (NumberFormatException nfe) {
                if (numdec.length() == 1)
                    tmpDec = numdec.charAt(0);
                else
                    throw new BuildException(MessageFormat.format(Messages.getString("PCTRun.4"), //$NON-NLS-1$
                            "numdec")); //$NON-NLS-1$
            }
            list.add("-numdec"); //$NON-NLS-1$
            list.add(Integer.toString(tmpDec));
        }

        if ((dateFormat != null) && (dateFormat.trim().length() > 0)) {
            list.add("-d");
            list.add(dateFormat.trim());
        }

        // Parameter
        if (parameter != null) {
            list.add("-param"); //$NON-NLS-1$
            list.add(parameter);
        }

        // Temp directory
        if (tempDir != null) {
            if (!tempDir.isDirectory()) {
                throw new BuildException(MessageFormat.format(Messages.getString("PCTRun.7"), //$NON-NLS-1$
                        tempDir));
            }
            list.add("-T");
            list.add(tempDir.getAbsolutePath());
        }

        if (assemblies != null) {
            list.add("-assemblies");
            list.add(assemblies.getAbsolutePath());
        }

        // Additional command line options
        if (options != null) {
            for (PCTRunOption opt : options) {
                if (opt.getName() == null) {
                    throw new BuildException("PCTRun.8"); //$NON-NLS-1$
                }
                list.add(opt.getName());
                if (opt.getValue() != null)
                    list.add(opt.getValue());
            }
        }

        return list;
    }

    /**
     * Returns list of database connections, from dbConnList and dbConnSet
     * 
     * @return List of PCTConnection objects. Empty list if no DB connections
     */
    public Collection<PCTConnection> getDBConnections() {
        Collection<PCTConnection> dbs = new ArrayList<>();
        if (dbConnList != null) {
            dbs.addAll(dbConnList);
        }
        if (dbConnSet != null) {
            for (DBConnectionSet set : dbConnSet) {
                dbs.addAll(set.getDBConnections());
            }
        }
        return dbs;
    }

    public Collection<PCTConnection> getAllDbConnections() {
        Collection<PCTConnection> coll = new ArrayList<>();
        if (dbConnSet != null) {
            for (DBConnectionSet set : dbConnSet) {
                coll.addAll(set.getDBConnections());
            }
        }
        if (dbConnList != null) {
            for (PCTConnection conn : dbConnList) {
                coll.add(conn);
            }
        }

        return coll;
    }

    public Collection<DBAlias> getAliases() {
        return aliases;
    }

    /**
     * Returns list of command line options.
     * 
     * @return List of PCTRunOption objects. Empty list if no options.
     */
    public List<PCTRunOption> getOptions() {
        return (options == null ? new ArrayList<PCTRunOption>() : options);
    }

    /**
     * Returns list of parameters passed to the called Progress procedure.
     * 
     * @return List of RunParameters objects. Empty list if no parameter.
     */
    public List<RunParameter> getParameters() {
        return (runParameters == null ? new ArrayList<RunParameter>() : runParameters);
    }

    /**
     * Returns list of output parameters to be filled by the called Progress procedure.
     * 
     * @return List of OutputParameter objects. Empty list if no parameter.
     */
    public List<OutputParameter> getOutputParameters() {
        return (outputParameters == null ? new ArrayList<OutputParameter>() : outputParameters);
    }

    public File getParamFile() {
        return paramFile;
    }

    /**
     * Creates a new Path instance
     * 
     * @return Path
     */
    public Path createPropath() {
        if (propath == null) {
            propath = new Path(parent.getProject());
        }

        return propath;
    }

    public boolean useRelativePaths() {
        return relativePaths;
    }

    public boolean isFailOnError() {
        return failOnError;
    }

    public String getMainCallback() {
        return mainCallback;
    }

    public boolean useNoErrorOnQuit() {
        return noErrorOnQuit;
    }

    public boolean isSuperInit() {
        return superInit;
    }
}
