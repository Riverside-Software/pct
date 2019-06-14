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
package za.co.mip.ablduck;

import java.util.List;

import za.co.mip.ablduck.models.Member;

import java.util.ArrayList;

public class HierarchyResult {
    private List<String> hierarchy = new ArrayList<>();
    private List<Member> inheritedmembers = new ArrayList<>();

    public List<String> getHierarchy() {
        return this.hierarchy;
    }

    public void addHierarchy(String h) {
        this.hierarchy.add(h);
    }

    public List<Member> getInheritedmembers() {
        return this.inheritedmembers;
    }

    public void addInheritedmember(Member member) {
        this.inheritedmembers.add(member);
    }
}
