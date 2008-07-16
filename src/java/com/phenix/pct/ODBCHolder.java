package com.phenix.pct;

import java.util.Collection;
import java.util.Vector;

public class ODBCHolder extends SchemaHolder {
    private String user;
    private String password;
    
    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getUser() {
        return user;
    }

    public void setUser(String user) {
        this.user = user;
    }

    public boolean validate() {
        return true;
    }

    public Collection getParameters() {
        Collection c = new Vector();
        c.add(new RunParameter("SchemaHolderName", this.getDbName()));
        c.add(new RunParameter("Collation", this.getCollation()));
        c.add(new RunParameter("Codepage", this.getCodepage()));
        c.add(new RunParameter("UserName", this.getUsername()));
        c.add(new RunParameter("Password", this.getPassword()));

        return c;
    }

    public String getProcedure() {
        return "pct/mssHolder.p";
    }
}
