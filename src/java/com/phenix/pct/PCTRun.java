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
import org.apache.tools.ant.types.Commandline;
import org.apache.tools.ant.types.Environment;
import org.apache.tools.ant.types.Environment.Variable;
import org.apache.tools.ant.types.FileList;
import org.apache.tools.ant.types.Path;

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
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * Run a Progress procedure.
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class PCTRun extends PCT {
    // Attributes
    protected String procedure = null;
    private String cpStream = null;
    private String cpInternal = null;
    private String parameter = null;
    private String numsep = null;
    private String numdec = null;
    private File paramFile = null;
    private File iniFile = null;
    private File tempDir = null;
    private File baseDir = null;
    private int inputChars = 0;
    private int dirSize = 0;
    private int centuryYearOffset = 0;
    private int token = 0;
    private int maximumMemory = 0;
    private int stackSize = 0;
    private int ttBufferSize = 0;
    private int messageBufferSize = 0;
    private int debugReady = -1;
    private boolean graphMode = false;
    private boolean debugPCT = false;
    private boolean compileUnderscore = false;
    protected Collection<PCTConnection> dbConnList = null;
    private Collection<PCTRunOption> options = null;
    protected Path propath = null;
    protected Path internalPropath = null;
    protected Collection<RunParameter> runParameters = null;
    protected List<OutputParameter> outputParameters = null;
    private boolean batchMode = true;
    private boolean failOnError = true;
    private String resultProperty = null;
    private File assemblies = null;

    // Internal use
    protected ExecTask exec = null;
    protected int statusID = -1; // Unique ID when creating temp files
    protected int initID = -1; // Unique ID when creating temp files
    protected int plID = -1; // Unique ID when creating temp files
    protected int outputStreamID = -1; // Unique ID when creating temp files
    protected File initProc = null;
    protected File status = null;
    protected File pctLib = null;
    protected File outputStream = null;
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

        if (tmp) {
            statusID = PCT.nextRandomInt();
            initID = PCT.nextRandomInt();
            plID = PCT.nextRandomInt();

            status = new File(System.getProperty("java.io.tmpdir"), "PCTResult" + statusID + ".out"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
            initProc = new File(System.getProperty("java.io.tmpdir"), "pctinit" + initID + ".p"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        }
    }

    public PCTRun(boolean tmp, boolean batchMode) {
        this(tmp);
        this.batchMode = batchMode;
    }

    /**
     * Adds a database connection
     * 
     * @param dbConn Instance of PCTConnection class
     * @deprecated
     */
    public void addPCTConnection(PCTConnection dbConn) {
        addDBConnection(dbConn);
    }

    public void addDBConnection(PCTConnection dbConn) {
        if (this.dbConnList == null) {
            this.dbConnList = new ArrayList<PCTConnection>();
        }

        this.dbConnList.add(dbConn);
    }

    /**
     * Adds a new command line option
     * 
     * @param option Instance of PCTRunOption class
     */
    public void addOption(PCTRunOption option) {
        if (this.options == null) {
            this.options = new ArrayList<PCTRunOption>();
        }

        this.options.add(option);
    }

    public void addPCTRunOption(PCTRunOption option) {
        if (this.options == null) {
            this.options = new ArrayList<PCTRunOption>();
        }

        this.options.add(option);
    }

    /**
     * Add a new parameter which will be passed to the progress procedure in a temp-table
     * 
     * @param param Instance of RunParameter class
     */
    public void addParameter(RunParameter param) {
        if (this.runParameters == null) {
            this.runParameters = new ArrayList<RunParameter>();
        }
        this.runParameters.add(param);
    }

    /**
     * Add a new output param which will be passed to progress procedure
     * 
     * @param param Instance of OutputParameter
     * @since PCT 0.14
     */
    public void addOutputParameter(OutputParameter param) {
        if (this.outputParameters == null)
            this.outputParameters = new ArrayList<OutputParameter>();
        this.outputParameters.add(param);
    }

    /**
     * Defines a new collection of parameters
     * 
     * @param params Collection<RunParameter>
     */
    public void setParameters(Collection<RunParameter> params) {
        this.runParameters = params;
    }

    /**
     * Parameter file (-pf attribute)
     * 
     * @param pf File
     */
    public void setParamFile(File pf) {
        this.paramFile = pf;
    }

    /**
     * Thousands separator (-numsep attribute)
     * 
     * @param numsep String
     */
    public void setNumSep(String numsep) {
        this.numsep = numsep;
    }

    /**
     * Decimal separator (-numdec attribute)
     * 
     * @param numdec String
     */
    public void setNumDec(String numdec) {
        this.numdec = numdec;
    }

    /**
     * Parameter (-param attribute)
     * 
     * @param param String
     */
    public void setParameter(String param) {
        this.parameter = param;
    }

    /**
     * Turns on/off debugging mode (keeps Progress temp files on disk)
     * 
     * @param debugPCT boolean
     */
    public void setDebugPCT(boolean debugPCT) {
        this.debugPCT = debugPCT;
    }

    /**
     * If files beginning with an underscore should be compiled (-zn option) See POSSE documentation
     * for more details
     * 
     * @param compUnderscore boolean
     */
    public void setCompileUnderscore(boolean compUnderscore) {
        this.compileUnderscore = compUnderscore;
    }

    /**
     * The number of compiled procedure directory entries (-D attribute)
     * 
     * @param dirSize int
     */
    public void setDirSize(int dirSize) {
        this.dirSize = dirSize;
    }

    /**
     * Graphical mode on/off (call to _progres or prowin32)
     * 
     * @param graphMode boolean
     */
    public void setGraphicalMode(boolean graphMode) {
        this.graphMode = graphMode;
    }

    /**
     * Sets .ini file to use (-basekey INI -ininame xxx)
     * 
     * @param iniFile File
     */
    public void setIniFile(File iniFile) {
        this.iniFile = iniFile;
    }

    /**
     * Sets the failOnError parameter. Defaults to true.
     * 
     * @param failOnError
     */
    public void setFailOnError(boolean failOnError) {
        this.failOnError = failOnError;
    }

    /**
     * Procedure to be run (not -p param, this parameter is always pct_initXXX.p)
     * 
     * @param procedure String
     */
    public void setProcedure(String procedure) {
        this.procedure = procedure;
    }

    public void setAssemblies(File assemblies) {
        this.assemblies = assemblies;
    }

    /**
     * Set the propath to be used when running the procedure
     * 
     * @param propath an Ant Path object containing the propath
     */
    public void addPropath(Path propath) {
        createPropath().append(propath);
    }

    /**
     * Creates a new Path instance
     * 
     * @return Path
     */
    public Path createPropath() {
        if (this.propath == null) {
            this.propath = new Path(this.getProject());
        }

        return this.propath;
    }

    /*
     * public void addPropathRef(Reference r) { this.propath.setRefid(r); }
     */

    /**
     * Stream code page (-cpstream attribute)
     * 
     * @param cpStream String
     */
    public void setCpStream(String cpStream) {
        this.cpStream = cpStream;
    }

    /**
     * Internal code page (-cpinternal attribute)
     * 
     * @param cpInternal String
     */
    public void setCpInternal(String cpInternal) {
        this.cpInternal = cpInternal;
    }

    /**
     * The number of characters allowed in a single statement (-inp attribute)
     * 
     * @param inputChars Integer
     */
    public void setInputChars(int inputChars) {
        this.inputChars = inputChars;
    }

    /**
     * Century year offset (-yy attribute)
     * 
     * @param centuryYearOffset Integer
     */
    public void setCenturyYearOffset(int centuryYearOffset) {
        this.centuryYearOffset = centuryYearOffset;
    }

    /**
     * The number of tokens allowed in a 4GL statement (-tok attribute)
     * 
     * @param token int
     */
    public void setToken(int token) {
        this.token = token;
    }

    /**
     * The amount of memory allocated for r-code segments
     * 
     * @param maximumMemory int
     */
    public void setMaximumMemory(int maximumMemory) {
        this.maximumMemory = maximumMemory;
    }

    /**
     * The size of the stack in 1KB units.
     * 
     * @param stackSize int
     */
    public void setStackSize(int stackSize) {
        this.stackSize = stackSize;
    }

    /**
     * Buffer Size for Temporary Tables (-Bt attribute)
     * 
     * @param ttBufferSize int
     */
    public void setTTBufferSize(int ttBufferSize) {
        this.ttBufferSize = ttBufferSize;
    }

    /**
     * Message buffer size (-Mm attribute)
     * 
     * @param msgBufSize int
     */
    public void setMsgBufferSize(int msgBufSize) {
        this.messageBufferSize = msgBufSize;
    }

    /**
     * Port number on which debugger should connect (-debugReady parameter)
     * 
     * @param debugReady int
     */
    public void setDebugReady(int debugReady) {
        this.debugReady = debugReady;
    }

    /**
     * Temporary directory for Progress runtime (-T parameter)
     * 
     * @param tempDir File
     */
    public void setTempDir(File tempDir) {
        this.tempDir = tempDir;
    }

    /**
     * The directory in which the Progress runtime should be executed.
     * 
     * @param baseDir File
     */
    public void setBaseDir(File baseDir) {
        this.baseDir = baseDir;
    }

    /**
     * Sets the name of a property in which the return valeur of the Progress procedure should be
     * stored. Only of interest if failonerror=false.
     * 
     * @since PCT 0.14
     * 
     * @param resultProperty name of property.
     */
    public void setResultProperty(String resultProperty) {
        this.resultProperty = resultProperty;
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
        if (!this.prepared) {
            this.prepareExecTask();
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

            this.preparePropath();
            this.createInitProcedure();
            this.setExecTaskParams();

            // Startup procedure
            exec.createArg().setValue("-p"); //$NON-NLS-1$
            exec.createArg().setValue(this.initProc.getAbsolutePath());
            if (getIncludedPL() && !extractPL(pctLib)) {
                throw new BuildException("Unable to extract pct.pl.");
            }

            exec.execute();
        } catch (BuildException be) {
            this.cleanup();
            throw be;
        } catch (IOException caught) {
            cleanup();
            throw new BuildException(caught);
        }

        if (this.getProgressProcedures().needRedirector()) {
            String s = null;
            try {
                BufferedReader br2 = new BufferedReader(new FileReader(this.outputStream));
                while ((s = br2.readLine()) != null) {
                    log(s, Project.MSG_INFO);
                }
                br2.close();
            } catch (Exception e) {
                System.out.println(e);
            }
        }

        // Reads output parameter
        if (this.outputParameters != null) {
            for (OutputParameter param : outputParameters) {
                File f = param.getTempFileName();
                try {
                    br = new BufferedReader(new InputStreamReader(new FileInputStream(f),
                            Charset.forName("utf-8")));
                    String s = br.readLine();
                    br.close();
                    getProject().setNewProperty(param.getName(), s);
                } catch (FileNotFoundException fnfe) {
                    log(MessageFormat
                            .format(Messages.getString("PCTRun.10"), new Object[]{param.getName(), f.getAbsolutePath()}), Project.MSG_ERR); //$NON-NLS-1$
                    cleanup();
                    throw new BuildException(fnfe);
                } catch (IOException ioe) {
                    try {
                        br.close();
                    } catch (IOException ioe2) {
                    }
                    log(MessageFormat
                            .format(Messages.getString("PCTRun.10"), new Object[]{param.getName(), f.getAbsolutePath()}), Project.MSG_ERR); //$NON-NLS-1$
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

            if (ret != 0 && failOnError) {
                throw new BuildException(MessageFormat.format(
                        Messages.getString("PCTRun.6"), new Object[]{Integer.valueOf(ret)})); //$NON-NLS-1$
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
        if (!this.prepared) {
            exec = new ExecTask(this);

            Environment.Variable var = new Environment.Variable();
            var.setKey("DLC"); //$NON-NLS-1$
            var.setValue(this.getDlcHome().toString());
            exec.addEnv(var);

            for (Variable var2 : getEnvironmentVariables()) {
                exec.addEnv(var2);
            }
        }

        this.prepared = true;
    }

    protected List<String> getCmdLineParameters() {
        List<String> list = new ArrayList<String>();

        // Parameter file
        if (this.paramFile != null) {
            list.add("-pf"); //$NON-NLS-1$
            list.add(this.paramFile.getAbsolutePath());
        }

        // Batch mode
        if (this.batchMode) {
            list.add("-b"); //$NON-NLS-1$
            list.add("-q"); //$NON-NLS-1$
        }

        // DebugReady
        if (this.debugReady != -1) {
            list.add("-debugReady"); //$NON-NLS-1$
            list.add(Integer.toString(this.debugReady));
        }

        // Inifile
        if (this.iniFile != null) {
            list.add("-basekey"); //$NON-NLS-1$
            list.add("INI"); //$NON-NLS-1$
            list.add("-ininame"); //$NON-NLS-1$
            list.add(Commandline.quoteArgument(this.iniFile.getAbsolutePath()));
        }

        // Max length of a line
        if (this.inputChars != 0) {
            list.add("-inp"); //$NON-NLS-1$
            list.add(Integer.toString(this.inputChars));
        }

        // Stream code page
        if (this.cpStream != null) {
            list.add("-cpstream"); //$NON-NLS-1$
            list.add(this.cpStream);
        }

        // Internal code page
        if (this.cpInternal != null) {
            list.add("-cpinternal"); //$NON-NLS-1$
            list.add(this.cpInternal);
        }

        // Directory size
        if (this.dirSize != 0) {
            list.add("-D"); //$NON-NLS-1$
            list.add(Integer.toString(this.dirSize));
        }

        if (this.centuryYearOffset != 0) {
            list.add("-yy"); //$NON-NLS-1$
            list.add(Integer.toString(this.centuryYearOffset));
        }

        if (this.maximumMemory != 0) {
            list.add("-mmax"); //$NON-NLS-1$
            list.add(Integer.toString(this.maximumMemory));
        }

        if (this.stackSize != 0) {
            list.add("-s"); //$NON-NLS-1$
            list.add(Integer.toString(this.stackSize));
        }

        if (this.token != 0) {
            list.add("-tok"); //$NON-NLS-1$
            list.add(Integer.toString(this.token));
        }

        if (this.messageBufferSize != 0) {
            list.add("-Mm"); //$NON-NLS-1$
            list.add(Integer.toString(this.messageBufferSize));
        }

        if (this.compileUnderscore) {
            list.add("-zn"); //$NON-NLS-1$
        }

        if (this.ttBufferSize != 0) {
            list.add("-Bt"); //$NON-NLS-1$
            list.add(Integer.toString(this.ttBufferSize));
        }

        if (this.numsep != null) {
            int tmpSep = 0;
            try {
                tmpSep = Integer.parseInt(this.numsep);
            } catch (NumberFormatException nfe) {
                if (this.numsep.length() == 1)
                    tmpSep = this.numsep.charAt(0);
                else
                    throw new BuildException(MessageFormat.format(Messages.getString("PCTRun.4"), //$NON-NLS-1$
                            new Object[]{"numsep"}), nfe); //$NON-NLS-1$
            }
            list.add("-numsep"); //$NON-NLS-1$
            list.add(Integer.toString(tmpSep));
        }

        if (this.numdec != null) {
            int tmpDec = 0;
            try {
                tmpDec = Integer.parseInt(this.numdec);
            } catch (NumberFormatException nfe) {
                if (this.numdec.length() == 1)
                    tmpDec = this.numdec.charAt(0);
                else
                    throw new BuildException(MessageFormat.format(Messages.getString("PCTRun.4"), //$NON-NLS-1$
                            new Object[]{"numdec"}), nfe); //$NON-NLS-1$
            }
            list.add("-numdec"); //$NON-NLS-1$
            list.add(Integer.toString(tmpDec));
        }

        // Parameter
        if (this.parameter != null) {
            list.add("-param"); //$NON-NLS-1$
            list.add(this.parameter);
        }

        // Temp directory
        if (this.tempDir != null) {
            // TODO Isn't exists method redundant with isDirectory ? Check JRE sources...
            // XXX Yes, it's redundant !
            if (!this.tempDir.exists() || !this.tempDir.isDirectory()) {
                throw new BuildException(MessageFormat.format(Messages.getString("PCTRun.7"), //$NON-NLS-1$
                        new Object[]{this.tempDir}));
            }
            list.add("-T");
            list.add(this.tempDir.getAbsolutePath());
        }

        if (assemblies != null) {
            list.add("-assemblies");
            list.add(assemblies.getAbsolutePath());
        }

        // Additional command line options
        if (this.options != null) {
            for (PCTRunOption opt : options) {
                if (opt.getName() == null) {
                    throw new BuildException(Messages.getString("PCTRun.8")); //$NON-NLS-1$
                }
                list.add(opt.getName());
                if (opt.getValue() != null)
                    list.add(opt.getValue());
            }
        }

        return list;
    }

    protected void setExecTaskParams() {
        File a = this.getExecPath((this.graphMode ? "prowin32" : "_progres")); //$NON-NLS-1$ //$NON-NLS-2$
        exec.setExecutable(a.toString());

        for (String str : getCmdLineParameters()) {
            exec.createArg().setValue(str);
        }

        // Check for base directory
        // TODO Check previous TODO about redundancy :)
        if (this.baseDir != null && this.baseDir.exists() && this.baseDir.isDirectory()) {
            exec.setDir(this.baseDir);
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
                if ("1252".equals(zz))
                    zz = "windows-1252";
                if ("big-5".equalsIgnoreCase(zz))
                    zz = "Big5";
                charset = Charset.forName(zz);
            }
        } catch (IllegalArgumentException caught) {
            log(MessageFormat.format(Messages.getString("PCTCompile.46"), new Object[]{zz}), Project.MSG_INFO); //$NON-NLS-1$
            charset = Charset.defaultCharset();
        }
        if (charset == null) {
            log(Messages.getString("PCTCompile.47"), Project.MSG_INFO); //$NON-NLS-1$
            charset = Charset.defaultCharset();
        }

        return charset;
    }

    private String readCharset() {
        String pfCpInt = null, pfCpStream = null;

        // If paramFile is defined, then read it and check for cpStream or cpInternal
        if (paramFile != null) {
            try {
                PFReader reader = new PFReader(new FileInputStream(paramFile));
                pfCpInt = reader.getCpInternal();
                pfCpStream = reader.getCpStream();
            } catch (IOException caught) {

            }
        }

        if (cpStream != null)
            return cpStream;
        else if (pfCpStream != null)
            return pfCpStream;
        else if (cpInternal != null)
            return cpInternal;
        else if (pfCpInt != null)
            return pfCpInt;
        else
            return null;
    }

    private void createInitProcedure() throws BuildException {
        try {
            BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(
                    initProc), getCharset()));

            // Progress v8 is unable to write to standard output, so output is redirected in a file,
            // which is parsed in a later stage
            if (this.getProgressProcedures().needRedirector()) {
                outputStreamID = PCT.nextRandomInt();
                outputStream = new File(
                        System.getProperty("java.io.tmpdir"), "pctOut" + outputStreamID + ".txt"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
            }
            bw.write(MessageFormat.format(
                    this.getProgressProcedures().getInitString(),
                    new Object[]{(this.outputStream == null ? null : this.outputStream
                            .getAbsolutePath())}));

            // Defines aliases
            if (dbConnList != null) {
                int dbNum = 1;
                for (PCTConnection dbc : dbConnList) {
                    String connect = dbc.createConnectString();
                    bw.write(MessageFormat.format(this.getProgressProcedures().getConnectString(),
                            new Object[]{connect}));

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
            }

            // Defines internal propath
            if (this.internalPropath != null) {
                String[] lst = this.internalPropath.list();
                for (int k = lst.length - 1; k >= 0; k--) {
                    bw.write(MessageFormat.format(this.getProgressProcedures().getPropathString(),
                            new Object[]{escapeString(lst[k]) + File.pathSeparatorChar}));
                }
            }

            // Defines PROPATH
            if (this.propath != null) {
                // Bug #1058733 : multiple assignments for propath, as a long propath
                // could lead to error 135 (More than xxx characters in a single
                // statement--use -inp parm)
                String[] lst = this.propath.list();
                for (int k = lst.length - 1; k >= 0; k--) {
                    bw.write(MessageFormat.format(this.getProgressProcedures().getPropathString(),
                            new Object[]{escapeString(lst[k]) + File.pathSeparatorChar}));
                }
            }

            // Defines parameters
            if (this.runParameters != null) {
                for (RunParameter param : runParameters) {
                    if (param.validate()) {
                        bw.write(MessageFormat.format(this.getProgressProcedures()
                                .getParameterString(), new Object[]{escapeString(param.getName()),
                                escapeString(param.getValue())}));
                    } else {
                        log(MessageFormat.format(
                                Messages.getString("PCTRun.9"), new Object[]{param.getName()}), Project.MSG_WARN); //$NON-NLS-1$
                    }
                }
            }

            // Defines variables for OUTPUT parameters
            if (this.outputParameters != null) {
                int zz = 0;
                for (OutputParameter param : outputParameters) {
                    param.setProgressVar("outParam" + zz++);
                    bw.write(MessageFormat.format(this.getProgressProcedures()
                            .getOutputParameterDeclaration(), new Object[]{param.getProgressVar()}));
                }
            }

            // Creates a StringBuffer containing output parameters when calling the progress
            // procedure
            StringBuffer sb = new StringBuffer();
            if ((this.outputParameters != null) && (this.outputParameters.size() > 0)) {
                sb.append('(');
                int zz = 0;
                for (OutputParameter param : outputParameters) {
                    if (zz++ > 0)
                        sb.append(',');
                    sb.append("OUTPUT ").append(param.getProgressVar());
                }
                sb.append(')');
            }

            // Calls progress procedure
            bw.write(MessageFormat.format(this.getProgressProcedures().getRunString(),
                    new Object[]{escapeString(this.procedure), sb.toString()}));
            // Checking return value
            bw.write(MessageFormat.format(this.getProgressProcedures().getAfterRun(),
                    new Object[]{}));
            // Writing output parameters to temporary files
            if (this.outputParameters != null) {
                for (OutputParameter param : outputParameters) {
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
        return this.debugPCT;
    }

    /**
     * Delete temporary files if debug not activated
     * 
     */
    protected void cleanup() {
        if (!this.debugPCT) {
            if ((this.initProc != null) && (this.initProc.exists() && !this.initProc.delete())) {
                log(MessageFormat
                        .format(Messages.getString("PCTRun.5"), new Object[]{this.initProc.getAbsolutePath()}), Project.MSG_VERBOSE); //$NON-NLS-1$
            }

            if ((this.status != null) && (this.status.exists() && !this.status.delete())) {
                log(MessageFormat
                        .format(Messages.getString("PCTRun.5"), new Object[]{this.status.getAbsolutePath()}), Project.MSG_VERBOSE); //$NON-NLS-1$
            }
            if ((this.outputStream != null)
                    && (this.outputStream.exists() && !this.outputStream.delete())) {
                log(MessageFormat
                        .format(Messages.getString("PCTRun.5"), new Object[]{this.outputStream.getAbsolutePath()}), Project.MSG_VERBOSE); //$NON-NLS-1$
            }
            if (this.outputParameters != null) {
                for (OutputParameter param : outputParameters) {
                    if ((param.getTempFileName() != null)
                            && (param.getTempFileName().exists() && !param.getTempFileName()
                                    .delete())) {
                        log(MessageFormat
                                .format(Messages.getString("PCTRun.5"), new Object[]{param.getTempFileName().getAbsolutePath()}), Project.MSG_VERBOSE); //$NON-NLS-1$
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
                    log(MessageFormat
                            .format(Messages.getString("PCTRun.5"), new Object[]{this.pctLib.getAbsolutePath()}), Project.MSG_VERBOSE); //$NON-NLS-1$
                }
            }
        }
    }
}