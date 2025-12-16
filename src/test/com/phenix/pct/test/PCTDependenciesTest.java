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
import static org.testng.Assert.assertTrue;

import java.io.File;

import org.testng.annotations.Test;

public class PCTDependenciesTest extends BuildFileTestNg {

    String getBaseDir() {
        return "Dependencies/";
    }

    @Test(groups= {"v12"})
    public void test01() {
        configureProject(getBaseDir() + "test01/build.xml");
        executeTarget("test");

        File f1 = new File(getBaseDir() + "test01/build/test.r");
        assertTrue(f1.exists());
        File f2 = new File(getBaseDir() + "test01/.dependencies/1e8bbe326d05d194a49b38a907e6e9af0a157c19/libcef.dll");
        assertTrue(f2.exists());
        File f3 = new File(getBaseDir() + "test01/myAssemblies/assemblies.config");
        assertTrue(f3.exists());
    }
}
