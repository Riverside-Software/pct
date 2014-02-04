/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) 2002 The Apache Software Foundation.  All rights
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

import java.io.File;

import org.apache.tools.ant.BuildException;
import org.testng.annotations.Test;

/**
 * Class for testing PCTProxygen task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTProxygenTest extends BuildFileTestNg {

    @Test(groups = { "v10", "v11" }, expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("PCTProxygen/test1/build.xml");
        executeTarget("test");
    }

    @Test(groups = { "v10", "v11", "win" })
    public void test2() {
        configureProject("PCTProxygen/test2/build.xml");
        executeTarget("prepare");

        executeTarget("test1");
        File f1 = new File("PCTProxygen/test2/pxg/Test.class");
        File f2 = new File("PCTProxygen/test2/pxg/TestImpl.class");
        File f3 = new File("PCTProxygen/test2/pxg/TestImpl.java");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        assertFalse(f3.exists());

        executeTarget("test2");
        assertTrue(f3.exists());
    }

    @Test(groups = { "v10", "v11", "win" })
    public void test3() {
        configureProject("PCTProxygen/test3/build.xml");
        executeTarget("prepare");

        File f1 = new File("PCTProxygen/test3/pxg/Test.class");
        File f2 = new File("PCTProxygen/test3/pxg/TestImpl.class");
        expectBuildException("test1", "Invalid JVM option");
        expectBuildException("test2", "Not enough memory");
        executeTarget("test3");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
    }
    
    @Test(groups = { "v9", "win" })
    public void test4() {
        configureProject("PCTProxygen/test4/build.xml");
        executeTarget("prepare");

        executeTarget("test1");
        File f1 = new File("PCTProxygen/test4/pxg/Test.class");
        File f2 = new File("PCTProxygen/test4/pxg/TestImpl.class");
        File f3 = new File("PCTProxygen/test4/pxg/TestImpl.java");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        assertFalse(f3.exists());

        executeTarget("test2");
        assertTrue(f3.exists());
    }
}
