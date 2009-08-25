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
import org.apache.tools.ant.taskdefs.Parallel;
import org.apache.tools.ant.types.Environment;
import org.apache.tools.ant.types.FileList;
import org.apache.tools.ant.types.Path;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketTimeoutException;

import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Random;

/**
 * Run a background Progress procedure.
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET </a>
 * @version $Revision$
 */
public abstract class PCTBgRun extends PCT {
    private GenericExecuteOptions options;

    protected Path internalPropath = null;

    // Number of processes to use
    private int numThreads = 1;
    // Internal use : socket communication
    private int port;
    // Internal use : throw BuildException
    private boolean buildException;
    private Throwable buildExceptionSource;
    
    protected File pctLib = null;
    protected int plID = -1; // Unique ID when creating temp files
    private File initProc = null;
    private int initProcId = -1; // Unique ID when creating temp files

    /**
     * Default constructor
     */
    public PCTBgRun() {
        super();

        options = new GenericExecuteOptions(getProject());
        options.setProcedure("pct/_server.p");

        // Nom de la PL à créer
        plID = new Random().nextInt() & 0xffff;
        pctLib = new File(System.getProperty("java.io.tmpdir"), "pct" + plID + ".pl"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$

        initProcId = new Random().nextInt() & 0xffff;
        initProc = new File(System.getProperty("java.io.tmpdir"), "pct_init" + initProcId + ".p"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
    }

    public void addPCTConnection(PCTConnection dbConn) {
        options.addPCTConnection(dbConn);
    }

    public void addOption(PCTRunOption option) {
        options.addOption(option);
    }

    public void addPCTRunOption(PCTRunOption option) {
        options.addPCTRunOption(option);
    }

    public void addParameter(RunParameter param) {
        options.addParameter(param);
    }

    public void addOutputParameter(OutputParameter param) {
        options.addOutputParameter(param);
    }

    public void setParamFile(File pf) {
        options.setParamFile(pf);
    }

    public void setNumSep(String numsep) {
        options.setNumSep(numsep);
    }

    public void setNumDec(String numdec) {
        options.setNumDec(numdec);
    }

    public void setParameter(String param) {
        options.setParameter(param);
    }

    public void setDebugPCT(boolean debugPCT) {
        options.setDebugPCT(debugPCT);
    }

    public void setCompileUnderscore(boolean compUnderscore) {
        options.setCompileUnderscore(compUnderscore);
    }

    public void setDirSize(int dirSize) {
        options.setDirSize(dirSize);
    }

    public void setGraphicalMode(boolean graphMode) {
        options.setGraphicalMode(graphMode);
    }

    public void setIniFile(File iniFile) {
        options.setIniFile(iniFile);
    }

    public void setFailOnError(boolean failOnError) {
        options.setFailOnError(failOnError);
    }

    public void setPropath(Path propath) {
        options.setPropath(propath);
    }

    public Path createPropath() {
        return options.createPropath();
    }

    public void setCpStream(String cpStream) {
        options.setCpStream(cpStream);
    }

    public void setCpInternal(String cpInternal) {
        options.setCpInternal(cpInternal);
    }

    public void setInputChars(int inputChars) {
        options.setInputChars(inputChars);
    }

    public void setCenturyYearOffset(int centuryYearOffset) {
        options.setCenturyYearOffset(centuryYearOffset);
    }

    public void setToken(int token) {
        options.setToken(token);
    }

    public void setMaximumMemory(int maximumMemory) {
        options.setMaximumMemory(maximumMemory);
    }

    public void setStackSize(int stackSize) {
        options.setStackSize(stackSize);
    }

    public void setTTBufferSize(int ttBufferSize) {
        options.setTTBufferSize(ttBufferSize);
    }

    public void setMsgBufferSize(int msgBufSize) {
        options.setMsgBufferSize(msgBufSize);
    }

    public void setDebugReady(int debugReady) {
        options.setDebugReady(debugReady);
    }

    public void setTempDir(File tempDir) {
        options.setTempDir(tempDir);
    }

    public void setBaseDir(File baseDir) {
        options.setBaseDir(baseDir);
    }

    public void setResultProperty(String resultProperty) {
        options.setResultProperty(resultProperty);
    }

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

    public GenericExecuteOptions getOptions() {
        return options;
    }

    protected abstract BackgroundWorker createOpenEdgeWorker(Socket socket);

    public void setBuildException() {
        buildException = true;
    }
    
    public void setBuildException(Throwable exception) {
        buildException = true;
        buildExceptionSource = exception;
    }
    
    private ExecTask prepareExecTask() {
        ExecTask exec = (ExecTask) getProject().createTask("exec"); //$NON-NLS-1$
        exec.setOwningTarget(getOwningTarget());
        exec.setTaskName(getTaskName());
        exec.setDescription(getDescription());

        File executable = this.getExecPath((options.isGraphMode() ? "prowin32" : "_progres")); //$NON-NLS-1$ //$NON-NLS-2$
        exec.setExecutable(executable.toString());

        for (Iterator i = options.getCmdLineParameters().iterator(); i.hasNext();) {
            exec.createArg().setValue((String) i.next());
        }

        // Check for base directory
        if (options.getBaseDir() != null && options.getBaseDir().exists()
                && options.getBaseDir().isDirectory()) {
            exec.setDir(options.getBaseDir());
        }

        Environment.Variable var = new Environment.Variable();
        var.setKey("DLC"); //$NON-NLS-1$
        var.setValue(this.getDlcHome().toString());
        exec.addEnv(var);

        return exec;
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        ListenerThread listener = null;

        // Starting the listener thread
        try {
            listener = new ListenerThread();
            listener.start();
            this.port = listener.getLocalPort();
        } catch (IOException ioe) {
            cleanup();
            throw new BuildException(ioe);
        }

        // Each thread needs to know the port number of master server
        options.addParameter(new RunParameter("portNumber", Integer.toString(this.port))); //$NON-NLS-1$

        this.preparePropath();

        createInitProcedure(initProc);

        // Using Ant Parallel task to execute processes
        Parallel parallel = (Parallel) getProject().createTask("parallel");
        parallel.setOwningTarget(this.getOwningTarget());
        parallel.setTaskName(this.getTaskName());
        parallel.setDescription(this.getDescription());

        // Creates as many Exec tasks as needed
        for (int zz = 0; zz < numThreads; zz++) {
            ExecTask task = prepareExecTask();
            task.createArg().setValue("-p");
            task.createArg().setValue(initProc.getAbsolutePath());
            parallel.addTask(task);
        }

        extractPL(pctLib);

        // And executes Exec task
        parallel.execute();
        cleanup();

        try {
            // Waiting for listener thread to stop
            listener.join();
        } catch (InterruptedException ie) {
            this.cleanup();
            throw new BuildException(ie);
        }

        if (buildException) {
            if (buildExceptionSource == null)
                throw new BuildException("Build failed");
            else
                throw new BuildException(buildExceptionSource);
        }
            
    }

    /**
     * This is a customized copy of PCTRun.createInitProcedure. The only difference is that database
     * connections and propath modifications are not made in this file (it's delayed in the
     * background process).
     */
    private void createInitProcedure(File f) throws BuildException {
        try {
            BufferedWriter bw = new BufferedWriter(new FileWriter(f));

            bw.write(MessageFormat.format(this.getProgressProcedures().getInitString(),
                    new Object[]{ /*
                                   * (this.outputStream == null ? null : this.outputStream
                                   * .getAbsolutePath())
                                   */}));

            // Defines internal propath
            if (this.internalPropath != null) {
                String[] lst = this.internalPropath.list();
                for (int k = lst.length - 1; k >= 0; k--) {
                    bw.write(MessageFormat.format(this.getProgressProcedures().getPropathString(),
                            new Object[]{escapeString(lst[k]) + File.pathSeparatorChar}));
                }
            }

            // Defines parameters
            for (Iterator i = options.getRunParameters().iterator(); i.hasNext();) {
                RunParameter param = (RunParameter) i.next();
                if (param.validate()) {
                    bw
                            .write(MessageFormat.format(this.getProgressProcedures()
                                    .getParameterString(), new Object[]{
                                    escapeString(param.getName()), escapeString(param.getValue())}));
                }
            }

            bw.write(MessageFormat.format(this.getProgressProcedures().getRunString(),
                    new Object[]{escapeString(options.getProcedure())}));

            bw.close();
        } catch (IOException ioe) {
            throw new BuildException(ioe);
        }
    }

    private List getPropathAsList() {
        List list = new ArrayList();
        if (options.getPropath() != null) {
            String[] lst = options.getPropath().list();
            for (int k = lst.length - 1; k >= 0; k--) {
                list.add(lst[k]);
            }
        }

        return list;
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

    protected void cleanup() {
        pctLib.delete();
        initProc.delete();
    }

    protected synchronized void logMessages(List logs) {
        for (Iterator i = logs.iterator(); i.hasNext(); ) {
            String s = (String) i.next();
            log(s);
        }
    }

    /**
     * Listener thread
     * 
     * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET </a>
     */
    private class ListenerThread extends Thread {
        // Timeout for accept method -- 5 seconds should be enough
        // Increase it if you're doing some debugging
        private final static int TIMEOUT = 5000;

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
        public void run() {
            int acceptedThreads = 0;
            ThreadGroup group = new ThreadGroup("PCT");

            while (acceptedThreads < numThreads) {
                try {
                    final BackgroundWorker status = createOpenEdgeWorker(server.accept());
                    status.setDBConnections(options.getDBConnections().iterator());
                    status.setPropath(getPropathAsList().iterator());
                    status.setCustomOptions(null); // TODO

                    Runnable r = new Runnable() {
                        public void run() {
                            try {
                                while (!status.quit) {
                                    status.performAction();
                                    status.listen();
                                }
                            } catch (IOException ioe) {

                            }
                        }
                    };
                    new Thread(group, r).start();
                    acceptedThreads++;
                } catch (SocketTimeoutException caught) {

                } catch (IOException ioe) {

                }
            }
            try {
                synchronized (group) {
                    while (group.activeCount() > 0) {
                        group.wait();
                    }
                }
            } catch (InterruptedException ie) {
                System.out.println("interrupted");
            }

        }
    }
}