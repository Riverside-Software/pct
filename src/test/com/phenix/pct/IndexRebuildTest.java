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

import org.testng.annotations.Test;

/**
 * Class for testing IndexRebuild task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class IndexRebuildTest extends BuildFileTestNg {

    @Test(groups = {"v10"})
    public void test1() {
        configureProject("IndexRebuild/test1/build.xml");
        executeTarget("init");
        expectBuildException("check", "No index yet");
        executeTarget("test");
        executeTarget("check");
    }

    @Test(groups = {"v10"})
    public void test2() {
        configureProject("IndexRebuild/test2/build.xml");
        executeTarget("init");
        expectBuildException("test1", "No index node");
        executeTarget("test2");
        File log = new File("IndexRebuild/test2/test.log");
        assertTrue(log.exists());
        expectBuildException("test3", "Invalid cpinternal");
    }

    @Test(groups = {"v10"})
    public void test3() {
        configureProject("IndexRebuild/test3/build.xml");
        executeTarget("init");
        expectBuildException("test1", "Invalid index node");
        expectBuildException("test2", "Invalid index node");
    }

    @Test(groups = {"v10"})
    public void test4() {
        configureProject("IndexRebuild/test4/build.xml");
        executeTarget("init");
        executeTarget("test1");
        expectBuildException("test2", "Invalid option value");
    }
}
