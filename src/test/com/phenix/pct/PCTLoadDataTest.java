/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) The Apache Software Foundation.  All rights
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

import java.io.File;
import java.io.IOException;

import org.apache.tools.ant.BuildException;
import org.testng.annotations.Test;

import com.phenix.pct.RCodeInfo.InvalidRCodeException;

/**
 * Class for testing PCTLoadData task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTLoadDataTest extends BuildFileTestNg {

    /**
     * Should throw BuildException : no filesets and no connection
     */
    @Test(groups= {"v9"}, expectedExceptions = BuildException.class)
    public void test1() {
        configureProject("PCTLoadData/test1/build.xml");
        executeTarget("test");
    }

    /**
     * Should throw BuildException : no filesets (or srcDir) defined
     */
    @Test(groups= {"v9"}, expectedExceptions = BuildException.class)
    public void test2() {
        configureProject("PCTLoadData/test2/build.xml");
        executeTarget("test");
    }

    /**
     * Should throw BuildException : no connection defined
     */
    @Test(groups= {"v9"}, expectedExceptions = BuildException.class)
    public void test3() {
        configureProject("PCTLoadData/test3/build.xml");
        executeTarget("test");
    }

    /**
     * Should load data into database, and expect first result in FOR EACH be 14
     */
    @Test(groups= {"v9"})
    public void test4() {
        configureProject("PCTLoadData/test4/build.xml");
        executeTarget("base");
        executeTarget("load");
        expectLog("test", "16");
    }

    /**
     * Should first load data into table Tab1, then in Tab2, using PCTTable attribute
     */
    @Test(groups= {"v9"})
    public void test5() {
        configureProject("PCTLoadData/test5/build.xml");
        executeTarget("base");
        expectLog("test1", "---");
        expectLog("test2", "---");

        executeTarget("load1");
        expectLog("test1", "16");
        expectLog("test2", "---");

        executeTarget("load2");
        expectLog("test1", "16");
        expectLog("test2", "15");
    }

    /**
     * Test procedure with callback
     */
    @Test(groups= {"v11"})
    public void test6() {
        // Only work with 11.3+
        try {
            DLCVersion version = DLCVersion.getObject(new File(System.getProperty("DLC")));
            if (version.getMinorVersion() <= 2)
                return;
        } catch (IOException e) {
            return;
        } catch (InvalidRCodeException e) {
            return;
        }

        configureProject("PCTLoadData/test6/build.xml");
        executeTarget("base");
        executeTarget("load-replace");
        executeTarget("load-replace");
        executeTarget("test1");
        assertPropertyEquals("LoadData-val1", "2");
        
        executeTarget("load-append");
        executeTarget("load-append");
        executeTarget("test2");
        assertPropertyEquals("LoadData-val2", "6");

        expectBuildException("load-error", "Should fail");
        File f = new File("PCTLoadData/test6/myerrors.txt");
        assertTrue(f.exists());
    }

    /**
     * Test procedure with callback
     */
    @Test(groups= {"v11"})
    public void test7() {
        // Only work with 11.3+
        try {
            DLCVersion version = DLCVersion.getObject(new File(System.getProperty("DLC")));
            if (version.getMinorVersion() <= 2)
                return;
        } catch (IOException e) {
            return;
        } catch (InvalidRCodeException e) {
            return;
        }

        configureProject("PCTLoadData/test7/build.xml");
        executeTarget("base");
        executeTarget("load-noerror");
        expectBuildException("load-error1", "Should fail");
        executeTarget("load-error2");
    }

    /**
     * Format error during load should throw exception
     */
    @Test(groups= {"v11"})
    public void test8() {
        // Only work with 11.3+
        try {
            DLCVersion version = DLCVersion.getObject(new File(System.getProperty("DLC")));
            if (version.getMinorVersion() <= 2)
                return;
        } catch (IOException e) {
            return;
        } catch (InvalidRCodeException e) {
            return;
        }

        configureProject("PCTLoadData/test8/build.xml");
        executeTarget("base");
        // Should fail with PCTLoadDataCallback
        expectBuildException("load1", "Should fail");
        // Doesn't fail with PCTLoadData
        executeTarget("load2");
    }

    /**
     * Format error during load should throw exception
     */
    @Test(groups= {"v11"})
    public void test9() {
        // Only work with 11.3+
        try {
            DLCVersion version = DLCVersion.getObject(new File(System.getProperty("DLC")));
            if (version.getMinorVersion() <= 2)
                return;
        } catch (IOException e) {
            return;
        } catch (InvalidRCodeException e) {
            return;
        }

        configureProject("PCTLoadData/test9/build.xml");
        // Configure database
        executeTarget("base");
        // Record '0' should be there
        executeTarget("test");
        
        // Should fail (invalid numsep numdec)
        expectBuildException("load1", "Should fail");
        // But record '0' should still be there
        executeTarget("test");
        
        // Should fail (invalid data >= tolerance)
        expectBuildException("load2", "Should fail");
        // But record '0' should still be there
        executeTarget("test");
    }

}
