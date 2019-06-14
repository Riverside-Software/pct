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

import static org.testng.Assert.assertFalse;
import static org.testng.Assert.assertTrue;

import java.io.File;

import org.apache.tools.ant.BuildException;
import org.testng.annotations.Test;

/**
 * Class for testing PCTProxygen task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTProxygenTest extends BuildFileTestNg {

    @Test(groups = { "v10" }, expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("PCTProxygen/test1/build.xml");
        executeTarget("test");
    }

    @Test(groups = { "v10", "win" })
    public void test2() {
        configureProject("PCTProxygen/test2/build.xml");
        executeTarget("prepare");

        executeTarget("test1");
        File f1 = new File("PCTProxygen/test2/pxg/Test.class");
        File f2 = new File("PCTProxygen/test2/pxg/TestImpl.class");
        File f3 = new File("PCTProxygen/test2/pxg/TestImpl.java");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        assertFalse(f3.exists());

        executeTarget("test2");
        assertTrue(f3.exists());
    }

    @Test(groups = { "v11", "win" })
    public void test3() {
        configureProject("PCTProxygen/test3/build.xml");
        executeTarget("prepare");

        File f1 = new File("PCTProxygen/test3/pxg/Test.class");
        File f2 = new File("PCTProxygen/test3/pxg/TestImpl.class");
        expectBuildException("test1", "Invalid JVM option");
        expectBuildException("test2", "Not enough memory");
        executeTarget("test3");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
    }
    
    @Test(groups = { "v10", "win" })
    public void test4() {
        configureProject("PCTProxygen/test4/build.xml");
        executeTarget("prepare");

        executeTarget("test1");
        File f1 = new File("PCTProxygen/test4/pxg/Test.class");
        File f2 = new File("PCTProxygen/test4/pxg/TestImpl.class");
        File f3 = new File("PCTProxygen/test4/pxg/TestImpl.java");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        assertFalse(f3.exists());

        executeTarget("test2");
        assertTrue(f3.exists());
    }

    @Test(groups = { "v11", "win" })
    public void test5() {
        configureProject("PCTProxygen/test5/build.xml");
        executeTarget("prepare");

        executeTarget("test1");
        File f1 = new File("PCTProxygen/test5/build-pxg1/Test.class");
        File f2 = new File("PCTProxygen/test5/build-pxg1/TestImpl.class");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        File f3 = new File("PCTProxygen/test5/build-pxg2/Test.class");
        File f4 = new File("PCTProxygen/test5/build-pxg2/TestImpl.class");
        assertTrue(f3.exists());
        assertTrue(f4.exists());
    }
}
