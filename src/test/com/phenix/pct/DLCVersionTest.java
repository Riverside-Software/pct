/**
 * Copyright 2005-2019 Riverside Software
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
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

    @Test(groups = {"v10"})
    public void test1() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 10.2B as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(10, version.getMajorVersion());
        assertEquals(2, version.getMinorVersion());
        assertEquals("B", version.getMaintenanceVersion());
        assertEquals("", version.getPatchVersion());
    }

    @Test(groups = {"v10"})
    public void test2() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 10.2B01 as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(10, version.getMajorVersion());
        assertEquals(2, version.getMinorVersion());
        assertEquals("B", version.getMaintenanceVersion());
        assertEquals("01", version.getPatchVersion());
    }

    @Test(groups = {"v10"})
    public void test3() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 10.2B0102 as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(10, version.getMajorVersion());
        assertEquals(2, version.getMinorVersion());
        assertEquals("B", version.getMaintenanceVersion());
        assertEquals("0102", version.getPatchVersion());
    }

    @Test(groups = {"v10"})
    public void test4() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 10.2B1P as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(10, version.getMajorVersion());
        assertEquals(2, version.getMinorVersion());
        assertEquals("B", version.getMaintenanceVersion());
        assertEquals("1P", version.getPatchVersion());
    }

    @Test(groups = {"v10"})
    public void test5() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 11.0.0 as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, version.getMajorVersion());
        assertEquals(0, version.getMinorVersion());
        assertEquals("0", version.getMaintenanceVersion());
        assertEquals("0", version.getPatchVersion());
    }

    @Test(groups = {"v10"})
    public void test6() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 11.0 as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, version.getMajorVersion());
        assertEquals(0, version.getMinorVersion());
        assertEquals("0", version.getMaintenanceVersion());
        assertEquals("0", version.getPatchVersion());
    }

    @Test(groups = {"v10"})
    public void test7() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 11 as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, version.getMajorVersion());
        assertEquals(0, version.getMinorVersion());
        assertEquals("0", version.getMaintenanceVersion());
        assertEquals("0", version.getPatchVersion());
    }

    @Test(groups = {"v10"})
    public void test8() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 11.1.0 as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, version.getMajorVersion());
        assertEquals(1, version.getMinorVersion());
        assertEquals("0", version.getMaintenanceVersion());
        assertEquals("0", version.getPatchVersion());
    }

    @Test(groups = {"v10"})
    public void test9() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 11.1 as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, version.getMajorVersion());
        assertEquals(1, version.getMinorVersion());
        assertEquals("0", version.getMaintenanceVersion());
        assertEquals("0", version.getPatchVersion());
    }

    @Test(groups = {"v10"})
    public void test10() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 11.1.1 as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, version.getMajorVersion());
        assertEquals(1, version.getMinorVersion());
        assertEquals("1", version.getMaintenanceVersion());
        assertEquals("0", version.getPatchVersion());
    }

    @Test(groups = {"v10"})
    public void test11() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 11.0.0.0BETA as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, version.getMajorVersion());
        assertEquals(0, version.getMinorVersion());
        assertEquals("0", version.getMaintenanceVersion());
        assertEquals("0", version.getPatchVersion());
    }

    @Test(groups = {"v10"})
    public void test12() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 11.0.0BETA as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, version.getMajorVersion());
        assertEquals(0, version.getMinorVersion());
        assertEquals("0", version.getMaintenanceVersion());
        assertEquals("0", version.getPatchVersion());
    }

    @Test(groups = {"v10"})
    public void test13() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 11.0BETA as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, version.getMajorVersion());
        assertEquals(0, version.getMinorVersion());
        assertEquals("0", version.getMaintenanceVersion());
        assertEquals("0", version.getPatchVersion());
    }

    @Test(groups = {"v10"})
    public void test14() {
        DLCVersion version = DLCVersion
                .getObject("OpenEdge Release 11BETA as of Fri Nov 13 19:02:09 EST 2009");
        assertEquals(11, version.getMajorVersion());
        assertEquals(0, version.getMinorVersion());
        assertEquals("0", version.getMaintenanceVersion());
        assertEquals("0", version.getPatchVersion());
    }

}
