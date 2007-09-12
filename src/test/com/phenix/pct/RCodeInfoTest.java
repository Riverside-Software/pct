/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) 2002 The Apache Software Foundation. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *  1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *  3. The end-user documentation included with the redistribution, if any,
 * must include the following acknowlegement: "This product includes software
 * developed by the Apache Software Foundation (http://www.apache.org/)."
 * Alternately, this acknowlegement may appear in the software itself, if and
 * wherever such third-party acknowlegements normally appear.
 *  4. The names "Ant" and "Apache Software Foundation" must not be used to
 * endorse or promote products derived from this software without prior written
 * permission. For written permission, please contact apache@apache.org.
 *  5. Products derived from this software may not be called "Apache" nor may
 * "Apache" appear in their names without prior written permission of the
 * Apache Group.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * APACHE SOFTWARE FOUNDATION OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many individuals
 * on behalf of the Apache Software Foundation. For more information on the
 * Apache Software Foundation, please see <http://www.apache.org/> .
 */

package com.phenix.pct;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import org.apache.tools.ant.Project;
import org.apache.tools.ant.taskdefs.Delete;
import org.apache.tools.ant.taskdefs.Mkdir;
import org.apache.tools.ant.types.FileSet;

import junit.framework.TestCase;

/**
 * Class for testing RCodeInfo class
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
 */

public class RCodeInfoTest extends TestCase {
    File sandbox = new File("sandbox");
    File rcode = new File("rcode");
    protected Project project;

    public void setUp() {
        project = new Project();
        project.init();

        Mkdir mk = new Mkdir();
        mk.setProject(project);
        mk.setDir(sandbox);
        mk.execute();

    }

    public void tearDown() {
        Delete del = new Delete();
        del.setProject(project);
        del.setDir(sandbox);
        del.execute();
    }

    /**
     * Compares CRC using RCodeInfo and RCODE-INFO:CRC-VALUE
     */
    public void test1() {
        BufferedWriter bw = null;
        String md5_1, md5_2, crc1, crc2;

        try {
            // Test files
            bw = new BufferedWriter(new FileWriter(new File(sandbox, "test1.p")));
            bw.write("MESSAGE 'Hello world !'");
            bw.close();
            bw = new BufferedWriter(new FileWriter(new File(sandbox, "test2.p")));
            bw.write("MESSAGE 'Hello galaxy !'");
            bw.close();

            PCTCompile comp = new PCTCompile();
            comp.setProject(project);
            comp.setBaseDir(sandbox);
            comp.setDlcHome(new File(System.getProperty("DLC")));
            comp.setDestDir(sandbox);
            comp.setMinSize(false);
            FileSet fs = new FileSet();
            fs.setDir(sandbox);
            fs.setIncludes("test*.p");
            comp.addFileset(fs);
            comp.execute();

            // Extracting CRC
            bw = new BufferedWriter(new FileWriter(new File(sandbox, "crc.p")));
            bw.write("RCODE-INFO:FILE-NAME = ENTRY(1, SESSION:PARAMETER, ':').");
            bw.newLine();
            bw.write("OUTPUT TO VALUE(ENTRY(2, SESSION:PARAMETER, ':')).");
            bw.newLine();
            bw.write("MESSAGE RCODE-INFO:CRC-VALUE.");
            bw.newLine();
            if (comp.getMajorVersion() >= 10) {
                bw.write("MESSAGE RCODE-INFO:MD5-VALUE.");
                bw.newLine();
            }
            bw.write("OUTPUT CLOSE.");
            bw.newLine();
            bw.write("RETURN '0'.");
            bw.close();

            PCTRun run = new PCTRun();
            run.setProject(project);
            run.setBaseDir(sandbox);
            run.setDlcHome(new File(System.getProperty("DLC")));
            run.setProcedure("crc.p");
            run.setParameter("test1.p:test1.crc");
            run.execute();

            BufferedReader br = new BufferedReader(new FileReader(new File(sandbox, "test1.crc")));
            crc1 = br.readLine();
            if (comp.getMajorVersion() >= 10) {
                md5_1 = br.readLine();
            }
            else {
                md5_1 = "-1";
            }
            br.close();

            run.setParameter("test2.p:test2.crc");
            run.execute();
            br = new BufferedReader(new FileReader(new File(sandbox, "test2.crc")));
            crc2 = br.readLine();
            if (comp.getMajorVersion() >= 10) {
                md5_2 = br.readLine();
            }
            else {
                md5_2 = "-1";
            }
            br.close();

            RCodeInfo file1 = new RCodeInfo(new File(sandbox, "test1.r"));
            RCodeInfo file2 = new RCodeInfo(new File(sandbox, "test2.r"));
            assertEquals(Long.parseLong(crc1), file1.getCRC());
            assertEquals(Long.parseLong(crc2), file2.getCRC());
            if (comp.getMajorVersion() >= 10) {
                assertEquals(md5_1, file1.getMD5());
                assertEquals(md5_2, file2.getMD5());
            }

        } catch (IOException ioe) {
            fail("Unable to write Progress procedure -- Test case is broken");
        } catch (RCodeInfo.InvalidRCodeException irce) {

        }
    }

}
