package com.phenix.pct;

import java.util.Collection;
import java.util.Vector;

public class OracleHolder extends SchemaHolder {
    private int oracleVersion;
    
    public int getOracleVersion() {
        return oracleVersion;
    }

    public void setOracleVersion(int oracleVersion) {
        this.oracleVersion = oracleVersion;
    }
    
    public boolean validate() {
        return (this.getDbName() != null);
    }

    public Collection getParameters() {
        Collection c = new Vector();
        c.add(new RunParameter("SchemaHolderName", this.getDbName()));
        c.add(new RunParameter("Collation", this.getCollation()));
        c.add(new RunParameter("Codepage", this.getCodepage()));
        c.add(new RunParameter("OracleVersion", Integer.toString(this.oracleVersion)));
        c.add(new RunParameter("UserName", this.getUsername()));
        c.add(new RunParameter("Password", this.getPassword()));

        return c;
    }

    public String getProcedure() {
        return "pct/oraHolder.p";
    }
}
