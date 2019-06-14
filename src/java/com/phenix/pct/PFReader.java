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

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;

public class PFReader {
    private String cpInternal;
    private String cpStream;

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
        try (Reader r = new InputStreamReader(stream);
                BufferedReader reader = new BufferedReader(r)) {
            String line = reader.readLine();
            while (line != null) {
                int end = line.indexOf('#');
                if (end > -1) {
                    line = line.substring(0, end);
                }
                if (line.length() > 0) {
                    parseLine(line);
                }

                line = reader.readLine();
            }
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
