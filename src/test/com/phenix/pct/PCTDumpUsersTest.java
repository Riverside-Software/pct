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
import static org.testng.Assert.assertEquals;

import org.apache.tools.ant.BuildException;
import org.testng.annotations.Test;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

/**
 * Class for testing PCTDumpUsers task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class PCTDumpUsersTest extends BuildFileTestNg {

    /**
     * Should throw BuildException : no destFile and no connection
     */
    @Test(groups= {"v11"}, expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("PCTDumpUsers/test1/build.xml");
        executeTarget("test");
    }

    /**
     * Should throw BuildException : no connection defined
     */
    @Test(groups= {"v11"}, expectedExceptions = BuildException.class)
    public void test2() {
        configureProject("PCTDumpUsers/test2/build.xml");
        executeTarget("test");
    }

    /**
     * Should throw BuildException : more than one connection defined
     */
    @Test(groups= {"v11"}, expectedExceptions = BuildException.class)
    public void test3() {
        configureProject("PCTDumpUsers/test3/build.xml");
        executeTarget("test");
    }

    /**
     * No users in database, so no dump file
     */
    @Test(groups= {"v11"})
    public void test4() {
        configureProject("PCTDumpUsers/test4/build.xml");
        executeTarget("prepare");
        executeTarget("test");

        File f1 = new File("PCTDumpUsers/test4/foo/_User.d");
        assertFalse(f1.exists());
    }

    /**
     * Should load 3 records in _User, and then dump 3 records
     */
    @Test(groups= {"v11"})
    public void test5() {
        configureProject("PCTDumpUsers/test5/build.xml");
        executeTarget("prepare");
        executeTarget("assert");

        executeTarget("test");
        File f1 = new File("PCTDumpUsers/test5/foo/_user.d");
        assertTrue(f1.exists());
        assertEquals(countUsers(f1), 3);
    }

    // Quick'n'dirty method to count number of users in dump file
    private int countUsers(File f) {
        int count = 0;

        try (FileReader r1 = new FileReader(f); BufferedReader reader = new BufferedReader(r1)) {
            String str = reader.readLine();

            while ((str != null) && !".".equals(str)) {
                count++;
                str = reader.readLine();
            }
        } catch (IOException uncaught) {
            // No-op
        }

        return count;
    }
}