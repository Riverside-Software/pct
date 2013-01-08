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
import org.apache.tools.ant.types.FileSet;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import java.util.ArrayList;
import java.util.List;

/**
 * Converts Webspeed HTML files to .w or .i
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET </a>
 */
public class PCTWSComp extends PCTRun {
    private List<FileSet> filesets = new ArrayList<FileSet>();
    private boolean debug = false;
    private boolean webObject = true;
    private boolean keepMetaContentType = false;
    private boolean failOnError = false;
    private boolean forceCompile = false;
    private File destDir = null;

    // Internal use
    private int fsListId = -1;
    private File fsList = null;
    private int paramsId = -1;
    private File params = null;
    
    public PCTWSComp() {
        super();

        fsListId = PCT.nextRandomInt();
        paramsId = PCT.nextRandomInt();

        fsList = new File(System.getProperty("java.io.tmpdir"), "pct_filesets" + fsListId + ".txt"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        params = new File(System.getProperty("java.io.tmpdir"), "pct_params" + paramsId + ".txt"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
    }

    /**
     * Force compilation, even if file is not modified
     * 
     * @param forceCompile "true|false|on|off|yes|no"
     */
    public void setForceCompile(boolean forceCompile) {
        this.forceCompile = forceCompile;
    }

    /**
     * Immediatly quit if a webspeed file fails to compile
     * 
     * @param failOnError "true|false|on|off|yes|no"
     */
    public void setFailOnError(boolean failOnError) {
        this.failOnError = failOnError;
    }

    /**
     * Sets debug flag on in e4gl-gen.p
     * 
     * @param debug true|false|yes|no|on|off
     */
    public void setDebug(boolean debug) {
        this.debug = debug;
    }

    /**
     * Sets web-object flag on in e4gl-gen.p
     * 
     * @param webObject true|false|yes|no|on|off
     */
    public void setWebObject(boolean webObject) {
        this.webObject = webObject;
    }

    /**
     * Sets keep-meta-content-type flag on in e4gl-gen.p
     * 
     * @param keepMetaContentType true|false|yes|no|on|off
     */
    public void setKeepMetaContentType(boolean keepMetaContentType) {
        this.keepMetaContentType = keepMetaContentType;
    }

    /**
     * Location to store the .w files
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
        filesets.add(set);
    }

    /**
     * 
     * @throws BuildException
     */
    private void writeFileList() throws BuildException {
        try {
            BufferedWriter bw = new BufferedWriter(new FileWriter(fsList));

            for (FileSet fs : filesets) {
                bw.write("FILESET=" + fs.getDir(this.getProject()).getAbsolutePath()); //$NON-NLS-1$
                bw.newLine();

                for (String str : fs.getDirectoryScanner(this.getProject()).getIncludedFiles()) {
                    bw.write(str);
                    bw.newLine();
                }
            }

            bw.close();
        } catch (IOException ioe) {
            throw new BuildException(Messages.getString("PCTWSComp.6")); //$NON-NLS-1$
        }
    }

    /**
     * 
     * @throws BuildException
     */
    private void writeParams() throws BuildException {
        try {
            BufferedWriter bw = new BufferedWriter(new FileWriter(params));
            bw.write("FILESETS=" + fsList.getAbsolutePath()); //$NON-NLS-1$
            bw.newLine();
            bw.write("OUTPUTDIR=" + destDir.getAbsolutePath()); //$NON-NLS-1$
            bw.newLine();
            bw.write("FORCECOMPILE=" + (this.forceCompile ? "1" : "0")); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
            bw.newLine();
            bw.write("FAILONERROR=" + (this.failOnError ? "1" : "0")); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
            bw.newLine();
            bw.write("DEBUG=" + (this.debug ? "1" : "0")); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
            bw.newLine();
            bw.write("WEBOBJECT=" + (this.webObject ? "1" : "0")); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
            bw.newLine();
            bw.write("KEEPMCT=" + (this.keepMetaContentType ? "1" : "0")); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
            bw.newLine();
            bw.close();
        } catch (IOException ioe) {
            throw new BuildException(Messages.getString("PCTWSComp.24")); //$NON-NLS-1$
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
            throw new BuildException(Messages.getString("PCTWSComp.25")); //$NON-NLS-1$
        }

        // Test output directory
        if (this.destDir.exists()) {
            if (!this.destDir.isDirectory()) {
                this.cleanup();
                throw new BuildException(Messages.getString("PCTWSComp.26")); //$NON-NLS-1$
            }
        } else {
            if (!this.destDir.mkdir()) {
                this.cleanup();
                throw new BuildException(Messages.getString("PCTWSComp.27")); //$NON-NLS-1$
            }
        }

        log(Messages.getString("PCTWSComp.28"), Project.MSG_INFO); //$NON-NLS-1$

        try {
            writeFileList();
            writeParams();
            this.setProcedure("pct/pctWSComp.p"); //$NON-NLS-1$
            this.setParameter(params.getAbsolutePath());
            super.execute();
            this.cleanup();
        } catch (BuildException be) {
            this.cleanup();
            throw be;
        }
    }

    /**
     * Delete temporary files if debug not activated
     * 
     * @see PCTRun#cleanup
     */
    protected void cleanup() {
        super.cleanup();

        if (!this.getDebugPCT()) {
            if (this.fsList.exists() && !this.fsList.delete()) {
                log(Messages.getString("PCTWSComp.30") + this.fsList.getAbsolutePath(), Project.MSG_VERBOSE); //$NON-NLS-1$
            }

            if (this.params.exists() && !this.params.delete()) {
                log(Messages.getString("PCTWSComp.30") + this.params.getAbsolutePath(), Project.MSG_VERBOSE); //$NON-NLS-1$
            }
        }
    }

}