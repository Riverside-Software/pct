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

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.rmi.server.UID;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.ExecTask;
import org.apache.tools.ant.taskdefs.Java;
import org.apache.tools.ant.types.Commandline;
import org.apache.tools.ant.types.Environment;
import org.apache.tools.ant.types.Commandline.Argument;

import com.progress.ubroker.util.PropFilename;

/**
 * Class managing appservers tasks
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET </a>
 * @version $Revision$
 */
public class PCTASBroker extends PCTBroker {
    private final static String STATELESS = "stateless";
    private final static String STATE_AWARE = "state-aware";
    private final static String STATE_RESET = "state-reset";
    private final static String STATE_FREE = "state-free";

    private String operatingMode = STATELESS;
    private String portNumber = null;
    private boolean autoStart = false;
    private File workDir = null;
    private File brokerLogFile = null;
    private File serverLogFile = null;
    private int brokerLogLevel = 1;
    private int serverLogLevel = 1;
    private int initialPool = 1;
    private int minPool = 1;
    private int maxPool = 1;
    private ServerProcess server = null;

    private File tmp = null;
    
    public void setAutoStart(boolean autoStart) {
        this.autoStart = autoStart;
    }

    public void setBrokerLogFile(File brokerLogFile) {
        this.brokerLogFile = brokerLogFile;
    }

    public void setBrokerLogLevel(int brokerLogLevel) {
        this.brokerLogLevel = brokerLogLevel;
    }

    public void setInitialPool(int initialPool) {
        this.initialPool = initialPool;
    }

    public void setMaxPool(int maxPool) {
        this.maxPool = maxPool;
    }

    public void setMinPool(int minPool) {
        this.minPool = minPool;
    }

    public void setOperatingMode(String operatingMode) {
        this.operatingMode = operatingMode;
    }

    public void setPortNumber(String portNumber) {
        this.portNumber = portNumber;
    }

    public void setServerLogFile(File serverLogFile) {
        this.serverLogFile = serverLogFile;
    }

    public void setServerLogLevel(int serverLogLevel) {
        this.serverLogLevel = serverLogLevel;
    }

    public void setWorkDir(File workDir) {
        this.workDir = workDir;
    }

    public void addConfiguredServer(ServerProcess sp) {
        if (this.server == null) {
            // Faire quelques vérifications ici
            this.server = sp;
        } else {
            throw new BuildException("Only one server process...");
        }
    }

    public void execute() throws BuildException {
        File propFile = null;

        // Quelques vérifications de base sur la conformité des attributs

        // Choix du fichier properties
        if (this.file == null) {
            propFile = new File(this.getDlcHome(), "properties/" + UBROKER_PROPERTIES);
        } else {
            propFile = new File(this.file);
        }
        if (!propFile.exists()) {
            throw new BuildException("pas le bon fichier");
        }

        // Traitement spécifique pour delete...
        
        // Pour le add/update
        writeDeltaFile();
        Task task = getCmdLineMergeTask(propFile, tmp);
        task.execute();
    }

    private void writeDeltaFile() {
        try {
            // A remonter à l'initialisation
            tmp = File.createTempFile("pct_delta", ".txt");
            log(tmp.getAbsolutePath(), Project.MSG_INFO);
            PrintWriter bw = new PrintWriter(new FileWriter(tmp));
            bw.println("[UBroker.AS." + this.name + "]");
            bw.println("portNumber=" + this.portNumber);
            bw.println("autoStart=" + (this.autoStart ? "1" : "0"));
            bw.println("brokerLogFile=" + this.brokerLogFile);
            bw.println("brkrLoggingLevel=" + this.brokerLogLevel);
            bw.println("srvrLogFile=" + this.serverLogFile);
            bw.println("srvrLoggingLevel=" + this.serverLogLevel);
            bw.println("operatingMode=" + this.operatingMode);
            bw.println("workDir=" + this.workDir);
            bw.println("initialSrvrInstance=" + this.initialPool);
            bw.println("minSrvrInstance=" + this.minPool);
            bw.println("maxSrvrInstance=" + this.maxPool);
            if (this.server.getActivateProc() != null) {
                bw.println("srvrActivateProc=" + this.server.getActivateProc());
            }
            if (this.server.getDeactivateProc() != null) {
                bw.println("srvrDeactivateProc=" + this.server.getDeactivateProc());
            }
            if (this.server.getConnectProc() != null) {
                bw.println("srvrConnectProc=" + this.server.getConnectProc());
            }
            if (this.server.getDisconnectProc() != null) {
                bw.println("srvrDisconnectProc=" + this.server.getDisconnectProc());
            }
            if (this.server.getStartupProc() != null) {
                bw.println("srvrStartupProc=" + this.server.getStartupProc());
            }
            if (this.server.getShutdownProc() != null) {
                bw.println("srvrShutdownProc=" + this.server.getShutdownProc());
            }
            if (this.UID.equalsIgnoreCase("auto")) {
                bw.println("uuid=" + new UID().toString());
            }
            else if (!this.UID.equalsIgnoreCase("none")) {
                bw.println("uuid=" + this.UID);
            }
            bw.close();
        }
        catch (IOException ioe) {
            throw new BuildException("Unable to create temp file");
        }
    }
    
    private Task getMergeTask() {
        Java task = (Java) getProject().createTask("java");
        task.setOwningTarget(this.getOwningTarget());
        task.setTaskName(this.getTaskName());
        task.setDescription(this.getDescription());
        task.setFork(true);
        task.setDir(this.getProject().getBaseDir());
        task.setClassname(MERGE_CLASS);
        task.createClasspath().addFileset(this.getJavaFileset());
        Environment.Variable var2 = new Environment.Variable();
        var2.setKey("Install.Dir"); //$NON-NLS-1$
        var2.setValue(this.getDlcHome().toString());
        task.addSysproperty(var2);
        Environment.Variable var4 = new Environment.Variable();
        var4.setKey("DLC"); //$NON-NLS-1$
        var4.setValue(this.getDlcHome().toString());
        task.addEnv(var4);

        return task;
    }
    
    private Task getCmdLineMergeTask(File propFile, File deltaFile) {
        ExecTask task = (ExecTask) getProject().createTask("exec");
        task.setOwningTarget(this.getOwningTarget());
        task.setTaskName(this.getTaskName());
        task.setDescription(this.getDescription());
        task.setDir(this.getProject().getBaseDir());
        task.setExecutable(this.getExecPath("mergeprop").getAbsolutePath());
        
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
}
