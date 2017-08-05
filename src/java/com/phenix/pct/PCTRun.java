/**
 * Copyright 2005-2018 Riverside Software
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

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.io.Writer;
import java.nio.charset.Charset;
import java.text.MessageFormat;
import java.util.Collection;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.taskdefs.ExecTask;
import org.apache.tools.ant.types.Environment;
import org.apache.tools.ant.types.Environment.Variable;
import org.apache.tools.ant.types.FileList;
import org.apache.tools.ant.types.Path;
import org.apache.tools.ant.util.FileUtils;

/**
 * Run a Progress procedure.
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class PCTRun extends PCT implements IRunAttributes {
    protected GenericExecuteOptions runAttributes;
    
    protected Path internalPropath = null;

    // Internal use
    protected ExecTask exec = null;
    protected int statusID = -1; // Unique ID when creating temp files
    protected int initID = -1; // Unique ID when creating temp files
    protected int plID = -1; // Unique ID when creating temp files
    private int xcodeID = -1; // Unique ID when creating temp files
    private int profilerID = -1; // Unique ID when creating temp files
    private int profilerOutID = -1; // Unique ID when creating temp files
    protected File initProc = null;
    protected File status = null;
    protected File pctLib = null;
    private File xcodeDir = null;
    private File profilerParamFile = null;
    private boolean prepared = false;
    private Charset charset = null;

    /**
     * Default constructor
     * 
     */
    public PCTRun() {
        this(true);
    }

    /**
     * Default constructor
     * 
     * @param tmp True if temporary files need to be created
     */
    public PCTRun(boolean tmp) {
        super();
        runAttributes = new GenericExecuteOptions(this);

        if (tmp) {
            statusID = PCT.nextRandomInt();
            initID = PCT.nextRandomInt();
            plID = PCT.nextRandomInt();
            profilerID = PCT.nextRandomInt();
            profilerOutID = PCT.nextRandomInt();
            xcodeID = PCT.nextRandomInt();

            status = new File(System.getProperty(PCT.TMPDIR), "PCTResult" + statusID + ".out"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
            initProc = new File(System.getProperty(PCT.TMPDIR), "pctinit" + initID + ".p"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
            profilerParamFile = new File(
                    System.getProperty(PCT.TMPDIR), "prof" + profilerID + ".pf"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
            // XCode temp directory
            xcodeDir = new File(System.getProperty(PCT.TMPDIR), "xcode" + xcodeID); 
        }
    }

    public PCTRun(boolean tmp, boolean batchMode) {
        this(tmp);
        runAttributes.setBatchMode(batchMode);
    }

    protected void setRunAttributes(GenericExecuteOptions attrs) {
        this.runAttributes = attrs;
    }

    /**
     * Tells underlying Progress session to be verbose
     * @deprecated
     */
    @Deprecated
    public void setVerbose(boolean verbose) {
        log("verbose attribute is not used anymore, please use the standard -v switch");
    }

    // Legacy method
    @Deprecated
    public void addPCTConnection(PCTConnection dbConn) {
        addDBConnection(dbConn);
    }

    // Slightly different syntax for antlib
    public void addDB_Connection(PCTConnection dbConn) {
        addDBConnection(dbConn);
    }

    // Slightly different syntax for antlib
    public void addDB_Connection_Set(DBConnectionSet set) {
        addDBConnectionSet(set);
    }

    // Legacy
    @Deprecated
    public void addPCTRunOption(PCTRunOption option) {
        addOption(option);
    }

    /**
     * Adds a collection of parameters
     */
    protected void setParameters(Collection<RunParameter> params) {
        for (RunParameter p : params) {
            runAttributes.addParameter(p);
        }
    }

    // **********************
    // IRunAttributes methods

    @Override
    public void addDBConnection(PCTConnection dbConn) {
        runAttributes.addDBConnection(dbConn);
    }

    @Override
    public void addDBConnectionSet(DBConnectionSet set) {
        runAttributes.addDBConnectionSet(set);
    }

    @Override
    public void addDBAlias(DBAlias alias) {
        runAttributes.addDBAlias(alias);
    }

    @Override
    public void addOption(PCTRunOption option) {
        runAttributes.addOption(option);
    }

    @Override
    public void addParameter(RunParameter param) {
        runAttributes.addParameter(param);
    }

    @Override
    public void addOutputParameter(OutputParameter param) {
        runAttributes.addOutputParameter(param);
    }

    @Override
    public void setParamFile(File pf) {
        runAttributes.setParamFile(pf);
    }

    @Override
    public void setNumSep(String numsep) {
        runAttributes.setNumSep(numsep);
    }

    @Override
    public void setNumDec(String numdec) {
        runAttributes.setNumDec(numdec);
    }

    @Override
    public void setParameter(String param) {
        runAttributes.setParameter(param);
    }

    @Override
    public void setDebugPCT(boolean debugPCT) {
        runAttributes.setDebugPCT(debugPCT);
    }
    
    @Override
    public void setCompileUnderscore(boolean compUnderscore) {
        runAttributes.setCompileUnderscore(compUnderscore);
    }

    @Override
    public void setDirSize(int dirSize) {
        runAttributes.setDirSize(dirSize);
    }

    @Override
    public void setGraphicalMode(boolean graphMode) {
        runAttributes.setGraphicalMode(graphMode);
    }

    @Override
    public void setIniFile(File iniFile) {
        runAttributes.setIniFile(iniFile);
    }

    @Override
    public void setFailOnError(boolean failOnError) {
        runAttributes.setFailOnError(failOnError);
    }

    @Override
    public void setQuickRequest(boolean quickRequest) {
        runAttributes.setQuickRequest(quickRequest);
    }

    @Override
    public void setProcedure(String procedure) {
        runAttributes.setProcedure(procedure);
    }

    @Override
    public void setXCodeSessionKey(String xCodeSessionKey) {
        runAttributes.setXCodeSessionKey(xCodeSessionKey);
    }

    @Override
    public void setInputChars(int inputChars) {
        runAttributes.setInputChars(inputChars);
    }

    @Override
    public void setDateFormat(String dateFormat) {
        runAttributes.setDateFormat(dateFormat);
    }

    @Override
    public void setCenturyYearOffset(int centuryYearOffset) {
        runAttributes.setCenturyYearOffset(centuryYearOffset);
    }

    @Override
    public void setToken(int token) {
        runAttributes.setToken(token);
    }

    @Override
    public void setMaximumMemory(int maximumMemory) {
        runAttributes.setMaximumMemory(maximumMemory);
    }

    @Override
    public void setStackSize(int stackSize) {
        runAttributes.setStackSize(stackSize);
    }

    @Override
    public void setTTBufferSize(int ttBufferSize) {
        runAttributes.setTTBufferSize(ttBufferSize);
    }

    @Override
    public void setMsgBufferSize(int msgBufSize) {
        runAttributes.setMsgBufferSize(msgBufSize);
    }

    @Override
    public void setDebugReady(int debugReady) {
        runAttributes.setDebugReady(debugReady);
    }

    @Override
    public void setTempDir(File tempDir) {
        runAttributes.setTempDir(tempDir);
    }

    @Override
    public void setBaseDir(File baseDir) {
        runAttributes.setBaseDir(baseDir);
    }

    @Override
    public void addPropath(Path propath) {
        runAttributes.addPropath(propath);
    }

    @Override
    public void setCpStream(String cpStream) {
        runAttributes.setCpStream(cpStream);
    }

    @Override
    public void setCpInternal(String cpInternal) {
        runAttributes.setCpInternal(cpInternal);
    }

    @Override
    public void setAssemblies(String assemblies) {
        runAttributes.setAssemblies(assemblies);
    }

    @Override
    public void setCpColl(String cpColl) {
        runAttributes.setCpColl(cpColl);
    }

    @Override
    public void setCpCase(String cpCase) {
        runAttributes.setCpCase(cpCase);
    }

    @Override
    public void setResultProperty(String resultProperty) {
        runAttributes.setResultProperty(resultProperty);
    }

    @Override
    public void setRelativePaths(boolean relativePaths) {
        runAttributes.setRelativePaths(relativePaths);
    }

    @Override
    public void addProfiler(Profiler profiler) {
        runAttributes.addProfiler(profiler);
    }

    @Override
    public void setMainCallback(String mainCallback) {
        runAttributes.setMainCallback(mainCallback);
    }

    @Override
    public void setNoErrorOnQuit(boolean noErrorOnQuit) {
        runAttributes.setNoErrorOnQuit(noErrorOnQuit);
    }

    @Override
    public void setSuperInit(boolean superInit) {
        runAttributes.setSuperInit(superInit);
    }

    @Override
    public void setOutput(File output) {
        runAttributes.setOutput(output);
    }

    // End of IRunAttribute methods
    // ****************************

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    @Override
    public void execute() {

        checkDlcHome();
        if ((runAttributes.getProcedure() == null) || (runAttributes.getProcedure().length() == 0))
            throw new BuildException("Procedure attribute not defined");

        if (!prepared) {
            prepareExecTask();
            if (runAttributes.getProfiler() != null) {
                runAttributes.getProfiler().validate(false);
            }
        }

        try {
            // File name generation is deffered at this stage, because when defined in constructor,
            // we still don't know if we have to use source code or compiled version. And it's
            // impossible to extract source code to a directory named something.pl as Progress tries
            // to open a procedure library, and miserably fails with error 13.
            pctLib = new File(
                    System.getProperty(PCT.TMPDIR), "pct" + plID + (isSourceCodeUsed() ? "" : ".pl")); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$

            preparePropath();
            createInitProcedure();
            createProfilerFile();
            setExecTaskParams();

            // Startup procedure
            exec.createArg().setValue("-p"); //$NON-NLS-1$
            exec.createArg().setValue(initProc.getAbsolutePath());
            if (getIncludedPL() && !extractPL(pctLib)) {
                throw new BuildException("Unable to extract pct.pl.");
            }

            // OE12 ? Define failOnError and resultProperty
            if (getDLCMajorVersion() >= 12) {
                exec.setFailonerror(runAttributes.isFailOnError());
                if (runAttributes.getResultProperty() != null)
                    exec.setResultProperty(runAttributes.getResultProperty());
            }

            exec.execute();
        } catch (BuildException be) {
            cleanup();
            throw be;
        } catch (IOException caught) {
            cleanup();
            throw new BuildException(caught);
        }

        // Reads output parameter
        if (runAttributes.getOutputParameters() != null) {
            for (OutputParameter param : runAttributes.getOutputParameters()) {
                File f = param.getTempFileName();
                try (InputStream fis = new FileInputStream(f);
                        Reader r = new InputStreamReader(fis, Charset.forName("utf-8"));
                        BufferedReader br = new BufferedReader(r)) {
                    String s = br.readLine();
                    getProject().setNewProperty(param.getName(), s);
                } catch (IOException ioe) {
                    log(MessageFormat.format(
                            Messages.getString("PCTRun.10"), param.getName(), f.getAbsolutePath()), Project.MSG_ERR); //$NON-NLS-1$
                    cleanup();
                    throw new BuildException(ioe);
                }
            }
        }

        if (getDLCMajorVersion() >= 12)
            return;

        // Now read status file
        try (Reader r = new FileReader(status); BufferedReader br = new BufferedReader(r)) {
            String s = br.readLine();
            int ret = Integer.parseInt(s);
            if (ret != 0 && runAttributes.isFailOnError()) {
                throw new BuildException(MessageFormat.format(Messages.getString("PCTRun.6"), ret)); //$NON-NLS-1$
            }
            maybeSetResultPropertyValue(ret);
        } catch (IOException caught) {
            throw new BuildException(Messages.getString("PCTRun.2"), caught); //$NON-NLS-1$
        } catch (NumberFormatException caught) {
            throw new BuildException(Messages.getString("PCTRun.3"), caught); //$NON-NLS-1$
        } finally {
            cleanup();
        }
    }

    // In order to know if Progress session has to use verbose logging
    protected boolean isVerbose() {
        return getAntLoggerLever() > 2;
    }

    // Helper method to set result property to the passed in value if appropriate.
    protected void maybeSetResultPropertyValue(int result) {
        if (runAttributes.getResultProperty() != null) {
            String res = Integer.toString(result);
            getProject().setNewProperty(runAttributes.getResultProperty(), res);
        }
    }

    /**
     * Is Exec task prepared ?
     */
    protected boolean isPrepared() {
        return this.prepared;
    }

    /**
     * Returns status file name (where to write progress procedure result)
     */
    protected String getStatusFileName() {
        return status.getAbsolutePath();
    }

    /**
     * Creates and initialize
     */
    protected void prepareExecTask() {
        if (!prepared) {
            exec = new ExecTask(this);

            Environment.Variable var = new Environment.Variable();
            var.setKey("DLC"); //$NON-NLS-1$
            var.setValue(getDlcHome().toString());
            exec.addEnv(var);

            for (Variable var2 : getEnvironmentVariables()) {
                exec.addEnv(var2);
            }
        }

        this.prepared = true;
    }

    protected void setExecTaskParams() {
        exec.setExecutable(getAVMExecutable(runAttributes.isGraphMode()).toString());

        for (String str : runAttributes.getCmdLineParameters()) {
            exec.createArg().setValue(str);
        }
        if ((runAttributes.getProfiler() != null) && runAttributes.getProfiler().isEnabled()) {
            exec.createArg().setValue("-profile");
            exec.createArg().setValue(profilerParamFile.getAbsolutePath());
        }

        // Check for base directory
        if ((runAttributes.getBaseDir() != null) && runAttributes.getBaseDir().isDirectory()) {
            exec.setDir(runAttributes.getBaseDir());
        }

        if (runAttributes.getOutput() != null) {
            exec.setOutput(runAttributes.getOutput());
        }
    }

    /**
     * Returns charset to be used when writing files in Java to be read by Progress session (thus
     * according to cpstream, parameter files, ...) and dealing with OE encodings (such as undefined
     * or 1252)
     */
    protected Charset getCharset() {
        if (charset != null) {
            return charset;
        }

        String zz = readCharset();
        try {
            if (zz != null) {
                // Central Europe
                if ("1250".equals(zz))
                    zz = "windows-1250";
                // Cyrillic
                if ("1251".equals(zz))
                    zz = "windows-1251";
                // Western Europe
                if ("1252".equals(zz))
                    zz = "windows-1252";
                // Greek
                if ("1253".equals(zz))
                    zz = "windows-1253";
                // Turkish
                if ("1254".equals(zz))
                    zz = "windows-1254";
                // Hebrew
                if ("1255".equals(zz))
                    zz = "windows-1255";
                // Arabic
                if ("1256".equals(zz))
                    zz = "windows-1256";
                // Baltic
                if ("1257".equals(zz))
                    zz = "windows-1257";
                // Vietnamese
                if ("1258".equals(zz))
                    zz = "windows-1258";
                if ("big-5".equalsIgnoreCase(zz))
                    zz = "Big5";
                charset = Charset.forName(zz);
            }
        } catch (IllegalArgumentException caught) {
            log(MessageFormat.format(Messages.getString("PCTCompile.46"), zz), Project.MSG_INFO); //$NON-NLS-1$
            charset = Charset.defaultCharset();
        }
        if (charset == null) {
            log(Messages.getString("PCTCompile.47"), Project.MSG_VERBOSE); //$NON-NLS-1$
            charset = Charset.defaultCharset();
        }

        return charset;
    }

    private String readCharset() {
        String pfCpInt = null;
        String pfCpStream = null;

        // If paramFile is defined, then read it and check for cpStream or cpInternal
        if (runAttributes.getParamFile() != null) {
            try (InputStream is = new FileInputStream(runAttributes.getParamFile()); ) {
                PFReader reader = new PFReader(is);
                pfCpInt = reader.getCpInternal();
                pfCpStream = reader.getCpStream();
            } catch (IOException uncaught) {

            }
        }

        if (runAttributes.getCpStream() != null)
            return runAttributes.getCpStream();
        else if (pfCpStream != null)
            return pfCpStream;
        else if (runAttributes.getCpInternal() != null)
            return runAttributes.getCpInternal();
        else if (pfCpInt != null)
            return pfCpInt;
        else
            return null;
    }

    protected void createProfilerFile() {
        if ((runAttributes.getProfiler() != null) && runAttributes.getProfiler().isEnabled()) {
            try (OutputStream os = new FileOutputStream(profilerParamFile);
                    Writer w = new OutputStreamWriter(os);
                    BufferedWriter bw = new BufferedWriter(w)) {
                if (runAttributes.getProfiler().getOutputFile() != null) {
                    bw.write("-FILENAME " + runAttributes.getProfiler().getOutputFile().getAbsolutePath());
                    bw.newLine();
                } else {
                    // Assuming nobody will use file names with double quotes in this case... 
                    bw.write("-FILENAME \""
                            + new File(runAttributes.getProfiler().getOutputDir(), "profiler" + profilerOutID
                                    + ".out\""));
                    bw.newLine();
                }
                if (runAttributes.getProfiler().hasCoverage()) {
                    bw.write("-COVERAGE");
                    bw.newLine();
                }
                if (runAttributes.getProfiler().hasStatistics()) {
                    bw.write("-STATISTICS");
                    bw.newLine();
                }
                if (runAttributes.getProfiler().getListings() != null) {
                    bw.write("-LISTINGS \"" + runAttributes.getProfiler().getListings().getAbsolutePath() + "\"");
                    bw.newLine();
                }
                bw.write("-DESCRIPTION \"" + runAttributes.getProfiler().getDescription() + "\"");
                bw.newLine();
            } catch (IOException caught) {
                throw new BuildException(caught);
            }
        }
    }

    private void createInitProcedure() {
        try (OutputStream os = new FileOutputStream(initProc);
                Writer w = new OutputStreamWriter(os, getCharset());
                BufferedWriter bw = new BufferedWriter(w)) {
            bw.write(MessageFormat.format(this.getProgressProcedures().getInitString(), isVerbose(),
                    runAttributes.useNoErrorOnQuit()));

            // XCode session key
            if ((runAttributes.getXCodeSessionKey() != null) && !runAttributes.getXCodeSessionKey().trim().isEmpty()) {
                bw.write(MessageFormat.format(this.getProgressProcedures().getXCodeSessionKey(),
                        runAttributes.getXCodeSessionKey().trim()));
                bw.newLine();
            }

            // Defines database connections and aliases
            int dbNum = 1;
            for (PCTConnection dbc : runAttributes.getAllDbConnections()) {
                String connect = dbc.createConnectString();
                bw.write(MessageFormat.format(this.getProgressProcedures().getConnectString(),
                        connect));

                Collection<PCTAlias> aliases = dbc.getAliases();
                if (aliases != null) {
                    for (PCTAlias alias : aliases) {
                        bw.write(MessageFormat.format(this.getProgressProcedures()
                                .getAliasString(), alias.getName(), Integer.valueOf(dbNum),
                                alias.getNoError() ? "NO-ERROR" : ""));
                        bw.newLine();
                    }
                }
                dbNum++;
            }
            if (runAttributes.getAliases() != null) {
                for (DBAlias alias : runAttributes.getAliases()) {
                    bw.write(MessageFormat.format(getProgressProcedures().getDBAliasString(),
                            alias.getName(), alias.getValue(), alias.getNoError() ? "NO-ERROR" : ""));
                }
            }

            // Defines internal propath
            if (this.internalPropath != null) {
                String[] lst = this.internalPropath.list();
                for (int k = lst.length - 1; k >= 0; k--) {
                    bw.write(MessageFormat.format(this.getProgressProcedures().getPropathString(),
                            escapeString(lst[k]) + File.pathSeparatorChar));
                }
            }

            // Defines PROPATH
            if (runAttributes.getPropath() != null) {
                // Bug #1058733 : multiple assignments for propath, as a long propath
                // could lead to error 135 (More than xxx characters in a single
                // statement--use -inp parm)
                String[] lst = runAttributes.getPropath().list();
                for (int k = lst.length - 1; k >= 0; k--) {
                    if (runAttributes.useRelativePaths()) {
                        try {
                            bw.write(MessageFormat.format(
                                    this.getProgressProcedures().getPropathString(),
                                    escapeString(FileUtils
                                            .getRelativePath(
                                                    (runAttributes.getBaseDir() == null
                                                            ? getProject().getBaseDir()
                                                            : runAttributes.getBaseDir()), new File(lst[k])).replace(
                                                    '/', File.separatorChar))
                                            + File.pathSeparatorChar));
                        } catch (Exception caught) {
                            throw new IOException(caught);
                        } 
                    } else {
                        bw.write(MessageFormat.format(this.getProgressProcedures()
                                .getPropathString(), escapeString(lst[k]) + File.pathSeparatorChar));
                    }
                }
            }

            // Callback
            if ((runAttributes.getMainCallback() != null) && (runAttributes.getMainCallback().trim().length() > 0)) {
                bw.write(MessageFormat.format(getProgressProcedures().getCallbackString(), runAttributes.getMainCallback()));
            }

            // Defines parameters
            if (runAttributes.getRunParameters() != null) {
                for (RunParameter param : runAttributes.getRunParameters()) {
                    if (param.validate()) {
                        bw.write(MessageFormat.format(this.getProgressProcedures()
                                .getParameterString(), escapeString(param.getName()),
                                escapeString(param.getValue())));
                    } else {
                        log(MessageFormat.format(Messages.getString("PCTRun.9"), param.getName()), Project.MSG_WARN); //$NON-NLS-1$
                    }
                }
            }

            // Defines variables for OUTPUT parameters
            if (runAttributes.getOutputParameters() != null) {
                int zz = 0;
                for (OutputParameter param : runAttributes.getOutputParameters()) {
                    param.setProgressVar("outParam" + zz++);
                    bw.write(MessageFormat.format(this.getProgressProcedures()
                            .getOutputParameterDeclaration(), param.getProgressVar()));
                }
            }

            // Creates a StringBuffer containing output parameters when calling the progress
            // procedure
            StringBuilder sb = new StringBuilder();
            if ((runAttributes.getOutputParameters() != null) && !runAttributes.getOutputParameters().isEmpty()) {
                sb.append('(');
                int zz = 0;
                for (OutputParameter param : runAttributes.getOutputParameters()) {
                    if (zz++ > 0)
                        sb.append(',');
                    sb.append("OUTPUT ").append(param.getProgressVar());
                }
                sb.append(')');
            }

            // Add init procedure to the super procedures stack
            if (runAttributes.isSuperInit()) {
                bw.write(getProgressProcedures().getSuperInitString());
            }

            // Calls progress procedure
            bw.write(MessageFormat.format(this.getProgressProcedures().getRunString(),
                    escapeString(runAttributes.getProcedure()), sb.toString()));
            // Checking return value
            bw.write(this.getProgressProcedures().getAfterRun());
            // Writing output parameters to temporary files
            if (this.runAttributes.getOutputParameters() != null) {
                for (OutputParameter param : runAttributes.getOutputParameters()) {
                    File tmpFile = new File(
                            System.getProperty(PCT.TMPDIR), param.getProgressVar() + "." + PCT.nextRandomInt() + ".out"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
                    param.setTempFileName(tmpFile);
                    bw.write(MessageFormat.format(this.getProgressProcedures()
                            .getOutputParameterCall(), param.getProgressVar(),
                            escapeString(tmpFile.getAbsolutePath())));
                }
            }
            // Quit
            bw.write(this.getProgressProcedures().getQuit());

            // Private procedures
            bw.write(MessageFormat.format(this.getProgressProcedures().getReturnProc(),
                    escapeString(status.getAbsolutePath())));
            bw.write(this.getProgressProcedures().getOutputParameterProc());
        } catch (IOException ioe) {
            throw new BuildException(ioe);
        }
    }

    protected void preparePropath() {
        if (this.getIncludedPL()) {
            // PL is extracted later, we just have a reference on filename
            FileList list = new FileList();
            list.setDir(pctLib.getParentFile().getAbsoluteFile());
            FileList.FileName fn = new FileList.FileName();
            fn.setName(pctLib.getName());
            list.addConfiguredFile(fn);
            this.internalPropath = new Path(this.getProject());
            this.internalPropath.addFilelist(list);
        }
    }

    /**
     * Escapes a string so it does not accidentally contain Progress escape characters
     * 
     * @param str the input string
     * @return the escaped string
     */
    protected static String escapeString(String str) {
        if (str == null) {
            return null;
        }

        int slen = str.length();
        StringBuilder res = new StringBuilder();

        for (int i = 0; i < slen; i++) {
            char c = str.charAt(i);

            switch (c) {
                case '\u007E' : // TILDE converted to TILDE TILDE
                    res.append("\u007E\u007E"); //$NON-NLS-1$
                    break;

                case '\u0022' : // QUOTATION MARK converted to TILDE APOSTROPHE
                case '\''     : // APOSTROPHE converted to TILDE APOSTROPHE
                    res.append("\u007E\u0027"); //$NON-NLS-1$
                    break;

                default :
                    res.append(c);
            }
        }

        return res.toString();
    }

    /**
     * Return PCT Debug status
     * 
     * @return boolean
     */
    protected boolean getDebugPCT() {
        return runAttributes.isDebugPCT();
    }

    /**
     * Delete temporary files if debug not activated
     */
    protected void cleanup() {
        // Always delete pct.pl, even in debugPCT mode
        if (pctLib != null) {
            deleteFile(pctLib);
        }
        if (runAttributes.isDebugPCT())
            return;

        deleteFile(initProc);
        deleteFile(status);
        deleteFile(profilerParamFile);
        for (OutputParameter param : runAttributes.getOutputParameters()) {
            deleteFile(param.getTempFileName());
        }
        deleteFile(xcodeDir);
    }
}