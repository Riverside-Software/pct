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
import static org.testng.Assert.fail;

import org.apache.tools.ant.BuildException;
import org.testng.annotations.Test;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

/**
 * PCTDumpSchema testcases
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTDumpSchemaTest extends BuildFileTestNg {

    @Test(groups= {"v9+"}, expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("PCTDumpSchema/test1/build.xml");
        executeTarget("test");
    }

    @Test(groups= {"v9+"}, expectedExceptions = BuildException.class)
    public void test2() {
        configureProject("PCTDumpSchema/test2/build.xml");
        executeTarget("test");
    }

    @Test(groups= {"v9+"}, expectedExceptions = BuildException.class)
    public void test3() {
        configureProject("PCTDumpSchema/test3/build.xml");
        executeTarget("test");
    }

    @Test(groups= {"v9+"})
    public void test4() {
        configureProject("PCTDumpSchema/test4/build.xml");

        executeTarget("base");
        executeTarget("test");
        File f1 = new File("PCTDumpSchema/test4/foo/sch.df");
        assertTrue(f1.exists());
        if (!checkFile(f1, "Tab1", ""))
            fail("Incorrect file");
    }

    @Test(groups= {"v9+"})
    public void test5() {
        configureProject("PCTDumpSchema/test5/build.xml");

        executeTarget("base");
        executeTarget("test");
        File f1 = new File("PCTDumpSchema/test5/foo/sch.df");
        assertTrue(f1.exists());
        if (!checkFile(f1, "_File", ""))
            fail("Incorrect file");
    }

    @Test(groups= {"v9+"})
    public void test6() {
        configureProject("PCTDumpSchema/test6/build.xml");

        executeTarget("base");
        executeTarget("test");

        File f1 = new File("PCTDumpSchema/test6/foo/files1.df");
        File f2 = new File("PCTDumpSchema/test6/foo/files2.df");
        File f3 = new File("PCTDumpSchema/test6/foo/files3.df");

        if (!checkFile(f1, "Tab1", "Tab3"))
            fail("Incorrect files1.df");
        if (!checkFile(f2, "Tab2", "Tab1"))
            fail("Incorrect files2.df");
        if (!checkFile(f3, "Tab3", "Tab2"))
            fail("Incorrect files3.df");
    }

    private boolean checkFile(File f, String inc, String exc) {
        BufferedReader reader = null;
        boolean bInc = false, bExc = true;
        try {
            reader = new BufferedReader(new FileReader(f));
            String str = null;
            while ((str = reader.readLine()) != null) {
                if (str.trim().startsWith("ADD TABLE \"" + inc + "\""))
                    bInc = true;
                if (str.trim().startsWith("ADD TABLE \"" + exc + "\""))
                    bExc = false;
            }
            reader.close();
            return (bInc && bExc);
        } catch (IOException caught) {
            return false;
        } finally {
            try {
                reader.close();
            } catch (IOException uncaught) {

            }
        }
    }
}
