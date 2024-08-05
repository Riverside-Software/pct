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
 * Class for testing PCTCreateDatabase task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTCreateDatabaseTest extends BuildFileTestNg {

    @Test(groups= {"v11"}, expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("PCTCreateDatabase/test1/build.xml");
        executeTarget("test");
    }

    @Test(groups= {"v11"}, expectedExceptions = BuildException.class)
    public void test2() {
        configureProject("PCTCreateDatabase/test2/build.xml");
        executeTarget("test");
    }

    @Test(groups= {"v11"})
    public void test3() {
        configureProject("PCTCreateDatabase/test3/build.xml");
        executeTarget("test");

        File f = new File("PCTCreateDatabase/test3/db/test3.db");
        assertTrue(f.exists());
    }

    @Test(groups= {"v11"}, expectedExceptions = BuildException.class)
    public void test4() {
        configureProject("PCTCreateDatabase/test4/build.xml");
        executeTarget("test");
    }

    @Test(groups= {"v11"})
    public void test5() {
        configureProject("PCTCreateDatabase/test5/build.xml");
        executeTarget("base");
        File f = new File("PCTCreateDatabase/test5/db/test.db");
        assertTrue(f.exists());

        executeTarget("test");
        f = new File("PCTCreateDatabase/test5/build/test.r");
        assertTrue(f.exists());
    }

    @Test(groups= {"v11"})
    public void test6() {
        configureProject("PCTCreateDatabase/test6/build.xml");
        executeTarget("test");

        File f = new File("PCTCreateDatabase/test6/db/test.db");
        long time = f.lastModified();
        executeTarget("test2");
        assertTrue(f.lastModified() == time);
    }

    @Test(groups= {"v11"})
    public void test7() {
        // TODO : fix the overwrite attribute and uncomment this
        // configureProject("PCTCreateDatabase/test7/build.xml");
        // executeTarget("test");

        // File f = new File("sandbox/test.db");
        // long time = f.lastModified();
        // executeTarget("test");
        // assert True(f.lastModified() != time);
    }

    @Test(groups= {"v11"})
    public void test8() {
        configureProject("PCTCreateDatabase/test8/build.xml");
        executeTarget("test");

        File f = new File("PCTCreateDatabase/test8/db/test.b1");
        assertTrue(f.exists());
        f = new File("PCTCreateDatabase/test8/db/test.b2");
        assertTrue(f.exists());
        f = new File("PCTCreateDatabase/test8/db/test.d1");
        assertTrue(f.exists());
        f = new File("PCTCreateDatabase/test8/db/test.d2");
        assertTrue(f.exists());

        executeTarget("test2");
    }

    @Test(groups= {"v11"})
    public void test9() {
        configureProject("PCTCreateDatabase/test9/build.xml");
        executeTarget("test");

        File f = new File("PCTCreateDatabase/test9/db/test.db");
        assertTrue(f.exists());
        executeTarget("test2");
        f = new File("PCTCreateDatabase/test9/build/test.r");
        assertTrue(f.exists());
    }

    @Test(groups= {"v11"})
    public void test10() {
        configureProject("PCTCreateDatabase/test10/build.xml");
        executeTarget("test");

        File f1 = new File("PCTCreateDatabase/test10/db/test.db");
        assertTrue(f1.exists());
        File f2 = new File("PCTCreateDatabase/test10/build/test.r");
        assertTrue(f2.exists());

        expectBuildException("test2", "Should throw BuildException as schema doesn't exist");
    }

    @Test(groups= {"v11"})
    public void test11() {
        configureProject("PCTCreateDatabase/test11/build.xml");
        executeTarget("test1");
        File f = new File("PCTCreateDatabase/test11/dir with spaces/test.db");
        assertTrue(f.exists());

        executeTarget("test2");
        f = new File("PCTCreateDatabase/test11/build/test.r");
        assertTrue(f.exists());
    }

    @Test(groups = {"v11"})
    public void test12() {
        configureProject("PCTCreateDatabase/test12/build.xml");
        
        expectBuildException("test", "Structure file not found");
        File f = new File("PCTCreateDatabase/test12/db/test.db");
        assertFalse(f.exists());
    }

    @Test(groups = {"v11"})
    public void test13() {
        configureProject("PCTCreateDatabase/test13/build.xml");
        
        executeTarget("test");
        executeTarget("verify");
    }

    @Test(groups = {"v11", "unix"})
    public void test14() {
        // Not valid anymore on v12+, all databases have large files enabled
        DLCVersion version = DLCVersion.getObject(new File(System.getProperty("DLC")));
        if (version.getMajorVersion() >= 12)
            return;

        configureProject("PCTCreateDatabase/test14/build.xml");
        executeTarget("test");
        executeTarget("verify");
    }

    @Test(groups = {"v11"})
    public void test15() {
        configureProject("PCTCreateDatabase/test15/build.xml");
        
        executeTarget("test");
        executeTarget("verify");
    }

    @Test(groups = {"v11"})
    public void test16() {
        configureProject("PCTCreateDatabase/test16/build.xml");
        
        executeTarget("test");
        executeTarget("verify");
    }

    @Test(groups= {"v11"})
    public void test17() {
        configureProject("PCTCreateDatabase/test17/build.xml");
        executeTarget("base");
        File f = new File("PCTCreateDatabase/test17/db/test.db");
        assertTrue(f.exists());
        File f2 = new File("PCTCreateDatabase/test17/db/test2.db");
        assertTrue(f2.exists());

        executeTarget("test");
        File f3 = new File("PCTCreateDatabase/test17/build/test.r");
        assertTrue(f3.exists());
        executeTarget("test2");
        File f4 = new File("PCTCreateDatabase/test17/build2/test.r");
        assertTrue(f4.exists());
    }

    @Test(groups= {"unix", "v11"})
    public void test18() {
        configureProject("PCTCreateDatabase/test18/build.xml");
        executeTarget("init");
        // Early exit - Unit tests in Docker are using root, thus can write everywhere
        File tmpDir = new File("PCTCreateDatabase/test18/tmp");
        if (tmpDir.canWrite())
            return;
        expectBuildException("db1", "Temp dir not writable");
        executeTarget("db2");
        executeTarget("test");
        File f = new File("PCTCreateDatabase/test18/build/test.r");
        assertTrue(f.exists());
    }

    @Test(groups= {"unix", "v11"})
    public void test19() {
        configureProject("PCTCreateDatabase/test19/build.xml");
        executeTarget("init");
        expectBuildException("test1", "Invalid structure file");
        expectBuildException("test2", "Failure during procopy");
    }

    @Test(groups= {"v11"})
    public void test20() {
        configureProject("PCTCreateDatabase/test20/build.xml");
        executeTarget("base");
        expectBuildException("test1", "No CDC");
        executeTarget("test2");
    }

    @Test(groups= {"v11"})
    public void test21() {
        configureProject("PCTCreateDatabase/test21/build.xml");
        executeTarget("base");
        expectBuildException("test1", "No Table Partitioning");
        executeTarget("test2");
    }

    @Test(groups= {"v11"})
    public void test22() {
        configureProject("PCTCreateDatabase/test22/build.xml");
        executeTarget("base");
        expectBuildException("test2", "TDE Activated");
        executeTarget("test1");
    }

}
