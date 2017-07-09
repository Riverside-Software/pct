/**
 * Copyright 2017 MIP Holdings
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
package za.co.mip.ablduck.utilities;
import java.util.HashMap;
import java.util.Map;

public class CommentParseResult {
    // Remaining formatted comment
    private String comment = "";

    // Deprecated version and note from @deprecated
    private String deprecatedVersion = "";
    private String deprecatedText = "";

    // Parameter comments from @param tags
    private Map<String, String> parameterComments = new HashMap<>();

    // Internal flag from @internal
    private Boolean internal = false;

    // Return comment
    private String returnComment = "";

    // Author tag
    private String author = "";

    public String getComment() {
        return this.comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public String getDeprecatedVersion() {
        return this.deprecatedVersion;
    }

    public void setDeprecatedVersion(String depVer) {
        this.deprecatedVersion = depVer;
    }

    public String getDeprecatedText() {
        return this.deprecatedText;
    }

    public void setDeprecatedText(String depText) {
        this.deprecatedText = depText;
    }

    public Map<String, String> getParameterComments() {
        return this.parameterComments;
    }

    public void setParameterComment(Map<String, String> params) {
        this.parameterComments = params;
    }

    public Boolean getInternal() {
        return this.internal;
    }

    public void setInternal(Boolean internal) {
        this.internal = internal;
    }

    public String getReturnComment() {
        return this.returnComment;
    }

    public void setReturnComment(String comment) {
        this.returnComment = comment;
    }

    public String getAuthor() {
        return this.author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }
}
