/*
 * Copyright  2000-2004 The Apache Software Foundation
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
