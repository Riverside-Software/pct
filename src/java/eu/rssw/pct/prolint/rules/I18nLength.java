package eu.rssw.pct.prolint.rules;

import java.io.File;

import org.prorefactor.core.JPNode;
import org.prorefactor.treeparser.ParseUnit;

import com.joanju.proparse.Environment;
import com.joanju.proparse.NodeTypes;

import eu.rssw.pct.prolint.AbstractLintRule;
import eu.rssw.pct.prolint.ILintCallback;
import eu.rssw.pct.prolint.LintWarning;

public class I18nLength extends AbstractLintRule{

    public I18nLength() {
        super("i18nlength", "i18n", 1, "LENGTH function called without TYPE parameter");
    }

    public void execute(ParseUnit unit, File xref, ILintCallback callback) {
        for (JPNode node : unit.getTopNode().query(NodeTypes.SUBSTRING)) {
            int zz2 = node.getDirectChildrenArray().length;
            if ((zz2 >= 5) && (zz2 <= 8)) {
                LintWarning warning = new LintWarning(getRuleName(), getCategory(), getSeverity(), new File(node.getFilename()));
                warning.setLine(node.getLine());
                warning.setCol(node.getColumn());
                JPNode endNode = node.getDirectChildrenArray()[zz2 - 1];
                warning.setEndLine(endNode.getLine());
                warning.setEndCol(endNode.getColumn());
                warning.setMsg("SUBSTRING function called without TYPE parameter");
                callback.publishWarning(warning);
            }
        }
        
        for (JPNode node : unit.getTopNode().query(NodeTypes.OVERLAY)) {
            int zz2 = node.getDirectChildrenArray().length;
            if ((zz2 >= 5) && (zz2 <= 8)) {
                LintWarning warning = new LintWarning(getRuleName(), getCategory(), getSeverity(), new File(node.getFilename()));
                warning.setLine(node.getLine());
                warning.setCol(node.getColumn());
                JPNode endNode = node.getDirectChildrenArray()[zz2 - 1];
                warning.setEndLine(endNode.getLine());
                warning.setEndCol(endNode.getColumn());
                warning.setMsg("OVERLAY function called without TYPE parameter");
                callback.publishWarning(warning);
            }
        }

        for (JPNode node : unit.getTopNode().query(NodeTypes.LENGTH)) {
            int zz2 = node.getDirectChildrenArray().length;
            if (zz2 < 5) {
                LintWarning warning = new LintWarning(getRuleName(), getCategory(), getSeverity(), new File(node.getFilename()));
                warning.setLine(node.getLine());
                warning.setCol(node.getColumn());
                JPNode endNode = node.getDirectChildrenArray()[zz2 - 1];
                warning.setEndLine(endNode.getLine());
                warning.setEndCol(endNode.getColumn());
                warning.setMsg("LENGTH function called without TYPE parameter");
                callback.publishWarning(warning);
            }
        }

    }
    
    public static void main(String[] args) throws Throwable {
        Environment env = Environment.instance();

        env.configSet("batch-mode", "true");
        env.configSet("opsys", "WIN32");
        env.configSet("proversion", "11.0");
        env.configSet("window-system", "TTY");

        ParseUnit unit = new ParseUnit(new File("test.p"));
        unit.treeParser01();
        
        for (JPNode node : unit.getTopNode().query(NodeTypes.PROCEDURE)) {
            System.out.println("PROCEDURE " + node.getText());
            System.out.println("Comments : " + node.getComments());    
        }
        
        
    }
}
