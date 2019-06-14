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

import java.io.File;

/**
 * Loads users to database
 *
 * @author <a href="mailto:cverbiest@users.sourceforge.net">Carl Verbiest</a>
 */
public class PCTLoadUsers extends PCTRun {
    private File srcFile = null;

    /**
     * Input file
     *
     * @param srcFile File
     */
    public void setSrcFile(File srcFile) {
        this.srcFile = srcFile;
    }

    /**
     * Do the work
     *
     * @throws BuildException Something went wrong
     */
    @Override
    public void execute() {
        if (runAttributes.getAllDbConnections().isEmpty()) {
            this.cleanup();
            throw new BuildException(Messages.getString("PCTDumpSchema.0")); //$NON-NLS-1$
        }

        if (runAttributes.getAllDbConnections().size() > 1) {
            this.cleanup();
            throw new BuildException(Messages.getString("PCTDumpSchema.1")); //$NON-NLS-1$
        }

        if (this.srcFile == null) {
            this.cleanup();
            throw new BuildException(Messages.getString("PCTDumpSchema.2")); //$NON-NLS-1$
        }

        String param = srcFile.toString();

        this.setProcedure(getProgressProcedures().getLoadUsersProcedure());
        this.setParameter(param);
        super.execute();
    }
}
