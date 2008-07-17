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
import java.rmi.server.UID;
import java.text.MessageFormat;
import java.util.Iterator;
import java.util.Random;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.ExecTask;
import org.apache.tools.ant.types.Environment;

/**
 * Class managing appservers tasks
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET </a>
 * @version $Revision$
 */
public class PCTWSBroker extends PCTBroker {
    private final static String DEFAULT_NS = "NS1";

    private String nameServer = DEFAULT_NS;
    private String appURL = null;
    private String cookiePath = null;
    private String cookieDomain = null;
    private File uploadDir = null;
    private boolean autoStart = false;
    private File workDir = null;
    private File brokerLogFile = null;
    private File serverLogFile = null;
    private int portNumber = -1;
    private int brokerLogLevel = -1;
    private int serverLogLevel = -1;
    private int initialPool = -1;
    private int minPool = -1;
    private int maxPool = -1;
    private int binUploadMaxSize = -1;
    private int debugMode = 2; // 2 = Default -- 0 = inactive -- 1 = active
    private boolean srvAppMode = false; // FALSE = development mode -- TRUE = production mode
    private WSServerProcess server = null;

    private int tmpFileID = -1;
    private File tmpFile = null;

    /**
     * Creates a new PCTASBroker object. Temp files initialization.
     */
    public PCTWSBroker() {
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
     * Server settings
     * 
     * @param sp ServerProcess (customized version of PCTRun)
     */
    public void addConfiguredServer(WSServerProcess sp) {
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
            // Unwanted side effect of using PCTRun in server attribute, empty temporary files need
            // to be cleaned
            if (this.server != null)
                this.server.cleanup();
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
            bw.println("[UBroker.WS." + this.name + "]");
            if (!this.action.equalsIgnoreCase("delete")) {
                bw.println("appserviceNameList=" + this.name);
                bw.println("registerNameServer=1");
                bw.println("controllingNameServer=" + this.nameServer);
                bw.println("registrationMode=Register-IP");
                bw.println("autoStart=" + (this.autoStart ? "1" : "0"));
                // TODO Erm, this is crap... I should use something else to handle correctly quotes
                // in command line
                if (this.server != null) {
                    bw.print("PROPATH=");
                    bw.println(this.server.getPropath());

                    bw.print("srvrStartupParam=");
                    for (Iterator i = this.server.getCmdLineParameters().iterator(); i.hasNext();) {
                        bw.print((String) i.next());
                        bw.print(' ');
                    }
                    bw.println("");
                }
                if (this.portNumber != -1)
                    bw.println("portNumber=" + this.portNumber);
                if (this.brokerLogFile != null)
                    bw.println("brokerLogFile=" + this.brokerLogFile);
                if (this.brokerLogLevel != -1)
                    bw.println("brkrLoggingLevel=" + this.brokerLogLevel);
                if (this.serverLogFile != null)
                    bw.println("srvrLogFile=" + this.serverLogFile);
                if (this.serverLogLevel != -1)
                    bw.println("srvrLoggingLevel=" + this.serverLogLevel);
                if (this.workDir != null)
                    bw.println("workDir=" + this.workDir);
                if (this.initialPool != -1)
                    bw.println("initialSrvrInstance=" + this.initialPool);
                if (this.minPool != -1)
                    bw.println("minSrvrInstance=" + this.minPool);
                if (this.maxPool != -1)
                    bw.println("maxSrvrInstance=" + this.maxPool);
                if (this.appURL != null)
                    bw.println("applicationURL=" + this.appURL);
                if (this.binUploadMaxSize != -1)
                    bw.println("binaryUploadMaxSize=" + this.binUploadMaxSize);
                if (this.cookiePath != null)
                    bw.println("defaultCookiePath=" + this.cookiePath);
                if (this.cookieDomain != null)
                    bw.println("defaultCookieDomain=" + this.cookieDomain);
                if (this.uploadDir != null)
                    bw.println("fileUploadDirectory=" + this.uploadDir);
                if (this.debugMode == 1)
                    bw.println("srvrDebug=Disabled");
                else if (this.debugMode == 2)
                    bw.println("srvrDebug=Enabled");
                else if (this.debugMode == 0)
                    bw.println("srvrDebug=Default");
                if (this.srvAppMode)
                    bw.println("srvrAppMode=Production");
                else
                    bw.println("srvrAppMode=Development");
                if (this.UID.equalsIgnoreCase("auto")) {
                    bw.println("uuid=" + new UID().toString());
                } else if (!this.UID.equalsIgnoreCase("none")) {
                    bw.println("uuid=" + this.UID);
                }
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
        if ((brokerLogLevel != -1) && ((brokerLogLevel < 1) || (brokerLogLevel > 5))) {
            throw new BuildException("Log level should be between 1 and 5");
        }
        if ((serverLogLevel != -1) && ((serverLogLevel < 1) || (brokerLogLevel > 5)))
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

    public String getAppURL() {
        return appURL;
    }

    public void setAppURL(String appURL) {
        this.appURL = appURL;
    }

    public int getBinUploadMaxSize() {
        return binUploadMaxSize;
    }

    public void setBinUploadMaxSize(int binUploadMaxSize) {
        this.binUploadMaxSize = binUploadMaxSize;
    }

    public String getCookieDomain() {
        return cookieDomain;
    }

    public void setCookieDomain(String cookieDomain) {
        this.cookieDomain = cookieDomain;
    }

    public String getCookiePath() {
        return cookiePath;
    }

    public void setCookiePath(String cookiePath) {
        this.cookiePath = cookiePath;
    }

    public int getDebugMode() {
        return debugMode;
    }

    public void setDebugMode(int debugMode) {
        this.debugMode = debugMode;
    }

    public File getUploadDir() {
        return uploadDir;
    }

    public void setUploadDir(File uploadDir) {
        this.uploadDir = uploadDir;
    }

    public boolean isSrvAppMode() {
        return srvAppMode;
    }

    public void setSrvAppMode(boolean srvAppMode) {
        this.srvAppMode = srvAppMode;
    }

}
