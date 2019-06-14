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

import org.testng.Assert;
import org.testng.annotations.Test;

/**
 * Class for testing ABLUnit task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class RestGenTest extends BuildFileTestNg {

    @Test(groups = {"v11", "win"})
    public void test1() {
        configureProject("RestGen/test1/build.xml");
        executeTarget("test");

        File paar = new File("RestGen/test1/dist/REST.paar");
        Assert.assertTrue(paar.exists());
    }

}