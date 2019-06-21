/**
 * Copyright 2005-2019 Riverside Software
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */
package com.phenix.pct;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.List;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.ExecTask;
import org.apache.tools.ant.types.Environment;
import org.apache.tools.ant.types.FileSet;

/**
 * Procedure encryption task using xcode utility from Progress
 * 
 * @author <a href="mailto:d.knol@steeg-software.nl">Dick Knol</a>
 */
public class PCTXCode extends PCT {
    private List<FileSet> filesets = new ArrayList<>();
    private String key = null;
    private File destDir = null;
    private int tmpLogId = -1;
    private File tmpLog = null;
    private int filesListId = -1;
    private File filesList = null;
    private boolean overwrite = false;
    private boolean lowercase = false;

    /**
     * Default constructor
     */
    public PCTXCode() {
        super();

        tmpLogId = PCT.nextRandomInt();
        tmpLog = new File(System.getProperty(PCT.TMPDIR), "pct_outp" + tmpLogId + ".log"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        filesListId = PCT.nextRandomInt();
        filesList = new File(System.getProperty(PCT.TMPDIR), "xcode" + filesListId + ".input"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
    }

    /**
     * Sets output directory (-d attribute)
     * 
     * @param destDir File
     */
    public void setDestDir(File destDir) {
        this.destDir = destDir;
    }

    /**
     * Sets key to be used for encryption (-k attribute)
     * 
     * @param key String
     */
    public void setKey(String key) {
        this.key = key;
    }

    /**
     * Overwrites files ?
     * 
     * @param overwrite boolean
     */
    public void setOverwrite(boolean overwrite) {
        this.overwrite = overwrite;
    }

    /**
     * Convert filenames to lowercase (-l attribute)
     * 
     * @param lowercase boolean
     */
    public void setLowercase(boolean lowercase) {
        this.lowercase = lowercase;
    }

    /**
     * Adds a set of files to encrypt
     * 
     * @param set FileSet
     */
    public void addFileset(FileSet set) {
        filesets.add(set);
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    @Override
    public void execute() {
        checkDlcHome();
        if (destDir == null) {
            cleanup();
            throw new BuildException(Messages.getString("PCTXCode.4")); //$NON-NLS-1$
        }

        log(Messages.getString("PCTXCode.5"), Project.MSG_INFO); //$NON-NLS-1$

        try {
            for (FileSet fs : filesets) {
                Task task = createExecTask(fs);
                task.execute();
            }
            cleanup();
        } catch (BuildException be) {
            cleanup();
            throw be;
        }
    }

    private void createFileList(FileSet fs) {
        try (FileWriter w = new FileWriter(filesList); BufferedWriter writer = new BufferedWriter(w)) {
            for (String str : fs.getDirectoryScanner(getProject()).getIncludedFiles()) {
                int j = str.replace(File.separatorChar, '/').lastIndexOf('/');

                if (j != -1) {
                    File f2 = new File(destDir, str.substring(0, j));

                    if (!f2.exists() && !f2.mkdirs()) {
                        throw new BuildException(MessageFormat.format(
                                Messages.getString("PCTXCode.3"), f2.getAbsolutePath())); //$NON-NLS-1$
                    }
                }

                File trgFile = new File(destDir, str);
                File srcFile = new File(fs.getDir(getProject()), str);

                if (!trgFile.exists() || overwrite
                        || (srcFile.lastModified() > trgFile.lastModified())) {
                    log(MessageFormat.format(
                            Messages.getString("PCTXCode.6"), trgFile.toString()), Project.MSG_VERBOSE); //$NON-NLS-1$
                    writer.write(str);
                    writer.newLine();

                    if (overwrite) {
                        Files.deleteIfExists(trgFile.toPath());
                    }
                }
            }
        } catch (IOException caught) {
            throw new BuildException(caught);
        }
    }

    private Task createExecTask(FileSet fs) {
        ExecTask exec = new ExecTask(this);
        exec.setDir(fs.getDir(getProject()));
        exec.setOutput(tmpLog);
        exec.setExecutable(getExecPath("xcode").toString()); //$NON-NLS-1$

        Environment.Variable var = new Environment.Variable();
        var.setKey("DLC"); //$NON-NLS-1$
        var.setValue(getDlcHome().toString());
        exec.addEnv(var);

        if (key != null) {
            exec.createArg().setValue("-k"); //$NON-NLS-1$
            exec.createArg().setValue(key);
        }

        exec.createArg().setValue("-d"); //$NON-NLS-1$
        exec.createArg().setValue(destDir.toString());

        if (lowercase) {
            exec.createArg().setValue("-l"); //$NON-NLS-1$
        }

        exec.createArg().setValue("-");

        createFileList(fs);
        exec.setInput(filesList);

        return exec;
    }

    protected void cleanup() {
        deleteFile(tmpLog);
        deleteFile(filesList);
    }
}
