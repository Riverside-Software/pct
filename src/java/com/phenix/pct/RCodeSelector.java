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

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.types.selectors.BaseExtendSelector;

import java.io.File;

/**
 * Selector for rcode
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET </a>
 * @since PCT 0.17
 */
public class RCodeSelector extends BaseExtendSelector {
    private final static int MODE_CRC = 1;
    private final static int MODE_MD5 = 2;
    
    private File dir = null;
    private int mode = MODE_CRC;

    public void setMode(String mode) {
        if ("crc".equalsIgnoreCase(mode))
            this.mode = MODE_CRC;
        else if ("md5".equalsIgnoreCase(mode))
            this.mode = MODE_MD5;
    }

    public void setDir(File dir) {
        this.dir = dir;
    }

    public void verifySettings() {
        super.verifySettings();

        if (dir == null)
            setError("No dir attribute defined");
        if ((mode != MODE_CRC) && (mode != MODE_MD5))
            setError("Invalid comparison mode");
    }

    /**
     * Compares two rcodes for CRC, and returns true if CRC are either different or one file is
     * missing (or not rcode). Returns false if both files are rcode with an equal CRC
     * 
     * @param basedir A java.io.File object for the base directory
     * @param filename The name of the file to check
     * @param file A File object for this filename
     * 
     * @return whether the file should be selected or not
     */
    public boolean isSelected(File basedir, String filename, File file) throws BuildException {
        validate();

        RCodeInfo file1, file2;
        try {
            file1 = new RCodeInfo(file);
        } catch (Exception e) {
            return true;
        }
        try {
            file2 = new RCodeInfo(new File(this.dir, filename));
        } catch (Exception e) {
            return true;
        }

        switch (mode) {
            case MODE_CRC: return (file1.getCRC() != file2.getCRC());
            case MODE_MD5: return !file1.getMD5().equals(file2.getMD5());
            default: return true;
        }
    }
}
