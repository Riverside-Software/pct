/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) 2002 The Apache Software Foundation.  All rights
 * reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution, if
 *    any, must include the following acknowlegement:
 *       "This product includes software developed by the
 *        Apache Software Foundation (http://www.apache.org/)."
 *    Alternately, this acknowlegement may appear in the software itself,
 *    if and wherever such third-party acknowlegements normally appear.
 *
 * 4. The names "Ant" and "Apache Software
 *    Foundation" must not be used to endorse or promote products derived
 *    from this software without prior written permission. For written
 *    permission, please contact apache@apache.org.
 *
 * 5. Products derived from this software may not be called "Apache"
 *    nor may "Apache" appear in their names without prior written
 *    permission of the Apache Group.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE APACHE SOFTWARE FOUNDATION OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation.  For more
 * information on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 */
package com.phenix.pct;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.RandomAccessFile;

import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.charset.Charset;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * Class for reading and extracting contents of a Progress Library file.
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
 */
public class PLReader {
    private static final int MAGIC = 0xd707;
    private static final int MAGIC_V11 = 0xd70b;
    private static final int MAGIC_SIZE = 2;
    private static final int ENCODING_OFFSET = 0x02;
    private static final int ENCODING_SIZE = 20;
    private static final int FILE_LIST_OFFSET = 0x1e;
    private static final int FILE_LIST_OFFSET_V11 = 0x22;
    // private static final int RECORD_MIN_SIZE = 29;
    // private static final int RECORD_MAX_SIZE = RECORD_MIN_SIZE + 255;

    private File pl;
    private List /* FileEntry */files = null;

    public PLReader(File file) {
        String name = file.getPath();
        SecurityManager sm = System.getSecurityManager();
        if (sm != null) {
            sm.checkRead(name);
        }

        this.pl = file;
    }

    /**
     * Returns entries contained in this procedure library
     * 
     * @throws RuntimeException If file is not a valid procedure library
     */
    public List getFileList() {
        if (this.files == null)
            readFileList();
        return files;
    }

    public FileEntry getEntry(String name) {
        for (Iterator iter = getFileList().iterator(); iter.hasNext();) {
            FileEntry entry = (FileEntry) iter.next();
            if (entry.getFileName().equals(name))
                return entry;
        }

        return null;
    }

    private void readFileList() {
        RandomAccessFile raf = null;
        try {
            raf = new RandomAccessFile(pl, "r");
            FileChannel fc = raf.getChannel();
            int version = 0;
            ByteBuffer magic = ByteBuffer.allocate(2);
            fc.read(magic);
            if ((magic.getShort(0) & 0xffff) == MAGIC)
                version = 1;
            else if ((magic.getShort(0) & 0xffff) == MAGIC_V11)
                version = 2;
            else
                // if (!checkMagic(fc))
                throw new RuntimeException("Not a valid PL file");

            Charset charset = getCharset(fc);
            int offset = getTOCOffset(fc, version);
            files = new ArrayList();
            FileEntry fe = null;
            while ((fe = readEntry(fc, offset, charset, version)) != null) {
                if (fe.isValid())
                    files.add(fe);
                offset += fe.getTocSize();
            }
        } catch (IOException caught) {
            throw new RuntimeException(caught);
        } finally {
            if (raf != null) {
                try {
                    raf.close();
                } catch (IOException uncaught) {

                }
            }
        }
    }

    public InputStream getInputStream(FileEntry fe) throws IOException {
        ByteBuffer bb = null;
        RandomAccessFile raf = null;
        try {
            raf = new RandomAccessFile(pl, "r");
            FileChannel fc = raf.getChannel();
            bb = ByteBuffer.allocate(fe.getSize());
            fc.read(bb, fe.getOffset());
        } finally {
            try {
                raf.close();
            } catch (IOException uncaught) {

            }
        }

        return new ByteArrayInputStream(bb.array());
    }

    private Charset getCharset(FileChannel fc) throws IOException {
        ByteBuffer bEncoding = ByteBuffer.allocate(ENCODING_SIZE);
        if (fc.read(bEncoding, ENCODING_OFFSET) != ENCODING_SIZE)
            throw new RuntimeException("Invalid PL file");
        bEncoding.position(0);
        StringBuffer sbEncoding = new StringBuffer();
        int zz = 0;
        while ((zz < 20) && (bEncoding.get(zz) != 0)) {
            sbEncoding.append((char) bEncoding.get(zz++));
        }
        try {
            return Charset.forName(sbEncoding.toString());
        } catch (IllegalArgumentException iae) {
            return Charset.forName("US-ASCII");
        }
    }

    private int getTOCOffset(FileChannel fc, int version) throws IOException {
        ByteBuffer bTOC = ByteBuffer.allocate(4);
        if (fc.read(bTOC, (version == 1 ? FILE_LIST_OFFSET : FILE_LIST_OFFSET_V11)) != 4)
            throw new RuntimeException("Invalid PL file");
        return bTOC.getInt(0);
    }

    private FileEntry readEntry(FileChannel fc, int offset, Charset charset, int version)
            throws IOException {
        ByteBuffer b1 = ByteBuffer.allocate(1);
        fc.read(b1, offset);

        if (b1.get(0) == (byte) 0xFE) {
            boolean stop = false;
            int zz = 0;
            while (!stop) {
                b1.position(0);
                int kk = fc.read(b1, offset + ++zz);
                stop = (kk == -1) || (b1.get(0) == (byte) 0xFF);
            }

            return new FileEntry(zz);
        } else if (b1.get(0) == (byte) 0xFF) {
            b1.position(0);
            fc.read(b1, offset + 1);
            int fNameSize = (int) b1.get(0) & 0xFF;
            if (fNameSize == 0)
                return new FileEntry(29);
            ByteBuffer b2 = ByteBuffer.allocate(fNameSize);
            fc.read(b2, offset + 2);
            b2.position(0);
            String fName = charset.decode(b2).toString();
            ByteBuffer b3 = ByteBuffer.allocate((version == 1 ? 28 : 48)); // Ou 47
            fc.read(b3, offset + 2 + fNameSize);
            int fileOffset = b3.getInt((version == 1 ? 2 : 6)); // 7
            int fileSize = b3.getInt((version == 1 ? 7 : 11)); // 12
            long added = b3.getInt((version == 1 ? 11 : 15)) * 1000L; // 16
            long modified = b3.getInt((version == 1 ? 15 : 19)) * 1000L; // 20

            int tocSize = (b3.get((version == 1 ? 27 : 47)) == 0 ? (version == 1 ? 30 : 50)
                    + fNameSize : (version == 1 ? 29 : 49) + fNameSize);
            return new FileEntry(fName, modified, added, fileOffset, fileSize, tocSize);
        } else {
            return null;
        }

    }
}
