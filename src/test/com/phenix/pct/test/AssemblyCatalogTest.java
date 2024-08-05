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

import static org.testng.Assert.assertEquals;
import static org.testng.Assert.assertFalse;
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
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class AssemblyCatalogTest extends BuildFileTestNg {

    public void genericTest(String rootDir) {
        configureProject(rootDir + "/build.xml");
        executeTarget("test");

        File f1 = new File(rootDir + "/assemblies.json");
        assertTrue(f1.exists());
        Gson gson = new GsonBuilder().create();
        try (FileReader reader = new FileReader(f1)) {
            AssemblyClass[] classes = gson.fromJson(reader, AssemblyClass[].class);
            assertNotNull(classes);
            assertTrue(classes.length > 10);
            AssemblyClass cls = null;
            for (AssemblyClass c : classes) {
                if ("System.Uri".equals(c.name)) {
                    cls = c;
                }
            }
            assertNotNull(cls);
            assertFalse(cls.isAbstract);
            assertTrue(cls.isClass);
            assertFalse(cls.isInterface);
            assertFalse(cls.isEnum);
            assertNotNull(cls.methods);
            assertEquals(cls.methods.length, 9);
            Method obsMethd = null;
            Method nonObsMethd = null;
            for (Method m : cls.methods) {
                if ("MakeRelative (toUri System.Uri)".equals(m.name)) {
                    obsMethd = m;
                }
                if ("IsWellFormedOriginalString ()".equals(m.name)) {
                    nonObsMethd = m;
                }
            }
            assertNotNull(obsMethd);
            assertNotNull(obsMethd.obsolete);
            assertFalse(obsMethd.obsolete.error);
            assertNotNull(nonObsMethd);
            assertNull(nonObsMethd.obsolete);
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
        if (isWindows) {
            // Only work with 12.7+
            DLCVersion version = DLCVersion.getObject(new File(System.getProperty("DLC")));
            if ((version.getMajorVersion() == 12) && (version.getMinorVersion() <= 6))
                return;
        } else {
         // Only work with 12.8+
            DLCVersion version = DLCVersion.getObject(new File(System.getProperty("DLC")));
            if ((version.getMajorVersion() == 12) && (version.getMinorVersion() <= 7))
                return;
        }
        genericTest("AssemblyCatalog/test2");
    }

    @SuppressWarnings("unused")
    private static class AssemblyClass {
        String name;
        String[] baseTypes;
        boolean isAbstract;
        boolean isClass;
        boolean isEnum;
        boolean isInterface;
        Property[] properties;
        Method[] methods;
        String[] events;
        Method[] staticMethods;
        Property[] staticProperties;
    }

    @SuppressWarnings("unused")
    private static class Method {
        String name;
        ObsoleteDescription obsolete;
    }

    @SuppressWarnings("unused")
    private static class Property {
        String name;
        String dataType;
        ObsoleteDescription obsolete;
    }

    @SuppressWarnings("unused")
    private static class ObsoleteDescription {
        String message;
        boolean error;
    }
}
