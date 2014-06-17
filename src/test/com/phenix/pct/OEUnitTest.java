/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) The Apache Software Foundation.  All rights
 * reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution, if
 *    any, must include the following acknowlegement:
 *       "This product includes software developed by the
 *        Apache Software Foundation (http://www.apache.org/)."
 *    Alternately, this acknowlegement may appear in the software itself,
 *    if and wherever such third-party acknowlegements normally appear.
 *
 * 4. The names "Ant" and "Apache Software
 *    Foundation" must not be used to endorse or promote products derived
 *    from this software without prior written permission. For written
 *    permission, please contact apache@apache.org.
 *
 * 5. Products derived from this software may not be called "Apache"
 *    nor may "Apache" appear in their names without prior written
 *    permission of the Apache Group.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE APACHE SOFTWARE FOUNDATION OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation.  For more
 * information on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
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
 * Class for testing ABLUnit task
 * 
 * @author <a href="mailto:b.thoral@riverside-software.fr">Bastien THORAL </a>
 */
public class OEUnitTest extends BuildFileTestNg {
    private final XPath xpath = XPathFactory.newInstance().newXPath();

    // Regular run of 2 test procedures
    @Test(groups = {"v10"})
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
    @Test(groups = {"v10"})
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
    @Test(groups = {"v10"})
    public void test3() throws XPathExpressionException {
        configureProject("OEUnit/test3/build.xml");
        executeTarget("test");

        InputSource inputSource = new InputSource("OEUnit/test3/FirstTestSuite.xml");
        Assert.assertEquals(xpath.evaluate("/testsuites/@tests", inputSource), "4");
        Assert.assertEquals(xpath.evaluate("/testsuites/@failures", inputSource), "0");
        Assert.assertEquals(xpath.evaluate("/testsuites/@errors", inputSource), "0");
    }

    // Test all report formats
    @Test(groups = {"v10"})
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