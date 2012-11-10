package eu.rssw.pct.oedoc;

import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement
public class Procedure {
    public Procedure() {
    }

    @XmlAttribute
    public String procedureName, signature;
    public AccessModifier modifier;
    @XmlElement(name = "comment")
    public String procedureComment;
    @XmlElement(name = "parameter")
    public List<Parameter> parameters = new ArrayList<Parameter>();
}