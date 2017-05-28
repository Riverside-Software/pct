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
import java.util.ArrayList;
import java.lang.Object;

import com.google.gson.annotations.SerializedName;
import com.google.gson.annotations.Expose;


public class DataJSObject {
	//Empty for now
	@Expose
	List<String> guides = new ArrayList<String>();
	@Expose
	List<String> videos = new ArrayList<String>();
	@Expose
	List<String> examples = new ArrayList<String>();
	@Expose
	Object guideSearch = new Object();

	//Implemented
	@Expose
	String localStorageDb = "docs";

	@Expose
	String commentsUrl = "";

	@Expose
	String commentsDomain = "";

	@Expose
	String message = "";

	@Expose
	Boolean tests = false;

	@Expose
	Boolean showPrintButton = true;

	@Expose
	Boolean touchExamplesUi = false; //TODO: Need to remove this

	@Expose
	Boolean source = false;

	@Expose
	List<ClassDataObject> classes = new ArrayList<ClassDataObject>();

	@Expose
	List<SearchDataObject> search = new ArrayList<SearchDataObject>();

	@Expose
	List<SignatureDataObject> signatures = new ArrayList<SignatureDataObject>();

	@Expose
	List<MemberTypeDataObject> memberTypes = new ArrayList<MemberTypeDataObject>();

	public DataJSObject() {
        signatures.add(new SignatureDataObject("internal","INT","internal"));
        signatures.add(new SignatureDataObject("abstract","ABS","abstract"));
        signatures.add(new SignatureDataObject("deprecated","DEP","deprecated"));
        signatures.add(new SignatureDataObject("experimental","EXP","experimental"));
        signatures.add(new SignatureDataObject("private","PRI","private"));
        signatures.add(new SignatureDataObject("protected","PRO","protected"));
        signatures.add(new SignatureDataObject("readonly","R O","readonly"));
        signatures.add(new SignatureDataObject("removed","REM","removed"));
        signatures.add(new SignatureDataObject("required","REQ","required"));
        signatures.add(new SignatureDataObject("static","STA","static"));

        MemberTypeDataObject memberType;
        SubsectionDataObject subsection;

        // Property Member Type
        memberType = new MemberTypeDataObject();
        memberType.name = "property";
        memberType.title = "Properties";
        memberType.icon = "icons/property.png";
        memberType.position = 1;
        
        subsection = new SubsectionDataObject();
        subsection.title = "Instance properties";
        subsection.default_ = true;
        subsection.filter.static_ = false;

        memberType.subsections.add(subsection);

        subsection = new SubsectionDataObject();
        subsection.title = "Static properties";
        subsection.filter.static_ = true;

        memberType.subsections.add(subsection);

        memberTypes.add(memberType);

        // Method Member Type
        memberType = new MemberTypeDataObject();
        memberType.name = "method";
        memberType.title = "Methods";
        memberType.icon = "icons/method.png";
        memberType.position = 2;
        
        subsection = new SubsectionDataObject();
        subsection.title = "Instance methods";
        subsection.default_ = true;
        subsection.filter.static_ = false;

        memberType.subsections.add(subsection);

        subsection = new SubsectionDataObject();
        subsection.title = "Static methods";
        subsection.filter.static_ = true;

        memberType.subsections.add(subsection);

        memberTypes.add(memberType);

        // Event Member Type
        memberType = new MemberTypeDataObject();
        memberType.name = "event";
        memberType.title = "Events";
        memberType.icon = "icons/event.png";
        memberType.position = 3;
        
        memberType.subsections = null;

        memberTypes.add(memberType);

    }
}