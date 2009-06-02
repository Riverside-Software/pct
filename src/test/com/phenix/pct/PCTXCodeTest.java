/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) 2002 The Apache Software Foundation. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *  1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *  3. The end-user documentation included with the redistribution, if any,
 * must include the following acknowlegement: "This product includes software
 * developed by the Apache Software Foundation (http://www.apache.org/)."
 * Alternately, this acknowlegement may appear in the software itself, if and
 * wherever such third-party acknowlegements normally appear.
 *  4. The names "Ant" and "Apache Software Foundation" must not be used to
 * endorse or promote products derived from this software without prior written
 * permission. For written permission, please contact apache@apache.org.
 *  5. Products derived from this software may not be called "Apache" nor may
 * "Apache" appear in their names without prior written permission of the
 * Apache Group.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * APACHE SOFTWARE FOUNDATION OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many individuals
 * on behalf of the Apache Software Foundation. For more information on the
 * Apache Software Foundation, please see <http://www.apache.org/> .
 */
package com.phenix.pct;

import org.apache.tools.ant.BuildFileTest;
import org.apache.tools.ant.taskdefs.Delete;
import org.apache.tools.ant.taskdefs.Mkdir;

import java.io.File;


/**
 * Class for testing PCTXCode task
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
 */
public class PCTXCodeTest extends BuildFileTest {
    public PCTXCodeTest(String name) {
        super(name);
    }

    public void setUp() {
        configureProject("PCTXCode.xml");

        // Creates a sandbox directory to play with
        Mkdir mkdir = new Mkdir();
        mkdir.setProject(this.getProject());
        mkdir.setDir(new File("sandbox"));
        mkdir.execute();
        mkdir.setDir(new File("build"));
        mkdir.execute();
    }

    public void tearDown() {
        Delete del = new Delete();
        del.setProject(this.project);
        del.setDir(new File("sandbox"));
        del.execute();
        del.setDir(new File("build"));
        del.execute();
    }

    public void test1() {
        expectBuildException("test1", "No destDir defined");
    }

    public void test2() {
        executeTarget("test2");
    }

    public void test3() {
        executeTarget("test3");

        File f = new File("build/test.p");
        assertTrue(f.exists());
    }

    public void test4() {
        executeTarget("test4");

        File f = new File("build/sandbox/foo/test.p");
        assertTrue(f.exists());
    }

    public void test5() {
        executeTarget("test5");

        File f = new File("build/test.p");
        assertTrue(f.exists());

        assertTrue(f.delete());
        executeTarget("test5bis");
        assertTrue(f.exists());
    }

    public void test6() {
    	executeTarget("test6");

    	File f = new File("build/test.p");
    	File f2 = new File("build/test2.p");

    	assertTrue(f.exists());
    	assertTrue(f2.exists());
    	// Rough test, but it should work
    	assertTrue(f.length() != f2.length());
    }
    
    public void test7() {
    	executeTarget("test7init");
    	executeTarget("test7");
    	expectBuildException("test7bis", "RETURN 1");
    }
    
    public void test8() {
        executeTarget("test8init");
        executeTarget("test8");
        
        File f1 = new File("sandbox/test.p");
        File f2 = new File("sandbox/test2.p");
        File f3 = new File("build/test.p");
        File f4 = new File("build/test2.p");
        
        assertTrue(f1.lastModified() < f3.lastModified());
        assertTrue(f1.length() != f3.length());
        assertTrue(f2.lastModified() < f4.lastModified());
        assertTrue(f2.length() != f4.length());
    }
}
