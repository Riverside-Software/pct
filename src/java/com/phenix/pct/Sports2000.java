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

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.Delete;
import org.apache.tools.ant.taskdefs.ExecTask;
import org.apache.tools.ant.types.Environment;
import org.apache.tools.ant.types.Environment.Variable;

import java.io.File;

/**
 * Class for creating a sports2000 database
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class Sports2000 extends PCT {
    private static final int DB_NAME_MAX_LENGTH = 11;

    private String dbName = null;
    private File destDir = null;
    private boolean overwrite = false;

    /**
     * Database name
     * 
     * @param dbName String
     */
    public void setDBName(String dbName) {
        this.dbName = dbName;
    }

    /**
     * In which directory create the database
     * 
     * @param destDir File
     */
    public void setDestDir(File destDir) {
        this.destDir = destDir;
    }

    /**
     * Overwrite database if existent
     * 
     * @param overwrite "true|false|on|off|yes|no"
     */
    public void setOverwrite(boolean overwrite) {
        log(Messages.getString("PCTCreateBase.1")); //$NON-NLS-1$
        this.overwrite = overwrite;
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    @Override
    public void execute() {
        checkDlcHome();

        // If dbName is null, then it's sports2000
        if (dbName == null) {
            dbName = "sports2000"; //$NON-NLS-1$
        }

        // Checking length of the database name
        if (dbName.length() > DB_NAME_MAX_LENGTH) {
            throw new BuildException(Messages.getString("PCTCreateBase.4")); //$NON-NLS-1$
        }

        // Update destDir if not defined
        if (destDir == null) {
            destDir = getProject().getBaseDir();
        }

        // Checks if DB already exists
        File db = new File(destDir, dbName + ".db"); //$NON-NLS-1$
        if (db.exists()) {
            if (this.overwrite) {
                Delete del = new Delete();
                del.bindToOwner(this);
                del.setFile(db);
                del.execute();
            } else {
                return;
            }
        }

        ExecTask exec = initCmdLine();
        exec.execute();
    }

    /**
     * Creates the _dbutil procopy sports2000 command line
     * 
     * @return An ExecTask, ready to be executed
     */
    private ExecTask initCmdLine() {
        ExecTask exec = new ExecTask(this);
        exec.bindToOwner(this);

        exec.setDir(destDir);
        exec.setExecutable(getExecPath("_dbutil").toString()); //$NON-NLS-1$
        exec.createArg().setValue("procopy"); //$NON-NLS-1$
        exec.createArg().setValue(new File(getDlcHome(), "sports2000").getAbsolutePath()); //$NON-NLS-1$
        exec.createArg().setValue(dbName);

        Environment.Variable var = new Environment.Variable();
        var.setKey("DLC"); //$NON-NLS-1$
        var.setValue(this.getDlcHome().toString());
        exec.addEnv(var);

        for (Variable var2 : getEnvironmentVariables()) {
            exec.addEnv(var2);
        }

        return exec;
    }
}