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

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.Base64;

/**
 * Gathers informations from r-code, as the RCODE-INFO system handle could provide. This class is
 * based upon procrc.c from Grant Maizels (grant AT maizels DOT nu). All credits go to his work.
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 * @since PCT 0.11
 */
public class RCodeInfo {
    // Magic numbers
    private static final int MAGIC1 = 0x56CED309;
    private static final int MAGIC2 = 0x09D3CE56; // Bytes swapped

    private static final short HEADER_SIZE = 68;
    private static final short HEADER_SIZE_V12 = 84;
    private static final short RCODE_DIGEST_HEADER_SIZE = 16;

    private int version;
    private boolean sixtyFourBits;
    private long crc;
    private String rcodeDigest;
    private long rCodeSize;
    private long timeStamp;

    private InputStream input;
    private int segmentTableSize;
    private long signatureSize;

    public RCodeInfo(File file) throws InvalidRCodeException, IOException {
        this(new BufferedInputStream(new FileInputStream(file), 65536));
    }

    /**
     * Input stream has to support mark()/reset(). Buffer should be large enough, otherwise this
     * method may throw an IOException. Large enough depends on number of methods and signatures.
     * This will be fixed in later releases.
     */
    public RCodeInfo(InputStream input) throws InvalidRCodeException, IOException {
        this.input = input;
        this.input.mark(0);
        processFile();
        input.close();
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

    public String getRcodeDigest() {
        return rcodeDigest;
    }

    public long getRCodeSize() {
        return rCodeSize;
    }

    public boolean is64bits() {
        return sixtyFourBits;
    }

    private void processFile() throws InvalidRCodeException, IOException {
        boolean swapped;
        long magic = readUnsignedInt(input, 0, false);
        if (magic == MAGIC1) {
            swapped = false;
        } else if (magic == MAGIC2) {
            swapped = true;
        } else {
            input.close();
            throw new InvalidRCodeException("Can't find magic number");
        }

        this.version = Math.abs(readShort(input, 14, swapped));
        this.sixtyFourBits = ((version & 0x4000) != 0);

        if ((version & 0x3FFF) >= 1200) {
            processV12(input, swapped);
        } else if ((version & 0x3FFF) >= 1100) {
            processV11(input, swapped);
        } else if ((version & 0x3FFF) > 1000) {
            processV10(input, swapped);
        } else
            processV9(input, swapped);
    }

    void processV12(InputStream fc, boolean swapped) throws IOException {
        timeStamp = readUnsignedInt(fc, 4, swapped);
        int rcodeDigestOffset = readUnsignedShort(fc, 22, swapped);
        segmentTableSize = readUnsignedShort(fc, 0x1E, swapped);
        signatureSize = readUnsignedInt(fc, 56, swapped);
        rCodeSize = readUnsignedInt(fc, 80, swapped);
        crc = readUnsignedShort(fc, HEADER_SIZE_V12 + segmentTableSize + signatureSize + 0xAE, swapped);
        rcodeDigest = bufferToBase64(fc, HEADER_SIZE_V12 + segmentTableSize + signatureSize + rcodeDigestOffset + RCODE_DIGEST_HEADER_SIZE, 32);
    }

    void processV11(InputStream fc, boolean swapped) throws IOException {
        timeStamp = readUnsignedInt(fc, 4, swapped);
        int md5Offset = readUnsignedShort(fc, 10, swapped);
        segmentTableSize = readUnsignedShort(fc, 0x1E, swapped);
        signatureSize = readUnsignedInt(fc, 56, swapped);
        rCodeSize = readUnsignedInt(fc, 64, swapped);
        crc = readUnsignedShort(fc, HEADER_SIZE + segmentTableSize + signatureSize + 0xA4, swapped);
        rcodeDigest = bufferToHex(fc, HEADER_SIZE + segmentTableSize + signatureSize + md5Offset, 16);
    }

    void processV10(InputStream fc, boolean swapped) throws IOException {
        timeStamp = readUnsignedInt(fc, 4, swapped);
        signatureSize = readUnsignedShort(fc, 8, swapped);
        int md5Offset = readUnsignedShort(fc, 10, swapped);
        segmentTableSize = readUnsignedShort(fc, 30, swapped);
        rCodeSize = readUnsignedInt(fc, 64, swapped);
        crc = readUnsignedShort(fc, HEADER_SIZE + segmentTableSize + signatureSize + 0x6E, swapped);
        rcodeDigest = bufferToHex(fc, HEADER_SIZE + segmentTableSize + signatureSize + md5Offset, 16);
    }

    void processV9(InputStream fc, boolean swapped) throws IOException {
        timeStamp = readUnsignedInt(fc, 4, swapped);
        signatureSize = readUnsignedShort(fc, 8, swapped);
        int md5Offset = readUnsignedShort(fc, 10, swapped);
        segmentTableSize = readUnsignedShort(fc, 30, swapped);
        crc = readUnsignedShort(fc, HEADER_SIZE + segmentTableSize + signatureSize + 0x46, swapped);
        rcodeDigest = bufferToHex(fc, HEADER_SIZE + segmentTableSize + signatureSize + md5Offset, 16);
    }

    private static short readShort(InputStream input, long pos, boolean swapped)
            throws IOException {
        byte[] buf = new byte[2];
        input.reset();
        input.skip(pos);
        input.read(buf);

        return ByteBuffer.wrap(buf).order(swapped ? ByteOrder.LITTLE_ENDIAN : ByteOrder.BIG_ENDIAN)
                .getShort();
    }

    private static int readUnsignedShort(InputStream input, long pos, boolean swapped)
            throws IOException {
        byte[] buf = new byte[2];
        input.reset();
        input.skip(pos);
        input.read(buf);

        if (swapped)
            return (((int) buf[1] & 0xFF) << 8) + ((int) buf[0] & 0xFF);
        else
            return (((int) buf[0] & 0xFF) << 8) + ((int) buf[1] & 0xFF);
    }

    private static long readUnsignedInt(InputStream input, long pos, boolean swapped)
            throws IOException {
        byte[] buf = new byte[4];
        input.reset();
        input.skip(pos);
        input.read(buf);

        if (swapped)
            return (((int) buf[3] & 0xFF) << 24) + (((int) buf[2] & 0xFF) << 16)
                    + (((int) buf[1] & 0xFF) << 8) + ((int) buf[0] & 0xFF);
        else
            return (((int) buf[0] & 0xFF) << 24) + (((int) buf[1] & 0xFF) << 16)
                    + (((int) buf[2] & 0xFF) << 8) + ((int) buf[3] & 0xFF);
    }

    private static String bufferToHex(InputStream input, long startOffset, int length)
            throws IOException {
        byte[] buf = new byte[length];
        input.reset();
        input.skip(startOffset);
        input.read(buf);

        StringBuilder hexString = new StringBuilder(2 * length);
        for (int i = 0; i < length; i++) {
            hexString.append(String.format("%02X", buf[i]));
        }

        return hexString.toString();
    }

    private static String bufferToBase64(InputStream input, long startOffset, int length) throws IOException {
        byte[] buf = new byte[length];
        input.reset();
        input.skip(startOffset);
        input.read(buf);

        return Base64.getEncoder().encodeToString(buf);
    }

    public static class InvalidRCodeException extends Exception {
        private static final long serialVersionUID = 1L;

        public InvalidRCodeException(String s) {
            super(s);
        }
    }

}
