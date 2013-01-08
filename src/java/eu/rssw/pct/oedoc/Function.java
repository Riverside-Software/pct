package eu.rssw.pct.oedoc;

import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement
public class Function {
    public Function() {
    }

    @XmlAttribute
    public String functionName, signature, returnType;
    @XmlElement(name = "comment")
    public String functionComment;
    @XmlElement(name = "parameter")
    public List<Parameter> parameters = new ArrayList<Parameter>();
}