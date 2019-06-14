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
public class Dataset {
    @XmlAttribute
    public String name;
    @XmlAttribute
    public String definition;
    @XmlAttribute
    public String xmlNodeName;
    @XmlAttribute
    public String serialize;

    @XmlAttribute
    public boolean isNew;
    @XmlAttribute
    public boolean isShared;

    @XmlElement(name = "text")
    public String aceText;

    @XmlAttribute
    public AccessModifier modifier;

    @XmlElement(name = "dsComment")
    public String comment;
    @XmlElement(name = "buffer")
    public List<String> buffers = new ArrayList<>();

    public void computeText() {
        StringBuilder sb = new StringBuilder("DEFINE DATASET ");
        if ((xmlNodeName != null) && !xmlNodeName.isEmpty()) {
            sb.append("XML-NODE-NAME '" + xmlNodeName + "' ");
        }
        if ((serialize != null) && !serialize.isEmpty()) {
            sb.append("SERIALIZE-NAME '" + serialize + "' ");
        }
        sb.append(name).append(" FOR ");
        boolean frst = true;
        for (String str : buffers) {
            if (frst) {
                frst = false;
            } else {
                sb.append(", ");
            }
            sb.append(str);
        }
        sb.append('\n');
        aceText = sb.toString();
    }

}
