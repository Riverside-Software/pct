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

import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.List;

import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.apache.tools.ant.BuildException;
import org.testng.Assert;
import org.testng.annotations.Test;
import org.xml.sax.InputSource;

/**
 * Class for testing ABLUnit task
 * 
 * @author <a href="mailto:b.thoral@riverside-software.fr">Bastien THORAL </a>
 */
public class ABLUnitTest extends BuildFileTestNg {
    private final XPath xpath = XPathFactory.newInstance().newXPath();

    // Two test procedures
    @Test(groups = {"v11"})
    public void test1() throws XPathExpressionException {
        configureProject("ABLUnit/test1/build.xml");
        executeTarget("test");

        InputSource inputSource = new InputSource("ABLUnit/test1/results.xml");
        // Should be 6/2/2
        Assert.assertEquals(xpath.evaluate("/testsuites/@tests", inputSource), "6");
        Assert.assertEquals(xpath.evaluate("/testsuites/@failures", inputSource), "2");
        Assert.assertEquals(xpath.evaluate("/testsuites/@errors", inputSource), "2");
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
        Assert.assertEquals(xpath.evaluate("/testsuites/@tests", inputSource), "3");
        Assert.assertEquals(xpath.evaluate("/testsuites/@failures", inputSource), "1");
        Assert.assertEquals(xpath.evaluate("/testsuites/@errors", inputSource), "1");
    }

    // Test with different path to resultset
    @Test(groups = {"v11", "win"})
    public void test4() throws XPathExpressionException, FileNotFoundException {
        configureProject("ABLUnit/test4/build.xml");
        executeTarget("test");

        File result = new File("ABLUnit/test4/tempDir", "results.xml");
        Assert.assertTrue(result.exists());
    }

    // Test with 1 file, 1 case
    @Test(groups = {"v11"})
    public void test6() throws XPathExpressionException {
        configureProject("ABLUnit/test6/build.xml");
        executeTarget("test");

        InputSource inputSource = new InputSource("ABLUnit/test6/results.xml");
        Assert.assertEquals(xpath.evaluate("/testsuites/@tests", inputSource), "1");
        Assert.assertEquals(xpath.evaluate("/testsuites/@failures", inputSource), "0");
    }

    // Test haltOnFailure property
    @Test(groups = {"v11"})
    public void test7() throws XPathExpressionException {
        configureProject("ABLUnit/test7/build.xml");
        executeTarget("test1");
        expectBuildException("test2", "haltOnFailure is true");
    }

    // Test writeLog property
    @Test(groups = {"v11"})
    public void test8() throws XPathExpressionException {
        configureProject("ABLUnit/test8/build.xml");
        File logFile = new File("ABLUnit/test8/temp/ablunit.log");
        Assert.assertFalse(logFile.exists());
        expectBuildException("test1", "Syntax error");
        Assert.assertFalse(logFile.exists());
        expectBuildException("test2", "Syntax error");
        Assert.assertTrue(logFile.exists());
    }

    // Test warning message
    @Test(groups = {"v11"})
    public void test9() throws XPathExpressionException {
        configureProject("ABLUnit/test9/build.xml");

        List<String> rexp = new ArrayList<>();
        rexp.add("Fileset directory .* not found in PROPATH");
        rexp.add("QUIT statement found");
        rexp.add("Total tests run: 2, Failures: 0, Errors: 2");
        expectLogRegexp("test1", rexp, false);

    }
}