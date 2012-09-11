package eu.rssw.pct.oedoc;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "unit", namespace = "")
public class CompilationUnit {
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

    public void toXML(File out) throws JAXBException, IOException {
        JAXBContext context = JAXBContext.newInstance(this.getClass().getPackage().getName());
        Marshaller marshaller = context.createMarshaller();
        marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, Boolean.TRUE);
        marshaller.marshal(this, new FileOutputStream(out));
    }

    @XmlRootElement
    public static class Constructor {
        public Constructor() {
        }
        @XmlAttribute
        public String signature;
        @XmlAttribute
        public AccessModifier modifier;
        @XmlAttribute
        public boolean isAbstract;
        public String constrComment;
        @XmlElement(name = "parameter")
        public List<Parameter> parameters = new ArrayList<Parameter>();
    }

    @XmlRootElement(name = "comment")
    public static class Comment {
        public List comment = new ArrayList();
        public Map parameters = new HashMap();
        public String returnValue = "";
        public Comment() {
        }
    }

    @XmlRootElement
    public static class Method {
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

    @XmlRootElement
    public static class Event {
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

    @XmlRootElement
    public static class Parameter {
        public Parameter() {
        }

        @XmlAttribute
        public String name, dataType;
        @XmlAttribute
        public int position;
        @XmlAttribute
        public ParameterMode mode;
    }

    @XmlRootElement
    public static class Property {
        public Property() {
        }

        @XmlAttribute
        public String name, dataType;
        @XmlAttribute
        public boolean isAbstract;
        @XmlAttribute
        public int extent;
        @XmlAttribute
        public AccessModifier modifier;
        @XmlAttribute
        public GetSetModifier getModifier = GetSetModifier.NONE, setModifier = GetSetModifier.NONE;
        public String propertyComment;
    }

    @XmlRootElement
    public static class Using {
        public Using() {
        }

        @XmlAttribute
        public String name;
        @XmlAttribute
        public UsingType type;
    }

    public static Comment parseComments(String comments) {
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

    @XmlEnum
    public enum AccessModifier {
        PUBLIC, PRIVATE, PROTECTED;

        public static AccessModifier from(int value) {
            if (value == 294)
                return PRIVATE;
            else if (value == 295)
                return PUBLIC;
            else if (value == 296)
                return PROTECTED;
            return null;
        }
    }

    @XmlEnum
    public enum ParameterMode {
        INPUT, OUTPUT, INOUT;

        public static ParameterMode from(int value) {
            if (value == 245)
                return INPUT;
            else if (value == 233)
                return OUTPUT;
            else if (value == 517)
                return INOUT;
            else
                return null;
        }
    }

    @XmlEnum
    public enum UsingType {
        NONE, PROPATH, ASSEMBLY;
    }
    
    public enum GetSetModifier {
        NONE, PUBLIC, PROTECTED, PRIVATE;
        
        public static GetSetModifier from(int value) {
            if (value == 294)
                return PRIVATE;
            else if ((value == 295) || (value == -1) /* No modifier */)
                return PUBLIC;
            else if (value == 296)
                return PROTECTED;
            return null;
        }
        
    }
}
