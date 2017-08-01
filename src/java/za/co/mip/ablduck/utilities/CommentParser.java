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

import org.apache.tools.ant.Task;
import org.commonmark.node.Node;
import org.commonmark.parser.Parser;
import org.commonmark.renderer.html.HtmlRenderer;

import za.co.mip.ablduck.javadoc.Javadoc;

import java.io.IOException;
import java.util.Objects;
import java.util.regex.Pattern;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;

public class CommentParser {
    private String comment;
    private String source;
    private Map<String, String> nestedComments = new HashMap<>();
    private Javadoc javadocParser;
    private Pattern oldCommentDetectPattern = Pattern.compile("^\\s*?\\/\\*\\s*?-+.+$",
            Pattern.MULTILINE);
    private String oldCommentTokenPattern = "(^\\s*?[TOKEN]\\s*?:([\\s\\S]*?))(?:\\n|\\z)*(?:^\\s*?Component\\s*?:|^\\s*?Author\\s*?:|^\\s*?File\\s*?:|^\\s*?Purpose\\s*?:|^\\s*?Syntax\\s*?:|^\\s*?Description\\s*?:|^\\s*?Author\\(s\\)\\s*?:|^\\s*?Created\\s*?:|^\\s*?Notes\\s*?:|^\\s*?@param|^\\s*?@return|^\\s*?## Purpose|^\\s*?## Description|^\\s*?## Notes|\\z)";
    private Map<String, Pattern> oldCommentPatterns = new HashMap<>();
    private String[] oldCommentTokens = {"File", "Purpose", "Syntax", "Description", "Author(s)",
            "Created", "Notes", "Author", "Component"};

    public CommentParser(Task ablduck) {
        javadocParser = new Javadoc(ablduck);

        for (String token : oldCommentTokens) {
            oldCommentPatterns.put(token,
                    Pattern.compile(
                            oldCommentTokenPattern.replaceFirst(Pattern.quote("[TOKEN]"),
                                    Matcher.quoteReplacement(token.replaceFirst("\\(", "\\\\(")
                                            .replaceFirst("\\)", "\\\\)"))),
                            Pattern.MULTILINE | Pattern.CASE_INSENSITIVE));
        }
    }

    public String markdown(String comment) throws IOException {
        String markdown = "";

        Parser parser = Parser.builder().build();
        Node document = parser.parse(comment);
        HtmlRenderer renderer = HtmlRenderer.builder().build();
        markdown = renderer.render(document);

        return markdown;
    }

    public void trimCommentLines() {

        Integer start = comment.indexOf('\n');
        Integer end = comment.lastIndexOf('\n');

        if (Objects.equals(start, end)) {
            comment = "";
            return;
        }

        if (start != -1 && end != -1) {
            comment = comment.substring(start + 1, end);
        }
        Pattern commentLeadingAstrix = Pattern.compile("^\\s*\\*(?:\\s|)(\\n?|[\\s\\S]+?)",
                Pattern.MULTILINE);
        comment = commentLeadingAstrix.matcher(comment).replaceAll("$1");
    }

    public void generateLinks() {
        List<String> tags = javadocParser.parseComment(comment, source);
        Pattern linkPattern = Pattern.compile("^\\{@link ((?:\\w|\\.|-)+)\\s*(.*)\\}$",
                Pattern.DOTALL);

        String l;
        String linkText;

        for (int i = 0; i < tags.size(); i++) {
            Matcher tag = linkPattern.matcher((String) tags.get(i));

            if (tag.find()) {
                if (!"".equals(tag.group(2)))
                    linkText = tag.group(2).trim();
                else
                    linkText = tag.group(1).trim();
                l = "<a href='#!/api/" + tag.group(1).trim() + "' rel='" + tag.group(1).trim()
                        + "' class='docClass'>" + linkText + "</a>";
                comment = comment.replaceFirst(Pattern.quote(tag.group(0)),
                        Matcher.quoteReplacement(l));
            }
        }

    }

    public CommentParseResult parseComment(String com, String src) throws IOException {
        CommentParseResult commentParseResult = new CommentParseResult();
        if (com == null)
            return commentParseResult;

        comment = com;
        source = src;

        Boolean isOldComment = detectOldComments();

        // Trim the comment lines
        trimCommentLines();

        if ("".equals(comment))
            return commentParseResult;

        // Take the internal comments out for javaDoc parser
        protectInternalComments();

        // Generate links
        generateLinks();

        // Deprecated flag
        parseDeprecated(commentParseResult);

        // Internal tag
        parseInternal(commentParseResult);

        // Return tag
        parseReturn(commentParseResult);

        // Parameter tags
        parseParamComments(commentParseResult);

        if (isOldComment) {
            parseOldCommentTokens(commentParseResult);
        } else {
            // Author tag
            parseAuthor(commentParseResult);
        }

        // Put comments back in after javaDoc parser
        returnInternalComments();

        comment = markdown(comment);

        commentParseResult.setComment(comment);

        return commentParseResult;
    }

    public Boolean detectOldComments() {
        Matcher oldComment = oldCommentDetectPattern.matcher(comment);
        return oldComment.find();
    }

    public void parseOldCommentTokens(CommentParseResult commentParseResult) {
        for (String token : oldCommentTokens) {
            getOldCommentTag(token, commentParseResult);
        }
    }

    public void getOldCommentTag(String tag, CommentParseResult commentParseResult) {
        Matcher t = oldCommentPatterns.get(tag).matcher(comment);

        if (t.find()) {
            String match = t.group(2).trim();
            match = match.replaceAll("(?m)^\\s*", "");

            if ("".equals(match)) {
                comment = comment.replaceFirst(Pattern.quote(t.group(1)), "");
            } else {
                switch (tag) {
                    case "Purpose" :
                        comment = comment.replaceFirst(Pattern.quote(t.group(1)),
                                Matcher.quoteReplacement("## Purpose\n" + match));
                        break;
                    case "Notes" :
                        comment = comment.replaceFirst(Pattern.quote(t.group(1)),
                                Matcher.quoteReplacement("## Notes\n" + match));
                        break;
                    case "Description" :
                        comment = comment.replaceFirst(Pattern.quote(t.group(1)),
                                Matcher.quoteReplacement("## Description\n" + match));
                        break;
                    case "Author(s)" :
                    case "Author" :
                        comment = comment.replaceFirst(Pattern.quote(t.group(1)), "");
                        commentParseResult.setAuthor(match);
                        break;
                    default :
                        comment = comment.replaceFirst(Pattern.quote(t.group(1)), "");
                        break;
                }
            }
        }
    }

    public void parseReturn(CommentParseResult commentParseResult) {
        commentParseResult
                .setReturnComment(getValueTag(Pattern.compile("@return\\s+(.*)", Pattern.DOTALL)));
    }

    public void parseAuthor(CommentParseResult commentParseResult) {
        commentParseResult
                .setAuthor(getValueTag(Pattern.compile("@author\\s+(.*)", Pattern.DOTALL)));
    }

    public void parseInternal(CommentParseResult commentParseResult) {
        commentParseResult.setInternal(getBooleanTag(Pattern.compile("@internal")));
    }

    public void parseDeprecated(CommentParseResult commentParseResult) throws IOException {
        Map<String, String> deprecated = getKeyValueTags(
                Pattern.compile("@deprecated\\s+(.+?)\\s+(.*)", Pattern.DOTALL));

        if (deprecated.size() > 0) {
            commentParseResult.setDeprecatedVersion(deprecated.keySet().iterator().next());
            commentParseResult
                    .setDeprecatedText(deprecated.get(commentParseResult.getDeprecatedVersion()));
        }
    }

    public void parseParamComments(CommentParseResult commentParseResult) throws IOException {
        commentParseResult.setParameterComment(
                getKeyValueTags(Pattern.compile("@param\\s+(.+?)\\s+(.*)", Pattern.DOTALL)));
    }

    public void protectInternalComments() {
        Pattern simpleComment = Pattern.compile("(\\/\\*.*\\*\\/)", Pattern.DOTALL);
        Matcher m = simpleComment.matcher(comment);
        Integer commentCount = 0;
        while (m.find()) {
            String commentTag = "[comment-" + commentCount.toString() + "]";
            nestedComments.put(commentTag, m.group(1));
            comment = comment.replaceFirst(Pattern.quote(m.group(1)),
                    Matcher.quoteReplacement(commentTag));
            commentCount++;
        }
    }

    public void returnInternalComments() {
        for (Map.Entry<String, String> c : nestedComments.entrySet()) {
            comment = comment.replaceFirst(Pattern.quote(c.getKey()),
                    Matcher.quoteReplacement(c.getValue()));
        }
    }

    public Map<String, String> getKeyValueTags(Pattern paramRegex) throws IOException {
        Map<String, String> keyvaluetag = new HashMap<>();

        List<String> tags = javadocParser.parseComment(comment, source);

        for (int i = 0; i < tags.size(); i++) {
            Matcher tag = paramRegex.matcher((String) tags.get(i));
            if (tag.find()) {
                keyvaluetag.put(tag.group(1), markdown(removeLeadingWhitespace(tag.group(2))));

                comment = comment.replaceFirst(Pattern.quote((String) tags.get(i)), "");
            }
        }

        comment = comment.trim();
        return keyvaluetag;
    }

    public String getValueTag(Pattern paramRegex) {
        String value = "";

        List<String> tags = javadocParser.parseComment(comment, source);

        for (int i = 0; i < tags.size(); i++) {
            Matcher tag = paramRegex.matcher((String) tags.get(i));
            if (tag.find()) {
                value = tag.group(1);

                comment = comment.replaceFirst(Pattern.quote((String) tags.get(i)), "");
            }
        }

        comment = comment.trim();
        return value;
    }

    public Boolean getBooleanTag(Pattern paramRegex) {
        Boolean flag = false;

        List<String> tags = javadocParser.parseComment(comment, source);

        for (int i = 0; i < tags.size(); i++) {
            Matcher tag = paramRegex.matcher((String) tags.get(i));
            if (tag.find()) {
                flag = true;

                comment = comment.replaceFirst(Pattern.quote((String) tags.get(i)), "");
            }
        }

        comment = comment.trim();
        return flag;
    }

    public String removeLeadingWhitespace(String text) {
        Pattern whitespace = Pattern.compile("\\n\\s+");

        String trimmed = whitespace.matcher(text).replaceAll("\n");

        return trimmed.trim();
    }
}
