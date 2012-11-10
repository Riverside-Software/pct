package eu.rssw.pct.oedoc;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "procedure", namespace = "")
public class ProcedureCompilationUnit {
    @XmlElement(name = "parameter")
    public List<Parameter> parameters = new ArrayList<Parameter>();
    @XmlElement(name = "comment")
    public List<String> procComment = new ArrayList<String>();
    @XmlElement(name = "procedure")
    public List<Procedure> procedures = new ArrayList<Procedure>();

    public void toXML(File out) throws JAXBException, IOException {
        JAXBContext context = JAXBContext.newInstance(this.getClass().getPackage().getName());
        Marshaller marshaller = context.createMarshaller();
        marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, Boolean.TRUE);
        marshaller.marshal(this, new FileOutputStream(out));
    }

    @XmlRootElement(name = "comment")
    public static class Comment {
        public List<String> comment = new ArrayList<String>();
        public Map<String, String> parameters = new HashMap<String, String>();
        public String returnValue = "";
        public Comment() {
        }
    }
}
