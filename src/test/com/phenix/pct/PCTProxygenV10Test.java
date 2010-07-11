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

import org.apache.tools.ant.BuildFileTest;
import org.apache.tools.ant.taskdefs.Delete;
import org.apache.tools.ant.taskdefs.Mkdir;

import java.io.File;

/**
 * Class for testing PCTProxygen task
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
 * @version $Revision: 887 $
 */
public class PCTProxygenV10Test extends BuildFileTest {
    private int majorVersion, minorVersion;
    
    public PCTProxygenV10Test(String name) {
        super(name);
    }

    public void setUp() {
        configureProject("PCTProxygen.xml");

        // Creates a sandbox directory to play with
        Mkdir mkdir = new Mkdir();
        mkdir.setProject(this.getProject());
        mkdir.setDir(new File("sandbox"));
        mkdir.execute();

        ProgressVersion version = new ProgressVersion();
        version.setProject(getProject());
        version.setDlcHome(new File(getProject().getProperty("DLC")));
        version.setMajorVersion("majorVersion");
        version.setMinorVersion("minorVersion");
        version.setRevision("revision");
        version.execute();
        
        majorVersion = Integer.parseInt(getProject().getProperty("majorVersion"));
        minorVersion = Integer.parseInt(getProject().getProperty("minorVersion"));
    }

    public void tearDown() throws Exception {
        super.tearDown();
        Delete del = new Delete();
        del.setFailOnError(false);
        del.setProject(this.project);
        del.setDir(new File("build"));
        del.execute();
        del.setDir(new File("sandbox"));
        del.execute();
        del.setDir(new File("pxg"));
        del.execute();
    }

    public void test1() {
        expectBuildException("test1", "No srcFile defined");
    }

    public void test2() {
        // Stupid 10.1...
        if ((majorVersion == 10) && (minorVersion == 1)) return;
        
        executeTarget("test2-init");
        executeTarget("test2");

        File f1 = new File("pxg/Test.class");
        File f2 = new File("pxg/TestImpl.class");
        File f3 = new File("pxg/TestImpl.java");
        // 10.1B doesn't handle relative paths...
        assertTrue("Failure expected on 10.1B...", f1.exists());
        assertTrue("Failure expected on 10.1B...", f2.exists());
        assertFalse("Failure expected on 10.1B...", f3.exists());

        executeTarget("test2-bis");
        assertTrue("Failure expected on 10.1B...", f3.exists());
    }

    public void test3() {
        // Stupid 10.1...
        if ((majorVersion == 10) && (minorVersion == 1)) return;
        // XPXG files are only in v10
        if (majorVersion == 9) return;
        
        executeTarget("test3-init");
        executeTarget("test3");

        File f1 = new File("pxg/Test.class");
        File f2 = new File("pxg/TestImpl.class");
        File f3 = new File("pxg/TestImpl.java");
        // 10.1B doesn't handle relative paths...
        assertTrue("Failure expected on 10.1B...", f1.exists());
        assertTrue("Failure expected on 10.1B...", f2.exists());
        assertFalse("Failure expected on 10.1B...", f3.exists());

        executeTarget("test3-bis");
        assertTrue("Failure expected on 10.1B...", f3.exists());
    }

    public void test4() {
        // Stupid 10.1...
        if ((majorVersion == 10) && (minorVersion == 1)) return;
        // XPXG files are only in v10
        if (majorVersion == 9) return;

        executeTarget("test4-init");
        executeTarget("test4");

        File f1 = new File("sandbox/pxg/Test.class");
        File f2 = new File("sandbox/pxg/TestImpl.class");
        // 10.1B doesn't handle relative paths...
        assertTrue("Failure expected on 10.1B...", f1.exists());
        assertTrue("Failure expected on 10.1B...", f2.exists());
    }

    public void test5() {
        // Stupid 10.1...
        if ((majorVersion == 10) && (minorVersion == 1)) return;
        // XPXG files are only in v10
        if (majorVersion == 9) return;

        executeTarget("test5-init");
        
        File f1 = new File("sandbox/pxg/Test.class");
        File f2 = new File("sandbox/pxg/TestImpl.class");
        assertFalse(f1.exists());
        assertFalse(f2.exists());
        
        executeTarget("test5");
        assertFalse(f1.exists());
        assertFalse(f2.exists());

        executeTarget("test5-part3");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
    }

}
