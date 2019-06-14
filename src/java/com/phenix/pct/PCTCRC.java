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
 * Generates a file containing CRC for each table (multiple databases allowed)
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 * @version $Revision$
 * @deprecated Since PCT 0.9 -- Use PCTBgCRC instead
 */
public class PCTCRC extends PCTRun {
    private File destFile = null;

    /**
     * Output file for CRCs
     * 
     * @param destFile File
     */
    public void setDestFile(File destFile) {
        this.destFile = destFile;
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    @Override
    public void execute() {
        if (this.destFile == null) {
            this.cleanup();
            throw new BuildException(Messages.getString("PCTCRC.0")); //$NON-NLS-1$
        }

        if (runAttributes.getAllDbConnections().isEmpty()) {
            this.cleanup();
            throw new BuildException(Messages.getString("PCTCRC.1")); //$NON-NLS-1$
        }

        this.setProcedure("pct/pctCRCExport.p"); //$NON-NLS-1$
        this.setParameter(destFile.toString());
        super.execute();
    }
}
