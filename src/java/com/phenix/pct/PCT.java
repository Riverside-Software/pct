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
import org.apache.tools.ant.Project;
import org.apache.tools.ant.taskdefs.Execute;
import org.apache.tools.ant.taskdefs.LogStreamHandler;
import org.apache.tools.ant.taskdefs.MatchingTask;
import org.apache.tools.ant.types.Commandline;

import java.io.File;


/**
  * Base class for creating tasks involving Progress
  * The class uses the 'Execute' task as it operates by executing various commands
  * supplied with Progress. By default the task expects Progress bin directory to be in the path,
  * you can override this by specifying the dlcHome attribute.
  **/
public abstract class PCT extends MatchingTask {
    private File dlcHome = null;
    private File baseDir = null;

    /**
     * Progress installation directory
     * @param dlcHome File
     */
    public final void setDlcHome(File dlcHome) {
        this.dlcHome = dlcHome;
    }

    /**
     * Base directory where to execute command lines
     * @param baseDir File
     */
    public final void setBaseDir(File baseDir) {
        this.baseDir = baseDir;
    }

    /**
     * Returns base directory
     */
    protected final File getBaseDir() {
        if (this.baseDir == null) {
            return this.getProject().getBaseDir();
        } else {
            return this.baseDir;
        }
    }

    /**
     * Returns Progress installation directory
     */
    protected final File getDlcHome() {
        return this.dlcHome;
    }

    /**
     * Returns a Progress executable path
     */
    protected String getExecPath(String exec) {
        if (this.dlcHome == null) {
            return exec;
        } else {
            return (this.dlcHome.toString() + File.separatorChar + "bin" +
            File.separatorChar + exec);
        }
    }

    /**
     * Runs a command line
     */
    protected int run(Commandline cmd) throws BuildException {
        return run(cmd, this.getBaseDir());
    }

    /**
     * Runs a command line in a specified directory
     */
    protected int run(Commandline cmd, File dir) throws BuildException {
        if (!dir.exists()) {
            throw new BuildException("Directory " + dir.toString() +
                " doesn't exist");
        }

        if (cmd == null) {
            throw new BuildException("Command line not defined");
        }

        try {
            Execute exe = new Execute(new LogStreamHandler(this,
                        Project.MSG_INFO, Project.MSG_WARN));
            exe.setWorkingDirectory(dir);
            log("Executing : " + cmd.toString() + " in directory " +
                dir.toString(), Project.MSG_VERBOSE);
            exe.setCommandline(cmd.getCommandline());

            return exe.execute();
        } catch (java.io.IOException e) {
            throw new BuildException(e, location);
        }
    }
}
