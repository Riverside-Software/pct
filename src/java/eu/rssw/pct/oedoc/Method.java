package eu.rssw.pct.oedoc;

import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;


@XmlRootElement
public class Method {
    public Method() {
    }

    @XmlAttribute
    public String methodName, returnType, signature;
    @XmlAttribute
    public AccessModifier modifier;
    @XmlElement(name = "comment")
    public String methodComment;
    @XmlAttribute
    public boolean isStatic;
    @XmlElement(name = "parameter")
    public List<Parameter> parameters = new ArrayList<Parameter>();
}