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
import java.util.Map;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.types.ArchiveScanner;
import org.apache.tools.ant.types.Resource;
import org.apache.tools.ant.types.resources.FileProvider;


public class PLScanner extends ArchiveScanner {

    @SuppressWarnings({"rawtypes", "unchecked"})
    protected void fillMapsFromArchive(Resource archive, String encoding, Map fileEntries,
            Map matchFileEntries, Map dirEntries, Map matchDirEntries) {
        File srcFile = null;
        FileProvider fp = archive.as(FileProvider.class);
        if (fp != null) {
            srcFile = fp.getFile();
        } else {
            throw new BuildException("Only file provider resources are supported");
        }

        PLReader reader = new PLReader(srcFile);

        for (FileEntry entry : reader.getFileList()) {
            Resource r = new PLResource(srcFile, entry);
            String name = entry.getFileName();
            fileEntries.put(name, r);
            if (match(name)) {
                matchFileEntries.put(name, r);
            }
        }
    }
}
