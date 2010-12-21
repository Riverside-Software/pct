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

/**
 * Class for testing PCTWSBroker task
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
 */
public class PCTWSBrokerTest extends BuildFileTestNg {
    public PCTWSBrokerTest(String name) {
        super(name);
    }

    @BeforeSuite
    public void setUp() {
        configureProject("PCTWSBroker.xml");

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
        while ((i < sections.length) && (!sections[i].equals("UBroker.WS.Test"))) {
            i = i + 1;
        }
        assertTrue((i < sections.length), "Section UBroker.WS.Test not found");
    }

    @Test
    public void testLogging() {
        executeTarget("TestLogging");

        File f1 = new File("sandbox/ubroker.properties");
        assertTrue(f1.exists(), "ubroker.properties not found");

        INIFile ini = new INIFile(f1.getAbsolutePath());
        Map map = ini.getProperties("UBroker.WS.Test");
        assertTrue((map != null), "No properties (null) in UBroker.WS.Test");
        String prop = ini.getStringProperty("UBroker.WS.Test", "brokerLogFile");
        assertTrue((prop != null), "brokerLogFile -- Property not found");
        prop = ini.getStringProperty("UBroker.WS.Test", "brkrLoggingLevel");
        assertTrue((prop != null), "brkrLoggingLevel -- Property not found");
        prop = ini.getStringProperty("UBroker.WS.Test", "srvrLoggingLevel");
        assertTrue((prop != null), "srvrLoggingLevel -- Property not found");
        prop = ini.getStringProperty("UBroker.WS.Test", "srvrLogFile");
        assertTrue((prop != null), "srvrLogFile -- Property not found");
    }

    // TODO This test should throw BuildException -- See how error should be trapped...
    // AFAIR, it threw an error on v9, but not on v10
    // public void testDoubleCreate() {
    // executeTarget("TestDoubleCreate-Part1");
    // expectBuildException("TestDoubleCreate-Part2",
    // "Already created, should throw BuilException");
    // }

    @Test
    public void testAttributes1() {
        executeTarget("TestAttributes-1");

        File f1 = new File("sandbox/ubroker.properties");
        assertTrue(f1.exists(), "ubroker.properties not found");

        INIFile ini = new INIFile(f1.getAbsolutePath());
        assertTrue((ini.getStringProperty("UBroker.WS.Test", "autoStart")
                .equals("1")), "Wrong autoStart");
        assertTrue((ini.getStringProperty("UBroker.WS.Test",
                "initialSrvrInstance").equals("4")), "Wrong initialPool");
        assertTrue((ini.getStringProperty("UBroker.WS.Test", "minSrvrInstance")
                .equals("3")), "Wrong minPool");
        assertTrue((ini.getStringProperty("UBroker.WS.Test", "maxSrvrInstance")
                .equals("5")), "Wrong maxPool");
        assertTrue((ini.getStringProperty("UBroker.WS.Test",
                "registerNameServer").equals("1")), "Wrong registerNameServer");
        assertTrue((ini.getStringProperty("UBroker.WS.Test",
                "appserviceNameList").equalsIgnoreCase("Test")), "Wrong appserviceNameList");
        assertTrue((ini.getStringProperty("UBroker.WS.Test",
                "registrationMode").equalsIgnoreCase("Register-IP")), "Wrong registrationMode");
        assertTrue((ini.getStringProperty("UBroker.WS.Test",
                "controllingNameServer").equalsIgnoreCase("NS1")), "Wrong controllingNameServer");
        assertTrue((ini.getStringProperty("UBroker.WS.Test", "brkrLogAppend").equalsIgnoreCase("1")), "Wrong brkrLogAppend");
        assertTrue((ini.getStringProperty("UBroker.WS.Test", "srvrLogAppend").equalsIgnoreCase("0")), "Wrong srvrLogAppend");
    }

}
