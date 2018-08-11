/**
 * Copyright 2017-2018 MIP Holdings
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
package za.co.mip.ablduck;

import static org.testng.Assert.assertEquals;
import static org.testng.Assert.assertTrue;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.testng.annotations.Test;

import com.google.gson.Gson;
import com.phenix.pct.BuildFileTestNg;

import za.co.mip.ablduck.models.DataJSObject;
import za.co.mip.ablduck.models.SourceJSObject;

/**
 * Class for testing ABLDuck task
 * 
 * @author <a href="mailto:robertedwardsmail@gmail.com">Robert Edwards</a>
 */
public class ABLDuckTest extends BuildFileTestNg {
    private Gson gson = new Gson();

    @Test(groups = {"v11"})
    public void testGenerateDocs() {
        configureProject("ABLDuck/test/build.xml");
        executeTarget("test");
    }

    @Test(groups = {"v11"}, dependsOnMethods = {"testGenerateDocs"})
    public void testDataJSFile() throws IOException {
        String filename = "ABLDuck/test/docs/data.js";

        // Does the data js file exist
        File f1 = new File(filename);
        assertTrue(f1.exists());

        String content = new String(Files.readAllBytes(Paths.get(filename)));
        content = content.substring(15, content.length() - 1);

        DataJSObject dataJSObject = gson.fromJson(content, DataJSObject.class);

        // Should contain 2 classes
        assertEquals(dataJSObject.classes.size(), 2);

        // Should contain 2 classes, 1 property and 2 methods, 1 constructor and 1 event
        assertEquals(dataJSObject.search.size(), 7);
    }

    @Test(groups = {"v11"}, dependsOnMethods = {"testGenerateDocs"})
    public void testSourceJSFiles() throws IOException {

        // Does the source js files exist
        String filename = "ABLDuck/test/docs/output/base.class.js";
        File f1 = new File(filename);
        assertTrue(f1.exists());

        String content = new String(Files.readAllBytes(Paths.get(filename)));
        content = content.substring(content.indexOf("(") + 1, content.length() - 2);

        SourceJSObject js = gson.fromJson(content, SourceJSObject.class);

        // Should contain 2 methods and 1 property
        assertEquals(js.members.size(), 3);

        assertEquals(js.id, "class-base.class");
        assertEquals(js.tagname, "class");
        assertEquals(js.name, "base.class");
        assertEquals(js.ext, "");
        assertEquals(js.meta.deprecated.version, "0.0.1");
        assertEquals(js.subclasses.size(), 1);
        assertEquals(js.superclasses.size(), 0);

        // Does the source js files exist
        filename = "ABLDuck/test/docs/output/test.js";
        f1 = new File(filename);
        assertTrue(f1.exists());

        content = new String(Files.readAllBytes(Paths.get(filename)));
        content = content.substring(content.indexOf("(") + 1, content.length() - 2);

        js = gson.fromJson(content, SourceJSObject.class);

        // Should contain 2 methods 1 property, 1 constructor and 1 event
        assertEquals(js.members.size(), 5);

        assertEquals(js.id, "class-test");
        assertEquals(js.tagname, "class");
        assertEquals(js.name, "test");
        assertEquals(js.ext, "base.class");
        assertEquals(js.subclasses.size(), 0);
        assertEquals(js.superclasses.size(), 2);

    }
}
