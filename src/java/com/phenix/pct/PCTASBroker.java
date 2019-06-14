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
import java.rmi.server.UID;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.ExecTask;
import org.apache.tools.ant.types.Environment;

/**
 * Class managing appservers tasks
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class PCTASBroker extends PCTBroker {
    private static final String STATELESS = "Stateless";
    private static final String STATE_AWARE = "State-aware";
    private static final String STATE_RESET = "State-reset";
    private static final String STATE_FREE = "State-free";
    private static final String DEFAULT_NS = "NS1";

    private String operatingMode = STATELESS;
    private String nameServer = DEFAULT_NS;
    private boolean autoStart = false;
    private File workDir = null;
    private File brokerLogFile = null;
    private boolean brokerLogFileAppend = true;
    private File serverLogFile = null;
    private boolean serverLogFileAppend = true;
    private int portNumber = -1;
    private int brokerLogLevel = -1;
    private int serverLogLevel = -1;
    private int initialPool = -1;
    private int minPool = -1;
    private int maxPool = -1;
    private ServerProcess server = null;

    private int tmpFileID = -1;
    private File tmpFile = null;

    /**
     * Creates a new PCTASBroker object. Temp files initialization.
     */
    public PCTASBroker() {
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
     * Broker log file property. No default value.
     * 
     * @param brokerLogFile File
     */
    public void setBrokerLogFile(File brokerLogFile) {
        this.brokerLogFile = brokerLogFile;
    }

    /**
     * Broker logging level. No default value. Should be between 1 and 5.
     * 
     * @param brokerLogLevel int
     */
    public void setBrokerLogLevel(int brokerLogLevel) {
        this.brokerLogLevel = brokerLogLevel;
    }

    /**
     * Broker log file append. Default value is true.
     * 
     * @param append Boolean
     */
    public void setBrokerLogFileAppend(boolean append) {
        this.brokerLogFileAppend = append;
    }

    /**
     * Initial number of servers to start.
     * 
     * @param initialPool int
     */
    public void setInitialPool(int initialPool) {
        this.initialPool = initialPool;
    }

    /**
     * Maximum number of servers.
     * 
     * @param maxPool int
     */
    public void setMaxPool(int maxPool) {
        this.maxPool = maxPool;
    }

    /**
     * Minimum number of servers.
     * 
     * @param minPool int
     */
    public void setMinPool(int minPool) {
        this.minPool = minPool;
    }

    /**
     * Operating mode. Should be stateless, state-reset, state-aware or state-free
     * 
     * @param operatingMode String
     */
    public void setOperatingMode(String operatingMode) {
        this.operatingMode = operatingMode;
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
     * Server log file append. Default value is true.
     * 
     * @param append Boolean
     */
    public void setServerLogFileAppend(boolean append) {
        this.serverLogFileAppend = append;
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
     * Server settings
     * 
     * @param sp ServerProcess (customized version of PCTRun)
     */
    public void addConfiguredServer(ServerProcess sp) {
        if (this.server == null) {
            this.server = sp;
        } else {
            throw new BuildException("Only one server process...");
        }
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
            checkAttributes();
            // Choosing right properties file
            if (file == null) {
                propFile = new File(getDlcHome(), "properties/" + UBROKER_PROPERTIES);
            } else {
                propFile = getProject().resolveFile(file);
            }
            if (!propFile.exists())
                throw new BuildException("Unable to find properties file "
                        + propFile.getAbsolutePath());
            // And do the work
            writeDeltaFile();
            Task task = getCmdLineMergeTask(propFile, tmpFile);
            task.execute();
        } finally {
            cleanup();
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
            bw.println("[UBroker.AS." + name + "]");
            if (!"delete".equalsIgnoreCase(action)) {
                bw.println("appserviceNameList=" + name);
                bw.println("registerNameServer=1");
                bw.println("controllingNameServer=" + nameServer);
                bw.println("registrationMode=Register-IP");
                bw.println("operatingMode=" + operatingMode);
                bw.println("autoStart=" + (autoStart ? "1" : "0"));
                if (server != null) {
                    if (!"".equals(server.getPropath())) {
                        bw.print("PROPATH=");
                        bw.println(server.getPropath());
                    }

                    // No quotes in this attribute
                    bw.print("srvrStartupParam=");
                    for (String str : server.getCmdLineParameters()) {
                        bw.print(str);
                        bw.print(' ');
                    }

                    bw.println("");
                }

                if (portNumber != -1)
                    bw.println("portNumber=" + portNumber);
                if (brokerLogFile != null)
                    bw.println("brokerLogFile=" + brokerLogFile);
                if (brokerLogLevel != -1)
                    bw.println("brkrLoggingLevel=" + brokerLogLevel);
                bw.println("brkrLogAppend=" + (brokerLogFileAppend ? "1" : "0"));
                if (serverLogFile != null)
                    bw.println("srvrLogFile=" + serverLogFile);
                if (serverLogLevel != -1)
                    bw.println("srvrLoggingLevel=" + serverLogLevel);
                bw.println("srvrLogAppend=" + (serverLogFileAppend ? "1" : "0"));
                if (workDir != null)
                    bw.println("workDir=" + workDir);
                if (initialPool != -1)
                    bw.println("initialSrvrInstance=" + initialPool);
                if (minPool != -1)
                    bw.println("minSrvrInstance=" + minPool);
                if (maxPool != -1)
                    bw.println("maxSrvrInstance=" + maxPool);
                if ((server != null) && (server.getActivateProc() != null)) {
                    bw.println("srvrActivateProc=" + server.getActivateProc());
                }
                if ((server != null) && (server.getDeactivateProc() != null)) {
                    bw.println("srvrDeactivateProc=" + server.getDeactivateProc());
                }
                if ((server != null) && (server.getConnectProc() != null)) {
                    bw.println("srvrConnectProc=" + server.getConnectProc());
                }
                if ((server != null) && (server.getDisconnectProc() != null)) {
                    bw.println("srvrDisconnProc=" + server.getDisconnectProc());
                }
                if ((server != null) && (server.getStartupProc() != null)) {
                    bw.println("srvrStartupProc=" + server.getStartupProc());
                }
                if ((server != null) && (server.getShutdownProc() != null)) {
                    bw.println("srvrShutdownProc=" + server.getShutdownProc());
                }
                if ("auto".equalsIgnoreCase(uid)) {
                    bw.println("uuid=" + new UID().toString());
                } else if (!"none".equalsIgnoreCase(uid)) {
                    bw.println("uuid=" + uid);
                }
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
        task.setDir(getProject().getBaseDir());
        task.setExecutable(getExecPath("mergeprop").getAbsolutePath());
        task.setFailonerror(true);

        Environment.Variable var1 = new Environment.Variable();
        var1.setKey("DLC"); //$NON-NLS-1$
        var1.setValue(getDlcHome().toString());
        task.addEnv(var1);
        Environment.Variable var2 = new Environment.Variable();
        var2.setKey("JAVA_HOME"); //$NON-NLS-1$
        var2.setValue(getJDK().getAbsolutePath());
        task.addEnv(var2);
        Environment.Variable var3 = new Environment.Variable();
        var3.setKey("JREHOME"); //$NON-NLS-1$
        var3.setValue(getJRE().getAbsolutePath());
        task.addEnv(var3);

        task.createArg().setValue("-type");
        task.createArg().setValue("ubroker");
        task.createArg().setValue("-action");
        task.createArg().setValue(action);
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
        if (action == null) {
            throw new BuildException("Action attribute is missing");
        }
        if ((!UPDATE.equalsIgnoreCase(action)) && (!CREATE.equalsIgnoreCase(action))
                && (!DELETE.equalsIgnoreCase(action))) {
            throw new BuildException("Unknown action : " + action);
        }
        if ((brokerLogLevel != -1) && ((brokerLogLevel < 1) || (brokerLogLevel > 5))) {
            throw new BuildException("Log level should be between 1 and 5");
        }
        if ((serverLogLevel != -1) && ((serverLogLevel < 1) || (brokerLogLevel > 5)))
            throw new BuildException("Log level should be between 1 and 5");

        if (name == null) {
            throw new BuildException("Name attribute is missing");
        }
        if (name.trim().length() == 0) {
            throw new BuildException("Name attribute is empty");
        }
        // TODO Operating mode is case-sensitive, so we should always replace value with the correct one
        if ((!operatingMode.equals(STATELESS)) && (!operatingMode.equals(STATE_AWARE))
                && (!operatingMode.equals(STATE_RESET)) && (!operatingMode.equals(STATE_FREE)))
            throw new BuildException(
                    "Invalid operating mode (warning : operatingMode attribute is case sensitive)");

    }

    private void cleanup() {
        deleteFile(tmpFile);
    }

}
