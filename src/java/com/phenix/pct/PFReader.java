package com.phenix.pct;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public class PFReader {
    private String cpInternal, cpStream;

    public PFReader(InputStream stream) throws IOException {
        readPFStream(stream);
    }

    public String getCpInternal() {
        return cpInternal;
    }

    public String getCpStream() {
        return cpStream;
    }

    private void readPFStream(InputStream stream) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(stream));

        String line = reader.readLine();
        while (line != null) {
            int end = line.indexOf("#");
            if (end > -1) {
                line = line.substring(0, end);
            }
            if (line.length() > 0) {
                parseLine(line);
            }

            line = reader.readLine();
        }
    }

    private void parseLine(String line) {
        QuotedStringTokenizer tokenizer = new QuotedStringTokenizer(line);

        while (tokenizer.hasMoreElements()) {
            String token = tokenizer.nextToken();
            if ("-cpinternal".equals(token)) {
                cpInternal = tokenizer.nextToken();
                cpInternal = stripQuotes(cpInternal);
            } else if ("-cpstream".equals(token)) {
                cpStream = tokenizer.nextToken();
                cpStream = stripQuotes(cpStream);
            }
        }
    }

    private String stripQuotes(String quotedString) {
        String s = quotedString;
        if ((s.startsWith("\"")) && (s.endsWith("\"")) && (s.length() > 1)) {
            s = quotedString.substring(1, s.length() - 1);
        }
        if ((s.startsWith("'")) && (s.endsWith("'")) && (s.length() > 1)) {
            s = quotedString.substring(1, s.length() - 1);
        }

        return s;
    }
}
