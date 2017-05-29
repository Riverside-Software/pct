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

import java.util.ArrayList;

import java.io.File;
import java.io.IOException;

import com.openedge.core.runtime.IPropath;

import eu.rssw.pct.oedoc.ClassDocumentationVisitor;

import eu.rssw.rcode.ClassCompilationUnit;
import eu.rssw.rcode.Method;
import eu.rssw.rcode.Property;
import eu.rssw.rcode.Parameter;
import eu.rssw.rcode.AccessModifier;

public class ABLDuckClassVisitor extends ClassDocumentationVisitor {
	
	public ABLDuckClassVisitor(IPropath propath) {
        super(propath);
    }

    public SourceJSObject getJSObject() throws IOException{
        SourceJSObject js = new SourceJSObject();
    	ClassCompilationUnit cu = getClassCompilationUnit();
        String fullClassName;

        if (cu.packageName != null)
    	   fullClassName = cu.packageName + "." + cu.className;
        else
            fullClassName = cu.className;

        js.id        = "class-" + fullClassName;
    	js.tagname   = "class";
    	js.name      = fullClassName;
        js.shortname = cu.className;
        js.classIcon = "class";

        if (cu.inherits != null)
            js.extends_ = cu.inherits;

        String c = cu.classComment.get(cu.classComment.size() - 1); // Assuming last comment will always be the class comment, will need to cater for license later
        
        try {
            CommentParseResult commentParseResult = CommentParser.parseComment(c, fullClassName);

            //TODO: fix this, not even sure i like it
            if (!commentParseResult.internal)
                commentParseResult.internal = cu.className.startsWith("_");

            js.comment = commentParseResult.comment;
            js.author = commentParseResult.author;
    
            if (commentParseResult.internal)
                js.meta.internal = "This is a private class for internal use by the framework. Don't rely on its existence.";
    
    
            if (!commentParseResult.deprecatedVersion.equals("")) {
                js.meta.deprecated = new DeprecatedObject();
    
                js.meta.deprecated.version = commentParseResult.deprecatedVersion;
                js.meta.deprecated.text    = commentParseResult.deprecatedText;
            }

        } catch (IOException ex) {
            throw ex;
        }

        Integer methodCount = 0;
        String previousMethodName = "";
        // Members
        for (Method method : cu.methods) {
            MemberObject m = new MemberObject();

            if (previousMethodName.equals(method.methodName)) {
                methodCount++;
            } else {
                methodCount = 0;
                previousMethodName = method.methodName;
            }

            if (methodCount == 0)
                m.id = "method-" + method.methodName;
            else
                m.id = "method-" + method.methodName + "-" + methodCount.toString();
            m.name = method.methodName;
            m.owner = fullClassName;
            m.tagname = "method";
            m.signature = method.signature;

            try {
                CommentParseResult commentParseResult = CommentParser.parseComment(method.methodComment, fullClassName + ":" + method.methodName);

                if (!commentParseResult.internal)
                    commentParseResult.internal = method.methodName.startsWith("_");

                m.returnComment = commentParseResult.returnComment;
                m.comment = commentParseResult.comment;

                if (commentParseResult.internal)
                    m.meta.internal = "This is a private method for internal use by the framework. Don't rely on its existence.";

                //TODO: remove this duplication tsk tsk, write a meta adding method for class, method and property
                if (!commentParseResult.deprecatedVersion.equals("")) {
                    m.meta.deprecated = new DeprecatedObject();
        
                    m.meta.deprecated.version = commentParseResult.deprecatedVersion;
                    m.meta.deprecated.text    = commentParseResult.deprecatedText;
                }
            } catch (IOException ex) {
                throw ex;
            }
            
            switch (method.modifier){
                case PRIVATE:
                    m.meta.private_ = true;
                    break;
                case PROTECTED:
                    m.meta.protected_ = true;
                    break;
            }
            
            if (method.isAbstract)
                m.meta.abstract_ = true;

            if (method.isStatic)
                m.meta.static_ = true;

            m.parameters = new ArrayList<ParameterObject>();
            for (Parameter parameter : method.parameters) {
                ParameterObject p = new ParameterObject();

                p.name = parameter.name;
                p.datatype = parameter.dataType;

                //TODO: do i need this? probably need to show this in the docs somewhere
                p.mode = parameter.mode.toString();

                m.parameters.add(p);
            }

            js.members.add(m);
        }

        //TODO: remove this duplication tsk tsk, write a meta adding method for class, method and property
        //Properties
        for (Property property : cu.properties) {
            MemberObject m = new MemberObject();

            m.id = "property-" + property.name;
            m.name = property.name;
            m.owner = fullClassName;
            m.tagname = "property";
            m.datatype = property.dataType;

            try {
                CommentParseResult commentParseResult = CommentParser.parseComment(property.propertyComment, fullClassName + ":" + property.name);

                if (!commentParseResult.internal)
                    commentParseResult.internal = property.name.startsWith("_");

                m.comment = commentParseResult.comment;

                if (commentParseResult.internal)
                    m.meta.internal = "This is a private property for internal use by the framework. Don't rely on its existence.";

                if (!commentParseResult.deprecatedVersion.equals("")) {
                    m.meta.deprecated = new DeprecatedObject();
        
                    m.meta.deprecated.version = commentParseResult.deprecatedVersion;
                    m.meta.deprecated.text    = commentParseResult.deprecatedText;
                }

            } catch (IOException ex) {
                throw ex;
            }
            
            switch (property.modifier){
                case PRIVATE:
                    m.meta.private_ = true;
                    break;
                case PROTECTED:
                    m.meta.protected_ = true;
                    break;
            }

            if (property.isAbstract)
                m.meta.abstract_ = true;

            if (property.isStatic)
                m.meta.static_ = true;

            js.members.add(m);
        }
        return js;
    }
}