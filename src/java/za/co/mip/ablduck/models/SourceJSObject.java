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

public class SourceJSObject {
	//Not used need to remove dep in web app
	@Expose
	List<String> mixedInto = new ArrayList<String>();
	@Expose
	List<String> parentMixins = new ArrayList<String>();
	@Expose
	List<String> files = new ArrayList<String>();
	@Expose
	List<String> alternateClassNames = new ArrayList<String>();
	@Expose
	List<String> mixins = new ArrayList<String>();
	@Expose
	List<String> requires = new ArrayList<String>();
	@Expose
	List<String> uses = new ArrayList<String>();
	@Expose
	Object aliases = new Object();

	//Actual js object properties
	@Expose
	String id = "";

	@Expose
	String tagname = "";

	@Expose
    String name = "";

    // extends is a reserved word
    @Expose
    @SerializedName("extends")
    String extends_ = "";

    @Expose
    String author = "";

    @Expose
    String shortDoc = "";

    @Expose
    String html = "";

    @Expose
    String classIcon = "";

    @Expose
	List<MemberObject> members = new ArrayList<MemberObject>();

    @Expose
	List<String> superclasses = new ArrayList<String>();

	@Expose
	List<String> subclasses = new ArrayList<String>();

	@Expose
	MetaObject meta = new MetaObject();

    //Internal Use
    @Expose(serialize = false)
    String comment = "";

    @Expose(serialize = false)
    String shortname = "";
}
