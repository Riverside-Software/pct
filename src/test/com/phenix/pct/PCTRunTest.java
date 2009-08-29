/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) The Apache Software Foundation.  All rights
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

import org.apache.tools.ant.BuildFileTest;
import org.apache.tools.ant.taskdefs.Delete;
import org.apache.tools.ant.taskdefs.Mkdir;

import java.io.File;
import java.util.Locale;

/**
 * Class for testing PCTRun task
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET </a>
 */
public class PCTRunTest extends BuildFileTest {
    public PCTRunTest(String name) {
        super(name);
    }

    /**
     * Sets up the fixture
     */
    public void setUp() {
        configureProject("PCTRun.xml");

        // Creates a sandbox directory to play with
        Mkdir mkdir = new Mkdir();
        mkdir.setProject(this.getProject());
        mkdir.setDir(new File("sandbox"));
        mkdir.execute();
    }

    /**
     * Tears down the fixture
     */
    public void tearDown() throws Exception {
        super.tearDown();
        Delete del = new Delete();
        del.setProject(this.getProject());
        del.setDir(new File("sandbox"));
        del.execute();
    }

    /**
     * Attribute procedure should always be defined
     */
    public void test1() {
        expectBuildException("test1", "No procedure name defined");
    }

    /**
     * Very simple run, and exits properly
     */
    public void test2() {
        expectLog("test2", "Hello world!");
    }

    /**
     * Very simple run, and exits with error code
     */
    public void test3() {
        expectBuildException("test3", "Return value : 1");
    }

    /**
     * Procedure file not found : should throw BuildException
     */
    public void test4() {
        File f = new File("sandbox/not_existing.p");
        assertFalse(f.exists());
        expectBuildException("test4", "Procedure not existing");
    }

    /**
     * Non-numeric return value : should throw BuildException
     */
    public void test5() {
        expectBuildException("test5", "Return value not numeric");
    }

    /**
     * Procedure don't compile : should throw BuildException
     */
    public void test6() {
        expectBuildException("test6", "Impossible to compile file");
    }

    /**
     * Checks if PROPATH is correctly defined
     */
    public void test7() {
        executeTarget("test7");
    }

    /**
     * Checks if strings containing ~ and ' are escaped
     */
    public void test8() {
        executeTarget("test8");
    }

    /**
     * Tests -param attribute
     */
    public void test9() {
        executeTarget("test9init");
        expectLog("test9", "Hello PCT");
        expectLog("test9bis", "Hello");
    }

    /**
     * Tests -yy attribute
     */
    public void test10() {
        executeTarget("test10init");
        expectLog("test10", "01/01/2060");
        expectLog("test10bis", "01/01/1960");
    }

    /**
     * Tests RETURN statement with no return value
     */
    public void test11() {
        executeTarget("test11");
    }

    /**
     * Tests numsep and numdec parameters
     */
    public void test12() {
        executeTarget("test12-init");
        expectLog("test12-part1", "123.456");
        expectLog("test12-part2", "123,456");
        expectLog("test12-part3", "123,456");
        expectLog("test12-part4", "123.456");
    }

    /**
     * Tests propath order
     */
    public void test13() {
        executeTarget("test13-init");
        expectLog("test13-part1", "This is dir1");
        expectLog("test13-part2", "This is dir2");
    }

    /**
     * Tests parameter containing quotes and so on... Doesn't work on UNIX
     */
    public void test14() {
        if (System.getProperty("os.name").toLowerCase(Locale.US).indexOf("windows") > -1) {
            executeTarget("test14-init");
            expectLog("test14-1", "-prop1=prop1 -prop2=prop2 -prop3='prop3'");
            expectLog("test14-2", "-prop1=prop1 -prop2=prop2 -prop3=prop3");
            expectLog("test14-3", "-prop1=prop1 -prop2=prop2 -prop3=prop 3");
        }
    }

    public void test15() {
        expectBuildException("test15", "Cannot connect to database");
    }

    public void test16() {
        executeTarget("test16");
        File f = new File("sandbox/subdir/Output.txt");
        assertTrue(f.exists());
    }

    public void test17() {
        executeTarget("test17");
        File f = new File("sandbox/subdir2/Output.txt");
        assertTrue(f.exists());
    }

    /**
     * Run option test
     */
    public void test18() {
        expectLog("test18", "utf-8");
    }

    /**
     * Spaces in parameter, this should fail
     */
    public void test19() {
        expectBuildException("test19", "Should fail because of spaces");
    }

    /**
     * Name parameter is mandatory in PCTRunOption
     */
    public void test20() {
        expectBuildException("test20", "Name parameter is mandatory in PCTRunOption");
    }

    /**
     * Profiler should be started, and sandbox/profiler.out created
     */
    public void test21() {
        File f = new File("sandbox/profiler.out");
        executeTarget("test21");
        assertTrue(f.exists());
    }

    /**
     * Parameter should be in quotes
     */
    public void test22() {
        expectLog("test22", "Message with spaces");
    }

    /**
     * Temp dir with space
     */
    public void test23() {
        File f = new File("sandbox/temp dir/test.txt");
        assertFalse(f.exists());
        executeTarget("test23");
        assertTrue(f.exists());
    }

    /**
     * Parameter should be in quotes
     */
    public void test24() {
        executeTarget("test24-pre");
        expectLog("test24", "TEST");
    }

    /**
     * Parameters collection : simple test
     */
    public void test25() {
        executeTarget("test25");
    }

    /**
     * Parameters collection : quotes
     */
    public void test26() {
        executeTarget("test26");
    }

    /**
     * Parameters collection : tilde
     */
    public void test27() {
        executeTarget("test27");
    }

    /**
     * Parameters collection : not defined
     */
    public void test28() {
        executeTarget("test28");
    }

    /**
     * Parameters collection : duplicate values
     */
    public void test29() {
        executeTarget("test29");
    }

    /**
     * Using propath refid
     */
    public void test30() {
        executeTarget("test30-init");
        expectBuildException("test30-part1", "Shouldn't work");
        executeTarget("test30-part2");
        executeTarget("test30-part3");
    }

    /**
     * test failOnError attribute
     */
    public void test31() {
        expectBuildException("test31-a", "Shouldn't work");
        executeTarget("test31-b");
    }
    
    public void test32() {
        assertPropertyUnset("myResult");
        executeTarget("test32-a");
        assertPropertyEquals("myResult", "0");
        
        assertPropertyUnset("myNewResult");
        executeTarget("test32-b");
        assertPropertyEquals("myNewResult", "17");
    }
    
    public void test33() {
        expectBuildException("test33-a", "No output parameter defined");

        assertPropertyUnset("firstParam");
        executeTarget("test33-b");
        assertPropertyEquals("firstParam", "PCT");
    }

    public void test34() {
        assertPropertyUnset("firstParam");
        assertPropertyUnset("secondParam");
        assertPropertyUnset("thirdParam");
        assertPropertyUnset("fourthParam");
        executeTarget("test34");
        assertPropertyEquals("firstParam", "PCT1");
        assertPropertyEquals("secondParam", "PCT2");
        assertPropertyEquals("thirdParam", "PCT3");
        assertPropertyEquals("fourthParam", "PCT4");
    }
}