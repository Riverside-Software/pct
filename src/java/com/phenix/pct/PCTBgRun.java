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
import org.apache.tools.ant.types.Commandline;
import org.apache.tools.ant.types.Environment;
import org.apache.tools.ant.types.FileList;
import org.apache.tools.ant.types.Path;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.ServerSocket;
import java.net.Socket;

import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Collection;
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
    protected String procedure = "pct/_server.p";
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
    protected Collection dbConnList = null;
    private Collection options = null;
    protected Path propath = null;
    protected Path internalPropath = null;
    protected Collection runParameters = null;
    protected List outputParameters = null;
    private boolean batchMode = true;
    private boolean failOnError = true;
    private String resultProperty = null;
    
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
    
    // Number of processes to use
    private int numThreads = 1;
    // Internal use : socket communication
    private int port;
    // Internal use : throw BuildException
    protected boolean buildException;

    protected File pctLib = null;
    protected int plID = -1; // Unique ID when creating temp files

    /**
     * Default constructor
     */
    public PCTBgRun() {
        super();

        // Nom de la PL à créer
        plID = new Random().nextInt() & 0xffff;
        pctLib = new File(System.getProperty("java.io.tmpdir"), "pct" + plID + ".pl"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
    }

    public void setNumThreads(int numThreads) {
        if (numThreads <= 0)
            throw new IllegalArgumentException("Invalid numThreads parameter");
        this.numThreads = numThreads;
    }

    /**
     * Adds a database connection
     * 
     * @param dbConn Instance of PCTConnection class
     */
    public void addPCTConnection(PCTConnection dbConn) {
        if (this.dbConnList == null) {
            this.dbConnList = new ArrayList();
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
            this.options = new ArrayList();
        }

        this.options.add(option);
    }
    
    public void addPCTRunOption(PCTRunOption option) {
        if (this.options == null) {
            this.options = new ArrayList();
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
            this.runParameters = new ArrayList();
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
            this.outputParameters = new ArrayList();
        this.outputParameters.add(param);
    }

    /**
     * Defines a new collection of parameters
     * 
     * @param params Collection<RunParameter>
     */
    public void setParameters(Collection params) {
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

//    public void setProcedure(String procedure) {
//        this.procedure = procedure;
//    }

    public void setFailOnError(boolean failOnError) {
        throw new BuildException(MessageFormat.format(
                Messages.getString("PCTBgRun.0"), new Object[]{"failOnError"})); //$NON-NLS-1$ //$NON-NLS-2$
    }

    /**
     * Instantiate your own Listener
     * 
     * @return A listener for your task
     */
    protected abstract PCTListener getListener(PCTBgRun parent) throws IOException;

    protected ExecTask prepareExecTask() {
        ExecTask exec = (ExecTask) getProject().createTask("exec"); //$NON-NLS-1$
        exec.setOwningTarget(this.getOwningTarget());
        exec.setTaskName(this.getTaskName());
        exec.setDescription(this.getDescription());

        File a = this.getExecPath((this.graphMode ? "prowin32" : "_progres")); //$NON-NLS-1$ //$NON-NLS-2$
        exec.setExecutable(a.toString());

        for (Iterator i = getCmdLineParameters().iterator(); i.hasNext();) {
            exec.createArg().setValue((String) i.next());
        }

        // Check for base directory
        // TODO Check previous TODO about redundancy :)
        if (this.baseDir != null && this.baseDir.exists() && this.baseDir.isDirectory()) {
            exec.setDir(this.baseDir);
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
        PCTListener listener = null;
        ExecTask[] threads = new ExecTask[numThreads];
        
        for (int zz = 0; zz < numThreads; zz++) {
            threads[zz] = prepareExecTask();
        }
        // Preparing Exec task
//        if (!this.isPrepared()) {
//            this.prepareExecTask();
//        }

        // Starting the listener thread
        try {
            listener = getListener(this);
            listener.start();
            this.port = listener.getLocalPort();
        } catch (IOException ioe) {
            this.cleanup();
            throw new BuildException(ioe);
        }

//        setProcedure("pct/_server.p"); //$NON-NLS-1$
        addParameter(new RunParameter("portNumber", Integer.toString(this.port))); //$NON-NLS-1$
//        addParameter(new RunParameter("threadNumber", Integer.toString(threadNumber))); //NON-NLS-1$
       
        Parallel parallel = (Parallel) getProject().createTask("parallel");
        parallel.setOwningTarget(this.getOwningTarget());
        parallel.setTaskName(this.getTaskName());
        parallel.setDescription(this.getDescription());

        this.preparePropath();
        
        for (int zz = 0; zz < numThreads; zz++) {
            File f = null;
            try {
            f = File.createTempFile("pct_init", ".p");
            } catch (IOException ioe) {
                throw new BuildException(ioe);
            }
            createInitProcedure(f, Integer.valueOf(zz));
            threads[zz].createArg().setValue("-p");
            threads[zz].createArg().setValue(f.getAbsolutePath());
            parallel.addTask(threads[zz]);
        }
        
//        this.createInitProcedure(/* Ajouter file et thread number */);
//        this.setExecTaskParams();
//        exec.createArg().setValue("-p"); //$NON-NLS-1$
//        exec.createArg().setValue(this.initProc.getAbsolutePath());

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
        if (buildException)
            throw new BuildException("Build failed");
    }

    /**
     * This is a customized copy of PCTRun.createInitProcedure. The only difference is that database
     * connections and propath modifications are not made in this file (it's delayed in the
     * background process).
     */
    private void createInitProcedure(File f, Integer threadNumber) throws BuildException {
        try {
            BufferedWriter bw = new BufferedWriter(new FileWriter(f));

            // Progress v8 is unable to write to standard output, so output is redirected in a file,
            // which is parsed in a later stage
//            if (this.getProgressProcedures().needRedirector()) {
//                outputStreamID = new Random().nextInt() & 0xffff;
//                outputStream = new File(
//                        System.getProperty("java.io.tmpdir"), "pctOut" + outputStreamID + ".txt"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
//            }
            bw.write(MessageFormat.format(this.getProgressProcedures().getInitString(),
                    new Object[]{ /*(this.outputStream == null ? null : this.outputStream
                            .getAbsolutePath()) */ }));

            // Defines internal propath
            if (this.internalPropath != null) {
                String[] lst = this.internalPropath.list();
                for (int k = lst.length - 1; k >= 0; k--) {
                    bw.write(MessageFormat.format(this.getProgressProcedures().getPropathString(),
                            new Object[]{escapeString(lst[k]) + File.pathSeparatorChar}));
                }
            }

            // Defines parameters
            if (this.runParameters != null) {
                for (Iterator i = this.runParameters.iterator(); i.hasNext();) {
                    RunParameter param = (RunParameter) i.next();
                    if (param.validate()) {
                        bw.write(MessageFormat.format(this.getProgressProcedures()
                                .getParameterString(), new Object[]{escapeString(param.getName()),
                                escapeString(param.getValue())}));
                    }
                }
            }
            bw.write(MessageFormat.format(this.getProgressProcedures()
                    .getParameterString(), new Object[]{escapeString("threadNumber"),
                    escapeString(threadNumber.toString())}));

            bw.write(MessageFormat.format(this.getProgressProcedures().getRunString(),
                    new Object[]{escapeString(this.procedure)}));
//            bw.write(MessageFormat.format(this.getProgressProcedures().getReturnProc(),
//                    new Object[]{escapeString(status.getAbsolutePath())}));

            bw.close();
        } catch (IOException ioe) {
            throw new BuildException(ioe);
        }
    }

    /**
     * Listener thread
     * 
     * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET </a>
     */
    protected abstract class PCTListener extends Thread {
        // Timeout for accept method -- 5 seconds should be enough
        // Increase it if you're doing some debugging
        private final static int TIMEOUT = 500000;

        protected PCTBgRun parent = null;

        private ServerSocket server = null;
//        private Socket sock = null;
//        private BufferedReader reader = null;
//        private BufferedWriter writer = null;
        protected ThreadStatus[] statuses = null;
        
        public PCTListener(PCTBgRun parent) throws IOException {
            this.parent = parent;
            this.server = new ServerSocket(0);
            this.server.setSoTimeout(TIMEOUT);
            statuses = new ThreadStatus[parent.numThreads];
            for (int zz = 0; zz < parent.numThreads; zz++) {
                statuses[zz] = new ThreadStatus(zz);
            }
        }

        public int getLocalPort() {
            return this.server.getLocalPort();
        }

        /**
         * Sends a command to the Progress process, and waits for execution
         * 
         * @param cmd String containing the Progress order (see pct/_server.p)
         * @return True if OK, false if not OK...
         */
        protected boolean sendCommand(int tNum, String cmd) throws IOException {
            // Check validity
            if ((cmd == null) || (cmd.trim().equals(""))) //$NON-NLS-1$
                return false;

            // Splits Progress command and parameters
            String command = null, param = null;
            int pos = cmd.indexOf(' ');
            if ((pos == -1) || (cmd.length() == pos)) {
                command = cmd.trim();
            } else {
                command = cmd.substring(0, pos).trim();
                param = cmd.substring(pos + 1).trim();
            }

            // First character in capital letters
            if (command.length() == 1) {
                command = command.toUpperCase();
            } else {
                command = command.substring(0, 1).toUpperCase() + command.substring(1);
            }

            statuses[tNum].writer.write(command + " " + param); //$NON-NLS-1$
            statuses[tNum].writer.newLine();
            statuses[tNum].writer.flush();

            return true;
            // And wait for response
            /* String returnCode = null;
            List retString = new Vector();
            String s = null;
            int count = 1;
            while (!(s = reader.readLine()).trim().equalsIgnoreCase("END.")) { //$NON-NLS-1$
                if (count++ == 1)
                    returnCode = s;
                else
                    retString.add(s);
            }

            Integer threadNumber = new Integer(returnCode.substring(0, 1));
            returnCode = returnCode.substring(2);
            boolean retValue = returnCode.startsWith("OK:"); //$NON-NLS-1$
            try {
                Method m = this.getClass().getMethod("handle" + command, //$NON-NLS-1$
                        new Class[]{Integer.class, String.class, String.class, List.class});
                m.invoke(this, new Object[]{threadNumber, param, returnCode, retString});
            } catch (NoSuchMethodException nsme) {
                log(MessageFormat.format(Messages.getString("PCTBgRun.1"), new Object[]{command}), //$NON-NLS-1$
                        Project.MSG_WARN);
            } catch (InvocationTargetException ite) {
                log(MessageFormat.format(Messages.getString("PCTBgRun.2"), new Object[]{command, //$NON-NLS-1$
                        ite.getCause().getClass().getName(), ite.getCause().getMessage()}),
                        Project.MSG_WARN);
            } catch (Throwable t) {
                log(MessageFormat.format(Messages.getString("PCTBgRun.3"), new Object[]{command, //$NON-NLS-1$
                        t.getClass().getName(), t.getMessage()}), Project.MSG_WARN);
            }

            return retValue;*/
        }

        /**
         * Ecoute sur la chaussette, et rend la main quand tout le monde est au bout
         * @return
         */
        public void listen(int tNum) {
            while (true) {
                try {
                    String s= statuses[tNum].reader.readLine();
                    String[] ss = s.split(":");
                    Integer threadNumber = new Integer(ss[0]);
                    if (ss[1].equalsIgnoreCase("OK")) {
                        if (ss[2].equalsIgnoreCase("quit")) {
                            statuses[threadNumber.intValue()].status  =5;
                            boolean quit = true;
                            for (int zz = 0; zz < numThreads; zz++) {
                                quit &= (statuses[threadNumber.intValue()].status == 5);
                            }
                            if (quit) return;
                        } else {
                        statuses[threadNumber.intValue()].lastCmdStatus = 1;
                        statuses[threadNumber.intValue()].lastCommand = ss[2];
                        statuses[threadNumber.intValue()].lastCommandParameter = (ss.length >= 4 ? ss[3] : null);
//                        statuses[threadNumber.intValue()].getRetVals().add(ss[3]);
                        }
                    } else if (ss[1].equalsIgnoreCase("ERR")){
                        statuses[threadNumber.intValue()].lastCmdStatus = 2;
                        statuses[threadNumber.intValue()].lastCommand = ss[2];
                        statuses[threadNumber.intValue()].lastCommandParameter = ss[3];
                    } else if (ss[1].equalsIgnoreCase("MSG")) {
                        statuses[threadNumber.intValue()].retVals.add(ss[2]);
                    } else if (ss[1].equalsIgnoreCase("END")) {
                        // On envoie la sauce
                        Method m = this.getClass().getMethod("handle" + statuses[threadNumber.intValue()].lastCommand, //$NON-NLS-1$
                                new Class[]{Integer.class , String.class/*, String.class, List.class */ });
                        m.invoke(this, new Object[]{threadNumber, statuses[threadNumber.intValue()].lastCommandParameter /*, param, returnCode, retString*/ });
                    }
                } catch (IOException ioe) {
                    ioe.printStackTrace();
                    return ;
                } catch (SecurityException e) {
                    e.printStackTrace();
                    return ;
                } catch (NoSuchMethodException e) {
                    e.printStackTrace();
                    return ;
                } catch (IllegalArgumentException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                    return ;
                } catch (IllegalAccessException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                    return ;
                } catch (InvocationTargetException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                    return ;
                }
            }
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
                    Socket socket = this.server.accept();
                    BufferedReader rr = new BufferedReader(new InputStreamReader(socket.getInputStream()));
                    String n = rr.readLine();
                    final int i = Integer.parseInt(n);
                    statuses[i].status = 1;
                    statuses[i].socket = socket;
                    statuses[i].reader = rr;
                    statuses[i].writer = new BufferedWriter(new OutputStreamWriter(socket.getOutputStream()));
                    statuses[i].dbConnections = (dbConnList == null ? null : dbConnList.iterator());

                    List list = new ArrayList();
                    if (this.parent.propath != null) {
                    String[] lst = this.parent.propath.list();
                    for (int k = lst.length - 1; k >= 0; k--) {
                        list.add(lst[k]);
//                        sendCommand(threadNumber.intValue(), "propath " + lst[k]); //$NON-NLS-1$
                    }
                    }
                    statuses[i].propath = list.iterator();

                    Runnable r = new Runnable() {
                        public void run() {
                            try {
                            handleConnect(Integer.valueOf(i), "");
                            listen(i);
                            } catch (IOException ioe) {
                                
                            }
//                            listen(i);
                        }
                    };
                    new Thread(r).start();
                    acceptedThreads++;
                } catch (IOException ioe) {
                    
                }
            }
            try {
            synchronized(group) {
                while (group.activeCount() > 0) {
                    group.wait();
                }
            }
            } catch (InterruptedException ie) {
                System.out.println("interrupted");
            }
            
//            try {
//                sock = this.server.accept();
//                reader = new BufferedReader(new InputStreamReader(sock.getInputStream()));
//                writer = new BufferedWriter(new OutputStreamWriter(sock.getOutputStream()));
//                // Receive greeting from Progress
////                while (!(reader.readLine()).trim().equals("END.")); //$NON-NLS-1$
//            } catch (IOException ioe) {
//                return;
//            }
            
//            listen();
            /* try {
                if (dbConnList != null) {
                    for (Iterator iter = dbConnList.iterator(); iter.hasNext();) {
                        PCTConnection dbc = (PCTConnection) iter.next();
                        String s = dbc.createConnectString();
                        sendCommand("CONNECT " + s); //$NON-NLS-1$
                        // FIXME Ajouter les alias
                    }
                }
                if (this.parent.propath != null) {
                    String[] lst = this.parent.propath.list();
                    for (int k = lst.length - 1; k >= 0; k--) {
                        sendCommand("propath " + lst[k]); //$NON-NLS-1$
                    }
                } 
                buildException = custom();
                sendCommand("QUIT"); //$NON-NLS-1$
            } catch (Throwable be) {
                this.parent.cleanup();
            } */

        }

        public void handleInit(Integer threadNumber, String param) throws IOException {
            statuses[threadNumber.intValue()].status = 1;
            // On attaque les connexions bases de données
            handleConnect(threadNumber, "");
        }

        /**
         * Handles connect response
         */
        public void handleConnect(Integer threadNumber , String param/*, String param, String ret, List strings*/) throws IOException {
            // Nothing
            statuses[threadNumber.intValue()].status = 2;
            if (statuses[threadNumber.intValue()].dbConnections == null) {
                handlePropath(threadNumber, "");
            } else 
            if (statuses[threadNumber.intValue()].dbConnections.hasNext()) {
                PCTConnection dbc = (PCTConnection) statuses[threadNumber.intValue()].dbConnections.next();
                StringBuffer sb = new StringBuffer(dbc.createConnectString());
                if (dbc.hasAliases()) {
                    sb.append('|').append(dbc.getDbName());
                    for (Iterator iter = dbc.getAliases().iterator(); iter.hasNext(); ) {
                        PCTAlias alias = (PCTAlias) iter.next();
                        sb.append('|').append(alias.getName());
                    }
                }
                sendCommand(threadNumber.intValue(), "Connect " + sb.toString());
            } else {
                handlePropath(threadNumber, "");
            }
        }

        /**
         * Handles propath response
         */
        public void handlePropath(Integer threadNumber , String param /*, String param, String ret, List strings*/ ) throws IOException {
            statuses[threadNumber.intValue()].status = 3;
            
            if (statuses[threadNumber.intValue()].propath == null) {
                // On passe la main aux customs
                custom(threadNumber.intValue());
            } else if (statuses[threadNumber.intValue()].propath.hasNext()) {
                String s = (String) statuses[threadNumber.intValue()].propath.next();
                sendCommand(threadNumber.intValue(), "Propath " + s + File.pathSeparatorChar);
            } else {
                custom(threadNumber.intValue());
            }
            
//            if (statuses[threadNumber.intValue()].status == 3) {
//                // On passe la main aux customs
//                custom(threadNumber.intValue());
//            } else {
//                if (this.parent.propath != null) {
//                    String[] lst = this.parent.propath.list();
//                    for (int k = lst.length - 1; k >= 0; k--) {
//                        sendCommand(threadNumber.intValue(), "propath " + lst[k]); //$NON-NLS-1$
//                    }
//                    statuses[threadNumber.intValue()].status = 3;
//                } else {
//                    statuses[threadNumber.intValue()].status = 3;
//                    // On passe la main aux customs
//                    custom(threadNumber.intValue());
//                    
//                }
//
//            }
        }

        /**
         * This is where you code the task's logic
         */
        protected abstract boolean custom(int threadNumber) throws IOException;
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
    
protected void cleanup() {
    // TODO Auto-generated method stub

}

    protected static class ThreadStatus {
        private final int threadNumber;

        private Socket socket;
        private BufferedReader reader;
        private BufferedWriter writer;

        // 0 tout début 1 connecté 2 db ok 3 propath ok 4 custom 5 terminé
        protected int status;
        // Dernière base de données connectée dans la liste
        private Iterator dbConnections;
        // Dernière entrée de propath ajoutée dans la liste
        private Iterator propath;
//        private int lastPropathEntry;
        
        // Dernière commande envoyée
        private String lastCommand;
        // Dernier paramètre de commande envoyé
        private String lastCommandParameter;
        // Succès ou échec de la commande
        protected int lastCmdStatus;
        
        // Valeurs renvoyées par la commande
        private final List retVals = new ArrayList();
        
        public ThreadStatus(int threadNumber) {
            this.threadNumber = threadNumber;
        }
        
   }
}