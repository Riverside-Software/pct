/**
 * Copyright 2005-2018 Riverside Software
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
import java.util.Arrays;

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

    private boolean swapped;
    private int version;
    private boolean sixty_four_bits;
    private long crc;
    private String md5;
    private long rCodeSize;
    private long timeStamp;

    private InputStream input;
    private int segmentTableSize;
    private long signatureSize;
    private String debugListingFile;

    public RCodeInfo(File file) throws InvalidRCodeException, IOException {
        this(new BufferedInputStream(new FileInputStream(file), 65536));
    }

    /**
     * Input stream has to support mark()/reset(). Buffer should be large enough, otherwise this
     * method may throw an IOException. Large enough depends on number of methods and signatures.
     * This will be fixed in later releases.
     * 
     * @param input
     * @throws InvalidRCodeException
     * @throws IOException
     */
    public RCodeInfo(InputStream input) throws InvalidRCodeException, IOException {
        this.input = input;
        this.input.mark(0);
        processFile();
        readDebugListing();
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

    public String getMD5() {
        return md5;
    }

    public long getRCodeSize() {
        return rCodeSize;
    }

    public boolean is64bits() {
        return sixty_four_bits;
    }

    public String getDebugListingFile() {
        return debugListingFile;
    }

    private void readDebugListing() throws IOException {
        byte[] buf1 = new byte[1024], buf2 = new byte[2048];
        input.reset();
        // Make sure we have at least 1024 bytes in buf2
        while (input.read(buf1) == 1024) {
            buf2 = Arrays.copyOf(buf1, buf1.length * 2);
            Arrays.fill(buf1, (byte) 0); 
        }
        for (int zz = 0; zz < buf1.length; zz++) {
            buf2[1024 + zz] = buf1[zz];
        }
        int last00 = -1, first02 = -1;
        // Search backwards for last 0x00 and first 0x02
        for (int zz = 2047; zz >= 0; zz--) {
            if ((first02 == -1) && (buf2[zz] == 0x00)) {
                last00 = zz;
            }
            if ((first02 == -1) && (buf2[zz] == 0x02)) {
                first02 = zz;
                break;
            }
        }
        debugListingFile = new String(Arrays.copyOfRange(buf2, first02 + 1, last00));
    }

    private void processFile() throws InvalidRCodeException, IOException {
        long magic = readUnsignedInt(input, 0, false);
        if (magic == MAGIC1) {
            swapped = false;
        } else if (magic == MAGIC2) {
            swapped = true;
        } else {
            input.close();
            throw new InvalidRCodeException("Can't find magic number");
        }

        this.version = readUnsignedShort(input, 14, swapped);
        this.sixty_four_bits = ((version & 0x4000) != 0);

        if ((version & 0x3FFF) >= 1100) {
            processV11(input, swapped);
        } else if ((version & 0x3FFF) > 1000) {
            processV10(input, swapped);
        } else
            processV9(input, swapped);
    }

    void processV11(InputStream fc, boolean swapped) throws IOException {
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
        rCodeSize = readUnsignedInt(fc, 64, swapped);
        crc = readUnsignedShort(fc, HEADER_SIZE + segmentTableSize + signatureSize + 0xA4, swapped);
        md5 = bufferToHex(fc, HEADER_SIZE + segmentTableSize + (int) signatureSize + md5Offset, 16);
    }

    void processV10(InputStream fc, boolean swapped) throws IOException {
        timeStamp = readUnsignedInt(fc, 4, swapped);
        signatureSize = readUnsignedShort(fc, 8, swapped);
        int md5Offset = readUnsignedShort(fc, 10, swapped);
        segmentTableSize = readUnsignedShort(fc, 30, swapped);
        rCodeSize = readUnsignedInt(fc, 64, swapped);
        crc = readUnsignedShort(fc, HEADER_SIZE + segmentTableSize + (int) signatureSize + 0x6E,
                swapped);
        md5 = bufferToHex(fc, HEADER_SIZE + segmentTableSize + (int) signatureSize + md5Offset, 16);
    }

    void processV9(InputStream fc, boolean swapped) throws IOException {
        timeStamp = readUnsignedInt(fc, 4, swapped);
        signatureSize = readUnsignedShort(fc, 8, swapped);
        int md5Offset = readUnsignedShort(fc, 10, swapped);
        segmentTableSize = readUnsignedShort(fc, 30, swapped);
        crc = readUnsignedShort(fc, HEADER_SIZE + segmentTableSize + (int) signatureSize + 0x46,
                swapped);
        md5 = bufferToHex(fc, HEADER_SIZE + segmentTableSize + (int) signatureSize + md5Offset, 16);
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

    private static String bufferToHex(InputStream input, int startOffset, int length)
            throws IOException {
        byte[] buf = new byte[length];
        input.reset();
        input.skip(startOffset);
        input.read(buf);

        StringBuffer hexString = new StringBuffer(2 * length);
        for (int i = 0; i < length; i++) {
            hexString.append(String.format("%02X", buf[i]));
        }

        return hexString.toString();
    }

    public static class InvalidRCodeException extends Exception {
        private static final long serialVersionUID = 1L;

        public InvalidRCodeException(String s) {
            super(s);
        }
    }

    public static void main(String[] args) throws Exception {
        RCodeInfo rci = new RCodeInfo(new File("C:\\Users\\gquerret\\Downloads\\catalogue.r"));
        System.out.println("CRC : " + rci.getCRC());
        System.out.println("MD5 : " + rci.getMD5());
        System.out.println("Val : " + rci.getVersion());
        System.out.println("64 bits : " + ((rci.getVersion() & 0x4000) != 0));
        
        rci = new RCodeInfo(new File("C:\\Users\\gquerret\\Downloads\\catalogueProd.r"));
        System.out.println("CRC : " + rci.getCRC());
        System.out.println("MD5 : " + rci.getMD5());
        System.out.println("Val : " + rci.getVersion());
        System.out.println("64 bits : " + ((rci.getVersion() & 0x4000) != 0));
    }

}
