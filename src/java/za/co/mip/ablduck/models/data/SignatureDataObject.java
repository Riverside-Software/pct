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
package za.co.mip.ablduck.models.data;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class SignatureDataObject {

    @Expose
    @SerializedName("long")
    public String longName = "";

    @Expose
    @SerializedName("short")
    public String shortName = "";

    @Expose
    public String tagname = "";

    public SignatureDataObject(String l, String s, String t) {
        this.longName = l;
        this.shortName = s;
        this.tagname = t;
    }
}
