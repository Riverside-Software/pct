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

import static org.testng.Assert.assertTrue;

import org.apache.tools.ant.taskdefs.Copy;
import org.apache.tools.ant.taskdefs.Delete;
import org.apache.tools.ant.taskdefs.Mkdir;
import org.testng.annotations.AfterSuite;
import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;

import com.freeware.inifiles.INIFile;

import java.io.File;
import java.util.Map;
import java.util.StringTokenizer;

/**
 * Class for testing PCTASBroker task
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
 * @version $Revision: 453 $
 */
public class PCTASBrokerTest extends BuildFileTestNg {
    public PCTASBrokerTest(String name) {
        super(name);
    }

    @BeforeSuite
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

    @AfterSuite
    public void tearDown() {
        super.tearDown();
        Delete del = new Delete();
        del.setProject(this.project);
        del.setDir(new File("sandbox"));
        del.execute();
    }

    @Test
    public void testFailure1() {
        expectBuildException("failure1", "Missing parameter, should throw BuildException");
    }

    @Test
    public void testFailure2() {
        expectBuildException("failure2", "Missing parameter, should throw BuildException");
    }

    @Test
    public void testSimplestTest() {
        executeTarget("SimplestTest");

        File f1 = new File("sandbox/ubroker.properties");
        assertTrue(f1.exists(), "ubroker.properties not found");

        INIFile ini = new INIFile(f1.getAbsolutePath());
        String[] sections = ini.getAllSectionNames();
        int i = 0;
        while ((i < sections.length) && (!sections[i].equals("UBroker.AS.Test"))) {
            i = i + 1;
        }
        assertTrue((i < sections.length), "Section UBroker.AS.Test not found");
    }

    @Test
    public void testUidNone() {
        executeTarget("TestUidNone");

        File f1 = new File("sandbox/ubroker.properties");
        assertTrue(f1.exists(), "ubroker.properties not found");

        INIFile ini = new INIFile(f1.getAbsolutePath());
        Map map = ini.getProperties("UBroker.AS.Test");
        assertTrue((map != null), "No properties (null) in UBroker.AS.Test");
        assertTrue(!map.containsKey("uuid"), "Found uuid section !");
    }

    @Test
    public void testUidAuto() {
        executeTarget("TestUidAuto");

        File f1 = new File("sandbox/ubroker.properties");
        assertTrue(f1.exists(), "ubroker.properties not found");

        INIFile ini = new INIFile(f1.getAbsolutePath());
        Map map = ini.getProperties("UBroker.AS.Test");
        assertTrue((map != null), "No properties (null) in UBroker.AS.Test");
        assertTrue(map.containsKey("uuid"), "uuid section not found !");
        String uuid = ini.getStringProperty("UBroker.AS.Test", "uuid");
        assertTrue((uuid != null), "Null uuid");
        assertTrue((uuid.length() < 30), "Weird UUID pattern...");
    }

    @Test
    public void testUid() {
        executeTarget("TestUid");

        File f1 = new File("sandbox/ubroker.properties");
        assertTrue(f1.exists(), "ubroker.properties not found");

        INIFile ini = new INIFile(f1.getAbsolutePath());
        Map map = ini.getProperties("UBroker.AS.Test");
        assertTrue((map != null), "No properties (null) in UBroker.AS.Test");
        assertTrue(map.containsKey("uuid"), "uuid section not found !");
        String uuid = ini.getStringProperty("UBroker.AS.Test", "uuid");
        assertTrue((uuid != null), "Null uuid");
        assertTrue((uuid.equals("3fb5744ad58ca1b0:239137:10a178402e4:-8000")), "Wrong UUID");
    }

    @Test
    public void testLogging() {
        executeTarget("TestLogging");

        File f1 = new File("sandbox/ubroker.properties");
        assertTrue(f1.exists(), "ubroker.properties not found");

        INIFile ini = new INIFile(f1.getAbsolutePath());
        Map map = ini.getProperties("UBroker.AS.Test");
        assertTrue((map != null), "No properties (null) in UBroker.AS.Test");
        String prop = ini.getStringProperty("UBroker.AS.Test", "brokerLogFile");
        assertTrue((prop != null), "brokerLogFile -- Property not found");
        prop = ini.getStringProperty("UBroker.AS.Test", "brkrLoggingLevel");
        assertTrue((prop != null), "brkrLoggingLevel -- Property not found");
        prop = ini.getStringProperty("UBroker.AS.Test", "srvrLoggingLevel");
        assertTrue((prop != null), "srvrLoggingLevel -- Property not found");
        prop = ini.getStringProperty("UBroker.AS.Test", "srvrLogFile");
        assertTrue((prop != null), "srvrLogFile -- Property not found");
    }

    @Test
    public void testApsvDelete() {
        executeTarget("TestApsvDelete");

        File f1 = new File("sandbox/ubroker.properties");
        assertTrue(f1.exists(), "ubroker.properties not found");

        INIFile ini = new INIFile(f1.getAbsolutePath());
        String[] sections = ini.getAllSectionNames();
        int i = 0;
        while ((i < sections.length) && (!sections[i].equals("UBroker.AS.Test"))) {
            i = i + 1;
        }
        assertTrue((i == sections.length), "Section UBroker.AS.Test not found");
    }

    @Test
    public void testApsvUpdate() {
        executeTarget("TestApsvUpdate-Part1");

        File f1 = new File("sandbox/ubroker.properties");
        assertTrue(f1.exists(), "ubroker.properties not found");

        INIFile ini = new INIFile(f1.getAbsolutePath());
        String portNumber = ini.getStringProperty("UBroker.AS.Test", "portNumber");
        assertTrue((portNumber != null), "Null portNumber (before update)");
        assertTrue((portNumber.equals("12345")), "Wrong portNumber (before update)");
        ini = null;
        
        executeTarget("TestApsvUpdate-Part2");
        ini = new INIFile(f1.getAbsolutePath());
        portNumber = ini.getStringProperty("UBroker.AS.Test", "portNumber");
        assertTrue((portNumber != null), "Null portNumber (after update)");
        assertTrue((portNumber.equals("12346")), "Wrong portNumber (after update)");
    }

    // TODO This test should throw BuildException -- See how error should be trapped...
    // AFAIR, it threw an error on v9, but not on v10
//    public void testDoubleCreate() {
//        executeTarget("TestDoubleCreate-Part1");
//        expectBuildException("TestDoubleCreate-Part2",
//                "Already created, should throw BuilException");
//    }

    public void testAttributes1() {
        executeTarget("TestAttributes-1");
        
        File f1 = new File("sandbox/ubroker.properties");
        assertTrue(f1.exists(), "ubroker.properties not found");

        INIFile ini = new INIFile(f1.getAbsolutePath());
        assertTrue((ini.getStringProperty("UBroker.AS.Test", "operatingMode").equals("State-reset")), "Wrong operatingMode");
        assertTrue((ini.getStringProperty("UBroker.AS.Test", "autoStart").equals("1")), "Wrong autoStart");
        assertTrue((ini.getStringProperty("UBroker.AS.Test", "initialSrvrInstance").equals("4")), "Wrong initialPool");
        assertTrue((ini.getStringProperty("UBroker.AS.Test", "minSrvrInstance").equals("3")), "Wrong minPool");
        assertTrue((ini.getStringProperty("UBroker.AS.Test", "maxSrvrInstance").equals("5")), "Wrong maxPool");
        assertTrue((ini.getStringProperty("UBroker.AS.Test", "registerNameServer").equals("1")), "Wrong registerNameServer");
        assertTrue((ini.getStringProperty("UBroker.AS.Test", "appserviceNameList").equalsIgnoreCase("Test")), "Wrong appserviceNameList");
        assertTrue((ini.getStringProperty("UBroker.AS.Test", "registrationMode").equalsIgnoreCase("Register-IP")), "Wrong registrationMode");
        assertTrue((ini.getStringProperty("UBroker.AS.Test", "controllingNameServer").equalsIgnoreCase("NS1")), "Wrong controllingNameServer");
        assertTrue((ini.getStringProperty("UBroker.AS.Test", "brkrLogAppend").equalsIgnoreCase("1")), "Wrong brkrLogAppend");
        assertTrue((ini.getStringProperty("UBroker.AS.Test", "srvrLogAppend").equalsIgnoreCase("0")), "Wrong srvrLogAppend");
    }

    public void testAttributes2() {
        executeTarget("TestAttributes-2");
        
        File f1 = new File("sandbox/ubroker.properties");
        assertTrue(f1.exists(), "ubroker.properties not found");

        INIFile ini = new INIFile(f1.getAbsolutePath());
        assertTrue((ini.getStringProperty("UBroker.AS.Test", "srvrActivateProc").equals("activate.p")), "Wrong activateProc");
        assertTrue((ini.getStringProperty("UBroker.AS.Test", "srvrDeactivateProc").equals("deactivate.p")), "Wrong deactivateProc");
        assertTrue((ini.getStringProperty("UBroker.AS.Test", "srvrConnectProc").equals("connect.p")), "Wrong connectProc");
        assertTrue((ini.getStringProperty("UBroker.AS.Test", "srvrDisconnProc").equals("disconnect.p")), "Wrong disconnectProc");
        assertTrue((ini.getStringProperty("UBroker.AS.Test", "srvrStartupProc").equals("startup.p")), "Wrong startupProc");
        assertTrue((ini.getStringProperty("UBroker.AS.Test", "srvrShutdownProc").equals("shutdown.p")), "Wrong shutdownProc");

        // Checking PROPATH
        String propath = ini.getStringProperty("UBroker.AS.Test", "PROPATH");
        StringTokenizer tokenizer = new StringTokenizer(propath, Character.toString(File.pathSeparatorChar));
        assertTrue((tokenizer.countTokens() == 2), "Wrong number of entries in PROPATH");
        assertTrue((tokenizer.nextToken().endsWith("build")), "First entry should be build");
        assertTrue((tokenizer.nextToken().endsWith("build2")), "Second entry should be build2");

        String startup = ini.getStringProperty("UBroker.AS.Test", "srvrStartupParam");
        assertTrue((startup.indexOf("-db myDB") != -1), "Unable to find myDB connection");
        assertTrue((startup.indexOf("-db myDB2") != -1), "Unable to find myDB2 connection");
    }

    @Test
    public void testForbiddenAttributes1() {
        expectBuildException("TestForbiddenAttributes-1", "Forbidden attribute : procedure");
    }

    @Test
    public void testForbiddenAttributes2() {
        expectBuildException("TestForbiddenAttributes-2", "Forbidden attribute : graphicalMode");
    }

    @Test
    public void testForbiddenAttributes3() {
        expectBuildException("TestForbiddenAttributes-3", "Forbidden attribute : debugPCT");
    }

    @Test
    public void testForbiddenAttributes4() {
        expectBuildException("TestForbiddenAttributes-4", "Forbidden attribute : baseDir");
    }
}
