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

import java.io.File;
import java.text.MessageFormat;

import org.apache.tools.ant.Project;
import org.apache.tools.ant.types.selectors.BaseExtendSelector;

/**
 * Selector for rcode
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 * @since PCT 0.17
 */
public class RCodeSelector extends BaseExtendSelector {
    private static final int MODE_CRC = 1;
    private static final int MODE_MD5 = 2;
    
    private File dir = null;
    private File lib = null;
    private PLReader reader = null;
    
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

    public void setLib(File lib) {
        this.lib = lib;
    }

    @Override
    public void verifySettings() {
        super.verifySettings();

        if ((dir == null) && (lib == null))
            setError("Either dir or lib must be defined");
        if ((dir != null) && (lib != null))
            setError("Either dir or lib must be defined");
        if ((mode != MODE_CRC) && (mode != MODE_MD5))
            setError("Invalid comparison mode");
        
        if ((lib != null) && (reader == null)) {
            reader = new PLReader(lib);
        }
    }

    /**
     * Compares two rcodes for CRC or MD5, and returns true if CRC or MD5 are either different or one file is
     * missing (or not rcode). Returns false if both files are rcode with an equal CRC or MD5
     * 
     * @param basedir A java.io.File object for the base directory
     * @param filename The name of the file to check
     * @param file A File object for this filename
     * 
     * @return whether the file should be selected or not
     */
    public boolean isSelected(File basedir, String filename, File file) {
        validate();

        RCodeInfo file1;
        RCodeInfo file2;
        try {
            file1 = new RCodeInfo(file);
        } catch (Exception e) {
            log(MessageFormat.format("Source {0} is an invalid rcode -- {1}", filename, e.getMessage()));
            return true;
        }
        
        if (reader == null) {
            try {
                file2 = new RCodeInfo(new File(dir, filename));
            } catch (Exception e) {
                log(MessageFormat.format("Target {0} is an invalid rcode -- {1}", filename, e.getMessage()));
                return true;
            }
        } else {
            FileEntry e = reader.getEntry(filename);
            if (e == null) {
                log(MessageFormat.format("Unable to find entry {0}", filename));
                return true;
            }
            try {
                // PLReader returns a ByteArrayInputStream object, so no need to wrap in a BufferedInputStream
                file2 = new RCodeInfo(reader.getInputStream(e));
            } catch (Exception e2) {
                log(MessageFormat.format("PLTarget {0} is an invalid rcode -- {1}", filename, e2.getMessage()));
                return true;
            }
        }

        switch (mode) {
            case MODE_CRC: 
                log(MessageFormat.format("CRC {2} File1 {0} File2 {1}", file1.getCRC(), file2.getCRC(), filename), Project.MSG_VERBOSE);
                return (file1.getCRC() != file2.getCRC());
            case MODE_MD5:
                log(MessageFormat.format("MD5 {2} File1 {0} File2 {1}", file1.getRcodeDigest(), file2.getRcodeDigest(), filename), Project.MSG_VERBOSE);
                return !file1.getRcodeDigest().equals(file2.getRcodeDigest());
            default:
                return true;
        }
    }
}
