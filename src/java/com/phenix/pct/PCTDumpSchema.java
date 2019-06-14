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
import org.apache.tools.ant.Project;

import java.io.File;
import java.util.ArrayList;
import java.util.Collection;

/**
 * Dumps schema from database
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTDumpSchema extends PCTRun {
    private File destFile = null;
    private Collection<PCTTable> tableList = null;
    private String tables = null;

    /**
     * Output file for dump
     * 
     * @param destFile File
     */
    public void setDestFile(File destFile) {
        this.destFile = destFile;
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
            tableList = new ArrayList<>();
        }
        tableList.add(table);
    }

    private String getTableList() {
        StringBuilder sb = new StringBuilder();
        if (tables != null)
            sb.append(tables);

        if (tableList != null) {
            for (PCTTable tbl : tableList) {
                if (sb.length() > 0)
                    sb.append(',');
                sb.append(tbl.getName());
            }
        }

        if (sb.length() == 0)
            return "ALL";
        else
            return sb.toString();
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    @Override
    public void execute() {
        if (runAttributes.getAllDbConnections().isEmpty()) {
            cleanup();
            throw new BuildException(Messages.getString("PCTDumpSchema.0")); //$NON-NLS-1$
        }

        if (runAttributes.getAllDbConnections().size() > 1) {
            cleanup();
            throw new BuildException(Messages.getString("PCTDumpSchema.1")); //$NON-NLS-1$
        }

        if (destFile == null) {
            cleanup();
            throw new BuildException(Messages.getString("PCTDumpSchema.2")); //$NON-NLS-1$
        }

        log("Dumping schema to " + destFile.toString(), Project.MSG_INFO); //$NON-NLS-1$

        String param = destFile.toString() + ";" + getTableList();
        setProcedure("pct/dmpSch.p"); //$NON-NLS-1$
        setParameter(param);
        super.execute();
    }
}
