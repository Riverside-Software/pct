/**
 * Copyright 2017-2024 MIP Holdings
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
package za.co.mip.ablduck.test;

import static org.testng.Assert.assertEquals;
import static org.testng.Assert.assertTrue;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.testng.annotations.Test;

import com.google.gson.Gson;
import com.phenix.pct.test.BuildFileTestNg;

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

    @Test(groups = {"v11"})
    public void test2GenerateDocs() {
        configureProject("ABLDuck/test2/build.xml");
        executeTarget("test2");
    }

    @Test(groups = {"v11"}, dependsOnMethods = {"test2GenerateDocs"})
    public void check2HierarchyMetadata() throws IOException {
        String filename = "ABLDuck/test2/docs/output/classes/hierarchy.Father.js";

        String content = new String(Files.readAllBytes(Paths.get(filename)));
        content = content.substring(content.indexOf('(') + 1, content.length() - 2);

        CompilationUnit js = gson.fromJson(content, CompilationUnit.class);
        assertEquals(js.subclasses.size(), 1);
        assertEquals(js.subclasses.get(0), "hierarchy.Son");

        filename = "ABLDuck/test2/docs/output/classes/hierarchy.Son.js";

        content = new String(Files.readAllBytes(Paths.get(filename)));
        content = content.substring(content.indexOf('(') + 1, content.length() - 2);

        js = gson.fromJson(content, CompilationUnit.class);
        assertEquals(js.superclasses.size(), 2);
        assertEquals(js.superclasses.get(0), "hierarchy.Father");
        assertEquals(js.superclasses.get(1), "hierarchy.Son");
        assertEquals(js.implementations.size(), 1);
        assertEquals(js.implementations.get(0), "hierarchy.IFamily");

        filename = "ABLDuck/test2/docs/output/classes/hierarchy.GrandSon.js";

        content = new String(Files.readAllBytes(Paths.get(filename)));
        content = content.substring(content.indexOf('(') + 1, content.length() - 2);

        js = gson.fromJson(content, CompilationUnit.class);
        assertEquals(js.superclasses.size(), 3);
        assertEquals(js.superclasses.get(0), "hierarchy.Father");
        assertEquals(js.superclasses.get(1), "hierarchy.Son");
        assertEquals(js.superclasses.get(2), "hierarchy.GrandSon");
        assertEquals(js.implementations.size(), 0);
        assertEquals(js.members.get(4).id, "method-hierarchy_Father_HelloWorldFather");
        assertEquals(js.members.get(4).tagname, "method");
        assertEquals(js.members.get(4).owner, "hierarchy.Father");


        filename = "ABLDuck/test2/docs/output/classes/hierarchy.IFamily.js";

        content = new String(Files.readAllBytes(Paths.get(filename)));
        content = content.substring(content.indexOf('(') + 1, content.length() - 2);

        js = gson.fromJson(content, CompilationUnit.class);
        assertEquals(js.implementers.size(), 1);
        assertEquals(js.implementers.get(0), "hierarchy.Son");
    }

    @Test(groups = {"v11"}, dependsOnMethods = {"test2GenerateDocs"})
    public void check2HeaderMetadata() throws IOException {
        String filename = "ABLDuck/test2/docs/output/classes/header.ClassHeader1.js";

        String content = new String(Files.readAllBytes(Paths.get(filename)));
        content = content.substring(content.indexOf('(') + 1, content.length() - 2);

        CompilationUnit js = gson.fromJson(content, CompilationUnit.class);
        assertEquals(js.author, "Han Solo");

        filename = "ABLDuck/test2/docs/output/classes/header.ClassHeader2.js";

        content = new String(Files.readAllBytes(Paths.get(filename)));
        content = content.substring(content.indexOf('(') + 1, content.length() - 2);

        js = gson.fromJson(content, CompilationUnit.class);
        assertEquals(js.author, "Han Solo");

        filename = "ABLDuck/test2/docs/output/classes/header.ClassHeader3.js";

        content = new String(Files.readAllBytes(Paths.get(filename)));
        content = content.substring(content.indexOf('(') + 1, content.length() - 2);

        js = gson.fromJson(content, CompilationUnit.class);
        assertEquals(js.author, "Han Solo");

        filename = "ABLDuck/test2/docs/output/classes/header.EnumHeader1.js";

        content = new String(Files.readAllBytes(Paths.get(filename)));
        content = content.substring(content.indexOf('(') + 1, content.length() - 2);

        js = gson.fromJson(content, CompilationUnit.class);
        assertEquals(js.author, "Han Solo");

        filename = "ABLDuck/test2/docs/output/classes/header.InterfaceHeader1.js";

        content = new String(Files.readAllBytes(Paths.get(filename)));
        content = content.substring(content.indexOf('(') + 1, content.length() - 2);

        js = gson.fromJson(content, CompilationUnit.class);
        assertEquals(js.author, "Han Solo");

        filename = "ABLDuck/test2/docs/output/procedures/header_ProcHeader1_p.js";

        content = new String(Files.readAllBytes(Paths.get(filename)));
        content = content.substring(content.indexOf('(') + 1, content.length() - 2);

        js = gson.fromJson(content, CompilationUnit.class);
        assertEquals(js.author, "Han Solo");
        assertEquals(js.parameters.size(), 2);
        assertEquals(js.parameters.get(0).comment, "The Param 1 comment");
        assertEquals(js.parameters.get(0).name, "pParam1");
        assertEquals(js.parameters.get(1).comment, "The Param 2 comment");
        assertEquals(js.parameters.get(1).name, "pParam2");

        filename = "ABLDuck/test2/docs/output/procedures/header_DialogHeader1_w.js";

        content = new String(Files.readAllBytes(Paths.get(filename)));
        content = content.substring(content.indexOf('(') + 1, content.length() - 2);

        js = gson.fromJson(content, CompilationUnit.class);
        assertEquals(js.author, "Han Solo");
        assertEquals(js.parameters.size(), 2);
        assertEquals(js.parameters.get(0).comment, "The Param 1 comment");
        assertEquals(js.parameters.get(0).name, "pParam1");
        assertEquals(js.parameters.get(1).comment, "The Param 2 comment");
        assertEquals(js.parameters.get(1).name, "pParam2");

        filename = "ABLDuck/test2/docs/output/procedures/header_WindowHeader1_w.js";

        content = new String(Files.readAllBytes(Paths.get(filename)));
        content = content.substring(content.indexOf('(') + 1, content.length() - 2);

        js = gson.fromJson(content, CompilationUnit.class);
        assertEquals(js.author, "Han Solo");
        assertEquals(js.parameters.size(), 2);
        assertEquals(js.parameters.get(0).comment, "The Param 1 comment");
        assertEquals(js.parameters.get(0).name, "pParam1");
        assertEquals(js.parameters.get(1).comment, "The Param 2 comment");
        assertEquals(js.parameters.get(1).name, "pParam2");
    }

    @Test(groups = {"v11"}, dependsOnMethods = {"test2GenerateDocs"})
    public void check2EnumMetadata() throws IOException {
        String filename = "ABLDuck/test2/docs/output/classes/header.EnumHeader1.js";

        String content = new String(Files.readAllBytes(Paths.get(filename)));
        content = content.substring(content.indexOf('(') + 1, content.length() - 2);

        CompilationUnit js = gson.fromJson(content, CompilationUnit.class);

        assertEquals(js.superclasses.size(), 2);
        assertEquals(js.superclasses.get(0), "Progress.Lang.FlagsEnum");
        assertEquals(js.members.size(), 4);
        assertEquals(js.members.get(3).comment,
                "<p>Comment LukeSkywalker</p>\n<h3>Definition:</h3>\n<p><code>LukeSkywalker = Padme, AnakinSkywalker</code></p>\n");
        assertEquals(js.members.get(3).definition, "LukeSkywalker = Padme, AnakinSkywalker");
    }

    @Test(groups = {"v11"}, dependsOnMethods = {"test2GenerateDocs"})
    public void check2StaticMetadata() throws IOException {
        String filename = "ABLDuck/test2/docs/output/classes/other.StaticCommentClass.js";

        String content = new String(Files.readAllBytes(Paths.get(filename)));
        content = content.substring(content.indexOf('(') + 1, content.length() - 2);

        CompilationUnit js = gson.fromJson(content, CompilationUnit.class);

        assertEquals(js.members.size(), 7);

        assertEquals(js.members.get(0).meta.isStatic, Boolean.TRUE);
        assertEquals(js.members.get(1).meta.isStatic, Boolean.TRUE);
        assertEquals(js.members.get(2).meta.isStatic, Boolean.TRUE);
        assertEquals(js.members.get(3).meta.isStatic, Boolean.TRUE);
        assertEquals(js.members.get(4).meta.isStatic, Boolean.TRUE);
        assertEquals(js.members.get(5).meta.isStatic, Boolean.TRUE);
        assertEquals(js.members.get(6).meta.isStatic, Boolean.TRUE);
    }

    @Test(groups = {"v11"}, dependsOnMethods = {"test2GenerateDocs"})
    public void check2TempTableMetadata() throws IOException {
        String filename = "ABLDuck/test2/docs/output/classes/other.TempTableComment.js";

        String content = new String(Files.readAllBytes(Paths.get(filename)));
        content = content.substring(content.indexOf('(') + 1, content.length() - 2);

        CompilationUnit js = gson.fromJson(content, CompilationUnit.class);
        assertEquals(js.members.size(), 6);
        assertEquals(js.members.get(2).name, "ttSample2");
        assertEquals(js.members.get(2).definition,
                "DEFINE TEMP-TABLE ttSample2 NO-UNDO <br>&nbsp;&nbsp;&nbsp;&nbsp;  FIELD champ1 AS CHARACTER<br>&nbsp;&nbsp;&nbsp;&nbsp;  FIELD champ2 AS CHARACTER EXTENT 2<br>&nbsp;&nbsp;&nbsp;&nbsp;  FIELD champ3 AS CHARACTER FORMAT X(3)<br>&nbsp;&nbsp;&nbsp;&nbsp;  FIELD champ4 AS CHARACTER EXTENT 4 FORMAT X(3)<br>&nbsp;&nbsp;&nbsp;&nbsp;  INDEX i1 PRIMARY UNIQUE champ1<br>&nbsp;&nbsp;&nbsp;&nbsp;");
    }

    @Test(groups = {"v11"}, dependsOnMethods = {"test2GenerateDocs"})
    public void check2PropertyMetadata() throws IOException {
        String filename = "ABLDuck/test2/docs/output/classes/other.PropertyComment.js";

        String content = new String(Files.readAllBytes(Paths.get(filename)));
        content = content.substring(content.indexOf('(') + 1, content.length() - 2);

        CompilationUnit js = gson.fromJson(content, CompilationUnit.class);
        assertEquals(js.members.size(), 12);
        assertEquals(js.members.get(0).comment, "<p>A simple comment for property1</p>\n");
        assertEquals(js.members.get(1).comment, "<p>A simple comment for property2</p>\n");
        assertEquals(js.members.get(2).comment,
                "<h3>Purpose:</h3>\n<p>Purpose of property3</p>\n<h3>Notes:</h3>\n<p>Note of property3</p>\n");
        assertEquals(js.members.get(3).comment,
                "<h2>Purpose</h2>\n<p>The purpose of the property4</p>\n");
        assertEquals(js.members.get(4).comment,
                "<h2>Purpose</h2>\n<p>The purpose of the property5</p>\n");
        assertEquals(js.members.get(4).meta.isInternal, Boolean.TRUE);
        assertEquals(js.members.get(4).meta.isDeprecated.version, "0.0.1");
        assertEquals(js.members.get(5).comment, "<p>A simple comment for property6</p>\n");
        assertEquals(js.members.get(5).meta.isInternal, Boolean.TRUE);
        assertEquals(js.members.get(5).meta.isDeprecated.version, "0.0.1");
        assertEquals(js.members.get(6).comment,
                "<h3>Purpose:</h3>\n<p>Purpose of property7</p>\n<h3>Notes:</h3>\n<p>Note of property7</p>\n");
        assertEquals(js.members.get(6).meta.isInternal, Boolean.TRUE);
        assertEquals(js.members.get(6).meta.isDeprecated.version, "0.0.1");
        assertEquals(js.members.get(7).comment,
                "<h3>Modifier:</h3>\n<p><code>GET - PROTECTED SET</code></p>\n");
        assertEquals(js.members.get(8).comment, "<h3>Modifier:</h3>\n<p><code>GET</code></p>\n");
        assertEquals(js.members.get(9).comment,
                "<p>Simple comment for property10</p>\n<h3>Modifier:</h3>\n<p><code>PROTECTED GET - SET</code></p>\n");
        assertEquals(js.members.get(10).comment,
                "<p>Simple comment for property11</p>\n<h3>Modifier:</h3>\n<p><code>SET</code></p>\n");
        assertEquals(js.members.get(11).comment,
                "<h2>Purpose</h2>\n<p>The purpose of the property12</p>\n<h3>Modifier:</h3>\n<p><code>PRIVATE GET - SET</code></p>\n");
    }

    @Test(groups = {"v11"})
    public void test3() {
        configureProject("ABLDuck/test3/build.xml");
        executeTarget("test");

        File f1 = new File("ABLDuck/test3/docs1/output/classes/rssw.pct.TestClass1.js");
        assertTrue(f1.exists());
        File f2 = new File("ABLDuck/test3/docs2/output/classes/rssw.pct.TestClass1.js");
        assertTrue(f2.exists());

        // Not exactly the same as ClassDocumentationTest#test3
        assertTrue(f2.length() < f1.length());

    }

}
