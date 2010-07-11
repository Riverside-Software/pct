/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) 2002-2003 The Apache Software Foundation.  All rights
 * reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution, if
 *    any, must include the following acknowlegement:
 *       "This product includes software developed by the
 *        Apache Software Foundation (http://www.apache.org/)."
 *    Alternately, this acknowlegement may appear in the software itself,
 *    if and wherever such third-party acknowlegements normally appear.
 *
 * 4. The names "Ant" and "Apache Software
 *    Foundation" must not be used to endorse or promote products derived
 *    from this software without prior written permission. For written
 *    permission, please contact apache@apache.org.
 *
 * 5. Products derived from this software may not be called "Apache"
 *    nor may "Apache" appear in their names without prior written
 *    permission of the Apache Group.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE APACHE SOFTWARE FOUNDATION OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation.  For more
 * information on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 */
package com.phenix.pct;

import org.apache.tools.ant.BuildFileTest;
import org.apache.tools.ant.taskdefs.Delete;
import org.apache.tools.ant.taskdefs.Mkdir;

import java.io.File;

/**
 * Class for testing PCTCreateBase task
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
 */
public class PCTCreateBaseTest extends BuildFileTest {
    public PCTCreateBaseTest(String name) {
        super(name);
    }

    public void setUp() {
        configureProject("PCTCreateBase.xml");

        // Creates a sandbox directory to play with
        Mkdir mkdir = new Mkdir();
        mkdir.setProject(this.getProject());
        mkdir.setDir(new File("sandbox"));
        mkdir.execute();
    }

    public void tearDown() throws Exception {
        super.tearDown();
        Delete del = new Delete();
        del.setFailOnError(false);
        del.setProject(this.project);
        del.setDir(new File("sandbox"));
        del.execute();
        del.setDir(new File("build"));
        del.execute();

        Delete del2 = new Delete();
        del2.setProject(this.project);
        del2.setFile(new File("${user.home}/schema.df"));
        del2.execute();
    }

    public void test1() {
        expectBuildException("test1", "No dbName defined");
    }

    public void test2() {
        expectBuildException("test2", "dbName longer than 11 characters");
    }

    public void test3() {
        executeTarget("test3");

        File f = new File("sandbox/test3.db");
        assertTrue(f.exists());
    }

    public void test4() {
        expectBuildException("test4", "noInit and noStruct both defined");
    }

    public void test5() {
        executeTarget("test5init");

        File f = new File("sandbox/test.db");
        assertTrue(f.exists());
        executeTarget("test5");
        f = new File("build/sandbox/test.r");
        assertTrue(f.exists());
    }

    public void test6() {
        File f = new File("sandbox/test.db");
        executeTarget("test6");

        long time = f.lastModified();
        executeTarget("test6");
        assertTrue(f.lastModified() == time);
    }

    public void test7() {
        executeTarget("test7");

        // TODO : fix the overwrite attribute and uncomment this
        // File f = new File("sandbox/test.db");
        // long time = f.lastModified();
        // executeTarget("test7");
        // assert True(f.lastModified() != time);
    }

    public void test8() {
        executeTarget("test8");

        File f = new File("sandbox/test.b1");
        assertTrue(f.exists());
        f = new File("sandbox/test.b2");
        assertTrue(f.exists());
        f = new File("sandbox/test.d1");
        assertTrue(f.exists());
        f = new File("sandbox/test.d2");
        assertTrue(f.exists());

        executeTarget("test8bis");
    }

    public void test9() {
        executeTarget("test9init");

        File f = new File("sandbox/test.db");
        assertTrue(f.exists());
        executeTarget("test9");
        f = new File("build/sandbox/test.r");
        assertTrue(f.exists());
    }

    public void test10() {
        executeTarget("test10-init");
        executeTarget("test10");
        File f = new File("sandbox/test.db");
        assertTrue(f.exists());
        f = new File("build/sandbox/test.r");
        assertTrue(f.exists());
        expectBuildException("test10-2", "Should throw BuildException as schema doesn't exist");
    }

    public void test11() {
        executeTarget("test11init");

        File f = new File("sandbox/dir with spaces/test.db");
        assertTrue(f.exists());
        executeTarget("test11");
        f = new File("build/sandbox/test.r");
        assertTrue(f.exists());
    }


}
