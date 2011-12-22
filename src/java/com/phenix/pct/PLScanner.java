package com.phenix.pct;

import java.io.File;
import java.util.Iterator;
import java.util.Map;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.types.ArchiveScanner;
import org.apache.tools.ant.types.Resource;
import org.apache.tools.ant.types.resources.FileProvider;


public class PLScanner extends ArchiveScanner {

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
//        reader.init();
        for (Iterator iter = reader.getFileList().iterator(); iter.hasNext();) {
            FileEntry entry = (FileEntry) iter.next();
            Resource r = new PLResource(srcFile, entry);
            String name = entry.getFileName();
            fileEntries.put(name, r);
            if (match(name)) {
                matchFileEntries.put(name, r);
            }
        }
    }
}
