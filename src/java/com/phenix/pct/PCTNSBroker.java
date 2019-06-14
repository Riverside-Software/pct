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
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.Writer;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.ExecTask;
import org.apache.tools.ant.types.Environment;

/**
 * Class managing name servers tasks
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class PCTNSBroker extends PCTBroker {
    private static final String DEFAULT_NS = "NS1";

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

        tmpFileID = PCT.nextRandomInt();
        tmpFile = new File(System.getProperty(PCT.TMPDIR), "pct_delta" + tmpFileID + ".txt"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
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
    @Override
    public void execute() {
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
        try (Writer w = new FileWriter(tmpFile); PrintWriter bw = new PrintWriter(w)) {
            bw.println("[NameServer." + this.nameServer + "]");
            if (!"delete".equalsIgnoreCase(this.action)) {
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
        } catch (IOException caught) {
            throw new BuildException("Unable to create temp file", caught);
        }
    }

    /**
     * Creates an Exec task, calling mergeprop shell script.
     */
    private Task getCmdLineMergeTask(File propFile, File deltaFile) {
        ExecTask task = new ExecTask(this);
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
    private void checkAttributes() {
        if ((!action.equalsIgnoreCase(UPDATE)) && (!action.equalsIgnoreCase(CREATE))
                && (!action.equalsIgnoreCase(DELETE))) {
            throw new BuildException("Unknown action : " + action);
        }

        if ((serverLogLevel != -1) && ((serverLogLevel < 1) || (serverLogLevel > 5)))
            throw new BuildException("Log level should be between 1 and 5");
    }

    private void cleanup() {
        deleteFile(tmpFile);
    }

}