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

import java.io.File;
import java.io.FileNotFoundException;

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

    // Regular run of 2 test procedures
    @Test(groups = {"v11"})
    public void test1() throws XPathExpressionException {
        configureProject("ABLUnit/test1/build.xml");
        executeTarget("test");

        InputSource inputSource = new InputSource("ABLUnit/test1/results.xml");
        // Should be 2/2/2
        Assert.assertEquals(xpath.evaluate("/testrun/@success", inputSource), "4");
        Assert.assertEquals(xpath.evaluate("/testrun/@failures", inputSource), "2");
        Assert.assertEquals(xpath.evaluate("/testrun/@errors", inputSource), "0");
    }

    // Build error, No tests to run
    @Test(groups = {"v11"}, expectedExceptions = BuildException.class)
    public void test2() {
        configureProject("ABLUnit/test2/build.xml");
        executeTarget("test");
    }

    // Test runned with classe
    @Test(groups = {"v11"})
    public void test3() throws XPathExpressionException {
        configureProject("ABLUnit/test3/build.xml");
        executeTarget("test");

        InputSource inputSource = new InputSource("ABLUnit/test3/results.xml");
        Assert.assertEquals(xpath.evaluate("/testrun/@success", inputSource), "1");
        Assert.assertEquals(xpath.evaluate("/testrun/@failures", inputSource), "1");
        Assert.assertEquals(xpath.evaluate("/testrun/@errors", inputSource), "1");
    }

    // Test with different path to resultset
    // TODO Doesn't work on Linux for now (due to ablunit.pl)
    @Test(groups = {"v11", "win"})
    public void test4() throws XPathExpressionException, FileNotFoundException {
        configureProject("ABLUnit/test4/build.xml");
        executeTarget("test");
        // XXX Non, on n'écrit pas /tmp parce qu'à la prochaine exécution le fichier sera  toujours là

        File result = new File("ABLUnit/test4/tempDir", "results.xml");
        Assert.assertTrue(result.exists());
    }

    // Test with 1 file, 1 case
    @Test(groups = {"v11"})
    public void test6() throws XPathExpressionException {
        configureProject("ABLUnit/test6/build.xml");
        executeTarget("test");

        // XXX Ne correspond pas au jeu de test à mon avis
        InputSource inputSource = new InputSource("ABLUnit/test6/results.xml");
        Assert.assertEquals(xpath.evaluate("/testrun/@success", inputSource), "1");
        Assert.assertEquals(xpath.evaluate("/testrun/@failures", inputSource), "0");
    }
}