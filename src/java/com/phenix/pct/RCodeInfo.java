package com.phenix.pct;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.lang.reflect.Array;
import java.nio.charset.CharsetDecoder;
import java.util.Arrays;
import java.util.List;
import java.util.StringTokenizer;
import java.util.Vector;

/**
 * Gathers informations from r-code, as the RCODE-INFO system handle could provide. This class is
 * based upon procrc.c from Grant Maizels (grant AT maizels DOT nu). All credits go to his work.
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET </a>
 * @since PCT 0.11
 */
public class RCodeInfo {
    // Magic numbers
    private final static int MAGIC1 = 0x56CED309;
    private final static int MAGIC2 = 0x09D3CE56; // Bytes swapped

    private final static short HEADER_SIZE = 68;

    // Offsets in header
    private final static short MAGIC_OFFSET = 0;
    private final static short TS_OFFSET = 4;
    private final static short ACTION_SEGMENT_OFFSET = 8;
    private final static short VERSION_OFFSET = 14;
    private final static short SEGMENT_SIZE_OFFSET = 30;

    // Offsets in segments list
    private final static short ISEGMENT_OFFSET = 0;
    // private final static short DEBUG_SEGMENT_OFFSET = 24;

    // Offsets in initial value segment
    private final static short CRC_OFFSET_V9 = 70;
    private final static short CRC_OFFSET_V10 = 110;
    private final static short MD5_OFFSET_V10 = 240;

    private byte[] header = new byte[HEADER_SIZE];
    private byte[] actionCodeSegment;
    private byte[] segmentsList;
    private byte[] initialValueSegment;
    private byte[] actionSegment;
    private byte[] ECodeSegment;
    private byte[] debugSegment;

    private File file;
    private boolean error;
    private boolean swapped;
    private long magic;
    private long version;
    private long crc;
    private String md5;
    private long timeStamp;
    private List procedures;

    /**
     * 
     * @param file
     * @throws Exception
     */
    public RCodeInfo(String file) throws InvalidRCodeException, FileNotFoundException {
        this(new File(file));
    }

    /**
     * 
     * @param file
     * @throws Exception
     */
    public RCodeInfo(File file) throws InvalidRCodeException, FileNotFoundException {
        this.file = file;
        processFile();
    }

    /**
     * Returns r-code CRC
     * 
     * @return CRC
     */
    public long getCRC() {
        return this.crc;
    }

    /**
     * Returns r-code compiler version
     * 
     * @return Version
     */
    public long getVersion() {
        return this.version;
    }

    /**
     * Returns r-code timestamp (in milliseconds)
     * 
     * @return
     */
    public long getTimeStamp() {
        return this.timeStamp;
    }

    public String getMD5() {
        return this.md5;
    }

    /**
     * Returns procedures list
     * 
     * @return List<ActionCodeEntry>
     */
    public List getProcedures() {
        return this.procedures;
    }

    private boolean processFile() throws InvalidRCodeException, FileNotFoundException {
        RandomAccessFile raf = null;
        try {
            raf = new RandomAccessFile(this.file, "r");

            // Checks file is long enough to hold header
            if (raf.length() < HEADER_SIZE) {
                raf.close();
                throw new InvalidRCodeException("File size is less than header size");
            }

            // Reads header
            raf.seek(0);
            raf.read(this.header, 0, HEADER_SIZE);

            // Checks magic number
            this.magic = readUnsignedInt(this.header, MAGIC_OFFSET, false);
            if (this.magic == MAGIC1) {
                this.swapped = false;
            } else if (this.magic == MAGIC2) {
                this.swapped = true;
            } else {
                raf.close();
                throw new InvalidRCodeException("Can't find magic number");
            }

            // Extract informations from header
            this.timeStamp = readUnsignedInt(this.header, TS_OFFSET, this.swapped) * 1000L;
            this.version = readUnsignedInt(this.header, VERSION_OFFSET, this.swapped);
            int actionCodeSegmentSize = readUnsignedShort(this.header, ACTION_SEGMENT_OFFSET,
                    this.swapped);
            long segmentsListSize = readUnsignedInt(this.header, SEGMENT_SIZE_OFFSET, this.swapped);

            // Reads action code segment from file, and extracts informations
            this.actionCodeSegment = new byte[actionCodeSegmentSize];
            raf.seek(HEADER_SIZE);
            raf.read(this.actionCodeSegment, 0, actionCodeSegmentSize);
            this.procedures = processActionCodeSegment(this.actionCodeSegment);

            // Reads segments list from file, and extracts informations
            this.segmentsList = new byte[(int) segmentsListSize];
            raf.seek(HEADER_SIZE + actionCodeSegmentSize);
            raf.read(this.segmentsList, 0, (int) segmentsListSize);
            long initialValueSegmentOffset = readUnsignedInt(this.segmentsList, 0, this.swapped);
            long initialValueSegmentSize = readUnsignedInt(this.segmentsList, 4, this.swapped);
            this.initialValueSegment = new byte[(int) initialValueSegmentSize];
            
            long actionSegmentOffset = readUnsignedInt(this.segmentsList, 40, this.swapped);
            long actionSegmentSize = readUnsignedInt(this.segmentsList, 44, this.swapped);
            this.actionSegment = new byte[(int) actionSegmentSize];
            
            long debugSegmentOffset = readUnsignedInt(this.segmentsList, 36, this.swapped);
            long debugSegmentSize = readUnsignedInt(this.segmentsList, 76, this.swapped);
            this.debugSegment = new byte[(int) debugSegmentSize];
            // processSegmentsList(this.segmentsList);

            // Reads initial values segment
            raf.seek(HEADER_SIZE + actionCodeSegmentSize + segmentsListSize + initialValueSegmentOffset);
            raf.read(this.initialValueSegment, 0, (int) initialValueSegmentSize);
            this.crc = readUnsignedShort(this.initialValueSegment, (this.version < 1000
                    ? CRC_OFFSET_V9
                    : CRC_OFFSET_V10), swapped);
            for (int i = MD5_OFFSET_V10; i < MD5_OFFSET_V10 + 16; i++) {
                this.md5 = bufferToHex(this.initialValueSegment, MD5_OFFSET_V10, 16);
            }
            
            // Reads debug segment
            raf.seek(HEADER_SIZE + actionCodeSegmentSize + segmentsListSize + debugSegmentOffset);
            raf.read(this.debugSegment, 0, (int) debugSegmentSize);
            
            // Reads action segment
            raf.seek(HEADER_SIZE + actionCodeSegmentSize + segmentsListSize + actionSegmentOffset);
            raf.read(this.actionSegment, 0, (int) actionSegmentSize);
            
            // long segmentsListOffset = actionSegmentSize + HEADER_SIZE;
            // long iSegmentOffset = readUnsignedInt(raf, segmentsListOffset + ISEGMENT_OFFSET,
            // this.swapped);
            // long debugSegmentOffset = readUnsignedInt(raf, segmentsListOffset +
            // DEBUG_SEGMENT_OFFSET, this.swapped);

            // this.crc = readUnsignedShort(raf, segmentsListOffset + iSegmentOffset + segmentSize +
            // (this.version < 1000 ? CRC_OFFSET_V9 : CRC_OFFSET_V10), this.swapped);
            error = false;
            raf.close();

            return true;
        } catch (FileNotFoundException fnfe) {
            error = true;
            throw fnfe;
        } catch (IOException ioe) {
            error = true;
            if (raf != null)
                try {
                    raf.close();
                } catch (IOException ioe2) {
                }
            return false;
        }
    }

    /**
     * @see http://www.bombaydigital.com/arenared/2004/2/12/1
     */
    public static String bufferToHex(byte buffer[], int startOffset, int length) {
        StringBuffer hexString = new StringBuffer(2 * length);
        int endOffset = startOffset + length;

        for (int i = startOffset; i < endOffset; i++)
            appendHexPair(buffer[i], hexString);

        return hexString.toString();
    }
    /**
     * @see http://www.bombaydigital.com/arenared/2004/2/12/1
     */
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
    
    /**
     * Returns a list of procedures/functions entries in r-code
     * 
     * @param b Action code segment as an array of bytes
     * @return List<ActionCodeEntry>
     */
    private List processActionCodeSegment(byte[] b) {
        List procs = new Vector();
        int i = 8;
        StringBuffer codepage = new StringBuffer();
        StringBuffer procName;
        while (b[i] != 0) {
            codepage.append((char) b[i++]);
        }
        i++;

        while ((i < b.length) && (b[i] != 0)) {
            procName = new StringBuffer();
            while (b[i] != 0) {
                procName.append((char) b[i++]);
            }
            procs.add(new ActionCodeEntry(procName.toString()));
            i++;
        }

        return procs;
    }

    private void processSegmentsList(byte[] b) {

    }

    private static int readUnsignedShort(byte[] b, int pos, boolean swapped) {
        if (swapped)
            return (((int) b[pos + 1] & 0xFF) << 8) + ((int) b[pos] & 0xFF);
        else
            return (((int) b[pos] & 0xFF) << 8) + ((int) b[pos + 1] & 0xFF);
    }

    private static long readUnsignedInt(byte[] b, int pos, boolean swapped) {
        if (swapped)
            return (((long) b[pos + 3] & 0xFF) << 24) + (((long) b[pos + 2] & 0xFF) << 16)
                    + (((long) b[pos + 1] & 0xFF) << 8) + ((long) b[pos] & 0xFF);
        else
            return (((long) b[pos] & 0xFF) << 24) + (((long) b[pos + 1] & 0xFF) << 16)
                    + (((long) b[pos + 2] & 0xFF) << 8) + ((long) b[pos + 3] & 0xFF);
    }

    public static void main(String[] args) throws Exception {
        RCodeInfo rci = new RCodeInfo("C:\\Eclipse\\HachetteL4G\\build\\ngapi\\getFolders.r");
        System.out.println("CRC : " + rci.getCRC());
        System.out.println("MD5 : " + rci.getMD5());
    }

    private class ActionCodeEntry {
        public static final int INPUT = 1;
        public static final int OUTPUT = 2;
        public static final int INPUT_OUTPUT = 3;

        private String type;
        private String name;
        private String returnType;
        private String parameters;

        public ActionCodeEntry(String s) {
            if (s.equals(""))
                return;
            StringTokenizer parser = new StringTokenizer(s, ",");

            StringBuffer tmp = new StringBuffer();
            String part1 = parser.nextToken();
            if (parser.hasMoreTokens()) {
                this.returnType = parser.nextToken();
                if (parser.hasMoreTokens()) {
                    this.parameters = parser.nextToken();
                } else {
                    this.parameters = "";
                }
            } else {
                this.returnType = "";
                this.parameters = "";
            }

            int i = 0;
            while (part1.charAt(i) != ' ') {
                tmp.append(part1.charAt(i++));
            }
            this.type = tmp.toString();
            i++;
            tmp = new StringBuffer();
            this.name = part1.substring(i);
        }

        public String toString() {
            return "Procedure " + this.name + "(" + this.parameters + ") RETURNS "
                    + this.returnType;
        }
    }

    public class InvalidRCodeException extends Exception {
        private static final long serialVersionUID = 1L;

        public InvalidRCodeException(String s) {
            super(s);
        }
    }
}
