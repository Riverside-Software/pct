/**
 * Copyright 2017-2018 MIP Holdings
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

import org.apache.tools.ant.Task;

import java.io.IOException;

import com.openedge.core.runtime.IPropath;

import eu.rssw.pct.oedoc.ClassDocumentationVisitor;

import eu.rssw.rcode.ClassCompilationUnit;
import eu.rssw.rcode.Constructor;
import eu.rssw.rcode.Event;
import eu.rssw.rcode.Method;
import eu.rssw.rcode.Property;
import eu.rssw.rcode.Parameter;
import eu.rssw.rcode.AccessModifier;

import za.co.mip.ablduck.models.SourceJSObject;
import za.co.mip.ablduck.models.generic.DeprecatedObject;
import za.co.mip.ablduck.models.source.MemberObject;
import za.co.mip.ablduck.models.source.ParameterObject;
import za.co.mip.ablduck.utilities.CommentParser;
import za.co.mip.ablduck.utilities.CommentParseResult;

public class ABLDuckClassVisitor extends ClassDocumentationVisitor {
    private CommentParser comments;

    public ABLDuckClassVisitor(IPropath propath, Task ablduck) {
        super(propath);

        this.comments = new CommentParser(ablduck);
    }

    public SourceJSObject getJSObject() throws IOException {
        SourceJSObject js = new SourceJSObject();
        ClassCompilationUnit cu = getClassCompilationUnit();
        String fullClassName;

        if (cu.packageName != null)
            fullClassName = cu.packageName + "." + cu.className;
        else
            fullClassName = cu.className;

        js.id = "class-" + fullClassName;
        js.tagname = "class";
        js.name = fullClassName;
        js.shortname = cu.className;
        js.interfaces.addAll(cu.interfaces);
        js.using.addAll(cu.usings);
        js.isInterface = cu.isInterface;

        if (cu.isInterface)
            js.classIcon = "interface";
        else
            js.classIcon = "class";

        if (cu.inherits != null)
            js.ext = cu.inherits;

        String c = null;
        if (!cu.classComment.isEmpty()) {
            for (int i = cu.classComment.size() - 1; i >= 0; i--) {
                c = cu.classComment.get(i); // Assuming last comment will always be the class
                                            // comment, will need to cater for license later
                if (c != null)
                    break;
            }
        }

        try {
            CommentParseResult commentParseResult = comments.parseComment(c, fullClassName);

            if (!commentParseResult.getInternal())
                commentParseResult.setInternal(cu.className.startsWith("_"));

            js.comment = commentParseResult.getComment();
            js.author = commentParseResult.getAuthor();

            if (commentParseResult.getInternal())
                js.meta.internal = "This is a private class for internal use by the framework. Don't rely on its existence.";

            if (!"".equals(commentParseResult.getDeprecatedVersion())) {
                js.meta.deprecated = new DeprecatedObject();

                js.meta.deprecated.version = commentParseResult.getDeprecatedVersion();
                js.meta.deprecated.text = commentParseResult.getDeprecatedText();
            }

        } catch (IOException ex) {
            throw ex;
        }
        
        Integer constructorCount = 0;
        for (Constructor constructor : cu.constructors) {
            MemberObject m = new MemberObject();
            
            constructorCount++;

            m.id = "constructor-" + cu.className + constructorCount.toString();
            m.name = cu.className;
            m.owner = fullClassName;
            m.tagname = "constructor";
            m.signature = constructor.signature;
            
            CommentParseResult commentParseResult = null;
            try {
                commentParseResult = comments.parseComment(constructor.constrComment,
                        fullClassName + ":" + cu.className);

                m.returnComment = commentParseResult.getReturnComment();
                m.comment = commentParseResult.getComment();

                if (commentParseResult.getInternal())
                    m.meta.internal = "This is a private constructor for internal use by the framework. Don't rely on its existence.";

                if (!"".equals(commentParseResult.getDeprecatedVersion())) {
                    m.meta.deprecated = new DeprecatedObject();

                    m.meta.deprecated.version = commentParseResult.getDeprecatedVersion();
                    m.meta.deprecated.text = commentParseResult.getDeprecatedText();
                }
            } catch (IOException ex) {
                throw ex;
            }
            
            if (constructor.modifier == AccessModifier.PRIVATE)
                m.meta.isPrivate = true;

            if (constructor.modifier == AccessModifier.PROTECTED)
                m.meta.isProtected = true;
            
            m.parameters = new ArrayList<>();
            for (Parameter parameter : constructor.parameters) {
                ParameterObject p = new ParameterObject();

                p.name = parameter.name;
                p.datatype = parameter.dataType;
                p.mode = parameter.mode == null ? "" : parameter.mode.toString();

                String paramComment = commentParseResult.getParameterComments().get(parameter.name);
                if (paramComment != null)
                    p.comment = paramComment;

                m.parameters.add(p);
            }
            
            js.members.add(m);
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

            CommentParseResult commentParseResult = null;
            try {
                commentParseResult = comments.parseComment(method.methodComment,
                        fullClassName + ":" + method.methodName);

                if (!commentParseResult.getInternal())
                    commentParseResult.setInternal(method.methodName.startsWith("_"));

                m.returnComment = commentParseResult.getReturnComment();
                m.comment = commentParseResult.getComment();

                if (commentParseResult.getInternal())
                    m.meta.internal = "This is a private method for internal use by the framework. Don't rely on its existence.";

                if (!"".equals(commentParseResult.getDeprecatedVersion())) {
                    m.meta.deprecated = new DeprecatedObject();

                    m.meta.deprecated.version = commentParseResult.getDeprecatedVersion();
                    m.meta.deprecated.text = commentParseResult.getDeprecatedText();
                }
            } catch (IOException ex) {
                throw ex;
            }

            if (method.modifier == AccessModifier.PRIVATE)
                m.meta.isPrivate = true;

            if (method.modifier == AccessModifier.PROTECTED)
                m.meta.isProtected = true;

            if (method.isAbstract)
                m.meta.isAbstract = true;

            if (method.isStatic)
                m.meta.isStatic = true;

            m.parameters = new ArrayList<>();
            for (Parameter parameter : method.parameters) {
                ParameterObject p = new ParameterObject();

                p.name = parameter.name;
                p.datatype = parameter.dataType;
                p.mode = parameter.mode == null ? "" : parameter.mode.toString();

                String paramComment = commentParseResult.getParameterComments().get(parameter.name);
                if (paramComment != null)
                    p.comment = paramComment;

                m.parameters.add(p);
            }

            js.members.add(m);
        }

        for (Property property : cu.properties) {
            MemberObject m = new MemberObject();

            m.id = "property-" + property.name;
            m.name = property.name;
            m.owner = fullClassName;
            m.tagname = "property";
            m.datatype = property.dataType;

            try {
                CommentParseResult commentParseResult = comments.parseComment(
                        property.propertyComment, fullClassName + ":" + property.name);

                if (!commentParseResult.getInternal())
                    commentParseResult.setInternal(property.name.startsWith("_"));

                m.comment = commentParseResult.getComment();

                if (commentParseResult.getInternal())
                    m.meta.internal = "This is a private property for internal use by the framework. Don't rely on its existence.";

                if (!"".equals(commentParseResult.getDeprecatedVersion())) {
                    m.meta.deprecated = new DeprecatedObject();

                    m.meta.deprecated.version = commentParseResult.getDeprecatedVersion();
                    m.meta.deprecated.text = commentParseResult.getDeprecatedText();
                }

            } catch (IOException ex) {
                throw ex;
            }

            if (property.modifier == AccessModifier.PRIVATE)
                m.meta.isPrivate = true;

            if (property.modifier == AccessModifier.PROTECTED)
                m.meta.isProtected = true;

            if (property.isAbstract)
                m.meta.isAbstract = true;

            if (property.isStatic)
                m.meta.isStatic = true;

            js.members.add(m);
        }
        
        for (Event event : cu.events) {
            MemberObject m = new MemberObject();

            m.id = "event-" + event.eventName;
            m.name = event.eventName;
            m.owner = fullClassName;
            m.tagname = "event";
            m.signature = event.signature;
            
            CommentParseResult commentParseResult = null;
            try {
                commentParseResult = comments.parseComment(event.eventComment,
                        fullClassName + ":" + event.eventName);

                if (!commentParseResult.getInternal())
                    commentParseResult.setInternal(event.eventName.startsWith("_"));

                m.returnComment = commentParseResult.getReturnComment();
                m.comment = commentParseResult.getComment();

                if (commentParseResult.getInternal())
                    m.meta.internal = "This is a private event for internal use by the framework. Don't rely on its existence.";

                if (!"".equals(commentParseResult.getDeprecatedVersion())) {
                    m.meta.deprecated = new DeprecatedObject();

                    m.meta.deprecated.version = commentParseResult.getDeprecatedVersion();
                    m.meta.deprecated.text = commentParseResult.getDeprecatedText();
                }
            } catch (IOException ex) {
                throw ex;
            }
            
            if (event.modifier == AccessModifier.PRIVATE)
                m.meta.isPrivate = true;

            if (event.modifier == AccessModifier.PROTECTED)
                m.meta.isProtected = true;

            if (event.isAbstract)
                m.meta.isAbstract = true;

            if (event.isStatic)
                m.meta.isStatic = true;
            
            m.parameters = new ArrayList<>();
            for (Parameter parameter : event.parameters) {
                ParameterObject p = new ParameterObject();

                p.name = parameter.name;
                p.datatype = parameter.dataType;
                p.mode = parameter.mode == null ? "" : parameter.mode.toString();

                String paramComment = commentParseResult.getParameterComments().get(parameter.name);
                if (paramComment != null)
                    p.comment = paramComment;

                m.parameters.add(p);
            }
            
            js.members.add(m);
        }
        return js;
    }
}
