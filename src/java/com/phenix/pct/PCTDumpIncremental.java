/**
 * Copyright 2005-2021 Riverside Software
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

/**
 * Creates a schema diff file between two databases. This is a wrapper around prodict/dump_inc.p
 * from POSSENET code.
 * 
 * @author Phillip BAIRD
 * @author <a href="g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class PCTDumpIncremental extends PCTDynamicRun {
    private File destFile = null;
    private File renameFile = null;
    private int activeIndexes = 0;
    private String codePage = null;
    private int debugLevel = 0;
    private boolean removeEmptyDFfile = false;
    private boolean dumpSection = false;
    private PCTConnection sourceDB;
    private PCTConnection targetDB;

    /**
     * Specifies if new indexes are created Active or Inactive. 
     *
     * <ul>
     * <li>0 = all new indexes active (Default)</li>
     * <li>1 = only new unique indexes inactive</li>
     * <li>2 = all new indexes inactive</li>
     * </ul>
     * @param activeIndexes int
     */
    public void setActiveIndexes(int activeIndexes) {
        this.activeIndexes = activeIndexes;
    }

    /**
     * Specifies the CodePage for the .df file.
     * <ul>
     * <li>code-page = ?,"" : default conversion (SESSION:STREAM)</li>
     * <li>code-page = "&lt;code-page&lt;" : convert to &lt;code-page&gt;</li>
     * </ul>
     * 
     * @param codePage String
     */
    public void setCodePage(String codePage) {
        this.codePage = codePage;
    }

    /**
     * Sets the debug level.
     * <ul>
     * <li>0 = debug off (only errors and important warnings)</li>
     * <li>1 = all the above plus all warnings</li>
     * <li>2 = all the above plus config info</li>
     * </ul>
     * 
     * @param debugLevel integer
     */
    public void setDebugLevel(int debugLevel) {
        this.debugLevel = debugLevel;
    }

    /**
     * Output file for incremental df.
     * 
     * @param destFile File
     */
    public void setDestFile(File destFile) {
        this.destFile = destFile;
    }

    /**
     * Set if DF file must be removed when no difference has occurred. Default = false.
     * 
     * @param removeEmptyDFfile boolean
     */
    public void setRemoveEmptyDFfile(boolean removeEmptyDFfile) {
        this.removeEmptyDFfile = removeEmptyDFfile;
    }

    public void setDumpSection(boolean dumpSection) {
        this.dumpSection = dumpSection;
    }

    /**
     * The RenameFile parameter is used to identify tables, database fields and sequences that have
     * changed names. The format of the file is a comma seperated list that identifies the renamed
     * object, its old name and the new name. When an object is found missing, this file is checked
     * to determine if it was renamed. If no matching entry is found, then the object
     * 
     * If RenameFile is not defined, then all missing objects are deleted. The RenameFile has
     * following format:
     * <ul>
     * <li>T,&lt;old-table-name&gt;,&lt;new-table-name&gt;</li>
     * <li>F,&lt;table-name&gt;,&lt;old-field-name&gt;,&lt;new-field-name&gt;</li>
     * <li>S,&lt;old-sequence-name&gt;,&lt;new-sequence-name&gt;</li>
     * </ul>
     * 
     * @param file File
     */
    public void setRenameFile(File file) {
        renameFile = file;
    }

    @Override
    public void addDBConnection(PCTConnection dbConn) {
        throw new BuildException(
                "DBConnection shouldn't be used in PCTDumpIncremental. Use sourceDb and targetDb instead");
    }

    /**
     * @deprecated
     */
    @Override
    public void addPCTConnection(PCTConnection dbConn) {
        log("PCTConnection is deprecrated. Use sourceDb and targetDb instead", Project.MSG_INFO);
        super.addDBConnection(dbConn);
    }

    public void addSourceDb(PCTConnection dbConn) {
        PCTAlias alias = new PCTAlias();
        alias.setName("dictdb");
        dbConn.addConfiguredPCTAlias(alias);
        this.sourceDB = dbConn;
    }

    public void addTargetDb(PCTConnection dbConn) {
        PCTAlias alias = new PCTAlias();
        alias.setName("dictdb2");
        dbConn.addConfiguredPCTAlias(alias);
        this.targetDB = dbConn;
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    @Override
    public void execute() {
        if ((sourceDB != null) && (targetDB != null)) {
            super.addDBConnection(sourceDB);
            super.addDBConnection(targetDB);
        } else if ((sourceDB != null) || (targetDB != null)) {
            cleanup();
            throw new BuildException("SourceDb and TargetDb nodes should be defined");
        } else {
            if (runAttributes.getAllDbConnections().size() != 2) {
                cleanup();
                throw new BuildException(Messages.getString("PCTDumpIncremental.1")); //$NON-NLS-1$
            }

            if (!aliasDefined("dictdb")) { //$NON-NLS-1$
                cleanup();
                throw new BuildException(Messages.getString("PCTDumpIncremental.3")); //$NON-NLS-1$
            }

            if (!aliasDefined("dictdb2")) { //$NON-NLS-1$
                cleanup();
                throw new BuildException(Messages.getString("PCTDumpIncremental.5")); //$NON-NLS-1$
            }
        }

        if (destFile == null) {
            cleanup();
            throw new BuildException(Messages.getString("PCTDumpIncremental.6")); //$NON-NLS-1$
        }

        checkDlcHome();

        setProcedure(getProgressProcedures().getIncrementalProcedure());
        addParameter(new RunParameter("DFFileName", destFile.getAbsolutePath()));
        addParameter(new RunParameter("CodePage", codePage));
        addParameter(new RunParameter("RenameFile", (renameFile == null
                ? ""
                : renameFile.getAbsolutePath())));
        addParameter(new RunParameter("IndexMode", Integer.toString(activeIndexes)));
        addParameter(new RunParameter("DebugMode", Integer.toString(debugLevel)));
        addParameter(new RunParameter("removeEmptyDFfile", Boolean.toString(removeEmptyDFfile)));
        addParameter(new RunParameter("dumpSection", Boolean.toString(dumpSection)));

        if ((sourceDB != null) && (targetDB != null)) {
            // Legacy behavior : sourceDb and TargetDb are not set when using PCTConnection
            log("Creating incremental DF from " + sourceDB.getDbName() + " to " + targetDB.getDbName());
        }
        super.execute();
    }

    /**
     * Validates a database connection exists with the supplied alias.
     * 
     * @param aliasName String
     * @return boolean
     */
    private boolean aliasDefined(String aliasName) {
        if (runAttributes.getAllDbConnections().isEmpty()) {
            return false;
        }

        for (PCTConnection c : runAttributes.getAllDbConnections()) {
            if (c.hasNamedAlias(aliasName)) {
                return true;
            }
        }

        return false;
    }
}
