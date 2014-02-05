package eu.rssw.pct.prolint;

import java.io.File;

import org.prorefactor.treeparser.ParseUnit;

public interface ILintRule {
    public String getRuleName();
    public int getSeverity();
    public String getDescription();
    public String getCategory();

    public void execute(ParseUnit topNode, File xrefFile, ILintCallback callback);
}
