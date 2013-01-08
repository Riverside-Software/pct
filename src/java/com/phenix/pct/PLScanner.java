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
        FileProvider fp = (FileProvider) archive.as(FileProvider.class);
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
