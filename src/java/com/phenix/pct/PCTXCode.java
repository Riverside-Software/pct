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
import org.apache.tools.ant.types.FileSet;

import java.io.File;
import java.io.IOException;

import java.util.Enumeration;
import java.util.Iterator;

import java.util.Vector;


/**
 * Procedure encryption task using xcode utility from Progress
 *
 * @author <a href="mailto:d.knol@steeg-software.nl">Dick Knol</a>
 */
public class PCTXCode extends PCT {
    private Vector filesets = new Vector();
    private String key = null;
    private File destDir = null;
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

        try {
            this.tmpLog = File.createTempFile("pct_outp", ".log");
        } catch (IOException ioe) {
            throw new BuildException("Unable to create temp files");
        }
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
        filesets.addElement(set);
    }

    /**
     * Creates destination directories, according to source directory tree
     *
     * @throws BuildException Something went wrong
     */
    private void createDirectories() throws BuildException {
        for (Enumeration e = filesets.elements(); e.hasMoreElements();) {
            FileSet fs = (FileSet) e.nextElement();

            String[] dsfiles = fs.getDirectoryScanner(this.getProject()).getIncludedFiles();

            for (int i = 0; i < dsfiles.length; i++) {
                String s = dsfiles[i].replace('\\', '/');
                int j = s.lastIndexOf('/');

                if (j != -1) {
                    File f2 = new File(this.destDir, s.substring(0, j));

                    if (!f2.exists()) {
                        if (!f2.mkdirs()) {
                            throw new BuildException("Unable to create directory : " +
                                                     f2.getAbsolutePath());
                        }
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
        if (this.destDir == null) {
            this.cleanup();
            throw new BuildException("destDir not defined");
        }

        log("PCTXCode - Progress Encryption Tool", Project.MSG_INFO);

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

                    if (!trgFile.exists() || this.overwrite ||
                          (srcFile.lastModified() > trgFile.lastModified())) {
                        log("Encryption of " + trgFile.toString(), Project.MSG_VERBOSE);
                        arg.setValue(dsfiles[i]);
                        exec.execute();
                    }
                }
            }
            this.cleanup();
        }
        catch (BuildException be) {
            this.cleanup();
            throw be;
        }
        
    }

    private void createExecTask() {
        exec = (ExecTask) getProject().createTask("exec");
        exec.setOwningTarget(this.getOwningTarget());
        exec.setTaskName(this.getTaskName());
        exec.setDescription(this.getDescription());
        exec.setOutput(tmpLog);
        exec.setExecutable(this.getExecPath("xcode").toString());

        if (this.key != null) {
            exec.createArg().setValue("-k");
            exec.createArg().setValue(this.key);
        }

        exec.createArg().setValue("-d");
        exec.createArg().setValue(this.destDir.toString());

        if (this.lowercase) {
            exec.createArg().setValue("-l");
        }

        arg = exec.createArg();
    }
    
    protected void cleanup() {
        if (this.tmpLog.exists() && !this.tmpLog.delete()) {
            log("Failed to delete " + this.tmpLog.getAbsolutePath(), Project.MSG_VERBOSE);
        }
    }
}
