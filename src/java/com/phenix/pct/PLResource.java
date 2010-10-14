package com.phenix.pct;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import org.apache.tools.ant.types.resources.ArchiveResource;
import org.apache.tools.ant.types.resources.FileResource;


public class PLResource extends ArchiveResource {
    private FileEntry e;

    public PLResource(File z, FileEntry e) {
        super(z, true);
        this.e = e;
        setEntry(e);
    }

    protected void fetchEntry() {
        // Nothing....
    }

    public InputStream getInputStream() throws IOException {
        FileResource res = (FileResource) this.getArchive();
        return new PLReader(res.getFile()).getInputStream(e);
    }

    private void setEntry(FileEntry e) {
        if (e == null) {
            setExists(false);
            return;
        }
        setName(e.getFileName());
        setExists(true);
        setLastModified(e.getModDate());
        setDirectory(false);
        setSize(e.getSize());
    }

    public class PLFileInputStream extends FileInputStream {
        private int bytesRead = 0;
        private FileEntry e;

        public PLFileInputStream(File file, FileEntry e) throws IOException {
            super(file);

            this.e = e;
            skip(e.getOffset());
        }

        public int available() throws IOException {
            return e.getSize() - bytesRead;
        }

        public int read() throws IOException {
            if (bytesRead > e.getSize())
                return -1;
            bytesRead++;
            return super.read();
        }

        public int read(byte[] b) throws IOException {
            throw new UnsupportedOperationException("Not supported 1");
        }

        public int read(byte[] b, int off, int len) throws IOException {
            if (bytesRead >= e.getSize())
                return -1;
            if (bytesRead + len > e.getSize()) {
                int i = super.read(b, off, e.getSize() - bytesRead);
                bytesRead = e.getSize();
                return i;
            } else {
                super.read(b, off, len);
                bytesRead += len;
                return len;
            }
        }
    }
}
