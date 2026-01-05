/**
 * Copyright 2005-2026 Riverside Software
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
package eu.rssw.openedge.ls.mapping;

import com.google.gson.annotations.SerializedName;

// Simplified JSON mapping of project config file, copied from language server module
public class ProjectConfigFile {

    @SerializedName(value = "dependencies")
    public Dependency[] dependencies;

    public static class Dependency {
        @SerializedName(value = "groupId")
        public String groupId;
        @SerializedName(value = "artifactId")
        public String artifactId;
        @SerializedName(value = "version")
        public String version;
        @SerializedName(value = "classifier")
        public String classifier;
        @SerializedName(value = "extension")
        public String extension;
    }

}
