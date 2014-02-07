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
            throw new BuildException("No files found or no fileset at all.");

        try {
            json = new File(System.getProperty("java.io.tmpdir"), JSONFILENAME);
            log("Json file created : " + json, Project.MSG_VERBOSE);
            writer = new JsonWriter(new FileWriter(json));
            writer.beginObject().name("tests");
            writer.beginArray();
            // Check fileset element
            for (FileSet fs : testFilesets) {
                for (String file : fs.getDirectoryScanner(getProject()).getIncludedFiles()) {

                    File f = new File(fs.getDir(), file);
                    log("Adding '" + f + "' to JSon.", Project.MSG_VERBOSE);
                    writer.beginObject().name("test").value(f.toString());
                    writer.endObject();
                }
            }
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
        //Setting PCTRun parameters
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
