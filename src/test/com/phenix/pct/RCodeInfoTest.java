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

import static org.testng.Assert.assertEquals;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

import org.testng.annotations.Test;

import com.phenix.pct.RCodeInfo.InvalidRCodeException;

/**
 * Class for testing RCodeInfo class
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */

public class RCodeInfoTest extends BuildFileTestNg {

    /**
     * Compares CRC using RCodeInfo and RCODE-INFO:CRC-VALUE
     */
    @Test
    public void test1() throws IOException, InvalidRCodeException {
        String md5_1, md5_2, crc1, crc2;

        configureProject("RCodeInfo/test1/build.xml");
        executeTarget("test");

        BufferedReader br = new BufferedReader(new FileReader(new File(
                "RCodeInfo/test1/build/test1.crc")));
        crc1 = br.readLine();
        md5_1 = br.readLine();
        br.close();

        BufferedReader br2 = new BufferedReader(new FileReader(new File(
                "RCodeInfo/test1/build/test2.crc")));
        crc2 = br2.readLine();
        md5_2 = br2.readLine();
        br2.close();

        RCodeInfo file1 = new RCodeInfo(new File("RCodeInfo/test1/build/test1.r"));
        RCodeInfo file2 = new RCodeInfo(new File("RCodeInfo/test1/build/test2.r"));

        assertEquals(Long.parseLong(crc1), file1.getCRC());
        assertEquals(Long.parseLong(crc2), file2.getCRC());
        assertEquals(md5_1, file1.getMD5());
        assertEquals(md5_2, file2.getMD5());
    }

}
