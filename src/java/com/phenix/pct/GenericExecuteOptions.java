package com.phenix.pct;

import java.io.File;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.types.Commandline;
import org.apache.tools.ant.types.Path;

public class GenericExecuteOptions {
    private Project project = null;

    private List dbConnList = null;
    private List options = null;
    private List runParameters = null;
    private List outputParameters = null;
    private Path propath = null;

    private int debugReady = -1;
    private boolean graphMode = false;
    private boolean debugPCT = false;
    private boolean compileUnderscore = false;
    private boolean batchMode = true;
    private String cpStream = null;
    private String cpInternal = null;
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

    public GenericExecuteOptions(Project p) {
        project = p;
    }

    /**
     * Adds a database connection
     * 
     * @param dbConn Instance of PCTConnection class
     */
    public void addPCTConnection(PCTConnection dbConn) {
        if (dbConnList == null) {
            dbConnList = new ArrayList();
        }
        dbConnList.add(dbConn);
    }

    /**
     * Returns list of database connections.
     * 
     * @return List of PCTConnection objects. Empty list if no DB connections
     */
    public List getDBConnections() {
        return (dbConnList == null ? new ArrayList() : dbConnList);
    }

    /**
     * Adds a new command line option
     * 
     * @param option Instance of PCTRunOption class
     */
    public void addOption(PCTRunOption option) {
        if (options == null) {
            options = new ArrayList();
        }
        options.add(option);
    }

    /**
     * @see com.phenix.pct.PCTRun#addOption(PCTRunOption)
     * @param option
     */
    public void addPCTRunOption(PCTRunOption option) {
        addOption(option);
    }

    /**
     * Returns list of command line options.
     * 
     * @return List of PCTRunOption objects. Empty list if no options.
     */
    public List getOptions() {
        return (options == null ? new ArrayList() : options);
    }

    /**
     * Adds a new parameter which can be read by the called Progress procedure
     * 
     * @param param Instance of RunParameter class
     */
    public void addParameter(RunParameter param) {
        if (runParameters == null) {
            runParameters = new ArrayList();
        }
        runParameters.add(param);
    }

    /**
     * Returns list of parameters passed to the called Progress procedure.
     * 
     * @return List of RunParameters objects. Empty list if no parameter.
     */
    public List getParameters() {
        return (runParameters == null ? new ArrayList() : runParameters);
    }

    /**
     * Add a new output param which will be passed to progress procedure
     * 
     * @param param Instance of OutputParameter
     * @since PCT 0.14
     */
    public void addOutputParameter(OutputParameter param) {
        if (outputParameters == null) {
            outputParameters = new ArrayList();
        }
        outputParameters.add(param);
    }

    /**
     * Returns list of output parameters to be filled by the called Progress procedure.
     * 
     * @return List of OutputParameter objects. Empty list if no parameter.
     */
    public List getOutputParameters() {
        return (outputParameters == null ? new ArrayList() : outputParameters);
    }

    /**
     * Set the propath to be used when running the procedure
     * 
     * @param propath an Ant Path object containing the propath
     */
    public void setPropath(Path propath) {
        createPropath().append(propath);
    }

    /**
     * Creates a new Path instance
     * 
     * @return Path
     */
    public Path createPropath() {
        if (propath == null) {
            propath = new Path(project);
        }

        return propath;
    }

    /**
     * Parameter file (-pf attribute)
     * 
     * @param pf File
     */
    public void setParamFile(File pf) {
        paramFile = pf;
    }

    public File getParamFile() {
        return paramFile;
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

    public void setFailOnError(boolean failOnError) {
        throw new BuildException(MessageFormat.format(
                Messages.getString("PCTBgRun.0"), new Object[]{"failOnError"})); //$NON-NLS-1$ //$NON-NLS-2$
    }

    public List getDbConnList() {
        return dbConnList;
    }

    public List getRunParameters() {
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

    public void setProcedure(String procedure) {
        this.procedure = procedure;
    }

    protected List getCmdLineParameters() {
        List list = new ArrayList();

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
                            new Object[]{"numdec"})); //$NON-NLS-1$
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
            if (!this.tempDir.exists() || !this.tempDir.isDirectory()) {
                throw new BuildException(MessageFormat.format(Messages.getString("PCTRun.7"), //$NON-NLS-1$
                        new Object[]{this.tempDir}));
            }
            list.add("-T");
            list.add(this.tempDir.getAbsolutePath());
        }

        // Additional command line options
        if (this.options != null) {
            for (Iterator i = this.options.iterator(); i.hasNext();) {
                PCTRunOption opt = (PCTRunOption) i.next();
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

}
