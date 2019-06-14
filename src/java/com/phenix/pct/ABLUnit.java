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

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.StringWriter;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;

import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.types.FileSet;
import org.apache.tools.ant.types.Resource;
import org.apache.tools.ant.types.resources.FileResource;
import org.xml.sax.InputSource;

import com.google.gson.stream.JsonWriter;

/**
 * Ant task for ABLUnit tests
 * 
 * @author <a href="mailto:b.thoral@riverside-software.fr">Bastien THORAL</a>
 */
public class ABLUnit extends PCTRun {
    private final XPath xpath = XPathFactory.newInstance().newXPath();

    private Collection<FileSet> testFilesets;
    private File destDir;
    private String format = "xml";
    private String[] testCase;
    private boolean writeLog;
    private boolean haltOnFailure;

    // Internal use
    private int jsonID = -1;
    private File json = null;

    public ABLUnit() {
        super();

        jsonID = PCT.nextRandomInt();
        json = new File(System.getProperty(PCT.TMPDIR), "ablunit" + jsonID + ".out"); 
    }

    /**
     * Set the path of the results file.
     */
    public void setDestDir(File destDir) {
        this.destDir = destDir;
    }

    /**
     * Stop the build process if a test fails (errors are considered failures as well).
     * 
     * @param haltOnFailure Boolean
     */
    public void setHaltOnFailure(boolean haltOnFailure) {
        this.haltOnFailure = haltOnFailure;
    }

    /**
     * Log attribute.
     */
    public void setWriteLog(boolean writelog) {
        this.writeLog = writelog;
    }

    /**
     * Select case(s).
     */
    public void setTestCase(String testCase) {
        this.testCase = testCase.split(",");
    }

    /**
     * Adds a set of files to test
     * 
     * @param set FileSet
     */
    public void addConfiguredFileset(FileSet set) {
        if (this.testFilesets == null) {
            testFilesets = new ArrayList<>();
        }
        testFilesets.add(set);
    }

    private void writeJsonConfigFile() throws IOException {
        StringWriter strWriter = new StringWriter();
        try (JsonWriter writer = new JsonWriter(strWriter)) {
            log("JSON file created : " + json, Project.MSG_VERBOSE);

            writer.beginObject();

            // Options
            writer.name("options").beginObject();
            writer.name("writeLog").value(writeLog);

            if (destDir != null) {
                log("Adding location'" + destDir + "' to JSon.", Project.MSG_VERBOSE);
                writer.name("output").beginObject();
                writer.name("location").value(destDir.getAbsolutePath());
                writer.name("format").value(format);
                writer.endObject();
            }

            // End "Options" object
            writer.endObject();

            // Tests
            writer.name("tests").beginArray();
            for (FileSet fs : testFilesets) {
                for (String file : fs.getDirectoryScanner(getProject()).getIncludedFiles()) {
                    File f = new File(fs.getDir(), file);
                    log("Adding '" + f + "' to JSon.", Project.MSG_VERBOSE);
                    writer.beginObject().name("test").value(f.toString());
                    // If we want to execute a specific test
                    // XXX Support only one case for now, but keep possibility to have multiple cases. Why ?
                    if (testCase != null) {
                        writer.name("cases").beginArray();
                        for (String cs : testCase) {
                            writer.value(cs);
                        }
                        writer.endArray();
                    }
                    writer.endObject();
                }
            }
            writer.endArray();

            // Root object
            writer.endObject();
        }

        try (FileWriter writer = new FileWriter(json)) {
            writer.write(strWriter.toString());
        }
    }

    @Override
    public void execute() {
        // Validation
        if (destDir != null && !destDir.isDirectory())
            throw new BuildException("Invalid destDir (" + destDir + ")");

        if (testFilesets == null || testFilesets.isEmpty()) {
            cleanup();
            throw new BuildException("No fileset found.");
        }
        // Display warning message if test directories are not found in PROPATH
        // Only first entry is tested as all entries have the same basedir in FileSet object
        for (FileSet fs : testFilesets) {
            Iterator<Resource> iter = fs.iterator();
            if (iter.hasNext()) {
                FileResource frs = (FileResource) iter.next();
                if (!isDirInPropath(frs.getBaseDir())) {
                    log(MessageFormat.format(Messages.getString("PCTCompile.48"),
                            frs.getBaseDir().getAbsolutePath()), Project.MSG_WARN);
                }
            }
        }

        try {
            writeJsonConfigFile();
        } catch (IOException e) {
            cleanup();
            throw new BuildException(e);
        }

        // Linux bug in OpenEdge.ABLUnit.Runner.TestConfig
        // DestDir has to be set to null, as backslash is used to generate file name
        if (destDir == null)
            destDir = getProject().getBaseDir();

        // Setting PCTRun parameters
        setProcedure("ABLUnitCore.p");
        setParameter("CFG=" + json.getAbsolutePath());
        setNoErrorOnQuit(true);

        // Run PCTRun
        super.execute();

        File results = new File(destDir, "results." + format);
        if (!results.exists())
            throw new BuildException(results.getAbsolutePath() + " not found");

        try {
            InputSource inputSource = new InputSource(results.getAbsolutePath());
            int numTests = Integer.parseInt(xpath.evaluate("/testsuites/@tests", inputSource));
            int numFailures = Integer
                    .parseInt(xpath.evaluate("/testsuites/@failures", inputSource));
            int numErrors = Integer.parseInt(xpath.evaluate("/testsuites/@errors", inputSource));

            log(MessageFormat.format(Messages.getString("ABLUnit.1"), numTests, numFailures, numErrors));

            if (haltOnFailure && (numFailures + numErrors > 0))
                throw new BuildException("Error or failure during tests");
        } catch (XPathExpressionException caught) {
            throw new BuildException("Unable to parse results file", caught);
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
        deleteFile(json);
    }
}
