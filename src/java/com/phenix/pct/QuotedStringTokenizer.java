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

import java.util.StringTokenizer;

public class QuotedStringTokenizer extends StringTokenizer {
    private String quote = "\"";
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
        this.quote = quote;
    }

    @Override
    public String nextToken() {
        String nextToken = super.nextToken();
        String nextDelimiter = null;

        while ((nextToken.length() == 1) && (this.delimiters.indexOf(nextToken) >= 0)) {
            if (!super.hasMoreTokens())
                break;
            nextToken = super.nextToken();
        }

        if ((this.quote != null) && (nextToken.startsWith(this.quote))
                && (!nextToken.endsWith(this.quote))) {
            while ((super.hasMoreTokens())
                    && (!(nextDelimiter = super.nextToken()).endsWith(this.quote))) {
                nextToken = nextToken + nextDelimiter;
            }
            nextToken = nextToken + nextDelimiter;
        }

        return nextToken;
    }
}