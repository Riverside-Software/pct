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
 * 
 * @author <a href="mailto:b.thoral@riverside-software.fr">Bastien THORAL</a>
 */
public class ABLUnit extends PCTRun {
    private Collection<FileSet> testFilesets = null;
    private String JSONFILENAME = "PCTests" + PCT.nextRandomInt() + ".json";
    private File json = null;
    private File buildPath;
    private String location;
    private String format = "xml";
    private String[] cases;
    private boolean writeLog = false;
    private boolean quitOnEnd = false;

    /**
     * Set the path of the results file.
     * 
     * @param location
     */
    public void setLocation(String location) {
        this.location = location;
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
     * QuitOnEnd attribute.
     * 
     * @param quitOnEnd
     */
    public void setQuitOnEnd(boolean quitOnEnd) {
        this.quitOnEnd = quitOnEnd;
    }

    /**
     * Select case(s).
     * 
     * @param cases
     */
    public void setCases(String cases) {
        this.cases = cases.split(",");
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

        if (testFilesets == null || testFilesets.isEmpty())
            throw new BuildException("No fileset found.");

        // Creating config file (json)
        try {
            json = new File(System.getProperty("java.io.tmpdir"), JSONFILENAME);
            writer = new JsonWriter(new FileWriter(json));
            log("Json file created : " + json, Project.MSG_VERBOSE);
            writer.beginObject();

            // Options
            writer.name("options").beginObject();
            // Result file
            if (location != null) {
                buildPath = new File(location);
                if (!buildPath.isDirectory())
                    throw new BuildException("Invalid directory :" + location);

                log("Adding location'" + buildPath + "' to JSon.", Project.MSG_VERBOSE);

                writer.name("output").beginObject();
                writer.name("location").value(location);
                writer.name("format").value(format);

                writer.endObject();
            } else
                buildPath = getProject().getBaseDir();

            // Log
            if (writeLog)
                writer.name("writeLog").value(writeLog);
            // QuitOnEnd
            if (quitOnEnd)
                writer.name("quitOnEnd").value(quitOnEnd);

            // End "Options" object
            writer.endObject();

            // Tests
            writer.name("tests").beginArray();
            for (FileSet fs : testFilesets) {
                for (String file : fs.getDirectoryScanner(getProject()).getIncludedFiles()) {

                    File f = new File(fs.getDir(), file);
                    log("Adding '" + f + "' to JSon.", Project.MSG_VERBOSE);
                    writer.beginObject().name("test").value(f.toString());
                    // If we want to execute a psecific test
                    if (cases != null) {
                        writer.name("cases").beginArray();
                        for (String cs : cases) {
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

        File results = new File(buildPath, "results." + format);
        if (!results.exists())
            throw new BuildException("No results file (" + results
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
                log(MessageFormat.format(Messages.getString("PCTCompile.42"),
                        json.getAbsolutePath()), Project.MSG_INFO);
            }
        }
    }
}
