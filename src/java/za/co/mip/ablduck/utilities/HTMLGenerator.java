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
import java.util.regex.Pattern;
import java.util.regex.Matcher;

import org.apache.tools.ant.BuildException;

import com.google.gson.annotations.SerializedName;

import za.co.mip.ablduck.models.SourceJSObject;
import za.co.mip.ablduck.models.generic.DeprecatedObject;
import za.co.mip.ablduck.models.generic.MetaObject;
import za.co.mip.ablduck.models.source.MemberObject;
import za.co.mip.ablduck.models.source.ParameterObject;

import java.lang.annotation.Annotation;
import java.lang.reflect.Field;

public class HTMLGenerator {
    private String ulTag = "<ul>";
    private String ulEndTag = "</ul>";
    private String liTag = "<li>";
    private String liEndTag = "</li>";
    private String brTag = "</br>";
    private String divEndTag = "</div>";
    
    private static Pattern returnType = Pattern.compile("\\):(.*)");
    private Map<String, SourceJSObject> classes;
            
    public String getClassHtml (Map<String, SourceJSObject> allclasses, SourceJSObject cls) {
        classes = allclasses;
        String classHtml = "<div>"
                           + renderSidebar(cls)
                           + "<div class='doc-contents'>"
                           + renderClassComment(cls)
                           + this.divEndTag
                           + "<div class='members'>"
                           + renderMemberDetails(cls, "property", "Properties")
                           + renderMemberDetails(cls, "method", "Methods")
                           + this.divEndTag
                         + this.divEndTag;
        return classHtml;
    }
    
    private String renderSidebar (SourceJSObject cls) {
        String sidebar = "";
        
        if(!"".equals(cls.ext) || cls.subclasses.size() > 0){
            
            sidebar = "<pre class='hierarchy'>"
                         + renderClassTree(cls)
                         + renderSubclasses(cls)
                         + renderAuthor(cls)
                    + "</pre>";
        }
        
        return sidebar;
    }
    
    private String renderAuthor (SourceJSObject cls) {
        String author = "";
        if (!"".equals(cls.author)){
            author = "<h4>Author</h4>"
                   + "<div class='dependency'>" + cls.author + this.divEndTag;
        }
        
        return author;
    }
    
    private String renderClassTree (SourceJSObject cls) {
        String classTree = "";
                
        if(!cls.superclasses.isEmpty()) {
            classTree = "<h4>Hierarchy</h4>";
            
            cls.superclasses.add(cls.name);
        
            classTree += renderSuperTree(cls.superclasses, 0);
        }
        
        return classTree;
    }
    
    private String renderSuperTree (List<String> superclasses, Integer i) {
        if (i == superclasses.size())
            return "";
        
        String tree = "";
        
        String firstChild = "";
        if(i==0){ 
            firstChild = "first-child";
        }
            
        String name = renderLink((String)superclasses.get(i));
        if (i == superclasses.size() -1){
            name = "<strong>" + superclasses.get(i) + "</strong>";
        }
             
        tree += "<div class='subclass " + firstChild + "'>"
              + name
              + renderSuperTree(superclasses, i + 1)
              + this.divEndTag;
        
        return tree;
    }
    
    private String renderSubclasses (SourceJSObject cls) {
        String deps = "";
        if(!cls.subclasses.isEmpty()){
            deps = "<h4>Subclasses</h4>";

            for (String subclass : cls.subclasses) {
                deps += "<div class='dependency'>" + renderLink(subclass) + this.divEndTag;
            }
        }
        return deps;
    }
    
    private String renderClassComment (SourceJSObject cls) {
        String classComment = "";
        
        if (cls.meta.internal != null) 
            classComment = renderInternal(cls.meta.internal) + this.brTag;
                
        if (cls.meta.deprecated != null)
            classComment = renderDeprecated("class", cls.meta.deprecated) + this.brTag + classComment;
               
        classComment += cls.comment;
        return classComment;
    }
    
    private String renderMemberDetails (SourceJSObject cls, String memberSection, String memberSectionTitle) {
        
        return "<div class='members-section'>"
                 + "<div class='definedBy'>Defined By</div>"
                 + "<h3 class='members-title icon-" + memberSection + "'>" + memberSectionTitle + "</h3>"
                 + "<div class='subsection'>"
                    + renderMember(cls, memberSection)
                 + this.divEndTag
              + this.divEndTag;
    }
    
    private String renderMember (SourceJSObject cls, String memberType) {
        
        String memberHTML = "";
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
                
                String doc = "";
                if(member.comment != null)
                    doc = member.comment;
                
                String shortdoc = stripHtmlTags(doc);
                if (shortdoc.length() > 100)
                    shortdoc = shortdoc.substring(0, 100) + " ..."; 
                
                if(shortdoc.length() == 0) {
                    shortdoc = "&nbsp;";
                    doc      = shortdoc;
                }
                
                if (member.meta.internal != null) 
                    doc = renderInternal(member.meta.internal) + this.brTag + doc;
                
                if (member.meta.deprecated != null)
                    doc = renderDeprecated(member.tagname, member.meta.deprecated) + this.brTag + doc;
               
                String sig = "";
                String returnT = "";
                
                if ("method".equals(member.tagname)) {
                    if (member.parameters.size() > 0) {
                        doc += this.brTag
                            + "<h3 class=\"pa\">Parameters</h3>"
                            + this.ulTag;
                    }
                    
                    sig = "(";

                    for (ParameterObject parameter : member.parameters) {
                        
                        //Are we a known class being passed in? if so render a link to class
                        String datatype;
                        if(classes.get(parameter.datatype) != null)
                          datatype = renderLink(parameter.datatype);
                        else 
                          datatype = parameter.datatype;
                        
                        if ("(".equals(sig))
                            sig += datatype;
                        else
                            sig += ", " + datatype;
                        
                        doc += renderParams(parameter);
                    }
                    sig += ")";
                    
                    if (member.parameters.size() > 0) {
                        doc += this.ulEndTag;
                    }
                    
                    Matcher r = returnType.matcher(member.signature);
                    if(r.find()) {
                        if(classes.get(r.group(1)) != null){
                            returnT = renderLink(r.group(1));
                        } else {
                            returnT = r.group(1);
                        }
                    }
                    
                    doc += renderReturns(returnT, member.returnComment);
                }
                
                if ("property".equals(member.tagname)) {
                    if(classes.get(member.datatype) != null){
                        returnT = renderLink(member.datatype);
                    } else {
                        returnT = member.datatype;
                    }
                }
                
                memberHTML += "<div id='" + member.id + "' class='member " + firstChild + " " + inherited + "'>"
                              // leftmost column: expand button
                              + "<a href='#' class='side expandable'>"
                                  + "<span>&nbsp;</span>"
                              + "</a>"
                              // member name and type + link to owner class and source
                              + "<div class='title'>"
                                  + "<div class='meta'>"
                                      + "<span class='defined-in' rel='" + member.owner + "'>" + member.owner + "</span>"
                                      + "<br/>"
                                      //+ "<a href='source/abc.html' target='_blank' class='view-source'>view source</a>"
                                  + this.divEndTag
                                  + "<a href='#!/api/" + cls.name + "-" + member.id + "' class='name expandable'>" + member.name + "</a>"
                                  + " " + sig + " : " + returnT
                                  + renderTags(member.meta)
                              + this.divEndTag
                              + "<div class='description'>"
                                  + "<div class='short'>"
                                      + shortdoc
                                  + this.divEndTag
                                  + "<div class='long'>"
                                      + doc
                                  + this.divEndTag
                              + this.divEndTag
                            + this.divEndTag;
            }
        }
        
        return memberHTML;
    }
    
    private String renderReturns (String returnsType, String returnsDoc) {
        return "<h3 class='pa'>Returns</h3>"
             + this.ulTag
                + this.liTag
                   + "<span class='pre'>" + returnsType +"</span>"
                   + "<div class='sub-desc'>"
                      + returnsDoc
                   + this.divEndTag
                + this.liEndTag
             + this.ulEndTag;
    }
    
    private String renderParams (ParameterObject renderParams) {
        return this.liTag
               + "<span class='pre'>" + renderParams.name + "</span> : "
               + renderParams.datatype
               + "<div class='sub-desc'>"
                   + renderParams.comment
               + this.divEndTag
             + this.liEndTag;
    }
    
    private String renderTags (MetaObject meta) {
        String tags = "<span class=\"signature\">";
        
        Class<?> c = meta.getClass();
        Field[] fields = c.getDeclaredFields();

        for (Field field : fields) {
            field.setAccessible(true);
            Boolean flag = false;
            String key = null;
            
            Annotation[] annotations = field.getDeclaredAnnotations();
            for(Annotation annotation : annotations){
                if(annotation instanceof SerializedName){
                    SerializedName myAnnotation = (SerializedName) annotation;
                    key = myAnnotation.value();
                    
                    try {
                        if(field.get(meta) instanceof DeprecatedObject || field.get(meta) instanceof String)
                            flag = true;
                        else
                            flag = (Boolean) field.get(meta);
                    } catch (IllegalAccessException ex) {
                        throw new BuildException(ex);
                    }
                    
                }
            }
            
            if (flag != null && flag)
                tags += "<span class='" + key.toLowerCase() + "'>" + key.toUpperCase() + "</span>";
        }
        
        tags += "</span>";
                
        return tags;
    }
    
    private String renderDeprecated (String tagname, DeprecatedObject deprecated) {
        return "<div class='rounded-box deprecated-box deprecated-tag-box'>\n"
                  + "<p>This " + tagname + " has been <strong>deprected</strong> since " + deprecated.version + "</p>\n"
                  + deprecated.text + "\n"
             + this.divEndTag;
    }
    
    private String renderInternal (String internal) {
        return "<div class='rounded-box private-box'>\n"
                  + "<p><strong>NOTE:</strong> " + internal + "</p>\n"
              + this.divEndTag;
    }
    
    private String renderLink (String link) {
        return "<a href='#!/api/" + link + "' rel='" + link + "' class='docClass'>" + link + "</a>";
    }
    
    private String stripHtmlTags(String doc) {
        return doc.replaceAll("<[^>]*>", "");
    }
}
