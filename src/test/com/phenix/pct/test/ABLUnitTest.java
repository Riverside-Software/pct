/**
 * Copyright 2005-2025 Riverside Software
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
import java.util.ArrayList;
import java.util.List;

import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.apache.tools.ant.BuildException;
import org.testng.annotations.Test;
import org.xml.sax.InputSource;

import com.phenix.pct.DLCVersion;

/**
 * Class for testing ABLUnit task
 * 
 * @author <a href="mailto:b.thoral@riverside-software.fr">Bastien THORAL </a>
 */
public class ABLUnitTest extends BuildFileTestNg {
    private static final String XPATH_TESTS = "/testsuites/@tests";
    private static final String XPATH_FAILURES = "/testsuites/@failures";
    private static final String XPATH_ERRORS = "/testsuites/@errors";

    private final XPath xpath = XPathFactory.newInstance().newXPath();

    // Two test procedures
    @Test(groups = {"v11"})
    public void test1() throws XPathExpressionException {
        configureProject("ABLUnit/test1/build.xml");
        executeTarget("test");

        InputSource inputSource = new InputSource("ABLUnit/test1/results.xml");
        // Should be 6/2/2
        assertEquals(xpath.evaluate(XPATH_TESTS, inputSource), "6");
        assertEquals(xpath.evaluate(XPATH_FAILURES, inputSource), "2");
        assertEquals(xpath.evaluate(XPATH_ERRORS, inputSource), "2");
    }

    // No test, should fail
    @Test(groups = {"v11"}, expectedExceptions = BuildException.class)
    public void test2() {
        configureProject("ABLUnit/test2/build.xml");
        executeTarget("test");
    }

    // Test class
    @Test(groups = {"v11"})
    public void test3() throws XPathExpressionException {
        configureProject("ABLUnit/test3/build.xml");
        executeTarget("test");

        InputSource inputSource = new InputSource("ABLUnit/test3/results.xml");
        assertEquals(xpath.evaluate(XPATH_TESTS, inputSource), "3");
        assertEquals(xpath.evaluate(XPATH_FAILURES, inputSource), "1");
        assertEquals(xpath.evaluate(XPATH_ERRORS, inputSource), "1");
    }

    // Test with different path to resultset
    @Test(groups = {"v11", "win"})
    public void test4() {
        configureProject("ABLUnit/test4/build.xml");
        executeTarget("test");

        File result = new File("ABLUnit/test4/tempDir", "results.xml");
        assertTrue(result.exists());
    }

    // Test with 1 file, 1 case
    @Test(groups = {"v11"})
    public void test6() throws XPathExpressionException {
        configureProject("ABLUnit/test6/build.xml");
        executeTarget("test");

        InputSource inputSource = new InputSource("ABLUnit/test6/results.xml");
        assertEquals(xpath.evaluate(XPATH_TESTS, inputSource), "1");
        assertEquals(xpath.evaluate(XPATH_FAILURES, inputSource), "0");
    }

    // Test haltOnFailure property
    @Test(groups = {"v11"})
    public void test7() {
        configureProject("ABLUnit/test7/build.xml");
        executeTarget("test1");
        expectBuildException("test2", "haltOnFailure is true");
    }

    // Test writeLog property
    @Test(groups = {"v11"})
    public void test8() {
        DLCVersion version = DLCVersion.getObject(new File(System.getProperty("DLC")));

        configureProject("ABLUnit/test8/build.xml");
        File logFile = new File("ABLUnit/test8/temp/ablunit.log");
        assertFalse(logFile.exists());

        // No failure will happen in 11.7.5 to 11.7.9 (fixed in 11.7.10) and 12.2.0 to 12.2.3 (fixed in 12.2.4)
        // Expectation is that a correct version is used. Yes, I don't want to spend time on outdated versions.
        if ((version.getMajorVersion() == 11) && (version.getMinorVersion() <= 7)
                && (Integer.parseInt(version.getMaintenanceVersion()) < 10)) {
            executeTarget("test1");
        } else {
            expectBuildException("test1", "Syntax error");
        }
        assertFalse(logFile.exists());
        if ((version.getMajorVersion() == 11) && (version.getMinorVersion() <= 7)
                && (Integer.parseInt(version.getMaintenanceVersion()) < 10)) {
            executeTarget("test2");
        } else {
            expectBuildException("test2", "Syntax error");
        }
        assertTrue(logFile.exists());
    }

    // Test warning message
    @Test(groups = {"v11"})
    public void test9() {
        configureProject("ABLUnit/test9/build.xml");

        List<String> rexp = new ArrayList<>();
        rexp.add("Fileset directory .* not found in PROPATH");
        rexp.add("QUIT statement found");
        rexp.add("Total tests run: \\d, Failures: 0, Errors: 2");
        expectLogRegexp("test1", rexp, false);

    }

    @Test(groups = {"v11"})
    public void test10() throws XPathExpressionException {
        configureProject("ABLUnit/test10/build.xml");
        executeTarget("test1");

        InputSource inputSource = new InputSource("ABLUnit/test10/results.xml");
        assertEquals(xpath.evaluate(XPATH_TESTS, inputSource), "2");
        assertEquals(xpath.evaluate(XPATH_FAILURES, inputSource), "0");
        assertEquals(xpath.evaluate(XPATH_ERRORS, inputSource), "0");
    }
}