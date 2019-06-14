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
package za.co.mip.ablduck.models;

import java.util.List;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class CompilationUnit {
    @Expose
    public List<String> files;

    @Expose
    public List<String> uses;

    @Expose
    public String id;

    @Expose
    public String tagname;

    @Expose
    public String name;

    @Expose
    @SerializedName("extends")
    public String inherits;

    @Expose
    public String author;

    @Expose
    public String comment;

    @Expose
    public String icon;

    @Expose
    public List<String> superclasses;

    @Expose
    public List<String> subclasses;

    @Expose
    @SerializedName("implements")
    public List<String> implementations;

    @Expose
    public List<String> implementers;

    @Expose
    public List<Member> members;

    @Expose
    public List<Parameter> parameters;

    @Expose
    public Meta meta = new Meta();
}
