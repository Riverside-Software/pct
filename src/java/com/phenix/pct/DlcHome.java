package com.phenix.pct;

import java.io.File;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.DefaultExcludes;

public class DlcHome extends Task {
    private File value = null;

    @Override
    public void execute() throws BuildException {
        if (value == null)
            throw new BuildException("Value can't be null");
        dlcHome = value;

        DefaultExcludes excludes = new DefaultExcludes();
        excludes.bindToOwner(this);
        excludes.setAdd("/.pct/**");
        excludes.execute();
    }

    public void setValue(File file) {
        this.value = file;
    }

    // Not really good in multi-threaded case...
    private static File dlcHome = null;
    public static File getDlcHome() {
        return dlcHome;
    }
}
