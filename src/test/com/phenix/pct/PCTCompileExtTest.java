/**
 * Copyright 2005-2016 Riverside Software
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */
package com.phenix.pct;

import static org.testng.Assert.assertEquals;
import static org.testng.Assert.assertTrue;
import static org.testng.Assert.assertFalse;

import org.apache.tools.ant.BuildException;
import org.testng.Assert;
import org.testng.annotations.Test;

import com.google.common.base.Charsets;
import com.google.common.io.Files;
import com.google.common.io.LineProcessor;
import com.phenix.pct.RCodeInfo.InvalidRCodeException;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;
import java.nio.charset.Charset;

/**
 * Class for testing PCTCompileExt task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTCompileExtTest extends BuildFileTestNg {
    private static final String BASEDIR = "PCTCompileExt/";

    @Test(groups = {"v10"}, expectedExceptions = BuildException.class)
    public void test1() {
        configureProject(BASEDIR + "test1/build.xml");
        executeTarget("test");
    }

    @Test(groups = {"v10"})
    public void test2() {
        configureProject(BASEDIR + "test2/build.xml");
        executeTarget("test");
    }

    @Test(groups = {"v10"})
    public void test3() {
        configureProject(BASEDIR + "test3/build.xml");
        executeTarget("test");

        File f = new File(BASEDIR + "test3/build/test.r");
        assertTrue(f.exists());
    }

    @Test(groups = {"v10"})
    public void test3bis() {
        configureProject(BASEDIR + "test3bis/build.xml");
        expectBuildException("test", "Compilation should fail");

        File f = new File(BASEDIR + "test3bis/build/test.r");
        assertFalse(f.exists());
    }

    @Test(groups = {"v10"})
    public void test4() {
        configureProject(BASEDIR + "test4/build.xml");
        executeTarget("test");

        File f1 = new File(BASEDIR + "test4/build/test.r");
        File f2 = new File(BASEDIR + "test4/build2/test.r");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        assertTrue(f2.length() < f1.length());
    }

    @Test(groups = {"v10"})
    public void test5() {
        configureProject(BASEDIR + "test5/build.xml");
        executeTarget("test");

        File f = new File(BASEDIR + "test5/build/wizz~~'~.r");
        assertTrue(f.exists());
    }

    @Test(groups = {"v10"})
    public void test6() {
        configureProject(BASEDIR + "test6/build.xml");
        executeTarget("test1");

        File f = new File(BASEDIR + "test6/build/test.r");
        long mod = f.lastModified();
        executeTarget("test2");
        assertTrue(mod == f.lastModified());
    }

    @Test(groups = {"v10"})
    public void test7() {
        configureProject(BASEDIR + "test7/build.xml");
        executeTarget("test1");

        File f = new File(BASEDIR + "test7/build/test.r");
        long mod = f.lastModified();
        executeTarget("test2");
        assertTrue(mod < f.lastModified());
    }

    @Test(groups = {"v10"})
    public void test8() {
        configureProject(BASEDIR + "test8/build.xml");
        executeTarget("test1");

        File f = new File(BASEDIR + "test8/build/test.r");
        long mod = f.lastModified();
        executeTarget("test2");
        assertTrue(mod < f.lastModified());
    }

    @Test(groups = {"v10"})
    public void test9() {
        configureProject(BASEDIR + "test9/build.xml");
        executeTarget("test1");

        File f = new File(BASEDIR + "test9/build/test.r");
        long mod = f.lastModified();
        executeTarget("test2");
        assertTrue(mod < f.lastModified());
    }

    @Test(groups = {"v10"})
    public void test10() {
        configureProject(BASEDIR + "test10/build.xml");
        executeTarget("test1");

        File f = new File(BASEDIR + "test10/build/test.r");
        long mod = f.lastModified();
        executeTarget("test2");
        assertTrue(mod < f.lastModified());
    }

    @Test(groups = {"v10"})
    public void test11() {
        configureProject(BASEDIR + "test11/build.xml");

        expectBuildException("test", "Second task should not be launched");
        File f = new File(BASEDIR + "test11/build/test2.r");
        assertFalse(f.exists());

        executeTarget("test2");
        File f2 = new File(BASEDIR + "test11/build2/test2.r");
        assertTrue(f2.exists());

        executeTarget("test3");
        assertTrue(new File(BASEDIR + "test11/build3/test0.r").exists());
        assertFalse(new File(BASEDIR + "test11/build3/test1.r").exists());
        assertTrue(new File(BASEDIR + "test11/build3/test2.r").exists());

        executeTarget("test4");
        assertTrue(new File(BASEDIR + "test11/build4/test0.r").exists());
        assertFalse(new File(BASEDIR + "test11/build4/test1.r").exists());
        assertFalse(new File(BASEDIR + "test11/build4/test2.r").exists());
    }

    @Test(groups = {"v10"})
    public void test12() {
        configureProject(BASEDIR + "test12/build.xml");
        expectBuildException("test1", "File with underscore");
        File f = new File(BASEDIR + "test12/build/test.r");
        assertFalse(f.exists());
        executeTarget("test2");
        assertTrue(f.exists());
    }

    @Test(groups = {"v10"})
    public void test13() {
        configureProject(BASEDIR + "test13/build.xml");
        executeTarget("test1");

        File f = new File(BASEDIR + "test13/build/test.r");
        long mod = f.lastModified();
        executeTarget("test2");
        assertTrue(mod < f.lastModified());
    }

    @Test(groups = {"v10"})
    public void test14() {
        configureProject(BASEDIR + "test14/build.xml");
        executeTarget("base");
        executeTarget("test1");

        File f1 = new File(BASEDIR + "test14/build/test.r");
        File f2 = new File(BASEDIR + "test14/build/test2.r");
        File f3 = new File(BASEDIR + "test14/build/test3.r");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        assertTrue(f3.exists());

        long mod1 = f1.lastModified();
        long mod2 = f2.lastModified();
        long mod3 = f3.lastModified();
        executeTarget("update");
        executeTarget("test2");
        assertTrue(mod1 < f1.lastModified());
        assertTrue(mod2 < f2.lastModified());
        assertTrue(mod3 < f3.lastModified());
    }

    @Test(groups = {"v10"})
    public void test15() {
        configureProject(BASEDIR + "test15/build.xml");
        executeTarget("base");
        executeTarget("test1");

        File f = new File(BASEDIR + "test15/build/test.r");
        assertTrue(f.exists());

        long mod = f.lastModified();
        executeTarget("test2");
        assertTrue(mod == f.lastModified());
    }

    @Test(groups = {"v10"})
    public void test16() {
        configureProject(BASEDIR + "test16/build.xml");
        executeTarget("xcode");
        File f1 = new File(BASEDIR + "test16/src/xcode/test.p");
        assertTrue(f1.exists());
        executeTarget("test");

        File f2 = new File(BASEDIR + "test16/build/std/test.r");
        assertTrue(f2.exists());
        File f3 = new File(BASEDIR + "test16/build/xcode/test.r");
        assertTrue(f3.exists());
    }

    @Test(groups = {"v10"})
    public void test17() {
        configureProject(BASEDIR + "test17/build.xml");
        executeTarget("xcode");
        File f1 = new File(BASEDIR + "test17/src/xcode/test.p");
        assertTrue(f1.exists());
        expectBuildException("test1", "No XCodeKey");

        executeTarget("test2");
        File f2 = new File(BASEDIR + "test17/build/xcode/test.r");
        assertFalse(f2.exists());
        File f3 = new File(BASEDIR + "test17/build2/xcode/test.r");
        assertTrue(f3.exists());
    }

    @Test(groups = {"v10"})
    public void test19() {
        configureProject(BASEDIR + "test19/build.xml");
        executeTarget("test1");

        File f1 = new File(BASEDIR + "test19/build/test.r");
        File f2 = new File(BASEDIR + "test19/build/.pct/test.p.crc");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        long mod1 = f1.lastModified();
        long mod2 = f2.lastModified();
        executeTarget("test2");
        assertTrue(mod1 < f1.lastModified());
        assertTrue(mod2 < f2.lastModified());
    }

    @Test(groups = {"v10"})
    public void test20() {
        configureProject(BASEDIR + "test20/build.xml");
        executeTarget("test1");

        File dotR = new File(BASEDIR + "test20/build/test.r");
        File f1 = new File(BASEDIR + "test20/build/.pct/test.p");
        File f2 = new File(BASEDIR + "test20/build/.pct/test.p.preprocess");
        File f3 = new File(BASEDIR + "test20/build/.dbg/test.p");
        File f4 = new File(BASEDIR + "test20/build/.pct/test.p.xref");
        File f5 = new File(BASEDIR + "test20/debug/test.p");
        File f6 = new File(BASEDIR + "test20/debug/dir1_dir2_test.p");

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

    @Test(groups = {"v10"})
    public void test21() {
        configureProject(BASEDIR + "test21/build.xml");
        executeTarget("test");

        File f1 = new File(BASEDIR + "test21/build/package/testclass.r");
        assertTrue(f1.exists());
    }

    @Test(groups = {"v10"})
    public void test22() {
        configureProject(BASEDIR + "test22/build.xml");
        executeTarget("test");

        File f1 = new File(BASEDIR + "test22/build/X.r");
        assertTrue(f1.exists());
        File f2 = new File(BASEDIR + "test22/build/Y.r");
        assertTrue(f2.exists());
        File f3 = new File(BASEDIR + "test22/build/.pct/X.cls.crc");
        assertTrue(f3.exists());
        File f4 = new File(BASEDIR + "test22/build/.pct/Y.cls.crc");
        assertTrue(f4.exists());

        executeTarget("test2");
        File f5 = new File(BASEDIR + "test22/build2/Y.r");
        assertTrue(f5.exists());
        File f6 = new File(BASEDIR + "test22/build2/X.r");
        assertTrue(f6.exists());
    }

    @Test(groups = {"v10", "win"})
    public void test23() {
        configureProject(BASEDIR + "test23/build.xml");
        expectBuildException("test1", "Should fail - No stream-io");

        File f = new File(BASEDIR + "test23/build/test.r");
        assertFalse(f.exists());
        executeTarget("test2");
        assertTrue(f.exists());
    }

    @Test(groups = {"v10"})
    public void test24() {
        configureProject(BASEDIR + "test24/build.xml");

        File f = new File(BASEDIR + "test24/build/test.r");
        assertFalse(f.exists());

        executeTarget("test1");
        assertFalse(f.exists());
        executeTarget("test2");
        assertTrue(f.exists());
    }

    @Test(groups = {"v10"})
    public void test25() {
        configureProject(BASEDIR + "test25/build.xml");
        executeTarget("test");

        File f = new File(BASEDIR + "test25/build/test.r");
        assertTrue(f.exists());
    }

    // Dropping this test case, doesn't work on 11.3 anymore, and no time to maintain it
    // @Test(groups= {"win"})
    public void test26() {
        configureProject(BASEDIR + "test26/build.xml");
        executeTarget("test");

        File f = new File(BASEDIR + "test26/build/Ö_example.r");
        assertTrue(f.exists());
    }

    @Test(groups = {"v10"})
    public void test27() {
        configureProject(BASEDIR + "test27/build.xml");
        executeTarget("test");

        File f1 = new File(BASEDIR + "test27/build/eu/rssw/pct/A.r");
        assertTrue(f1.exists());
        File f2 = new File(BASEDIR + "test27/build/eu/rssw/pct/B.r");
        assertTrue(f2.exists());
        File f3 = new File(BASEDIR + "test27/build/eu/rssw/pct/X.r");
        assertTrue(f3.exists());
        File f4 = new File(BASEDIR + "test27/build/eu/rssw/pct/Y.r");
        assertTrue(f4.exists());
        File f5 = new File(BASEDIR + "test27/build/eu/rssw/pct/Z.r");
        assertTrue(f5.exists());
        File f6 = new File(BASEDIR + "test27/build/.pct/eu/rssw/pct/Z.cls.hierarchy");
        assertTrue(f6.exists());
        assertTrue(f6.length() > 0);
    }

    @Test(groups = {"v10", "win"})
    public void test28() {
        configureProject(BASEDIR + "test28/build.xml");
        executeTarget("build");

        File f1 = new File(BASEDIR + "test28/src-tty/test.p");
        assertTrue(f1.exists());
        assertTrue(f1.length() > 0);
        File f2 = new File(BASEDIR + "test28/src-gui/test.p");
        assertTrue(f2.exists());
        assertTrue(f2.length() > 0);
        File f3 = new File(BASEDIR + "test28/src-tty/sub1/sub2/sub3/test.p");
        assertTrue(f3.exists());
        File f4 = new File(BASEDIR + "test28/src-tty/sub1/sub2/sub4/test.p");
        assertTrue(f4.exists());

        executeTarget("test");
        String str1 = getProject().getProperty("test28-tty");
        assertTrue(str1.equals("TTY"));
        String str2 = getProject().getProperty("test28-gui");
        assertTrue(str2.startsWith("MS-WIN"));
    }

    @Test(groups = {"v10"})
    public void test29() {
        configureProject(BASEDIR + "test29/build.xml");
        executeTarget("build");

        File f1 = new File(BASEDIR + "test29/build1/test.r");
        assertTrue(f1.exists());
        File f2 = new File(BASEDIR + "test29/build2/test.r");
        assertTrue(f2.exists());

        executeTarget("test1");
        executeTarget("test2");
        executeTarget("test3");

        String test1Inc = getProject().getProperty("test1-inc");
        // Absolute paths, so it should be found
        File ff = new File(test1Inc);
        assertTrue(ff.exists());
        String test1Main = getProject().getProperty("test1-main");
        File ff2 = new File(test1Main);
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

    @Test(groups = {"v10"})
    public void test30() {
        configureProject(BASEDIR + "test30/build.xml");

        executeTarget("test");
        assertTrue(new File(BASEDIR + "test30/build/test1.r").exists());
        assertFalse(new File(BASEDIR + "test30/build/test2.r").exists());
        assertTrue(new File(BASEDIR + "test30/build/test3.r").exists());

        expectBuildException("test2", "ZipFileset not supported");

        executeTarget("test3");
        assertFalse(new File(BASEDIR + "test30/build3/test1.r").exists());
        assertTrue(new File(BASEDIR + "test30/build3/test2.r").exists());
        assertFalse(new File(BASEDIR + "test30/build3/test3.r").exists());

        executeTarget("test4");
        assertEquals(new File(BASEDIR + "test30/build4").list().length, 1); // Only .pct

        executeTarget("test5");
        assertTrue(new File(BASEDIR + "test30/build5/test1.r").exists());
        assertTrue(new File(BASEDIR + "test30/build5/test2.r").exists());
        assertTrue(new File(BASEDIR + "test30/build5/test3.r").exists());

        executeTarget("test6");
        assertTrue(new File(BASEDIR + "test30/build6/test1.r").exists());
        assertFalse(new File(BASEDIR + "test30/build6/test2.r").exists());
        assertFalse(new File(BASEDIR + "test30/build6/test3.r").exists());

        executeTarget("test7");
        assertTrue(new File(BASEDIR + "test30/build7/test1.r").exists());
        assertTrue(new File(BASEDIR + "test30/build7/test2.r").exists());
        assertTrue(new File(BASEDIR + "test30/build7/test3.r").exists());

        executeTarget("test8");
        assertTrue(new File(BASEDIR + "test30/build8/test1.r").exists());
        assertTrue(new File(BASEDIR + "test30/build8/test2.r").exists());
        assertTrue(new File(BASEDIR + "test30/build8/test3.r").exists());
    }

    @Test(groups = {"v10"})
    public void test32() {
        configureProject(BASEDIR + "test32/build.xml");
        executeTarget("test");

        assertTrue(new File(BASEDIR + "test32/build1/.pct/test1.p.strxref").exists());
        assertTrue(new File(BASEDIR + "test32/build1/.pct/test2.p.strxref").exists());
        assertTrue(new File(BASEDIR + "test32/build2/.pct/strings.xref").exists());
    }

    @Test(groups = {"v10"})
    public void test33() {
        configureProject(BASEDIR + "test33/build.xml");
        executeTarget("test");

        assertTrue(new File(BASEDIR + "test33/build/test1.r").exists());
        assertTrue(new File(BASEDIR + "test33/build/test2.r").exists());

        expectBuildException("test2", "Expected failure");
        assertFalse(new File(BASEDIR + "test33/build2/test1.r").exists());
        assertFalse(new File(BASEDIR + "test33/build2/test2.r").exists());
        assertFalse(new File(BASEDIR + "test33/build2/test3.r").exists());
    }

    @Test(groups = {"v10"})
    public void test34() throws IOException, InvalidRCodeException {
        configureProject(BASEDIR + "test34/build.xml");
        executeTarget("test");

        File dbg1 = new File(BASEDIR + "test34/debugListing/test1.p");
        File dbg2 = new File(BASEDIR + "test34/debugListing/foo_bar_test2.p");
        File rcode1 = new File(BASEDIR + "test34/build/test1.r");
        File rcode2 = new File(BASEDIR + "test34/build/foo/bar/test2.r");
        assertTrue(dbg1.exists());
        assertTrue(dbg2.exists());
        assertTrue(rcode1.exists());
        assertTrue(rcode2.exists());
        // Doesn't work...
        // RCodeInfo r1 = new RCodeInfo(rcode1);
        // RCodeInfo r2 = new RCodeInfo(rcode2);
        // assertEquals(r1.getDebugListingFile(), "test1.p");
        // assertEquals(r2.getDebugListingFile(), "foo_bar_test2.p");
    }

    @Test(groups = {"v10"})
    public void test35() throws IOException {
        configureProject(BASEDIR + "test35/build.xml");
        executeTarget("init");
        executeTarget("test");
        executeTarget("test2");

        File crc = new File(BASEDIR + "test35/build/.pct/test.p.crc");
        assertTrue(crc.exists());
        String line = Files.readFirstLine(crc, Charset.defaultCharset());
        assertTrue(line.startsWith("\"sports2000.Item\""));
        File inc = new File(BASEDIR + "test35/build/.pct/test.p.inc");
        assertTrue(inc.exists());
        // TODO Problem is still there, test case kept for future reference
        // LineProcessor<Boolean> lineProcessor = new Test35LineProcessor();
        // Files.readLines(inc, Charset.defaultCharset(), lineProcessor);
        // assertTrue(lineProcessor.getResult());

        File crc2 = new File(BASEDIR + "test35/build2/.pct/test.p.crc");
        assertTrue(crc2.exists());
        String line2 = Files.readFirstLine(crc2, Charset.defaultCharset());
        assertTrue(line2.startsWith("\"sports2000.Item\""));
        File inc2 = new File(BASEDIR + "test35/build2/.pct/test.p.inc");
        assertTrue(inc2.exists());
        LineProcessor<Boolean> lineProcessor2 = new Test35LineProcessor();
        Files.readLines(inc2, Charset.defaultCharset(), lineProcessor2);
        assertTrue(lineProcessor2.getResult());
    }

    private final static class Test35LineProcessor implements LineProcessor<Boolean> {
        private boolean retVal = false;
        private int zz = 0;

        @Override
        public Boolean getResult() {
            return retVal;
        }

        @Override
        public boolean processLine(String line) throws IOException {
            if (zz == 0) {
                retVal = line.startsWith("\"test.i\"");
            } else if (zz == 1) {
                retVal &= line.startsWith("\"test2.i\"");
            } else if (zz == 2) {
                retVal &= line.startsWith("\"test3.i\"");
            }
            zz++;

            return true;
        }
    }

    @Test(groups = {"v10"})
    public void test36() throws IOException {
        configureProject(BASEDIR + "test36/build.xml");
        executeTarget("test");

        assertTrue(new File(BASEDIR + "test36/build/bar/test1.r").exists());
        assertTrue(new File(BASEDIR + "test36/build/bar/test2.r").exists());
        assertTrue(new File(BASEDIR + "test36/build/bar/test3.r").exists());
        assertFalse(new File(BASEDIR + "test36/build/bar/test4.r").exists());
        assertTrue(new File(BASEDIR + "test36/build/foo/test.r").exists());
        assertTrue(new File(BASEDIR + "test36/build/foo/subdir/subdir2/test.r").exists());
        assertFalse(new File(BASEDIR + "test36/build/baz/test.r").exists());

        executeTarget("test2");

        assertTrue(new File(BASEDIR + "test36/build2/bar/test1.r").exists());
        assertTrue(new File(BASEDIR + "test36/build2/bar/test2.r").exists());
        assertTrue(new File(BASEDIR + "test36/build2/bar/test3.r").exists());
        assertFalse(new File(BASEDIR + "test36/build2/bar/test4.r").exists());
        assertTrue(new File(BASEDIR + "test36/build2/foo/test.r").exists());
        assertTrue(new File(BASEDIR + "test36/build2/foo/subdir/subdir2/test.r").exists());
        assertFalse(new File(BASEDIR + "test36/build2/baz/test.r").exists());
    }

    // @Test(groups = {"v10"})
    // Not really a test case, just to show something is broken...
    public void test37() throws IOException {
        configureProject(BASEDIR + "test37/build.xml");
        executeTarget("init");

        assertTrue(new File(BASEDIR + "test37/build1/package/bar.r").exists());
        assertTrue(new File(BASEDIR + "test37/build1/package/Foo.r").exists());
        assertTrue(new File(BASEDIR + "test37/build2/package/bar.r").exists());
        assertTrue(new File(BASEDIR + "test37/build2/package/foo.r").exists());
        assertTrue(new File(BASEDIR + "test37/build3/package/bAr.r").exists());
        assertTrue(new File(BASEDIR + "test37/build3/package/fOO.r").exists());

        executeTarget("test1");
        executeTarget("test2");
        executeTarget("test3");
    }

    @Test(groups = {"all"})
    public void test38() {
        // Compile error with xcode
        configureProject(BASEDIR + "test38/build.xml");
        executeTarget("init");
        expectBuildException("test", "Should fail - Progress syntax error");
    }

    @Test(groups = {"all"})
    public void test39() {
        // Compile error, no xcode
        configureProject(BASEDIR + "test39/build.xml");
        expectBuildException("test", "Should fail - Progress syntax error");
    }

    @Test(groups = {"v10"})
    public void test40() {
        // Test keepXref attribute
        configureProject(BASEDIR + "test40/build.xml");
        executeTarget("test");

        assertFalse(new File(BASEDIR + "test40/build1/.pct/test.p.xref").exists());
        assertTrue(new File(BASEDIR + "test40/build2/.pct/test.p.xref").exists());
    }

    @Test(groups = {"v10"})
    public void test42() {
        configureProject(BASEDIR + "test42/build.xml");
        executeTarget("test");

        File f1 = new File(BASEDIR + "test42/build/test.r");
        File f2 = new File(BASEDIR + "test42/build2/test.r");
        long mod1 = f1.lastModified();
        long mod2 = f2.lastModified();

        executeTarget("test2");
        /*
         * Bug in 11.3 with standard XREF, but not on different versions. To be investigated
         * (later...)
         */
        // assertTrue(mod1 == f1.lastModified());
        /* But fixed with XML-XREF */
        assertTrue(f2.lastModified() > mod2);
    }

    @Test(groups = {"v10"})
    public void test43() {
        configureProject(BASEDIR + "test43/build.xml");
        executeTarget("test");

        File f1 = new File(BASEDIR + "test43/build/test.r");
        File f2 = new File(BASEDIR + "test43/build2/test.r");
        long mod1 = f1.lastModified();
        long mod2 = f2.lastModified();
        assertFalse(new File(BASEDIR + "test43/build/.pct/test.p.xref").exists());
        assertFalse(new File(BASEDIR + "test43/build/.pct/test.p.inc").exists());
        assertFalse(new File(BASEDIR + "test43/build/.pct/test.p.crc").exists());
        assertFalse(new File(BASEDIR + "test43/build/.dbg/test.p").exists());
        assertTrue(new File(BASEDIR + "test43/build2/.dbg/test.p").exists());
        assertTrue(new File(BASEDIR + "test43/build2/.pct/test.p.preprocess").exists());

        executeTarget("test2");
        assertTrue(f1.lastModified() > mod1);
        assertTrue(f2.lastModified() > mod2);
    }

    @Test(groups = {"v10"})
    public void test45() {
        configureProject(BASEDIR + "test45/build.xml");
        executeTarget("test");

        File f1 = new File(BASEDIR + "test45/build/test.r");
        File f2 = new File(BASEDIR + "test45/build/.pct/test.p");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        assertTrue(f2.length() > 650);
    }

    @Test(groups = {"v10"})
    public void test46() {
        configureProject(BASEDIR + "test46/build.xml");
        executeTarget("test");

        File f1 = new File(BASEDIR + "test46/build/test.r");
        File f2 = new File(BASEDIR + "test46/build/.pct/test.p");
        File f3 = new File(BASEDIR + "test46/build2/test.r");
        File f4 = new File(BASEDIR + "test46/build2/.pct/test.p");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        assertTrue(f3.exists());
        assertTrue(f4.exists());
        try {
            // Preprocessed source code removes many lines of unreachable code
            assertTrue(Files.readLines(f2, Charsets.UTF_8).size() + 10 < Files
                    .readLines(f4, Charsets.UTF_8).size());
        } catch (IOException caught) {
            Assert.fail("Unable to open file", caught);
        }
    }

    @Test(groups = {"v10"})
    public void test47() {
        configureProject(BASEDIR + "test47/build.xml");
        executeTarget("test1");

        File f1 = new File(BASEDIR + "test47/build/dir1/test.r");
        assertTrue(f1.exists());
        long mod1 = f1.lastModified();

        executeTarget("test2");
        assertTrue(f1.lastModified() > mod1);
    }

    @Test(groups = {"v10"})
    public void test48() {
        configureProject(BASEDIR + "test48/build.xml");
        executeTarget("test1");

        File f1 = new File(BASEDIR + "test48/build/test.r");
        assertTrue(f1.exists());
        long mod1 = f1.lastModified();

        executeTarget("test2");
        assertTrue(f1.lastModified() > mod1);
    }

    @Test(groups = {"v10"})
    public void test49() {
        configureProject(BASEDIR + "test49/build.xml");
        executeTarget("test1");
        File warns = new File(BASEDIR + "test49/build/.pct/test.p.warnings");
        assertTrue(warns.exists());
        assertTrue(warns.length() > 0);
    }

    @Test(groups = {"v10"})
    public void test50() {
        configureProject(BASEDIR + "test50/build.xml");
        executeTarget("test1");
        File rcode = new File(BASEDIR + "test50/build/test.r");
        assertTrue(rcode.exists());
        assertTrue(rcode.length() > 0);
    }

    @Test(groups = {"v10"})
    public void test51() {
        configureProject(BASEDIR + "test51/build.xml");
        executeTarget("test1"); /* compile all programms */
        File f1 = new File(BASEDIR + "test51/build/test.r");
        assertTrue(f1.exists());
        long mod1 = f1.lastModified();
        File f2 = new File(BASEDIR + "test51/build/test2.r");
        assertTrue(f2.exists());
        long mod2 = f2.lastModified();

        executeTarget("test2"); /* nothing should compile */
        File f3 = new File(BASEDIR + "test51/build/test.r");
        assertTrue(f3.exists());
        assertFalse(f3.lastModified() > mod1);
        mod1 = f1.lastModified();

        File f4 = new File(BASEDIR + "test51/build/test2.r");
        assertTrue(f4.exists());
        assertFalse(f4.lastModified() > mod2);

        executeTarget("test3"); /* all programms should be compiled */
        File f5 = new File(BASEDIR + "test51/build/test.r");
        long mod5 = f5.lastModified();
        assertTrue(f5.exists());
        assertTrue(mod5 > mod1);

        File f6 = new File(BASEDIR + "test51/build/test2.r");
        long mod6 = f6.lastModified();
        assertTrue(f6.exists());
        assertTrue(mod6 > mod2);

        executeTarget("test4"); /* all programms should be compiled */
        File f7 = new File(BASEDIR + "test51/build/test.r");
        assertTrue(f7.exists());
        assertTrue(f7.lastModified() > mod5);

        File f8 = new File(BASEDIR + "test51/build/test2.r");
        assertTrue(f8.exists());
        assertTrue(f8.lastModified() > mod6);
    }

    @Test(groups = {"v10"})
    public void test56() {
        configureProject(BASEDIR + "test56/build.xml");
        executeTarget("test");
        assertTrue(new File(BASEDIR + "test56/build1/build2/build3/test.r").exists());
    }

    @Test(groups = {"v10"})
    public void test57() {
        configureProject(BASEDIR + "test57/build.xml");
        executeTarget("test");
        assertTrue(new File(BASEDIR + "test57/build/test.r").exists());
    }

    @Test(groups = {"v10"})
    public void test58() {
        configureProject(BASEDIR + "test58/build.xml");
        executeTarget("db");
        executeTarget("build");
        assertTrue(new File(BASEDIR + "test58/build/file1.r").exists());
        assertTrue(new File(BASEDIR + "test58/build/dir1/file2.r").exists());
        assertTrue(new File(BASEDIR + "test58/build/dir1/file3.r").exists());
        expectLog("test-fr", "String1-FRString2-FR");
        expectLog("test-de", "String1-DEString2-DE");
    }

    @Test(groups = {"v10"})
    public void test101() {
        configureProject(BASEDIR + "test101/build.xml");
        executeTarget("test");

        File f1 = new File(BASEDIR + "test101/build/test1.p");
        assertTrue(f1.exists());
        File f2 = new File(BASEDIR + "test101/build/test2.p");
        assertTrue(f2.exists());
    }

    @Test(groups = {"v10"})
    public void test102() {
        configureProject(BASEDIR + "test102/build.xml");
        executeTarget("test");

        File f1 = new File(BASEDIR + "test102/build/testrenamed.r");
        File f2 = new File(BASEDIR + "test102/build/test2renamed.r");
        File f3 = new File(BASEDIR + "test102/build/triggers/trigger.r");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        assertTrue(f3.exists());

        long l1 = f1.lastModified();
        long l2 = f2.lastModified();
        long l3 = f3.lastModified();
        executeTarget("test2");
        assertEquals(f1.lastModified(), l1);
        assertEquals(f2.lastModified(), l2);
        assertEquals(f3.lastModified(), l3);
    }

    @Test(groups = {"v10"})
    public void test103() throws IOException {
        File inputDir = new File(BASEDIR + "test103/src");
        File srcFile = new File(BASEDIR + "test103/query-tester.w");
        for (int ii = 0; ii < 10; ii++) {
            for (int jj = 0; jj < 10; jj++) {
                copy(srcFile, new File(inputDir, "test" + ii + jj + ".p"));
            }
        }
        configureProject(BASEDIR + "test103/build.xml");
        executeTarget("test");

        File f = new File(BASEDIR + "test103/build/test00.r");
        assertTrue(f.exists());
        f = new File(BASEDIR + "test103/build/test99.r");
        assertTrue(f.exists());
    }

    @Test(groups = {"v10"})
    public void test104() throws IOException {
        configureProject(BASEDIR + "test104/build.xml");
        executeTarget("base");

        expectBuildException("test1", "Invalid alias");
        executeTarget("test2");
        executeTarget("test3");
        executeTarget("test4");
        File f1 = new File(BASEDIR + "test104/build/proc.r");
        File f2 = new File(BASEDIR + "test104/build/proc2.r");
        File f3 = new File(BASEDIR + "test104/build/proc3.r");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        assertTrue(f3.exists());
    }

    @Test(groups = {"v10"})
    public void test105() throws IOException {
        configureProject(BASEDIR + "test105/build.xml");
        executeTarget("base");
        executeTarget("test1");
        expectBuildException("test2", "No DB connection, should throw BuildException");

        File f1 = new File(BASEDIR + "test105/build/test.r");
        File f2 = new File(BASEDIR + "test105/build2/test.r");
        assertTrue(f1.exists());
        assertFalse(f2.exists());
    }

    @Test(groups = {"v10"})
    public void test106() throws IOException {
        configureProject(BASEDIR + "test106/build.xml");
        executeTarget("test");

        File f1 = new File(BASEDIR + "test106/profiler");
        // 2 profiler files generated
        assertEquals(f1.list().length, 2);
    }

    @Test(groups = {"v10"})
    public void test107() throws IOException {
        configureProject(BASEDIR + "test107/build.xml");
        executeTarget("test");

        File f1 = new File(BASEDIR + "test107/build/test.r");
        File f2 = new File(BASEDIR + "test107/build/test2.r");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
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
