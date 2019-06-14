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

public class Member {
    @Expose
    public String id;

    @Expose
    public String name;

    @Expose
    public String owner;

    @Expose
    public String tagname;

    @Expose
    public String datatype;

    @Expose
    public String definition;

    @Expose
    public String comment;

    @Expose
    public List<Parameter> parameters;

    @Expose
    public Return returns;

    @Expose
    public Meta meta = new Meta();

    public Member() {
        // No-op
    }

    public Member(Member clone) {
        this.id = clone.id;
        this.name = clone.name;
        this.owner = clone.owner;
        this.tagname = clone.tagname;
        this.datatype = clone.datatype;
        this.definition = clone.definition;
        this.comment = clone.comment;
        this.parameters = clone.parameters;
        this.returns = clone.returns;
        this.meta = clone.meta;
    }

}
