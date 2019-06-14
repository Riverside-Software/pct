/**
 * Copyright 2005-2019 Riverside Software
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

import static org.testng.Assert.assertTrue;
import static org.testng.Assert.assertFalse;

import org.apache.tools.ant.BuildException;
import org.testng.annotations.Test;

import java.io.File;

/**
 * Class for testing PCTBinaryDump task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTBinaryDumpTest extends BuildFileTestNg {

    @Test(groups = {"v10"}, expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("PCTBinaryDump/test1/build.xml");
        executeTarget("test");
    }

    @Test(groups = {"v10"}, expectedExceptions = BuildException.class)
    public void test2() {
        configureProject("PCTBinaryDump/test2/build.xml");
        executeTarget("test");
    }

    @Test(groups = {"v10"}, expectedExceptions = BuildException.class)
    public void test3() {
        configureProject("PCTBinaryDump/test3/build.xml");
        executeTarget("test");
    }

    @Test(groups = {"v10"})
    public void test4() {
        configureProject("PCTBinaryDump/test4/build.xml");
        executeTarget("test");

        File f1 = new File("PCTBinaryDump/test4/Tab1.bd");
        File f2 = new File("PCTBinaryDump/test4/Tab2.bd");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
    }

    @Test(groups = {"v10"})
    public void test5() {
        configureProject("PCTBinaryDump/test5/build.xml");
        executeTarget("test");

        File f1 = new File("PCTBinaryDump/test5/Tab1.bd");
        File f2 = new File("PCTBinaryDump/test5/Tab2.bd");
        assertTrue(f1.exists());
        assertFalse(f2.exists());
    }

    @Test(groups = {"v10"})
    public void test6() {
        configureProject("PCTBinaryDump/test6/build.xml");
        executeTarget("test");

        File f1 = new File("PCTBinaryDump/test6/aa.bd");
        File f2 = new File("PCTBinaryDump/test6/aab.bd");
        File f3 = new File("PCTBinaryDump/test6/aabc.bd");
        assertTrue(f1.exists());
        assertFalse(f2.exists());
        assertTrue(f3.exists());
    }
}
