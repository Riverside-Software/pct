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
public class TempTable {
    @XmlAttribute
    public String name;
    @XmlAttribute
    public String like;
    @XmlAttribute
    public String definition;
    @XmlAttribute
    public boolean noUndo;
    @XmlAttribute
    public boolean isNew;
    @XmlAttribute
    public boolean isGlobal;
    @XmlAttribute
    public boolean isShared;
    @XmlAttribute
    public String beforeTable;
    @XmlAttribute
    public String xmlNodeName;
    @XmlAttribute
    public String serialize;

    @XmlAttribute
    public AccessModifier modifier;

    @XmlElement(name = "text")
    public String aceText;

    @XmlElement(name = "ttComment")
    public String comment;
    @XmlElement(name = "field")
    public List<TableField> fields = new ArrayList<>();
    @XmlElement(name = "index")
    public List<TableIndex> indexes = new ArrayList<>();

    public void computeText() {
        StringBuilder sb = new StringBuilder("DEFINE TEMP-TABLE ");
        sb.append(name).append(' ');
        if (like != null) {
            sb.append("LIKE ").append(like).append(' ');
        }
        if (noUndo) {
            sb.append("NO-UNDO ");
        }
        if ((beforeTable != null) && !beforeTable.isEmpty()) {
            sb.append("BEFORE-TABLE " + beforeTable + " ");
        }
        if ((xmlNodeName != null) && !xmlNodeName.isEmpty()) {
            sb.append("XML-NODE-NAME '" + xmlNodeName + "' ");
        }
        if ((serialize != null) && !serialize.isEmpty()) {
            sb.append("SERIALIZE-NAME '" + serialize + "' ");
        }
        sb.append('\n');
        for (TableField fld : fields) {
            sb.append("  FIELD ").append(fld.name).append(" AS ").append(fld.dataType);
            if (fld.initialValue != null)
                sb.append(" INITIAL ").append(fld.initialValue);
            sb.append('\n');
        }
        for (TableIndex idx : indexes) {
            sb.append("  INDEX ").append(idx.name);
            if (idx.primary)
                sb.append(" PRIMARY");
            if (idx.unique)
                sb.append(" UNIQUE");
            if (idx.wordIndex)
                sb.append(" WORD-INDEX");
            for (String str : idx.fields) {
                sb.append(' ').append(str);
            }
            sb.append('\n');
        }
        aceText = sb.toString();
    }

}
