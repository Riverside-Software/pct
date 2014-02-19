package com.phenix.pct;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.types.FileSet;

import com.google.gson.stream.JsonWriter;
import com.phenix.pct.PCTRun;

/**
 * Ant task for ABLunit tests. For more details about ABLUnit, see the progress documentation.
 * 
 * @author <a href="mailto:b.thoral@riverside-software.fr">Bastien THORAL</a>
 */
public class ABLUnit extends PCTRun {
    private Collection<FileSet> testFilesets = null;
    private String jsonFileName = "PCTests" + PCT.nextRandomInt() + ".json";
    private File json = null;
    private File destDir;
    private String format = "xml";
    final static List<String> GOODFORMAT = Arrays.asList("xml");
    private String[] testCase;
    private boolean writeLog = false;

    /**
     * Set the path of the results file.
     * 
     * @param location
     */
    public void setDestDir(File destDir) {
        this.destDir = destDir;
    }

    /**
     * Set the format of the results file.
     * 
     * @param format
     */
    public void setFormat(String format) {
        this.format = format;
    }

    /**
     * Log attribute.
     * 
     * @param writelog
     */
    public void setWriteLog(boolean writelog) {
        this.writeLog = writelog;
    }

    /**
     * Select case(s).
     * 
     * @param cases
     */
    public void setTestCase(String testCase) {
        this.testCase = testCase.split(",");
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

    public void execute() throws BuildException {
        JsonWriter writer = null;

        // Validation
        if (destDir != null && !destDir.isDirectory())
            throw new BuildException("Invalid destDir (" + destDir + ")");

        if (testFilesets == null || testFilesets.isEmpty())
            throw new BuildException("No fileset found.");

        if (format != null && !GOODFORMAT.contains(format))
            throw new BuildException("Invalid format (" + format + "). Valid formats: "
                    + GOODFORMAT);

        // Creating config file (json)
        try {
            json = new File(System.getProperty("java.io.tmpdir"), jsonFileName);
            writer = new JsonWriter(new FileWriter(json));
            log("Json file created : " + json, Project.MSG_VERBOSE);
            writer.beginObject();

            // Options
            writer.name("options").beginObject();

            if (destDir != null) {
                log("Adding location'" + destDir + "' to JSon.", Project.MSG_VERBOSE);
                writer.name("output").beginObject();
                writer.name("location").value(destDir.toString());
                writer.name("format").value(format);
                writer.endObject();
            }
            // Log
            writer.name("writeLog").value(writeLog);

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
                    // XXX For now only support 1 case but keep possibility to have many
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
        } catch (IOException e) {
            throw new BuildException(e);
        } finally {
            try {
                writer.close();
            } catch (IOException e) {
                throw new BuildException(e);
            }
        }
        // Setting PCTRun parameters
        setProcedure("ABLUnitCore.p");
        setParameter("CFG=" + json);
        // QUIT expected in 'ABLUnitCore.p'
        setNoErrorOnQuit(true);
        // Run PCTRun
        super.execute();
        
        if(destDir==null)
            destDir=getProject().getBaseDir();

        File results = new File(destDir, "results." + format);
        if (!results.exists())
            throw new BuildException("No results file (" + results
                    + ") ! It could be an error in an ABL Procedure/Class.");
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
                log(MessageFormat.format(Messages.getString("PCTCompile.42"),
                        json.getAbsolutePath()), Project.MSG_INFO);
            }
        }
    }
}
