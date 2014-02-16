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

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.types.FileSet;

/**
 * Loads data into database
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTLoadData extends PCTRun {
    private File srcDir = null;
    private Collection<PCTTable> tableList = null;
    private Collection<FileSet> tableFilesets = null;
    private String tables = null;

    // Internal use
    private int paramsId = -1;
    private File params = null;

    /**
     * Creates a new PCTLoadData object
     */
    public PCTLoadData() {
        super();

        paramsId = PCT.nextRandomInt();

        params = new File(System.getProperty("java.io.tmpdir"), "pct_params" + paramsId + ".txt"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
    }

    /**
     * Input directory
     * 
     * @param srcDir directory
     */
    public void setSrcDir(File srcDir) {
        this.srcDir = srcDir;
    }

    /**
     * Tables list to dump
     * 
     * @param tables the tables to dump
     */
    public void setTables(String tables) {
        this.tables = tables;
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

    private String getTableList() {
        StringBuffer sb = new StringBuffer();
        if (tables != null)
            sb.append(tables);

        if (tableList != null) {
            for (PCTTable tbl : tableList) {
                if (sb.length() > 0)
                    sb.append(',');
                sb.append(tbl.getName());
            }
        }
        if (tableFilesets != null) {
            for (FileSet fs : tableFilesets) {
                for (String file : fs.getDirectoryScanner(getProject()).getIncludedFiles()) {
                    if (file.endsWith(".d")) {
                        if (sb.length() > 0) {
                            sb.append(',');
                        }
                        sb.append(file.substring(0, file.lastIndexOf(".d")));
                    }
                }
            }
        }

        if (sb.length() == 0) {
            return "ALL";
        } else {
            return sb.toString();
        }
    }

    /**
     * 
     * @throws BuildException
     */
    private void writeParams() throws BuildException {
        try {
            BufferedWriter bw = new BufferedWriter(new FileWriter(params));
            String tbl = getTableList();
            log("Loading with TABLES=" + tbl, Project.MSG_VERBOSE);
            if (tbl != null) {
                bw.write("TABLES=");
                bw.write(tbl);
                bw.newLine();
            }
            bw.write("SRCDIR=" + srcDir.getAbsolutePath()); //$NON-NLS-1$
            bw.newLine();
            bw.close();
        } catch (IOException ioe) {
            throw new BuildException(Messages.getString("PCTCompile.3")); //$NON-NLS-1$
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

        if (getDbConnections().size() > 1) {
            cleanup();
            throw new BuildException(Messages.getString("PCTLoadData.1")); //$NON-NLS-1$
        }

        if (srcDir == null) {
            cleanup();
            throw new BuildException(Messages.getString("PCTLoadData.2")); //$NON-NLS-1$
        }

        try {
            writeParams();
            setProcedure("pct/pctLoadData.p"); //$NON-NLS-1$
            setParameter(params.getAbsolutePath());
            super.execute();
            cleanup();
        } catch (BuildException be) {
            cleanup();
            throw be;
        }
    }
}
