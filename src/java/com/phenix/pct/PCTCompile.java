/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) The Apache Software Foundation.  All rights
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
import org.apache.tools.ant.types.FileSet;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import java.util.Enumeration;
import java.util.Vector;


/**
 * Class for compiling Progress procedures
 *
 * @author <a href="mailto:gilles.querret@nerim.net">Gilles QUERRET</a>
 */
public class PCTCompile extends PCTRun {
    private Vector filesets = new Vector();
    private boolean minSize = false;
    private boolean md5 = true;
    private boolean forceCompile = false;
    private boolean failOnError = false;
    private File destDir = null;
    private File xRefDir = null;

    // Internal use
    private File fsList = null;
    private File params = null;

    /**
     * Creates a new PCTCompile object
     */
    public PCTCompile() {
        super();

        try {
            fsList = File.createTempFile("pct_filesets", ".txt");
            params = File.createTempFile("pct_params", ".txt");
        } catch (IOException ioe) {
            throw new BuildException("Unable to create temp files");
        }
    }

    /**
     * Reduce r-code size ? MIN-SIZE option of the COMPILE statement
     *
     * @param minSize "true|false|on|off|yes|no"
     */
    public void setMinSize(boolean minSize) {
        this.minSize = minSize;
    }

    /**
     * Force compilation, without xref generation
     *
     * @param forceCompile "true|false|on|off|yes|no"
     *
     * @since 0.3b
     */
    public void setForceCompile(boolean forceCompile) {
        this.forceCompile = forceCompile;
    }

    /**
     * Immediatly quit if a progress procedure fails to compile
     *
     * @param failOnError "true|false|on|off|yes|no"
     */
    public void setFailOnError(boolean failOnError) {
        this.failOnError = failOnError;
    }

    /**
     * Don't use XREF (and so compile everything). Removed since 0.5, use forceCompile
     *
     * @param noXref "true|false|on|off|yes|no"
     *
     * @deprecated
     */
    public void setNoXref(boolean noXref) {
        log("noXref is deprecated and will be removed in future releases. Use forceCompile");
        this.forceCompile = noXref;
    }

    /**
     * Directory where to store CRC and includes files : .pct subdirectory is created there
     *
     * @param xrefDir File
     */
    public void setXRefDir(File xrefDir) {
        this.xRefDir = xrefDir;
    }

    /**
     * Put MD5 in r-code ? GENERATE-MD5 option of the COMPILE statement
     *
     * @param md5 "true|false|on|off|yes|no"
     */
    public void setMD5(boolean md5) {
        this.md5 = md5;
    }

    /**
     * Location to store the .r files
     *
     * @param destDir Destination directory
     */
    public void setDestDir(File destDir) {
        this.destDir = destDir;
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
     *
     * @throws BuildException
     */
    private void writeFileList() throws BuildException {
        try {
            BufferedWriter bw = new BufferedWriter(new FileWriter(fsList));

            for (Enumeration e = filesets.elements(); e.hasMoreElements();) {
                // Parse filesets
                FileSet fs = (FileSet) e.nextElement();
                bw.write("FILESET=" + fs.getDir(this.getProject()).getAbsolutePath().toString());
                bw.newLine();

                // And get files from fileset
                String[] dsfiles = fs.getDirectoryScanner(this.getProject()).getIncludedFiles();

                for (int i = 0; i < dsfiles.length; i++) {
                    bw.write(dsfiles[i]);
                    bw.newLine();
                }
            }

            bw.close();
        } catch (IOException ioe) {
            throw new BuildException("Unable to write file list to compile");
        }
    }

    /**
     *
     * @throws BuildException
     */
    private void writeParams() throws BuildException {
        try {
            BufferedWriter bw = new BufferedWriter(new FileWriter(params));
            bw.write("FILESETS=" + fsList.getAbsolutePath());
            bw.newLine();
            bw.write("OUTPUTDIR=" + destDir.getAbsolutePath());
            bw.newLine();
            bw.write("PCTDIR=" + xRefDir.getAbsolutePath());
            bw.newLine();
            bw.write("FORCE=" + (this.forceCompile ? "1" : "0"));
            bw.newLine();
            bw.write("MINSIZE=" + (this.minSize ? "1" : "0"));
            bw.newLine();
            bw.write("MD5=" + (this.md5 ? "1" : "0"));
            bw.newLine();
            bw.write("FORCECOMPILE=" + (this.forceCompile ? "1" : "0"));
            bw.newLine();
            bw.write("FAILONERROR=" + (this.failOnError ? "1" : "0"));
            bw.newLine();
            bw.close();
        } catch (IOException ioe) {
            throw new BuildException("Unable to write file list to compile");
        }
    }

    /**
     * Do the work
     *
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        File xRefDir = null; // Where to store XREF files

        if (this.destDir == null) {
            throw new BuildException("destDir attribute not defined");
        }

        // Test output directory
        if (this.destDir.exists()) {
            if (!this.destDir.isDirectory()) {
                throw new BuildException("destDir is not a directory");
            }
        } else {
            if (!this.destDir.mkdir()) {
                throw new BuildException("Unable to create destDir");
            }
        }

        // Test xRef directory
        if (this.xRefDir == null) {
            this.xRefDir = new File(this.destDir, ".pct");
        }

        if (this.xRefDir.exists()) {
            if (!this.xRefDir.isDirectory()) {
                throw new BuildException("xRefDir is not a directory");
            }
        } else {
            if (!this.xRefDir.mkdir()) {
                throw new BuildException("Unable to create xRefDir");
            }
        }

        log("PCTCompile - Progress Code Compiler", Project.MSG_INFO);

        try {
            writeFileList();
            writeParams();
            this.setProcedure("pct/pctCompile.p");
            this.setParameter(params.getAbsolutePath());
            super.execute();
            if (!this.fsList.delete()) {
                log("Failed to delete " + this.fsList.getAbsolutePath());
            }

            if (!this.params.delete()) {
                log("Failed to delete " + this.params.getAbsolutePath());
            }

        } catch (BuildException be) {
            if (!this.fsList.delete()) {
                log("Failed to delete " + this.fsList.getAbsolutePath());
            }

            if (!this.params.delete()) {
                log("Failed to delete " + this.params.getAbsolutePath());
            }

            throw be;
        }
    }
}
