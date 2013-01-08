package eu.rssw.pct.oedoc;

import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlRootElement;


@XmlRootElement
public class Using {
    public Using() {
    }

    @XmlAttribute
    public String name;
    @XmlAttribute
    public UsingType type;
}