package eu.rssw.pct.oedoc;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "comment")
public class Comment {
    public List<String> comment = new ArrayList<String>();
    public Map<String, String> parameters = new HashMap<String, String>();
    public String returnValue = "";
    public Comment() {
    }
}