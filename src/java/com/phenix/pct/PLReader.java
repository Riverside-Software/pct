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

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.RandomAccessFile;

import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.channels.FileChannel;
import java.nio.charset.Charset;

import java.text.MessageFormat;

import java.util.Date;
import java.util.Enumeration;
import java.util.Vector;

/**
 * Class for reading and extracting contents of a Progress Library file.
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
 */
public class PLReader {
    private static final int MAGIC = 0xD707;
    private static final int ENCODING_OFFSET = 0x02;
    private static final int FILE_LIST_OFFSET = 0x1E;
    private static final int RECORD_MIN_SIZE = 29;
    private static final int RECORD_MAX_SIZE = RECORD_MIN_SIZE + 255;

    private File f;
    private Vector files = null;
    private boolean init = false;
//    private String encoding = null;
    
    public PLReader(File f) {
        this.f = f;
        init();
    }

    /**
     * Performs initialization actions like checking file integrity and reading file list
     */
    public void init() {
        this.init = false;

        if (this.f == null) {
            throw new NullPointerException();
        }

        this.files = new Vector();

        try {
            readFileList();
            this.init = true;
        } catch (Exception e) {
            System.out.println(e);
        }
    }

    /**
     * Specifies a file to read. Should be initialized with init
     * 
     * @param f File to read
     */
    public void setFile(File f) {
        this.f = f;
        this.init = false;
        this.files = null;
    }

    /**
     * Specifies a file to read.
     * 
     * @param f File to read
     * @param init If initialization should be done
     */
    public void setFile(File f, boolean init) {
        this.f = f;

        if (init) {
            init();
        } else {
            this.init = false;
            this.files = null;
        }
    }

    /**
     * 
     * @return Vector of FileEntry
     */
    public Vector getFileList() {
        if (this.init) {
            return this.files;
        } else {
            return null;
        }
    }

    /**
     * Read file list
     * 
     * @throws Exception File has bad format
     */
    private void readFileList() throws Exception {
        ByteBuffer bb = ByteBuffer.allocate(RECORD_MAX_SIZE);
        long offset = 0;
        int br = 0;
        Charset charset = null;
        
        if (!checkMagic()) {
            return;
        }

        try {
            FileInputStream fis = new FileInputStream(f);
            FileChannel in = fis.getChannel();
            
            // Reads encoding from library
            ByteBuffer bEncoding = ByteBuffer.allocate(20); 
            in.read(bEncoding, ENCODING_OFFSET);
            bEncoding.position(0);
            byte bb3;
            StringBuffer sbEncoding = new StringBuffer();
            while((bb3 = bEncoding.get()) != 0) {
                sbEncoding.append((char) bb3);
            }
            try {
                charset = Charset.forName(sbEncoding.toString());
            } catch (IllegalArgumentException iae) {
                System.out.println("Unknown charset : " + sbEncoding.toString() + " - Defaulting to US-ASCII");
                charset = Charset.forName("US-ASCII");
            }
            
            ByteBuffer b = ByteBuffer.allocate(4);
            int f_offs = in.read(b, FILE_LIST_OFFSET);

            if (f_offs == 4) {
                // 4 bytes were read
                offset = ((long) b.getInt(0) & 0xffffffffL);

                StringBuffer sb = new StringBuffer();

                // Reading first file in list
                br = in.read(bb, offset);

                while (br > RECORD_MIN_SIZE) {
                    // First byte should be 0xFE or 0xFF
                    short magic = ((short) (bb.get(0) & (short) 0xff));

                    if (magic == 0xFE) {
                        int k = 1;

                        while (((short) (bb.get(k) & (short) 0xff)) != 0xFF) {
                            k++;
                        }

                        // Reading next entry
                        offset += k;
                        bb.clear();
                        br = in.read(bb, offset);
                    } else if (magic == 0xFF) {
                        short fnsz = ((short) (bb.get(1) & (short) 0xff));

                        if (fnsz > 0) {
                            sb.setLength(0);
                            
                            bb.position(1);
                            ByteBuffer bb2 = bb.duplicate();
                            bb2.limit(bb2.get(1) + 2);
                            bb2.position(2);
                            CharBuffer fileName = charset.decode(bb2);

                            offset += (RECORD_MIN_SIZE + fnsz);

                            long fileOffset = ((long) bb.getInt(fnsz + 4) & 0xffffffffL);
                            long fileSize = ((long) bb.getInt(fnsz + 9) & 0xffffffffL);
                            long addDate = ((long) bb.getInt(fnsz + 13) & 0xffffffffL);
                            long modDate = ((long) bb.getInt(fnsz + 17) & 0xffffffffL);

                            // Creates new file entry and adds it to vector
                            FileEntry fe = new FileEntry(fileName.toString(), modDate, addDate,
                                    fileOffset, (int) fileSize);
                            files.add(fe);

                            // Reading next entry
                            bb.clear();
                            br = in.read(bb, offset);
                        } else {
                            br = 0;
                        }
                    } else {
                        try {
                            in.close();
                            fis.close();
                        } catch (IOException ioe) {
                        }
                        throw new Exception(MessageFormat.format(Messages.getString("PLReader.0"),
                                new Object[]{new Long(offset), new Long(magic)}));
                    }
                }
            } else { // i == 4

                try {
                    in.close();
                    fis.close();
                } catch (IOException ioe) {
                }

                throw new Exception(Messages.getString("PLReader.12")); //$NON-NLS-1$
            }

            in.close();
            fis.close();
        } catch (IOException ioe) {
            System.out.println(ioe.getMessage());
        }
    }

    public String toString() {
        if (!this.init) {
            return Messages.getString("PLReader.13"); //$NON-NLS-1$
        }

        if (this.files == null) {
            return Messages.getString("PLReader.14"); //$NON-NLS-1$
        }

        StringBuffer sb = new StringBuffer();
        for (Enumeration e = files.elements(); e.hasMoreElements();) {
            FileEntry fe = (FileEntry) e.nextElement();
            sb.append(fe.toString());
            sb.append("\n");
        }
        return sb.toString();
    }

    public boolean checkMagic() {
        boolean retVal = false;

        try {
            FileInputStream fis = new FileInputStream(f);
            FileChannel in = fis.getChannel();

            ByteBuffer bb = ByteBuffer.allocate(2);
            int i = in.read(bb, 0);

            if (i == 2) {
                int magic = (bb.getShort(0) & 0xffff);
                retVal = (magic == MAGIC);
            } else {
                retVal = false;
            }

            in.close();
            fis.close();

            return retVal;
        } catch (FileNotFoundException fnfe) {
            System.out.println(fnfe.getMessage());
        } catch (IOException ioe) {
            System.out.println(ioe.getMessage());
        }

        return false;
    }

    public boolean extractFile(FileEntry fe, File dest) {
        try {
            if (!dest.getParentFile().exists())
                if (!dest.getParentFile().mkdirs())
                    return false;

            RandomAccessFile raf = new RandomAccessFile(this.f, "r");
            raf.seek(fe.getOffset());
            RandomAccessFile out = new RandomAccessFile(dest, "rw");
            for (long l = 0; l < fe.getSize(); l++) {
                out.writeByte(raf.readUnsignedByte()); // TODO Use packets of byte
            }
            out.close();
            raf.close();
        } catch (FileNotFoundException fnfe) {
            System.out.println("Unable to find file " + fnfe.getMessage());
        } catch (IOException ioe) {
            System.out.println("oel"); // TODO Message
        }
        return true;
    }

    public static void main(String[] args) {
        PLReader t = new PLReader(new File(args[0]));
        System.out.println(t);
    }

    /**
     * Class representing a static file entry in a PL file
     */
    public class FileEntry {
        private String fileName;
        private Date modDate;
        private Date addDate;
        private long offset;
        private int size;

        public FileEntry(String fileName, long modDate, long addDate, long offSet, int size) {
            this.fileName = fileName;
            this.modDate = new Date(modDate * 1000);
            this.addDate = new Date(addDate * 1000);
            this.offset = offSet;
            this.size = size;
        }

        public String getFileName() {
            return this.fileName;
        }

        public int getSize() {
            return this.size;
        }

        public Date getModDate() {
            return this.modDate;
        }

        public Date getAddDate() {
            return this.addDate;
        }

        public long getOffset() {
            return this.offset;
        }

        public String toString() {
            return MessageFormat
                    .format(
                            Messages.getString("PLReader.6"), new Object[]{this.fileName, new Integer(size), this.addDate, this.modDate, new Long(offset)}); //$NON-NLS-1$
        }
    }
}
