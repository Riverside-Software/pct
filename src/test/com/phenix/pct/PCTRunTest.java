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


/**
 * Class for testing PCTRun task
 * @author <a href="mailto:gilles.querret@nerim.net">Gilles QUERRET</a>
 */
public class PCTRunTest extends BuildFileTest {
    public PCTRunTest(String name) {
        super(name);
    }

    /**
     * Sets up the fixture
     */
    public void setUp() {
        configureProject("src/test/PCTRun.xml");

        // Creates a sandbox directory to play with
        Mkdir mkdir = new Mkdir();
        mkdir.setProject(this.getProject());
        mkdir.setDir(new File("src/test/sandbox"));
        mkdir.execute();
    }

    /**
     * Tears down the fixture
     */
    public void tearDown() {
        Delete del = new Delete();
        del.setProject(this.getProject());
        del.setDir(new File("src/test/sandbox"));
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
        File f = new File("src/test/sandbox/not_existing.p");
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
}
