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

import java.util.List;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

import org.apache.tools.ant.BuildException;

import java.lang.reflect.*;

public class HTMLGenerator {
    private static Pattern signature = Pattern.compile("\\((.+)\\)");
    private static Pattern returnType = Pattern.compile("\\):(.*)");
    private HashMap classes;
            
    public String getClassHtml (HashMap allclasses, SourceJSObject cls) {
        classes = allclasses;
        String classHtml = "<div>"
                           + renderSidebar(cls)
                           + "<div class='doc-contents'>"
                           + renderClassComment(cls)
                           + "</div>"
                           + "<div class='members'>"
                           + renderMemberDetails(cls, "property", "Properties")
                           + renderMemberDetails(cls, "method", "Methods")
                           + "</div>"
                         + "</div>";
        return classHtml;
    }
    
    private String renderSidebar (SourceJSObject cls) {
        String sidebar = "";
        
        if(!cls.extends_.equals("") || cls.subclasses.size() > 0){
            
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
        if (!cls.author.equals("")){
            author = "<h4>Author</h4>"
                   + "<div class='dependency'>" + cls.author + "</div>";
        }
        
        return author;
    }
    
    private String renderClassTree (SourceJSObject cls) {
        String classTree = "";
                
        if(cls.superclasses.size() > 0) {
            classTree = "<h4>Hierarchy</h4>";
            
            cls.superclasses.add(cls.name);
        
            classTree += renderSuperTree(cls.superclasses, 0);
        }
        
        return classTree;
    }
    
    private String renderSuperTree (List superclasses, Integer i) {
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
              + "</div>";
        
        return tree;
    }
    
    private String renderSubclasses (SourceJSObject cls) {
        String deps = "";
        if(cls.subclasses.size() > 0){
            deps = "<h4>Subclasses</h4>";

            for (String subclass : cls.subclasses) {
                deps += "<div class='dependency'>" + renderLink(subclass) + "</div>";
            }
        }
        return deps;
    }
    
    private String renderClassComment (SourceJSObject cls) {
        String classComment = "";
        
        if (cls.meta.internal != null) 
            classComment = renderInternal(cls.meta.internal) + "</br>";
                
        if (cls.meta.deprecated != null)
            classComment = renderDeprecated("class", cls.meta.deprecated) + "</br>" + classComment;
               
        classComment += cls.comment;
        return classComment;
    }
    
    private String renderMemberDetails (SourceJSObject cls, String memberSection, String memberSectionTitle) {
        
        String member = "<div class='members-section'>"
                          + "<div class='definedBy'>Defined By</div>"
                          + "<h3 class='members-title icon-" + memberSection + "'>" + memberSectionTitle + "</h3>"
                          + "<div class='subsection'>"
                              + renderMember(cls, memberSection)
                          + "</div>"
                      + "</div>";
        
        return member;
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
                    doc      = "&nbsp;";
                }
                
                if (member.meta.internal != null) 
                    doc = renderInternal(member.meta.internal) + "</br>" + doc;
                
                if (member.meta.deprecated != null)
                    doc = renderDeprecated(member.tagname, member.meta.deprecated) + "</br>" + doc;
               
                String sig = "";
                String returnT = "";
                
                if (member.tagname.equals("method")) {
                    if (member.parameters.size() > 0) {
                        doc += "<br>"
                            + "<h3 class=\"pa\">Parameters</h3>"
                            + "<ul>";
                    }
                    
                    sig = "(";

                    for (ParameterObject parameter : member.parameters) {
                        
                        //Are we a known class being passed in? if so render a link to class
                        String datatype;
                        if(classes.get(parameter.datatype) != null)
                          datatype = renderLink(parameter.datatype);
                        else 
                          datatype = parameter.datatype;
                        
                        if (sig.equals("("))
                            sig += datatype;
                        else
                            sig += ", " + datatype;
                        
                        doc += renderParams(parameter);
                    }
                    sig += ")";
                    
                    if (member.parameters.size() > 0) {
                        doc += "</ul>";
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
                
                if (member.tagname.equals("property")) {
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
                                      // TODO: inherited
                                      + "<span class='defined-in' rel='" + member.owner + "'>" + member.owner + "</span>"
                                      + "<br/>"
                                      // TODO: source optional
                                      //+ "<a href='source/abc.html' target='_blank' class='view-source'>view source</a>"
                                  + "</div>"
                                  + "<a href='#!/api/" + cls.name + "-" + member.id + "' class='name expandable'>" + member.name + "</a>"
                                  + " " + sig + " : " + returnT
                                  + renderTags(member.meta)
                              + "</div>"
                              + "<div class='description'>"
                                  + "<div class='short'>"
                                      + shortdoc
                                  + "</div>"
                                  + "<div class='long'>"
                                      + doc
                                  + "</div>"
                              + "</div>"
                            + "</div>";
            }
        }
        
        return memberHTML;
    }
    
    private String renderReturns (String returnsType, String returnsDoc) {
        String returns = "";
        
        returns += "<h3 class='pa'>Returns</h3>"
                   + "<ul>"
                       + "<li>"
                           + "<span class='pre'>" + returnsType +"</span>"
                           + "<div class='sub-desc'>"
                               + returnsDoc
                           + "</div>"
                       + "</li>"
                    + "</ul>";
        
        return returns;
    }
    
    private String renderParams (ParameterObject renderParams) {
        String param = "";
        
        param += "<li>"
                   + "<span class='pre'>" + renderParams.name + "</span> : "
                   + renderParams.datatype
                   + "<div class='sub-desc'>"
                       + renderParams.comment
                   + "</div>"
               + "</li>";
        
        return param;
    }
    
    private String renderTags (MetaObject meta) {
        String tags = "<span class=\"signature\">";

        Class<?> c = meta.getClass();
        Field[] fields = c.getDeclaredFields();

        for (Field field : fields) {
          Boolean flag = false;
          String key;

          try {
            if(field.get(meta) instanceof DeprecatedObject || field.get(meta) instanceof String)
                flag = true;
            else
                flag = (Boolean)field.get(meta);
            
            key = field.getName().toString().replace("_", "");

          } catch (IllegalAccessException ex) {
            throw new BuildException(ex);
          }

          if (flag != null && flag)
              tags += "<span class='" + key.toLowerCase() + "'>" + key.toUpperCase() + "</span>";
        }
        
        tags += "</span>";
                
        return tags;
    }
    
    private String renderDeprecated (String tagname, DeprecatedObject deprecated) {
        String dep = "<div class='rounded-box deprecated-box deprecated-tag-box'>\n" +
                         "<p>This " + tagname + " has been <strong>deprected</strong> since " + deprecated.version + "</p>\n" +
                         deprecated.text + "\n" +
                     "</div>";
        return dep;
    }
    
    private String renderInternal (String internal) {
        String dep = "<div class='rounded-box private-box'>\n" +
                         "<p><strong>NOTE:</strong> " + internal + "</p>\n" +
                     "</div>";
        return dep;
    }
    
    private String renderLink (String link) {
        return "<a href='#!/api/" + link + "' rel='" + link + "' class='docClass'>" + link + "</a>";
    }
    
    private String stripHtmlTags(String doc) {
        
        doc = doc.replaceAll("<[^>]*>", "");
        
        return doc;

    }
}
