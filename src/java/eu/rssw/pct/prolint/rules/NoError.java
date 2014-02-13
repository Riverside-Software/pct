package eu.rssw.pct.prolint.rules;

import java.io.File;
import java.util.List;

import org.prorefactor.core.JPNode;
import org.prorefactor.treeparser.ParseUnit;

import com.joanju.proparse.NodeTypes;

import eu.rssw.pct.prolint.AbstractLintRule;
import eu.rssw.pct.prolint.ILintCallback;
import eu.rssw.pct.prolint.LintWarning;

public class NoError extends AbstractLintRule {

    public NoError() {
        super("noerror", "Bug", 9, "Check that no-error is used for find statements");
    }

    public void execute(ParseUnit unit, File xref, ILintCallback callback) {
        for (JPNode node : unit.getTopNode().query(NodeTypes.FIND)) {
            for (JPNode node2 : node.query(NodeTypes.RECORD_NAME)) {
                List<JPNode> list3 = node2.query(NodeTypes.NOERROR_KW);
                if (list3.size() == 0) {
                    LintWarning warning = new LintWarning(getRuleName(), getCategory(),
                            getSeverity(), new File(node.getFilename()));
                    warning.setLine(node.getLine());
                    warning.setCol(node.getColumn());
                    warning.setMsg("Find with no-error");
                    callback.publishWarning(warning);
                }
            }
        }

    }

}
