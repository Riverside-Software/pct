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

import org.testng.annotations.Test;

import java.io.File;

/**
 * Class for testing Sports2000 task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class Sports2000Test extends BuildFileTestNg {

    @Test(groups= {"v10"})
    public void test1() {
        configureProject("Sports2000/test1/build.xml");
        
        executeTarget("test1");
        File f1 = new File("Sports2000/test1/sports2000.db");
        assertTrue(f1.exists());

        executeTarget("test2");
        File f2 = new File("Sports2000/test1/sp2k.db");
        assertTrue(f2.exists());

        executeTarget("test3");
        File f3 = new File("Sports2000/test1/db/sports2000.db");
        assertTrue(f3.exists());

        executeTarget("test4");
        File f4 = new File("Sports2000/test1/db/sp2k.db");
        assertTrue(f4.exists());
    }

}
