/**
 * Copyright 2005-2019 Riverside Software
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

import org.apache.tools.ant.BuildException;
import org.testng.annotations.Test;

import java.io.File;

import java.util.List;

/**
 * Class for testing PCTLibrary task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTLibraryTest extends BuildFileTestNg {

    /**
     * Attribute destFile should always be defined
     */
    @Test(groups= {"v10"}, expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("PCTLibrary/test1/build.xml");
        executeTarget("test");
    }

    @Test(groups= {"v10"}, expectedExceptions = BuildException.class)
    public void test2() {
        configureProject("PCTLibrary/test2/build.xml");
        executeTarget("test");
    }

    /**
     * Checks that a file is added in the library
     */
    @Test(groups= {"v10"})
    public void test3() {
        configureProject("PCTLibrary/test3/build.xml");
        executeTarget("test");

        File pl = new File("PCTLibrary/test3/lib/test.pl");
        assertTrue(pl.exists());

        PLReader r = new PLReader(pl);
        List<FileEntry> v = r.getFileList();
        assertTrue(v != null);
        assertTrue(v.size() == 1);
        assertTrue(((FileEntry) v.get(0)).getFileName().startsWith("test"));
    }

    /**
     * Checks that a file is added in the library
     */
    @Test(groups= {"v10"})
    public void test4() {
        configureProject("PCTLibrary/test4/build.xml");
        executeTarget("test1");

        File pl = new File("PCTLibrary/test4/lib/test.pl");
        assertTrue(pl.exists());

        PLReader r = new PLReader(pl);
        List<FileEntry> v = r.getFileList();
        assertTrue(v != null);
        assertTrue(v.size() == 1);

        executeTarget("test2");
        PLReader r2 = new PLReader(pl);
        List<FileEntry> v2 = r2.getFileList();
        assertTrue(v2 != null);
        assertTrue(v2.size() == 1);
    }

    @Test(groups= {"v10"})
    public void test5() {
        configureProject("PCTLibrary/test5/build.xml");
        executeTarget("test");

        File f1 = new File("PCTLibrary/test5/lib/test.pl");
        assertTrue(f1.exists());
        File f2 = new File("PCTLibrary/test5/lib/test2.pl");
        assertTrue(f2.exists());
        assertTrue((f2.length() < f1.length()));
    }

    @Test(groups= {"v10"})
    public void test6() {
        configureProject("PCTLibrary/test6/build.xml");
        executeTarget("test");

        File f1 = new File("PCTLibrary/test6/lib/test.pl");
        assertTrue(f1.exists());

        PLReader r = new PLReader(f1);
        List<FileEntry> v = r.getFileList();
        assertTrue(v != null);
        assertTrue(v.size() == 3);
        assertTrue(((FileEntry) v.get(0)).getFileName().startsWith("test"));
        assertTrue(((FileEntry) v.get(1)).getFileName().startsWith("test"));
        assertTrue(((FileEntry) v.get(2)).getFileName().startsWith("test"));
    }

    @Test(groups= {"v10"}, expectedExceptions = BuildException.class)
    public void test7() {
        configureProject("PCTLibrary/test7/build.xml");
        executeTarget("test");
    }

    @Test(groups= {"v10"})
    public void test8() {
        configureProject("PCTLibrary/test8/build.xml");
        executeTarget("test");

        File f1 = new File("PCTLibrary/test8/lib/test.pl");
        assertTrue(f1.exists());

        PLReader r = new PLReader(f1);
        List<FileEntry> v = r.getFileList();
        assertTrue(v != null);
        assertTrue(v.size() == 2);
    }

    @Test(groups= {"v10"})
    public void test9() {
        configureProject("PCTLibrary/test9/build.xml");
        executeTarget("test");

        File f1 = new File("PCTLibrary/test9/lib/test1.pl");
        File f2 = new File("PCTLibrary/test9/lib/test2.pl");
        assertTrue(f1.exists());
        assertTrue(f2.exists());

        PLReader r1 = new PLReader(f1);
        PLReader r2 = new PLReader(f2);
        List<FileEntry> v1 = r1.getFileList();
        List<FileEntry> v2 = r2.getFileList();
        assertTrue(v1 != null);
        assertTrue(v1.size() == 2);
        assertTrue(((FileEntry) v1.get(0)).getFileName().startsWith("test"));
        assertTrue(((FileEntry) v1.get(1)).getFileName().startsWith("test"));

        assertTrue(v2 != null);
        assertTrue(v2.size() == 1);
        assertTrue(((FileEntry) v2.get(0)).getFileName().startsWith("test"));
    }

//    @Test Not tested for now
    public void test10() {
        configureProject("PCTLibrary/test10/build.xml");
        executeTarget("prepare");

        File f1 = new File("PCTLibrary/test10/lib/test.pl");
        assertTrue(f1.exists());
        File f2 = new File("PCTLibrary/test10/lib/test2.pl");
        assertTrue(f2.exists());

        expectLog("test", "éèà");

        PLReader r = new PLReader(f2);
        List<FileEntry> v = r.getFileList();
        assertTrue(v != null);
        assertTrue(v.size() == 2);
        assertTrue(v.contains(new String("éèà.txt")));
    }

    // @Test(groups= {"v10"})
    public void test11() {
        configureProject("PCTLibrary/test11/build.xml");

        executeTarget("test1");
        File f1 = new File("PCTLibrary/test11/lib/test1.pl");
        assertTrue(f1.exists());

        PLReader r = new PLReader(f1);
        List<FileEntry> v = r.getFileList();
        assertTrue(v != null);
        assertTrue(v.size() == 1);
        assertTrue(((FileEntry) v.get(0)).getFileName().startsWith("Twenty"));

        executeTarget("test2");
        File f2 = new File("PCTLibrary/test11/lib/test2.pl");
        assertTrue(f2.exists());

        PLReader r2 = new PLReader(f2);
        List<FileEntry> v2 = r2.getFileList();
        assertTrue(v2 != null);
        assertTrue(v2.size() == 1);
        assertTrue(((FileEntry) v2.get(0)).getFileName().startsWith("Twenty"));
    }

    @Test(groups= {"v10"})
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
    @Test(groups= {"v10"})
    public void test13() {
        configureProject("PCTLibrary/test13/build.xml");
        executeTarget("test1");
        File pl1 = new File("PCTLibrary/test13/lib1/test.pl");
        assertTrue(pl1.exists());
        File pl2 = new File("PCTLibrary/test13/lib1/shared.pl");
        assertTrue(pl2.exists());

        // Memory-mapped PL can't be read by PLReader
        // PLReader r = new PLReader(pl2);
        // List<FileEntry> v = r.getFileList();
        // assertTrue(v != null);
        // assertTrue(v.size() == 1);
        // assertTrue(((FileEntry) v.get(0)).getFileName().startsWith("test"));

        executeTarget("test2");
        File dir = new File("PCTLibrary/test13/lib2");
        assertEquals(dir.listFiles().length, 1);
        File pl4 = new File("PCTLibrary/test13/lib2/shared.pl");
        assertTrue(pl4.exists());

        expectBuildException("test3", "No destFile or sharedFile");

        executeTarget("test4");
    }
}
