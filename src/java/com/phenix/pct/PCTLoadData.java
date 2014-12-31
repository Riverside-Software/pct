/*
 * Copyright  2000-2004 The Apache Software Foundation
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
import java.util.Collection;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.types.FileSet;

import com.google.common.base.Joiner;
import com.google.common.base.Splitter;

/**
 * Loads data into database
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTLoadData extends PCTRun {
    private File srcDir = null, srcFile = null;
    private String table = null;
    private String callback = null;
    private int errorPercentage = 0;
    private Collection<PCTTable> tableList = null;
    private Collection<FileSet> tableFilesets = null;
    private Collection<String> tables = null;

    /**
     * Input directory
     * 
     * @param srcDir directory
     */
    public void setSrcDir(File srcDir) {
        this.srcDir = srcDir;
    }

    /**
     * Input file
     * 
     * @param srcFile file
     */
    public void setSrcFile(File srcFile) {
        this.srcFile = srcFile;
    }

    public void setTable(String table) {
        this.table = table;
    }

    public void setCallbackClass(String callback) {
        this.callback = callback;
    }

    /**
     * Tables list to load
     * 
     * @param tables the tables to load
     */
    public void setTables(String tables) {
        this.tables = Splitter.on(',').trimResults().omitEmptyStrings().splitToList(tables);
    }

    /**
     * Acceptable error percentage. Should be in the 0-100 range.
     * 
     * @param perc Error percentage
     */
    public void setErrorPercentage(int perc) {
        if ((perc < 0) || (perc > 100))
            throw new BuildException("Invalid errorPercentage value " + perc);
        this.errorPercentage = perc;
    }

    public void addConfiguredTable(PCTTable table) {
        if (this.tableList == null) {
            tableList = new ArrayList<PCTTable>();
        }
        tableList.add(table);
    }

    /**
     * Adds a set of files to load
     * 
     * @param set FileSet
     */
    public void addConfiguredFileset(FileSet set) {
        if (this.tableFilesets == null) {
            tableFilesets = new ArrayList<FileSet>();
        }
        tableFilesets.add(set);
    }

    private Collection<String> getTableList() {
        Collection<String> list = new ArrayList<String>();
        if (tables != null)
            list.addAll(tables);

        if (tableList != null) {
            for (PCTTable tbl : tableList) {
                list.add(tbl.getName());
            }
        }

        if (tableFilesets != null) {
            for (FileSet fs : tableFilesets) {
                for (String file : fs.getDirectoryScanner(getProject()).getIncludedFiles()) {
                    if (file.endsWith(".d")) {
                        list.add(file.substring(0, file.lastIndexOf(".d")));
                    }
                }
            }
        }

        if (list.size() == 0)
            list.add("ALL");

        return list;
    }

    private void checkAttributes() throws BuildException {
        // Only one of srcDir / srcFile can be used
        if ((srcDir == null) && (srcFile == null))
            throw new BuildException(Messages.getString("PCTLoadData.4")); //$NON-NLS-1$
        if ((srcDir != null) && (srcFile != null))
            throw new BuildException(Messages.getString("PCTLoadData.4")); //$NON-NLS-1$

        if (srcFile != null) {
            if ((table == null) || (table.trim().length() == 0))
                throw new BuildException(Messages.getString("PCTLoadData.5")); //$NON-NLS-1$
            if (!srcFile.isFile())
                throw new BuildException(Messages.getString("PCTLoadData.6")); //$NON-NLS-1$
        } else {
            if (!srcDir.isDirectory())
                throw new BuildException(Messages.getString("PCTLoadData.7")); //$NON-NLS-1$
        }
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        if (getDbConnections().size() == 0) {
            cleanup();
            throw new BuildException(Messages.getString("PCTLoadData.0")); //$NON-NLS-1$
        }
        checkAttributes();

        try {
            if (srcDir != null) {
                addParameter(new RunParameter("srcDir", srcDir.getAbsolutePath()));
                addParameter(new RunParameter("tables", Joiner.on(',').join(getTableList())));
                setProcedure(getProgressProcedures().getLoadMultipleTablesDataProcedure());
            } else {
                addParameter(new RunParameter("srcFile", srcFile.getAbsolutePath()));
                addParameter(new RunParameter("tableName", table));
                addParameter(new RunParameter("errorPercentage", Integer.toString(errorPercentage)));
                setProcedure(getProgressProcedures().getLoadSingleTableDataProcedure());
            }
            addParameter(new RunParameter("callbackClass", callback));

            super.execute();
            cleanup();
        } catch (BuildException be) {
            cleanup();
            throw be;
        }
    }
}
