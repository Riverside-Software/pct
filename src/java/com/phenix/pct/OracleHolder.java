package com.phenix.pct;

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

    public String getParameterString() {
        StringBuffer sb = new StringBuffer();
        sb.append(this.getDbName()).append(';');
        sb.append(this.getCodepage()).append(';');
        sb.append(this.getCollation()).append(';');
        sb.append(this.oracleVersion);
        
        return sb.toString();
    }

    public String getProcedure() {
        return "pct/oraHolder.p";
    }
}
