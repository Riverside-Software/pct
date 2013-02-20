package eu.rssw.pct.oedoc;

import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlRootElement;


@XmlRootElement
public class Property {
    public Property() {
    }

    @XmlAttribute
    public String name, dataType;
    @XmlAttribute
    public boolean isAbstract, isStatic;
    @XmlAttribute
    public int extent;
    @XmlAttribute
    public AccessModifier modifier;
    @XmlAttribute
    public GetSetModifier getModifier = GetSetModifier.NONE, setModifier = GetSetModifier.NONE;
    public String propertyComment;
}