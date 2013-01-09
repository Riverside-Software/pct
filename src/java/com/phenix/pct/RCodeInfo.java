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

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;

/**
 * Gathers informations from r-code, as the RCODE-INFO system handle could provide. This class is
 * based upon procrc.c from Grant Maizels (grant AT maizels DOT nu). All credits go to his work.
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 * @version $Revision$
 * @since PCT 0.11
 */
public class RCodeInfo {
    // Magic numbers
    private final static int MAGIC1 = 0x56CED309;
    private final static int MAGIC2 = 0x09D3CE56; // Bytes swapped

    private final static short HEADER_SIZE = 68;

    private boolean swapped;
    private int version;
    private boolean sixty_four_bits;
    private long crc;
    private String md5;
    private long timeStamp;

    private File file;
    private FileInputStream input;
    private int segmentTableSize;
    private long signatureSize;

    public RCodeInfo(File file) throws InvalidRCodeException, IOException {
        this.file = file;
        this.input = new FileInputStream(file);

        processFile();
    }

    public File getFile() {
        return file;
    }

    /**
     * Returns r-code CRC
     * 
     * @return CRC
     */
    public long getCRC() {
        return crc;
    }

    /**
     * Returns r-code compiler version
     * 
     * @return Version
     */
    public long getVersion() {
        return version;
    }

    /**
     * Returns r-code timestamp (in milliseconds)
     * 
     * @return Timestamp
     */
    public long getTimeStamp() {
        return timeStamp;
    }

    public String getMD5() {
        return md5;
    }

    public boolean is64bits() {
        return sixty_four_bits;
    }

    private void processFile() throws InvalidRCodeException, IOException {
        FileChannel fc = input.getChannel();

        long magic = readUnsignedInt(fc, 0, false);
        if (magic == MAGIC1) {
            swapped = false;
        } else if (magic == MAGIC2) {
            swapped = true;
        } else {
            input.close();
            throw new InvalidRCodeException("Can't find magic number");
        }

        this.version = readUnsignedShort(fc, 14, swapped);
        this.sixty_four_bits = ((version & 0x4000) != 0);

        if ((version & 0x3FFF) >= 1100) {
            processV11(fc, swapped);
        } else if ((version & 0x3FFF) > 1000) {
            processV10(fc, swapped);
        } else
            processV9(fc, swapped);
    }

    void processV11(FileChannel fc, boolean swapped) throws IOException {
        timeStamp = readUnsignedInt(fc, 4, swapped);
        int md5Offset = readUnsignedShort(fc, 10, swapped);
        // maxFileNumber = readUnsignedShort(fc, 10, swapped);
        // compilerVersion = readUnsignedShort(fc, 12, swapped);
        // demoVersion = readByte(fc, 25);
        segmentTableSize = readUnsignedShort(fc, 0x1E, swapped);
        // serialRestriction = readUnsignedInt(fc, 28, swapped);
        // expirationDate = readUnsignedInt(fc, 32, swapped);
        signatureSize = readUnsignedInt(fc, 56, swapped);
        // typeBlockSize = readUnsignedInt(fc, 60, swapped);
        // rcodeSize = readUnsignedInt(fc, 64, swapped);
        crc = readUnsignedShort(fc, HEADER_SIZE + segmentTableSize + signatureSize + 0xA4, swapped);
        md5 = bufferToHex(fc, HEADER_SIZE + segmentTableSize + (int) signatureSize + md5Offset, 16);
    }

    void processV10(FileChannel fc, boolean swapped) throws IOException {
        timeStamp = readUnsignedInt(fc, 4, swapped);
        signatureSize = readUnsignedShort(fc, 8, swapped);
        int md5Offset = readUnsignedShort(fc, 10, swapped);
        segmentTableSize = readUnsignedShort(fc, 30, swapped);
        crc = readUnsignedShort(fc, HEADER_SIZE + segmentTableSize + (int) signatureSize + 0x6E,
                swapped);
        md5 = bufferToHex(fc, HEADER_SIZE + segmentTableSize + (int) signatureSize + md5Offset, 16);
    }

    void processV9(FileChannel fc, boolean swapped) throws IOException {
        timeStamp = readUnsignedInt(fc, 4, swapped);
        signatureSize = readUnsignedShort(fc, 8, swapped);
        int md5Offset = readUnsignedShort(fc, 10, swapped);
        segmentTableSize = readUnsignedShort(fc, 30, swapped);
        crc = readUnsignedShort(fc, HEADER_SIZE + segmentTableSize + (int) signatureSize + 0x46,
                swapped);
        md5 = bufferToHex(fc, HEADER_SIZE + segmentTableSize + (int) signatureSize + md5Offset, 16);
    }

    private static int readUnsignedShort(FileChannel fc, long pos, boolean swapped)
            throws IOException {
        ByteBuffer buf = ByteBuffer.allocate(2);
        if (fc.position(pos).read(buf) != 2)
            throw new IOException("Unable to read short at position " + pos);

        if (swapped)
            return (((int) buf.get(1) & 0xFF) << 8) + ((int) buf.get(0) & 0xFF);
        else
            return (((int) buf.get(0) & 0xFF) << 8) + ((int) buf.get(1) & 0xFF);
    }

    private static long readUnsignedInt(FileChannel fc, long pos, boolean swapped)
            throws IOException {
        ByteBuffer buf = ByteBuffer.allocate(4);
        if (fc.position(pos).read(buf) != 4)
            throw new IOException("Unable to read int at position " + pos);

        if (swapped)
            return (((int) buf.get(3) & 0xFF) << 24) + (((int) buf.get(2) & 0xFF) << 16)
                    + (((int) buf.get(1) & 0xFF) << 8) + ((int) buf.get(0) & 0xFF);
        else
            return (((int) buf.get(0) & 0xFF) << 24) + (((int) buf.get(1) & 0xFF) << 16)
                    + (((int) buf.get(2) & 0xFF) << 8) + ((int) buf.get(3) & 0xFF);
    }

    private static String bufferToHex(FileChannel fc, int startOffset, int length)
            throws IOException {
        ByteBuffer buf = ByteBuffer.allocate(length);
        fc.position(startOffset).read(buf);

        StringBuffer hexString = new StringBuffer(2 * length);
        for (int i = 0; i < length; i++)
            appendHexPair(buf.get(i), hexString);

        return hexString.toString();
    }

    private static void appendHexPair(byte b, StringBuffer hexString) {
        char highNibble = kHexChars[(b & 0xF0) >> 4];
        char lowNibble = kHexChars[b & 0x0F];

        hexString.append(highNibble);
        hexString.append(lowNibble);
    }

    /**
     * @see http://www.bombaydigital.com/arenared/2004/2/12/1
     */
    private static final char kHexChars[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A',
            'B', 'C', 'D', 'E', 'F'};

    public static class InvalidRCodeException extends Exception {
        private static final long serialVersionUID = 1L;

        public InvalidRCodeException(String s) {
            super(s);
        }
    }
}
