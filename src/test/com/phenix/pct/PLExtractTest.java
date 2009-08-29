/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) 2002 The Apache Software Foundation. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *  1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *  3. The end-user documentation included with the redistribution, if any,
 * must include the following acknowlegement: "This product includes software
 * developed by the Apache Software Foundation (http://www.apache.org/)."
 * Alternately, this acknowlegement may appear in the software itself, if and
 * wherever such third-party acknowlegements normally appear.
 *  4. The names "Ant" and "Apache Software Foundation" must not be used to
 * endorse or promote products derived from this software without prior written
 * permission. For written permission, please contact apache@apache.org.
 *  5. Products derived from this software may not be called "Apache" nor may
 * "Apache" appear in their names without prior written permission of the
 * Apache Group.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * APACHE SOFTWARE FOUNDATION OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many individuals
 * on behalf of the Apache Software Foundation. For more information on the
 * Apache Software Foundation, please see <http://www.apache.org/> .
 */

package com.phenix.pct;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.taskdefs.Delete;
import org.apache.tools.ant.taskdefs.Mkdir;
import org.apache.tools.ant.types.PatternSet;

import junit.framework.TestCase;

/**
 * Class for testing RCodeInfo class
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
 */

public class PLExtractTest extends TestCase {
    private File sandbox = new File("sandbox");
    private File createDir = new File(sandbox, "test1");
    private File extractDir = new File(sandbox, "test2");

    private Project project;

    public void setUp() {
        project = new Project();
        project.setBasedir(".");
        project.init();

        Mkdir mk = new Mkdir();
        mk.setProject(project);
        mk.setDir(sandbox);
        mk.execute();

        mk.setDir(createDir);
        mk.execute();

        mk.setDir(extractDir);
        mk.execute();
    }

    public void tearDown() throws Exception {
        super.tearDown();
        Delete del = new Delete();
        del.setProject(project);
        del.setDir(sandbox);
        del.execute();
    }

    private boolean writeTestFile(File f) {
        BufferedWriter bw = null;
        try {
            bw = new BufferedWriter(new FileWriter(f));
            bw.write("MESSAGE 'Hello world !'");
            bw.close();
            return true;
        } catch (IOException ioe) {
            return false;
        }
    }

    private boolean createProlib(File destFile, File baseDir, String inc, String exc) {
        try {
            PCTLibrary lib = new PCTLibrary();
            lib.setProject(project);
            lib.setBasedir(baseDir);
            lib.setDlcHome(new File(project.getProperty("DLC")));
            lib.setDestFile(destFile);
            lib.setIncludes(inc);
            lib.setExcludes(exc);
            lib.execute();
            return true;
        } catch (BuildException be) {
            return false;
        }
    }

    /**
     * 
     */
    public void testBasic() {
        File srcFile = new File(createDir, "test1.p");
        File pl = new File(sandbox, "test.pl");
        assertTrue(writeTestFile(srcFile));
        assertTrue(createProlib(pl, createDir, "**/*.p", ""));
        assertTrue(pl.exists());

        PLExtract extract = new PLExtract();
        extract.setProject(project);
        extract.setSrc(pl);
        extract.setDest(extractDir);

        File f1 = new File(extractDir, "test1.p");
        assertFalse(f1.exists());
        extract.execute();
        assertTrue(f1.exists());
        assertTrue((f1.length() != 0));
    }

    /**
     * Testing overwrite attribute
     */
    public void testOverwrite() {
        File srcFile = new File(createDir, "test1.p");
        File pl = new File(sandbox, "test.pl");
        assertTrue(writeTestFile(srcFile));
        assertTrue(createProlib(pl, createDir, "**/*.p", ""));
        assertTrue(pl.exists());

        PLExtract extract = new PLExtract();
        extract.setProject(project);
        extract.setSrc(pl);
        extract.setDest(extractDir);
        extract.setOverwrite(false);

        File f1 = new File(extractDir, "test1.p");
        assertFalse(f1.exists());
        extract.execute();
        assertTrue(f1.exists());
        assertTrue((f1.length() != 0));

        BufferedWriter bw = null;
        try {
            bw = new BufferedWriter(new FileWriter(f1));
            bw.write("");
            bw.close();
        } catch (IOException ioe) {
            fail("Test case broken");
        }

        // Overwrite still set to false, so don't overwrite file
        assertTrue(f1.exists());
        assertTrue((f1.length() == 0));
        extract.execute();
        assertTrue(f1.exists());
        assertTrue((f1.length() == 0));

        extract.setOverwrite(true);
        extract.execute();
        assertTrue(f1.exists());
        assertTrue((f1.length() != 0));
    }

    /**
     * 
     */
    public void testSimplePattern() {
        File srcFile1 = new File(createDir, "test1.p");
        File srcFile2 = new File(createDir, "test2.p");
        File srcFile3 = new File(createDir, "test3.p");
        File pl = new File(sandbox, "test.pl");
        assertTrue(writeTestFile(srcFile1));
        assertTrue(writeTestFile(srcFile2));
        assertTrue(writeTestFile(srcFile3));
        assertTrue(createProlib(pl, createDir, "**/*.p", ""));
        assertTrue(pl.exists());

        PLExtract extract = new PLExtract();
        extract.setProject(project);
        extract.setSrc(pl);
        extract.setDest(extractDir);
        PatternSet ps = new PatternSet();
        ps.setProject(project);
        ps.setIncludes("test1.p,test3.p");
        ps.setExcludes("test2.p");
        extract.addPatternset(ps);

        File f1 = new File(extractDir, "test1.p");
        File f2 = new File(extractDir, "test2.p");
        File f3 = new File(extractDir, "test3.p");
        assertFalse(f1.exists());
        assertFalse(f2.exists());
        assertFalse(f3.exists());
        extract.execute();
        assertTrue(f1.exists());
        assertTrue((f1.length() != 0));
        assertFalse(f2.exists());
        assertTrue(f3.exists());
        assertTrue((f3.length() != 0));
    }

}