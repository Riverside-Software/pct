package com.phenix.pct;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.text.MessageFormat;
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
            testFilesets = new ArrayList<FileSet>();
        }
        testFilesets.add(set);
    }

    public OEUnit() {
        super();
    }

    public void execute() throws BuildException {
        // Validation
        if (testFilesets == null)
            throw new BuildException("You must set a fileset (testFilesets).");

        if (destDir != null && !destDir.isDirectory())
            throw new BuildException("Invalid destDir (" + destDir + ")");

        if (destDir == null)
            destDir = getProject().getBaseDir();

        // Create a temp file which list test class to be executed
        testFilesList = new File(System.getProperty("java.io.tmpdir"), testFileName);
        BufferedWriter bw = null;
        try {
            bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(testFilesList),
                    getCharset()));

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
        } finally {
            if (bw != null) {
                try {
                    bw.close();
                } catch (IOException uncaught) {
                }
            }
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
    protected void cleanup() {
        super.cleanup();
        // Clean Test list file
        if (!getDebugPCT()) {
            if (testFilesList.exists() && !testFilesList.delete()) {
                log(MessageFormat.format(Messages.getString("PCTCompile.42"),
                        testFilesList.getAbsolutePath()), Project.MSG_INFO);
            }
        }
    }
}
