/*
 * Copyright  2000-2004 The Apache Software Foundation
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

import org.apache.tools.ant.types.selectors.MappingSelector;

import java.io.File;

/**
 * Selector for rcode
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET </a>
 * @since PCT 0.11
 */
public class CRCDifferent extends MappingSelector {

    /**
     * Compares two rcodes for CRC, and returns true if CRC are either different or one file is
     * missing (or not rcode). Returns false if both files are rcode with an equal CRC
     * 
     * @param srcFile the source file
     * @param destFile the destination file
     * @return true if the files are different
     */
    protected boolean selectionTest(File srcFile, File destFile) {
        RCodeInfo file1, file2;
        try {
            file1 = new RCodeInfo(srcFile);
        } catch (Exception e) {
            return true;
        }
        try {
            file2 = new RCodeInfo(destFile);
        } catch (Exception e) {
            return true;
        }
        return (file1.getCRC() != file2.getCRC());
    }

}
