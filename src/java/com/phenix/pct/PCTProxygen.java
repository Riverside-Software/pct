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
import org.apache.tools.ant.Project;
import org.apache.tools.ant.taskdefs.Java;
import org.apache.tools.ant.taskdefs.condition.Os;
import org.apache.tools.ant.types.Commandline;
import org.apache.tools.ant.types.Environment;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.text.MessageFormat;

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

    // Internal use
    private int logID = -1;
    protected File logFile = null;

    public PCTProxygen() {
        logID = PCT.nextRandomInt();
        logFile = new File(System.getProperty("java.io.tmpdir"), "pxg" + logID + ".out"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
    }

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

        pxg.setFailonerror(true);
        // Catch output in order to parse it
        pxg.setOutput(logFile);
        pxg.setLogError(false);

        boolean fail = false;
        File pxgLogFile = null; // Generated by proxygen itself
        try {
            pxg.execute();
        } catch (BuildException caught) {
            fail = true;
        }

        // Parse output of proxygen task
        BufferedReader reader = null;
        try {
            reader = new BufferedReader(new FileReader(logFile));
            String str = null;
            while ((str = reader.readLine()) != null) {
                if (str.contains("Warnings")) {
                    log(str, Project.MSG_WARN);
                } else if (str.contains("Failed")) {
                    log(str, Project.MSG_ERR);
                    fail = true;
                } else {
                    log(str, Project.MSG_INFO);
                }
                if ((pxgLogFile == null) && (str.startsWith("For details see the log file"))) {
                    pxgLogFile = new File(str.substring(29).trim());
                }
            }
        } catch (IOException caught) {
            cleanup();
            throw new BuildException("Unable to parse output", caught);
        } finally {
            if (reader != null) {
                try {
                    reader.close();
                } catch (IOException uncaught) {
                }
            }
        }
        cleanup();

        // Parse log file of proxygen itself, if file is available
        if (pxgLogFile.exists()) {
            try {
                reader = new BufferedReader(new FileReader(pxgLogFile));
                String str = null;
                while ((str = reader.readLine()) != null) {
                    if (str.trim().startsWith(">>WARN")) {
                        log(str.trim(), Project.MSG_WARN);
                    } else if (str.trim().startsWith(">>ERR")) {
                        log(str.trim(), Project.MSG_ERR);
                    } 
                }
            } catch (IOException caught) {
                cleanup();
                throw new BuildException("Unable to parse log file", caught);
            } finally {
                if (reader != null) {
                    try {
                        reader.close();
                    } catch (IOException uncaught) {
                    }
                }
            }
        } else {
            log("Unable to read log file : " + pxgLogFile.getAbsolutePath(), Project.MSG_WARN);
        }

        if (fail) {
            throw new BuildException("Proxy generation failed");
        }
    }

    protected void cleanup() {
        if ((logFile != null) && logFile.exists() && !logFile.delete()) {
            log(MessageFormat.format(Messages.getString("PCTRun.5"), logFile.getAbsolutePath()), Project.MSG_INFO); //$NON-NLS-1$
        }
    }
}
