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
import org.apache.tools.ant.taskdefs.ExecTask;
import org.apache.tools.ant.types.FileSet;

import java.io.File;

import java.util.Enumeration;
import java.util.Vector;


/**
 * Class for managing Progress library files
 * @author <a href="mailto:gilles.querret@nerim.net">Gilles QUERRET</a>
 */
public class PCTLibrary extends PCT {
    private File destFile = null;
    private String encoding = null;
    private boolean noCompress = false;
    private Vector filesets = new Vector();

    /**
     * Adds a set of files to archive.
     * @param set FileSet
     */
    public void addFileset(FileSet set) {
        filesets.addElement(set);
    }

    /**
     * Library file name to create/update
     * @param destFile File
     */
    public void setDestFile(File destFile) {
        this.destFile = destFile;
    }

    /**
     * Codepage to use
     * @param encoding String
     */
    public void setEncoding(String encoding) {
        this.encoding = encoding;
    }

    /**
     * Compress library at the end of the process
     * @param noCompress boolean
     */
    public void setNoCompress(boolean noCompress) {
        this.noCompress = noCompress;
    }

    /**
     * Do the work
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        ExecTask exec = null;

        // Library name must be defined
        if (this.destFile == null) {
            throw new BuildException("Library name not defined");
        }

        // Creates new library
        exec = createArchiveTask();
        exec.execute();

        // Parses filesets
        for (Enumeration e = filesets.elements(); e.hasMoreElements();) {
            FileSet fs = (FileSet) e.nextElement();
            File f = null;
            String[] dsfiles = fs.getDirectoryScanner(this.getProject()).getIncludedFiles();

            for (int i = 0; i < dsfiles.length; i++) {
                f = new File(fs.getDir(this.getProject()), dsfiles[i]);
                if (f.lastModified() > this.destFile.lastModified()) {
                    exec = addFileTask(dsfiles[i], fs.getDir(this.getProject()));
                    exec.execute();
                }
            }
        }

        if (!this.noCompress) {
            exec = compressTask();
            exec.execute();
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

    private ExecTask addFileTask(String f, File dir) {
        ExecTask exec = (ExecTask) getProject().createTask("exec");

        exec.setOwningTarget(this.getOwningTarget());
        exec.setTaskName(this.getTaskName());
        exec.setDescription(this.getDescription());

        exec.setExecutable(getExecPath("prolib").toString());
        exec.setDir(dir);
        exec.createArg().setValue(this.destFile.getAbsolutePath());
        exec.createArg().setValue("-replace");
        exec.createArg().setValue(f);
        exec.createArg().setValue("-nowarn");

        return exec;
    }

    private ExecTask compressTask() {
        ExecTask exec = (ExecTask) getProject().createTask("exec");

        exec.setOwningTarget(this.getOwningTarget());
        exec.setTaskName(this.getTaskName());
        exec.setDescription(this.getDescription());

        exec.setExecutable(getExecPath("prolib").toString());
        exec.createArg().setValue(this.destFile.getAbsolutePath());
        exec.createArg().setValue("-compress");
        exec.createArg().setValue("-nowarn");

        return exec;
    }
}
