package eu.rssw.pct.oedoc;

import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;


@XmlRootElement
public class Constructor {
    public Constructor() {
    }
    @XmlAttribute
    public String signature;
    @XmlAttribute
    public AccessModifier modifier;
    public String constrComment;
    @XmlElement(name = "parameter")
    public List<Parameter> parameters = new ArrayList<Parameter>();
}