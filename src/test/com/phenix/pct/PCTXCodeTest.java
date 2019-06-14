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
 * Class for testing PCTXCode task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTXCodeTest extends BuildFileTestNg {

    @Test(groups= {"v10"})
    public void test1() {
        configureProject("PCTXCode/test1/build.xml");
        executeTarget("test");

        assertTrue(new File("PCTXCode/test1/src/xcode/dir1/test1.p").exists());
        assertTrue(new File("PCTXCode/test1/src/xcode/test2.p").exists());
        assertTrue(new File("PCTXCode/test1/src/xcode/dir1/dir2/test3.p").exists());
        assertTrue(new File("PCTXCode/test1/src/xcode/test1.p").exists());
    }

}
