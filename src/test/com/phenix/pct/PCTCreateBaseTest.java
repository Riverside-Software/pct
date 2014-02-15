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

import static org.testng.Assert.assertFalse;
import static org.testng.Assert.assertTrue;

import org.apache.tools.ant.BuildException;
import org.testng.annotations.Test;

import java.io.File;

/**
 * Class for testing PCTCreateBase task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTCreateBaseTest extends BuildFileTestNg {

    @Test(groups= {"v9"}, expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("PCTCreateBase/test1/build.xml");
        executeTarget("test");
    }

    @Test(groups= {"v9"}, expectedExceptions = BuildException.class)
    public void test2() {
        configureProject("PCTCreateBase/test2/build.xml");
        executeTarget("test");
    }

    @Test(groups= {"v9"})
    public void test3() {
        configureProject("PCTCreateBase/test3/build.xml");
        executeTarget("test");

        File f = new File("PCTCreateBase/test3/db/test3.db");
        assertTrue(f.exists());
    }

    @Test(groups= {"v9"}, expectedExceptions = BuildException.class)
    public void test4() {
        configureProject("PCTCreateBase/test4/build.xml");
        executeTarget("test");
    }

    @Test(groups= {"v9"})
    public void test5() {
        configureProject("PCTCreateBase/test5/build.xml");
        executeTarget("base");
        File f = new File("PCTCreateBase/test5/db/test.db");
        assertTrue(f.exists());

        executeTarget("test");
        f = new File("PCTCreateBase/test5/build/test.r");
        assertTrue(f.exists());
    }

    @Test(groups= {"v9"})
    public void test6() {
        configureProject("PCTCreateBase/test6/build.xml");
        executeTarget("test");

        File f = new File("PCTCreateBase/test6/db/test.db");
        long time = f.lastModified();
        executeTarget("test2");
        assertTrue(f.lastModified() == time);
    }

    @Test(groups= {"v9"})
    public void test7() {
        // TODO : fix the overwrite attribute and uncomment this
        // configureProject("PCTCreateBase/test7/build.xml");
        // executeTarget("test");

        // File f = new File("sandbox/test.db");
        // long time = f.lastModified();
        // executeTarget("test");
        // assert True(f.lastModified() != time);
    }

    @Test(groups= {"v9"})
    public void test8() {
        configureProject("PCTCreateBase/test8/build.xml");
        executeTarget("test");

        File f = new File("PCTCreateBase/test8/db/test.b1");
        assertTrue(f.exists());
        f = new File("PCTCreateBase/test8/db/test.b2");
        assertTrue(f.exists());
        f = new File("PCTCreateBase/test8/db/test.d1");
        assertTrue(f.exists());
        f = new File("PCTCreateBase/test8/db/test.d2");
        assertTrue(f.exists());

        executeTarget("test2");
    }

    @Test(groups= {"v9"})
    public void test9() {
        configureProject("PCTCreateBase/test9/build.xml");
        executeTarget("test");

        File f = new File("PCTCreateBase/test9/db/test.db");
        assertTrue(f.exists());
        executeTarget("test2");
        f = new File("PCTCreateBase/test9/build/test.r");
        assertTrue(f.exists());
    }

    @Test(groups= {"v9"})
    public void test10() {
        configureProject("PCTCreateBase/test10/build.xml");
        executeTarget("test");

        File f1 = new File("PCTCreateBase/test10/db/test.db");
        assertTrue(f1.exists());
        File f2 = new File("PCTCreateBase/test10/build/test.r");
        assertTrue(f2.exists());

        expectBuildException("test2", "Should throw BuildException as schema doesn't exist");
    }

    @Test(groups= {"v9"})
    public void test11() {
        configureProject("PCTCreateBase/test11/build.xml");
        executeTarget("test1");
        File f = new File("PCTCreateBase/test11/dir with spaces/test.db");
        assertTrue(f.exists());

        executeTarget("test2");
        f = new File("PCTCreateBase/test11/build/test.r");
        assertTrue(f.exists());
    }

    @Test(groups = {"v9"})
    public void test12() {
        configureProject("PCTCreateBase/test12/build.xml");
        
        expectBuildException("test", "Structure file not found");
        File f = new File("PCTCreateBase/test12/db/test.db");
        assertFalse(f.exists());
    }

    @Test(groups = {"v10"})
    public void test13() {
        configureProject("PCTCreateBase/test13/build.xml");
        
        executeTarget("test");
        executeTarget("verify");
    }

    @Test(groups = {"v10"})
    public void test14() {
        configureProject("PCTCreateBase/test14/build.xml");
        
        executeTarget("test");
        executeTarget("verify");
    }

    @Test(groups = {"v9"})
    public void test15() {
        configureProject("PCTCreateBase/test15/build.xml");
        
        executeTarget("test");
        executeTarget("verify");
    }

}
