package com.phenix.pct;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;

import org.apache.tools.ant.BuildException;

import com.google.gson.stream.JsonWriter;
import com.phenix.pct.PCTRun;

/**
 * Ant task for ABLunit tests. For more details about ABLUnit, see the progress documentation.
 * ABLUnit is officially available for version greater than 11.4.
 * 
 * @author <a href="mailto:b.thoral@riverside-software.fr">Bastien THORAL</a>
 * @version $Revision$
 */
public class ABLUnit extends PCTRun {
    private Collection<BatchTestParameter> testList = null;

    // We get the batchtests list
    public void addConfiguredBatchTest(BatchTestParameter batchtest) {
        if (this.testList == null) {
            testList = new ArrayList<BatchTestParameter>();
        }
        testList.add(batchtest);
    }

    public ABLUnit() {
        super();
    }

    public void execute() throws BuildException {    
        String proc = "ablunitcore.p";
        JsonWriter writer;
        String loc = this.getLocation().toString();
        loc = loc.substring(0, loc.lastIndexOf("\\"));

        if (testList != null) {
            try {
                writer = new JsonWriter(new FileWriter(loc+"\\tests.json"));
                writer.beginObject(); // {
                writer.name("tests"); // "tests" :
                writer.beginArray(); // [
                for (BatchTestParameter rn : testList) {
                    String value = rn.getName();
                    if (rn.getTest() != null)
                        value += value + "#" + rn.getTest();

                    writer.beginObject(); // {
                    writer.name("test").value(value);
                    writer.endObject(); // }
                }
                writer.endArray(); // ]
                writer.endObject(); // }
                writer.close();

            } catch (IOException e) {
                throw new BuildException(e);
            }
        } else
            throw new BuildException("Task 'ABLUnit' requires, at least, one 'batchtest' node.");
        
        this.setProcedure(proc);
        this.setParameter("\"CFG="+loc+"\\tests.json\"");
        //QUIT expected in 'ABLUnitCore.p'
        this.setNoErrorOnQuit(true);
        
        super.execute();
        
        File results = new File(loc+"\\results.xml");
        if(!results.exists())
            throw new BuildException("No results.xml file ("+loc+") ! Must be an error in a ABL Procedure/Classe.");
    }
}
