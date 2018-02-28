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
package za.co.mip.ablduck.models;

import java.util.List;
import java.util.ArrayList;

import com.google.gson.annotations.SerializedName;

import eu.rssw.rcode.Using;
import za.co.mip.ablduck.models.generic.MetaObject;
import za.co.mip.ablduck.models.source.MemberObject;

import com.google.gson.annotations.Expose;

public class SourceJSObject {
    // Not used need to remove dep in web app
    @Expose
    List<String> mixedInto = new ArrayList<>();
    @Expose
    List<String> parentMixins = new ArrayList<>();
    @Expose
    List<String> files = new ArrayList<>();
    @Expose
    List<String> alternateClassNames = new ArrayList<>();
    @Expose
    List<String> mixins = new ArrayList<>();
    @Expose
    List<String> requires = new ArrayList<>();
    @Expose
    List<String> uses = new ArrayList<>();
    @Expose
    Object aliases = new Object();

    // Actual js object properties
    @Expose
    public String id = "";

    @Expose
    public String tagname = "";

    @Expose
    public String name = "";

    // extends is a reserved word
    @Expose
    @SerializedName("extends")
    public String ext = "";

    @Expose
    public String author = "";

    @Expose
    public String shortDoc = "";

    @Expose
    public String html = "";

    @Expose
    public String classIcon = "";

    @Expose
    public List<MemberObject> members = new ArrayList<>();

    @Expose
    public List<String> superclasses = new ArrayList<>();

    @Expose
    public List<String> subclasses = new ArrayList<>();

    @Expose
    public MetaObject meta = new MetaObject();

    // Internal Use
    @Expose(serialize = false)
    public String comment = "";

    @Expose(serialize = false)
    public String shortname = "";
    
    @Expose(serialize = false)
    public boolean isInterface = false;

    @Expose(serialize = false)
    public List<String> interfaces = new ArrayList<>();
    
    @Expose(serialize = false)
    public List<String> implementers = new ArrayList<>();
    
    @Expose(serialize = false)
    public List<Using> using = new ArrayList<>();
}
