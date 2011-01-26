package com.phenix.pct;

import java.util.ResourceBundle;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.Echo;

public class Version extends Task {
    private static final String BUNDLE_NAME = "com.phenix.pct.PCT"; //$NON-NLS-1$

    private static final ResourceBundle RESOURCE_BUNDLE = ResourceBundle.getBundle(BUNDLE_NAME);

    public void execute() throws BuildException {
        String str = "PCT Version " + RESOURCE_BUNDLE.getString("PCTVersion") + " - Build "
                + RESOURCE_BUNDLE.getString("PCTBuild");
        Echo echo = new Echo();
        echo.bindToOwner(this);
        echo.setMessage(str);
        echo.execute();
    }
}
