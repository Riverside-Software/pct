/**
 * Copyright 2005-2024 Riverside Software
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

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.nio.charset.Charset;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.ExecTask;
import org.apache.tools.ant.taskdefs.Parallel;
import org.apache.tools.ant.types.Environment;
import org.apache.tools.ant.types.Environment.Variable;
import org.apache.tools.ant.types.FileList;
import org.apache.tools.ant.types.Path;
import org.apache.tools.ant.util.FileUtils;

import com.phenix.pct.BackgroundWorker.Message;

/**
 * Run a background Progress procedure.
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public abstract class PCTBgRun extends PCT implements IRunAttributes {
    private static final long DEFAULT_TIMEOUT = 30L * 60L; // 30 minutes

    protected Path internalPropath = null;

    // Attributes
    private int numThreads = 1;
    private GenericExecuteOptions options;
    private long timeout = DEFAULT_TIMEOUT;

    // Internal use : throw BuildException
    private boolean buildException;
    private Throwable buildExceptionSource;

    protected File pctLib = null;
    protected int plID = -1; // Unique ID when creating temp files
    private File initProc = null;
    private int initProcId = -1; // Unique ID when creating temp files
    private Charset charset = null;
    private Collection<File> profilerParams = new ArrayList<>();

    /**
     * Default constructor
     */
    public PCTBgRun() {
        super();

        options = new GenericExecuteOptions(this);
        options.setProcedure("pct/server.p");

        // Nom de la PL à créer
        plID = PCT.nextRandomInt();

        initProcId = PCT.nextRandomInt();
        initProc = new File(System.getProperty(PCT.TMPDIR), "pct_init" + initProcId + ".p"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
    }

    protected void setRunAttributes(GenericExecuteOptions attrs) {
        this.options = attrs;
        options.setProcedure("pct/server.p");
    }

    /**
     * @deprecated
     */
    @Deprecated
    public void addPCTConnection(PCTConnection dbConn) {
        addDBConnection(dbConn);
    }

    // Variation pour antlib
    public void addDB_Connection(PCTConnection dbConn) {
        addDBConnection(dbConn);
    }

    // Variation pour antlib
    public void addDB_Connection_Set(DBConnectionSet set) {
        addDBConnectionSet(set);
    }

    // Legacy
    public void addPCTRunOption(PCTRunOption option) {
        options.addOption(option);
    }

    // **********************
    // IRunAttributes methods

    @Override
    public void addDBConnection(PCTConnection dbConn) {
        options.addDBConnection(dbConn);
    }

    @Override
    public void addDBConnectionSet(DBConnectionSet set) {
        options.addDBConnectionSet(set);
    }

    @Override
    public void addOption(PCTRunOption option) {
        options.addOption(option);
    }

    @Override
    public void addParameter(RunParameter param) {
        options.addParameter(param);
    }

    @Override
    public void addOutputParameter(OutputParameter param) {
        options.addOutputParameter(param);
    }

    @Override
    public void addProfiler(Profiler profiler) {
        options.addProfiler(profiler);
    }

    @Override
    public void setParamFile(File pf) {
        options.setParamFile(pf);
    }

    @Override
    public void setNumSep(String numsep) {
        options.setNumSep(numsep);
    }

    @Override
    public void setNumDec(String numdec) {
        options.setNumDec(numdec);
    }

    @Override
    public void setParameter(String param) {
        options.setParameter(param);
    }

    @Override
    public void setDebugPCT(boolean debugPCT) {
        options.setDebugPCT(debugPCT);
    }

    @Override
    public void setXCodeSessionKey(String xCodeSessionKey) {
        options.setXCodeSessionKey(xCodeSessionKey);
    }

    @Override
    public void setClientMode(String clientMode) {
        options.setClientMode(clientMode);
    }

    @Override
    public void setClrnetcore(boolean clrnetcore) {
        options.setClrnetcore(clrnetcore);
    }

    @Override
    public void setCompileUnderscore(boolean compUnderscore) {
        options.setCompileUnderscore(compUnderscore);
    }

    @Override
    public void setDirSize(int dirSize) {
        options.setDirSize(dirSize);
    }

    @Override
    public void setGraphicalMode(boolean graphMode) {
        options.setGraphicalMode(graphMode);
    }

    @Override
    public void setIniFile(File iniFile) {
        options.setIniFile(iniFile);
    }

    @Override
    public void setFailOnError(boolean failOnError) {
        options.setFailOnError(failOnError);
    }

    @Override
    public void setQuickRequest(boolean quickRequest) {
        options.setQuickRequest(quickRequest);
    }

    @Override
    public void addPropath(Path propath) {
        options.addPropath(propath);
    }

    @Override
    public void setCpStream(String cpStream) {
        options.setCpStream(cpStream);
    }

    @Override
    public void setCpInternal(String cpInternal) {
        options.setCpInternal(cpInternal);
    }

    @Override
    public void setCpCase(String cpCase) {
        options.setCpCase(cpCase);
    }

    @Override
    public void setCpColl(String cpColl) {
        options.setCpColl(cpColl);
    }

    @Override
    public void setInputChars(int inputChars) {
        options.setInputChars(inputChars);
    }

    @Override
    public void setCenturyYearOffset(int centuryYearOffset) {
        options.setCenturyYearOffset(centuryYearOffset);
    }

    @Override
    public void setToken(int token) {
        options.setToken(token);
    }

    @Override
    public void setMaximumMemory(int maximumMemory) {
        options.setMaximumMemory(maximumMemory);
    }

    @Override
    public void setStackSize(int stackSize) {
        options.setStackSize(stackSize);
    }

    @Override
    public void setTTBufferSize(int ttBufferSize) {
        options.setTTBufferSize(ttBufferSize);
    }

    @Override
    public void setMsgBufferSize(int msgBufSize) {
        options.setMsgBufferSize(msgBufSize);
    }

    @Override
    public void setDebugReady(int debugReady) {
        options.setDebugReady(debugReady);
    }

    @Override
    public void setTempDir(File tempDir) {
        options.setTempDir(tempDir);
    }

    @Override
    public void setBaseDir(File baseDir) {
        options.setBaseDir(baseDir);
    }

    @Override
    public void setAssemblies(String assemblies) {
        options.setAssemblies(assemblies);
    }

    @Override
    public void setDateFormat(String dateFormat) {
        options.setDateFormat(dateFormat);
    }

    @Override
    public void setRelativePaths(boolean rel) {
        options.setRelativePaths(rel);
    }

    @Override
    public void addDBAlias(DBAlias alias) {
        options.addDBAlias(alias);
    }

    public void setResultProperty(String resultProperty) {
        options.setResultProperty(resultProperty);
    }

    @Override
    public void setMainCallback(String callback) {
        throw new BuildException("Callback is not yet supported on multi-threaded PCTRun");
    }

    @Override
    public void setNoErrorOnQuit(boolean noErrorOnQuit) {
        throw new BuildException("noErrorOnQuit is not yet supported on multi-threaded PCTRun");
    }

    @Override
    public void setSuperInit(boolean superInit) {
        throw new BuildException("superInit is not yet supported on multi-threaded PCTRun");
    }

    @Override
    public void setOutput(File output) {
        throw new BuildException("output is not yet supported on multi-threaded PCTRun");
    }

    // End of IRunAttribute methods
    // ****************************

    /**
     * Number of threads to throw when running task
     * 
     * @param numThreads Number of threads
     */
    public void setNumThreads(int numThreads) {
        if (numThreads <= 0)
            throw new IllegalArgumentException("Invalid numThreads parameter");
        this.numThreads = numThreads;
    }

    public void setTimeout(long timeout) {
        this.timeout = timeout;
    }

    public GenericExecuteOptions getOptions() {
        return options;
    }

    protected abstract BackgroundWorker createOpenEdgeWorker(Socket socket);

    public void setBuildException(Throwable exception) {
        buildException = true;
        buildExceptionSource = exception;
    }

    private ExecTask prepareExecTask() {
        ExecTask exec = new ExecTask(this);
        exec.setExecutable(getAVMExecutable(options.isGraphMode()).toString());

        for (String str : options.getCmdLineParameters()) {
            exec.createArg().setValue(str);
        }

        // Check for base directory
        if (options.getBaseDir() != null && options.getBaseDir().isDirectory()) {
            exec.setDir(options.getBaseDir());
        }

        // Specific configuration for profiler
        if ((options.getProfiler() != null) && options.getProfiler().isEnabled()) {
            File profParam = new File(System.getProperty(PCT.TMPDIR), "prof" + PCT.nextRandomInt() + ".pf"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
            createProfilerParamFile(profParam);
            exec.createArg().setValue("-profiler");
            exec.createArg().setValue(profParam.getAbsolutePath());
            // Kept for cleanup
            profilerParams.add(profParam);
        }

        Environment.Variable var = new Environment.Variable();
        var.setKey("DLC"); //$NON-NLS-1$
        var.setValue(this.getDlcHome().toString());
        exec.addEnv(var);

        for (Variable var2 : getEnvironmentVariables()) {
            exec.addEnv(var2);
        }

        return exec;
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    @Override
    public void execute() {
        if ((options.getProcedure() == null) || (options.getProcedure().length() == 0))
            throw new BuildException("Procedure attribute not defined");
        if ((options.getProcedure() != null) && !options.getProcedure().trim().isEmpty()
                && (options.getClassName() != null) && !options.getClassName().trim().isEmpty())
            throw new BuildException("Procedure and className attributes are mutually exclusive");

        ListenerThread listener = null;
        int port = 0;
        checkDlcHome();
        if (options.getProfiler() != null)
            options.getProfiler().validate(true);
        
        // See comment in PCTRun#execute() on why file name is generated now
        pctLib = new File(
                System.getProperty(PCT.TMPDIR), "pct" + plID + (isSourceCodeUsed() ? "" : ".pl")); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$

        // Starting the listener thread
        try {
            listener = new ListenerThread();
            listener.start();
            port = listener.getLocalPort();
        } catch (IOException ioe) {
            cleanup();
            throw new BuildException(ioe);
        }

        // Each thread needs to know the port number of master server
        options.addParameter(new RunParameter("portNumber", Integer.toString(port))); //$NON-NLS-1$

        this.preparePropath();

        createInitProcedure(initProc);

        // Using Ant Parallel task to execute processes
        Parallel parallel = new Parallel();
        parallel.bindToOwner(this);

        // Creates as many Exec tasks as needed
        for (int zz = 0; zz < numThreads; zz++) {
            ExecTask task = prepareExecTask();
            task.createArg().setValue("-p");
            task.createArg().setValue(initProc.getAbsolutePath());
            parallel.addTask(task);
        }

        try {
            if (!extractPL(pctLib)) {
                throw new BuildException("Unable to extract pct.pl");
            }
        } catch (IOException caught) {
            cleanup();
            throw new BuildException(caught);
        }

        // And executes Exec task
        parallel.execute();
        cleanup();

        try {
            // Waiting for listener thread to stop
            listener.join();
        } catch (InterruptedException ie) {
            throw new BuildException(ie);
        } finally {
            cleanup();
        }

        if (buildException) {
            if (buildExceptionSource == null)
                throw new BuildException("Build failed");
            else
                throw new BuildException(buildExceptionSource);
        }

    }

    /**
     * Returns charset to be used when writing files in Java to be read by Progress session (thus
     * according to cpstream, parameter files, ...) and dealing with OE encodings (such as undefined
     * or 1252)
     */
    public Charset getCharset() {
        if (charset != null) {
            return charset;
        }
        charset = getCharset(readCharset());

        return charset;
    }

    private String readCharset() {
        String pfCpInt = null, pfCpStream = null;

        // If paramFile is defined, then read it and check for cpStream or cpInternal
        if (options.getParamFile() != null) {
            try {
                PFReader reader = new PFReader(new FileInputStream(options.getParamFile()));
                pfCpInt = reader.getCpInternal();
                pfCpStream = reader.getCpStream();
            } catch (IOException uncaught) {

            }
        }

        if (options.getCpStream() != null)
            return options.getCpStream();
        else if (pfCpStream != null)
            return pfCpStream;
        else if (options.getCpInternal() != null)
            return options.getCpInternal();
        else if (pfCpInt != null)
            return pfCpInt;
        else
            return null;
    }

    /**
     * This is a customized copy of PCTRun.createInitProcedure. The only difference is that database
     * connections and propath modifications are not made in this file (it's delayed in the
     * background process).
     */
    private void createInitProcedure(File f) {
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(f))) {
            bw.write(MessageFormat.format(this.getProgressProcedures().getInitString(),
                    options.isVerbose(), false));

            // Defines internal propath
            if (this.internalPropath != null) {
                String[] lst = this.internalPropath.list();
                for (int k = lst.length - 1; k >= 0; k--) {
                    bw.write(MessageFormat.format(this.getProgressProcedures().getPropathString(),
                            escapeString(lst[k]) + File.pathSeparatorChar));
                }
            }

            // XCode session key
            if ((options.getXCodeSessionKey() != null) && !options.getXCodeSessionKey().trim().isEmpty()) {
                bw.write(MessageFormat.format(this.getProgressProcedures().getXCodeSessionKey(),
                        options.getXCodeSessionKey().trim()));
                bw.newLine();
            }

            // Defines parameters
            for (RunParameter param : options.getRunParameters()) {
                if (param.validate()) {
                    bw.write(MessageFormat.format(
                            this.getProgressProcedures().getParameterString(),
                            escapeString(param.getName()), escapeString(param.getValue())));
                }
            }

            bw.write(MessageFormat.format(this.getProgressProcedures().getRunString(),
                    escapeString(options.getProcedure()), ""));

        } catch (IOException ioe) {
            throw new BuildException(ioe);
        }
    }

    private void createProfilerParamFile(File paramFile) {
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(paramFile))) {
            // Assuming nobody will use file names with double quotes in this case...
            bw.write("-FILENAME \"" + new File(options.getProfiler().getOutputDir(), "profiler"
                    + PCT.nextRandomInt() + options.getProfiler().getExtension() + "\""));
            bw.newLine();
            if (options.getProfiler().hasCoverage()) {
                bw.write("-COVERAGE");
                bw.newLine();
            }
            if (options.getProfiler().hasStatistics()) {
                bw.write("-STATISTICS");
                bw.newLine();
            }
            if (options.getProfiler().getListings() != null) {
                bw.write("-LISTINGS \"" + options.getProfiler().getListings().getAbsolutePath()
                        + "\"");
                bw.newLine();
            }
            bw.write("-DESCRIPTION \"" + options.getProfiler().getDescription() + "\"");
            bw.newLine();
        } catch (IOException caught) {
            throw new BuildException(caught);
        }
    }

    private List<String> getPropathAsList() {
        List<String> list = new ArrayList<>();
        if (options.getPropath() != null) {
            String[] lst = options.getPropath().list();
            for (int k = lst.length - 1; k >= 0; k--) {
                if (options.useRelativePaths()) {
                    try {
                        list.add(FileUtils.getRelativePath(
                                (options.getBaseDir() == null ? getProject().getBaseDir() : options
                                        .getBaseDir()), new File(lst[k])).replace('/',
                                File.separatorChar));
                    } catch (Exception caught) {
                        throw new BuildException(caught);
                    }
                } else {
                    list.add(lst[k]);
                }
            }
        }

        return list;
    }
    protected void preparePropath() {
        // PL is extracted later, we just have a reference on filename
        FileList list = new FileList();
        list.setDir(pctLib.getParentFile().getAbsoluteFile());
        FileList.FileName fn = new FileList.FileName();
        fn.setName(pctLib.getName());
        list.addConfiguredFile(fn);
        this.internalPropath = new Path(this.getProject());
        this.internalPropath.addFilelist(list);
    }

    protected void cleanup() {
        // Always delete pct.pl, even in debugPCT mode
        if (pctLib != null) {
            deleteFile(pctLib);
        }
        if (options.isDebugPCT())
            return;

        deleteFile(initProc);
        for (File f : profilerParams) {
            deleteFile(f);
        }
    }

    protected synchronized void logMessages(List<Message> logs) {
        for (Message s : logs) {
            log(s.getMsg(), s.getLevel());
        }
    }

    /**
     * Listener thread
     */
    private class ListenerThread extends Thread {
        // Timeout for accept method -- 30 seconds should be enough.
        private static final int TIMEOUT = 30000;

        private ServerSocket server = null;

        public ListenerThread() throws IOException {
            this.server = new ServerSocket(0);
            this.server.setSoTimeout(TIMEOUT);
        }

        public int getLocalPort() {
            return server.getLocalPort();
        }

        /**
         * Generic calls made by PCTBgRun : connect to database and change propath, then pass away
         * to custom method
         */
        @Override
        public void run() {
            ExecutorService group = Executors.newFixedThreadPool(numThreads);
            for (int zz = 0; zz < numThreads; zz++) {
                final Socket socket;
                try {
                    socket = server.accept();
                } catch (IOException caught) {
                    setBuildException(caught);
                    return;
                }

                group.execute(() -> {
                    final BackgroundWorker status = createOpenEdgeWorker(socket);
                    status.setDBConnections(options.getDBConnections().iterator());
                    status.setAliases(options.getAliases().iterator());
                    status.setPropath(getPropathAsList().iterator());

                    try {
                        while (!status.quit) {
                            status.performAction();
                            status.listen();
                        }
                    } catch (IOException caught) {
                        setBuildException(caught);
                    }
                });
            }
            group.shutdown();
            try {
                group.awaitTermination(timeout, TimeUnit.SECONDS);
            } catch (InterruptedException caught) {
                setBuildException(caught);
                Thread.currentThread().interrupt();
            }
        }
    }
}