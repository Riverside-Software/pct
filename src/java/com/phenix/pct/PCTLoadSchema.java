/**
 * Copyright 2005-2017 Riverside Software
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
import org.apache.tools.ant.types.Resource;
import org.apache.tools.ant.types.ResourceCollection;
import org.apache.tools.ant.types.resources.FileResource;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * Loads schema into database
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTLoadSchema extends PCTRun {
    private File srcFile = null;
    private List<ResourceCollection> rcs = new ArrayList<>();
    private boolean unfreeze = false;
    private boolean commitWhenErrors = false;
    private boolean onlineChanges = false;
    private boolean inactiveIndexes = false;
    private String callbackClass = "", analyzerClass = "";

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

    public void add(ResourceCollection rc) {
        rcs.add(rc);
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
     * Callback class
     * 
     * @param callbackClass
     */
    public void setCallbackClass(String callbackClass) {
        this.callbackClass = callbackClass;
    }

    public void setAnalyzerClass(String analyzerClass) {
        this.analyzerClass = analyzerClass;
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

    public void setInactiveIndexes(boolean inactive) {
        this.inactiveIndexes = inactive;
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        if (runAttributes.getAllDbConnections().size() == 0) {
            cleanup();
            throw new BuildException(Messages.getString("PCTLoadSchema.0")); //$NON-NLS-1$
        }

        if ((srcFile == null) && (rcs.size() == 0)) {
            cleanup();
            throw new BuildException(Messages.getString("PCTLoadSchema.2")); //$NON-NLS-1$
        }

        if ((srcFile != null) && (rcs.size() > 0)) {
            cleanup();
            throw new BuildException(Messages.getString("PCTLoadSchema.5")); //$NON-NLS-1$
        }

        if ((srcFile != null) && (!srcFile.exists())) {
            cleanup();
            throw new BuildException(MessageFormat.format(
                    Messages.getString("PCTLoadSchema.4"), this.srcFile)); //$NON-NLS-1$
        }

        // Verify resource collections
        for (ResourceCollection rc : rcs) {
            if (!rc.isFilesystemOnly()) {
                cleanup();
                throw new BuildException("PCTLoadSchema only accepts file-system resources collections");
            }
        }

        checkDlcHome();

        try {
            writeFileList();
            setProcedure(getProgressProcedures().getLoadSchemaProcedure());
            addParameter(new RunParameter("fileList", fsList.getAbsolutePath())); //$NON-NLS-1$
            addParameter(new RunParameter("online", Boolean.toString(onlineChanges))); //$NON-NLS-1$
            addParameter(new RunParameter("unfreeze", Boolean.toString(unfreeze))); //$NON-NLS-1$
            addParameter(new RunParameter("callbackClass", callbackClass)); //$NON-NLS-1$
            addParameter(new RunParameter("analyzerClass", analyzerClass)); //$NON-NLS-1$
            addParameter(new RunParameter("inactiveIdx", Boolean.toString(inactiveIndexes))); //$NON-NLS-1$
            addParameter(new RunParameter(
                    "commitWhenErrors", Boolean.toString(this.commitWhenErrors))); //$NON-NLS-1$
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

            for (ResourceCollection rc : rcs) {
                Iterator<Resource> iter = rc.iterator();
                while (iter.hasNext()) {
                    FileResource frs = (FileResource) iter.next();
                    if (frs.isDirectory()) {
                        log("Skipping " + frs.getName() + " as it is a directory", Project.MSG_INFO);
                    } else {
                        bw.write(frs.getFile().getAbsolutePath());
                        bw.newLine();
                    }
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
