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
 * Dumps data from database
 *
 * @author <a href="mailto:d.knol@steeg-software.nl">Ing. D.G. Knol</a>
 */
public class PCTDumpData extends PCTRun {
    private File destDir = null;
    private String tables = null;
    private String encoding = null;

    /**
     * Output directory for dump
     * @param destDir directory
     */
    public void setDestDir(File destDir) {
        this.destDir = destDir;
    }

    /**
     * Tables list to dump
     * @param tables the tables to dump
     */
    public void setTables(String tables) {
        this.tables = tables;
    }

    /**
     * Set encoding to be used to dump data. If not set or empty,
     * dump will be done using -cpstream default value.
     */
    public void setEncoding(String encoding) {
        this.encoding = encoding;
    }

    /**
     * Do the work
     * @throws BuildException Something went wrong
     */
    @Override
    public void execute() {
        if (runAttributes.getAllDbConnections().isEmpty()) {
            cleanup();
            throw new BuildException(Messages.getString("PCTDumpData.0")); //$NON-NLS-1$
        }

        if (runAttributes.getAllDbConnections().size() > 1) {
            cleanup();
            throw new BuildException(Messages.getString("PCTDumpData.1")); //$NON-NLS-1$
        }

        if (destDir == null) {
            cleanup();
            throw new BuildException(Messages.getString("PCTDumpData.2")); //$NON-NLS-1$
        }

        addParameter(new RunParameter("destDir", destDir.toString())); //$NON-NLS-1$
        addParameter(new RunParameter("tables", tables == null ? "ALL" : tables)); //$NON-NLS-1$ $NON-NLS-2$
        addParameter(new RunParameter("encoding", encoding == null ? "" : encoding)); //$NON-NLS-1$ $NON-NLS-2$
        setProcedure("pct/pctDumpData.p"); //$NON-NLS-1$

        super.execute();
    }
}
