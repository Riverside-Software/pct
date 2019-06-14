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

import static org.testng.Assert.assertEquals;
import static org.testng.Assert.assertNotNull;

import org.apache.tools.ant.BuildException;
import org.ini4j.Ini;
import org.ini4j.InvalidFileFormatException;
import org.ini4j.Profile.Section;
import org.testng.annotations.Test;

import java.io.File;
import java.io.IOException;

/**
 * Class for testing PCTWSBroker task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTWSBrokerTest extends BuildFileTestNg {

    @Test(groups = {"v10"}, expectedExceptions = BuildException.class)
    public void testFailure1() {
        configureProject("PCTWSBroker/test1/build.xml");
        executeTarget("test");
    }

    @Test(groups = {"v10"}, expectedExceptions = BuildException.class)
    public void testFailure2() {
        configureProject("PCTWSBroker/test2/build.xml");
        executeTarget("test");
    }

    @Test(groups = {"v10"})
    public void testSimplestTest() throws InvalidFileFormatException, IOException {
        configureProject("PCTWSBroker/test3/build.xml");
        executeTarget("test");

        Ini ini = new Ini(new File("PCTWSBroker/test3/ubroker.properties"));
        assertNotNull(ini.get("UBroker.WS.Test"));
    }

    @Test(groups = {"v10"})
    public void testLogging() throws InvalidFileFormatException, IOException {
        configureProject("PCTWSBroker/test4/build.xml");
        executeTarget("test");

        Ini ini = new Ini(new File("PCTWSBroker/test4/ubroker.properties"));
        Section section = ini.get("UBroker.WS.Test");
        assertNotNull(section.get("brokerLogFile"));
        assertNotNull(section.get("brkrLoggingLevel"));
        assertNotNull(section.get("srvrLoggingLevel"));
        assertNotNull(section.get("srvrLogFile"));
    }

    @Test(groups = {"v10"})
    public void testAttributes1() throws InvalidFileFormatException, IOException {
        configureProject("PCTWSBroker/test5/build.xml");
        executeTarget("test");

        Ini ini = new Ini(new File("PCTWSBroker/test5/ubroker.properties"));
        Section section = ini.get("UBroker.WS.Test");
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
    public void test6() throws InvalidFileFormatException, IOException {
        configureProject("PCTWSBroker/test6/build.xml");
        executeTarget("test");

        Ini ini = new Ini(new File("PCTWSBroker/test6/ubroker.properties"));
        Section section = ini.get("UBroker.WS.Test");
        assertEquals(section.get("srvrStartupParam", String.class), "-q -p web/objects/web-disp.p -db sp2k");
    }

}
