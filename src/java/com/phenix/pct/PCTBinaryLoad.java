/**
 * Copyright 2005-2024 Riverside Software
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

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.ExecTask;
import org.apache.tools.ant.types.FileSet;

/**
 * Binary load task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 * @version $Revision$
 */
public class PCTBinaryLoad extends PCT {
    private PCTConnection connection = null;
    private List<FileSet> filesets = new ArrayList<>();
    private int indexRebuildTimeout = 0;
    private boolean rebuildIndexes = true;
    private File paramFile = null;
    private List<PCTRunOption> options = null;

    /**
     * Add a database connection
     * @deprecated
     */
    @Deprecated
    public void addPCTConnection(PCTConnection dbConn) {
        addDBConnection(dbConn);
    }

    // Variation pour antlib
    public void addDB_Connection(PCTConnection dbConn) {
        addDBConnection(dbConn);
    }

    public void addDBConnection(PCTConnection dbConn) {
        if (this.connection != null) {
            throw new BuildException(Messages.getString("PCTBinaryLoad.2")); //$NON-NLS-1$
        }
        this.connection = dbConn;
    }

    /**
     * Adds a set of files to archive.
     * 
     * @param set FileSet
     */
    public void addFileset(FileSet set) {
        filesets.add(set);
    }

    /**
     * Sets the timeout before indexes are rebuilt (-G parameter)
     * 
     * @param timeout Timeout
     */
    public void setIndexRebuildTimeout(int timeout) {
        if (timeout < 0) {
            throw new BuildException(Messages.getString("PCTBinaryLoad.0")); //$NON-NLS-1$
        }

        this.indexRebuildTimeout = timeout;
    }

    /**
     * Parameter file (-pf attribute)
     *
     * @param pf File
     */
    public void setParamFile(File pf) {
        this.paramFile = pf;
    }

    /**
     * Sets to false if indexes shouldn't be rebuilt
     * 
     * @param rebuildIndexes boolean
     */
    public void setRebuildIndexes(boolean rebuildIndexes) {
        this.rebuildIndexes = rebuildIndexes;
    }

    public void addOption(PCTRunOption option) {
        if (options == null) {
            options = new ArrayList<>();
        }
        options.add(option);
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    @Override
    public void execute() {
        checkDlcHome();
        if (connection == null) {
            throw new BuildException(Messages.getString("PCTBinaryLoad.1")); //$NON-NLS-1$
        }

        for (FileSet fs : filesets) {
            for (String str : fs.getDirectoryScanner(this.getProject()).getIncludedFiles()) {
                File foo = new File(fs.getDir(this.getProject()), str);
                ExecTask exec = loadTask(foo);
                exec.execute();
            }
        }
    }

    private ExecTask loadTask(File binaryFile) {
        ExecTask exec = new ExecTask(this);
        exec.setFailonerror(true);
        File a = getExecPath("_proutil"); //$NON-NLS-1$
        exec.setExecutable(a.toString());
        connection.createArguments(exec);

        // Binary load
        exec.createArg().setValue("-C"); //$NON-NLS-1$
        exec.createArg().setValue("load"); //$NON-NLS-1$

        // File to load
        exec.createArg().setValue(binaryFile.getAbsolutePath());

        // Rebuild indexes
        if (rebuildIndexes) {
            exec.createArg().setValue("build"); //$NON-NLS-1$
            exec.createArg().setValue("indexes"); //$NON-NLS-1$
            exec.createArg().setValue("-G"); //$NON-NLS-1$
            exec.createArg().setValue(Integer.toString(indexRebuildTimeout));
        }
        if (this.paramFile != null) {
            exec.createArg().setValue("-pf"); //$NON-NLS-1$
            exec.createArg().setValue(this.paramFile.getAbsolutePath());
        }

        if (options != null) {
            for (PCTRunOption opt : options) {
                if (opt.getName() == null) {
                    throw new BuildException("PCTRun.8"); //$NON-NLS-1$
                }
                exec.createArg().setValue(opt.getName());
                if (opt.getValue() != null)
                    exec.createArg().setValue(opt.getValue());
            }
        }

        return exec;
    }
}
