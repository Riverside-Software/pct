package com.phenix.pct;

public class MSSHolder extends SchemaHolder {
    public boolean caseSensitive;

    public boolean validate() {
        return true;
    }

    public String getParameterString() {
        StringBuffer sb = new StringBuffer();
        sb.append(this.getDbName()).append(';');
        sb.append(this.getCollation()).append(';');
        sb.append((this.caseSensitive ? '1' : '0'));

        return sb.toString();
    }

    public String getProcedure() {
        return "pct/mssHolder.p";
    }

    public boolean isCaseSensitive() {
        return caseSensitive;
    }

    public void setCaseSensitive(boolean caseSensitive) {
        this.caseSensitive = caseSensitive;
    }
}
