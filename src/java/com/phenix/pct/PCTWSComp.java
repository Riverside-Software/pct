/**
 * Copyright 2005-2019 Riverside Software
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
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class PCTWSComp extends PCTRun {
    private List<FileSet> filesets = new ArrayList<>();
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

        fsList = new File(System.getProperty(PCT.TMPDIR), "pct_filesets" + fsListId + ".txt"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        params = new File(System.getProperty(PCT.TMPDIR), "pct_params" + paramsId + ".txt"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
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
    @Override
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
    private void writeFileList() {
        try (FileWriter fw = new FileWriter(fsList); BufferedWriter bw = new BufferedWriter(fw)) {
            for (FileSet fs : filesets) {
                bw.write("FILESET=" + fs.getDir(this.getProject()).getAbsolutePath()); //$NON-NLS-1$
                bw.newLine();

                for (String str : fs.getDirectoryScanner(this.getProject()).getIncludedFiles()) {
                    bw.write(str);
                    bw.newLine();
                }
            }
        } catch (IOException caught) {
            throw new BuildException(Messages.getString("PCTWSComp.6"), caught); //$NON-NLS-1$
        }
    }

    /**
     * 
     * @throws BuildException
     */
    private void writeParams() {
        try (FileWriter fw = new FileWriter(params); BufferedWriter bw = new BufferedWriter(fw)) {
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
        } catch (IOException caught) {
            throw new BuildException(Messages.getString("PCTWSComp.24"), caught); //$NON-NLS-1$
        }
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    @Override
    public void execute() {

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
    @Override
    protected void cleanup() {
        super.cleanup();

        if (getDebugPCT())
            return;
        deleteFile(fsList);
        deleteFile(params);
    }

}