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

import static org.testng.Assert.assertTrue;

import org.apache.tools.ant.BuildException;
import org.testng.annotations.Test;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

/**
 * Class for testing PCTCRC task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTCRCTest extends BuildFileTestNg {

    @Test(groups= {"v10"}, expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("PCTCRC/test1/build.xml");
        executeTarget("test");
    }

    @Test(groups= {"v10"}, expectedExceptions = BuildException.class)
    public void test2() {
        configureProject("PCTCRC/test2/build.xml");
        executeTarget("test");
    }

    @Test(groups= {"v10"})
    public void test3() {
        configureProject("PCTCRC/test3/build.xml");
        executeTarget("base");
        executeTarget("test");

        File f = new File("PCTCRC/test3/foo/crc.txt");
        assertTrue(f.exists());

        BufferedReader br = null;

        try {
            br = new BufferedReader(new FileReader(f));

            String s = br.readLine();
            assertTrue(s.startsWith("test.Tab1"));
        } catch (FileNotFoundException fnfe) {
        } catch (IOException ioe) {
        } finally {
            try {
                br.close();
            } catch (IOException ioe) {
            }
        }
    }

    @Test(groups= {"v10"})
    public void test4() {
        configureProject("PCTCRC/test4/build.xml");
        executeTarget("base");
        executeTarget("test");

        File f = new File("PCTCRC/test4/foo/crc.txt");
        assertTrue(f.exists());

        BufferedReader br = null;

        try {
            br = new BufferedReader(new FileReader(f));

            String s = br.readLine();
            assertTrue(s.startsWith("test.Tab1"));
            s = br.readLine();
            assertTrue(s.startsWith("test2.Tab1"));
        } catch (FileNotFoundException fnfe) {
        } catch (IOException ioe) {
        } finally {
            try {
                br.close();
            } catch (IOException ioe) {
            }
        }
    }
}
