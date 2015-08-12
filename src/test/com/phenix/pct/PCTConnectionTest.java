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
import static org.testng.Assert.assertTrue;
import static org.testng.Assert.assertFalse;
import static org.testng.Assert.fail;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.taskdefs.ExecTask;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

/**
 * Class for testing PCTConnection class
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
 */
public class PCTConnectionTest extends BuildFileTestNg {
    private ExecTask exec = null;
    private Project project = null;

    @BeforeMethod
    public void setUp() {
        // Defines a new Project and a new ExecTask
        project = new Project();
        project.init();
        exec = new ExecTask();
        exec.setProject(project);
    }

    @Test(groups = {"v9"}, expectedExceptions = BuildException.class)
    public void testDbNameRequired() {
        PCTConnection conn = new PCTConnection();
        conn.createArguments(exec);
    }

    @Test(groups = {"v9"})
    public void testAliases() {
        PCTConnection conn = new PCTConnection();

        if (conn.getAliases().size() > 0) {
            fail("No aliases should be defined at this time");
        }

        PCTAlias alias1 = new PCTAlias();
        PCTAlias alias2 = new PCTAlias();
        alias1.setName("alias1");
        alias2.setName("alias2");
        alias2.setNoError(true);
        conn.addConfiguredPCTAlias(alias1);
        conn.addConfiguredPCTAlias(alias2);

        if (conn.getAliases().size() != 2) {
            fail("There should be only 2 aliases");
        }

        for (PCTAlias a : conn.getAliases()) {
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

    @Test(groups = {"v9"})
    public void testNamedAlias() {
        PCTConnection conn = new PCTConnection();
        PCTAlias alias1 = new PCTAlias();
        alias1.setName("alias1");
        conn.addConfiguredPCTAlias(alias1);
        alias1 = new PCTAlias();
        alias1.setName("alias3");
        conn.addConfiguredPCTAlias(alias1);

        assertTrue(conn.hasNamedAlias("alias1"));
        assertTrue(conn.hasNamedAlias("alias3"));
        assertFalse(conn.hasNamedAlias("alias2"));
    }

    @Test(groups = {"v9"})
    public void testReference() {
        configureProject("PCTConnection/test1/build.xml");
        Object db1 = getProject().getReference("db1");
        Object db2 = getProject().getReference("db2");
        Object db3 = getProject().getReference("db3");
        Object db4 = getProject().getReference("db4");
        Object db5 = getProject().getReference("db5");
        Object db6 = getProject().getReference("db6");
        Object db7 = getProject().getReference("db7");
        Object set1 = getProject().getReference("set1");
        Object set2 = getProject().getReference("set2");

        assertTrue(db1 instanceof PCTConnection);
        assertTrue(db2 instanceof PCTConnection);
        assertTrue(db3 instanceof PCTConnection);
        assertTrue(db4 instanceof PCTConnection);
        assertTrue(db5 instanceof PCTConnection);
        assertTrue(db6 instanceof PCTConnection);
        assertTrue(db7 instanceof PCTConnection);
        assertTrue(set1 instanceof DBConnectionSet);
        assertTrue(set2 instanceof DBConnectionSet);
        
        PCTConnection c1 = (PCTConnection) db1;
        PCTConnection c2 = (PCTConnection) db2;
        PCTConnection c3 = (PCTConnection) db3;
        PCTConnection c4 = (PCTConnection) db4;
        PCTConnection c5 = (PCTConnection) db5;
        PCTConnection c6 = (PCTConnection) db6;
        PCTConnection c7 = (PCTConnection) db7;

        assertTrue(c1.getAliases().size() == 0);
        assertTrue(c2.getAliases().size() == 1);
        assertTrue(c3.getAliases().size() == 3);
        assertTrue(c4.getAliases().size() == 3);
        assertTrue(c6.getConnectParametersList().contains("-1"));
        assertTrue(c6.getConnectParametersList().contains("-S"));
        assertTrue(c6.getConnectParametersList().contains("1234"));
        assertFalse(c7.getConnectParametersList().contains("-1"));
        
        DBConnectionSet s1 = (DBConnectionSet) set1;
        assertEquals(s1.getDBConnections().size(), 3);
        DBConnectionSet s2 = (DBConnectionSet) set2;
        assertEquals(s2.getDBConnections().size(), 3);
    }
}
