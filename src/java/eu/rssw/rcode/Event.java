/**
 * Copyright 2011-2019 Riverside Software
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
package eu.rssw.rcode;

import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement
public class Event {
    @XmlAttribute
    public String eventName;
    @XmlAttribute
    public String signature;
    @XmlAttribute
    public String delegateName;

    @XmlAttribute
    public AccessModifier modifier;
    @XmlAttribute
    public boolean isStatic;
    @XmlAttribute
    public boolean isAbstract;
    @XmlAttribute
    public boolean isOverride;
    @XmlAttribute
    public String eventComment;

    @XmlElement(name = "parameter")
    public List<Parameter> parameters = new ArrayList<>();
}
