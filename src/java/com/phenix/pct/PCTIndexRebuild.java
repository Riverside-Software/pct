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
import org.apache.tools.ant.types.Environment;

/**
 * IndexRebuild task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class PCTIndexRebuild extends PCT {
    private File dbDir = null;
    private String dbName = null;
    private String passphraseCmdLine = null;
    private File outputLog = null;
    private List<IndexNode> indexes = new ArrayList<>();
    private String cpInternal = null;
    private List<PCTRunOption> options = new ArrayList<>();

    /**
     * Database name
     */
    public void setDBName(String dbName) {
        this.dbName = dbName;
    }

    /**
     * Database directory
     */
    public void setDbDir(File dbDir) {
        this.dbDir = dbDir;
    }

    public void setOutputLog(File outputLog) {
        this.outputLog = outputLog;
    }

    public void setPassphraseCmdLine(String passphraseCmdLine) {
        this.passphraseCmdLine = passphraseCmdLine;
    }

    /**
     * Internal code page (-cpinternal attribute)
     */
    public void setCpInternal(String cpInternal) {
        this.cpInternal = cpInternal;
    }

    public void addConfiguredIndex(IndexNode index) {
        if ((index.table == null) || index.table.isEmpty())
            throw new BuildException("Invalid index");
        if ((index.index == null) || index.index.isEmpty())
            throw new BuildException("Invalid index");
        this.indexes.add(index);
    }

    public void addOption(PCTRunOption option) {
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

        // Checking dbName and dbDir are defined
        if (dbName == null) {
            throw new BuildException(Messages.getString("PCTCreateDatabase.3"));
        }
        if (indexes.isEmpty())
            throw new BuildException("Index list can't be empty");

        // Update dbDir if not defined
        if (dbDir == null) {
            dbDir = getProject().getBaseDir();
        }

        idxBuildCmdLine().execute();
    }

    public static class IndexNode {
        private String table;
        private String index;

        public void setTable(String table) {
            this.table = table;
        }

        public void setIndex(String index) {
            this.index = index;
        }
    }

    private String generateInputString() {
        StringBuilder sb = new StringBuilder("some").append(System.lineSeparator());
        for (IndexNode idx : indexes) {
            sb.append(idx.table).append(System.lineSeparator());
            sb.append(idx.index).append(System.lineSeparator());
        }
        sb.append("!").append(System.lineSeparator());
        sb.append("y").append(System.lineSeparator());
        sb.append("y").append(System.lineSeparator());

        return sb.toString();
    }

    /**
     * Creates the _dbutil procopy emptyX command line
     * 
     * @return An ExecTask, ready to be executed
     */
    private ExecTask idxBuildCmdLine() {
        ExecTask exec = new ExecTask(this);
        exec.setFailonerror(true);

        File db = new File(dbDir, dbName);
        exec.setExecutable(getExecPath("_dbutil").toString());
        exec.createArg().setValue(db.getAbsolutePath());
        exec.createArg().setValue("-C");
        exec.createArg().setValue("idxbuild");
        if (outputLog != null) {
            exec.setOutput(outputLog.getAbsoluteFile());
        }
        for (PCTRunOption option : options) {
            exec.createArg().setValue(option.getName());
            if (option.getValue() != null)
                exec.createArg().setValue(option.getValue());
        }
        if (cpInternal != null) {
            exec.createArg().setValue("-cpinternal");
            exec.createArg().setValue(cpInternal);
        }

        if (hasCmdLinePassphrase()) {
            exec.createArg().setValue("-Passphrase");
            exec.setInputString(getPassphraseFromCmdLine(passphraseCmdLine) + System.lineSeparator() + generateInputString());
        } else {
            exec.setInputString(generateInputString());
        }

        Environment.Variable envVar = new Environment.Variable();
        envVar.setKey("DLC"); //$NON-NLS-1$
        envVar.setValue(getDlcHome().toString());
        exec.addEnv(envVar);

        return exec;
    }

    private boolean hasCmdLinePassphrase() {
        return (passphraseCmdLine != null) && !passphraseCmdLine.trim().isEmpty();
    }

}