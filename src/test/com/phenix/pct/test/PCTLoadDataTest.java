/**
 * Copyright 2005-2024 Riverside Software
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
package com.phenix.pct.test;

import static org.testng.Assert.assertFalse;
import static org.testng.Assert.assertTrue;

import java.io.File;

import org.apache.tools.ant.BuildException;
import org.testng.annotations.Test;

import com.phenix.pct.DLCVersion;

/**
 * Class for testing PCTLoadData task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTLoadDataTest extends BuildFileTestNg {

    /**
     * Should throw BuildException : no filesets and no connection
     */
    @Test(groups= {"v11"}, expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("PCTLoadData/test1/build.xml");
        executeTarget("test");
    }

    /**
     * Should throw BuildException : no filesets (or srcDir) defined
     */
    @Test(groups= {"v11"}, expectedExceptions = BuildException.class)
    public void test2() {
        configureProject("PCTLoadData/test2/build.xml");
        executeTarget("test");
    }

    /**
     * Should throw BuildException : no connection defined
     */
    @Test(groups= {"v11"}, expectedExceptions = BuildException.class)
    public void test3() {
        configureProject("PCTLoadData/test3/build.xml");
        executeTarget("test");
    }

    /**
     * Should load data into database, and expect first result in FOR EACH be 14
     */
    @Test(groups= {"v11"})
    public void test4() {
        configureProject("PCTLoadData/test4/build.xml");
        executeTarget("base");
        executeTarget("load");
        expectLog("test", "16 20");
        File dotD = new File("PCTLoadData/test4/data/Tab1.d");
        assertTrue(dotD.exists()); // Just to be sure we're in the right dir
        File dotE = new File("PCTLoadData/test4/data/Tab1.e");
        assertFalse(dotE.exists());
    }

    /**
     * Should first load data into table Tab1, then in Tab2, using PCTTable attribute
     */
    @Test(groups= {"v11"})
    public void test5() {
        configureProject("PCTLoadData/test5/build.xml");
        executeTarget("base");
        expectLog("test1", "---");
        expectLog("test2", "---");

        executeTarget("load1");
        expectLog("test1", "16");
        expectLog("test2", "---");

        executeTarget("load2");
        expectLog("test1", "16");
        expectLog("test2", "15");
    }

    /**
     * Test procedure with callback
     */
    @Test(groups= {"v11"})
    public void test6() {
        // Only work with 11.3+
        DLCVersion version = DLCVersion.getObject(new File(System.getProperty("DLC")));
        if ((version.getMajorVersion() == 11) && (version.getMinorVersion() <= 2))
            return;

        configureProject("PCTLoadData/test6/build.xml");
        executeTarget("base");
        executeTarget("load-replace");
        executeTarget("load-replace");
        executeTarget("test1");
        assertPropertyEquals("LoadData-val1", "2");
        
        executeTarget("load-append");
        executeTarget("load-append");
        executeTarget("test2");
        assertPropertyEquals("LoadData-val2", "6");

        expectBuildException("load-error", "Should fail");
        File f = new File("PCTLoadData/test6/myerrors.txt");
        assertTrue(f.exists());
    }

    /**
     * Test procedure with callback
     */
    @Test(groups= {"v11"})
    public void test7() {
        // Only work with 11.3+
        DLCVersion version = DLCVersion.getObject(new File(System.getProperty("DLC")));
        if ((version.getMajorVersion() == 11) && (version.getMinorVersion() <= 2))
            return;

        configureProject("PCTLoadData/test7/build.xml");
        executeTarget("base");
        executeTarget("load-noerror");
        expectBuildException("load-error1", "Should fail");
        executeTarget("load-error2");
    }

    /**
     * Format error during load should throw exception
     */
    @Test(groups= {"v11"})
    public void test8() {
        // Only work with 11.3+
        DLCVersion version = DLCVersion.getObject(new File(System.getProperty("DLC")));
        if ((version.getMajorVersion() == 11) && (version.getMinorVersion() <= 2))
            return;
        // Issue fixed in 12.5, so can't reproduce test case
        if (version.getMajorVersion() >= 13)
            return;
        if ((version.getMajorVersion() == 12) && (version.getMinorVersion() >= 5))
            return;

        configureProject("PCTLoadData/test8/build.xml");
        executeTarget("base");
        // Should fail with PCTLoadDataCallback
        expectBuildException("load1", "Should fail");
        expectBuildException("load2", "Should fail");
    }

    /**
     * Format error during load should throw exception
     */
    @Test(groups= {"v11"})
    public void test9() {
        // Only work with 11.3+
        DLCVersion version = DLCVersion.getObject(new File(System.getProperty("DLC")));
        if ((version.getMajorVersion() == 11) && (version.getMinorVersion() <= 2))
            return;
        // Issue fixed in 12.5, so can't reproduce test case
        if (version.getMajorVersion() >= 13)
            return;
        if ((version.getMajorVersion() == 12) && (version.getMinorVersion() >= 5))
            return;

        configureProject("PCTLoadData/test9/build.xml");
        // Configure database
        executeTarget("base");
        // Record 'é' should be there
        executeTarget("test");
        
        // Should fail (invalid numsep numdec)
        expectBuildException("load1", "Should fail");
        // But record 'é' should still be there
        executeTarget("test");
        
        // Should fail (invalid data >= tolerance)
        expectBuildException("load2", "Should fail");
        // But record 'é' should still be there
        executeTarget("test");
    }

    /**
     * Should return error when loading data twice with errorTolerance zero
     */
    @Test(groups= {"v11"})
    public void test10() {
        configureProject("PCTLoadData/test10/build.xml");
        // Build db and load initial data
        executeTarget("base");
        // Should fail, because errorTolerance is 0
        expectBuildException("load1", "Should fail");
        // Should run successful, because errorTolerance is 100
        executeTarget("load2");
        // Should fail, because errorTolerance is 0
        expectBuildException("load3", "Should fail");
        // Should run successful, because errorTolerance is 100
        executeTarget("load4");
        // Should fail, because errorTolerance is only 30
        expectBuildException("load5", "Should fail");
        // Should fail, because errorTolerance is 60, but numsep is incorrect
        // Issue fixed in 12.5, so can't reproduce test case
        DLCVersion version = DLCVersion.getObject(new File(System.getProperty("DLC")));
        if (version.getMajorVersion() >= 13)
            return;
        if ((version.getMajorVersion() == 12) && (version.getMinorVersion() >= 5))
            return;
        expectBuildException("load6", "Should fail");
    }

}
