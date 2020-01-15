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
 * Creates database documentation
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTSchemaDoc extends PCTRun {
    private File destFile = null;

    /**
     * Output directory
     * 
     * @param file File
     */
    public void setFile(File file) {
        this.destFile = file;
    }

    /**
     * do the work
     * 
     * @throws BuildException If attributes are not valid
     */
    @Override
    public void execute() {
        if (this.destFile == null) {
            this.cleanup();
            throw new BuildException(Messages.getString("PCTSchemaDoc.0")); //$NON-NLS-1$
        }

        if (runAttributes.getAllDbConnections().isEmpty()) {
            this.cleanup();
            throw new BuildException(Messages.getString("PCTSchemaDoc.1")); //$NON-NLS-1$
        }

        if (runAttributes.getAllDbConnections().size() > 1) {
            this.cleanup();
            throw new BuildException(Messages.getString("PCTSchemaDoc.2")); //$NON-NLS-1$
        }

        this.setProcedure("pct/pctSchemaDoc.p"); //$NON-NLS-1$
        this.setParameter(destFile.getAbsolutePath());
        super.execute();
    }
}
