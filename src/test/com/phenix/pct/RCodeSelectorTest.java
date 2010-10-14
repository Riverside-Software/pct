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
 * Class for testing RCodeSelector
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
 */
public class RCodeSelectorTest extends BuildFileTest {
    public RCodeSelectorTest(String name) {
        super(name);
    }

    public void setUp() {
        configureProject("RCodeSelector.xml");

        // Creates a sandbox directory to play with
        Mkdir mkdir = new Mkdir();
        mkdir.setProject(this.getProject());
        mkdir.setDir(new File("sandbox"));
        mkdir.execute();
    }

    public void tearDown() throws Exception {
        super.tearDown();
        Delete del = new Delete();
        del.setProject(this.project);
        del.setDir(new File("sandbox"));
        del.execute();
    }

    public void test1() {
        executeTarget("prepare");
        executeTarget("compile");
        executeTarget("test");
        
        File f1 = new File("sandbox/copy1");
        assertEquals(0, f1.list().length);
        
        File f2 = new File("sandbox/copy2");
        assertEquals(0, f2.list().length);
        
        File f3 = new File("sandbox/copy3");
        assertEquals(1, f3.list().length);
        assertTrue(f3.list()[0].equals("test2.r"));

        File f4 = new File("sandbox/copy4");
        assertEquals(1, f4.list().length);
        assertTrue(f4.list()[0].equals("test2.r"));

        File f5 = new File("sandbox/copy5");
        assertEquals(0, f5.list().length);
        
        File f6 = new File("sandbox/copy6");
        assertEquals(1, f6.list().length);
        assertTrue(f6.list()[0].equals("test3.r"));
        
        File f7 = new File("sandbox/copy7");
        assertEquals(1, f7.list().length);
        assertTrue(f7.list()[0].equals("test2.r"));

        File f8 = new File("sandbox/copy8");
        assertEquals(2, f8.list().length);
        assertTrue(f8.list()[0].equals("test2.r"));
        assertTrue(f8.list()[1].equals("test3.r"));
        
        executeTarget("test2");
        f1 = new File("sandbox/copylib1");
        assertEquals(0, f1.list().length);
        
        f2 = new File("sandbox/copylib2");
        assertEquals(0, f2.list().length);

        f3 = new File("sandbox/copylib3");
        assertEquals(1, f3.list().length);
        assertTrue(f3.list()[0].equals("test2.r"));

        f4 = new File("sandbox/copylib4");
        assertEquals(1, f4.list().length);
        assertTrue(f4.list()[0].equals("test2.r"));

        f5 = new File("sandbox/copylib5");
        assertEquals(0, f5.list().length);
        
        f6 = new File("sandbox/copylib6");
        assertEquals(1, f6.list().length);
        assertTrue(f6.list()[0].equals("test3.r"));
        
        f7 = new File("sandbox/copylib7");
        assertEquals(1, f7.list().length);
        assertTrue(f7.list()[0].equals("test2.r"));

        f8 = new File("sandbox/copylib8");
        assertEquals(2, f8.list().length);
        assertTrue(f8.list()[0].equals("test2.r"));
        assertTrue(f8.list()[1].equals("test3.r"));
}

}
