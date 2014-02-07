package eu.rssw.pct.prolint;

public interface ILintCallback {
    public void initialize();
    public void publishWarning(LintWarning str);
    public void terminate();
}
