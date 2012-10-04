package com.phenix.pct;

import java.io.File;
import java.util.Iterator;
import java.util.List;

import org.apache.tools.ant.BuildException;

public class WSServerProcess extends PCTRun {
    private boolean webLogError = true;

    public WSServerProcess() {
        super(false, false);
        this.procedure = "web/objects/web-disp.p";
    }

    public void setGraphicalMode(boolean graphMode) {
        throw new BuildException("Unknown attribute");
    }

    public void setDebugPCT(boolean debugPCT) {
        throw new BuildException("Unknown attribute");
    }

    public void setBaseDir(File baseDir) {
        throw new BuildException("Unknown attribute");
    }

    public void setFailOnError(boolean failOnError) {
        throw new BuildException("Unknown attribute");
    }

    public boolean isWebLogError() {
        return webLogError;
    }

    public void setWebLogError(boolean webLogError) {
        this.webLogError = webLogError;
    }

    protected List getCmdLineParameters() {
        List list = super.getCmdLineParameters();

        if (this.webLogError)
            list.add("-weblogerror");
        
        list.add("-p");
        list.add(procedure);
        
        if (dbConnList != null) {
            for (Iterator iter = dbConnList.iterator(); iter.hasNext(); ) {
                PCTConnection conn = (PCTConnection) iter.next();
                list.addAll(conn.getConnectParametersList());
            }
        }

        return list;
    }

    /**
     * Get the current propath as a path-separated list
     * 
     * @return String
     */
    public String getPropath() {
        if (this.propath == null)
            return "";

        StringBuffer propathList = new StringBuffer("");
        String[] lst = this.propath.list();
        for (int k = 0; k < lst.length; k++) {
            propathList.append(lst[k]);
            if (k < lst.length - 1)
                propathList.append(File.pathSeparatorChar);
        }
        return propathList.toString();
    }
}
