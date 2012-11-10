package eu.rssw.pct.oedoc;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "unit", namespace = "")
public class ClassCompilationUnit {
    @XmlAttribute
    public String packageName, className, inherits;
    @XmlElement
    public List<String> interfaces = new ArrayList<String>();
    @XmlAttribute
    public boolean isAbstract, isFinal, isInterface;

    @XmlElement(name = "classComment")
    public List<String> classComment = new ArrayList<String>();
    @XmlElement(name = "constructor")
    public List<Constructor> constructors = new ArrayList<Constructor>();
    @XmlElement(name = "method")
    public List<Method> methods = new ArrayList<Method>();
    @XmlElement(name = "property")
    public List<Property> properties = new ArrayList<Property>();
    @XmlElement(name = "event")
    public List<Event> events = new ArrayList<Event>();
    @XmlElement(name = "using")
    public List<Using> usings = new ArrayList<Using>();

    public void classToXML(File out) throws JAXBException, IOException {
        JAXBContext context = JAXBContext.newInstance(this.getClass().getPackage().getName());
        Marshaller marshaller = context.createMarshaller();
        marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, Boolean.TRUE);
        marshaller.marshal(this, new FileOutputStream(out));
    }

    
    @SuppressWarnings("unused")
    private static Comment parseComments(String comments) {
        Comment comm = new Comment();
        comments = comments.trim();
        if (comments.startsWith("/*"))
            comments = comments.substring(2);
        else
            return null;
        StringTokenizer st = new StringTokenizer(comments, "\n");
        String str = null;
        String zz = "";
        while (st.hasMoreTokens()) {
            str = st.nextToken().trim();
            if (str.charAt(0) == '*')
                str = str.substring(1).trim();
            if (str.startsWith("@param")) {
                int idx1 = str.indexOf(' ');
                if (idx1 > 0) {
                    String str2 = str.substring(idx1).trim();
                    int idx2 = str2.indexOf(' ');
                    if (idx2 > 0) {
                        comm.parameters.put(str2.substring(0, idx2), str2.substring(idx2).trim());
                    }
                }
            } else if (str.startsWith("@return")) {
                comm.returnValue = str.substring(7).trim();
            } else {
                if ((str.length() == 0) && (zz.length() > 0)) {
                    comm.comment.add(zz);
                    zz = "";
                } else if (str.length() > 0) {
                    zz = zz + " " + str;
                }
            }

        }
        if (zz.length() > 0) {
            comm.comment.add(zz);
        }
        return comm;
    }
}
