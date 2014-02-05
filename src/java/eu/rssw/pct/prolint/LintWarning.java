package eu.rssw.pct.prolint;

import java.io.File;

public class LintWarning {
    private File file;
    private int line, col;
    private int endLine, endCol;

    private String rule, category;
    private int severity;
    private String msg;

    public LintWarning(String rule, String category, int severity, File file) {
        this.file = file;
        this.rule = rule;
        this.severity = severity;
        this.category = category;
    }

    public void setLine(int line) {
        this.line = line;
    }

    public void setCol(int col) {
        this.col = col;
    }

    public int getCol() {
        return col;
    }

    public int getLine() {
        return line;
    }

    public File getFile() {
        return file;
    }

    public String getRule() {
        return rule;
    }

    public int getSeverity() {
        return severity;
    }

    public void setEndLine(int endLine) {
        this.endLine = endLine;
    }

    public void setEndCol(int endCol) {
        this.endCol = endCol;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    public int getEndCol() {
        return endCol;
    }

    public int getEndLine() {
        return endLine;
    }
    
    public String getMsg() {
        return msg;
    }

    public String getCategory() {
        return category;
    }
}
