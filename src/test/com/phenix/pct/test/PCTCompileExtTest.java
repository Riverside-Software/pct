/**
 * Copyright 2005-2024 Riverside Software
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
import static org.testng.Assert.assertFalse;
import static org.testng.Assert.assertTrue;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

import org.testng.annotations.Test;

import com.phenix.pct.DLCVersion;

/**
 * Class for testing PCTCompileExt task
 *
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTCompileExtTest extends PCTCompileTest {

    @Override
    String getBaseDir() {
        return "PCTCompileExt/";
    }

    // ResultProperty is meaningless in multi-threaded builds
    @Override
    @Test(enabled=false, groups = {"v11"})
    public void test73() {
        // No-op
    }

    // String values are different in PCTCompileExt
    @Override
    @Test(groups = {"v11"})
    public void test76() {
        // Only work with 11.3+
        DLCVersion version = DLCVersion.getObject(new File(System.getProperty("DLC")));
        if ((version.getMajorVersion() == 11) && (version.getMinorVersion() <= 2))
            return;

        configureProject(getBaseDir() + "test76/build.xml");
        executeTarget("compile");

        expectLog("testInitialize", "Initialize#pct/pctBgCompile.p");
        expectLog("testBeforeCompile", "Before Compile#pct/pctBgCompile.p#test.p#src");
        expectLog("testAfterCompile", "After Compile#pct/pctBgCompile.p#test.p#src");

        File f = new File(getBaseDir() + "test76/build/test.r");
        assertTrue(f.exists());
    }

    // No test case as 'outputType' attribute is not implemented in PCTCompileExt
    @Override
    @Test(enabled=false, groups = {"v11"})
    public void test79() {
        // No-op
    }

    @Override
    @Test(enabled = false, groups = {"v11"})
    public void test83() {
        // No-op
    }

    @Test(groups = {"v11"})
    public void test101() {
        configureProject(getBaseDir() + "test101/build.xml");
        executeTarget("test");

        File f1 = new File(getBaseDir() + "test101/build/test1.p");
        assertTrue(f1.exists());
        File f2 = new File(getBaseDir() + "test101/build/test2.p");
        assertTrue(f2.exists());
    }

    @Test(groups = {"v11"})
    public void test102() {
        configureProject(getBaseDir() + "test102/build.xml");
        executeTarget("test");

        File f1 = new File(getBaseDir() + "test102/build/testrenamed.r");
        File f2 = new File(getBaseDir() + "test102/build/test2renamed.r");
        File f3 = new File(getBaseDir() + "test102/build/triggers/trigger.r");
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

    @Test(groups = {"v11"})
    public void test103() throws IOException {
        File inputDir = new File(getBaseDir() + "test103/src");
        File subDir1 = new File(inputDir, "dir1");
        File subDir2 = new File(subDir1, "dir2");
        subDir2.mkdirs();
        File srcFile = new File(getBaseDir() + "test103/query-tester.w");
        for (int ii = 0; ii < 10; ii++) {
            for (int jj = 0; jj < 10; jj++) {
                Files.copy(srcFile.toPath(), subDir2.toPath().resolve("test" + ii + jj + ".p"));
            }
        }
        configureProject(getBaseDir() + "test103/build.xml");
        executeTarget("test");

        File f = new File(getBaseDir() + "test103/build/dir1/dir2/test00.r");
        assertTrue(f.exists());
        f = new File(getBaseDir() + "test103/build/dir1/dir2/test99.r");
        assertTrue(f.exists());
    }

    @Test(groups = {"v11"})
    public void test104() {
        configureProject(getBaseDir() + "test104/build.xml");
        executeTarget("base");

        expectBuildException("test1", "Invalid alias");
        executeTarget("test2");
        executeTarget("test3");
        executeTarget("test4");
        File f1 = new File(getBaseDir() + "test104/build/proc.r");
        File f2 = new File(getBaseDir() + "test104/build/proc2.r");
        File f3 = new File(getBaseDir() + "test104/build/proc3.r");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        assertTrue(f3.exists());
    }

    @Test(groups = {"v11"})
    public void test105() {
        configureProject(getBaseDir() + "test105/build.xml");
        executeTarget("base");
        executeTarget("test1");
        expectBuildException("test2", "No DB connection, should throw BuildException");

        File f1 = new File(getBaseDir() + "test105/build/test.r");
        File f2 = new File(getBaseDir() + "test105/build2/test.r");
        assertTrue(f1.exists());
        assertFalse(f2.exists());
    }

    @Test(groups = {"v11"})
    public void test106() {
        configureProject(getBaseDir() + "test106/build.xml");
        executeTarget("test");

        File f1 = new File(getBaseDir() + "test106/profiler");
        // 2 profiler files generated
        assertEquals(f1.list().length, 2);
    }

    @Test(groups = {"v11"})
    public void test107() {
        configureProject(getBaseDir() + "test107/build.xml");
        executeTarget("test");

        File f1 = new File(getBaseDir() + "test107/build/test.r");
        File f2 = new File(getBaseDir() + "test107/build/test2.r");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
    }
}
