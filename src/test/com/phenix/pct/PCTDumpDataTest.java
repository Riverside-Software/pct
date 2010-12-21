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

import org.apache.tools.ant.taskdefs.Delete;
import org.apache.tools.ant.taskdefs.Mkdir;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

import java.io.File;

/**
 * Class for testing PCTDumpData task
 * 
 * @author <a href="mailto:g.querret@gmail.com">Gilles QUERRET </a>
 */
public class PCTDumpDataTest extends BuildFileTestNg {

    @BeforeMethod
    public void setUp() {
        configureProject("PCTDumpData.xml");

        // Creates a sandbox directory to play with
        Mkdir mkdir = new Mkdir();
        mkdir.setProject(this.getProject());
        mkdir.setDir(new File("sandbox"));
        mkdir.execute();
    }

    @AfterMethod
    public void tearDown() {
        super.tearDown();
        Delete del = new Delete();
        del.setProject(this.getProject());
        del.setDir(new File("sandbox"));
        del.execute();
    }

    /**
     * Should throw BuildException : no filesets and no connection
     */
    @Test
    public void test1() {
        expectBuildException("test1", "Should throw BuildException : no filesets and no connection");
    }

    /**
     * Should throw BuildException : no filesets (or srcDir) defined 
     */
    @Test
    public void test2() {
        expectBuildException("test2", "Should throw BuildException : no filesets (or srcDir) defined ");
    }

    /**
     * Should throw BuildException : no connection defined
     */
    @Test
    public void test3() {
        expectBuildException("test3", "Should throw BuildException : no connection defined");
    }

    /**
     * Should dump Tab1 in target directory
     */
    @Test
    public void test4() {
        executeTarget("test4init");
        executeTarget("test4");
        
        File f1 = new File("sandbox/Tab1.d");
        assertTrue(f1.exists());
    }
    
    /**
     * Should dump _File in target directory
     */
    @Test
    public void test5() {
        executeTarget("test5init");
        executeTarget("test5");
        
        File f1 = new File("sandbox/_File.d");
        assertTrue(f1.exists());
    }

}