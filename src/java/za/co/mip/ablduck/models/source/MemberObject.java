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
package za.co.mip.ablduck.models.source;

import java.util.List;

import com.google.gson.annotations.Expose;

import za.co.mip.ablduck.models.generic.MetaObject;

public class MemberObject {
    @Expose
    public String id = "";

    @Expose
    public String name = "";

    @Expose
    public String owner = "";

    @Expose
    public String tagname = "";

    @Expose
    public String datatype = null;

    @Expose
    public String signature = null;

    @Expose
    public String returnComment = null;

    @Expose
    public MetaObject meta = new MetaObject();

    // Internal Use
    @Expose(serialize = false)
    public String comment = "";

    @Expose(serialize = false)
    public List<ParameterObject> parameters = null;
}
