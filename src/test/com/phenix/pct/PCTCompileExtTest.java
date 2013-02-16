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

import static org.testng.Assert.assertEquals;
import static org.testng.Assert.assertTrue;
import static org.testng.Assert.assertFalse;

import org.apache.tools.ant.BuildException;
import org.testng.annotations.Test;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;

/**
 * Class for testing PCTCompileExt task
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
 */
public class PCTCompileExtTest extends BuildFileTestNg {

    @Test(groups={"v10", "v11"}, expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("PCTCompileExt/test1/build.xml");
        executeTarget("test");
    }

    @Test(groups={"v10", "v11"})
    public void test2() {
        configureProject("PCTCompileExt/test2/build.xml");
        executeTarget("test");
    }

    @Test(groups={"v10", "v11"})
    public void test3() {
        configureProject("PCTCompileExt/test3/build.xml");
        executeTarget("test");

        File f = new File("PCTCompileExt/test3/build/test.r");
        assertTrue(f.exists());
    }

    @Test(groups={"v10", "v11"})
    public void test3bis() {
        configureProject("PCTCompileExt/test3bis/build.xml");
        expectBuildException("test", "Compilation should fail");

        File f = new File("PCTCompileExt/test3bis/build/test.r");
        assertFalse(f.exists());
    }

    @Test(groups={"v10", "v11"})
    public void test4() {
        configureProject("PCTCompileExt/test4/build.xml");
        executeTarget("test");

        File f1 = new File("PCTCompileExt/test4/build/test.r");
        File f2 = new File("PCTCompileExt/test4/build2/test.r");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        assertTrue(f2.length() < f1.length());
    }

    @Test(groups={"v10", "v11"})
    public void test5() {
        configureProject("PCTCompileExt/test5/build.xml");
        executeTarget("test");

        File f = new File("PCTCompileExt/test5/build/wizz~~'~.r");
        assertTrue(f.exists());
    }

    @Test(groups={"v10", "v11"})
    public void test6() {
        configureProject("PCTCompileExt/test6/build.xml");
        executeTarget("test1");

        File f = new File("PCTCompileExt/test6/build/test.r");
        long mod = f.lastModified();
        executeTarget("test2");
        assertTrue(mod == f.lastModified());
    }

    @Test(groups={"v10", "v11"})
    public void test7() {
        configureProject("PCTCompileExt/test7/build.xml");
        executeTarget("test1");

        File f = new File("PCTCompileExt/test7/build/test.r");
        long mod = f.lastModified();
        executeTarget("test2");
        assertTrue(mod < f.lastModified());
    }

    @Test(groups={"v10", "v11"})
    public void test8() {
        configureProject("PCTCompileExt/test8/build.xml");
        executeTarget("test1");

        File f = new File("PCTCompileExt/test8/build/test.r");
        long mod = f.lastModified();
        executeTarget("test2");
        assertTrue(mod < f.lastModified());
    }

    @Test(groups={"v10", "v11"})
    public void test9() {
        configureProject("PCTCompileExt/test9/build.xml");
        executeTarget("test1");

        File f = new File("PCTCompileExt/test9/build/test.r");
        long mod = f.lastModified();
        executeTarget("test2");
        assertTrue(mod < f.lastModified());
    }

    @Test(groups={"v10", "v11"})
    public void test10() {
        configureProject("PCTCompileExt/test10/build.xml");
        executeTarget("test1");

        File f = new File("PCTCompileExt/test10/build/test.r");
        long mod = f.lastModified();
        executeTarget("test2");
        assertTrue(mod < f.lastModified());
    }

    @Test(groups={"v10", "v11"})
    public void test11() {
        configureProject("PCTCompileExt/test11/build.xml");

        expectBuildException("test", "Second task should not be launched");
        File f = new File("PCTCompileExt/test11/build/test2.r");
        assertFalse(f.exists());
        
        executeTarget("test2");
        File f2 = new File("PCTCompileExt/test11/build2/test2.r");
        assertTrue(f2.exists());
    }

    @Test(groups={"v10", "v11"})
    public void test12() {
        configureProject("PCTCompileExt/test12/build.xml");
        expectBuildException("test1", "File with underscore");
        File f = new File("PCTCompileExt/test12/build/test.r");
        assertFalse(f.exists());
        executeTarget("test2");
        assertTrue(f.exists());
    }

    @Test(groups={"v10", "v11"})
    public void test13() {
        configureProject("PCTCompileExt/test13/build.xml");
        executeTarget("test1");

        File f = new File("PCTCompileExt/test13/build/test.r");
        long mod = f.lastModified();
        executeTarget("test2");
        assertTrue(mod < f.lastModified());
    }

    @Test(groups={"v10", "v11"})
    public void test14() {
        configureProject("PCTCompileExt/test14/build.xml");
        executeTarget("base");
        executeTarget("test1");

        File f1 = new File("PCTCompileExt/test14/build/test.r");
        File f2 = new File("PCTCompileExt/test14/build/test2.r");
        assertTrue(f1.exists());
        assertTrue(f2.exists());

        long mod1 = f1.lastModified();
        long mod2 = f2.lastModified();
        executeTarget("update");
        executeTarget("test2");
        assertTrue(mod1 < f1.lastModified());
        assertTrue(mod2 < f2.lastModified());
    }

    @Test(groups={"v10", "v11"})
    public void test15() {
        configureProject("PCTCompileExt/test15/build.xml");
        executeTarget("base");
        executeTarget("test1");

        File f = new File("PCTCompileExt/test15/build/test.r");
        assertTrue(f.exists());

        long mod = f.lastModified();
        executeTarget("test2");
        assertTrue(mod == f.lastModified());
    }

    @Test(groups={"v10", "v11"})
    public void test16() {
        configureProject("PCTCompileExt/test16/build.xml");
        executeTarget("xcode");
        File f1 = new File("PCTCompileExt/test16/src/xcode/test.p");
        assertTrue(f1.exists());
        executeTarget("test");

        File f2 = new File("PCTCompileExt/test16/build/std/test.r");
        assertTrue(f2.exists());
        File f3 = new File("PCTCompileExt/test16/build/xcode/test.r");
        assertTrue(f3.exists());
    }

    @Test(groups={"v10", "v11"})
    public void test17() {
        configureProject("PCTCompileExt/test17/build.xml");
        executeTarget("xcode");
        File f1 = new File("PCTCompileExt/test17/src/xcode/test.p");
        assertTrue(f1.exists());
        expectBuildException("test1", "No XCodeKey");

        executeTarget("test2");
        File f2 = new File("PCTCompileExt/test17/build/xcode/test.r");
        assertFalse(f2.exists());
        File f3 = new File("PCTCompileExt/test17/build2/xcode/test.r");
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

    @Test(groups={"v10", "v11"})
    public void test19() {
        configureProject("PCTCompileExt/test19/build.xml");
        executeTarget("test1");

        File f1 = new File("PCTCompileExt/test19/build/test.r");
        File f2 = new File("PCTCompileExt/test19/build/.pct/test.p.crc");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        long mod1 = f1.lastModified();
        long mod2 = f2.lastModified();
        executeTarget("test2");
        assertTrue(mod1 < f1.lastModified());
        assertTrue(mod2 < f2.lastModified());
    }

    @Test(groups={"v10", "v11"})
    public void test20() {
        configureProject("PCTCompileExt/test20/build.xml");
        executeTarget("test1");

        File dotR = new File("PCTCompileExt/test20/build/test.r");
        File f1 = new File("PCTCompileExt/test20/build/.pct/test.p");
        File f2 = new File("PCTCompileExt/test20/build/.pct/test.p.preprocess");
        File f3 = new File("PCTCompileExt/test20/build/.pct/test.p.dbg");
        File f4 = new File("PCTCompileExt/test20/build/.pct/test.p.xref");
        File f5 = new File("PCTCompileExt/test20/debug/test.p");
        File f6 = new File("PCTCompileExt/test20/debug/dir1/dir2/test.p");

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

        executeTarget("test3");
        assertTrue(f5.exists(), "Unable to find debug-listing file");
        assertTrue(f6.exists(), "Unable to find debug-listing file");
    }

    @Test(groups={"v10", "v11"})
    public void test21() {
        configureProject("PCTCompileExt/test21/build.xml");
        executeTarget("test");

        File f1 = new File("PCTCompileExt/test21/build/package/testclass.r");
        assertTrue(f1.exists());
    }

    @Test(groups={"v10", "v11"})
    public void test22() {
        configureProject("PCTCompileExt/test22/build.xml");
        executeTarget("test");

        File f1 = new File("PCTCompileExt/test22/build/X.r");
        assertTrue(f1.exists());
        File f2 = new File("PCTCompileExt/test22/build/Y.r");
        assertTrue(f2.exists());
        File f3 = new File("PCTCompileExt/test22/build/.pct/X.cls.crc");
        assertTrue(f3.exists());
        File f4 = new File("PCTCompileExt/test22/build/.pct/Y.cls.crc");
        assertTrue(f4.exists());
    }

    @Test(groups = { "v10", "v11", "win" } )
    public void test23() {
        configureProject("PCTCompileExt/test23/build.xml");
        expectBuildException("test1", "Should fail - No stream-io");

        File f = new File("PCTCompileExt/test23/build/test.r");
        assertFalse(f.exists());
        executeTarget("test2");
        assertTrue(f.exists());
    }

    @Test(groups= {"all"})
    public void test25() {
        configureProject("PCTCompileExt/test25/build.xml");
        executeTarget("test");

        File f = new File("PCTCompileExt/test25/build/test.r");
        assertTrue(f.exists());
    }

    // SHOULD be working on Linux, but doesn't...
    @Test(groups= {"win"})
    public void test26() {
        configureProject("PCTCompileExt/test26/build.xml");
        executeTarget("test");

        File f = new File("PCTCompileExt/test26/build/Ö_example.r");
        assertTrue(f.exists());
    }

    @Test(groups= {"v10", "v11"})
    public void test27() {
        configureProject("PCTCompileExt/test27/build.xml");
        executeTarget("test");

        File f1 = new File("PCTCompileExt/test27/build/eu/rssw/pct/A.r");
        assertTrue(f1.exists());
        File f2 = new File("PCTCompileExt/test27/build/eu/rssw/pct/B.r");
        assertTrue(f2.exists());
        File f3 = new File("PCTCompileExt/test27/build/eu/rssw/pct/X.r");
        assertTrue(f3.exists());
        File f4 = new File("PCTCompileExt/test27/build/eu/rssw/pct/Y.r");
        assertTrue(f4.exists());
        File f5 = new File("PCTCompileExt/test27/build/eu/rssw/pct/Z.r");
        assertTrue(f5.exists());
        File f6 = new File("PCTCompileExt/test27/build/.pct/eu/rssw/pct/Z.cls.hierarchy");
        assertTrue(f6.exists());
        assertTrue(f6.length() > 0);
    }

    @Test(groups= {"win"})
    public void test28() {
        configureProject("PCTCompileExt/test28/build.xml");
        executeTarget("build");
        
        File f1 = new File("PCTCompileExt/test28/src-tty/test.p");
        assertTrue(f1.exists());
        assertTrue(f1.length() > 0);
        File f2 = new File("PCTCompileExt/test28/src-gui/test.p");
        assertTrue(f2.exists());
        assertTrue(f2.length() > 0);
        File f3 = new File("PCTCompileExt/test28/src-tty/sub1/sub2/sub3/test.p");
        assertTrue(f3.exists());
        File f4 = new File("PCTCompileExt/test28/src-tty/sub1/sub2/sub4/test.p");
        assertTrue(f4.exists());

        executeTarget("test");
        String str1 = getProject().getProperty("test28-tty");
        assertTrue(str1.equals("TTY"));
        String str2 = getProject().getProperty("test28-gui");
        assertTrue(str2.startsWith("MS-WIN"));
    }

    @Test(groups = {"all"})
    public void test29() {
        configureProject("PCTCompileExt/test29/build.xml");
        executeTarget("build");
        
        File f1 = new File("PCTCompileExt/test29/build1/test.r");
        assertTrue(f1.exists());
        File f2 = new File("PCTCompileExt/test29/build2/test.r");
        assertTrue(f2.exists());
        
        executeTarget("test1");
        executeTarget("test2");
        executeTarget("test3");

        String test1Inc = getProject().getProperty("test1-inc");
        // Absolute paths, so it should be found
        File ff = new File(test1Inc);
        assertTrue(ff.exists());
        String test1Main = getProject().getProperty("test1-main");
        File ff2 =new File(test1Main);
        assertTrue(ff2.exists());
        
        String test2Inc = getProject().getProperty("test2-inc");
        assertEquals(test2Inc.replace('\\', '/'), "inc/test.i");
        String test2Main = getProject().getProperty("test2-main");
        assertEquals(test2Main.replace('\\', '/'), "src/test.p");

        String test3Main = getProject().getProperty("test3-main");
        assertEquals(test3Main.replace('\\', '/'), "src/foo/bar/test.p");
        String test3Inc1 = getProject().getProperty("test3-inc1");
        assertEquals(test3Inc1.replace('\\', '/'), "src/foo/foo.i");
        String test3Inc2 = getProject().getProperty("test3-inc2");
        assertEquals(test3Inc2.replace('\\', '/'), "inc/foo/bar.i");
    }

    @Test(groups = { "v10", "v11" } )
    public void test101() {
        configureProject("PCTCompileExt/test101/build.xml");
        executeTarget("test");

        File f1 = new File("PCTCompileExt/test101/build/test1.p");
        assertTrue(f1.exists());
        File f2 = new File("PCTCompileExt/test101/build/test2.p");
        assertTrue(f2.exists());
    }

    @Test(groups = { "v10", "v11" } )
    public void test102() {
        configureProject("PCTCompileExt/test102/build.xml");
        executeTarget("test");

        File f1 = new File("PCTCompileExt/test102/build/testrenamed.r");
        File f2 = new File("PCTCompileExt/test102/build/test2renamed.r");
        File f3 = new File("PCTCompileExt/test102/build/triggers/trigger.r");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        assertTrue(f3.exists());
    }

    @Test(groups = { "v10", "v11" } )
    public void test103() throws IOException {
        File inputDir = new File("PCTCompileExt/test103/src");
        File srcFile = new File("PCTCompileExt/test103/query-tester.w");
        for (int ii = 0; ii < 10; ii++) {
            for (int jj = 0; jj < 10; jj++) {
                for (int kk = 0; kk < 10; kk++) {
                    copy(srcFile, new File(inputDir, "test" + ii + jj + kk + ".p"));
                }
            }
        }
        configureProject("PCTCompileExt/test103/build.xml");
        executeTarget("test");

        File f = new File("PCTCompileExt/test103/build/test000.r");
        assertTrue(f.exists());
        f = new File("PCTCompileExt/test103/build/test999.r");
        assertTrue(f.exists());
    }

    @Test(groups = { "v10", "v11" } )
    public void test104() throws IOException {
        configureProject("PCTCompileExt/test104/build.xml");
        executeTarget("base");

        expectBuildException("test1", "Invalid alias");
        executeTarget("test2");
        executeTarget("test3");
        executeTarget("test4");
        File f1 = new File("PCTCompileExt/test104/build/proc.r");
        File f2 = new File("PCTCompileExt/test104/build/proc2.r");
        File f3 = new File("PCTCompileExt/test104/build/proc3.r");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        assertTrue(f3.exists());
    }

    @Test(groups = { "v10", "v11" } )
    public void test105() throws IOException {
        configureProject("PCTCompileExt/test105/build.xml");
        executeTarget("base");
        executeTarget("test1");
        expectBuildException("test2", "No DB connection, should throw BuildException");

        File f1 = new File("PCTCompileExt/test105/build/test.r");
        File f2 = new File("PCTCompileExt/test105/build2/test.r");
        assertTrue(f1.exists());
        assertFalse(f2.exists());
    }

    private static void copy(File src, File dst) throws IOException {
        // Create channel on the source
        FileChannel srcChannel = new FileInputStream(src).getChannel();

        // Create channel on the destination
        FileChannel dstChannel = new FileOutputStream(dst).getChannel();

        // Copy file contents from source to destination
        dstChannel.transferFrom(srcChannel, 0, srcChannel.size());

        // Close the channels
        srcChannel.close();
        dstChannel.close();

    }

}
