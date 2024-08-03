/**
 * Copyright 2005-2024 Riverside Software
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

/**
 * RestGen task unit tests
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class RestGenTest extends BuildFileTestNg {

    @Test(groups = {"v11", "win", "nov12", "nov13"})
    public void test1() {
        configureProject("RestGen/test1/build.xml");
        executeTarget("test");

        assertTrue(new File("RestGen/test1/dist/REST.paar").exists());
        assertTrue(new File("RestGen/test1/dist/REST.mobpaar").exists());
        assertTrue(new File("RestGen/test1/dist/REST.restwar").exists());
        assertTrue(new File("RestGen/test1/dist/REST.mobwar").exists());
    }

}