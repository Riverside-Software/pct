/**
 * Copyright 2005-2026 Riverside Software
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

import java.io.File;
import java.io.IOException;

import org.apache.tools.ant.BuildException;

/**
 * Generates a JSON file with the description of all .Net types available in the OpenEdge session. Generation is
 * delegated to PCTTools.dll (https://github.com/clement-brodu/PCTTools).
 */
public class AssemblyCatalog extends PCTRun {
    private static final String PCTTOOLS_RESOURCE = "/assemblycatalog/PCTTools.dll";

    private File destFile = null;
    private File pctTools = null;

    // Internal use
    private File workDir = null;

    public AssemblyCatalog() {
        super();
        workDir = new File(System.getProperty(PCT.TMPDIR), "asmcat" + PCT.nextRandomInt());
    }

    /**
     * Assembly catalog output file
     *
     * @param destFile File
     */
    public void setDestFile(File destFile) {
        this.destFile = destFile;
    }

    /**
     * Use another version of PCTTools.dll instead of the one bundled in PCT
     *
     * @param pctTools File
     */
    public void setPctTools(File pctTools) {
        this.pctTools = pctTools;
    }

    @Override
    public void execute() {
        if (destFile == null) {
            cleanup();
            throw new BuildException(Messages.getString("PCTCRC.0")); //$NON-NLS-1$
        }
        if ((pctTools != null) && !pctTools.isFile()) {
            cleanup();
            throw new BuildException("Unable to find PCTTools library " + pctTools.getAbsolutePath());
        }

        File dll = pctTools;
        if (dll == null) {
            try {
                dll = extractPCTTools();
            } catch (IOException caught) {
                cleanup();
                throw new BuildException("Unable to extract PCTTools library", caught);
            }
        }

        setProcedure("pct/v12/assemblyCatalog.p"); //$NON-NLS-1$
        addParameter(new RunParameter("destFile", destFile.getAbsolutePath())); //$NON-NLS-1$
        addParameter(new RunParameter("pctTools", dll.getAbsolutePath())); //$NON-NLS-1$

        super.execute();
    }

    private File extractPCTTools() throws IOException {
        if (!createDir(workDir))
            throw new IOException("Unable to create directory " + workDir.getAbsolutePath());
        if (PCT.class.getResource(PCTTOOLS_RESOURCE) == null)
            throw new IOException("Resource " + PCTTOOLS_RESOURCE + " not found in PCT.jar");
        File dll = new File(workDir, "PCTTools.dll");
        copyStreamFromJar(PCTTOOLS_RESOURCE, dll);
        return dll;
    }

    @Override
    protected void cleanup() {
        super.cleanup();

        if (getDebugPCT())
            return;
        deleteDirectory(workDir);
    }
}
