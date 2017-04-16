/**
 * Copyright 2011-2016 Riverside Software
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

    @XmlElement(name = "text")
    public String aceText;

    @XmlElement(name = "dsComment")
    public String comment;
    @XmlElement(name = "field")
    public List<String> buffers = new ArrayList<>();

    public void computeText() {
        StringBuilder sb = new StringBuilder("DEFINE DATASET ");
        sb.append(name).append(' ');
        sb.append('\n').append(" FOR ");
        boolean frst = true;
        for (String str : buffers) {
            if (!frst) {
                sb.append(',');
                frst = false;
            }
            sb.append(str);
        }
        sb.append('\n');
        aceText = sb.toString();
    }

}
