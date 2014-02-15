/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) 2002-2003 The Apache Software Foundation.  v9+ rights
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
 *    if and wherever such third-party acknowlegements normv9+y appear.
 *
 * 4. The names "Ant" and "Apache Software
 *    Foundation" must not be used to endorse or promote products derived
 *    from this software without prior written permission. For written
 *    permission, please contact apache@apache.org.
 *
 * 5. Products derived from this software may not be cv9+ed "Apache"
 *    nor may "Apache" appear in their names without prior written
 *    permission of the Apache Group.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHv9+ THE APACHE SOFTWARE FOUNDATION OR
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

import org.testng.annotations.Test;

/**
 * Class for testing version extraction
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class DLCVersionTest {

    @Test(groups = {"v9+"})
    public void test1() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 10.2B as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(10, version.getMajorVersion());
        assertEquals(2, version.getMinorVersion());
        assertEquals("B", version.getMaintenanceVersion());
        assertEquals("", version.getPatchVersion());
    }

    @Test(groups = {"v9+"})
    public void test2() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 10.2B01 as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(10, version.getMajorVersion());
        assertEquals(2, version.getMinorVersion());
        assertEquals("B", version.getMaintenanceVersion());
        assertEquals("01", version.getPatchVersion());
    }

    @Test(groups = {"v9+"})
    public void test3() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 10.2B0102 as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(10, version.getMajorVersion());
        assertEquals(2, version.getMinorVersion());
        assertEquals("B", version.getMaintenanceVersion());
        assertEquals("0102", version.getPatchVersion());
    }

    @Test(groups = {"v9+"})
    public void test4() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 10.2B1P as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(10, version.getMajorVersion());
        assertEquals(2, version.getMinorVersion());
        assertEquals("B", version.getMaintenanceVersion());
        assertEquals("1P", version.getPatchVersion());
    }

    @Test(groups = {"v9+"})
    public void test5() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 11.0.0 as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, version.getMajorVersion());
        assertEquals(0, version.getMinorVersion());
        assertEquals("0", version.getMaintenanceVersion());
        assertEquals("0", version.getPatchVersion());
    }

    @Test(groups = {"v9+"})
    public void test6() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 11.0 as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, version.getMajorVersion());
        assertEquals(0, version.getMinorVersion());
        assertEquals("0", version.getMaintenanceVersion());
        assertEquals("0", version.getPatchVersion());
    }

    @Test(groups = {"v9+"})
    public void test7() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 11 as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, version.getMajorVersion());
        assertEquals(0, version.getMinorVersion());
        assertEquals("0", version.getMaintenanceVersion());
        assertEquals("0", version.getPatchVersion());
    }

    @Test(groups = {"v9+"})
    public void test8() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 11.1.0 as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, version.getMajorVersion());
        assertEquals(1, version.getMinorVersion());
        assertEquals("0", version.getMaintenanceVersion());
        assertEquals("0", version.getPatchVersion());
    }

    @Test(groups = {"v9+"})
    public void test9() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 11.1 as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, version.getMajorVersion());
        assertEquals(1, version.getMinorVersion());
        assertEquals("0", version.getMaintenanceVersion());
        assertEquals("0", version.getPatchVersion());
    }

    @Test(groups = {"v9+"})
    public void test10() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 11.1.1 as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, version.getMajorVersion());
        assertEquals(1, version.getMinorVersion());
        assertEquals("1", version.getMaintenanceVersion());
        assertEquals("0", version.getPatchVersion());
    }

    @Test(groups = {"v9+"})
    public void test11() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 11.0.0.0BETA as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, version.getMajorVersion());
        assertEquals(0, version.getMinorVersion());
        assertEquals("0", version.getMaintenanceVersion());
        assertEquals("0", version.getPatchVersion());
    }

    @Test(groups = {"v9+"})
    public void test12() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 11.0.0BETA as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, version.getMajorVersion());
        assertEquals(0, version.getMinorVersion());
        assertEquals("0", version.getMaintenanceVersion());
        assertEquals("0", version.getPatchVersion());
    }

    @Test(groups = {"v9+"})
    public void test13() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 11.0BETA as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, version.getMajorVersion());
        assertEquals(0, version.getMinorVersion());
        assertEquals("0", version.getMaintenanceVersion());
        assertEquals("0", version.getPatchVersion());
    }

    @Test(groups = {"v9+"})
    public void test14() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 11BETA as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, version.getMajorVersion());
        assertEquals(0, version.getMinorVersion());
        assertEquals("0", version.getMaintenanceVersion());
        assertEquals("0", version.getPatchVersion());
    }

}
