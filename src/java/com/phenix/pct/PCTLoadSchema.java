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

import java.io.File;
import java.text.MessageFormat;

/**
 * Loads schema into database
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTLoadSchema extends PCTRun {
    private File srcFile = null;
    private boolean unfreeze = false;
    private boolean commitWhenErrors = false;
    private boolean onlineChanges = false;

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
            this.cleanup();
            throw new BuildException(Messages.getString("PCTLoadSchema.0")); //$NON-NLS-1$
        }

        if (getDbConnections().size() > 1) {
            this.cleanup();
            throw new BuildException(Messages.getString("PCTLoadSchema.1")); //$NON-NLS-1$
        }

        if (this.srcFile == null) {
            this.cleanup();
            throw new BuildException(Messages.getString("PCTLoadSchema.2")); //$NON-NLS-1$
        }

        if (!this.srcFile.exists()) {
            this.cleanup();
            throw new BuildException(MessageFormat.format(
                    Messages.getString("PCTLoadSchema.4"), new Object[]{this.srcFile})); //$NON-NLS-1$
        }

        this.setProcedure("pct/loadSch.p"); //$NON-NLS-1$
        this.addParameter(new RunParameter("online", Boolean.toString(onlineChanges))); //$NON-NLS-1$
        this.addParameter(new RunParameter("unfreeze", Boolean.toString(this.unfreeze))); //$NON-NLS-1$
        this.addParameter(new RunParameter("srcFile", srcFile.getAbsolutePath())); //$NON-NLS-1$
        this.addParameter(new RunParameter(
                "commitWhenErrors", Boolean.toString(this.commitWhenErrors))); //$NON-NLS-1$
        log(
                MessageFormat.format(Messages.getString("PCTLoadSchema.3"),
                        new Object[]{this.srcFile}), Project.MSG_INFO);
        super.execute();
    }
}
