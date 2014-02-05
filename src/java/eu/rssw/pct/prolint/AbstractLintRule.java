package eu.rssw.pct.prolint;

public abstract class AbstractLintRule implements ILintRule {
    private final String name, category, description;
    private final int severity;
    
    public AbstractLintRule(String name, String category, int severity, String description) {
        this.name = name;
        this.category = category;
        this.severity = severity;
        this.description = description;
    }

    public String getRuleName() {
        return name;
    }

    public int getSeverity() {
        return severity;
    }

    public String getCategory() {
        return category;
    }

    public String getDescription() {
        return description;
    }
}
