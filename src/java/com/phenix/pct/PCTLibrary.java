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
import org.apache.tools.ant.types.FileSet;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import java.util.Enumeration;
import java.util.Vector;

/**
 * Class for managing Progress library files
 * 
 * @author <a href="mailto:gilles.querret@nerim.net">Gilles QUERRET </a>
 */
public class PCTLibrary extends PCT {
    private File tmpFile = null;
    private File destFile = null;
    private String encoding = null;
    private boolean noCompress = false;
    private FileSet fileset = new FileSet();
    private Vector filesets = new Vector();
    private File baseDir = null;

    /**
     * Default constructor
     *  
     */
    public PCTLibrary() {
        super();

        try {
            tmpFile = File.createTempFile("PCTLib", ".txt");
        } catch (IOException ioe) {
            throw new BuildException("Unable to create temp files");
        }
    }

    /**
     * Adds a set of files to archive.
     * 
     * @param set FileSet
     */
    public void addFileset(FileSet set) {
        filesets.addElement(set);
    }

    /**
     * Library file name to create/update
     * 
     * @param destFile File
     */
    public void setDestFile(File destFile) {
        this.destFile = destFile;
    }

    /**
     * Codepage to use
     * 
     * @param encoding String
     */
    public void setEncoding(String encoding) {
        this.encoding = encoding;
    }

    /**
     * Compress library at the end of the process
     * 
     * @param noCompress boolean
     */
    public void setNoCompress(boolean noCompress) {
        this.noCompress = noCompress;
    }

    /**
     * Directory from which to archive files; optional.
     * 
     * @param baseDir File
     */
    public void setBasedir(File baseDir) {
        this.baseDir = baseDir;
        this.fileset.setDir(baseDir);
    }

    /**
     * Sets the set of include patterns. Patterns may be separated by a comma
     * or a space.
     *
     * @param includes the string containing the include patterns
     */
    public void setIncludes(String includes) {
        fileset.setIncludes(includes);
    }

    /**
     * Sets the set of exclude patterns. Patterns may be separated by a comma
     * or a space.
     *
     * @param excludes the string containing the exclude patterns
     */
    public void setExcludes(String excludes) {
        fileset.setExcludes(excludes);
    }

    /**
     * Sets the name of the file containing the includes patterns.
     *
     * @param includesfile A string containing the filename to fetch
     * the include patterns from.
     */
    public void setIncludesfile(File includesfile) {
        fileset.setIncludesfile(includesfile);
    }

    /**
     * Sets the name of the file containing the includes patterns.
     *
     * @param excludesfile A string containing the filename to fetch
     * the include patterns from.
     */
    public void setExcludesfile(File excludesfile) {
        fileset.setExcludesfile(excludesfile);
    }

    /**
     * Sets whether default exclusions should be used or not.
     *
     * @param useDefaultExcludes "true"|"on"|"yes" when default exclusions
     *                           should be used, "false"|"off"|"no" when they
     *                           shouldn't be used.
     */
    public void setDefaultexcludes(boolean useDefaultExcludes) {
        fileset.setDefaultexcludes(useDefaultExcludes);
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        ExecTask exec = null;

        // Library name must be defined
        if (this.destFile == null) {
            this.cleanup();
            throw new BuildException("Library name not defined");
        }
        
        // There must be at least one fileset
        if ((this.baseDir == null) && (this.filesets.size() == 0)) {
            throw new BuildException("basedir attribute must be set, "
                    + "or at least "
                    + "one fileset must be given!");
        }

        try {
            // Creates new library
            exec = createArchiveTask();
            exec.execute();
            // Parse fileset from task
            if (this.baseDir != null) {
                exec = addFilesTask(this.baseDir);
                writeFileList(this.fileset);
                exec.execute();
            }
            // Parses filesets
            for (Enumeration e = filesets.elements(); e.hasMoreElements();) {
                FileSet fs = (FileSet) e.nextElement();
                exec = addFilesTask(fs.getDir(this.getProject()));
                writeFileList(fs);
                exec.execute();
            }
            this.cleanup();
            // Compress library if noCompress set to false
            if (!this.noCompress) {
                exec = compressTask();
                exec.execute();
            }
        } catch (BuildException be) {
            this.cleanup();
            throw be;
        }
    }

    private ExecTask createArchiveTask() {
        ExecTask exec = (ExecTask) getProject().createTask("exec");

        exec.setOwningTarget(this.getOwningTarget());
        exec.setTaskName(this.getTaskName());
        exec.setDescription(this.getDescription());

        exec.setExecutable(getExecPath("prolib").toString());
        exec.createArg().setValue(this.destFile.getAbsolutePath());
        exec.createArg().setValue("-create");

        if (this.encoding != null) {
            exec.createArg().setValue("-codepage");
            exec.createArg().setValue(this.encoding);
        }

        exec.createArg().setValue("-nowarn");

        return exec;
    }

    private ExecTask addFilesTask(File dir) {
        ExecTask exec = (ExecTask) getProject().createTask("exec");

        exec.setOwningTarget(this.getOwningTarget());
        exec.setTaskName(this.getTaskName());
        exec.setDescription(this.getDescription());
        exec.setDir(dir);

        exec.setExecutable(getExecPath("prolib").toString());
        exec.createArg().setValue(this.destFile.getAbsolutePath().toString());
        exec.createArg().setValue("-pf");
        exec.createArg().setValue(this.tmpFile.getAbsolutePath().toString());

        return exec;
    }

    private ExecTask compressTask() {
        ExecTask exec = (ExecTask) getProject().createTask("exec");
        
        exec.setOwningTarget(this.getOwningTarget());
        exec.setTaskName(this.getTaskName());
        exec.setDescription(this.getDescription());

        exec.setExecutable(getExecPath("prolib").toString());
        exec.createArg().setValue(this.destFile.getAbsolutePath().toString());
        exec.createArg().setValue("-compress");

        return exec;
    }
    /**
     * 
     * @throws BuildException
     */
    private void writeFileList(FileSet fs) throws BuildException {
        try {
            BufferedWriter bw = new BufferedWriter(new FileWriter(tmpFile));
            bw.write("-replace ");

            // And get files from fileset
            String[] dsfiles = fs.getDirectoryScanner(this.getProject()).getIncludedFiles();

            for (int i = 0; i < dsfiles.length; i++) {
                File resourceAsFile = new File(fs.getDir(this.getProject()), dsfiles[i]);
                if (resourceAsFile.equals(this.destFile)) {
                    bw.close();
                    throw new BuildException("A .pl file cannot include itself");
                }
                bw.write(dsfiles[i] + " ");
            }
            bw.write("-nowarn ");

            bw.close();
        } catch (IOException ioe) {
            throw new BuildException("Unable to write file list to add to library");
        }
    }

    /**
     * Delete temporary files if debug not activated
     * 
     */
    protected void cleanup() {
        if (this.tmpFile.exists() && !this.tmpFile.delete()) {
            log("Failed to delete " + this.tmpFile.getAbsolutePath(), Project.MSG_VERBOSE);
        }
    }

}