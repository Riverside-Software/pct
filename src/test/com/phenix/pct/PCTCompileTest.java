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

import java.io.File;


/**
 * Class for testing PCTCompile task
 * @author <a href="mailto:gilles.querret@nerim.net">Gilles QUERRET</a>
 */
public class PCTCompileTest extends BuildFileTest {
    public PCTCompileTest(String name) {
        super(name);
    }

    public void setUp() {
        configureProject("src/test/PCTCompile.xml");
    }

    public void tearDown() {
        Delete del = new Delete();
        del.setProject(this.project);
        del.setDir(new File("src/test/build"));
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

        File f = new File("src/test/build/progress/simple.r");
        assertTrue(f.exists());
    }

    public void test3bis() {
        expectBuildException("test3bis", "Compilation should fail");

        File f = new File("src/test/build/progress/temp.r");
        assertFalse(f.exists());
        executeTarget("test3post");
    }

    public void test4() {
        long size1 = 0;
        long size2 = 0;
        executeTarget("test4");

        File f = new File("src/test/build/progress/simple.r");
        assertTrue(f.exists());
        size1 = f.length();
        assertTrue(f.delete());
        executeTarget("test4bis");
        assertTrue(f.exists());
        size2 = f.length();
        assertTrue(size2 < size1);
    }

    public void test5() {
        executeTarget("test5");

        File f = new File("src/test/build/progress/wizz~~'~.r");
        assertTrue(f.exists());
    }

    public void test6() {
        executeTarget("test6init");
        executeTarget("test6");

        File f = new File("src/test/build/progress/temp.r");
        long mod = f.lastModified();
        executeTarget("test6bis");
        assertTrue(mod == f.lastModified());
    }

    public void test7() {
        executeTarget("test7init");
        executeTarget("test7");

        File f = new File("src/test/build/progress/temp.r");
        long mod = f.lastModified();
        executeTarget("test7bis");
        assertTrue(mod < f.lastModified());
    }

    public void test8() {
        executeTarget("test8init");
        executeTarget("test8");

        File f = new File("src/test/build/progress/temp.r");
        long mod = f.lastModified();
        executeTarget("test8bis");
        assertTrue(mod < f.lastModified());
    }

    public void test9() {
        executeTarget("test9init");
        executeTarget("test9");

        File f = new File("src/test/build/progress/temp.r");
        long mod = f.lastModified();
        executeTarget("test9bis");
        assertTrue(mod < f.lastModified());
    }

    public void test10() {
        executeTarget("test10init");
        executeTarget("test10");

        File f = new File("src/test/build/progress/temp.r");
        long mod = f.lastModified();
        executeTarget("test10bis");
        assertTrue(mod < f.lastModified());
    }

    public void test11() {
        executeTarget("test11init");
        expectBuildException("test11", "Second task should not be launched");
        executeTarget("test11post");

        File f = new File("src/test/build/progress/temp2.r");
        assertFalse(f.exists());
    }

    public void test12() {
        File f = new File("src/test/build/progress/temp.r");
        executeTarget("test12init");
        expectBuildException("test12", "File with underscore");
        assertFalse(f.exists());
        executeTarget("test12bis");
        assertTrue(f.exists());
        executeTarget("test12post");
    }
}
