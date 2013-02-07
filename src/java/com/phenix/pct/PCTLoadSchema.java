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
import org.apache.tools.ant.types.FileSet;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Collection;

/**
 * Loads schema into database
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTLoadSchema extends PCTRun {
    private File srcFile = null;
    private Collection<FileSet> filesets = new ArrayList<FileSet>();
    private boolean unfreeze = false;
    private boolean commitWhenErrors = false;
    private boolean onlineChanges = false;

    // Internal use
    private int fsListId = -1;
    private File fsList = null;

    /**
     * Creates a new PCTCompile object
     */
    public PCTLoadSchema() {
        super();

        fsListId = PCT.nextRandomInt();
        fsList = new File(System.getProperty("java.io.tmpdir"), "pct_filesets" + fsListId + ".txt"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
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
     * Dump file
     * 
     * @param srcFile File
     */
    public void setSrcFile(File srcFile) {
        this.srcFile = srcFile;
    }

    /**
     * Unfreeze
     * 
     * @param unfreeze boolean
     */
    public void setUnfreeze(boolean unfreeze) {
        this.unfreeze = unfreeze;
    }

    /**
     * Commit transaction when errors during load
     * 
     * @param commit boolean
     */
    public void setCommitWhenErrors(boolean commit) {
        this.commitWhenErrors = commit;
    }

    public void setOnlineChanges(boolean online) {
        this.onlineChanges = online;
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        if (getDbConnections().size() == 0) {
            cleanup();
            throw new BuildException(Messages.getString("PCTLoadSchema.0")); //$NON-NLS-1$
        }

        if (getDbConnections().size() > 1) {
            cleanup();
            throw new BuildException(Messages.getString("PCTLoadSchema.1")); //$NON-NLS-1$
        }

        if ((srcFile == null) && (filesets.size() == 0)) {
            cleanup();
            throw new BuildException(Messages.getString("PCTLoadSchema.2")); //$NON-NLS-1$
        }

        if ((srcFile != null) && (filesets.size() > 0)) {
            cleanup();
            throw new BuildException(Messages.getString("PCTLoadSchema.5")); //$NON-NLS-1$
        }

        if ((srcFile != null) && (!srcFile.exists())) {
            cleanup();
            throw new BuildException(MessageFormat.format(
                    Messages.getString("PCTLoadSchema.4"), this.srcFile)); //$NON-NLS-1$
        }

        try {
            writeFileList();
            setProcedure("pct/loadSch.p"); //$NON-NLS-1$
            addParameter(new RunParameter("fileList", fsList.getAbsolutePath())); //$NON-NLS-1$
            addParameter(new RunParameter("online", Boolean.toString(onlineChanges))); //$NON-NLS-1$
            addParameter(new RunParameter("unfreeze", Boolean.toString(unfreeze))); //$NON-NLS-1$
            addParameter(new RunParameter(
                    "commitWhenErrors", Boolean.toString(this.commitWhenErrors))); //$NON-NLS-1$
            log(MessageFormat.format(Messages.getString("PCTLoadSchema.3"), srcFile),
                    Project.MSG_INFO);
            super.execute();
        } catch (BuildException caught) {
            cleanup();
            throw caught;
        }
    }

    private void writeFileList() throws BuildException {
        try {
            BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(
                    fsList), getCharset()));

            if (srcFile != null) {
                bw.write(srcFile.getAbsolutePath());
                bw.newLine();
            }

            for (FileSet fs : filesets) {
                for (String str : fs.getDirectoryScanner(this.getProject()).getIncludedFiles()) {
                    bw.write(new File(fs.getDir(), str).getAbsolutePath());
                    bw.newLine();
                }
            }

            bw.close();
        } catch (IOException ioe) {
            throw new BuildException(Messages.getString("PCTCompile.2"), ioe); //$NON-NLS-1$
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
                log(MessageFormat.format(
                        Messages.getString("PCTCompile.42"), this.fsList.getAbsolutePath()), Project.MSG_VERBOSE); //$NON-NLS-1$
            }
        }
    }
}
