/**
 * Copyright 2005-2018 Riverside Software
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

import static org.testng.Assert.assertFalse;
import static org.testng.Assert.assertTrue;

import org.apache.tools.ant.BuildException;
import org.testng.annotations.Test;

import java.io.File;

/**
 * Class for testing PCTCreateBase task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTCreateBaseTest extends BuildFileTestNg {

    @Test(groups= {"v10"}, expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("PCTCreateBase/test1/build.xml");
        executeTarget("test");
    }

    @Test(groups= {"v10"}, expectedExceptions = BuildException.class)
    public void test2() {
        configureProject("PCTCreateBase/test2/build.xml");
        executeTarget("test");
    }

    @Test(groups= {"v10"})
    public void test3() {
        configureProject("PCTCreateBase/test3/build.xml");
        executeTarget("test");

        File f = new File("PCTCreateBase/test3/db/test3.db");
        assertTrue(f.exists());
    }

    @Test(groups= {"v10"}, expectedExceptions = BuildException.class)
    public void test4() {
        configureProject("PCTCreateBase/test4/build.xml");
        executeTarget("test");
    }

    @Test(groups= {"v10"})
    public void test5() {
        configureProject("PCTCreateBase/test5/build.xml");
        executeTarget("base");
        File f = new File("PCTCreateBase/test5/db/test.db");
        assertTrue(f.exists());

        executeTarget("test");
        f = new File("PCTCreateBase/test5/build/test.r");
        assertTrue(f.exists());
    }

    @Test(groups= {"v10"})
    public void test6() {
        configureProject("PCTCreateBase/test6/build.xml");
        executeTarget("test");

        File f = new File("PCTCreateBase/test6/db/test.db");
        long time = f.lastModified();
        executeTarget("test2");
        assertTrue(f.lastModified() == time);
    }

    @Test(groups= {"v10"})
    public void test7() {
        // TODO : fix the overwrite attribute and uncomment this
        // configureProject("PCTCreateBase/test7/build.xml");
        // executeTarget("test");

        // File f = new File("sandbox/test.db");
        // long time = f.lastModified();
        // executeTarget("test");
        // assert True(f.lastModified() != time);
    }

    @Test(groups= {"v10"})
    public void test8() {
        configureProject("PCTCreateBase/test8/build.xml");
        executeTarget("test");

        File f = new File("PCTCreateBase/test8/db/test.b1");
        assertTrue(f.exists());
        f = new File("PCTCreateBase/test8/db/test.b2");
        assertTrue(f.exists());
        f = new File("PCTCreateBase/test8/db/test.d1");
        assertTrue(f.exists());
        f = new File("PCTCreateBase/test8/db/test.d2");
        assertTrue(f.exists());

        executeTarget("test2");
    }

    @Test(groups= {"v10"})
    public void test9() {
        configureProject("PCTCreateBase/test9/build.xml");
        executeTarget("test");

        File f = new File("PCTCreateBase/test9/db/test.db");
        assertTrue(f.exists());
        executeTarget("test2");
        f = new File("PCTCreateBase/test9/build/test.r");
        assertTrue(f.exists());
    }

    @Test(groups= {"v10"})
    public void test10() {
        configureProject("PCTCreateBase/test10/build.xml");
        executeTarget("test");

        File f1 = new File("PCTCreateBase/test10/db/test.db");
        assertTrue(f1.exists());
        File f2 = new File("PCTCreateBase/test10/build/test.r");
        assertTrue(f2.exists());

        expectBuildException("test2", "Should throw BuildException as schema doesn't exist");
    }

    @Test(groups= {"v10"})
    public void test11() {
        configureProject("PCTCreateBase/test11/build.xml");
        executeTarget("test1");
        File f = new File("PCTCreateBase/test11/dir with spaces/test.db");
        assertTrue(f.exists());

        executeTarget("test2");
        f = new File("PCTCreateBase/test11/build/test.r");
        assertTrue(f.exists());
    }

    @Test(groups = {"v10"})
    public void test12() {
        configureProject("PCTCreateBase/test12/build.xml");
        
        expectBuildException("test", "Structure file not found");
        File f = new File("PCTCreateBase/test12/db/test.db");
        assertFalse(f.exists());
    }

    @Test(groups = {"v10"})
    public void test13() {
        configureProject("PCTCreateBase/test13/build.xml");
        
        executeTarget("test");
        executeTarget("verify");
    }

    @Test(groups = {"v11", "unix"})
    public void test14() {
        configureProject("PCTCreateBase/test14/build.xml");
        
        executeTarget("test");
        executeTarget("verify");
    }

    @Test(groups = {"v10"})
    public void test15() {
        configureProject("PCTCreateBase/test15/build.xml");
        
        executeTarget("test");
        executeTarget("verify");
    }

    @Test(groups = {"v10"})
    public void test16() {
        configureProject("PCTCreateBase/test16/build.xml");
        
        executeTarget("test");
        executeTarget("verify");
    }

    @Test(groups= {"v10"})
    public void test17() {
        configureProject("PCTCreateBase/test17/build.xml");
        executeTarget("base");
        File f = new File("PCTCreateBase/test17/db/test.db");
        assertTrue(f.exists());
        File f2 = new File("PCTCreateBase/test17/db/test2.db");
        assertTrue(f2.exists());

        executeTarget("test");
        File f3 = new File("PCTCreateBase/test17/build/test.r");
        assertTrue(f3.exists());
        executeTarget("test2");
        File f4 = new File("PCTCreateBase/test17/build2/test.r");
        assertTrue(f4.exists());
    }

    @Test(groups= {"unix", "v10"})
    public void test18() {
        configureProject("PCTCreateBase/test18/build.xml");
        executeTarget("init");
        expectBuildException("db1", "Temp dir not writable");
        executeTarget("db2");
        executeTarget("test");
        File f = new File("PCTCreateBase/test18/build/test.r");
        assertTrue(f.exists());
    }


}
