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
import org.apache.tools.ant.taskdefs.Java;
import org.apache.tools.ant.types.Environment;

import java.io.File;


/**
 * Proxygen task
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
 */
public class PCTProxygen extends PCT {
    private File srcFile = null;
    private boolean keepFiles = false;
    private File workingDirectory = null;

    /**
     * Keep files
     * @param keepFiles boolean
     */
    public void setKeepFiles(boolean keepFiles) {
        this.keepFiles = keepFiles;
    }

    /**
     * Working directory
     * @param workingDir File
     */
    public void setWorkingDirectory(File workingDir) {
        if (!workingDir.exists()) {
            throw new BuildException("work dir pas bon");
        }

        this.workingDirectory = workingDir;
    }

    /**
     * PXG file to use
     * @param srcFile File
     */
    public void setSrcFile(File srcFile) {
        this.srcFile = srcFile;
    }

    /**
     * Do the work
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        if (this.srcFile == null) {
            throw new BuildException("Proxygen file not defined");
        }

        if (this.getDlcHome() == null) {
            throw new BuildException("Progress installation directory not defined");
        }

        // Creates a new Java task to launch proxygen task
        Java pxg = (Java) getProject().createTask("java");

        pxg.setOwningTarget(this.getOwningTarget());
        pxg.setTaskName(this.getTaskName());
        pxg.setDescription(this.getDescription());
        
        if (this.workingDirectory != null) {
            // Bug #1081209 : fork needed to change working directory
            pxg.setFork(true);
            pxg.setDir(this.workingDirectory);
        }

        pxg.setClassname("com.progress.open4gl.proxygen.Batch");

        // Bug #1114731 : new way of handling JAR dependencies
        pxg.createClasspath().addFileset(this.getJavaFileset());
       
        // As Progress doesn't know command line parameters,
        // arguments are given via environment variables
        Environment.Variable var = new Environment.Variable();
        var.setKey("PXGFile");
        var.setValue(this.srcFile.toString());
        pxg.addEnv(var);

        Environment.Variable var2 = new Environment.Variable();
        var2.setKey("Install.Dir");
        var2.setValue(this.getDlcHome().toString());
        pxg.addEnv(var2);

        Environment.Variable var3 = new Environment.Variable();
        var3.setKey("Proxygen.LeaveProxyFiles");
        var3.setValue((this.keepFiles ? "true" : "false"));
        pxg.addEnv(var3);

        Environment.Variable var4 = new Environment.Variable();
        var4.setKey("DLC");
        var4.setValue(this.getDlcHome().toString());
        pxg.addEnv(var4);

        // Don't use executeJava and get return code as Progress doesn't know what a return value is
        pxg.execute();
    }
}
