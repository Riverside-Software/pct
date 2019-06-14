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
import static org.testng.Assert.assertEquals;

import org.apache.tools.ant.BuildException;
import org.testng.annotations.Test;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

/**
 * Class for testing PCTDumpData task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class PCTDumpDataTest extends BuildFileTestNg {

    /**
     * Should throw BuildException : no filesets and no connection
     */
    @Test(groups= {"v10"}, expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("PCTDumpData/test1/build.xml");
        executeTarget("test");
    }

    /**
     * Should throw BuildException : no filesets (or srcDir) defined
     */
    @Test(groups= {"v10"}, expectedExceptions = BuildException.class)
    public void test2() {
        configureProject("PCTDumpData/test2/build.xml");
        executeTarget("test");
    }

    /**
     * Should throw BuildException : no connection defined
     */
    @Test(groups= {"v10"}, expectedExceptions = BuildException.class)
    public void test3() {
        configureProject("PCTDumpData/test3/build.xml");
        executeTarget("test");
    }

    /**
     * Should dump Tab1 in target directory
     */
    @Test(groups= {"v10"})
    public void test4() {
        configureProject("PCTDumpData/test4/build.xml");
        executeTarget("prepare");

        executeTarget("test");

        File f1 = new File("PCTDumpData/test4/dump/Tab1.d");
        assertTrue(f1.exists());
    }

    /**
     * Should dump _File in target directory
     */
    @Test(groups= {"v10"})
    public void test5() {
        configureProject("PCTDumpData/test5/build.xml");
        executeTarget("prepare");

        executeTarget("test");

        File f1 = new File("PCTDumpData/test5/dump/_File.d");
        assertTrue(f1.exists());
    }

    /**
     * Tests various encodings
     */
    @Test(groups= {"v10"})
    public void test6() {
        configureProject("PCTDumpData/test6/build.xml");
        executeTarget("prepare");

        executeTarget("test");

        File f1 = new File("PCTDumpData/test6/dump/8859-1/_File.d");
        assertTrue(f1.exists());
        assertEquals(readEncoding(f1), "iso8859-1");
        File f2 = new File("PCTDumpData/test6/dump/8859-15/_File.d");
        assertTrue(f2.exists());
        assertEquals(readEncoding(f2), "iso8859-15");
        File f3 = new File("PCTDumpData/test6/dump/utf8/_File.d");
        assertTrue(f3.exists());
        assertEquals(readEncoding(f3), "utf-8");
    }

    // Quick'n'dirty method to read encoding in dump file
    private String readEncoding(File f) {
        BufferedReader reader = null;
        String encoding = null;

        try {
            reader = new BufferedReader(new FileReader(f));
            String str = null;

            while ((str = reader.readLine()) != null) {
                if (str.startsWith("cpstream="))
                    encoding = str.substring(9);
            }
        } catch (IOException uncaught) {
        } finally {
            try {
                reader.close();
            } catch (IOException uncaught) {

            }
        }
        return encoding;
    }
}