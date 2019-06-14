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
     * Compares CRC and MD5 using RCodeInfo and RCODE-INFO:CRC-VALUE
     */
    @Test(groups = { "v10" })
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
        assertEquals(md5_1, file1.getRcodeDigest());
        assertEquals(md5_2, file2.getRcodeDigest());
    }

}
