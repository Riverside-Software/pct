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
 * Class for testing PCTDumpSequences task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class PCTDumpSequencesTest extends BuildFileTestNg {

    /**
     * Should throw BuildException : no filesets and no connection
     */
    @Test(groups= {"v10"}, expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("PCTDumpSequences/test1/build.xml");
        executeTarget("test");
    }

    /**
     * Should throw BuildException : no destDir defined
     */
    @Test(groups= {"v10"}, expectedExceptions = BuildException.class)
    public void test2() {
        configureProject("PCTDumpSequences/test2/build.xml");
        executeTarget("test");
    }

    /**
     * Should throw BuildException : no connection defined
     */
    @Test(groups= {"v10"}, expectedExceptions = BuildException.class)
    public void test3() {
        configureProject("PCTDumpSequences/test3/build.xml");
        executeTarget("test");
    }

    /**
     * Should dump two sequences in target directory
     */
    @Test(groups= {"v10"})
    public void test4() {
        configureProject("PCTDumpSequences/test4/build.xml");
        executeTarget("base");
        executeTarget("test");

        File f1 = new File("PCTDumpSequences/test4/sandbox/_seqvals.d");
        assertTrue(f1.exists());
    }

    /**
     * Should dump no sequences in target directory
     */
    @Test(groups= {"v10"})
    public void test5() {
        configureProject("PCTDumpSequences/test5/build.xml");
        executeTarget("base");
        executeTarget("test");

        File f1 = new File("PCTDumpSequences/test5/sandbox/_seqvals.d");
        assertTrue(f1.exists());
    }

}