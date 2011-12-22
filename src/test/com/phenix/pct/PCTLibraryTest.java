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

import static org.testng.Assert.assertTrue;

import org.apache.tools.ant.BuildException;
import org.testng.annotations.Test;

import java.io.File;

import java.util.List;

/**
 * Class for testing PCTLibrary task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTLibraryTest extends BuildFileTestNg {

    /**
     * Attribute destFile should always be defined
     */
    @Test(expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("PCTLibrary/test1/build.xml");
        executeTarget("test");
    }

    @Test(expectedExceptions = BuildException.class)
    public void test2() {
        configureProject("PCTLibrary/test2/build.xml");
        executeTarget("test");
    }

    /**
     * Checks that a file is added in the library
     */
    @Test
    public void test3() {
        configureProject("PCTLibrary/test3/build.xml");
        executeTarget("test");

        File pl = new File("PCTLibrary/test3/lib/test.pl");
        assertTrue(pl.exists());

        PLReader r = new PLReader(pl);
        List v = r.getFileList();
        assertTrue(v != null);
        assertTrue(v.size() == 1);
    }

    /**
     * Checks that a file is added in the library
     */
    @Test
    public void test4() {
        configureProject("PCTLibrary/test4/build.xml");
        executeTarget("test1");

        File pl = new File("PCTLibrary/test4/lib/test.pl");
        assertTrue(pl.exists());

        PLReader r = new PLReader(pl);
        List v = r.getFileList();
        assertTrue(v != null);
        assertTrue(v.size() == 1);

        executeTarget("test2");
        PLReader r2 = new PLReader(pl);
        List v2 = r2.getFileList();
        assertTrue(v2 != null);
        assertTrue(v2.size() == 1);
    }

    @Test
    public void test5() {
        configureProject("PCTLibrary/test5/build.xml");
        executeTarget("test");

        File f1 = new File("PCTLibrary/test5/lib/test.pl");
        assertTrue(f1.exists());
        File f2 = new File("PCTLibrary/test5/lib/test2.pl");
        assertTrue(f2.exists());
        assertTrue((f2.length() < f1.length()));
    }

    @Test
    public void test6() {
        configureProject("PCTLibrary/test6/build.xml");
        executeTarget("test");

        File f1 = new File("PCTLibrary/test6/lib/test.pl");
        assertTrue(f1.exists());

        PLReader r = new PLReader(f1);
        List v = r.getFileList();
        assertTrue(v != null);
        assertTrue(v.size() == 3);
    }

    @Test(expectedExceptions = BuildException.class)
    public void test7() {
        configureProject("PCTLibrary/test7/build.xml");
        executeTarget("test");
    }

    @Test
    public void test8() {
        configureProject("PCTLibrary/test8/build.xml");
        executeTarget("test");

        File f1 = new File("PCTLibrary/test8/lib/test.pl");
        assertTrue(f1.exists());

        PLReader r = new PLReader(f1);
        List v = r.getFileList();
        assertTrue(v != null);
        assertTrue(v.size() == 2);
    }

    @Test
    public void test9() {
        configureProject("PCTLibrary/test9/build.xml");
        executeTarget("test");

        File f1 = new File("PCTLibrary/test9/lib/test.pl");
        assertTrue(f1.exists());

        PLReader r = new PLReader(f1);
        List v = r.getFileList();
        assertTrue(v != null);
        assertTrue(v.size() == 1);
    }

    @Test
    public void test10() {
        configureProject("PCTLibrary/test10/build.xml");
        executeTarget("prepare");

        File f1 = new File("PCTLibrary/test10/lib/test.pl");
        assertTrue(f1.exists());
        File f2 = new File("PCTLibrary/test10/lib/test2.pl");
        assertTrue(f2.exists());

        expectLog("test", "éèà");

        PLReader r = new PLReader(f2);
        List v = r.getFileList();
        assertTrue(v != null);
        assertTrue(v.size() == 2);
        assertTrue(v.contains(new String("éèà.txt")));
    }
}
