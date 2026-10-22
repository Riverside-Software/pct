/**
 * Copyright 2005-2026 Riverside Software
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

import static org.testng.Assert.assertEquals;
import static org.testng.Assert.assertNotNull;
import static org.testng.Assert.assertNull;
import static org.testng.Assert.assertTrue;
import static org.testng.Assert.fail;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;

import org.testng.annotations.Test;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.phenix.pct.DLCVersion;

/**
 * Class for testing AssemblyCatalog task
 */
public class AssemblyCatalogTest extends BuildFileTestNg {

    public void genericTest(String rootDir) {
        configureProject(rootDir + "/build.xml");
        executeTarget("test");

        File f1 = new File(rootDir + "/assemblies.json");
        assertTrue(f1.exists());
        Gson gson = new GsonBuilder().create();
        try (FileReader reader = new FileReader(f1)) {
            Catalog catalog = gson.fromJson(reader, Catalog.class);
            assertNotNull(catalog);
            assertEquals(catalog.schemaVersion, 1);
            assertNotNull(catalog.classes);
            assertTrue(catalog.classes.length > 10);
            AssemblyClass cls = null;
            for (AssemblyClass c : catalog.classes) {
                if ("System.Uri".equals(c.name)) {
                    cls = c;
                }
            }
            assertNotNull(cls);
            assertTrue(cls.isClass);
            assertNotNull(cls.methods);
            assertTrue(cls.methods.length >= 9);
            Method obsMethd = null;
            Method nonObsMethd = null;
            for (Method m : cls.methods) {
                if ("MakeRelative".equals(m.name)) {
                    obsMethd = m;
                }
                if ("IsWellFormedOriginalString".equals(m.name)) {
                    nonObsMethd = m;
                }
            }
            assertNotNull(obsMethd);
            assertNotNull(obsMethd.obsolete);
            assertEquals(obsMethd.returnType, "CHARACTER");
            assertEquals(obsMethd.parameters.length, 1);
            assertEquals(obsMethd.parameters[0].type, "System.Uri");
            assertNotNull(nonObsMethd);
            assertNull(nonObsMethd.obsolete);
            assertEquals(nonObsMethd.returnType, "LOGICAL");
        } catch (IOException caught) {
            fail("Unable to read assemblies.json");
        }
    }

    @Test(groups= {"win", "v11"})
    public void test1() {
        genericTest("AssemblyCatalog/test1");
    }

    @Test(groups= {"v12"})
    public void test2() {
        boolean isWindows = System.getProperty("os.name").toLowerCase().contains("win");
        DLCVersion version = DLCVersion.getObject(new File(System.getProperty("DLC")));
        // .Net core requires 12.7+ on Windows, 12.8+ on Linux
        if ((version.getMajorVersion() == 12) && (version.getMinorVersion() <= (isWindows ? 6 : 7)))
            return;
        genericTest("AssemblyCatalog/test2");
    }

    @Test(groups= {"v11"})
    public void test3() {
        configureProject("AssemblyCatalog/test3/build.xml");
        expectBuildException("test", "PCTTools.dll doesn't exist");
        assertTrue(!new File("AssemblyCatalog/test3/assemblies.json").exists());
    }

    @SuppressWarnings("unused")
    private static class Catalog {
        int schemaVersion;
        AssemblyClass[] classes;
    }

    @SuppressWarnings("unused")
    private static class AssemblyClass {
        String name;
        boolean isClass;
        Method[] methods;
    }

    @SuppressWarnings("unused")
    private static class Method {
        String name;
        String returnType;
        Parameter[] parameters;
        ObsoleteDescription obsolete;
    }

    @SuppressWarnings("unused")
    private static class Parameter {
        String type;
    }

    private static class ObsoleteDescription {
    }
}
