package com.phenix.pct;

import org.apache.tools.ant.types.ArchiveFileSet;
import org.apache.tools.ant.types.ArchiveScanner;
import org.apache.tools.ant.types.FileSet;

public class PLFileSet extends ArchiveFileSet {
    public PLFileSet() {
        super();
    }

    protected PLFileSet(FileSet fileset) {
        super(fileset);
    }

    protected PLFileSet(PLFileSet fileset) {
        super(fileset);
    }

    protected ArchiveScanner newArchiveScanner() {
        return new PLScanner();
    }
}
