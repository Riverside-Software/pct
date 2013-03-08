package com.phenix.pct;

import java.io.IOException;
import java.io.Reader;

import org.apache.tools.ant.filters.BaseFilterReader;
import org.apache.tools.ant.filters.BaseParamFilterReader;
import org.apache.tools.ant.filters.ChainableReader;

public class DebugListingFilterReader extends BaseParamFilterReader implements ChainableReader {
    /** Data that must be read from, if not null. */
    private String queuedData = null;

    /**
     * Constructor for "dummy" instances.
     * 
     * @see BaseFilterReader#BaseFilterReader()
     */
    public DebugListingFilterReader() {
        super();
    }

    /**
     * Creates a new filtered reader.
     * 
     * @param in A Reader object providing the underlying stream. Must not be <code>null</code>.
     */
    public DebugListingFilterReader(final Reader in) {
        super(in);
    }

    /**
     * Returns the next character in the filtered stream. One line is read from the original input,
     * and the prefix added. The resulting line is then used until it ends, at which point the next
     * original line is read, etc.
     * 
     * @return the next character in the resulting stream, or -1 if the end of the resulting stream
     *         has been reached
     * 
     * @exception IOException if the underlying stream throws an IOException during reading
     */
    public int read() throws IOException {
        if (!getInitialized()) {
            setInitialized(true);
        }

        int ch = -1;

        if (queuedData != null && queuedData.length() == 0) {
            queuedData = null;
        }

        if (queuedData != null) {
            ch = queuedData.charAt(0);
            queuedData = queuedData.substring(1);
            if (queuedData.length() == 0) {
                queuedData = null;
            }
        } else {
            queuedData = readLine();
            if (queuedData == null) {
                ch = -1;
            } else {
                if (queuedData.length() > 12)
                    queuedData = queuedData.substring(12);
                else
                    queuedData = "";
                return read();
            }
        }
        return ch;
    }

    @Override
    public Reader chain(Reader rdr) {
        DebugListingFilterReader newFilter = new DebugListingFilterReader(rdr);
        newFilter.setInitialized(true);
        return newFilter;
    }

}
