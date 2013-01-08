package eu.rssw.pct.oedoc;

import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlRootElement;


@XmlRootElement
public class Parameter {
    public Parameter() {
    }

    @XmlAttribute
    public String name, dataType;
    @XmlAttribute
    public int position;
    @XmlAttribute
    public ParameterMode mode;
}