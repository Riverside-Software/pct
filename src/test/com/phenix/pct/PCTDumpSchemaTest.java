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
import static org.testng.Assert.fail;

import org.apache.tools.ant.BuildException;
import org.testng.annotations.Test;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

/**
 * PCTDumpSchema testcases
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTDumpSchemaTest extends BuildFileTestNg {

    @Test(groups= {"v10"}, expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("PCTDumpSchema/test1/build.xml");
        executeTarget("test");
    }

    @Test(groups= {"v10"}, expectedExceptions = BuildException.class)
    public void test2() {
        configureProject("PCTDumpSchema/test2/build.xml");
        executeTarget("test");
    }

    @Test(groups= {"v10"}, expectedExceptions = BuildException.class)
    public void test3() {
        configureProject("PCTDumpSchema/test3/build.xml");
        executeTarget("test");
    }

    @Test(groups= {"v10"})
    public void test4() {
        configureProject("PCTDumpSchema/test4/build.xml");

        executeTarget("base");
        executeTarget("test");
        File f1 = new File("PCTDumpSchema/test4/foo/sch.df");
        assertTrue(f1.exists());
        if (!checkFile(f1, "Tab1", ""))
            fail("Incorrect file");
    }

    @Test(groups= {"v10"})
    public void test5() {
        configureProject("PCTDumpSchema/test5/build.xml");

        executeTarget("base");
        executeTarget("test");
        File f1 = new File("PCTDumpSchema/test5/foo/sch.df");
        assertTrue(f1.exists());
        if (!checkFile(f1, "_File", ""))
            fail("Incorrect file");
    }

    @Test(groups= {"v10"})
    public void test6() {
        configureProject("PCTDumpSchema/test6/build.xml");

        executeTarget("base");
        executeTarget("test");

        File f1 = new File("PCTDumpSchema/test6/foo/files1.df");
        File f2 = new File("PCTDumpSchema/test6/foo/files2.df");
        File f3 = new File("PCTDumpSchema/test6/foo/files3.df");

        if (!checkFile(f1, "Tab1", "Tab3"))
            fail("Incorrect files1.df");
        if (!checkFile(f2, "Tab2", "Tab1"))
            fail("Incorrect files2.df");
        if (!checkFile(f3, "Tab3", "Tab2"))
            fail("Incorrect files3.df");
    }

    private boolean checkFile(File f, String inc, String exc) {
        BufferedReader reader = null;
        boolean bInc = false, bExc = true;
        try {
            reader = new BufferedReader(new FileReader(f));
            String str = null;
            while ((str = reader.readLine()) != null) {
                if (str.trim().startsWith("ADD TABLE \"" + inc + "\""))
                    bInc = true;
                if (str.trim().startsWith("ADD TABLE \"" + exc + "\""))
                    bExc = false;
            }
            reader.close();
            return (bInc && bExc);
        } catch (IOException caught) {
            return false;
        } finally {
            try {
                reader.close();
            } catch (IOException uncaught) {

            }
        }
    }
}
