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

import static org.testng.Assert.assertEquals;
import static org.testng.Assert.fail;

import java.io.File;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.taskdefs.Copy;
import org.apache.tools.ant.taskdefs.Delete;
import org.apache.tools.ant.taskdefs.Echo;
import org.apache.tools.ant.taskdefs.Mkdir;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

/**
 * Class for testing PCT abstract task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTTest {
    private static final String DLC = "dlc/";
    private static final String DLC_TTY = "dlc/tty/";
    private static final String DLC_BIN = "dlc/bin/";
    private static final String DLC_BIN_FAKE = "bin/";
    private static final String DLC_JAVA = "dlc/java/";
    private static final String DLC_JAVA_FAKE = "java/";
    private static final String DLC_FAKE = "dlc/foo";
    private Project project;
    private PCTRun pct;

    @BeforeMethod
    public void setUp() {
        project = new Project();
        project.init();
        pct = new PCTRun();
        pct.setProject(project);

        Mkdir mkdir = new Mkdir();
        mkdir.setProject(project);
        mkdir.setDir(new File(DLC));
        mkdir.execute();
        mkdir.setDir(new File(DLC_TTY));
        mkdir.execute();
        mkdir.setDir(new File(DLC_BIN));
        mkdir.execute();
        mkdir.setDir(new File(DLC_JAVA));
        mkdir.execute();
        mkdir.setDir(new File(DLC_BIN_FAKE));
        mkdir.execute();
        mkdir.setDir(new File(DLC_JAVA_FAKE));
        mkdir.execute();
        
        // setDlcHome() now verifies version
        Echo echo = new Echo();
        echo.setProject(project);
        echo.setFile(new File(DLC + "version"));
        echo.setMessage("OpenEdge Release 10.2B as of Fri Nov 13 19:02:09 EST 2009");
        echo.execute();
        
        Copy copy = new Copy();
        copy.setProject(project);
        copy.setFile(new File("prostart.r"));
        copy.setTofile(new File(DLC_TTY + "prostart.r"));
        copy.execute();
    }

    @AfterMethod
    public void tearDown() throws Exception {
        pct.cleanup();
        Delete del = new Delete();
        del.setProject(project);
        del.setDir(new File(DLC));
        del.execute();
        del.setDir(new File(DLC_BIN_FAKE));
        del.execute();
        del.setDir(new File(DLC_JAVA_FAKE));
        del.execute();
    }

    /**
     * Check if bin subdirectory is detected when dlcHome is set
     */
    @Test
    public void testDlcBinCheck() {
        File bin = new File(DLC_BIN);

        pct.setDlcHome(new File(DLC));
        assertEquals(bin, pct.getDlcBin());
    }

    /**
     * Check if setting dlcBin attribute overrides bin subdirectory found when setting dlcHome
     * attribute
     */
    @Test
    public void testDlcBinOverride() {
        File bin = new File(DLC_BIN_FAKE);

        pct.setDlcHome(new File(DLC));
        pct.setDlcBin(bin);
        assertEquals(bin, pct.getDlcBin());
    }

    /**
     * Check if not valid DLC directory throws BuildException
     */
    @Test
    public void testDlcFailure() {
        File dlc = new File(DLC_FAKE);
        try {
            pct.setDlcHome(dlc);
        } catch (BuildException be) {
            return;
        }
        fail("BuildException should be thrown (dlc directory is wrong");
    }

    /**
     * Check if not valid DLC bin directory throws BuildException
     */
    @Test
    public void testDlcBinFailure() {
        pct.setDlcHome(new File(DLC));
        try {
            pct.setDlcBin(new File(DLC_FAKE));
        } catch (BuildException be) {
            return;
        }
        fail("BuildException should be thrown (dlcBin directory is wrong");
    }

    /**
     * Check if not valid DLC java directory throws BuildException
     */
    @Test
    public void testDlcJavaFailure() {
        pct.setDlcHome(new File(DLC));
        try {
            pct.setDlcJava(new File(DLC_FAKE));
        } catch (BuildException be) {
            return;
        }
        fail("BuildException should be thrown (dlcJava directory is wrong");
    }

}
