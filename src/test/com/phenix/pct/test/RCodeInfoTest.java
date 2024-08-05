/**
 * Copyright 2005-2024 Riverside Software
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
package com.phenix.pct.test;

import static org.testng.Assert.assertEquals;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.testng.annotations.Test;

import eu.rssw.pct.RCodeInfo;
import eu.rssw.pct.RCodeInfo.InvalidRCodeException;

/**
 * Class for testing RCodeInfo class
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */

public class RCodeInfoTest extends BuildFileTestNg {

    /**
     * Compares CRC and MD5 using RCodeInfo and RCODE-INFO:CRC-VALUE
     */
    @Test(groups = {"v11"})
    public void test1() throws IOException, InvalidRCodeException {
        String digest1;
        String digest2;
        String crc1;
        String crc2;

        configureProject("RCodeInfo/test1/build.xml");
        executeTarget("test");

        try (BufferedReader reader = Files
                .newBufferedReader(Paths.get("RCodeInfo/test1/build/test1.crc"))) {
            crc1 = reader.readLine();
            digest1 = reader.readLine();
        }

        try (BufferedReader reader = Files
                .newBufferedReader(Paths.get("RCodeInfo/test1/build/test2.crc"))) {
            crc2 = reader.readLine();
            digest2 = reader.readLine();
        }

        RCodeInfo file1 = new RCodeInfo(
                new FileInputStream(new File("RCodeInfo/test1/build/test1.r")));
        RCodeInfo file2 = new RCodeInfo(
                new FileInputStream(new File("RCodeInfo/test1/build/test2.r")));

        assertEquals(Long.parseLong(crc1), file1.getCrc());
        assertEquals(Long.parseLong(crc2), file2.getCrc());
        assertEquals(digest1, file1.getDigest());
        assertEquals(digest2, file2.getDigest());
    }

}
