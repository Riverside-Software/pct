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

import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement
public class Property {
    @XmlAttribute
    public String name;
    @XmlAttribute
    public String dataType;
    @XmlAttribute
    public boolean isAbstract;
    @XmlAttribute
    public boolean isStatic;
    @XmlAttribute
    public boolean isOverride;
    @XmlAttribute
    public int extent;
    @XmlAttribute
    public AccessModifier modifier;
    @XmlAttribute
    public GetSetModifier getModifier = GetSetModifier.NONE;
    @XmlAttribute
    public GetSetModifier setModifier = GetSetModifier.NONE;
    @XmlElement(name = "propertyComment")
    public String propertyComment;

}
