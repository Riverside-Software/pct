/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) The Apache Software Foundation.  All rights
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
import static org.testng.Assert.assertEquals;

import org.apache.tools.ant.BuildException;
import org.testng.annotations.Test;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

/**
 * Class for testing PCTDumpData task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class PCTDumpDataTest extends BuildFileTestNg {

    /**
     * Should throw BuildException : no filesets and no connection
     */
    @Test(groups= {"v9"}, expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("PCTDumpData/test1/build.xml");
        executeTarget("test");
    }

    /**
     * Should throw BuildException : no filesets (or srcDir) defined
     */
    @Test(groups= {"v9"}, expectedExceptions = BuildException.class)
    public void test2() {
        configureProject("PCTDumpData/test2/build.xml");
        executeTarget("test");
    }

    /**
     * Should throw BuildException : no connection defined
     */
    @Test(groups= {"v9"}, expectedExceptions = BuildException.class)
    public void test3() {
        configureProject("PCTDumpData/test3/build.xml");
        executeTarget("test");
    }

    /**
     * Should dump Tab1 in target directory
     */
    @Test(groups= {"v9"})
    public void test4() {
        configureProject("PCTDumpData/test4/build.xml");
        executeTarget("prepare");

        executeTarget("test");

        File f1 = new File("PCTDumpData/test4/dump/Tab1.d");
        assertTrue(f1.exists());
    }

    /**
     * Should dump _File in target directory
     */
    @Test(groups= {"v9"})
    public void test5() {
        configureProject("PCTDumpData/test5/build.xml");
        executeTarget("prepare");

        executeTarget("test");

        File f1 = new File("PCTDumpData/test5/dump/_File.d");
        assertTrue(f1.exists());
    }

    /**
     * Tests various encodings
     */
    @Test(groups= {"v9"})
    public void test6() {
        configureProject("PCTDumpData/test6/build.xml");
        executeTarget("prepare");

        executeTarget("test");

        File f1 = new File("PCTDumpData/test6/dump/8859-1/_File.d");
        assertTrue(f1.exists());
        assertEquals(readEncoding(f1), "iso8859-1");
        File f2 = new File("PCTDumpData/test6/dump/8859-15/_File.d");
        assertTrue(f2.exists());
        assertEquals(readEncoding(f2), "iso8859-15");
        File f3 = new File("PCTDumpData/test6/dump/utf8/_File.d");
        assertTrue(f3.exists());
        assertEquals(readEncoding(f3), "utf-8");
    }

    // Quick'n'dirty method to read encoding in dump file
    private String readEncoding(File f) {
        BufferedReader reader = null;
        String encoding = null;

        try {
            reader = new BufferedReader(new FileReader(f));
            String str = null;

            while ((str = reader.readLine()) != null) {
                if (str.startsWith("cpstream="))
                    encoding = str.substring(9);
            }
        } catch (IOException uncaught) {
        } finally {
            try {
                reader.close();
            } catch (IOException uncaught) {

            }
        }
        return encoding;
    }
}