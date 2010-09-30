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
import org.apache.tools.ant.types.Parameter;
import org.apache.tools.ant.types.selectors.BaseExtendSelector;

import java.io.File;

/**
 * Selector for rcode
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET </a>
 * @since PCT 0.17
 */
public class RCodeSelector extends BaseExtendSelector {
    private File dir = null;
    private boolean md5 = false, crc = false;
    
    public void setMD5(boolean md5) {
        this.md5 = md5;
    }
    
    public void setCRC(boolean crc) {
        this.crc = crc;
    }

    public void setDir(File targetDir) {
        this.dir = targetDir;
    }
    
    public void setParameters(Parameter[] parameters) {
        for (int zz = 0; zz < parameters.length; zz++) {
            Parameter param = parameters[zz];
            if ("dir".equalsIgnoreCase(param.getName()))
                setDir(new File(param.getValue()));
        }
    }

    public void verifySettings() {
        super.verifySettings();
        
        if (dir == null)
            setError("No dir attribute defined");
        if (!md5 && !crc)
            setError("One of md5 or crc attribute must be set to true");
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
        
        boolean md5Equals = file1.getMD5().equals(file2.getMD5());
        boolean crcEquals = (file1.getCRC() == file2.getCRC());
        if (md5 && crc)
            return md5Equals && crcEquals;
        if (md5)
            return md5Equals;
        return crcEquals;
    }
}
