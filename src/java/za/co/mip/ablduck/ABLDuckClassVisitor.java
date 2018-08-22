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
import java.util.HashMap;
import java.util.List;

import org.apache.tools.ant.Task;

import com.openedge.core.runtime.IPropath;

import eu.rssw.pct.oedoc.ClassDocumentationVisitor;
import eu.rssw.rcode.AccessModifier;
import eu.rssw.rcode.ClassCompilationUnit;
import eu.rssw.rcode.Constructor;
import eu.rssw.rcode.Dataset;
import eu.rssw.rcode.Event;
import eu.rssw.rcode.Method;
import eu.rssw.rcode.Property;
import eu.rssw.rcode.TempTable;
import eu.rssw.rcode.Using;
import za.co.mip.ablduck.javadoc.Javadoc;
import za.co.mip.ablduck.javadoc.JavadocListener;
import za.co.mip.ablduck.models.CompilationUnit;
import za.co.mip.ablduck.models.Member;
import za.co.mip.ablduck.models.Parameter;
import za.co.mip.ablduck.models.Return;

public class ABLDuckClassVisitor extends ClassDocumentationVisitor {
    private Javadoc javadocParser;
    
    public ABLDuckClassVisitor(IPropath propath, Task ablduck) {
        super(propath);

        javadocParser = new Javadoc(ablduck);
    }

    public CompilationUnit getCompilationUnit() {
        CompilationUnit cu = new CompilationUnit();
        ClassCompilationUnit classUnit = getClassCompilationUnit();

        String fullyQualifiedClassName = (classUnit.packageName != null
                ? classUnit.packageName + "."
                : "") + classUnit.className;

        cu.files = new ArrayList<String>();

        cu.uses = new ArrayList<String>();
        for (Using using : classUnit.usings) {
            cu.uses.add(using.name);
        }

        cu.id = "class-" + fullyQualifiedClassName;
        cu.tagname = "class";
        cu.name = fullyQualifiedClassName;

        cu.inherits = (classUnit.inherits != null ? classUnit.inherits : "");

        cu.superclasses = new ArrayList<String>();
        cu.subclasses = new ArrayList<String>();

        if (classUnit.isInterface) {
            cu.icon = "interface";
            cu.implementers = new ArrayList<String>();
        } else {
            cu.icon = "class";
            cu.implementations = new ArrayList<String>();
            cu.implementations.addAll(classUnit.interfaces);
        }

        String c = null;
        if (!classUnit.classComment.isEmpty()) {
            for (int i = classUnit.classComment.size() - 1; i >= 0; i--) {
                c = classUnit.classComment.get(i); // Assuming last comment will always be the class
                                                   // comment, will need to cater for license later
                if (c != null)
                    break;
            }
        }

        JavadocListener classComment = parseComment(c, fullyQualifiedClassName);

        cu.comment = classComment.getComment();
        cu.author = classComment.getAuthor();

        cu.meta.isInternal = classComment.isInternal();
        cu.meta.isDeprecated = classComment.getDeprecated();
        cu.meta.isAbstract = (classUnit.isAbstract ? classUnit.isAbstract : null);
        cu.meta.isFinal = (classUnit.isFinal ? classUnit.isFinal : null);
        
        cu.members = new ArrayList<>();
        
        // Constructor
        Integer constructorCount = 1;
        for (Constructor constructor : classUnit.constructors) {
            Member member = new Member();
            
            member.id = "constructor-" + classUnit.className + constructorCount.toString();
            member.name = classUnit.className;
            member.owner = fullyQualifiedClassName;
            member.tagname = "constructor";
            
            JavadocListener constructorComment = parseComment(constructor.constrComment, fullyQualifiedClassName + ":constructor#" + constructorCount.toString());
            
            member.comment = constructorComment.getComment();
            
            member.meta.isPrivate = (constructor.modifier == AccessModifier.PRIVATE ? true : null);
            member.meta.isProtected = (constructor.modifier == AccessModifier.PROTECTED ? true : null);
            member.meta.isStatic = (constructor.modifier == AccessModifier.STATIC ? true : null);
            member.meta.isInternal = constructorComment.isInternal();
            member.meta.isDeprecated = constructorComment.getDeprecated();
            
            member.parameters = addParameters(constructor.parameters, constructorComment.getParameters());
                    
            constructorCount++;
            cu.members.add(member);
        }
        
        //TODO: Implement Destructors
        
        // Events
        for (Event event : classUnit.events) {
            Member member = new Member();

            member.id = "event-" + event.eventName;
            member.name = event.eventName;
            member.owner = fullyQualifiedClassName;
            member.tagname = "event";
            
            JavadocListener eventComment = parseComment(event.eventComment, fullyQualifiedClassName + ":" + event.eventName);
            
            member.comment = eventComment.getComment();
            
            member.meta.isPrivate = (event.modifier == AccessModifier.PRIVATE ? true : null);
            member.meta.isProtected = (event.modifier == AccessModifier.PROTECTED ? true : null);
            member.meta.isStatic = (event.modifier == AccessModifier.STATIC ? true : null);
            member.meta.isAbstract = (event.isAbstract ? true : null);
            //TODO: Implement override on events
            member.meta.isInternal = eventComment.isInternal();
            member.meta.isDeprecated = eventComment.getDeprecated();
            
            member.returns = new Return();
            member.returns.comment = eventComment.getReturn();
            //TODO: Implement event return datatype
            
            member.parameters = addParameters(event.parameters, eventComment.getParameters());
            
            cu.members.add(member);
        }
        
        // Properties
        for (Property property : classUnit.properties) {
            Member member = new Member();

            member.id = "property-" + property.name;
            member.name = property.name;
            member.owner = fullyQualifiedClassName;
            member.tagname = "property";
            member.datatype = property.dataType;

            JavadocListener propertyComment = parseComment(property.propertyComment, fullyQualifiedClassName + ":" + property.name);
            
            member.comment = propertyComment.getComment();
            
            member.meta.isPrivate = (property.modifier == AccessModifier.PRIVATE ? true : null);
            member.meta.isProtected = (property.modifier == AccessModifier.PROTECTED ? true : null);
            member.meta.isStatic = (property.modifier == AccessModifier.STATIC ? true : null);
            member.meta.isAbstract = (property.isAbstract ? true : null);
            //TODO: Implement override on properties
            member.meta.isInternal = propertyComment.isInternal();
            member.meta.isDeprecated = propertyComment.getDeprecated();
            
            cu.members.add(member);
        }
        
        // Methods
        Integer methodCount = 0;
        String previousMethodName = "";
        for (Method method : classUnit.methods) {
            Member member = new Member();

            if (previousMethodName.equals(method.methodName)) {
                methodCount++;
            } else {
                methodCount = 0;
                previousMethodName = method.methodName;
            }

            member.id = "method-" + method.methodName + (methodCount > 0 ? "-" + methodCount.toString() : "");

            member.name = method.methodName;
            member.owner = fullyQualifiedClassName;
            member.tagname = "method";
            
            JavadocListener methodComment = parseComment(method.methodComment, fullyQualifiedClassName + ":" + method.methodName);
            
            member.comment = methodComment.getComment();
            
            member.meta.isPrivate = (method.modifier == AccessModifier.PRIVATE ? true : null);
            member.meta.isProtected = (method.modifier == AccessModifier.PROTECTED ? true : null);
            member.meta.isStatic = (method.modifier == AccessModifier.STATIC ? true : null);
            member.meta.isAbstract = (method.isAbstract ? true : null);
            //TODO: Implement override on methods
            member.meta.isFinal = (method.isFinal ? true : null);
            member.meta.isInternal = methodComment.isInternal();
            member.meta.isDeprecated = methodComment.getDeprecated();
            
            member.returns = new Return();
            member.returns.comment = methodComment.getReturn();
            member.returns.datatype = method.returnType;
            
            member.parameters = addParameters(method.parameters, methodComment.getParameters());
            
            cu.members.add(member);
        }
        
        // Temp-Tables
        for (TempTable tempTable : classUnit.tts) {
            Member member = new Member();

            member.id = "temptable-" + tempTable.name;
            member.name = tempTable.name;
            member.owner = fullyQualifiedClassName;
            member.tagname = "temptable";
            member.definition = tempTable.aceText.replace("\n", "<br>&nbsp;&nbsp;&nbsp;&nbsp;");

            JavadocListener tempTableComment = parseComment(tempTable.comment, fullyQualifiedClassName + ":" + tempTable.name);
            
            member.comment = tempTableComment.getComment();
            member.meta.isInternal = tempTableComment.isInternal();
            member.meta.isDeprecated = tempTableComment.getDeprecated();
            
            //TODO: Implement private on temp-tables
            //TODO: Implement protected on temp-tables 
            //TODO: Implement static on temp-tables
            //TODO: Implement new on temp-tables 
            //TODO: Implement global on temp-tables 
            //TODO: Implement shared on temp-tables 
            member.meta.isNoUndo = (tempTable.noUndo ? true : null);
            
            
            cu.members.add(member);
        }
        
        // Datasets
        for (Dataset dataset : classUnit.dss) {
            Member member = new Member();

            member.id = "dataset-" + dataset.name;
            member.name = dataset.name;
            member.owner = fullyQualifiedClassName;
            member.tagname = "dataset";
            member.definition = dataset.aceText.replace("\n", "<br>&nbsp;&nbsp;&nbsp;&nbsp;");
 
            JavadocListener datasetComment = parseComment(dataset.comment, fullyQualifiedClassName + ":" + dataset.name);
            
            member.comment = datasetComment.getComment();
            member.meta.isInternal = datasetComment.isInternal();
            member.meta.isDeprecated = datasetComment.getDeprecated();
            
            //TODO: Implement private on temp-tables
            //TODO: Implement protected on temp-tables 
            //TODO: Implement static on temp-tables
            //TODO: Implement new on temp-tables 
            //TODO: Implement shared on temp-tables 
            
            cu.members.add(member);
        }
            
        return cu;
        
    }
    
    public JavadocListener parseComment(String comment, String source){
        if(comment == null)
            comment = "";
        
        JavadocListener parsedComment;
        // Javadoc Style Comments
        if(comment.startsWith("/**")) {
            parsedComment = javadocParser.parseComment(comment, source);
        } else { // Old Progress Style
            parsedComment = new JavadocListener();
        }
        
        return parsedComment;
    }
    
    public List<Parameter> addParameters(List<eu.rssw.rcode.Parameter> parameters, HashMap<String, String> parameterComments){
        List<Parameter> memberParams = null;
        
        if (!parameters.isEmpty()) {
            memberParams = new ArrayList<>();
            for (eu.rssw.rcode.Parameter param : parameters) {
                Parameter parameter = new Parameter();
    
                parameter.name = param.name;
                parameter.datatype = param.dataType;
                parameter.mode = (param.mode == null ? "" : param.mode.toString());
    
                if (parameterComments != null)
                    parameter.comment = parameterComments.get(parameter.name);
                else
                    parameter.comment = "";
                
                memberParams.add(parameter);  
            }
        }
        
        return memberParams;
    }
}
