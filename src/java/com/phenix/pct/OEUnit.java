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
 * Ant task for OEUnit tests. For more details about OEUnit, see https://github.com/CameronWills/OEUnit.
 * 
 * @author <a href="mailto:b.thoral@riverside-software.fr">Bastien THORAL</a>
 */
public class OEUnit extends PCTRun {

    private File srcDir;
    private File destDir;

    /**
     * Set the path of the results file.
     * 
     * @param location
     */
    public void setDestDir(File destDir) {
        this.destDir = destDir;
    }

    /**
     * Set path to test folder.
     * 
     * @param location
     */
    public void setSrcDir(File srcDir) {
        this.srcDir = srcDir;
    }

    public OEUnit() {
        super();
    }

    public void execute() throws BuildException {
       
        // Validation
        if (destDir != null && !destDir.isDirectory())
            throw new BuildException("Invalid destDir (" + destDir + ")");
        else if(destDir==null)
            destDir=getProject().getBaseDir();
        
        if (srcDir == null || !srcDir.isDirectory())
            throw new BuildException("Invalid srcDir (" + srcDir + ")");
        
        // Setting PCTRun parameters
        setProcedure("RunFromCommandLine.p");
        setParameter(destDir+","+srcDir);
        // Run PCTRun
        super.execute();
        
       /* File results = new File(destDir, "results." + format);
        if (!results.exists())
            throw new BuildException("No results file (" + results
                    + ") ! It could be an error in an ABL Procedure/Class.");*/
    }
}
