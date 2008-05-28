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

import org.apache.tools.ant.BuildFileTest;
import org.apache.tools.ant.taskdefs.Delete;
import org.apache.tools.ant.taskdefs.Mkdir;

import java.io.File;


/**
 * Class for testing PCTCompileExt task
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
 */
public class PCTCompileExtTest extends BuildFileTest {
    public PCTCompileExtTest(String name) {
        super(name);
    }

    public void setUp() {
        configureProject("PCTCompileExt.xml");

        // Creates a sandbox directory to play with
        Mkdir mkdir = new Mkdir();
        mkdir.setProject(this.getProject());
        mkdir.setDir(new File("sandbox"));
        mkdir.execute();
    }

    public void tearDown() {
        Delete del = new Delete();
        del.setProject(this.project);
        del.setDir(new File("build"));
        del.execute();
        del.setDir(new File("sandbox"));
        del.execute();
        del.setDir(new File("xcode"));
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

        File f = new File("build/sandbox/test.r");
        assertTrue(f.exists());
    }

    public void test3bis() {
        expectBuildException("test3bis", "Compilation should fail");

        File f = new File("build/sandbox/temp.r");
        assertFalse(f.exists());
    }

    public void test4() {
        long size1 = 0;
        long size2 = 0;
        executeTarget("test4");

        File f = new File("build/sandbox/test.r");
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

        File f = new File("build/sandbox/wizz~~'~.r");
        assertTrue(f.exists());
    }

    public void test6() {
        executeTarget("test6init");
        executeTarget("test6");

        File f = new File("build/sandbox/temp.r");
        long mod = f.lastModified();
        executeTarget("test6bis");
        assertTrue(mod == f.lastModified());
    }

    public void test7() {
        executeTarget("test7init");
        executeTarget("test7");

        File f = new File("build/sandbox/temp.r");
        long mod = f.lastModified();
        executeTarget("test7bis");
        assertTrue(mod < f.lastModified());
    }

    public void test8() {
        executeTarget("test8init");
        executeTarget("test8");

        File f = new File("build/sandbox/temp.r");
        long mod = f.lastModified();
        executeTarget("test8bis");
        assertTrue(mod < f.lastModified());
    }

    public void test9() {
        executeTarget("test9init");
        executeTarget("test9");

        File f = new File("build/sandbox/temp.r");
        long mod = f.lastModified();
        executeTarget("test9bis");
        assertTrue(mod < f.lastModified());
    }

    public void test10() {
        executeTarget("test10init");
        executeTarget("test10");

        File f = new File("build/sandbox/temp.r");
        long mod = f.lastModified();
        executeTarget("test10bis");
        assertTrue(mod < f.lastModified());
    }

    public void test11() {
        executeTarget("test11init");
        expectBuildException("test11", "Second task should not be launched");

        File f = new File("build/sandbox/temp2.r");
        assertFalse(f.exists());
    }

    public void test12() {
        File f = new File("build/sandbox/temp.r");
        executeTarget("test12init");
        expectBuildException("test12", "File with underscore");
        assertFalse(f.exists());
        executeTarget("test12bis");
        assertTrue(f.exists());
    }

    public void test13() {
        executeTarget("test13init");
        executeTarget("test13");

        File f = new File("build/sandbox/temp.r");
        long mod = f.lastModified();
        executeTarget("test13bis");
        assertTrue(mod < f.lastModified());
    }

    public void test14() {
        executeTarget("test14init");
        executeTarget("test14");

        File f = new File("build/sandbox/test.r");
        File f2 = new File("build/sandbox/test2.r");
        assertTrue(f.exists());
        assertTrue(f2.exists());

        long mod = f.lastModified();
        long mod2 = f2.lastModified();
        executeTarget("test14bis");
        assertTrue(mod < f.lastModified());
        assertTrue(mod2 < f2.lastModified());
    }

    public void test15() {
        executeTarget("test15init");
        executeTarget("test15");

        File f = new File("build/sandbox/test.r");
        assertTrue(f.exists());

        long mod = f.lastModified();
        executeTarget("test15bis");
        assertTrue(mod == f.lastModified());
    }
    
    public void test16() {
    	executeTarget("test16init");
    	executeTarget("test16");
        File f = new File("build/sandbox/temp.r");
        assertTrue(f.exists());
        File f2 = new File("build/xcode/temp.r");
        assertTrue(f2.exists());
    }
    
    public void test17() {
    	executeTarget("test17init");
    	expectBuildException("test17-part1", "Should fail - No key specified");
    	executeTarget("test17-part2");
    	File f = new File("build/xcode/temp.r");
    	assertTrue(f.exists());
    }
    
    public void test18() {
        executeTarget("test18init");
        executeTarget("test18");

        File f = new File("build/sandbox/test.r");
        File f2 = new File("build/sandbox/test2.r");
        assertTrue(f.exists());
        assertTrue(f2.exists());

        long mod = f.lastModified();
        long mod2 = f2.lastModified();
        executeTarget("test18bis");
        assertTrue(mod < f.lastModified());
        assertTrue(mod2 < f2.lastModified());
    }

    public void test19() {
        executeTarget("test19init");
        executeTarget("test19");

        File f1 = new File("build/sandbox/temp.r");
        File f2 = new File("build/.pct/sandbox/temp.p.crc");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        long mod1 = f1.lastModified();
        long mod2 = f2.lastModified();
        executeTarget("test19bis");
        assertTrue(mod1 < f1.lastModified());
        assertTrue(mod2 < f2.lastModified());
    }

    public void test20() {
        executeTarget("test20-init");
        executeTarget("test20-part1");
        
        File dotR = new File("build/sandbox/temp.r");
        File f1 = new File("build/.pct/sandbox/temp.p");
        File f2 = new File("build/.pct/sandbox/temp.p.preprocess");
        File f3 = new File("build/.pct/sandbox/temp.dbg");
        assertFalse(f1.exists());
        assertFalse(f2.exists());
        assertFalse(f3.exists());
        dotR.delete();
        executeTarget("test20-part2");
        assertTrue("Unable to find listing file", f1.exists());
        assertTrue("Unable to find preprocess file", f2.exists());
        assertTrue("Unable to find debug-listing file", f3.exists());
    }
    
    public void test21() {
        executeTarget("test21");

        File f1 = new File("build/test.p");
        File f2 = new File("build/test2.p");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
    }

    public void test22() {
        executeTarget("test22");

        File f1 = new File("build/sandbox/testrenamed.r");
        File f2 = new File("build/sandbox/test2renamed.r");
        File f3 = new File("build/triggers/sandbox/trigger.r");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        assertTrue(f3.exists());
    }
   
    public void test23() {
        executeTarget("test23");
        File f1 = new File("build/package/package/testclass.r");
        assertFalse(f1.exists());
        File f2 = new File("build/package/testclass.r");
        assertTrue(f2.exists());
    }

}
