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
package za.co.mip.ablduck;

import org.markdown4j.Markdown4jProcessor;
import java.io.IOException;
import java.util.Objects;
import java.util.regex.Pattern;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javadoc.*;

public class CommentParser {
    private static String comment;
    private static CommentParseResult commentParseResult;
    private static HashMap<String, String> nestedComments = new HashMap<String, String>();
    
    public static String markdown(String comment){
        String markdown = "";
        try {
            Markdown4jProcessor processor = new Markdown4jProcessor();
            markdown = processor.process(comment);
        } catch (IOException ex) {
            System.out.println (ex.toString());
        }
        return markdown;
    }
    
    public static void trimCommentLines(){
        
        Integer start = comment.indexOf("\n");
        Integer end   = comment.lastIndexOf("\n");
        
        if (Objects.equals(start, end)) {
            comment = "";
            return;
        }
            
        if (start != -1 && end != -1) {
            comment = comment.substring(start + 1, end - 1);
        }
        Pattern commentLeadingAstrix = Pattern.compile("^\\s*\\*\\s", Pattern.MULTILINE);
        comment = commentLeadingAstrix.matcher(comment).replaceAll("");
    }
    
    public static void generateLinks(){
        ArrayList tags = Javadoc.parseComment(comment);
        Pattern linkPattern = Pattern.compile("^\\{@link ((?:\\w|\\.|-)+)\\s*(.*)\\}$", Pattern.DOTALL);
        
        String l;
        String linkText;
        
        for (int i = 0; i < tags.size(); i++) {
            Matcher tag = linkPattern.matcher((String)tags.get(i));
            
            if(tag.find()) {
                if (!tag.group(2).equals(""))
                    linkText = tag.group(2).trim();
                else
                    linkText = tag.group(1).trim();
                l = "<a href='#!/api/" + tag.group(1).trim() + "' rel='" + tag.group(1).trim() + "' class='docClass'>" + linkText + "</a>";
                comment = comment.replaceFirst(Pattern.quote(tag.group(0)), Matcher.quoteReplacement(l));
            }
        }
        
    }
    
    public static CommentParseResult parseComment(String com){
        CommentParseResult commentParseResult = new CommentParseResult();
        if (com == null)
            return commentParseResult;
        
        comment = com;
        
        // Trim the comment lines
        trimCommentLines();
        
        if(comment.equals(""))
            return commentParseResult;
        
        //Take the internal comments out for javaDoc parser
        protectInternalComments();
        
        //Generate links
        generateLinks();
        
        //Deprecated flag
        parseDeprecated(commentParseResult);
        
        //Internal tag
        parseInternal(commentParseResult);
        
        //Return tag
        parseReturn(commentParseResult);
        
        //Parameter tags
        parseParamComments(commentParseResult);
        
        //Internal tag
        parseAuthor(commentParseResult);
        
        //Put comments back in after javaDoc parser
        returnInternalComments();
        
        comment = markdown(comment);
        
        commentParseResult.comment = comment;
        
        return commentParseResult;
    }
    
    public static void parseReturn(CommentParseResult commentParseResult){
        commentParseResult.returnComment = getValueTag(Pattern.compile("@return\\s+(.*)", Pattern.DOTALL));
    }
    
    public static void parseAuthor(CommentParseResult commentParseResult){
        commentParseResult.author = getValueTag(Pattern.compile("@author\\s+(.*)", Pattern.DOTALL));
    }
    
    public static void parseInternal(CommentParseResult commentParseResult){
        commentParseResult.internal = getBooleanTag(Pattern.compile("@internal"));
    }
    
    public static void parseDeprecated(CommentParseResult commentParseResult){
        HashMap<String, String> deprecated = getKeyValueTags(Pattern.compile("@deprecated\\s+(.+?)\\s+(.*)", Pattern.DOTALL));
        
        if (deprecated.size() > 0) {
            commentParseResult.deprecatedVersion = deprecated.keySet().iterator().next();
            commentParseResult.deprecatedText = deprecated.get(commentParseResult.deprecatedVersion);
        }
    }
    
    public static void parseParamComments(CommentParseResult commentParseResult){
        commentParseResult.parameterComments = getKeyValueTags(Pattern.compile("@param\\s+(.+?)\\s+(.*)", Pattern.DOTALL));
    }
    
    public static void protectInternalComments(){
        Pattern simpleComment = Pattern.compile("(\\/\\*.*\\*\\/)", Pattern.DOTALL);
        Matcher m = simpleComment.matcher(comment);
        Integer commentCount = 0;
        while (m.find()) {
            String commentTag = "[comment-" + commentCount.toString() + "]";
            nestedComments.put(commentTag, m.group(1));
            comment = comment.replaceFirst(Pattern.quote(m.group(1)), Matcher.quoteReplacement(commentTag));
            commentCount++;
        }
    }
    
    public static void returnInternalComments(){
        for (Map.Entry c:nestedComments.entrySet()) {
            comment = comment.replaceFirst(Pattern.quote((String)c.getKey()), Matcher.quoteReplacement((String)c.getValue()));
        }
    }
    
    public static HashMap<String, String> getKeyValueTags(Pattern paramRegex){
        HashMap<String, String> keyvaluetag = new HashMap<String, String>();
        
        ArrayList tags = Javadoc.parseComment(comment);
        
        for (int i = 0; i < tags.size(); i++) {
            Matcher tag = paramRegex.matcher((String)tags.get(i));
            if(tag.find()) {
                keyvaluetag.put(tag.group(1), markdown(removeLeadingWhitespace(tag.group(2))));
              
                comment = comment.replaceFirst(Pattern.quote((String)tags.get(i)), "");
            }
        }

        comment = comment.trim();
        return keyvaluetag;
    }
    
    public static String getValueTag(Pattern paramRegex){
        String value = "";
        
        ArrayList tags = Javadoc.parseComment(comment);
        
        for (int i = 0; i < tags.size(); i++) {
            Matcher tag = paramRegex.matcher((String)tags.get(i));
            if(tag.find()) {
                value = tag.group(1);
              
                comment = comment.replaceFirst(Pattern.quote((String)tags.get(i)), "");
            }
        }

        comment = comment.trim();
        return value;
    }
    
    public static Boolean getBooleanTag(Pattern paramRegex){
        Boolean flag = false;
        
        ArrayList tags = Javadoc.parseComment(comment);
        
        for (int i = 0; i < tags.size(); i++) {
            Matcher tag = paramRegex.matcher((String)tags.get(i));
            if(tag.find()) {
                flag = true;
              
                comment = comment.replaceFirst(Pattern.quote((String)tags.get(i)), "");
            }
        }

        comment = comment.trim();
        return flag;
    }
    
    public static String removeLeadingWhitespace(String text){
        Pattern whitespace = Pattern.compile("\\n\\s+");
        
        text = whitespace.matcher(text).replaceAll("\n");
        
        return text.trim();
    }
}
