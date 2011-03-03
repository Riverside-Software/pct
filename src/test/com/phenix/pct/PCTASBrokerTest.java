/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) 2002 The Apache Software Foundation.  All rights
 * reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution, if
 *    any, must include the following acknowlegement:
 *       "This product includes software developed by the
 *        Apache Software Foundation (http://www.apache.org/)."
 *    Alternately, this acknowlegement may appear in the software itself,
 *    if and wherever such third-party acknowlegements normally appear.
 *
 * 4. The names "Ant" and "Apache Software
 *    Foundation" must not be used to endorse or promote products derived
 *    from this software without prior written permission. For written
 *    permission, please contact apache@apache.org.
 *
 * 5. Products derived from this software may not be called "Apache"
 *    nor may "Apache" appear in their names without prior written
 *    permission of the Apache Group.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE APACHE SOFTWARE FOUNDATION OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation.  For more
 * information on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 */
package com.phenix.pct;

import static org.testng.Assert.assertFalse;
import static org.testng.Assert.assertEquals;
import static org.testng.Assert.assertNotNull;
import static org.testng.Assert.assertNull;
import static org.testng.Assert.assertTrue;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.Copy;
import org.apache.tools.ant.taskdefs.Delete;
import org.apache.tools.ant.taskdefs.Mkdir;
import org.ini4j.Ini;
import org.ini4j.Profile.Section;
import org.ini4j.InvalidFileFormatException;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

import java.io.File;
import java.io.IOException;
import java.util.StringTokenizer;

/**
 * Class for testing PCTASBroker task
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
 * @version $Revision: 453 $
 */
public class PCTASBrokerTest extends BuildFileTestNg {

    @BeforeMethod
    public void setUp() {
        configureProject("PCTASBroker.xml");

        // Creates a sandbox directory to play with
        Mkdir mkdir = new Mkdir();
        mkdir.setProject(this.getProject());
        mkdir.setDir(new File("sandbox"));
        mkdir.execute();

        // And copy sample properties files to play with
        Copy copy = new Copy();
        copy.setProject(this.getProject());
        copy.setFile(new File("ubroker.template"));
        copy.setTofile(new File("sandbox/ubroker.properties"));
        copy.execute();
        copy.setFile(new File("conmgr.template"));
        copy.setTofile(new File("sandbox/conmgr.properties"));
        copy.execute();
    }

    @AfterMethod
    public void tearDown() {
        super.tearDown();
        Delete del = new Delete();
        del.setProject(this.project);
        del.setDir(new File("sandbox"));
        del.execute();
    }

    @Test(expectedExceptions=BuildException.class)
    public void testFailure1() {
        executeTarget("failure1");
    }

    @Test(expectedExceptions=BuildException.class)
    public void testFailure2() {
        executeTarget("failure2");
    }

    @Test
    public void testSimplestTest() throws InvalidFileFormatException, IOException {
        executeTarget("SimplestTest");

        Ini ini = new Ini(new File("sandbox/ubroker.properties"));
        assertNotNull(ini.get("UBroker.AS.Test"));
    }

    @Test
    public void testUidNone() throws InvalidFileFormatException, IOException {
        executeTarget("TestUidNone");

        Ini ini = new Ini(new File("sandbox/ubroker.properties"));
        Section section = ini.get("UBroker.AS.Test");
        assertNotNull(section);
        assertFalse(section.containsKey("uuid"));
    }

    @Test
    public void testUidAuto() throws InvalidFileFormatException, IOException {
        executeTarget("TestUidAuto");

        Ini ini = new Ini(new File("sandbox/ubroker.properties"));
        Section section = ini.get("UBroker.AS.Test");
        assertNotNull(section);
        assertTrue(section.containsKey("uuid"));
        assertNotNull(section.get("uuid"), "Null uuid");
        assertTrue((section.get("uuid", String.class).length() < 30), "Weird UUID pattern...");
    }

    @Test
    public void testUid() throws InvalidFileFormatException, IOException {
        executeTarget("TestUid");

        Ini ini = new Ini(new File("sandbox/ubroker.properties"));
        Section section = ini.get("UBroker.AS.Test");
        assertNotNull(section);
        assertTrue(section.containsKey("uuid"));
        assertNotNull(section.get("uuid"), "Null uuid");
        assertTrue(section.get("uuid", String.class).equals("3fb5744ad58ca1b0:239137:10a178402e4:-8000"), "Wrong UUID");
    }

    @Test
    public void testLogging() throws InvalidFileFormatException, IOException {
        executeTarget("TestLogging");

        Ini ini = new Ini(new File("sandbox/ubroker.properties"));
        Section section = ini.get("UBroker.AS.Test");
        assertNotNull(section.get("brokerLogFile"));
        assertNotNull(section.get("brkrLoggingLevel"));
        assertNotNull(section.get("srvrLoggingLevel"));
        assertNotNull(section.get("srvrLogFile"));
    }

    @Test
    public void testApsvDelete() throws InvalidFileFormatException, IOException {
        executeTarget("TestApsvDelete");

        Ini ini = new Ini(new File("sandbox/ubroker.properties"));
        assertNull(ini.get("UBroker.AS.Test"));
    }

    @Test
    public void testApsvUpdate() throws InvalidFileFormatException, IOException {
        executeTarget("TestApsvUpdate-Part1");

        Ini ini = new Ini(new File("sandbox/ubroker.properties"));
        Section section = ini.get("UBroker.AS.Test");
        assertTrue("12345".equals(section.get("portNumber")));
        ini = null;
        
        executeTarget("TestApsvUpdate-Part2");
        ini = new Ini(new File("sandbox/ubroker.properties"));
        section = ini.get("UBroker.AS.Test");
        assertTrue("12346".equals(section.get("portNumber")));
    }

    // TODO This test should throw BuildException -- See how error should be trapped...
    // AFAIR, it threw an error on v9, but not on v10
//    public void testDoubleCreate() {
//        executeTarget("TestDoubleCreate-Part1");
//        expectBuildException("TestDoubleCreate-Part2",
//                "Already created, should throw BuilException");
//    }

    public void testAttributes1() throws InvalidFileFormatException, IOException {
        executeTarget("TestAttributes-1");
        
        Ini ini = new Ini(new File("sandbox/ubroker.properties"));
        Section section = ini.get("UBroker.AS.Test");
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

    public void testAttributes2() throws InvalidFileFormatException, IOException {
        executeTarget("TestAttributes-2");
        
        Ini ini = new Ini(new File("sandbox/ubroker.properties"));
        Section section = ini.get("UBroker.AS.Test");
        assertEquals(section.get("srvrActivateProc", String.class), "activate.p");
        assertEquals(section.get("srvrDeactivateProc", String.class), "deactivate.p");
        assertEquals(section.get("srvrConnectProc", String.class), "connect.p");
        assertEquals(section.get("srvrDisconnProc", String.class), "disconnect.p");
        assertEquals(section.get("srvrStartupProc", String.class), "startup.p");
        assertEquals(section.get("srvrShutdownProc", String.class), "shutdown.p");

        // Checking PROPATH
        String propath = section.get("PROPATH", String.class);
        StringTokenizer tokenizer = new StringTokenizer(propath, Character.toString(File.pathSeparatorChar));
        assertEquals(tokenizer.countTokens(), 2, "Wrong number of entries in PROPATH");
        assertTrue((tokenizer.nextToken().endsWith("build")), "First entry should be build");
        assertTrue((tokenizer.nextToken().endsWith("build2")), "Second entry should be build2");

        String startup = section.get("srvrStartupParam", String.class);
        assertTrue((startup.indexOf("-db myDB") != -1), "Unable to find myDB connection");
        assertTrue((startup.indexOf("-db myDB2") != -1), "Unable to find myDB2 connection");
    }

    @Test(expectedExceptions=BuildException.class)
    public void testForbiddenAttributes1() {
        executeTarget("TestForbiddenAttributes-1");
    }

    @Test(expectedExceptions=BuildException.class)
    public void testForbiddenAttributes2() {
        executeTarget("TestForbiddenAttributes-2");
    }

    @Test(expectedExceptions=BuildException.class)
    public void testForbiddenAttributes3() {
        executeTarget("TestForbiddenAttributes-3");
    }

    @Test(expectedExceptions=BuildException.class)
    public void testForbiddenAttributes4() {
        executeTarget("TestForbiddenAttributes-4");
    }
}
