package eu.rssw.pct.prolint;

import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

public class XMLLintCallback implements ILintCallback {
    private File output;
    private List /*<LintWarning>*/ warnings = new ArrayList /*<LintWarning>*/ ();

    public XMLLintCallback(File file) {
        this.output = file;
    }

    public void publishWarning(LintWarning warning) {
        warnings.add(warning);
    }

    public void initialize() {

    }

    public void terminate() {

        try {
            DocumentBuilder DOC_BUILDER = DocumentBuilderFactory.newInstance().newDocumentBuilder();
            DOMImplementation DOM_IMPL = DOC_BUILDER.getDOMImplementation();
            Transformer UTF8_SERIALIZER = TransformerFactory.newInstance().newTransformer();
            UTF8_SERIALIZER.setOutputProperty(OutputKeys.ENCODING, "utf-8");
            UTF8_SERIALIZER.setOutputProperty(OutputKeys.INDENT, "yes");

            Document doc = DOM_IMPL.createDocument(null, "lint", null);
            Element root = doc.getDocumentElement();

            for (Iterator iter = warnings.iterator(); iter.hasNext();) {
                LintWarning warning = (LintWarning) iter.next();
                Element w = doc.createElement("warning");
                w.setAttribute("rule", warning.getRule());
                w.setAttribute("category", warning.getCategory());
                w.setAttribute("severity", Integer.toString(warning.getSeverity()));
                w.setAttribute("file", warning.getFile().getAbsolutePath());
                w.setAttribute("line", Integer.toString(warning.getLine()));
                w.setAttribute("column", Integer.toString(warning.getCol()));
                w.setAttribute("message", warning.getMsg());
                if ((warning.getEndLine() != 0) && (warning.getEndCol() != 0)) {
                    w.setAttribute("endline", Integer.toString(warning.getEndLine()));
                    w.setAttribute("endcolumn", Integer.toString(warning.getEndCol()));
                }
                root.appendChild(w);
            }

            UTF8_SERIALIZER.transform(new DOMSource(doc), new StreamResult(output));
        } catch (ParserConfigurationException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (TransformerConfigurationException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (TransformerFactoryConfigurationError e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (TransformerException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

    }
}
