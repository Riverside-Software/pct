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
import org.apache.tools.ant.taskdefs.ExecTask;
import org.apache.tools.ant.types.Commandline;
import org.apache.tools.ant.types.Environment;
import org.apache.tools.ant.types.FileSet;

import java.io.File;

import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * Procedure encryption task using xcode utility from Progress
 * 
 * @author <a href="mailto:d.knol@steeg-software.nl">Dick Knol</a>
 */
public class PCTXCode extends PCT {
    private List filesets = new ArrayList();
    private String key = null;
    private File destDir = null;
    private int tmpLogId = -1;
    private File tmpLog = null;
    private boolean overwrite = false;
    private boolean lowercase = false;

    // Internal use
    private ExecTask exec = null;
    private Commandline.Argument arg = null;

    /**
     * Default constructor
     */
    public PCTXCode() {
        super();

        tmpLogId = PCT.nextRandomInt();

        tmpLog = new File(System.getProperty("java.io.tmpdir"), "pct_outp" + tmpLogId + ".log"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
    }

    /**
     * Sets output directory (-d attribute)
     * 
     * @param destDir File
     */
    public void setDestDir(File destDir) {
        this.destDir = destDir;
    }

    /**
     * Sets key to be used for encryption (-k attribute)
     * 
     * @param key String
     */
    public void setKey(String key) {
        this.key = key;
    }

    /**
     * Overwrites files ?
     * 
     * @param overwrite boolean
     */
    public void setOverwrite(boolean overwrite) {
        this.overwrite = overwrite;
    }

    /**
     * Convert filenames to lowercase (-l attribute)
     * 
     * @param lowercase boolean
     */
    public void setLowercase(boolean lowercase) {
        this.lowercase = lowercase;
    }

    /**
     * Adds a set of files to encrypt
     * 
     * @param set FileSet
     */
    public void addFileset(FileSet set) {
        filesets.add(set);
    }

    /**
     * Creates destination directories, according to source directory tree
     * 
     * @throws BuildException Something went wrong
     */
    private void createDirectories() throws BuildException {
        for (Iterator e = filesets.iterator(); e.hasNext();) {
            FileSet fs = (FileSet) e.next();

            String[] dsfiles = fs.getDirectoryScanner(this.getProject()).getIncludedFiles();

            for (int i = 0; i < dsfiles.length; i++) {
                String s = dsfiles[i].replace('\\', '/');
                int j = s.lastIndexOf('/');

                if (j != -1) {
                    File f2 = new File(this.destDir, s.substring(0, j));

                    if (!f2.exists() && !f2.mkdirs()) {
                            throw new BuildException(MessageFormat.format(Messages
                                    .getString("PCTXCode.3"), new Object[]{f2.getAbsolutePath()})); //$NON-NLS-1$
                    }
                }
            }
        }
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        checkDlcHome();
        if (this.destDir == null) {
            this.cleanup();
            throw new BuildException(Messages.getString("PCTXCode.4")); //$NON-NLS-1$
        }

        log(Messages.getString("PCTXCode.5"), Project.MSG_INFO); //$NON-NLS-1$

        try {
            this.createDirectories();
            this.createExecTask();

            for (Iterator e = filesets.iterator(); e.hasNext();) {
                // Parse filesets
                FileSet fs = (FileSet) e.next();
                exec.setDir(fs.getDir(this.getProject()));

                // And get files from fileset
                String[] dsfiles = fs.getDirectoryScanner(this.getProject()).getIncludedFiles();

                for (int i = 0; i < dsfiles.length; i++) {
                    File trgFile = new File(this.destDir, dsfiles[i]);
                    File srcFile = new File(fs.getDir(this.getProject()), dsfiles[i]);

                    if (!trgFile.exists() || this.overwrite
                            || (srcFile.lastModified() > trgFile.lastModified())) {
                        log(
                                MessageFormat
                                        .format(
                                                Messages.getString("PCTXCode.6"), new Object[]{trgFile.toString()}), Project.MSG_VERBOSE); //$NON-NLS-1$
                        arg.setValue(dsfiles[i]);
                        if (this.overwrite) {
                            if (!trgFile.delete()) throw new BuildException(Messages.getString("PCTXCode.7"));
                        }
                        exec.execute();
                    }
                }
            }
            this.cleanup();
        } catch (BuildException be) {
            this.cleanup();
            throw be;
        }

    }

    private void createExecTask() {
        exec = new ExecTask(this);
        exec.setOutput(tmpLog);
        exec.setExecutable(this.getExecPath("xcode").toString()); //$NON-NLS-1$

        Environment.Variable var = new Environment.Variable();
        var.setKey("DLC"); //$NON-NLS-1$
        var.setValue(this.getDlcHome().toString());
        exec.addEnv(var);

        if (this.key != null) {
            exec.createArg().setValue("-k"); //$NON-NLS-1$
            exec.createArg().setValue(this.key);
        }

        exec.createArg().setValue("-d"); //$NON-NLS-1$
        exec.createArg().setValue(this.destDir.toString());

        if (this.lowercase) {
            exec.createArg().setValue("-l"); //$NON-NLS-1$
        }

        arg = exec.createArg();
    }

    protected void cleanup() {
        if (this.tmpLog.exists() && !this.tmpLog.delete()) {
            log(
                    MessageFormat
                            .format(
                                    Messages.getString("PCTXCode.13"), new Object[]{this.tmpLog.getAbsolutePath()}), Project.MSG_VERBOSE); //$NON-NLS-1$
        }
    }
}
