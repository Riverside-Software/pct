package com.phenix.pct;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.RandomAccessFile;

/**
 * Gathers informations from r-code, as the RCODE-INFO system handle could provide. This class is
 * based upon procrc.c from Grant Maizels (grant AT maizels DOT nu). All credits go to his work.
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET </a>
 * @since PCT 0.11
 */
public class RCodeInfo {
    private final static int MAGIC1 = 0x56CED309;
    private final static int MAGIC2 = 0x09D3CE56; // Bytes wrapped
    
    private final static short HEADER_SIZE = 68;

    private final static short MAGIC_OFFSET = 0;
    private final static short TS_OFFSET = 4;
    private final static short HEADER1_OFFSET = 8;
    private final static short VERSION_OFFSET = 14;
    private final static short SEGMENT_SIZE_OFFSET = 30;

    private final static short ISEGMENT_OFFSET = 0;
    // private final static short DEBUG_SEGMENT_OFFSET = 24;

    private final static short CRC_OFFSET = 70;
    private File file;
    private boolean swapped;
    private long magic;
    
    private long version;
    private long crc;
    private long timeStamp;
    
    public RCodeInfo(String file) throws Exception {
        this(new File(file));
    }

    public RCodeInfo(File file) throws Exception{
        this.file = file;
        if (!processFile()) throw new Exception("Unable to parse file"); 
    }

    public long getCRC() {
        return this.crc;
    }
    
    public long getVersion() {
        return this.version;
    }
    
    public long getTimeStamp() {
        return this.timeStamp;
    }
    
    private boolean processFile() {
        RandomAccessFile raf = null;
        try {
            raf = new RandomAccessFile(this.file, "r");
            this.magic = readUnsignedInt(raf, MAGIC_OFFSET, false);
            if (this.magic == MAGIC1) {
                this.swapped = false;
            } else if (this.magic == MAGIC2) {
                this.swapped = true;
            } else {
                raf.close();
                return false;
            }
            
            this.timeStamp = readUnsignedInt(raf, TS_OFFSET, this.swapped);
            this.version = readUnsignedInt(raf, VERSION_OFFSET, this.swapped);
            
            int header1Size = readUnsignedShort(raf, HEADER1_OFFSET, this.swapped);
            long segmentSize = readUnsignedInt(raf, SEGMENT_SIZE_OFFSET, this.swapped);
            long segmentsListOffset = header1Size + HEADER_SIZE;
            long iSegmentOffset = readUnsignedInt(raf, segmentsListOffset + ISEGMENT_OFFSET, this.swapped);
            // long debugSegmentOffset = readUnsignedInt(raf, segmentsListOffset + DEBUG_SEGMENT_OFFSET, this.swapped);
            
            this.crc = readUnsignedShort(raf, segmentsListOffset + iSegmentOffset + segmentSize + CRC_OFFSET, this.swapped);
            
            raf.close();
            return true;
        } catch (FileNotFoundException fnfe) {
            return false;
        } catch (IOException ioe) {
            if (raf != null) try { raf.close(); } catch (IOException ioe2) { }
            return false;
        }
    }

    private static int readUnsignedShort(RandomAccessFile raf, long pos, boolean swapped)
            throws IOException {
        raf.seek(pos);
        int ch1 = raf.readUnsignedByte();
        int ch2 = raf.readUnsignedByte();
        if (swapped)
            return (ch2 << 8) + ch1;
        else
            return (ch1 << 8) + ch2;
    }

    private static long readUnsignedInt(RandomAccessFile raf, long pos, boolean swapped)
            throws IOException {
        raf.seek(pos);
        int ch1 = raf.readUnsignedByte();
        int ch2 = raf.readUnsignedByte();
        int ch3 = raf.readUnsignedByte();
        int ch4 = raf.readUnsignedByte();
        if (swapped)
            return (long) (ch4 << 24) + (long) (ch3 << 16) + (long) (ch2 << 8) + (long) ch1;
        else
            return (long) (ch1 << 24) + (long) (ch2 << 16) + (long) (ch3 << 8) + (long) ch4;
    }

    public static void main(String[] args) throws Exception {
        RCodeInfo rci = new RCodeInfo("C:\\Eclipse\\CodexiaDlc\\build\\smt\\dAppliGed.r");
        System.out.println("CRC : " + rci.getCRC());
    }
}
