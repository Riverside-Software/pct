package com.phenix.pct;

import java.util.ArrayList;
import java.util.Collection;

import org.apache.tools.ant.BuildException;

import com.phenix.pct.PCTRun;

/**
 * Ant task for ABLunit tests. For more details about ABLUnit, see the progress documentation.
 * ABLUnit is officially available for version greater than 11.4.
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 * @version $Revision$
 */
public class ABLUnit extends PCTRun {
    private Collection<BatchTestParameter> testList = null;

    //We get the batchtests list
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
        StringBuffer sb = new StringBuffer("");
        String proc = "pct/v11/PCTABLUnitRunner.p";

        if (testList != null) {
            for (BatchTestParameter rn : testList) {
                if (sb.length() > 0)
                    sb.append(',');
                sb.append(rn.getName());
                String test = rn.getTest();
                if (test != null ) {
                   
                        sb.append("#" + test);
                }
            }
        }else
            throw new BuildException("Task 'ABLUnit' requires, at least, one 'batchtest' bode.");

        this.setProcedure(proc);
        this.setParameter(sb.toString());

        super.execute();

    }
}
