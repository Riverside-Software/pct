/**
 * Copyright 2005-2018 Riverside Software
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

import java.io.File;

import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.testng.Assert;
import org.testng.annotations.Test;
import org.xml.sax.InputSource;

/**
 * Class for testing OEUnit task
 * 
 * @author <a href="mailto:b.thoral@riverside-software.fr">Bastien THORAL </a>
 */
public class OEUnitTest extends BuildFileTestNg {
    private final XPath xpath = XPathFactory.newInstance().newXPath();

    // Regular run of 2 test procedures
    @Test(groups = {"v10", "nov12"})
    public void test1() throws XPathExpressionException {
        configureProject("OEUnit/test1/build.xml");
        executeTarget("test");

        InputSource inputSource = new InputSource("OEUnit/test1/OEReports/FirstOEUnitTest.xml");
        Assert.assertEquals(xpath.evaluate("/testsuite/@tests", inputSource), "3");
        Assert.assertEquals(xpath.evaluate("/testsuite/@failures", inputSource), "0");
        Assert.assertEquals(xpath.evaluate("/testsuite/@errors", inputSource), "0");

        inputSource = new InputSource("OEUnit/test1/OEReports/StandAloneTests.xml");
        Assert.assertEquals(xpath.evaluate("/testsuite/@tests", inputSource), "1");
        Assert.assertEquals(xpath.evaluate("/testsuite/@failures", inputSource), "0");
        Assert.assertEquals(xpath.evaluate("/testsuite/@errors", inputSource), "0");
    }

    // No output dir, default value instead
    @Test(groups = {"v10", "nov12"})
    public void test2() throws XPathExpressionException {
        configureProject("OEUnit/test2/build.xml");
        executeTarget("test");

        InputSource inputSource = new InputSource("OEUnit/test2/FirstOEUnitTest.xml");
        Assert.assertEquals(xpath.evaluate("/testsuite/@tests", inputSource), "3");
        Assert.assertEquals(xpath.evaluate("/testsuite/@failures", inputSource), "0");
        Assert.assertEquals(xpath.evaluate("/testsuite/@errors", inputSource), "0");

        inputSource = new InputSource("OEUnit/test2/StandAloneTests.xml");
        Assert.assertEquals(xpath.evaluate("/testsuite/@tests", inputSource), "1");
        Assert.assertEquals(xpath.evaluate("/testsuite/@failures", inputSource), "0");
        Assert.assertEquals(xpath.evaluate("/testsuite/@errors", inputSource), "0");
    }

    // Running a test suite class
    @Test(groups = {"v10", "nov12"})
    public void test3() throws XPathExpressionException {
        configureProject("OEUnit/test3/build.xml");
        executeTarget("test");

        InputSource inputSource = new InputSource("OEUnit/test3/FirstTestSuite.xml");
        Assert.assertEquals(xpath.evaluate("/testsuites/@tests", inputSource), "4");
        Assert.assertEquals(xpath.evaluate("/testsuites/@failures", inputSource), "0");
        Assert.assertEquals(xpath.evaluate("/testsuites/@errors", inputSource), "0");
    }

    // Test all report formats
    @Test(groups = {"v10", "nov12"})
    public void test4() throws XPathExpressionException {
        configureProject("OEUnit/test4/build.xml");
        executeTarget("test");

        File f = new File("OEUnit/test4/FirstOEUnitTest.csv");
        assertTrue(f.exists());
        f = new File("OEUnit/test4/FirstOEUnitTest.txt");
        assertTrue(f.exists());
        f = new File("OEUnit/test4/FirstOEUnitTest.xml");
        assertTrue(f.exists());
        f = new File("OEUnit/test4/SureFire-report/FirstOEUnitTest.xml");
        assertTrue(f.exists());
    }
}