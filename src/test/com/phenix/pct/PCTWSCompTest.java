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

import org.apache.tools.ant.BuildException;
import org.testng.annotations.Test;

import java.io.File;

/**
 * Class for testing PCTWSComp task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class PCTWSCompTest extends BuildFileTestNg {

    @Test(groups = { "v10" }, expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("PCTWSComp/test1/build.xml");
        executeTarget("test");
    }

    /**
     * Do nothing : should not hurt
     */
    @Test(groups = { "v10" })
    public void test2() {
        configureProject("PCTWSComp/test2/build.xml");
        executeTarget("test");
    }

    /**
     * Very simple compilation
     */
    @Test(groups = { "v10" })
    public void test3() {
        configureProject("PCTWSComp/test3/build.xml");
        executeTarget("test1");

        File f = new File("PCTWSComp/test3/build/index.w");
        assertTrue(f.exists());

        executeTarget("test2");
        File f2 = new File("PCTWSComp/test3/build/index.i");
        assertTrue(f.exists());
        assertTrue(f2.length() < f.length());
    }
}