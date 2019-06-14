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

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.Collection;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.types.FileSet;

/**
 * Ant task for OEUnit tests. For more details about OEUnit, see
 * https://github.com/CameronWills/OEUnit.
 * 
 * @author <a href="mailto:b.thoral@riverside-software.fr">Bastien THORAL</a>
 */
public class OEUnit extends PCTRun {

    private File destDir;
    private Collection<FileSet> testFilesets = null;
    private File testFilesList;
    private String format = "JUnit";

    private String testFileName = "PCTestList" + PCT.nextRandomInt() + ".txt";

    public OEUnit() {
        super();
    }

    /**
     * Set the path of the results file.
     */
    public void setDestDir(File destDir) {
        this.destDir = destDir;
    }

    /**
     * Set the format of the results file.
     * 
     * @param format (JUnit,SureFire,CSV,Text)
     */
    public void setFormat(String format) {
        this.format = format;
    }

    /**
     * Adds a set of files to load
     * 
     * @param set FileSet
     */
    public void addConfiguredFileset(FileSet set) {
        if (this.testFilesets == null) {
            testFilesets = new ArrayList<>();
        }
        testFilesets.add(set);
    }

    @Override
    public void execute() {
        // Validation
        if (testFilesets == null)
            throw new BuildException("You must set a fileset (testFilesets).");

        if (destDir != null && !destDir.isDirectory())
            throw new BuildException("Invalid destDir (" + destDir + ")");

        if (destDir == null)
            destDir = getProject().getBaseDir();

        // Create a temp file which list test class to be executed
        testFilesList = new File(System.getProperty(PCT.TMPDIR), testFileName);
        try (FileOutputStream fos = new FileOutputStream(testFilesList);
                OutputStreamWriter writer = new OutputStreamWriter(fos, getCharset());
                BufferedWriter bw = new BufferedWriter(writer)) {
            for (FileSet fs : testFilesets) {
                for (String file : fs.getDirectoryScanner(getProject()).getIncludedFiles()) {
                    File f = new File(fs.getDir(), file);
                    log("Adding '" + f + "' to list.", Project.MSG_VERBOSE);
                    // Add a line like this :
                    // MyClassName=C:\Path\To\Class\MyClassName.cls
                    bw.write(f.getName().substring(0, f.getName().lastIndexOf('.')) + "=" + f.getAbsolutePath());
                    bw.newLine();
                }
            }
        } catch (Exception e) {
            throw new BuildException(e);
        }

        // Setting PCTRun parameters
        setProcedure("pct/pctOEUnitRunner.p");
        setParameter(testFilesList + "," + destDir + "," + format.toUpperCase());

        // Run PCTRun
        super.execute();
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
        deleteFile(testFilesList);
    }
}
