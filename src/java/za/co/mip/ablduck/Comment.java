/**
 * Copyright 2017-2019 MIP Holdings
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
package za.co.mip.ablduck;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.commonmark.node.Node;
import org.commonmark.parser.Parser;
import org.commonmark.renderer.html.HtmlRenderer;

import za.co.mip.ablduck.models.Deprecated;

public class Comment {
    private static final String NEWLINE_SEPARATOR = System.getProperty("line.separator");

    private String comment = "";
    private String author = "";
    private String returns = "";
    private Boolean isInternal = null;
    private Deprecated deprecated = null;
    private Map<String, String> parameters = new HashMap<>();

    public String getComment() {
        return markdown(comment);
    }

    public String getAuthor() {
        return author;
    }

    public String getReturn() {
        return returns;
    }

    public Boolean isInternal() {
        return isInternal;
    }

    public Deprecated getDeprecated() {
        return deprecated;
    }

    public Map<String, String> getParameters() {
        return parameters;
    }

    public void parseComment(String comment) {
        if (comment == null || "".equals(comment))
            return;

        if (comment.startsWith("/**") && comment.split("\n")[0].indexOf('-') == -1) {
            parseJavadocComment(comment);
        } else {
            parseABLDocComment(comment);
        }
    }

    private void parseABLDocComment(String comment) {
        String[] commentLines = comment.split(NEWLINE_SEPARATOR);

        String tagType = null;
        String tagText = null;
        List<Tag> resolvedTags = new ArrayList<>();

        // Assuming the first and last lines are /* */
        for (int i = 1; i < commentLines.length - 1; i++) {

            String commentLine = ltrim(commentLines[i]) + '\n'; // Put this back as we split on it

            // Assuming a line that starts with an @xxx is a token
            if (commentLine.startsWith("@") && !" ".equals(commentLine.substring(1, 2))) {

                // Store previous tag if we had one
                if (tagType != null)
                    resolvedTags.add(new Tag(tagType, tagText));

                Integer nextSpace = commentLine.indexOf(' ');

                if (nextSpace != -1) {
                    tagType = commentLine.substring(1, nextSpace);
                    tagText = ltrim(commentLine.substring(nextSpace));
                } else {
                    tagType = commentLine.substring(1);
                    tagText = "";
                }

                continue;
            }

            Integer colonPosition = commentLine.indexOf(':');

            // Potential Token in the form Token : xxxx
            if (colonPosition != -1) {
                String token = commentLine.substring(0, colonPosition).trim();

                // If there is no space in the token name, its a token.
                if (token.indexOf(' ') == -1) {

                    // Store previous tag if we had one
                    if (tagType != null)
                        resolvedTags.add(new Tag(tagType, tagText));

                    tagType = token;
                    tagText = ltrim(commentLine.substring(colonPosition + 1));

                    continue;
                }
            }
            tagText += " " + commentLine;

        }

        // Store previous tag if we had one
        if (tagType != null)
            resolvedTags.add(new Tag(tagType, tagText));

        for (Tag tag : resolvedTags) {
            switch (tag.getType().toLowerCase().trim()) {
                case "param" :
                    int nextSpace = tag.getText().indexOf(' ');
                    if (nextSpace == -1)
                        parameters.put(tag.getText(), "");
                    else
                        parameters.put(tag.getText().substring(0, nextSpace),
                                tag.getText().substring(nextSpace + 1));
                    break;
                case "return" :
                    this.returns = tag.getText();
                    break;
                case "author" :
                case "author(s)" :
                    this.author = tag.getText();
                    break;
                default :
                    if (!"".equals(tag.getText()))
                        this.comment += "### " + tag.getType() + ":\n" + tag.getText() + "\n";
                    break;
            }
        }
    }

    private void parseJavadocComment(String comment) {
        String[] commentLines = comment.split(NEWLINE_SEPARATOR);

        String tagType = null;
        String tagText = null;
        List<Tag> resolvedTags = new ArrayList<>();

        // Assuming the first and last lines are /** */
        for (int i = 1; i < commentLines.length - 1; i++) {

            // Lets get the line and trim off the leading *
            String commentLine = commentLines[i] + '\n'; // Put this back as we split on it
            commentLine = commentLine.substring(commentLine.indexOf('*') + 1);

            // There might be a space after the *, or not
            if (commentLine.length() > 0 && " ".equals(commentLine.substring(0, 1)))
                commentLine = commentLine.substring(1);

            // Assuming a line that starts with an @xxx is a token
            if (commentLine.startsWith("@") && !" ".equals(commentLine.substring(1, 2))) {

                // Store previous tag if we had one
                if (tagType != null)
                    resolvedTags.add(new Tag(tagType, tagText));

                Integer nextSpace = commentLine.indexOf(' ');

                if (nextSpace != -1) {
                    tagType = commentLine.substring(1, nextSpace);
                    tagText = ltrim(commentLine.substring(nextSpace));
                } else {
                    tagType = commentLine.substring(1);
                    tagText = "";
                }

                continue;
            }

            if (tagType != null)
                tagText += " " + commentLine;
            else
                this.comment += commentLine;

        }

        // Store previous tag if we had one
        if (tagType != null)
            resolvedTags.add(new Tag(tagType, tagText));

        int nextSpace;
        for (Tag tag : resolvedTags) {
            switch (tag.getType().trim()) {
                case "param" :
                    nextSpace = tag.getText().indexOf(' ');
                    if (nextSpace == -1)
                        parameters.put(tag.getText(), "");
                    else
                        parameters.put(tag.getText().substring(0, nextSpace),
                                tag.getText().substring(nextSpace + 1));
                    break;
                case "deprecated" :
                    nextSpace = tag.getText().indexOf(' ');
                    if (nextSpace == -1)
                        deprecated = new Deprecated(tag.getText(), "");
                    else
                        deprecated = new Deprecated(tag.getText().substring(0, nextSpace),
                                tag.getText().substring(nextSpace + 1));
                    break;
                case "return" :
                    this.returns = tag.getText();
                    break;
                case "author" :
                    this.author = tag.getText();
                    break;
                case "internal" :
                    this.isInternal = true;
                    break;
            }
        }
    }

    private String ltrim(String s) {
        int i = 0;
        while (i < s.length() && Character.isWhitespace(s.charAt(i))) {
            i++;
        }
        return s.substring(i);
    }

    public String markdown(String comment) {
        String markdown = "";

        Parser parser = Parser.builder().build();
        Node document = parser.parse(comment);
        HtmlRenderer renderer = HtmlRenderer.builder().build();
        markdown = renderer.render(document);

        return markdown;
    }

    private class Tag {
        private String type;
        private String text;

        public Tag(String type, String text) {
            this.type = type;
            this.text = text;
        }

        public String getType() {
            return this.type;
        }

        public String getText() {
            return this.text;
        }
    }
}
