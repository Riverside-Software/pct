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
import java.util.ArrayList;
import java.util.List;

import org.testng.annotations.Test;

/**
 * Class for testing PCTDynamicRun task
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET </a>
 */
public class PCTDynamicRunTest extends BuildFileTestNg {

    @Test(groups = {"v11"})
    public void test1() {
        configureProject("PCTDynamicRun/test1/build.xml");
        executeTarget("init");

        List<String> rexp = new ArrayList<>();
        rexp.add("This is dir1");
        rexp.add("val1");
        rexp.add("val2");
        rexp.add("num-dbs: 2");
        rexp.add("num-aliases: 6");
        rexp.add("Output val1val2");
        expectLogRegexp("test1", rexp, true);

        expectLog("test2", "This is dir2");
    }

    @Test(groups = {"v11"})
    public void test2() {
        configureProject("PCTDynamicRun/test2/build.xml");
        expectLog("test", "Output val1 val2");
        expectLog("test2", "Output val1 val2 val1 val2 val1 val2");
    }

    @Test(groups = {"v11"})
    public void test3() {
        configureProject("PCTDynamicRun/test3/build.xml");
        executeTarget("init");

        List<String> rexp = new ArrayList<>();
        rexp.add("This is dir1");
        rexp.add("val1");
        rexp.add("val2");
        rexp.add("num-dbs: 2");
        rexp.add("num-aliases: 6");
        rexp.add("val3");
        rexp.add("Output val1val2");
        expectLogRegexp("test1", rexp, true);
    }

    @Test(groups = {"v11"})
    public void test4() {
        configureProject("PCTDynamicRun/test4/build.xml");
        List<String> rexp = new ArrayList<>();
        rexp.add("initialize");
        rexp.add("beforeRun");
        rexp.add("In main file");
        rexp.add("afterRun 0");
        expectLogRegexp("test", rexp, true);
    }

    @Test(groups = {"v11"})
    public void test5() {
        final String USER_PASSPHRASE = "User#234";
        configureProject("PCTDynamicRun/test5/build.xml");
        executeTarget("init");
        expectBuildException("test1", "No passphrase");
        assertFalse(searchInList(getLogBuffer(), USER_PASSPHRASE));
        assertFalse(searchInFile(new File("test1.txt"), USER_PASSPHRASE));
        if (System.getProperty("os.name").toLowerCase().startsWith("win")) {
            executeTarget("test4-win");
            assertFalse(searchInList(getLogBuffer(), USER_PASSPHRASE));
            assertFalse(searchInFile(new File("test4.txt"), USER_PASSPHRASE));
            expectBuildException("test5-win", "Wrong command line passphrase");
            assertFalse(searchInList(getLogBuffer(), USER_PASSPHRASE));
            assertFalse(searchInFile(new File("test5.txt"), USER_PASSPHRASE));
        } else {
            executeTarget("test4-unix");
            assertFalse(searchInList(getLogBuffer(), USER_PASSPHRASE));
            assertFalse(searchInFile(new File("test4.txt"), USER_PASSPHRASE));
            expectBuildException("test5-unix", "Wrong command line passphrase");
            assertFalse(searchInList(getLogBuffer(), USER_PASSPHRASE));
            assertFalse(searchInFile(new File("test5.txt"), USER_PASSPHRASE));
        }
    }

    @Test(groups = {"v11"})
    public void test6() {
        configureProject("PCTDynamicRun/test6/build.xml");
        expectBuildException("test", "Failure");
        assertTrue(searchInList(getLogBuffer(), "Not an int"));
        expectBuildException("test2", "Failure");
        assertTrue(searchInList(getLogBuffer(), "** Unable to understand after -- \"mesage\". (247)"));
    }

    @Test(groups = {"v11"})
    public void test7() {
        configureProject("PCTDynamicRun/test7/build.xml");
        executeTarget("test");
        assertTrue(searchInList(getLogBuffer(), "hello"));
        expectBuildException("test2", "Failure");
        assertTrue(searchInList(getLogBuffer(), "hello2"));
        expectBuildException("test3", "Failure");
        assertTrue(searchInList(getLogBuffer(), "(15304)"));
        expectBuildException("test4", "Failure");
        assertTrue(searchInList(getLogBuffer(), "hello4"));
        expectBuildException("test5", "Failure");
        assertTrue(searchInList(getLogBuffer(), "(15285)"));
        expectBuildException("test6", "Failure");
        assertTrue(searchInList(getLogBuffer(), "(15285)"));
        expectBuildException("test7", "Failure");
        assertTrue(searchInList(getLogBuffer(), "(247)"));
        assertTrue(searchInList(getLogBuffer(), "(15285)"));
    }
}
