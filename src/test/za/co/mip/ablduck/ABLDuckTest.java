/**
 * Copyright 2017-2019 MIP Holdings
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

import za.co.mip.ablduck.models.CompilationUnit;
import za.co.mip.ablduck.models.Data;

/**
 * Class for testing ABLDuck task
 * 
 * @author <a href="mailto:robertedwardsmail@gmail.com">Robert Edwards</a>
 */
public class ABLDuckTest extends BuildFileTestNg {
    private static final String FILENAME = "ABLDuck/test/docs/data.js";
    private Gson gson = new Gson();

    @Test(groups = {"v11"})
    public void testGenerateDocs() {
        configureProject("ABLDuck/test/build.xml");
        executeTarget("test");
    }

    @Test(groups = {"v11"}, dependsOnMethods = {"testGenerateDocs"})
    public void checkDataFile() {
        // Does the data js file exist
        File f1 = new File(FILENAME);
        assertTrue(f1.exists());
    }

    @Test(groups = {"v11"}, dependsOnMethods = {"checkDataFile"})
    public void checkClassCount() throws IOException {
        String content = new String(Files.readAllBytes(Paths.get(FILENAME)));
        content = content.substring(15, content.length() - 1);

        Data data = gson.fromJson(content, Data.class);
        assertEquals(data.classes.size(), 2);
    }

    @Test(groups = {"v11"}, dependsOnMethods = {"checkDataFile"})
    public void checkProcedureCount() throws IOException {
        String content = new String(Files.readAllBytes(Paths.get(FILENAME)));
        content = content.substring(15, content.length() - 1);

        Data data = gson.fromJson(content, Data.class);
        assertEquals(data.procedures.size(), 1);
    }

    @Test(groups = {"v11"}, dependsOnMethods = {"checkDataFile"})
    public void checkSearchCount() throws IOException {
        String content = new String(Files.readAllBytes(Paths.get(FILENAME)));
        content = content.substring(15, content.length() - 1);

        Data data = gson.fromJson(content, Data.class);
        assertEquals(data.search.size(), 14);
    }

    @Test(groups = {"v11"}, dependsOnMethods = {"testGenerateDocs"})
    public void checkBaseClassCreated() {
        String filename = "ABLDuck/test/docs/output/classes/base.class.js";
        File f1 = new File(filename);
        assertTrue(f1.exists());
    }

    @Test(groups = {"v11"}, dependsOnMethods = {"testGenerateDocs"})
    public void checkTestClassCreated() {
        String filename = "ABLDuck/test/docs/output/classes/test.js";
        File f1 = new File(filename);
        assertTrue(f1.exists());
    }

    @Test(groups = {"v11"}, dependsOnMethods = {"testGenerateDocs"})
    public void checkTestProcedureCreated() {
        String filename = "ABLDuck/test/docs/output/procedures/test_p.js";
        File f1 = new File(filename);
        assertTrue(f1.exists());
    }

    @Test(groups = {"v11"}, dependsOnMethods = {"checkBaseClassCreated"})
    public void checkBaseClassMetadata() throws IOException {
        String filename = "ABLDuck/test/docs/output/classes/base.class.js";

        String content = new String(Files.readAllBytes(Paths.get(filename)));
        content = content.substring(content.indexOf('(') + 1, content.length() - 2);

        CompilationUnit js = gson.fromJson(content, CompilationUnit.class);
        assertEquals(js.members.size(), 3);
        assertEquals(js.id, "class-base.class");
        assertEquals(js.tagname, "class");
        assertEquals(js.name, "base.class");
        assertEquals(js.inherits, "");
        assertEquals(js.meta.isDeprecated.version, "0.0.1");
        assertEquals(js.subclasses.size(), 1);
        assertEquals(js.superclasses.size(), 1);
    }

    @Test(groups = {"v11"}, dependsOnMethods = {"checkTestClassCreated"})
    public void checkTestClassMetadata() throws IOException {
        String filename = "ABLDuck/test/docs/output/classes/test.js";

        String content = new String(Files.readAllBytes(Paths.get(filename)));
        content = content.substring(content.indexOf('(') + 1, content.length() - 2);

        CompilationUnit js = gson.fromJson(content, CompilationUnit.class);
        assertEquals(js.members.size(), 5);
        assertEquals(js.id, "class-test");
        assertEquals(js.tagname, "class");
        assertEquals(js.name, "test");
        assertEquals(js.inherits, "base.class");
        assertEquals(js.subclasses.size(), 0);
        assertEquals(js.superclasses.size(), 2);
    }

    @Test(groups = {"v11"}, dependsOnMethods = {"checkTestProcedureCreated"})
    public void checkTestProcedureMetadata() throws IOException {
        String filename = "ABLDuck/test/docs/output/procedures/test_p.js";

        String content = new String(Files.readAllBytes(Paths.get(filename)));
        content = content.substring(content.indexOf('(') + 1, content.length() - 2);

        CompilationUnit js = gson.fromJson(content, CompilationUnit.class);
        assertEquals(js.members.size(), 6);
        assertEquals(js.id, "procedure-test");
        assertEquals(js.tagname, "procedure");
        assertEquals(js.name, "test.p");
        assertEquals(js.parameters.size(), 1);
        assertEquals(js.meta.isDeprecated.version, "1.0.0");
    }

}
