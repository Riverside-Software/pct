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

import java.io.File;

import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.testng.Assert;
import org.testng.annotations.Test;
import org.xml.sax.InputSource;

/**
 * Class for testing PCTSchemaDoc task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTSchemaDocTest extends BuildFileTestNg {
    private final XPath xpath = XPathFactory.newInstance().newXPath();

    @Test(groups = {"v10"})
    public void test1() throws XPathExpressionException {
        configureProject("PCTSchemaDoc/test1/build.xml");
        executeTarget("test");

        assertTrue(new File("PCTSchemaDoc/test1/doc.xml").exists());
        InputSource inputSource = new InputSource("PCTSchemaDoc/test1/doc.xml");
        Assert.assertEquals(
                xpath.evaluate("//database/area[@name='Schema Area']/@num", inputSource), "6");
        Assert.assertEquals(xpath.evaluate("//database/area[@name='Employee']/@num", inputSource),
                "7");
        Assert.assertEquals(
                xpath.evaluate("//database/sequence[@name='NextBinNum']/@cycle", inputSource),
                "no");
        Assert.assertEquals(
                xpath.evaluate("//database/table[@name='Benefits']/@areaNum", inputSource), "7");
        Assert.assertEquals(
                xpath.evaluate("//database/table[@name='Benefits']/field[@name='EmpNum']/@dataType",
                        inputSource),
                "integer");
    }

}
