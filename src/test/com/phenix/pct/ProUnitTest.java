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

import static org.testng.Assert.assertTrue;

import org.apache.tools.ant.BuildException;
import org.testng.annotations.Test;

import java.io.File;

/**
 * Class for testing ProUnit task
 * 
 * @author <a href="mailto:b.thoral@riverside-software.fr">Bastien THORAL </a>
 */
public class ProUnitTest extends BuildFileTestNg {

    //Expected error if we miss project file parameter
    @Test(groups= {"v10", "nov12"}, expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("ProUnit/test1/build.xml");
        executeTarget("test");
    }

    //Expected error if it's a bad project file parameter
    @Test(groups= {"v10", "nov12"}, expectedExceptions = BuildException.class)
    public void test2() {
        configureProject("ProUnit/test2/build.xml");
        executeTarget("test");
    }

    //Normal execution with results
    @Test(groups= {"v10", "nov12"})
    public void test3() {
        configureProject("ProUnit/test3/build.xml");
        executeTarget("test");
        File f = new File("ProUnit/test3/testProUnit.xml");
        assertTrue(f.exists());
    }

}