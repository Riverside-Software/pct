/**
 * Copyright 2005-2026 Riverside Software
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
package com.phenix.pct.test;

import static org.testng.Assert.assertEquals;
import static org.testng.Assert.assertNotNull;
import static org.testng.Assert.assertTrue;

import java.io.File;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.condition.Os;
import org.testng.annotations.Test;

import eu.rssw.pct.FileEntry;
import eu.rssw.pct.PLReader;

/**
 * Class for testing PCTLibrary task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTLibraryTest extends BuildFileTestNg {

    /**
     * Attribute destFile should always be defined
     */
    @Test(groups= {"v11"}, expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("PCTLibrary/test1/build.xml");
        executeTarget("test");
    }

    @Test(groups= {"v11"}, expectedExceptions = BuildException.class)
    public void test2() {
        configureProject("PCTLibrary/test2/build.xml");
        executeTarget("test");
    }

    /**
     * Checks that a file is added in the library
     */
    @Test(groups= {"v11"})
    public void test3() {
        configureProject("PCTLibrary/test3/build.xml");
        executeTarget("test");

        File pl = new File("PCTLibrary/test3/lib/test.pl");
        assertTrue(pl.exists());

        PLReader r = new PLReader(pl.toPath());
        List<FileEntry> v = r.getFileList();
        assertNotNull(v);
        assertEquals(v.size(), 1);
        assertEquals(v.get(0).getFileName(), "test");
    }

    /**
     * Checks that a file is added in the library
     */
    @Test(groups= {"v11"})
    public void test4() {
        configureProject("PCTLibrary/test4/build.xml");
        executeTarget("test1");

        File pl = new File("PCTLibrary/test4/lib/test.pl");
        assertTrue(pl.exists());

        PLReader r = new PLReader(pl.toPath());
        List<FileEntry> v = r.getFileList();
        assertNotNull(v);
        assertEquals(v.size(), 1);

        executeTarget("test2");
        PLReader r2 = new PLReader(pl.toPath());
        List<FileEntry> v2 = r2.getFileList();
        assertNotNull(v2);
        assertEquals(v2.size(), 1);
    }

    @Test(groups= {"v11"})
    public void test5() {
        configureProject("PCTLibrary/test5/build.xml");
        executeTarget("test");

        File f1 = new File("PCTLibrary/test5/lib/test.pl");
        assertTrue(f1.exists());
        File f2 = new File("PCTLibrary/test5/lib/test2.pl");
        assertTrue(f2.exists());
        assertTrue(f2.length() < f1.length());
    }

    @Test(groups= {"v11"})
    public void test6() {
        configureProject("PCTLibrary/test6/build.xml");
        executeTarget("test");

        File f1 = new File("PCTLibrary/test6/lib/test.pl");
        assertTrue(f1.exists());

        PLReader r = new PLReader(f1.toPath());
        List<FileEntry> v = r.getFileList();
        assertNotNull(v);
        assertEquals(v.size(), 3);
        Set<String> names = v.stream().map(FileEntry::getFileName).collect(Collectors.toSet());
        Set<String> expected = new HashSet(Arrays.asList("test", "test2", "test3"));
        assertEquals(names, expected);
    }

    @Test(groups= {"v11"}, expectedExceptions = BuildException.class)
    public void test7() {
        configureProject("PCTLibrary/test7/build.xml");
        executeTarget("test");
    }

    @Test(groups= {"v11"})
    public void test8() {
        configureProject("PCTLibrary/test8/build.xml");
        executeTarget("test");

        File f1 = new File("PCTLibrary/test8/lib/test.pl");
        assertTrue(f1.exists());

        PLReader r = new PLReader(f1.toPath());
        List<FileEntry> v = r.getFileList();
        assertNotNull(v);
        assertEquals(v.size(), 2);
    }

    @Test(groups= {"v11"})
    public void test9() {
        configureProject("PCTLibrary/test9/build.xml");
        executeTarget("test");

        File f1 = new File("PCTLibrary/test9/lib/test1.pl");
        File f2 = new File("PCTLibrary/test9/lib/test2.pl");
        assertTrue(f1.exists());
        assertTrue(f2.exists());

        PLReader r1 = new PLReader(f1.toPath());
        PLReader r2 = new PLReader(f2.toPath());
        List<FileEntry> v1 = r1.getFileList();
        List<FileEntry> v2 = r2.getFileList();
        assertNotNull(v1);
        assertEquals(v1.size(), 2);
        Set<String> names = v1.stream().map(FileEntry::getFileName).collect(Collectors.toSet());
        Set<String> expected = new HashSet(Arrays.asList("test space", "test space2"));
        assertEquals(names, expected);

        assertNotNull(v2);
        assertEquals(v2.size(), 1);
        assertEquals(v2.get(0).getFileName(), "test space");
    }

    // This has never been enabled, good candidate for removal 
    @Test(groups= {"v11"}, enabled = false)
    public void test10() {
        configureProject("PCTLibrary/test10/build.xml");
        executeTarget("prepare");

        File f1 = new File("PCTLibrary/test10/lib/test.pl");
        assertTrue(f1.exists());
        File f2 = new File("PCTLibrary/test10/lib/test2.pl");
        assertTrue(f2.exists());

        expectLog("test", "éèà");

        PLReader r = new PLReader(f2.toPath());
        List<FileEntry> v = r.getFileList();
        assertNotNull(v);
        assertTrue(v.size() == 2);
        assertEquals(v.get(0).getFileName(), "éèà.txt");
    }

    // Test has been disabled in 2015, another good candidate for removal
    @Test(groups= {"v11"}, enabled = false)
    public void test11() {
        configureProject("PCTLibrary/test11/build.xml");

        executeTarget("test1");
        File f1 = new File("PCTLibrary/test11/lib/test1.pl");
        assertTrue(f1.exists());

        PLReader r = new PLReader(f1.toPath());
        List<FileEntry> v = r.getFileList();
        assertNotNull(v);
        assertEquals(v.size(), 1);
        assertTrue(v.get(0).getFileName().startsWith("Twenty"));

        executeTarget("test2");
        File f2 = new File("PCTLibrary/test11/lib/test2.pl");
        assertTrue(f2.exists());

        PLReader r2 = new PLReader(f2.toPath());
        List<FileEntry> v2 = r2.getFileList();
        assertTrue(v2 != null);
        assertTrue(v2.size() == 1);
        assertTrue(v2.get(0).getFileName().startsWith("Twenty"));
    }

    @Test(groups= {"v11"})
    public void test12() {
        configureProject("PCTLibrary/test12/build.xml");

        executeTarget("build");
        File f1 = new File("PCTLibrary/test12/dist/test.pl");
        assertTrue(f1.exists());
        
        expectLog("test1", "14844066 49853 50064"); // •½Ð
        expectLog("test2", "14844066 49852 50334"); // •¼Ğ
        expectLog("test3", "55184 55186 49809"); // אג±
        expectLog("test4", "49853 50064"); // ½Ð
        expectLog("test5", "50089 50334 50309 50064"); // éĞąÐ
    }

    /**
     * Checks that a file is added in the library
     */
    @Test(groups= {"v11"})
    public void test13() {
        configureProject("PCTLibrary/test13/build.xml");
        executeTarget("test1");
        File pl1 = new File("PCTLibrary/test13/lib1/test.pl");
        assertTrue(pl1.exists());
        File pl2 = new File("PCTLibrary/test13/lib1/shared.pl");
        assertTrue(pl2.exists());
        // Memory-mapped PL can't be read by PLReader

        executeTarget("test2");
        File dir = new File("PCTLibrary/test13/lib2");
        assertEquals(dir.listFiles().length, 1);
        File pl4 = new File("PCTLibrary/test13/lib2/shared.pl");
        assertTrue(pl4.exists());

        expectBuildException("test3", "No destFile or sharedFile");

        executeTarget("test4");
    }

    /**
     * Checks that a file is added in the library with the right slash
     */
    @Test(groups= {"v11"})
    public void test14() {
        configureProject("PCTLibrary/test14/build.xml");
        executeTarget("test");

        File pl = new File("PCTLibrary/test14/lib/test.pl");
        assertTrue(pl.exists());

        PLReader r = new PLReader(pl.toPath());
        List<FileEntry> v = r.getFileList();
        assertNotNull(v);
        assertEquals(v.size(), 1);
        assertEquals(v.get(0).getFileName(), "abl/test");

        executeTarget("test2");

        File pl2 = new File("PCTLibrary/test14/lib2/test.pl");
        assertTrue(pl2.exists());

        PLReader r2 = new PLReader(pl2.toPath());
        List<FileEntry> v2 = r2.getFileList();
        assertNotNull(v2);
        assertEquals(v2.size(), 1);
        if (Os.isFamily(Os.FAMILY_WINDOWS)) {
            assertEquals(v2.get(0).getFileName(), "abl\\test");
        } else {
            assertEquals(v2.get(0).getFileName(), "abl/test");
        }

    }
}
