package com.phenix.pct;

import java.util.StringTokenizer;

public class QuotedStringTokenizer extends StringTokenizer {
    private String _quote = "\"";
    private String delimiters = " \t\n\r\f";

    public QuotedStringTokenizer(String str) {
        super(str, " \t\n\r\f", true);
    }

    public QuotedStringTokenizer(String str, String delim) {
        super(str, delim, true);
        this.delimiters = delim;
    }

    public QuotedStringTokenizer(String str, String delim, String quote) {
        super(str, delim, true);
        this.delimiters = delim;
        this._quote = quote;
    }

    public String nextToken() {
        String nextToken = super.nextToken();
        String nextDelimiter = null;

        while ((nextToken.length() == 1) && (this.delimiters.indexOf(nextToken) >= 0)) {
            if (!super.hasMoreTokens())
                break;
            nextToken = super.nextToken();
        }

        if ((this._quote != null) && (nextToken.startsWith(this._quote))
                && (!nextToken.endsWith(this._quote))) {
            while ((super.hasMoreTokens())
                    && (!(nextDelimiter = super.nextToken()).endsWith(this._quote))) {
                nextToken = nextToken + nextDelimiter;
            }
            nextToken = nextToken + nextDelimiter;
        }

        return nextToken;
    }
}