/**
 * Copyright 2005-2021 Riverside Software
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

import static org.testng.Assert.assertFalse;
import static org.testng.Assert.assertTrue;
import static org.testng.Assert.fail;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.channels.FileChannel;
import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;
import java.util.regex.Matcher;

import org.testng.annotations.Test;

/**
 * Class for testing PCTDumpIncremental task Assertion - following classes should work properly :
 * PCTCreateBase PCTCompile PCTLoadSchema
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTDumpIncrementalTest extends BuildFileTestNg {

    /**
     * Simple incremental test
     */
    @Test(groups= {"v11"})
    public void test1() {
        configureProject("PCTDumpIncremental/test1/build.xml");
        executeTarget("base");

        executeTarget("test1");
        File f1 = new File("PCTDumpIncremental/test1/incr/incremental.df");
        assertTrue(f1.exists());

        executeTarget("test2");
        File f2 = new File("PCTDumpIncremental/test1/build/test.r");
        assertTrue(f2.exists());
    }

    /**
     * Test activeIndexes attribute
     */
    @Test(groups= {"v11"})
    public void test2() {
        configureProject("PCTDumpIncremental/test2/build.xml");
        executeTarget("base");
        executeTarget("test");

        File f1 = new File("PCTDumpIncremental/test2/incr/incremental1.df");
        File f2 = new File("PCTDumpIncremental/test2/incr/incremental2.df");
        File f3 = new File("PCTDumpIncremental/test2/incr/incremental3.df");
        assertTrue(f1.exists());
        assertTrue(f2.exists());

        java.util.regex.Pattern regexp = java.util.regex.Pattern.compile("INACTIVE",
                java.util.regex.Pattern.MULTILINE);
        // Get a Channel for the source file
        try (FileInputStream fis = new FileInputStream(f1)) {
            FileChannel fc = fis.getChannel();

            // Get a CharBuffer from the source file
            ByteBuffer bb = fc.map(FileChannel.MapMode.READ_ONLY, 0, (int) fc.size());
            Charset cs = Charset.forName("8859_1");
            CharsetDecoder cd = cs.newDecoder();
            CharBuffer cb = cd.decode(bb);

            Matcher m = regexp.matcher(cb);
            if (m.find())
                fail("Index was declared inactive but activeIndexes is set to 0");
        } catch (Exception e) {
            fail("Unable to parse file incremental1.df");
        }

        regexp = java.util.regex.Pattern.compile("INACTIVE", java.util.regex.Pattern.MULTILINE);
        // Get a Channel for the source file
        try (FileInputStream fis = new FileInputStream(f2)){
            FileChannel fc = fis.getChannel();

            // Get a CharBuffer from the source file
            ByteBuffer bb = fc.map(FileChannel.MapMode.READ_ONLY, 0, (int) fc.size());
            Charset cs = Charset.forName("8859_1");
            CharsetDecoder cd = cs.newDecoder();
            CharBuffer cb = cd.decode(bb);

            // Run some matches
            Matcher m = regexp.matcher(cb);
            if (!m.find())
                fail("Index wasn't declared inactive but activeIndexes is set to 1");
        } catch (Exception e) {
            fail("Unable to parse file incremental2.df");
        }

        regexp = java.util.regex.Pattern.compile("INACTIVE", java.util.regex.Pattern.MULTILINE);
        // Get a Channel for the source file
        try (FileInputStream fis = new FileInputStream(f3)) {
            FileChannel fc = fis.getChannel();

            // Get a CharBuffer from the source file
            ByteBuffer bb = fc.map(FileChannel.MapMode.READ_ONLY, 0, (int) fc.size());
            Charset cs = Charset.forName("8859_1");
            CharsetDecoder cd = cs.newDecoder();
            CharBuffer cb = cd.decode(bb);

            // Run some matches
            Matcher m = regexp.matcher(cb);
            if (!m.find())
                fail("Index wasn't declared inactive but activeIndexes is set to 2");
        } catch (Exception e) {
            fail("Unable to parse file incremental3.df");
        }    }

    /**
     * Verifies codepage attribute
     */
    @Test(groups= {"v11"})
    public void test3() {
        configureProject("PCTDumpIncremental/test3/build.xml");
        executeTarget("base");
        executeTarget("test");

        File f1 = new File("PCTDumpIncremental/test3/incr/incremental1.df");
        File f2 = new File("PCTDumpIncremental/test3/incr/incremental2.df");
        assertTrue(f1.exists());
        assertTrue(f2.exists());

        java.util.regex.Pattern regexp = java.util.regex.Pattern.compile("cpstream=iso8859-1",
                java.util.regex.Pattern.MULTILINE);
        // Get a Channel for the source file
        try (FileInputStream fis = new FileInputStream(f1)) {
            FileChannel fc = fis.getChannel();

            // Get a CharBuffer from the source file
            ByteBuffer bb = fc.map(FileChannel.MapMode.READ_ONLY, 0, (int) fc.size());
            Charset cs = Charset.forName("ISO-8859-1");
            CharsetDecoder cd = cs.newDecoder();
            CharBuffer cb = cd.decode(bb);

            Matcher m = regexp.matcher(cb);
            if (!m.find())
                fail("Codepage declared was iso8859-1");
        } catch (Exception e) {
            fail("Unable to parse file incr1.df");
        }

        regexp = java.util.regex.Pattern.compile("cpstream=utf-8",
                java.util.regex.Pattern.MULTILINE);
        // Get a Channel for the source file
        try (FileInputStream fis = new FileInputStream(f2)) {
            FileChannel fc = fis.getChannel();

            // Get a CharBuffer from the source file
            ByteBuffer bb = fc.map(FileChannel.MapMode.READ_ONLY, 0, (int) fc.size());
            Charset cs = Charset.forName("utf-8");
            CharsetDecoder cd = cs.newDecoder();
            CharBuffer cb = cd.decode(bb);

            // Run some matches
            Matcher m = regexp.matcher(cb);
            if (!m.find())
                fail("Codepage declared was iso8859-1");
        } catch (Exception e) {
            fail("Unable to parse file incr2.df");
        }
    }

    /**
     * Test renameFile attribute : 1/ Creates Tab1 table in test DB with Fld1 and Fld2 2/ Creates
     * Tab1 table in test2 DB with Fld1 and Fld3 3/ Generate rename file 4/ Generates incremental
     * dump file between test and test2 DBs with and without rename file 5/ Compares differences
     * between both output files
     */
    @Test(groups= {"v11"})
    public void test4() {
        configureProject("PCTDumpIncremental/test4/build.xml");
        executeTarget("base");
        executeTarget("test");

        File f1 = new File("PCTDumpIncremental/test4/incr/incremental1.df");
        File f2 = new File("PCTDumpIncremental/test4/incr/incremental2.df");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        assertTrue(f1.length() != f2.length());
    }

    /**
     * Simple incremental test with new attributes SourceDb and TargetDb
     */
    @Test(groups= {"v11"})
    public void test5() {
        configureProject("PCTDumpIncremental/test5/build.xml");
        executeTarget("base");

        executeTarget("test1");
        File f1 = new File("PCTDumpIncremental/test5/incr/incremental.df");
        assertTrue(f1.exists());

        executeTarget("test2");
        File f2 = new File("PCTDumpIncremental/test5/build/test.r");
        assertTrue(f2.exists());
    }

    @Test(groups = {"v11"})
    public void test6() {
        configureProject("PCTDumpIncremental/test6/build.xml");
        executeTarget("base");

        executeTarget("test1");
        File f1 = new File("PCTDumpIncremental/test6/incr/incremental.df");
        assertFalse(f1.exists());

        executeTarget("test2");
        assertTrue(f1.exists());
    }

    /**
     * Test renameFile attribute on tables
     */
    @Test(groups= {"v11"})
    public void test7() {
        configureProject("PCTDumpIncremental/test7/build.xml");
        executeTarget("base");
        executeTarget("test");

        File f1 = new File("PCTDumpIncremental/test7/incr/incremental1.df");
        File f2 = new File("PCTDumpIncremental/test7/incr/incremental2.df");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        assertTrue(f1.length() > f2.length());
    }

    /**
     * Test renameFile attribute on tables
     */
    @Test(groups= {"v12"})
    public void test9() {
        // Only work with 12.4+
        DLCVersion version = DLCVersion.getObject(new File(System.getProperty("DLC")));
        if ((version.getMajorVersion() == 12) && (version.getMinorVersion() <= 3))
            return;

        configureProject("PCTDumpIncremental/test9/build.xml");
        executeTarget("base");
        executeTarget("test");

        File f1 = new File("PCTDumpIncremental/test9/incr/incremental1.df");
        File f2 = new File("PCTDumpIncremental/test9/incr/incremental2.df");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        assertTrue(f1.length() < f2.length());
    }
}
