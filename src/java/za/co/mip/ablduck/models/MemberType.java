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

import com.google.gson.annotations.Expose;

public class MemberType {
    @Expose
    public String name = "";

    @Expose
    public String title = "";

    @Expose
    public String icon = "";

    @Expose
    public Integer position = 0;

    public MemberType(String name, String title, String icon, Integer position) {
        this.name = name;
        this.title = title;
        this.icon = icon;
        this.position = position;
    }
}
