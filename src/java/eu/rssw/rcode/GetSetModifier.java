/**
 * Copyright 2011-2016 Riverside Software
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
package eu.rssw.rcode;

import com.openedge.pdt.core.ast.ProgressParserTokenTypes;

public enum GetSetModifier {
    NONE, PUBLIC, PROTECTED, PRIVATE;

    public static GetSetModifier from(int value) {
        if (value == ProgressParserTokenTypes.PRIVATE)
            return PRIVATE;
        else if ((value == ProgressParserTokenTypes.PUBLIC) || (value == -1) /* No modifier */)
            return PUBLIC;
        else if (value == ProgressParserTokenTypes.PROTECTED)
            return PROTECTED;
        return null;
    }

}
