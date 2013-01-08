package eu.rssw.pct.oedoc;

import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;


@XmlRootElement
public class Event {
    public Event() {
    }

    @XmlAttribute
    public String eventName, signature, delegateName = null;
    @XmlAttribute
    public AccessModifier modifier;
    @XmlAttribute
    public boolean isStatic, isAbstract;
    public String eventComment;
    @XmlElement(name = "parameter")
    public List<Parameter> parameters = new ArrayList<Parameter>();
}