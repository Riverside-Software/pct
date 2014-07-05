package eu.rssw.pct.prolint.rules;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.prorefactor.treeparser.ParseUnit;

import eu.rssw.pct.prolint.AbstractLintRule;
import eu.rssw.pct.prolint.ILintCallback;
import eu.rssw.pct.prolint.LintWarning;

public class WholeIndex extends AbstractLintRule {
    private Pattern pattern;

    public WholeIndex() {
        super("wholeindex", "Performance", 9, "WHOLE-INDEX found in xref");
        pattern = Pattern
                .compile("^\\S+\\s(\\S+)\\s(\\d+)\\sSEARCH\\s([\\.\\w]+)\\s([\\.\\w]+)\\sWHOLE-INDEX$");
    }

    public void execute(ParseUnit unit, File xref, ILintCallback callback) {
        if ((xref == null) || (!xref.exists()))
            return;

        try {
            BufferedReader reader = new BufferedReader(new FileReader(xref));
            String str = reader.readLine();
            while (str != null) {
                Matcher m = pattern.matcher(str);
                if (m.matches()) {
                    LintWarning warning = new LintWarning(getRuleName(), getCategory(), getSeverity(), new File(
                            m.group(1)));
                    warning.setLine(Integer.parseInt(m.group(2)));
                    warning.setMsg("WHOLE-INDEX on " + m.group(3));
                    callback.publishWarning(warning);
                }
                str = reader.readLine();
            }
            reader.close();
        } catch (IOException caught) {

        }
    }

}
