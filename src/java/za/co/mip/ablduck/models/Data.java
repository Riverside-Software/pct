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

import java.util.ArrayList;
import java.util.List;

import com.google.gson.annotations.Expose;

public class Data {
    @Expose
    public List<String> guides = new ArrayList<>();

    @Expose
    public List<String> videos = new ArrayList<>();

    @Expose
    public List<String> examples = new ArrayList<>();

    @Expose
    public Object guideSearch = new Object();

    @Expose
    public String localStorageDb = "docs";

    @Expose
    public String message = "";

    @Expose
    public Boolean tests = false;

    @Expose
    public Boolean showPrintButton = false;

    @Expose
    public Boolean source = false;

    @Expose
    public List<Cls> classes = new ArrayList<>();

    @Expose
    public List<Procedure> procedures = new ArrayList<>();

    @Expose
    public List<Search> search = new ArrayList<>();

    @Expose
    public List<Signature> signatures = new ArrayList<>();

    @Expose
    public List<MemberType> memberTypes = new ArrayList<>();

    public Data() {
        signatures.add(new Signature("private", "PRI"));
        signatures.add(new Signature("protected", "PRO"));
        signatures.add(new Signature("static", "STA"));
        signatures.add(new Signature("abstract", "ABS"));
        signatures.add(new Signature("override", "OVR"));
        signatures.add(new Signature("final", "FIN"));
        signatures.add(new Signature("super", "SUP"));
        signatures.add(new Signature("new", "NEW"));
        signatures.add(new Signature("global", "GLO"));
        signatures.add(new Signature("shared", "SHA"));
        signatures.add(new Signature("noundo", "N-U"));
        signatures.add(new Signature("internal", "INT"));
        signatures.add(new Signature("deprecated", "DEP"));

        memberTypes.add(new MemberType("constructor", "Constructors", "icons/event.png", 1));
        memberTypes.add(new MemberType("destructor", "Destructors", "icons/event.png", 2));
        memberTypes.add(new MemberType("event", "Events", "icons/event.png", 3));
        memberTypes.add(new MemberType("property", "Properties", "icons/property.png", 4));
        memberTypes.add(new MemberType("method", "Methods", "icons/method.png", 5));
        memberTypes.add(new MemberType("procedure", "Procedures", "icons/method.png", 6));
        memberTypes.add(new MemberType("function", "Functions", "icons/method.png", 7));
        memberTypes.add(new MemberType("temptable", "Temp Tables", "icons/property.png", 8));
        memberTypes.add(new MemberType("dataset", "Datasets", "icons/property.png", 9));
    }
}
