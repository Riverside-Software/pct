package com.phenix.pct;

import java.io.File;
import java.util.List;

import org.apache.tools.ant.BuildException;

public class WSServerProcess extends PCTRun {
    private boolean webLogError = true;
    
    public WSServerProcess() {
        this.procedure = "web\\objects\\web-disp.p";
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
        
        return list;
    }
}
