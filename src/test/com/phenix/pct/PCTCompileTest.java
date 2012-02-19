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
import static org.testng.Assert.assertFalse;

import org.apache.tools.ant.BuildException;
import org.testng.annotations.Test;

import java.io.File;

/**
 * Class for testing PCTCompile task
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
 */
public class PCTCompileTest extends BuildFileTestNg {

    @Test(groups= {"all"}, expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("PCTCompile/test1/build.xml");
        executeTarget("test");
    }

    @Test(groups= {"all"})
    public void test2() {
        configureProject("PCTCompile/test2/build.xml");
        executeTarget("test");
    }

    @Test(groups= {"all"})
    public void test3() {
        configureProject("PCTCompile/test3/build.xml");
        executeTarget("test");

        File f = new File("PCTCompile/test3/build/test.r");
        assertTrue(f.exists());
    }

    @Test(groups= {"all"})
    public void test3bis() {
        configureProject("PCTCompile/test3bis/build.xml");
        expectBuildException("test", "Compilation should fail");

        File f = new File("PCTCompile/test3bis/build/test.r");
        assertFalse(f.exists());
    }

    @Test(groups= {"all"})
    public void test4() {
        configureProject("PCTCompile/test4/build.xml");
        executeTarget("test");

        File f1 = new File("PCTCompile/test4/build/test.r");
        File f2 = new File("PCTCompile/test4/build2/test.r");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        assertTrue(f2.length() < f1.length());
    }

    @Test(groups= {"all"})
    public void test5() {
        configureProject("PCTCompile/test5/build.xml");
        executeTarget("test");

        File f = new File("PCTCompile/test5/build/wizz~~'~.r");
        assertTrue(f.exists());
    }

    @Test(groups= {"all"})
    public void test6() {
        configureProject("PCTCompile/test6/build.xml");
        executeTarget("test1");

        File f = new File("PCTCompile/test6/build/test.r");
        long mod = f.lastModified();
        executeTarget("test2");
        assertTrue(mod == f.lastModified());
    }

    @Test(groups= {"all"})
    public void test7() {
        configureProject("PCTCompile/test7/build.xml");
        executeTarget("test1");

        File f = new File("PCTCompile/test7/build/test.r");
        long mod = f.lastModified();
        executeTarget("test2");
        assertTrue(mod < f.lastModified());
    }

    @Test(groups= {"all"})
    public void test8() {
        configureProject("PCTCompile/test8/build.xml");
        executeTarget("test1");

        File f = new File("PCTCompile/test8/build/test.r");
        long mod = f.lastModified();
        executeTarget("test2");
        assertTrue(mod < f.lastModified());
    }

    @Test(groups= {"all"})
    public void test9() {
        configureProject("PCTCompile/test9/build.xml");
        executeTarget("test1");

        File f = new File("PCTCompile/test9/build/test.r");
        long mod = f.lastModified();
        executeTarget("test2");
        assertTrue(mod < f.lastModified());
    }

    @Test(groups= {"all"})
    public void test10() {
        configureProject("PCTCompile/test10/build.xml");
        executeTarget("test1");

        File f = new File("PCTCompile/test10/build/test.r");
        long mod = f.lastModified();
        executeTarget("test2");
        assertTrue(mod < f.lastModified());
    }

    @Test(groups= {"all"})
    public void test11() {
        configureProject("PCTCompile/test11/build.xml");
        expectBuildException("test", "Second task should not be launched");

        File f = new File("PCTCompile/test11/build/test2.r");
        assertFalse(f.exists());
    }

    @Test(groups= {"all"})
    public void test12() {
        configureProject("PCTCompile/test12/build.xml");
        expectBuildException("test1", "File with underscore");
        File f = new File("PCTCompile/test12/build/test.r");
        assertFalse(f.exists());
        executeTarget("test2");
        assertTrue(f.exists());
    }

    @Test(groups= {"all"})
    public void test13() {
        configureProject("PCTCompile/test13/build.xml");
        executeTarget("test1");

        File f = new File("PCTCompile/test13/build/test.r");
        long mod = f.lastModified();
        executeTarget("test2");
        assertTrue(mod < f.lastModified());
    }

    @Test(groups= {"all"})
    public void test14() {
        configureProject("PCTCompile/test14/build.xml");
        executeTarget("base");
        executeTarget("test1");

        File f1 = new File("PCTCompile/test14/build/test.r");
        File f2 = new File("PCTCompile/test14/build/test2.r");
        assertTrue(f1.exists());
        assertTrue(f2.exists());

        long mod1 = f1.lastModified();
        long mod2 = f2.lastModified();
        executeTarget("update");
        executeTarget("test2");
        assertTrue(mod1 < f1.lastModified());
        assertTrue(mod2 < f2.lastModified());
    }

    @Test(groups= {"all"})
    public void test15() {
        configureProject("PCTCompile/test15/build.xml");
        executeTarget("base");
        executeTarget("test1");

        File f = new File("PCTCompile/test15/build/test.r");
        assertTrue(f.exists());

        long mod = f.lastModified();
        executeTarget("test2");
        assertTrue(mod == f.lastModified());
    }

    @Test(groups= {"v10", "v11"})
    public void test16() {
        configureProject("PCTCompile/test16/build.xml");
        executeTarget("xcode");
        File f1 = new File("PCTCompile/test16/src/xcode/test.p");
        assertTrue(f1.exists());
        executeTarget("test");

        File f2 = new File("PCTCompile/test16/build/std/test.r");
        assertTrue(f2.exists());
        File f3 = new File("PCTCompile/test16/build/xcode/test.r");
        assertTrue(f3.exists());
    }

    @Test(groups= {"v10", "v11"})
    public void test17() {
        configureProject("PCTCompile/test17/build.xml");
        executeTarget("xcode");
        File f1 = new File("PCTCompile/test17/src/xcode/test.p");
        assertTrue(f1.exists());
        expectBuildException("test1", "No XCodeKey");

        executeTarget("test2");
        File f2 = new File("PCTCompile/test17/build/xcode/test.r");
        assertFalse(f2.exists());
        File f3 = new File("PCTCompile/test17/build2/xcode/test.r");
        assertTrue(f3.exists());
    }

    // @Test
    // public void test18() {
    // executeTarget("test18init");
    // executeTarget("test18");
    //
    // File f = new File("build/sandbox/test.r");
    // File f2 = new File("build/sandbox/test2.r");
    // assertTrue(f.exists());
    // assertTrue(f2.exists());
    //
    // long mod = f.lastModified();
    // long mod2 = f2.lastModified();
    // executeTarget("test18bis");
    // assertTrue(mod < f.lastModified());
    // assertTrue(mod2 < f2.lastModified());
    // }

    @Test(groups= {"all"})
    public void test19() {
        configureProject("PCTCompile/test19/build.xml");
        executeTarget("test1");

        File f1 = new File("PCTCompile/test19/build/test.r");
        File f2 = new File("PCTCompile/test19/build/.pct/test.p.crc");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        long mod1 = f1.lastModified();
        long mod2 = f2.lastModified();
        executeTarget("test2");
        assertTrue(mod1 < f1.lastModified());
        assertTrue(mod2 < f2.lastModified());
    }

    @Test(groups= {"all"})
    public void test20() {
        configureProject("PCTCompile/test20/build.xml");
        executeTarget("test1");

        File dotR = new File("PCTCompile/test20/build//test.r");
        File f1 = new File("PCTCompile/test20/build/.pct/test.p");
        File f2 = new File("PCTCompile/test20/build/.pct/test.p.preprocess");
        File f3 = new File("PCTCompile/test20/build/.pct/test.dbg");
        File f4 = new File("PCTCompile/test20/build/.pct/test.p.xref");
        assertTrue(dotR.exists());
        assertFalse(f1.exists());
        assertFalse(f2.exists());
        assertFalse(f3.exists());
        assertFalse(f4.exists());

        executeTarget("test2");
        assertTrue(f1.exists(), "Unable to find listing file");
        assertTrue(f2.exists(), "Unable to find preprocess file");
        assertTrue(f3.exists(), "Unable to find debug-listing file");
        assertTrue(f4.exists(), "Unable to find xref file");
        assertTrue((f4.length() > 0), "Empty xref file");
    }

    @Test(groups= {"v10", "v11"})
    public void test21() {
        configureProject("PCTCompile/test21/build.xml");
        executeTarget("test");

        File f1 = new File("PCTCompile/test21/build/package/testclass.r");
        assertTrue(f1.exists());
    }

    @Test(groups= {"v10", "v11"})
    public void test22() {
        configureProject("PCTCompile/test22/build.xml");
        executeTarget("test");

        File f1 = new File("PCTCompile/test22/build/X.r");
        assertTrue(f1.exists());
        File f2 = new File("PCTCompile/test22/build/Y.r");
        assertTrue(f2.exists());
        File f3 = new File("PCTCompile/test22/build/.pct/X.cls.crc");
        assertTrue(f3.exists());
        File f4 = new File("PCTCompile/test22/build/.pct/Y.cls.crc");
        assertTrue(f4.exists());
    }

    @Test(groups= {"win"})
    public void test23() {
        configureProject("PCTCompile/test23/build.xml");
        expectBuildException("test1", "Should fail - No stream-io");

        File f = new File("PCTCompile/test23/build/test.r");
        assertFalse(f.exists());
        executeTarget("test2");
        assertTrue(f.exists());
    }

    @Test(groups= {"all"})
    public void test24() {
        configureProject("PCTCompile/test24/build.xml");

        File f = new File("PCTCompile/test24/build/test.r");
        assertFalse(f.exists());

        executeTarget("test1");
        assertFalse(f.exists());
        executeTarget("test2");
        assertTrue(f.exists());
    }

}
