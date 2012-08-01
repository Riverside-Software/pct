package eu.rssw.pct.prolint.rules;

import java.io.File;
import java.util.Iterator;
import java.util.List;

import org.prorefactor.core.JPNode;
import org.prorefactor.treeparser.ParseUnit;

import com.joanju.proparse.NodeTypes;

import eu.rssw.pct.prolint.AbstractLintRule;
import eu.rssw.pct.prolint.ILintCallback;
import eu.rssw.pct.prolint.LintWarning;

public class DotComment extends AbstractLintRule {

    public DotComment() {
        super("dotcomment", "Bug", 8, "PERIOD comments a statement");
    }

    public void execute(ParseUnit unit, File xref, ILintCallback callback) {
        List list = unit.getTopNode().query(NodeTypes.DOT_COMMENT);
        for (Iterator iter = list.iterator(); iter.hasNext();) {
            JPNode node = (JPNode) iter.next();
            LintWarning warning = new LintWarning(getRuleName(), getCategory(), getSeverity(), new File(
                    node.getFilename()));
            warning.setLine(node.getLine());
            warning.setCol(node.getColumn());
            warning.setMsg("PERIOD comments a statement");
            callback.publishWarning(warning);
        }
    }
}
