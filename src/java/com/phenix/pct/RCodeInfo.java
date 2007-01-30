package com.phenix.pct;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.List;
import java.util.StringTokenizer;
import java.util.Vector;

/**
 * Gathers informations from r-code, as the RCODE-INFO system handle could provide. This class is
 * based upon procrc.c from Grant Maizels (grant AT maizels DOT nu). All credits go to his work.
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET </a>
 * @version $Revision$
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
    private final static short PROCEDURES_LIST_OFFSET = 8;
    private final static short VERSION_OFFSET = 14;
    private final static short SEGMENTS_LIST_SIZE = 30;

    // Offsets in segments location segment
    private static final short ISEGMENT_OFFSET = 0;
    private static final short ISEGMENT_SIZE = 4;
    private static final short ACTION_SEGMENT_OFFSET = 40;
    private static final short ACTION_SEGMENT_SIZE_V9 = 30;
    private static final short ACTION_SEGMENT_SIZE_V10 = 44;
    private static final short DEBUG_SEGMENT_OFFSET = 36;
    private static final short DEBUG_SEGMENT_SIZE_V9 = 40;
    private static final short DEBUG_SEGMENT_SIZE_V10 = 76;
    private static final short ECODE1_SEGMENT_OFFSET = 20;
    private static final short ECODE1_SEGMENT_SIZE_V9 = 32;
    private static final short ECODE1_SEGMENT_SIZE_V10 = 60;
    private static final short TEXT_SEGMENT_OFFSET = 90;
    private static final short TEXT_SEGMENT_SIZE = 94;

    // Offsets in initial value segment
    private final static short CRC_OFFSET_V9 = 70;
    private final static short CRC_OFFSET_V10 = 110;
    private final static short MD5_OFFSET_V10 = 240;

    private byte[] segHeader = new byte[HEADER_SIZE];
    private byte[] segProcsList;
    private byte[] segSegLocations;
    private byte[] segInitialValues;
    private byte[] segActionMain;
    // TODO Prévoir de l'espace pour les actions segments de chaque procédure
    private byte[] segECode1; //, segECode2, segECode3, segECode4;
    private byte[] segDebug;
    private byte[] segText;

    private File file;
//    private boolean error;
    private boolean swapped;
    private long magic;
    private long version;
    private long crc;
    private String md5;
    private long timeStamp;
    private List procedures;
    private List strings;

    /**
     * 
     * @param file
     * @throws Exception
     */
    public RCodeInfo(String file) throws InvalidRCodeException, IOException {
        this(new File(file));
    }

    /**
     * 
     * @param file
     * @throws Exception
     */
    public RCodeInfo(File file) throws InvalidRCodeException, IOException {
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
     * @return Timestamp
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

    /**
     * Returns strings list
     * 
     * @return List<String>
     */
    public List getStrings() {
        return this.strings;
    }

    private boolean processFile() throws InvalidRCodeException, IOException {
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
            raf.read(this.segHeader, 0, HEADER_SIZE);

            // Checks magic number
            this.magic = readUnsignedInt(this.segHeader, MAGIC_OFFSET, false);
            if (this.magic == MAGIC1) {
                this.swapped = false;
            } else if (this.magic == MAGIC2) {
                this.swapped = true;
            } else {
                raf.close();
                throw new InvalidRCodeException("Can't find magic number");
            }

            // Extract informations from header
            this.timeStamp = readUnsignedInt(this.segHeader, TS_OFFSET, this.swapped) * 1000L;
            this.version = readUnsignedInt(this.segHeader, VERSION_OFFSET, this.swapped);
            int offsetProcsList = readUnsignedShort(this.segHeader, PROCEDURES_LIST_OFFSET, this.swapped);
            long szSegLocations = readUnsignedInt(this.segHeader, SEGMENTS_LIST_SIZE, this.swapped);

            // Reads action code segment from file, and extracts informations
            this.segProcsList = new byte[offsetProcsList];
            raf.seek(HEADER_SIZE);
            raf.read(this.segProcsList, 0, offsetProcsList);
            this.procedures = processProcsList(this.segProcsList);

            // Reads segments list from file, and extracts informations
            this.segSegLocations = new byte[(int) szSegLocations];
            raf.seek(HEADER_SIZE + offsetProcsList);
            raf.read(this.segSegLocations, 0, (int) szSegLocations);

            long initialValueSegmentOffset = readUnsignedInt(this.segSegLocations, ISEGMENT_OFFSET,
                    this.swapped) + HEADER_SIZE + offsetProcsList + szSegLocations;
            long initialValueSegmentSize = readUnsignedInt(this.segSegLocations, ISEGMENT_SIZE,
                    this.swapped);
            this.segInitialValues = new byte[(int) initialValueSegmentSize];

            long actionSegmentOffset = readUnsignedInt(this.segSegLocations, ACTION_SEGMENT_OFFSET,
                    this.swapped) + HEADER_SIZE + offsetProcsList + szSegLocations;
            long actionSegmentSize =  (this.version < 1000 ? readUnsignedShort(this.segSegLocations, ACTION_SEGMENT_SIZE_V9, this.swapped) : readUnsignedInt(this.segSegLocations, ACTION_SEGMENT_SIZE_V10,
                    this.swapped));
            this.segActionMain = new byte[(int) actionSegmentSize];

            long debugSegmentOffset = readUnsignedInt(this.segSegLocations, DEBUG_SEGMENT_OFFSET,
                    this.swapped) + HEADER_SIZE + offsetProcsList + szSegLocations;
            long debugSegmentSize = readUnsignedInt(this.segSegLocations, (this.version < 1000 ? DEBUG_SEGMENT_SIZE_V9 : DEBUG_SEGMENT_SIZE_V10),
                    this.swapped);
            this.segDebug = new byte[(int) debugSegmentSize];

            long offsetECode1 = readUnsignedInt(this.segSegLocations, ECODE1_SEGMENT_OFFSET,
                    this.swapped) + HEADER_SIZE + offsetProcsList + szSegLocations;
            long szECode1 = readUnsignedInt(this.segSegLocations, (this.version < 1000 ? ECODE1_SEGMENT_SIZE_V9 : ECODE1_SEGMENT_SIZE_V10), this.swapped);
            this.segECode1 = new byte[(int) szECode1];

//            long offsetText = readUnsignedInt(this.segSegLocations, TEXT_SEGMENT_OFFSET,
//                    this.swapped) + HEADER_SIZE + offsetProcsList + szSegLocations;
//            long szText = readUnsignedInt(this.segSegLocations, TEXT_SEGMENT_SIZE, this.swapped);
//            this.segText = new byte[(int) szText];

            // Reads initial values segment
            raf.seek(initialValueSegmentOffset);
            raf.read(this.segInitialValues, 0, (int) initialValueSegmentSize);
            this.crc = readUnsignedShort(this.segInitialValues, (this.version < 1000
                    ? CRC_OFFSET_V9
                    : CRC_OFFSET_V10), swapped);
            for (int i = MD5_OFFSET_V10; i < MD5_OFFSET_V10 + 16; i++) {
                this.md5 = bufferToHex(this.segInitialValues, MD5_OFFSET_V10, 16);
            }

            // Reads debug segment
            raf.seek(debugSegmentOffset);
            raf.read(this.segDebug, 0, (int) debugSegmentSize);

            // Reads main action code segment
            raf.seek(actionSegmentOffset);
            raf.read(this.segActionMain, 0, (int) actionSegmentSize);

            // Reads ecode segment 1
            raf.seek(offsetECode1);
            raf.read(this.segECode1, 0, (int) szECode1);

            // Reads text segment
//            raf.seek(offsetText);
//            raf.read(this.segText, 0, (int) szText);
//            this.strings = processTextSegment(this.segText);

            // error = false;
            raf.close();

            return true;
        } catch (FileNotFoundException fnfe) {
            // error = true;
            throw fnfe;
        } catch (IOException ioe) {
            // error = true;
            if (raf != null)
                try {
                    raf.close();
                } catch (IOException ioe2) {
                }
            throw ioe;
        }
    }

    public static String bufferToHex(byte buffer[], int startOffset, int length) {
        StringBuffer hexString = new StringBuffer(2 * length);
        int endOffset = startOffset + length;

        for (int i = startOffset; i < endOffset; i++)
            appendHexPair(buffer[i], hexString);

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

    /**
     * Returns a list of procedures/functions entries in r-code
     * 
     * @param b Action code segment as an array of bytes
     * @return List<ActionCodeEntry>
     */
    private List processProcsList(byte[] b) {
        List procs = new Vector();
        int i = 8;
        StringBuffer codepage = new StringBuffer();
        StringBuffer procName;
        if (i >= b.length)
            return null;
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

    private List processTextSegment(byte[] b) {
        List strings = new Vector();
        int i = 4;
        StringBuffer str;
        while ((i < b.length) && (b[i] != 0)) {
            str = new StringBuffer();
            while (b[i] != 0) {
                str.append((char) b[i++]);
            }
            strings.add(str.toString());
            i++;
        }

        return strings;
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
        // RCodeInfo rci = new RCodeInfo("C:\\EclipseWS\\PCT\\testbox\\rcode\\strings1.r");
        RCodeInfo rci = new RCodeInfo("C:\\EclipseWS\\PCT\\build-v10\\pct\\pctCompile.r");
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
            return "Procedure " + this.type + " " + this.name + "(" + this.parameters
                    + ") RETURNS " + this.returnType;
        }
    }

    public class InvalidRCodeException extends Exception {
        private static final long serialVersionUID = 1L;

        public InvalidRCodeException(String s) {
            super(s);
        }
    }
}
