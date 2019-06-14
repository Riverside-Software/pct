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

import java.io.File;
import java.io.IOException;

import org.testng.annotations.Test;

import com.phenix.pct.RCodeInfo.InvalidRCodeException;

/**
 * Class for testing PLFileSet
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PLFileSetTest extends BuildFileTestNg {

    @Test(groups = { "v10" })
    public void test1() {
        // Really crude, but we rely on prodict.pl in $DLC/tty
        // Number of files is different in every release
        try {
            DLCVersion version = DLCVersion.getObject(new File(System.getProperty("DLC")));
            if (version.getMajorVersion() != 10)
                return;
        } catch (IOException e) {
            return;
        } catch (InvalidRCodeException e) {
            return;
        }
        
        configureProject("PLFileSet/test1/build.xml");

        executeTarget("test1");
        File f1 = new File("PLFileSet/test1/lib1/prodict");
        assertEquals(f1.list().length, 36);

        executeTarget("test2");
        File f2 = new File("PLFileSet/test1/lib2/prodict");
        assertEquals(f2.list().length, 14);

        executeTarget("test3");
        File f3 = new File("PLFileSet/test1/lib3/prodict");
        assertEquals(f3.list().length, 3);
    }

    @Test(groups = {"v11"})
    public void test2() {
        DLCVersion version = null;
        // Really crude, but we rely on prodict.pl in $DLC/tty
        // Number of files is different in every release
        try {
            version = DLCVersion.getObject(new File(System.getProperty("DLC")));
            if (version.getMajorVersion() != 11)
                return;
        } catch (IOException e) {
            return;
        } catch (InvalidRCodeException e) {
            return;
        }

        configureProject("PLFileSet/test2/build.xml");

        executeTarget("test1");
        File f1 = new File("PLFileSet/test2/lib1/prodict");
        assertEquals(f1.list().length, version.getMinorVersion() >= 7 ? 40 : 38);

        executeTarget("test2");
        File f2 = new File("PLFileSet/test2/lib2/prodict");
        assertEquals(f2.list().length, 14);

        executeTarget("test3");
        File f3 = new File("PLFileSet/test2/lib3/prodict");
        assertEquals(f3.list().length, 3);
    }

}
