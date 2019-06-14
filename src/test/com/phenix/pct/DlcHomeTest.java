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

import javax.xml.xpath.XPathExpressionException;

import org.testng.Assert;
import org.testng.annotations.Test;

public class DlcHomeTest extends BuildFileTestNg {

    @Test(groups = {"v10"})
    public void test1() throws XPathExpressionException {
        configureProject("DlcHome/test1/build.xml");
        executeTarget("test");
        assertPropertyEquals(DlcHome.GLOBAL_DLCHOME, System.getProperty("DLC"));
        executeTarget("test2");
    }

    @Test(groups = {"v10"})
    public void test2() throws XPathExpressionException {
        configureProject("DlcHome/test2/build.xml");
        executeTarget("test");
        Assert.assertTrue(getProject().getProperty(DlcHome.GLOBAL_DLCHOME).endsWith("foobar"));
        expectBuildException("test2", "DLC not set correctly");
    }
}
