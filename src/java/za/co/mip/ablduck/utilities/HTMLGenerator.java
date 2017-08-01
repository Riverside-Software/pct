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

import java.util.List;
import java.util.Map;
import java.util.ResourceBundle;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

import org.apache.tools.ant.BuildException;

import com.google.gson.annotations.SerializedName;

import za.co.mip.ablduck.ABLDuck;
import za.co.mip.ablduck.models.SourceJSObject;
import za.co.mip.ablduck.models.generic.DeprecatedObject;
import za.co.mip.ablduck.models.generic.MetaObject;
import za.co.mip.ablduck.models.source.MemberObject;
import za.co.mip.ablduck.models.source.ParameterObject;

import java.lang.annotation.Annotation;
import java.lang.reflect.Field;
import java.text.MessageFormat;

public class HTMLGenerator {
    private static final ResourceBundle TEMPLATES = ResourceBundle
            .getBundle("za.co.mip.ablduck.utilities.templates");
    private static final String DEPENDANCY = "DEPENDANCY.ITEM";

    private static Pattern returnType = Pattern.compile("\\):(.*)");
    private Map<String, SourceJSObject> classes;

    public String getTemplate(String key) {
        return TEMPLATES.getString(key);
    }

    public String getClassHtml(Map<String, SourceJSObject> allclasses, SourceJSObject cls) {
        this.classes = allclasses;

        return MessageFormat.format(getTemplate("CLASSBODY"), renderSidebar(cls),
                renderClassComment(cls), renderMemberDetails(cls, "constructor", "Constructors"),
                renderMemberDetails(cls, "event", "Events"), renderMemberDetails(cls, "property", "Properties"),
                renderMemberDetails(cls, "method", "Methods"));
    }

    private String renderSidebar(SourceJSObject cls) {
        boolean hasSubIntImp = !cls.subclasses.isEmpty() || !cls.interfaces.isEmpty()
                || !cls.implementers.isEmpty();
        if (hasSubIntImp || !"".equals(cls.ext) || !"".equals(cls.author))
            return MessageFormat.format(getTemplate("SIDEBAR"), renderClassTree(cls),
                    renderSubclasses(cls), renderInterfaces(cls), renderImplementers(cls),
                    renderAuthor(cls));

        return "";
    }

    private String renderImplementers(SourceJSObject cls) {
        if (!cls.implementers.isEmpty()) {
            StringBuilder implementerBuilder = new StringBuilder();
            for (String implementer : cls.implementers) {
                implementerBuilder.append(MessageFormat.format(getTemplate(DEPENDANCY),
                        renderLink(cls, implementer)));
            }
            return MessageFormat.format(getTemplate("IMPLEMENTERS"), implementerBuilder.toString());
        }
        return "";
    }

    private String renderInterfaces(SourceJSObject cls) {
        if (!cls.interfaces.isEmpty()) {

            StringBuilder interfaceBuilder = new StringBuilder();
            for (String iface : cls.interfaces) {
                interfaceBuilder.append(MessageFormat.format(getTemplate(DEPENDANCY),
                        renderLink(cls, iface)));
            }

            return MessageFormat.format(getTemplate("INTERFACES"), interfaceBuilder.toString());
        }

        return "";
    }

    private String renderAuthor(SourceJSObject cls) {
        if (!"".equals(cls.author))
            return MessageFormat.format(getTemplate("AUTHOR"), cls.author);

        return "";
    }

    private String renderClassTree(SourceJSObject cls) {
        if (!cls.superclasses.isEmpty()) {
            // Add this class to the tree for display purposes
            cls.superclasses.add(cls.name);

            String classTree = renderSuperTree(cls, 0);

            return MessageFormat.format(getTemplate("HIERARCHY"), classTree);
        }

        return "";
    }

    private String renderSuperTree(SourceJSObject cls, Integer i) {
        List<String> superclasses = cls.superclasses;
        // If we are finished rendering the links leave
        if (i == superclasses.size())
            return "";

        // Add the first child class if we are the first class
        String cssClass = "";
        if (i == 0)
            cssClass = "first-child";

        // Render superclasses as a hyperlink unless we are the first class, ourself
        String classLink = renderLink(cls, superclasses.get(i));

        if (i == superclasses.size() - 1)
            classLink = "<strong>" + superclasses.get(i) + "</strong>";

        return MessageFormat.format(getTemplate("HIERARCHY.ITEM"), cssClass, classLink,
                renderSuperTree(cls, i + 1));
    }

    private String renderSubclasses(SourceJSObject cls) {
        if (!cls.subclasses.isEmpty()) {

            StringBuilder subclassBuilder = new StringBuilder();
            for (String subclass : cls.subclasses) {
                subclassBuilder.append(MessageFormat.format(getTemplate(DEPENDANCY),
                        renderLink(cls, subclass)));
            }

            return MessageFormat.format(getTemplate("SUBCLASSES"), subclassBuilder.toString());
        }

        return "";
    }

    private String renderClassComment(SourceJSObject cls) {
        StringBuilder classComment = new StringBuilder();

        if (cls.meta.deprecated != null)
            classComment.append(renderDeprecated("class", cls.meta.deprecated));

        if (cls.meta.internal != null)
            classComment.append(renderInternal(cls.meta.internal));

        classComment.append(cls.comment);

        return classComment.toString();
    }

    private String renderMemberDetails(SourceJSObject cls, String memberSection,
            String memberSectionTitle) {
        return MessageFormat.format(getTemplate("MEMBER.SECTION"), memberSection,
                memberSectionTitle, renderMember(cls, memberSection));
    }

    private String renderMember(SourceJSObject cls, String memberType) {

        StringBuilder memberHTML = new StringBuilder();
        Boolean first = true;

        for (MemberObject member : cls.members) {

            if (member.tagname.equals(memberType)) {

                String firstChild = "";
                if (first) {
                    firstChild = "first-child";
                    first = false;
                }

                String inherited;
                if (member.owner.equals(cls.name))
                    inherited = "not-inherited";
                else
                    inherited = "inherited";

                StringBuilder doc = new StringBuilder();

                if (member.meta.deprecated != null)
                    doc.append(renderDeprecated(member.tagname, member.meta.deprecated));

                if (member.meta.internal != null)
                    doc.append(renderInternal(member.meta.internal));

                if (member.comment != null)
                    doc.append(member.comment);

                String shortdoc = stripHtmlTags(doc.toString());
                if (shortdoc.length() > 100)
                    shortdoc = shortdoc.substring(0, 100) + " ...";

                if (shortdoc.length() == 0) {
                    shortdoc = "&nbsp;";
                    doc.setLength(0);
                    doc.append(shortdoc);
                }

                StringBuilder sig = new StringBuilder();
                String returnTypeDoc = "";

                if ("method".equals(member.tagname) || "event".equals(member.tagname) || "constructor".equals(member.tagname)) {
                    StringBuilder parameters = new StringBuilder();
                    sig.append("(");

                    for (ParameterObject parameter : member.parameters) {

                        // Are we a known class being passed in? if so render a link to class
                        String datatype = renderLink(cls, parameter.datatype);

                        if (!"(".equals(sig.toString()))
                            sig.append(", ");
                            
                        if (!"INPUT".equals(parameter.mode))
                            sig.append(parameter.mode + " ");
                        
                        sig.append(datatype);
                            
                        parameters.append(renderParams(cls, parameter));
                    }
                    sig.append(")");

                    if (!member.parameters.isEmpty()) {
                        doc.append(MessageFormat.format(getTemplate("PARAMETERS"),
                                parameters.toString()));
                    }

                    Matcher r = returnType.matcher(member.signature);
                    if (r.find()) {
                        returnTypeDoc = renderLink(cls, r.group(1));

                        doc.append(renderReturns(returnTypeDoc, member.returnComment));
                    }
                }

                if ("property".equals(member.tagname)) {
                    returnTypeDoc = renderLink(cls, member.datatype);
                }

                String colonReturnType = "";
                if (returnTypeDoc.length() > 0)
                    colonReturnType = " : " + returnTypeDoc;

                memberHTML.append(MessageFormat.format(getTemplate("MEMBER"), member.id, // 0
                        firstChild, // 1
                        inherited, // 2
                        member.owner, // 3
                        cls.name, // 4
                        member.name, // 5
                        sig.toString(), // 6
                        colonReturnType, // 7
                        renderTags(member.meta), // 8
                        shortdoc, // 9
                        doc.toString())); // 10
            }
        }

        return memberHTML.toString();
    }

    private String renderReturns(String returnsType, String returnsDoc) {
        return MessageFormat.format(getTemplate("RETURNS"), returnsType, returnsDoc);
    }

    private String renderParams(SourceJSObject cls, ParameterObject renderParams) {
        return MessageFormat.format(getTemplate("PARAMETER"), renderParams.name,
                renderLink(cls, renderParams.datatype), renderParams.comment);
    }

    private String renderTags(MetaObject meta) {
        StringBuilder tags = new StringBuilder();

        Class<?> c = meta.getClass();
        Field[] fields = c.getDeclaredFields();

        for (Field field : fields) {
            field.setAccessible(true);
            Boolean flag = false;
            String key = null;

            Annotation[] annotations = field.getDeclaredAnnotations();
            for (Annotation annotation : annotations) {
                if (annotation instanceof SerializedName) {
                    SerializedName myAnnotation = (SerializedName) annotation;
                    key = myAnnotation.value();

                    try {
                        if (field.get(meta) instanceof DeprecatedObject
                                || field.get(meta) instanceof String)
                            flag = true;
                        else
                            flag = (Boolean) field.get(meta);
                    } catch (IllegalAccessException ex) {
                        throw new BuildException(ex);
                    }

                }
            }

            if (flag != null && flag)
                tags.append(MessageFormat.format(getTemplate("TAG"), key.toLowerCase(),
                        key.toUpperCase()));
        }

        return MessageFormat.format(getTemplate("TAGS"), tags);
    }

    private String renderDeprecated(String tagname, DeprecatedObject deprecated) {
        return MessageFormat.format(getTemplate("DEPRECATED"), tagname, deprecated.version,
                deprecated.text);
    }

    private String renderInternal(String internal) {
        return MessageFormat.format(getTemplate("INTERNAL"), internal);
    }

    private String renderLink(SourceJSObject cls, String dataType) {
        String fullClassName = ABLDuck.determineUsingClass(classes, cls, dataType);

        // Can we find a with the exact className
        if (classes.get(fullClassName) != null)
            return MessageFormat.format(getTemplate("LINK"), fullClassName, dataType);

        return dataType;
    }

    private String stripHtmlTags(String doc) {
        return doc.replaceAll("<[^>]*>", "");
    }
}
