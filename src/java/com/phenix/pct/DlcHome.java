package com.phenix.pct;

import java.io.File;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

public class DlcHome extends Task {
    private File value = null;

    @Override
    public void execute() throws BuildException {
        if (value == null)
            throw new BuildException("Value can't be null");

        dlcHome = value;
    }

    public void setValue(File file) {
        this.value = file;
    }

    private static File dlcHome = null;
    public static File getDlcHome() {
        return dlcHome;
    }
}
