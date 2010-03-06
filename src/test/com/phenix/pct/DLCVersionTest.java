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

import com.phenix.pct.DLCVersion.Builder;

/**
 * Class for testing version extraction
 * 
 * @author <a href="mailto:g.querret@gmail.com">Gilles QUERRET</a>
 */
public class DLCVersionTest extends TestCase {

    public void test1() {
        Builder builder = new Builder();
        DLCVersion.readVersionFile(builder,
                "OpenEdge Release 10.2B as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(10, builder.major);
        assertEquals(2, builder.minor);
        assertEquals("B", builder.maintenance);
        assertEquals("", builder.patch);
    }

    public void test2() {
        Builder builder = new Builder();
        DLCVersion.readVersionFile(builder,
                "OpenEdge Release 10.2B01 as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(10, builder.major);
        assertEquals(2, builder.minor);
        assertEquals("B", builder.maintenance);
        assertEquals("01", builder.patch);
    }

    public void test3() {
        Builder builder = new Builder();
        DLCVersion.readVersionFile(builder,
                "OpenEdge Release 10.2B0102 as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(10, builder.major);
        assertEquals(2, builder.minor);
        assertEquals("B", builder.maintenance);
        assertEquals("0102", builder.patch);
    }

    public void test4() {
        Builder builder = new Builder();
        DLCVersion.readVersionFile(builder,
                "OpenEdge Release 10.2B1P as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(10, builder.major);
        assertEquals(2, builder.minor);
        assertEquals("B", builder.maintenance);
        assertEquals("1P", builder.patch);
    }

    public void test5() {
        Builder builder = new Builder();
        DLCVersion.readVersionFile(builder,
                "OpenEdge Release 11.0.0 as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, builder.major);
        assertEquals(0, builder.minor);
        assertEquals("0", builder.maintenance);
        assertEquals("0", builder.patch);
    }

    public void test6() {
        Builder builder = new Builder();
        DLCVersion.readVersionFile(builder,
                "OpenEdge Release 11.0 as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, builder.major);
        assertEquals(0, builder.minor);
        assertEquals("0", builder.maintenance);
        assertEquals("0", builder.patch);
    }

    public void test7() {
        Builder builder = new Builder();
        DLCVersion.readVersionFile(builder,
                "OpenEdge Release 11 as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, builder.major);
        assertEquals(0, builder.minor);
        assertEquals("0", builder.maintenance);
        assertEquals("0", builder.patch);
    }

    public void test8() {
        Builder builder = new Builder();
        DLCVersion.readVersionFile(builder,
                "OpenEdge Release 11.1.0 as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, builder.major);
        assertEquals(1, builder.minor);
        assertEquals("0", builder.maintenance);
        assertEquals("0", builder.patch);
    }

    public void test9() {
        Builder builder = new Builder();
        DLCVersion.readVersionFile(builder,
                "OpenEdge Release 11.1 as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, builder.major);
        assertEquals(1, builder.minor);
        assertEquals("0", builder.maintenance);
        assertEquals("0", builder.patch);
    }

    public void test10() {
        Builder builder = new Builder();
        DLCVersion.readVersionFile(builder,
                "OpenEdge Release 11.1.1 as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, builder.major);
        assertEquals(1, builder.minor);
        assertEquals("1", builder.maintenance);
        assertEquals("0", builder.patch);
    }

    public void test11() {
        Builder builder = new Builder();
        DLCVersion.readVersionFile(builder,
                "OpenEdge Release 11.0.0.0BETA as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, builder.major);
        assertEquals(0, builder.minor);
        assertEquals("0", builder.maintenance);
        assertEquals("0", builder.patch);
    }

    public void test12() {
        Builder builder = new Builder();
        DLCVersion.readVersionFile(builder,
                "OpenEdge Release 11.0.0BETA as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, builder.major);
        assertEquals(0, builder.minor);
        assertEquals("0", builder.maintenance);
        assertEquals("0", builder.patch);
    }

    public void test13() {
        Builder builder = new Builder();
        DLCVersion.readVersionFile(builder,
                "OpenEdge Release 11.0BETA as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, builder.major);
        assertEquals(0, builder.minor);
        assertEquals("0", builder.maintenance);
        assertEquals("0", builder.patch);
    }

    public void test14() {
        Builder builder = new Builder();
        DLCVersion.readVersionFile(builder,
                "OpenEdge Release 11BETA as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, builder.major);
        assertEquals(0, builder.minor);
        assertEquals("0", builder.maintenance);
        assertEquals("0", builder.patch);
    }

}
