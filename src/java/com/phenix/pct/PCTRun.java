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
import org.apache.tools.ant.Project;
import org.apache.tools.ant.taskdefs.ExecTask;
import org.apache.tools.ant.types.Environment;
import org.apache.tools.ant.types.Environment.Variable;
import org.apache.tools.ant.types.FileList;
import org.apache.tools.ant.types.Path;
import org.apache.tools.ant.util.FileUtils;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.nio.charset.Charset;

import java.text.MessageFormat;
import java.util.Collection;

/**
 * Run a Progress procedure.
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class PCTRun extends PCT implements IRunAttributes {
    protected GenericExecuteOptions runAttributes;
    
    // Attributes
    private String mainCallback = null;
    private boolean noErrorOnQuit = false;
    private boolean superInit = true;
//    protected Path propath = null;
    protected Path internalPropath = null;
//    protected boolean failOnError = true;
    private String resultProperty = null;

    // Internal use
    protected ExecTask exec = null;
    protected int statusID = -1; // Unique ID when creating temp files
    protected int initID = -1; // Unique ID when creating temp files
    protected int plID = -1; // Unique ID when creating temp files
    protected int outputStreamID = -1; // Unique ID when creating temp files
    private int profilerID = -1;
    private int profilerOutID = -1;
    protected File initProc = null;
    protected File status = null;
    protected File pctLib = null;
    protected File outputStream = null;
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
        runAttributes = new GenericExecuteOptions(getProject());

        if (tmp) {
            statusID = PCT.nextRandomInt();
            initID = PCT.nextRandomInt();
            plID = PCT.nextRandomInt();
            profilerID = PCT.nextRandomInt();
            profilerOutID = PCT.nextRandomInt();

            status = new File(System.getProperty("java.io.tmpdir"), "PCTResult" + statusID + ".out"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
            initProc = new File(System.getProperty("java.io.tmpdir"), "pctinit" + initID + ".p"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
            profilerParamFile = new File(
                    System.getProperty("java.io.tmpdir"), "prof" + profilerID + ".pf"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
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
    public void setParameters(Collection<RunParameter> params) {
        for (RunParameter p : params) {
            runAttributes.addParameter(p);
        }
    }

    /**
     * Mail callback class
     * @param mainCallback
     */
    public void setMainCallback(String mainCallback) {
        this.mainCallback = mainCallback;
    }

    /**
     * Turns on/off onQuit mode (no error on expected QUIT)
     * 
     * @param noErrorOnQuit boolean
     */
    public void setNoErrorOnQuit(boolean noErrorOnQuit) {
        this.noErrorOnQuit = noErrorOnQuit;
    }

    /**
     * Add init procedure to the super procedures stack
     * 
     * @param superInit boolean
     */
    public void setSuperInit(boolean superInit) {
        this.superInit = superInit;
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
    public void setProcedure(String procedure) {
        runAttributes.setProcedure(procedure);
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
    public void setAssemblies(File assemblies) {
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

    // End of IRunAttribute methods
    // ****************************

    public boolean isVerbose() {
        return (getAntLoggerLever() > 2);
    }

    /**
     * Defines profiler
     * 
     * @param profiler
     */
    public void addProfiler(Profiler profiler) {
        runAttributes.addProfiler(profiler);
    }

    /**
     * Helper method to set result property to the passed in value if appropriate.
     * 
     * @param result value desired for the result property value.
     */
    protected void maybeSetResultPropertyValue(int result) {
        if (resultProperty != null) {
            String res = Integer.toString(result);
            getProject().setNewProperty(resultProperty, res);
        }
    }

    /**
     * Exec task is prepared ?
     * 
     * @return boolean
     */
    public boolean isPrepared() {
        return this.prepared;
    }

    /**
     * Returns status file name (where to write progress procedure result)
     * 
     * @return String
     */
    protected String getStatusFileName() {
        return status.getAbsolutePath();
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        BufferedReader br = null;

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
            // we still don't know if
            // we have to use source code or compiled version. And it's impossible to extract source
            // code to a directory named
            // something.pl as Progress tries to open a procedure library, and miserably fails with
            // error 13.
            pctLib = new File(
                    System.getProperty("java.io.tmpdir"), "pct" + plID + (isSourceCodeUsed() ? "" : ".pl")); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$

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

            exec.execute();
        } catch (BuildException be) {
            cleanup();
            throw be;
        } catch (IOException caught) {
            cleanup();
            throw new BuildException(caught);
        }

        if (getProgressProcedures().needRedirector()) {
            String s = null;
            try {
                BufferedReader br2 = new BufferedReader(new FileReader(outputStream));
                while ((s = br2.readLine()) != null) {
                    log(s, Project.MSG_INFO);
                }
                br2.close();
            } catch (Exception e) {
                System.out.println(e);
            }
        }

        // Reads output parameter
        if (runAttributes.getOutputParameters() != null) {
            for (OutputParameter param : runAttributes.getOutputParameters()) {
                File f = param.getTempFileName();
                try {
                    br = new BufferedReader(new InputStreamReader(new FileInputStream(f),
                            Charset.forName("utf-8")));
                    String s = br.readLine();
                    br.close();
                    getProject().setNewProperty(param.getName(), s);
                } catch (FileNotFoundException fnfe) {
                    log(MessageFormat.format(
                            Messages.getString("PCTRun.10"), param.getName(), f.getAbsolutePath()), Project.MSG_ERR); //$NON-NLS-1$
                    cleanup();
                    throw new BuildException(fnfe);
                } catch (IOException ioe) {
                    try {
                        br.close();
                    } catch (IOException ioe2) {
                    }
                    log(MessageFormat.format(
                            Messages.getString("PCTRun.10"), param.getName(), f.getAbsolutePath()), Project.MSG_ERR); //$NON-NLS-1$
                    cleanup();
                    throw new BuildException(ioe);
                }
            }
        }

        // Now read status file
        try {
            br = new BufferedReader(new FileReader(status));

            String s = br.readLine();
            br.close();

            this.cleanup();
            int ret = Integer.parseInt(s);

            if (ret != 0 && runAttributes.isFailOnError()) {
                throw new BuildException(MessageFormat.format(Messages.getString("PCTRun.6"), ret)); //$NON-NLS-1$
            }
            maybeSetResultPropertyValue(ret);
        } catch (FileNotFoundException fnfe) {
            // No need to clean BufferedReader as it's null in this case
            this.cleanup();
            throw new BuildException(Messages.getString("PCTRun.1"), fnfe); //$NON-NLS-1$
        } catch (IOException ioe) {
            try {
                br.close();
            } catch (IOException ioe2) {
            }
            this.cleanup();
            throw new BuildException(Messages.getString("PCTRun.2"), ioe); //$NON-NLS-1$
        } catch (NumberFormatException nfe) {
            this.cleanup(); // Ce truc là ne serait pas manquant ??
            throw new BuildException(Messages.getString("PCTRun.3"), nfe); //$NON-NLS-1$
        }

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
        String pfCpInt = null, pfCpStream = null;

        // If paramFile is defined, then read it and check for cpStream or cpInternal
        if (runAttributes.getParamFile() != null) {
            try {
                PFReader reader = new PFReader(new FileInputStream(runAttributes.getParamFile()));
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

    private void createProfilerFile() throws BuildException {
        if ((runAttributes.getProfiler() != null) && runAttributes.getProfiler().isEnabled()) {
            BufferedWriter bw = null;
            try {
                bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(
                        profilerParamFile)));
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
                bw.close();
            } catch (IOException caught) {
                throw new BuildException(caught);
            } finally {
                try {
                    bw.close();
                } catch (IOException uncaught) {
                }
            }
        }
    }

    private void createInitProcedure() throws BuildException {
        BufferedWriter bw = null;
        try {
            bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(
                    initProc), getCharset()));

            // Progress v8 is unable to write to standard output, so output is redirected in a file,
            // which is parsed in a later stage
            if (this.getProgressProcedures().needRedirector()) {
                outputStreamID = PCT.nextRandomInt();
                outputStream = new File(
                        System.getProperty("java.io.tmpdir"), "pctOut" + outputStreamID + ".txt"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
            }
            bw.write(MessageFormat.format(this.getProgressProcedures().getInitString(),
                    (this.outputStream == null ? null : this.outputStream.getAbsolutePath()),
                    isVerbose(), noErrorOnQuit));

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
            if ((mainCallback != null) && (mainCallback.trim().length() > 0)) {
                bw.write(MessageFormat.format(getProgressProcedures().getCallbackString(), mainCallback));
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
            StringBuffer sb = new StringBuffer();
            if ((runAttributes.getOutputParameters() != null) && (runAttributes.getOutputParameters().size() > 0)) {
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
            if (superInit) {
                bw.write(getProgressProcedures().getSuperInitString());
            }

            // Calls progress procedure
            bw.write(MessageFormat.format(this.getProgressProcedures().getRunString(),
                    escapeString(runAttributes.getProcedure()), sb.toString()));
            // Checking return value
            bw.write(MessageFormat.format(this.getProgressProcedures().getAfterRun(),
                    new Object[]{}));
            // Writing output parameters to temporary files
            if (this.runAttributes.getOutputParameters() != null) {
                for (OutputParameter param : runAttributes.getOutputParameters()) {
                    File tmpFile = new File(
                            System.getProperty("java.io.tmpdir"), param.getProgressVar() + "." + PCT.nextRandomInt() + ".out"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
                    param.setTempFileName(tmpFile);
                    bw.write(MessageFormat.format(this.getProgressProcedures()
                            .getOutputParameterCall(), new Object[]{param.getProgressVar(),
                            escapeString(tmpFile.getAbsolutePath())}));
                }
            }
            // Quit
            bw.write(MessageFormat.format(this.getProgressProcedures().getQuit(), new Object[]{}));

            // Private procedures
            bw.write(MessageFormat.format(this.getProgressProcedures().getReturnProc(),
                    new Object[]{escapeString(status.getAbsolutePath())}));
            bw.write(MessageFormat.format(this.getProgressProcedures().getOutputParameterProc(),
                    new Object[]{}));

            bw.close();
        } catch (IOException ioe) {
            throw new BuildException(ioe);
        } finally {
            if (bw != null) {
                try {
                    bw.close();
                } catch (IOException uncaught) {
                    
                }
            }
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
        StringBuffer res = new StringBuffer();

        for (int i = 0; i < slen; i++) {
            char c = str.charAt(i);

            switch (c) {
                case '\u007E' : // TILDE converted to TILDE TILDE
                    res.append("\u007E\u007E"); //$NON-NLS-1$

                    break;

                case '\u0022' : // QUOTATION MARK converted to TILDE APOSTROPHE
                    res.append("\u007E\u0027"); //$NON-NLS-1$

                    break;

                case '\'' : // APOSTROPHE converted to TILDE APOSTROPHE
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
     * 
     */
    protected void cleanup() {
        if (!runAttributes.isDebugPCT()) {
            if ((initProc != null) && initProc.exists() && !initProc.delete()) {
                log(MessageFormat
                        .format(Messages.getString("PCTRun.5"), initProc.getAbsolutePath()), Project.MSG_INFO); //$NON-NLS-1$
            }

            if ((status != null) && status.exists() && !status.delete()) {
                log(MessageFormat.format(Messages.getString("PCTRun.5"), status.getAbsolutePath()), Project.MSG_INFO); //$NON-NLS-1$
            }
            if ((outputStream != null) && outputStream.exists() && !outputStream.delete()) {
                log(MessageFormat.format(
                        Messages.getString("PCTRun.5"), outputStream.getAbsolutePath()), Project.MSG_INFO); //$NON-NLS-1$
            }
            if ((profilerParamFile != null) && profilerParamFile.exists()
                    && !profilerParamFile.delete()) {
                log(MessageFormat.format(Messages.getString("PCTRun.5"), profilerParamFile.getAbsolutePath()), Project.MSG_INFO); //$NON-NLS-1$
            }
            if (runAttributes.getOutputParameters() != null) {
                for (OutputParameter param : runAttributes.getOutputParameters()) {
                    if ((param.getTempFileName() != null)
                            && (param.getTempFileName().exists() && !param.getTempFileName()
                                    .delete())) {
                        log(MessageFormat
                                .format(Messages.getString("PCTRun.5"), param.getTempFileName().getAbsolutePath()), Project.MSG_INFO); //$NON-NLS-1$
                    }
                }
            }
        }
        // pct.pl is always deleted
        if ((pctLib != null) && pctLib.exists()) {
            if (pctLib.isDirectory()) {
                try {
                    deleteDirectory(pctLib);
                } catch (IOException uncaught) {

                }
            } else {
                if (!pctLib.delete()) {
                    log(MessageFormat.format(
                            Messages.getString("PCTRun.5"), pctLib.getAbsolutePath()), Project.MSG_VERBOSE); //$NON-NLS-1$
                }
            }
        }
    }
}