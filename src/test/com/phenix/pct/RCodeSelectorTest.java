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

import static org.testng.Assert.assertEquals;
import static org.testng.Assert.assertTrue;

import org.testng.annotations.Test;

import java.io.File;
import java.util.Arrays;
import java.util.List;

/**
 * Class for testing RCodeSelector
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class RCodeSelectorTest extends BuildFileTestNg {

    @Test(groups = { "v10" })
    public void test1() {
        configureProject("RCodeSelector/test1/build.xml");
        executeTarget("prepare");

        executeTarget("test1");

        File f1 = new File("RCodeSelector/test1/copy1");
        assertEquals(0, f1.list().length);

        File f2 = new File("RCodeSelector/test1/copy2");
        assertEquals(0, f2.list().length);

        File f3 = new File("RCodeSelector/test1/copy3");
        assertEquals(1, f3.list().length);
        assertTrue(f3.list()[0].equals("test2.r"));

        File f4 = new File("RCodeSelector/test1/copy4");
        assertEquals(1, f4.list().length);
        assertTrue(f4.list()[0].equals("test2.r"));

        File f5 = new File("RCodeSelector/test1/copy5");
        assertEquals(0, f5.list().length);

        File f6 = new File("RCodeSelector/test1/copy6");
        assertEquals(1, f6.list().length);
        assertTrue(f6.list()[0].equals("test3.r"));

        File f7 = new File("RCodeSelector/test1/copy7");
        assertEquals(1, f7.list().length);
        assertTrue(f7.list()[0].equals("test2.r"));

        File f8 = new File("RCodeSelector/test1/copy8");
        assertEquals(2, f8.list().length);
        List<String> tmp =  Arrays.asList(f8.list());
        assertTrue(tmp.contains("test2.r"));
        assertTrue(tmp.contains("test3.r"));

        executeTarget("test2");
        f1 = new File("RCodeSelector/test1/copylib1");
        assertEquals(0, f1.list().length);

        f2 = new File("RCodeSelector/test1/copylib2");
        assertEquals(0, f2.list().length);

        f3 = new File("RCodeSelector/test1/copylib3");
        assertEquals(1, f3.list().length);
        assertTrue(f3.list()[0].equals("test2.r"));

        f4 = new File("RCodeSelector/test1/copylib4");
        assertEquals(1, f4.list().length);
        assertTrue(f4.list()[0].equals("test2.r"));

        f5 = new File("RCodeSelector/test1/copylib5");
        assertEquals(0, f5.list().length);

        f6 = new File("RCodeSelector/test1/copylib6");
        assertEquals(1, f6.list().length);
        assertTrue(f6.list()[0].equals("test3.r"));

        f7 = new File("RCodeSelector/test1/copylib7");
        assertEquals(1, f7.list().length);
        assertTrue(f7.list()[0].equals("test2.r"));

        f8 = new File("RCodeSelector/test1/copylib8");
        assertEquals(2, f8.list().length);
        List<String> tmp2 =  Arrays.asList(f8.list());
        assertTrue(tmp2.contains("test2.r"));
        assertTrue(tmp2.contains("test3.r"));
    }

}
