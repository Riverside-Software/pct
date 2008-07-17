/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) The Apache Software Foundation.  All rights
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

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.MessageFormat;
import java.util.Random;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.ExecTask;
import org.apache.tools.ant.types.Environment;

/**
 * Class managing name servers tasks
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET </a>
 * @version $Revision$
 */
public class PCTNSBroker extends PCTBroker {
    private final static String DEFAULT_NS = "NS1";

    private String nameServer = DEFAULT_NS;
    private boolean autoStart = false;
    private int brokerKeepAliveTimeout = -1;
    private boolean logAppend = true;
    private File workDir = null;
    private File serverLogFile = null;
    private int portNumber = -1;
    private int serverLogLevel = -1;

    private int tmpFileID = -1;
    private File tmpFile = null;

    /**
     * Creates a new PCTNSBroker object. Temp files initialization.
     */
    public PCTNSBroker() {
        super();

        tmpFileID = new Random().nextInt() & 0xffff;
        tmpFile = new File(System.getProperty("java.io.tmpdir"), "pct_delta" + tmpFileID + ".txt"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
    }

    /**
     * AutoStart property. Default value is false.
     * 
     * @param autoStart Boolean
     */
    public void setAutoStart(boolean autoStart) {
        this.autoStart = autoStart;
    }

    /**
     * brokerKeepAliveTimeout property. Default value is 30.
     * 
     * @param brokerKeepAliveTimeout int
     */
    public void setBrokerKeepAliveTimeout(int brokerKeepAliveTimeout) {
        this.brokerKeepAliveTimeout = brokerKeepAliveTimeout;
    }

    /**
     * LogAppend property. Default value is true.
     * 
     * @param logAppend Boolean
     */
    public void setLogAppend(boolean logAppend) {
        this.logAppend = logAppend;
    }

    /**
     * Port number (or name).
     * 
     * @param portNumber String
     */
    public void setPortNumber(int portNumber) {
        this.portNumber = portNumber;
    }

    /**
     * Server log file property. No default value.
     * 
     * @param serverLogFile File
     */
    public void setServerLogFile(File serverLogFile) {
        this.serverLogFile = serverLogFile;
    }

    /**
     * Server logging level property. No default value. Should be between 1 and 5.
     * 
     * @param serverLogLevel
     */
    public void setServerLogLevel(int serverLogLevel) {
        this.serverLogLevel = serverLogLevel;
    }

    /**
     * Working directory of servers. No default value.
     * 
     * @param workDir File
     */
    public void setWorkDir(File workDir) {
        this.workDir = workDir;
    }

    /**
     * Controlling name server. Default value is NS1
     * 
     * @param ns String
     */
    public void setNameServer(String ns) {
        this.nameServer = ns;
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        File propFile = null;

        try {
            this.checkAttributes();
            // Choosing right properties file
            if (this.file == null) {
                propFile = new File(this.getDlcHome(), "properties/" + UBROKER_PROPERTIES);
            } else {
                propFile = new File(this.file);
            }
            if (!propFile.exists())
                throw new BuildException("Unable to find properties file "
                        + propFile.getAbsolutePath());
            // And do the work
            writeDeltaFile();
            Task task = getCmdLineMergeTask(propFile, tmpFile);
            task.execute();
        } catch (BuildException be) {
            throw be;
        } finally {
            this.cleanup();
        }
    }

    /**
     * Write files to be used as a parameter for the MergeProp shell script.
     * 
     * @throws BuildException Something went wrong during write.
     * 
     */
    private void writeDeltaFile() {
        try {
            PrintWriter bw = new PrintWriter(new FileWriter(tmpFile));
            bw.println("[NameServer." + this.nameServer + "]");
            if (!this.action.equalsIgnoreCase("delete")) {
                bw.println("environment=" + this.name);
                bw.println("autoStart=" + (this.autoStart ? "1" : "0"));
                bw.println("brokerKeepAliveTimeout=" + this.brokerKeepAliveTimeout);
                bw.println("logAppend=" + (this.logAppend ? "1" : "0"));
                if (this.portNumber != -1)
                    bw.println("portNumber=" + this.portNumber);
                if (this.serverLogFile != null)
                    bw.println("srvrLogFile=" + this.serverLogFile);
                if (this.serverLogLevel != -1)
                    bw.println("srvrLoggingLevel=" + this.serverLogLevel);
                if (this.workDir != null)
                    bw.println("workDir=" + this.workDir);

            }
            bw.close();
        } catch (IOException ioe) {
            throw new BuildException("Unable to create temp file");
        }
    }

    /**
     * Creates an Exec task, calling mergeprop shell script.
     */
    private Task getCmdLineMergeTask(File propFile, File deltaFile) {
        ExecTask task = (ExecTask) getProject().createTask("exec");
        task.setOwningTarget(this.getOwningTarget());
        task.setTaskName(this.getTaskName());
        task.setDescription(this.getDescription());
        task.setDir(this.getProject().getBaseDir());
        task.setExecutable(this.getExecPath("mergeprop").getAbsolutePath());
        task.setFailonerror(true);

        Environment.Variable var4 = new Environment.Variable();
        var4.setKey("DLC"); //$NON-NLS-1$
        var4.setValue(this.getDlcHome().toString());
        task.addEnv(var4);

        task.createArg().setValue("-type");
        task.createArg().setValue("ubroker");
        task.createArg().setValue("-action");
        task.createArg().setValue(this.action);
        task.createArg().setValue("-target");
        task.createArg().setValue(propFile.getAbsolutePath());
        task.createArg().setValue("-delta");
        task.createArg().setValue(deltaFile.getAbsolutePath());

        return task;
    }

    /**
     * Cross-attributes check
     * 
     * @throws BuildException Attributes are wrong...
     */
    private void checkAttributes() throws BuildException {
        if ((!action.equalsIgnoreCase(UPDATE)) && (!action.equalsIgnoreCase(CREATE))
                && (!action.equalsIgnoreCase(DELETE))) {
            throw new BuildException("Unknown action : " + action);
        }

        if ((serverLogLevel != -1) && ((serverLogLevel < 1) || (serverLogLevel > 5)))
            throw new BuildException("Log level should be between 1 and 5");

        if (this.name == null) {
            throw new BuildException("Name attribute is missing");
        }
        if (this.action == null) {
            throw new BuildException("Action attribute is missing");
        }
    }

    private void cleanup() {
        if (this.tmpFile.exists() && !this.tmpFile.delete()) {
            log(
                    MessageFormat
                            .format(
                                    Messages.getString("PCTASBroker.1"), new Object[]{this.tmpFile.getAbsolutePath()}), Project.MSG_VERBOSE); //$NON-NLS-1$
        }
    }

}