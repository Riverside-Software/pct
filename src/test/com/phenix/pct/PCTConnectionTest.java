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

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.taskdefs.ExecTask;

import java.util.Enumeration;


/**
 * Class for testing PCTConnection class
 * @author <a href="mailto:gilles.querret@nerim.net">Gilles QUERRET</a>
 */
public class PCTConnectionTest extends TestCase {
    private ExecTask exec = null;
    private Project project = null;

    public void setUp() {
        // Defines a new Project and a new ExecTask
        project = new Project();
        project.init();
        exec = new ExecTask();
        exec.setProject(project);
    }

    public void tearDown() {
    }

    public void testDbNameRequired() {
        PCTConnection conn = new PCTConnection();

        try {
            conn.createArguments(exec);
        } catch (BuildException be) {
            return;
        }

        fail("Should throw BuildException");
    }

    public void testAliases() {
        PCTConnection conn = new PCTConnection();

        if (conn.getAliases() != null) {
            fail("No aliases should be defined at this time");
        }

        PCTAlias alias1 = new PCTAlias();
        PCTAlias alias2 = new PCTAlias();
        alias1.setName("alias1");
        alias2.setName("alias2");
        alias2.setNoError(true);
        conn.addPCTAlias(alias1);
        conn.addPCTAlias(alias2);

        if (conn.getAliases().size() != 2) {
            fail("There should be only 2 aliases");
        }

        for (Enumeration e = conn.getAliases().elements(); e.hasMoreElements();) {
            PCTAlias a = (PCTAlias) e.nextElement();
            String s = a.getName();

            if (s.equalsIgnoreCase("alias1")) {
            } else if (s.equalsIgnoreCase("alias2")) {
                if (!a.getNoError()) {
                    fail("Alias 2 should be noError");
                }
            } else {
                fail("Another alias found");
            }
        }
    }
}
