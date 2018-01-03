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

import com.google.gson.annotations.Expose;

import za.co.mip.ablduck.models.data.ClassDataObject;
import za.co.mip.ablduck.models.data.MemberTypeDataObject;
import za.co.mip.ablduck.models.data.SearchDataObject;
import za.co.mip.ablduck.models.data.SignatureDataObject;

public class DataJSObject {
    // Empty for now
    @Expose
    public List<String> guides = new ArrayList<>();
    @Expose
    public List<String> videos = new ArrayList<>();
    @Expose
    public List<String> examples = new ArrayList<>();
    @Expose
    public Object guideSearch = new Object();

    // Implemented
    @Expose
    public String localStorageDb = "docs";

    @Expose
    public String commentsUrl = "";

    @Expose
    public String commentsDomain = "";

    @Expose
    public String message = "";

    @Expose
    public Boolean tests = false;

    @Expose
    public Boolean showPrintButton = true;

    @Expose
    public Boolean touchExamplesUi = false;

    @Expose
    public Boolean source = false;

    @Expose
    public List<ClassDataObject> classes = new ArrayList<>();

    @Expose
    public List<SearchDataObject> search = new ArrayList<>();

    @Expose
    public List<SignatureDataObject> signatures = new ArrayList<>();

    @Expose
    public List<MemberTypeDataObject> memberTypes = new ArrayList<>();

    public DataJSObject() {
        signatures.add(new SignatureDataObject("internal", "INT", "internal"));
        signatures.add(new SignatureDataObject("abstract", "ABS", "abstract"));
        signatures.add(new SignatureDataObject("deprecated", "DEP", "deprecated"));
        signatures.add(new SignatureDataObject("experimental", "EXP", "experimental"));
        signatures.add(new SignatureDataObject("private", "PRI", "private"));
        signatures.add(new SignatureDataObject("protected", "PRO", "protected"));
        signatures.add(new SignatureDataObject("readonly", "R O", "readonly"));
        signatures.add(new SignatureDataObject("removed", "REM", "removed"));
        signatures.add(new SignatureDataObject("required", "REQ", "required"));
        signatures.add(new SignatureDataObject("static", "STA", "static"));

        MemberTypeDataObject memberType;
        
        // Constructor Member Type
        memberType = new MemberTypeDataObject();
        memberType.name = "constructor";
        memberType.title = "Constructors";
        memberType.icon = "icons/event.png";
        memberType.position = 1;

        memberType.subsections = null;

        memberTypes.add(memberType);

        // Property Member Type
        memberType = new MemberTypeDataObject();
        memberType.name = "property";
        memberType.title = "Properties";
        memberType.icon = "icons/property.png";
        memberType.position = 2;

        memberTypes.add(memberType);

        // Method Member Type
        memberType = new MemberTypeDataObject();
        memberType.name = "method";
        memberType.title = "Methods";
        memberType.icon = "icons/method.png";
        memberType.position = 3;

        memberTypes.add(memberType);

        // Event Member Type
        memberType = new MemberTypeDataObject();
        memberType.name = "event";
        memberType.title = "Events";
        memberType.icon = "icons/event.png";
        memberType.position = 4;

        memberType.subsections = null;

        memberTypes.add(memberType);
    }
}
