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
import org.apache.tools.ant.DirectoryScanner;
import org.apache.tools.ant.types.Commandline;
import org.apache.tools.ant.types.FileSet;
import org.apache.tools.ant.types.Path;

import java.io.File;

//import java.util.Enumeration;
import java.util.Vector;


/**
  * Class for managing Progress library files
  */
public class PCTLibrary extends PCT {
    private File destFile = null;
    private String encoding = null;
    private boolean noCompress = false;
    private Vector filesets = new Vector();

    /**
     * Adds a set of files to archive.
     */
    public void addFileset(FileSet set) {
        filesets.addElement(set);
    }

    /**
     * Library file name to create/update
     */
    public void setDestFile(File destFile) {
        this.destFile = destFile;
    }

    /**
     * Codepage to use
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
     * Append all files found by a directory scanner to a vector.
     */
    private void appendFiles(Vector files, DirectoryScanner ds) {
        String[] dsfiles = ds.getIncludedFiles();

        for (int i = 0; i < dsfiles.length; i++) {
            files.addElement(dsfiles[i]);
        }
    }

    /**
     * Get the complete list of files to be included in the cab.  Filenames
     * are gathered from filesets if any have been added, otherwise from the
     * traditional include parameters.
     */
    private Vector getFileList() throws BuildException {
        Vector files = new Vector();

        if (filesets.size() == 0) {
            // get files from old methods - includes and nested include
            appendFiles(files, super.getDirectoryScanner(this.getBaseDir()));
        } else {
            // get files from filesets
            for (int i = 0; i < filesets.size(); i++) {
                FileSet fs = (FileSet) filesets.elementAt(i);

                if (fs != null) {
                    appendFiles(files, fs.getDirectoryScanner(this.getProject()));
                }
            }
        }

        return files;
    }

    public void execute() throws BuildException {
        Commandline cmdLine = null;
        int result = 0;

        // Library name must be defined
        if (this.destFile == null) {
            throw new BuildException("Library name not defined");
        }

        cmdLine = createLib();
        result = run(cmdLine);

        if (result != 0) {
            String msg = "Failed creating new library: " + cmdLine.toString() +
                " - Return code : " + result;
            throw new BuildException(msg, location);
        }

        Vector files = getFileList();

        for (int i = 0; i < files.size(); i++) {
            cmdLine = addFile(files.elementAt(i).toString());
            result = run(cmdLine);

            if (result != 0) {
                String msg = "Failed adding file: " + cmdLine.toString() +
                    " - Return code : " + result;
                throw new BuildException(msg, location);
            }
        }

        if (!this.noCompress) {
            cmdLine = compressLib();
            result = run(cmdLine);

            if (result != 0) {
                String msg = "Failed compressing library: " +
                    cmdLine.toString() + " - Return code : " + result;
                throw new BuildException(msg, location);
            }
        }
    }

    private Commandline createLib() {
        Commandline commandLine = new Commandline();
        commandLine.setExecutable(getExecPath("prolib"));
        commandLine.createArgument().setValue(this.destFile.toString());
        commandLine.createArgument().setValue("-create");

        if (this.encoding != null) {
            commandLine.createArgument().setValue("-codepage");
            commandLine.createArgument().setValue(this.encoding);
        }

        commandLine.createArgument().setValue("-nowarn");

        return commandLine;
    }

    private Commandline addFile(String f) {
        Commandline commandLine = new Commandline();
        commandLine.setExecutable(getExecPath("prolib"));

        commandLine.createArgument().setValue(this.destFile.toString());
        commandLine.createArgument().setValue("-replace");
        commandLine.createArgument().setValue(f);
        commandLine.createArgument().setValue("-nowarn");

        return commandLine;
    }

    private Commandline compressLib() {
        Commandline commandLine = new Commandline();
        commandLine.setExecutable(getExecPath("prolib"));
        commandLine.createArgument().setValue(this.destFile.toString());
        commandLine.createArgument().setValue("-compress");
        commandLine.createArgument().setValue("-nowarn");

        return commandLine;
    }
}
