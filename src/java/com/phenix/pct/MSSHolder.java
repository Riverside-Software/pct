package com.phenix.pct;

import java.util.ArrayList;
import java.util.Collection;

public class MSSHolder extends SchemaHolder {
    public boolean caseSensitive;

    public boolean validate() {
        return true;
    }

    public Collection getParameters() {
        Collection c = new ArrayList();
        c.add(new RunParameter("SchemaHolderName", this.getDbName()));
        c.add(new RunParameter("Collation", this.getCollation()));
        c.add(new RunParameter("Codepage", this.getCodepage()));
        c.add(new RunParameter("CaseSensitive", Boolean.toString(this.caseSensitive)));
        c.add(new RunParameter("UserName", this.getUsername()));
        c.add(new RunParameter("Password", this.getPassword()));

        return c;
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
