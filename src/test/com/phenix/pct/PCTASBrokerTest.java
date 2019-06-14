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
import static org.testng.Assert.assertEquals;
import static org.testng.Assert.assertNotNull;
import static org.testng.Assert.assertNull;
import static org.testng.Assert.assertTrue;

import org.apache.tools.ant.BuildException;
import org.ini4j.Ini;
import org.ini4j.Profile.Section;
import org.ini4j.InvalidFileFormatException;
import org.testng.annotations.Test;

import java.io.File;
import java.io.IOException;

/**
 * Class for testing PCTASBroker task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTASBrokerTest extends BuildFileTestNg {

    @Test(groups = {"v10"}, expectedExceptions = BuildException.class)
    public void testFailure1() {
        configureProject("PCTASBroker/test1/build.xml");
        executeTarget("test");
    }

    @Test(groups = {"v10"}, expectedExceptions = BuildException.class)
    public void testFailure2() {
        configureProject("PCTASBroker/test2/build.xml");
        executeTarget("test");
    }

    @Test(groups = {"v10"})
    public void testSimplestTest() throws InvalidFileFormatException, IOException {
        configureProject("PCTASBroker/test3/build.xml");
        executeTarget("test");

        Ini ini = new Ini(new File("PCTASBroker/test3/ubroker.properties"));
        assertNotNull(ini.get("UBroker.AS.Test"));
    }

    @Test(groups = {"v10"})
    public void testUidNone() throws InvalidFileFormatException, IOException {
        configureProject("PCTASBroker/test4/build.xml");
        executeTarget("test");

        Ini ini = new Ini(new File("PCTASBroker/test4/ubroker.properties"));
        Section section = ini.get("UBroker.AS.Test");
        assertNotNull(section);
        assertFalse(section.containsKey("uuid"));
    }

    @Test(groups = {"v10"})
    public void testUidAuto() throws InvalidFileFormatException, IOException {
        configureProject("PCTASBroker/test5/build.xml");
        executeTarget("test");

        Ini ini = new Ini(new File("PCTASBroker/test5/ubroker.properties"));
        Section section = ini.get("UBroker.AS.Test");
        assertNotNull(section);
        assertTrue(section.containsKey("uuid"));
        assertNotNull(section.get("uuid"), "Null uuid");
        assertTrue((section.get("uuid", String.class).length() < 30), "Weird UUID pattern...");
    }

    @Test(groups = {"v10"})
    public void testUid() throws InvalidFileFormatException, IOException {
        configureProject("PCTASBroker/test6/build.xml");
        executeTarget("test");

        Ini ini = new Ini(new File("PCTASBroker/test6/ubroker.properties"));
        Section section = ini.get("UBroker.AS.Test");
        assertNotNull(section);
        assertTrue(section.containsKey("uuid"));
        assertNotNull(section.get("uuid"), "Null uuid");
        assertTrue(
                section.get("uuid", String.class).equals(
                        "3fb5744ad58ca1b0:239137:10a178402e4:-8000"), "Wrong UUID");
    }

    @Test(groups = {"v10"})
    public void testLogging() throws InvalidFileFormatException, IOException {
        configureProject("PCTASBroker/test7/build.xml");
        executeTarget("test");

        Ini ini = new Ini(new File("PCTASBroker/test7/ubroker.properties"));
        Section section = ini.get("UBroker.AS.Test");
        assertNotNull(section.get("brokerLogFile"));
        assertNotNull(section.get("brkrLoggingLevel"));
        assertNotNull(section.get("srvrLoggingLevel"));
        assertNotNull(section.get("srvrLogFile"));
    }

    @Test(groups = {"v10"})
    public void testApsvDelete() throws InvalidFileFormatException, IOException {
        configureProject("PCTASBroker/test8/build.xml");
        executeTarget("test");

        Ini ini = new Ini(new File("PCTASBroker/test8/ubroker.properties"));
        assertNull(ini.get("UBroker.AS.Test"));
    }

    @Test(groups = {"v10"})
    public void testApsvUpdate() throws InvalidFileFormatException, IOException {
        configureProject("PCTASBroker/test9/build.xml");
        executeTarget("test1");

        Ini ini = new Ini(new File("PCTASBroker/test9/ubroker.properties"));
        Section section = ini.get("UBroker.AS.Test");
        assertNotNull(section);
        assertTrue("12345".equals(section.get("portNumber")));
        ini = null;

        executeTarget("test2");
        ini = new Ini(new File("PCTASBroker/test9/ubroker.properties"));
        section = ini.get("UBroker.AS.Test");
        assertNotNull(section);
        assertTrue("12346".equals(section.get("portNumber")));
    }

    @Test(groups = {"v10"})
    public void testAttributes1() throws InvalidFileFormatException, IOException {
        configureProject("PCTASBroker/test10/build.xml");
        executeTarget("test");

        Ini ini = new Ini(new File("PCTASBroker/test10/ubroker.properties"));
        Section section = ini.get("UBroker.AS.Test");
        assertNotNull(section);
        assertEquals(section.get("operatingMode", String.class), "State-reset");
        assertEquals(section.get("autoStart", String.class), "1");
        assertEquals(section.get("initialSrvrInstance", String.class), "4");
        assertEquals(section.get("minSrvrInstance", String.class), "3");
        assertEquals(section.get("maxSrvrInstance", String.class), "5");
        assertEquals(section.get("registerNameServer", String.class), "1");
        assertEquals(section.get("appserviceNameList", String.class), "Test");
        assertEquals(section.get("registrationMode", String.class), "Register-IP");
        assertEquals(section.get("controllingNameServer", String.class), "NS1");
        assertEquals(section.get("brkrLogAppend", String.class), "1");
        assertEquals(section.get("srvrLogAppend", String.class), "0");
    }

    @Test(groups = {"v10"})
    public void testAttributes2() throws InvalidFileFormatException, IOException {
        configureProject("PCTASBroker/test11/build.xml");
        executeTarget("test");

        Ini ini = new Ini(new File("PCTASBroker/test11/ubroker.properties"));
        Section section = ini.get("UBroker.AS.Test");
        assertNotNull(section);
        assertEquals(section.get("srvrActivateProc", String.class), "activate.p");
        assertEquals(section.get("srvrDeactivateProc", String.class), "deactivate.p");
        assertEquals(section.get("srvrConnectProc", String.class), "connect.p");
        assertEquals(section.get("srvrDisconnProc", String.class), "disconnect.p");
        assertEquals(section.get("srvrStartupProc", String.class), "startup.p");
        assertEquals(section.get("srvrShutdownProc", String.class), "shutdown.p");

        // Checking PROPATH
        // XXX Ini4J escapes strings with \ so this doesn't work on Win
//        String propath = section.get("PROPATH", String.class);
//        StringTokenizer tokenizer = new StringTokenizer(propath,
//                Character.toString(File.pathSeparatorChar));
//        assertEquals(tokenizer.countTokens(), 2, "Wrong number of entries in PROPATH");
//        assertTrue((tokenizer.nextToken().endsWith("build")), "First entry should be build");
//        assertTrue((tokenizer.nextToken().endsWith("build2")), "Second entry should be build2");

        String startup = section.get("srvrStartupParam", String.class);
        assertTrue((startup.indexOf("-db myDB") != -1), "Unable to find myDB connection");
        assertTrue((startup.indexOf("-db myDB2") != -1), "Unable to find myDB2 connection");
    }

    @Test(groups = {"v10"}, expectedExceptions = BuildException.class)
    public void testForbiddenAttributes1() {
        configureProject("PCTASBroker/test12/build.xml");
        executeTarget("test");
    }

    @Test(groups = {"v10"}, expectedExceptions = BuildException.class)
    public void testForbiddenAttributes2() {
        configureProject("PCTASBroker/test13/build.xml");
        executeTarget("test");
    }

    @Test(groups = {"v10"}, expectedExceptions = BuildException.class)
    public void testForbiddenAttributes3() {
        configureProject("PCTASBroker/test14/build.xml");
        executeTarget("test");
    }

    @Test(groups = {"v10"}, expectedExceptions = BuildException.class)
    public void testForbiddenAttributes4() {
        configureProject("PCTASBroker/test15/build.xml");
        executeTarget("test");
    }

    @Test(groups = {"v10"}, expectedExceptions = BuildException.class)
    public void testDoubleCreate() {
        configureProject("PCTASBroker/test16/build.xml");
        executeTarget("test1");
        executeTarget("test2");
    }
}
