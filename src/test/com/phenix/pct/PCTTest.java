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

import junit.framework.TestCase;

import org.apache.tools.ant.Project;
import org.apache.tools.ant.taskdefs.Delete;
import org.apache.tools.ant.taskdefs.Mkdir;

import java.io.File;


/**
 * Class for testing PCT abstract task
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
 */
public class PCTTest extends TestCase {
    private static final String DLC = "dlc/";
    private static final String DLC_BIN = "dlc/bin/";
    private static final String DLC_BIN_FAKE = "bin/";
    private static final String DLC_JAVA = "dlc/java/";
    private static final String DLC_JAVA_FAKE = "java/";
    private static final String DLC_PROXYGEN_ZIP = "proxygen.zip";
    private static final String DLC_PROGRESS_ZIP = "progress.zip";
    private static final String DLC_PROGRESS_JAR = "progress.jar";
    private Project project;
    private PCTRun pct;

    /**
     * Sets up the fixture
     */
    public void setUp() {
        project = new Project();
        project.init();
        pct = new PCTRun();
        pct.setProject(project);

        Mkdir mkdir = new Mkdir();
        mkdir.setProject(project);
        mkdir.setDir(new File(DLC));
        mkdir.execute();
        mkdir.setDir(new File(DLC_BIN));
        mkdir.execute();
        mkdir.setDir(new File(DLC_JAVA));
        mkdir.execute();
        mkdir.setDir(new File(DLC_BIN_FAKE));
        mkdir.execute();
        mkdir.setDir(new File(DLC_JAVA_FAKE));
        mkdir.execute();
    }

    /**
     * Tears down the fixture
     */
    public void tearDown() {
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
    public void testDlcBinCheck() {
        File bin = new File(DLC_BIN);

        pct.setDlcHome(new File(DLC));
        assertEquals(bin, pct.getDlcBin());
    }

    /**
     * Check if setting dlcBin attribute overrides bin subdirectory
     * found when setting dlcHome attribute
     */
    public void testDlcBinOverride() {
        File bin = new File(DLC_BIN_FAKE);

        pct.setDlcHome(new File(DLC));
        pct.setDlcBin(bin);
        assertEquals(bin, pct.getDlcBin());
    }

}
