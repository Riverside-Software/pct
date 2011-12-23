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

import static org.testng.Assert.assertFalse;
import static org.testng.Assert.assertTrue;

import org.apache.tools.ant.BuildException;
import org.testng.annotations.Test;

import java.io.File;

/**
 * Class for testing PCTRun task
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET </a>
 */
public class PCTRunTest extends BuildFileTestNg {

    @Test(expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("PCTRun/test1/build.xml");
        executeTarget("test");
    }

    @Test
    public void test2() {
        configureProject("PCTRun/test2/build.xml");
        executeTarget("test");
    }

    @Test(expectedExceptions = BuildException.class)
    public void test3() {
        configureProject("PCTRun/test3/build.xml");
        executeTarget("test");
    }

    @Test(expectedExceptions = BuildException.class)
    public void test4() {
        File f = new File("nofile.p");
        assertFalse(f.exists());

        configureProject("PCTRun/test4/build.xml");
        executeTarget("test");
    }

    @Test(expectedExceptions = BuildException.class)
    public void test5() {
        configureProject("PCTRun/test5/build.xml");
        executeTarget("test");
    }

    @Test(expectedExceptions = BuildException.class)
    public void test6() {
        configureProject("PCTRun/test6/build.xml");
        executeTarget("test");
    }

    @Test
    public void test7() {
        configureProject("PCTRun/test7/build.xml");
        executeTarget("test");
    }

    @Test
    public void test8() {
        configureProject("PCTRun/test8/build.xml");
        executeTarget("test");
    }

    @Test
    public void test9() {
        configureProject("PCTRun/test9/build.xml");
        expectLog("test1", "Hello PCT");
        expectLog("test2", "Hello");
    }

    @Test
    public void test10() {
        configureProject("PCTRun/test10/build.xml");
        expectLog("test1", "01/01/2060");
        expectLog("test2", "01/01/1960");
    }

    @Test
    public void test11() {
        configureProject("PCTRun/test11/build.xml");
        executeTarget("test");
    }

    @Test
    public void test12() {
        configureProject("PCTRun/test12/build.xml");
        expectLog("test1", "123.456");
        expectLog("test2", "123,456");
        expectLog("test3", "123,456");
        expectLog("test4", "123.456");
    }

    @Test
    public void test13() {
        configureProject("PCTRun/test13/build.xml");
        expectLog("test1", "This is dir1");
        expectLog("test2", "This is dir2");
    }

    @Test(groups = { "no-unix" } )
    public void test14() {
        // Sous Windows uniquement
        configureProject("PCTRun/test14/build.xml");
        expectLog("test1", "-prop1=prop1 -prop2=prop2 -prop3='prop3'");
        expectLog("test2", "-prop1=prop1 -prop2=prop2 -prop3=prop3");
        expectLog("test3", "-prop1=prop1 -prop2=prop2 -prop3=prop 3");
    }

    @Test(expectedExceptions = BuildException.class)
    public void test15() {
        configureProject("PCTRun/test15/build.xml");
        executeTarget("test15");
    }

    @Test
    public void test16() {
        configureProject("PCTRun/test16/build.xml");
        executeTarget("test");
        File f = new File("PCTRun/test16/subdir/Output.txt");
        assertTrue(f.exists());
    }

    @Test
    public void test17() {
        configureProject("PCTRun/test17/build.xml");
        executeTarget("test");
        File f = new File("PCTRun/test17/sandbox/subdir2/Output.txt");
        assertTrue(f.exists());
    }

    @Test
    public void test18() {
        configureProject("PCTRun/test18/build.xml");
        expectLog("test", "utf-8");
    }

    @Test(expectedExceptions = BuildException.class)
    public void test19() {
        configureProject("PCTRun/test19/build.xml");
        executeTarget("test");
    }

    @Test(expectedExceptions = BuildException.class)
    public void test20() {
        configureProject("PCTRun/test20/build.xml");
        executeTarget("test");
    }

    @Test
    public void test21() {
        configureProject("PCTRun/test21/build.xml");
        executeTarget("test");
        File f = new File("PCTRun/test21/sandbox/profiler.out");
        assertTrue(f.exists());
    }

    @Test
    public void test22() {
        configureProject("PCTRun/test22/build.xml");
        expectLog("test", "Message with spaces");
    }

    @Test
    public void test23() {
        configureProject("PCTRun/test23/build.xml");
        executeTarget("test");
        File f = new File("PCTRun/test23/temp dir/test.txt");
        assertTrue(f.exists());
    }

    @Test
    public void test24() {
        configureProject("PCTRun/test24/build.xml");
        expectLog("test", "TEST");
    }

    @Test
    public void test25() {
        configureProject("PCTRun/test25/build.xml");
        executeTarget("test");
    }

    @Test
    public void test26() {
        configureProject("PCTRun/test26/build.xml");
        executeTarget("test");
    }

    @Test
    public void test27() {
        configureProject("PCTRun/test27/build.xml");
        executeTarget("test");
    }

    @Test
    public void test28() {
        configureProject("PCTRun/test28/build.xml");
        executeTarget("test");
    }

    @Test
    public void test29() {
        configureProject("PCTRun/test29/build.xml");
        executeTarget("test");
    }

    @Test
    public void test30() {
        configureProject("PCTRun/test30/build.xml");
        expectBuildException("test1", "Shouldn't work");
        executeTarget("test2");
        executeTarget("test3");
    }

    @Test
    public void test31() {
        configureProject("PCTRun/test31/build.xml");
        expectBuildException("test1", "Shouldn't work");
        executeTarget("test2");
    }
    
    @Test
    public void test32() {
        configureProject("PCTRun/test32/build.xml");
        assertPropertyUnset("myResult");
        executeTarget("test1");
        assertPropertyEquals("myResult", "0");
        
        assertPropertyUnset("myNewResult");
        executeTarget("test2");
        assertPropertyEquals("myNewResult", "17");
    }
    
    @Test
    public void test33() {
        configureProject("PCTRun/test33/build.xml");
        expectBuildException("test1", "No output parameter defined");

        assertPropertyUnset("firstParam");
        executeTarget("test2");
        assertPropertyEquals("firstParam", "PCT");
    }

    @Test
    public void test34() {
        configureProject("PCTRun/test34/build.xml");
        assertPropertyUnset("firstParam");
        assertPropertyUnset("secondParam");
        assertPropertyUnset("thirdParam");
        assertPropertyUnset("fourthParam");
        
        executeTarget("test");
        assertPropertyEquals("firstParam", "PCT1");
        assertPropertyEquals("secondParam", "PCT2");
        assertPropertyEquals("thirdParam", "PCT3");
        assertPropertyEquals("fourthParam", "PCT4");
    }
    
    @Test
    public void test35() {
        configureProject("PCTRun/test35/build.xml");
        executeTarget("test1");
        expectBuildException("test2", "Not in propath");
    }

    @Test
    public void test36() {
        configureProject("PCTRun/test36/build.xml");
        executeTarget("base");
        expectBuildException("test1", "Incorrect alias");
        executeTarget("test2");
        executeTarget("test3");
        executeTarget("test4");
    }
}