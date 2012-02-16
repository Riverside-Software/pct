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
import org.apache.tools.ant.taskdefs.condition.Os;
import org.apache.tools.ant.types.Commandline;
import org.apache.tools.ant.types.Environment;

import java.io.File;

/**
 * Proxygen task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTProxygen extends PCT {
    // Class used by Proxygen
    private static final String PROXYGEN_CLASS = "com.progress.open4gl.proxygen.Batch";

    private File srcFile = null;
    private boolean keepFiles = false;
    private File workingDirectory = null;

    private Java pxg = null;

    /**
     * Keep files
     * 
     * @param keepFiles boolean
     */
    public void setKeepFiles(boolean keepFiles) {
        this.keepFiles = keepFiles;
    }

    /**
     * Working directory
     * 
     * @param workingDir File
     */
    public void setWorkingDirectory(File workingDir) {
        if (!workingDir.exists()) {
            throw new BuildException(Messages.getString("PCTProxygen.0")); //$NON-NLS-1$
        }

        this.workingDirectory = workingDir;
    }

    /**
     * PXG file to use
     * 
     * @param srcFile File
     */
    public void setSrcFile(File srcFile) {
        this.srcFile = srcFile;
    }

    /**
     * For jvmarg nested elements
     */
    public Commandline.Argument createJvmarg() {
        if (pxg == null) {
            pxg = new Java(this);
        }

        return pxg.getCommandLine().createVmArgument();
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        if (this.srcFile == null) {
            throw new BuildException(Messages.getString("PCTProxygen.1")); //$NON-NLS-1$
        }

        checkDlcHome();

        // Creates a new Java task to launch proxygen task
        if (pxg == null) {
            pxg = new Java(this);
        }

        // The previous behaviour was to fork only when working directory was specified.
        // This caused problems with JUnit testing, as I think there are System.exit statements
        // in proxygen code
        pxg.setFork(true);
        // No included JDK on UNIX
        if (Os.isFamily(Os.FAMILY_WINDOWS))
            pxg.setJvm(getJVM().getAbsolutePath());
        if (this.workingDirectory != null) {
            pxg.setDir(this.workingDirectory);
        } else {
            pxg.setDir(this.getProject().getBaseDir());
        }

        pxg.setClassname(PROXYGEN_CLASS);
        // Bug #1114731 : new way of handling JAR dependencies
        pxg.createClasspath().addFileset(this.getJavaFileset(this.getProject()));

        // As Progress doesn't know command line parameters,
        // arguments are given via environment variables
        Environment.Variable var = new Environment.Variable();
        // Bug #1311746 : mixed case extension are not handled correctly
        // So, at first extract extension and then compare ignore case
        int ext_pos = this.srcFile.toString().lastIndexOf('.');
        String extension = (ext_pos == -1 ? "" : this.srcFile.toString().substring(ext_pos));
        if (extension.equalsIgnoreCase(".xpxg")) //$NON-NLS-1$
            var.setKey("XPXGFile"); //$NON-NLS-1$
        else
            var.setKey("PXGFile"); //$NON-NLS-1$

        var.setValue(this.srcFile.toString());
        pxg.addSysproperty(var);

        Environment.Variable var2 = new Environment.Variable();
        var2.setKey("Install.Dir"); //$NON-NLS-1$
        var2.setValue(this.getDlcHome().toString());
        pxg.addSysproperty(var2);

        Environment.Variable var3 = new Environment.Variable();
        var3.setKey("ProxyGen.LeaveProxyFiles"); //$NON-NLS-1$
        var3.setValue((this.keepFiles ? "yes" : "no")); //$NON-NLS-1$ //$NON-NLS-2$
        pxg.addSysproperty(var3);

        Environment.Variable var4 = new Environment.Variable();
        var4.setKey("DLC"); //$NON-NLS-1$
        var4.setValue(this.getDlcHome().toString());
        pxg.addEnv(var4);

        Environment.Variable var6 = new Environment.Variable();
        var6.setKey("Proxygen.StartDir"); //$NON-NLS-1$
        var6.setValue(workingDirectory.getAbsolutePath());
        pxg.addSysproperty(var6);

        // Don't use executeJava and get return code as Progress doesn't know what a return value is
        pxg.setFailonerror(true);
        int retVal = pxg.executeJava();
        if (retVal != 0) {
            throw new BuildException("PCTProxygen failed - Return code " + retVal + " - Command line : " + pxg.getCommandLine().toString());
        }
    }
}
