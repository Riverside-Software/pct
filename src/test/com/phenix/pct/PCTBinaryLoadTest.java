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

import org.apache.tools.ant.BuildException;
import org.testng.annotations.Test;

/**
 * Class for testing PCTBinaryLoad task
 *
 * @author <a href="mailto:lieven.cardoen+PCT@gmail.com">Lieven CARDOEN</a>
 */
public class PCTBinaryLoadTest extends BuildFileTestNg {

    /**
     * Should throw BuildException : No database connection defined
     */
    @Test(groups = {"v10"}, expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("PCTBinaryLoad/test1/build.xml");
        executeTarget("test");
    }

    /**
     * Should load binary data into database and expect "16 20" for test target
     */
    @Test(groups = {"v10", "win"})
    public void test2() {
        configureProject("PCTBinaryLoad/test2/build.xml");
        executeTarget("base");
        executeTarget("load");
        expectLog("test", "16 20");
    }

    /**
     * Should first load binary data into table Tab1, then in Tab2
     */
    @Test(groups = {"v10", "win"})
    public void test3() {
        configureProject("PCTBinaryLoad/test3/build.xml");
        executeTarget("base");
        expectLog("test1", "---");
        expectLog("test2", "---");

        executeTarget("load1");
        expectLog("test1", "16");
        expectLog("test2", "---");

        executeTarget("load2");
        expectLog("test1", "16");
        expectLog("test2", "20");
    }

    /**
     * Should load binary data into database using a parameter file
     */
    @Test(groups = {"v10", "win"})
    public void test4() {
        configureProject("PCTBinaryLoad/test4/build.xml");
        executeTarget("base");
        executeTarget("load");
        expectLog("test", "16 20");
    }

    /**
     * Should load binary data into database using a parameter file.
     * Only executed on v11 as proutil load doesn't return an error for invalid codepage on v10
     */
    @Test(groups = {"v11", "win"})
    public void test5() {
        configureProject("PCTBinaryLoad/test5/build.xml");
        executeTarget("base");
        expectBuildException("load", "Load with iso codepage instead of utf");
    }
}
