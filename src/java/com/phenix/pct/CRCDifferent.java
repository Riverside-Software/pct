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

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.types.Parameter;
import org.apache.tools.ant.types.selectors.BaseExtendSelector;

import java.io.File;

/**
 * Selector for rcode
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 * @since PCT 0.11
 */
public class CRCDifferent extends BaseExtendSelector {
    private File targetDir = null;

    private void setTargetDir() {
        Parameter[] params = this.getParameters();
        for (int i = 0; i < params.length; i++) {
            if ("targetDir".equalsIgnoreCase(params[i].getName())) {
                this.targetDir = new File(params[i].getValue());
            }
        }
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
    public boolean isSelected(File basedir, String filename, File file) {
        RCodeInfo file1;
        RCodeInfo file2;
        if (this.targetDir == null)
            setTargetDir();
        if (this.targetDir == null) {
            throw new BuildException("Unable to find targetDir attribute in CRCDifferent mapper");
        }
        try {
            file1 = new RCodeInfo(file);
        } catch (Exception e) {
            return true;
        }
        try {
            file2 = new RCodeInfo(new File(this.targetDir, filename));
        } catch (Exception e) {
            return true;
        }
        return (file1.getCRC() != file2.getCRC());
    }
}
