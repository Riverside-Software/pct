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

import org.apache.tools.ant.taskdefs.Delete;
import org.apache.tools.ant.taskdefs.Mkdir;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

import java.io.File;
import java.io.FileInputStream;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.channels.FileChannel;
import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;
import java.util.regex.Matcher;

/**
 * Class for testing PCTDumpIncremental task
 * Assertion - following classes should work properly : PCTCreateBase PCTCompile PCTLoadSchema
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
 */
public class PCTDumpIncrementalTest extends BuildFileTestNg {

    @BeforeMethod
    public void setUp() {
        configureProject("PCTDumpIncremental.xml");

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
        del.setProject(this.project);
        del.setDir(new File("sandbox"));
        del.execute();
    }

    @Test
    public void test1() {
        File f = new File("sandbox/incr.df");
        File f2 = new File("sandbox/test1.r");

        executeTarget("test1init");
        executeTarget("test1");
        assertTrue(f.exists());
        executeTarget("test1bis");
        assertTrue(f2.exists());
    }

    @Test
    public void test2() {
        File f1 = new File("sandbox/incr1.df");
        File f2 = new File("sandbox/incr2.df");

        executeTarget("test2init");
        executeTarget("test2");
        assertTrue(f1.exists());
        assertTrue(f2.exists());

        java.util.regex.Pattern regexp = java.util.regex.Pattern.compile("INACTIVE",
                java.util.regex.Pattern.MULTILINE);
        // Get a Channel for the source file
        try {
            FileInputStream fis = new FileInputStream(f1);
            FileChannel fc = fis.getChannel();

            // Get a CharBuffer from the source file
            ByteBuffer bb = fc.map(FileChannel.MapMode.READ_ONLY, 0, (int) fc.size());
            Charset cs = Charset.forName("8859_1");
            CharsetDecoder cd = cs.newDecoder();
            CharBuffer cb = cd.decode(bb);

            Matcher m = regexp.matcher(cb);
            if (m.find())
                fail("Index was declared inactive but activeIndexes is set to TRUE");
        } catch (Exception e) {
            fail("Unable to parse file incr1.df");
        }

        regexp = java.util.regex.Pattern.compile("INACTIVE", java.util.regex.Pattern.MULTILINE);
        // Get a Channel for the source file
        try {
            FileInputStream fis = new FileInputStream(f2);
            FileChannel fc = fis.getChannel();

            // Get a CharBuffer from the source file
            ByteBuffer bb = fc.map(FileChannel.MapMode.READ_ONLY, 0, (int) fc.size());
            Charset cs = Charset.forName("8859_1");
            CharsetDecoder cd = cs.newDecoder();
            CharBuffer cb = cd.decode(bb);

            // Run some matches
            Matcher m = regexp.matcher(cb);
            if (!m.find())
                fail("Index wasn't declared inactive but activeIndexes is set to FALSE");
        } catch (Exception e) {
            fail("Unable to parse file incr2.df");
        }
    }

    @Test
    public void test3() {
        File f1 = new File("sandbox/incr1.df");
        File f2 = new File("sandbox/incr2.df");

        executeTarget("test3init");
        executeTarget("test3");
        assertTrue(f1.exists());
        assertTrue(f2.exists());

        java.util.regex.Pattern regexp = java.util.regex.Pattern.compile("cpstream=iso8859-1",
                java.util.regex.Pattern.MULTILINE);
        // Get a Channel for the source file
        try {
            FileInputStream fis = new FileInputStream(f1);
            FileChannel fc = fis.getChannel();

            // Get a CharBuffer from the source file
            ByteBuffer bb = fc.map(FileChannel.MapMode.READ_ONLY, 0, (int) fc.size());
            Charset cs = Charset.forName("ISO-8859-1");
            CharsetDecoder cd = cs.newDecoder();
            CharBuffer cb = cd.decode(bb);

            Matcher m = regexp.matcher(cb);
            if (!m.find())
                fail("Codepage declared was iso8859-1");
        } catch (Exception e) {
            fail("Unable to parse file incr1.df");
        }

        regexp = java.util.regex.Pattern.compile("cpstream=utf-8",
                java.util.regex.Pattern.MULTILINE);
        // Get a Channel for the source file
        try {
            FileInputStream fis = new FileInputStream(f2);
            FileChannel fc = fis.getChannel();

            // Get a CharBuffer from the source file
            ByteBuffer bb = fc.map(FileChannel.MapMode.READ_ONLY, 0, (int) fc.size());
            Charset cs = Charset.forName("utf-8");
            CharsetDecoder cd = cs.newDecoder();
            CharBuffer cb = cd.decode(bb);

            // Run some matches
            Matcher m = regexp.matcher(cb);
            if (!m.find())
                fail("Codepage declared was iso8859-1");
        } catch (Exception e) {
            fail("Unable to parse file incr2.df");
        }
    }

    @Test
    public void test4() {
        File f1 = new File("sandbox/incr1.df");
        File f2 = new File("sandbox/incr2.df");

        executeTarget("test4init");
        executeTarget("test4");
        assertTrue(f1.exists());
        assertTrue(f2.exists());
        assertTrue(f1.length() != f2.length());
    }
}
