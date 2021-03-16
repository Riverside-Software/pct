/**
 * Copyright 2005-2021 Riverside Software
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

import static org.testng.Assert.assertEquals;
import static org.testng.Assert.assertFalse;
import static org.testng.Assert.assertTrue;

import java.io.File;
import java.io.FilenameFilter;

import org.apache.tools.ant.BuildException;
import org.testng.annotations.Test;

/**
 * Class for testing PCTLoadSchema task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class PCTLoadSchemaTest extends BuildFileTestNg {

    /**
     * Should throw BuildException : no srcFile and no connection
     */
    @Test(groups = { "v11" }, expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("PCTLoadSchema/test1/build.xml");
        executeTarget("test");
    }

    /**
     * Should throw BuildException : no srcFile defined
     */
    @Test(groups = { "v11" }, expectedExceptions = BuildException.class)
    public void test2() {
        configureProject("PCTLoadSchema/test2/build.xml");
        executeTarget("test");
    }

    /**
     * Should throw BuildException : no connection defined
     */
    @Test(groups = { "v11" }, expectedExceptions = BuildException.class)
    public void test3() {
        configureProject("PCTLoadSchema/test3/build.xml");
        executeTarget("test");
    }

    @Test(groups = { "v11" })
    public void test4() {
        configureProject("PCTLoadSchema/test4/build.xml");
        executeTarget("base");

        executeTarget("test1");
        executeTarget("test2");
    }

    // Error message due to frozen tables isn't trapped in v10
    @Test(groups = { "v11" })
    public void test5() {
        configureProject("PCTLoadSchema/test5/build.xml");
        executeTarget("base");
        expectBuildException("update", "Frozen table, so index can't be created");

        expectBuildException("test1", "");
        executeTarget("update-unfreeze");

        executeTarget("test1");
        expectBuildException("test2", "");
    }
    
    @Test(groups = { "v11" })
    public void test6() {
        configureProject("PCTLoadSchema/test6/build.xml");
        
        expectBuildException("base", "Invalid schema file");
        File[] files = new File("PCTLoadSchema/test6").listFiles(new FilenameFilter() {
            @Override
            public boolean accept(File dir, String name) {
                return name.startsWith("test.e.");
            }
        });
        assertEquals(files.length, 1);
    }
    
    @Test(groups = { "v11" })
    public void test7() {
        configureProject("PCTLoadSchema/test7/build.xml");

        executeTarget("base");
        // Still only one file
        File[] files = new File("PCTLoadSchema/test7").listFiles(new FilenameFilter() {
            @Override
            public boolean accept(File dir, String name) {
                return name.startsWith("test.e");
            }
        });
        // test.e is deleted, and no test.e.XX.YY should be there
        assertFalse(new File("PCTLoadSchema/test7/test.e").exists());
        assertEquals(files.length, 0);   
    }

    // Error message due to frozen tables isn't trapped in v10
    @Test(groups = { "v11" })
    public void test8() {
        configureProject("PCTLoadSchema/test8/build.xml");
        
        expectBuildException("base", "Invalid schema file");
        File[] files = new File("PCTLoadSchema/test8").listFiles(new FilenameFilter() {
            @Override
            public boolean accept(File dir, String name) {
                return name.startsWith("test.e.");
            }
        });
        assertEquals(files.length, 1);

        executeTarget("base2");
        files = new File("PCTLoadSchema/test8").listFiles(new FilenameFilter() {
            @Override
            public boolean accept(File dir, String name) {
                return name.startsWith("test.e.");
            }
        });
        assertEquals(files.length, 2);
        
        expectBuildException("test1", "No Tab2 in DB");
        File f2 = new File("PCTLoadSchema/test8/build/test.r");
        assertFalse(f2.exists());
        
        executeTarget("test2");
        assertTrue(f2.exists());
    }

    @Test(groups = { "v11" })
    public void test9() {
        configureProject("PCTLoadSchema/test9/build.xml");
        executeTarget("base");
        executeTarget("test");
    }
    
    @Test(groups = { "v11" })
    public void test10() {
        configureProject("PCTLoadSchema/test10/build.xml");
        expectBuildException("base", "002.df is invalid");
        executeTarget("base2");
        
        expectBuildException("test", "Fld3 not added");
        executeTarget("test2");
    }

    @Test(groups = { "v11" })
    public void test11() {
        configureProject("PCTLoadSchema/test11/build.xml");
        executeTarget("base");
        File[] files = new File("PCTLoadSchema/test11").listFiles(new FilenameFilter() {
            @Override
            public boolean accept(File dir, String name) {
                return name.startsWith("test.e.");
            }
        });
        assertEquals(files.length, 3);
      executeTarget("test");
    }

    @Test(groups = { "v11" })
    public void test12() {
        configureProject("PCTLoadSchema/test12/build.xml");
        executeTarget("base");
        executeTarget("base2");
        executeTarget("test");
    }

    @Test(groups = { "v11" })
    public void test13() {
        // Only work with 11.3+
        DLCVersion version = DLCVersion.getObject(new File(System.getProperty("DLC")));
        if ((version.getMajorVersion() == 11) && (version.getMinorVersion() <= 2))
            return;

        configureProject("PCTLoadSchema/test13/build.xml");
        executeTarget("base");
        expectBuildException("test", "Failure expected");
        File f = new File("PCTLoadSchema/test13/myerrors.txt");
        assertTrue(f.exists());
        assertTrue(f.length() > 0);
    }

    @Test(groups = { "v11" })
    public void test14() {
        // Only work with 11.3+
        DLCVersion version = DLCVersion.getObject(new File(System.getProperty("DLC")));
        if ((version.getMajorVersion() == 11) && (version.getMinorVersion() <= 2))
            return;

        configureProject("PCTLoadSchema/test14/build.xml");
        executeTarget("base");
        executeTarget("load1");
        executeTarget("load2");
        executeTarget("load3");
        executeTarget("test1");
        expectBuildException("test2", "Failure expected");
        executeTarget("test3");
        File f = new File("PCTLoadSchema/test14/NewIndexes.txt");
        assertTrue(f.exists());
        assertTrue(f.length() > 10);
    }

    @Test(groups = { "v11" })
    public void test15() {
        // Empty schema, we shouldn't fail
        configureProject("PCTLoadSchema/test15/build.xml");
        executeTarget("base");
    }

    @Test(groups = {"v12"})
    public void test16() {
        // Only work with 12.4+
        DLCVersion version = DLCVersion.getObject(new File(System.getProperty("DLC")));
        if ((version.getMajorVersion() == 12) && (version.getMinorVersion() <= 3))
            return;

        configureProject("PCTLoadSchema/test16/build.xml");
        executeTarget("prepare");
        executeTarget("load");
        executeTarget("test");
    }
}
