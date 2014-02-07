package com.phenix.pct;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Collection;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.types.FileSet;

import com.google.gson.stream.JsonWriter;
import com.phenix.pct.PCTRun;

/**
 * Ant task for ABLunit tests. For more details about ABLUnit, see the progress documentation.
 * ABLUnit is available for versions greater than 11.4.
 * 
 * @author <a href="mailto:b.thoral@riverside-software.fr">Bastien THORAL</a>
 */
public class ABLUnit extends PCTRun {
    private Collection<BatchTestParameter> testList = null;
    private Collection<FileSet> testFilesets = null;
    private boolean voidFlag = true;
    private String JSONFILENAME = "PCTests" + PCT.nextRandomInt() + ".json";
    private File json = null;

    // We get the batchtests list
    public void addConfiguredBatchTest(BatchTestParameter batchtest) {
        if (this.testList == null) {
            testList = new ArrayList<BatchTestParameter>();
        }
        testList.add(batchtest);
    }

    /**
     * Adds a set of files to load
     * 
     * @param set FileSet
     */
    public void addConfiguredFileset(FileSet set) {
        if (this.testFilesets == null) {
            testFilesets = new ArrayList<FileSet>();
        }
        testFilesets.add(set);
    }

    public ABLUnit() {
        super();
    }

    private void writeJson(String value, JsonWriter writer) throws IOException {
        writer.beginObject().name("test").value(value);
        writer.endObject();
        // At least one test was written
        voidFlag = false;
    }

    public void execute() throws BuildException {
        JsonWriter writer = null;

        if (testList == null && testFilesets == null)
            throw new BuildException(
                    "Task 'ABLUnit' requires one 'batchtest' node or a valid fileset.");

        json = new File(System.getProperty("java.io.tmpdir"), JSONFILENAME);

        try {
            log("Creating json file : " + json, Project.MSG_VERBOSE);
            writer = new JsonWriter(new FileWriter(json));
            writer.beginObject().name("tests");
            writer.beginArray();
            if (testList != null && !testList.isEmpty()) {
                // Check batchtest element
                for (BatchTestParameter rn : testList) {
                    String value = rn.getName();
                    if (!value.isEmpty()) {
                        log("Batchtest : " + value, Project.MSG_VERBOSE);
                        if (value.endsWith(".p") || value.endsWith(".cls")) {
                            log("Adding '" + value + "' to JSon.", Project.MSG_VERBOSE);
                            /*
                             * if (rn.getTest() != null) value += value + "#" + rn.getTest();
                             */
                            writeJson(value, writer);
                        } else
                            log("Ignore invalid name: " + value, Project.MSG_INFO);
                    } else
                        log("We expect a 'name' attribut.", Project.MSG_ERR);
                }
            }
            if (testFilesets != null && !testFilesets.isEmpty()) {
                // Check fileset element
                for (FileSet fs : testFilesets) {
                    for (String file : fs.getDirectoryScanner(getProject()).getIncludedFiles()) {
                        if (file.endsWith(".p") || file.endsWith(".cls")) {
                            File f = new File(fs.getDir(), file);
                            log("Adding '" + f + "' to JSon.", Project.MSG_VERBOSE);
                            writeJson(f.toString(), writer);
                        }
                    }
                }
            }
            if (voidFlag)
                throw new BuildException("Nothing to test !");
        } catch (IOException e) {
            throw new BuildException(e);
        } finally {
            try {
                writer.endArray();
                writer.endObject();
                writer.close();
            } catch (IOException e) {
                throw new BuildException(e);
            }
        }

        setProcedure("ABLUnitCore.p");
        setParameter("CFG=" + json);
        // QUIT expected in 'ABLUnitCore.p'
        setNoErrorOnQuit(true);
        // Run PCTRun
        super.execute();

        // Check result file to detect potential error on the ABL side
        File buildPath = getProject().getBaseDir();

        File results = new File(buildPath, "results.xml");
        if (!results.exists())
            throw new BuildException("No results.xml file (" + buildPath
                    + ") ! It must be an error in a ABL Procedure/Classe.");
    }
    /**
     * Delete temporary files if debug not activated
     * 
     * @see PCTRun#cleanup
     */
    protected void cleanup() {
        super.cleanup();
        // Clean JSON File
        if (!getDebugPCT()) {
            if (json.exists() && !json.delete()) {
                log(MessageFormat.format(
                        Messages.getString("PCTCompile.42"), json.getAbsolutePath()), Project.MSG_INFO); //$NON-NLS-1$
            }
        }
    }
}
