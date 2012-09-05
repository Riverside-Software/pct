/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) 2002 The Apache Software Foundation.  All rights
 * reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution, if
 *    any, must include the following acknowlegement:
 *       "This product includes software developed by the
 *        Apache Software Foundation (http://www.apache.org/)."
 *    Alternately, this acknowlegement may appear in the software itself,
 *    if and wherever such third-party acknowlegements normally appear.
 *
 * 4. The names "Ant" and "Apache Software
 *    Foundation" must not be used to endorse or promote products derived
 *    from this software without prior written permission. For written
 *    permission, please contact apache@apache.org.
 *
 * 5. Products derived from this software may not be called "Apache"
 *    nor may "Apache" appear in their names without prior written
 *    permission of the Apache Group.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE APACHE SOFTWARE FOUNDATION OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation.  For more
 * information on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 */
package com.phenix.pct;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;

import java.io.File;

import java.util.Iterator;

/**
 * Creates a schema diff file between two databases. This is a wrapper around prodict/dump_inc.p
 * from POSSENET code.
 * 
 * @author Phillip BAIRD
 * @author <a href="justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
 * @version $Revision$
 */
public class PCTDumpIncremental extends PCTRun {
    private File destFile = null;
    private File renameFile = null;
    private int activeIndexes = 0;
    private String codePage = null;
    private int debugLevel = 0;
    private PCTConnection sourceDB, targetDB;

    /**
     * Specifies if new indexes are created Active (true) or Inactive (false). Defaults to Active.
     * 
     * @param activeIndexes boolean
     */
    public void setActiveIndexes(int activeIndexes) {
        this.activeIndexes = activeIndexes;
    }

    /**
     * Specifies the CodePage for the .df file.
     * <ul>
     * <li>code-page = ?,"" : default conversion (SESSION:STREAM)</li>
     * <li>code-page = "<code-page>" : convert to &lt;code-page&gt;</li>
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

    public void addDBConnection(PCTConnection dbConn) {
        throw new BuildException("DBConnection shouldn't be used in PCTDumpIncremental. Use sourceDb and targetDb instead");
    }

    /**
     * @deprecated
     */
    public void addPCTConnection(PCTConnection dbConn) {
        log("PCTConnection is deprecrated. Use sourceDb and targetDb instead", Project.MSG_INFO);
        super.addDBConnection(dbConn);
    }

    /**
     * 
     * @param dbConn
     */
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
    public void execute() throws BuildException {
        if ((sourceDB != null) && (targetDB != null)) {
            super.addDBConnection(sourceDB);
            super.addDBConnection(targetDB);
        } else if ((sourceDB != null) || (targetDB != null)) {
            cleanup();
            throw new BuildException("SourceDb and TargetDb nodes should be defined");
        } else {
            if (dbConnList == null) {
                this.cleanup();
                throw new BuildException(Messages.getString("PCTDumpIncremental.0")); //$NON-NLS-1$
            }
    
            if (dbConnList.size() != 2) {
                this.cleanup();
                throw new BuildException(Messages.getString("PCTDumpIncremental.1")); //$NON-NLS-1$
            }
    
            if (!aliasDefined("dictdb")) { //$NON-NLS-1$
                this.cleanup();
                throw new BuildException(Messages.getString("PCTDumpIncremental.3")); //$NON-NLS-1$
            }
    
            if (!aliasDefined("dictdb2")) { //$NON-NLS-1$
                this.cleanup();
                throw new BuildException(Messages.getString("PCTDumpIncremental.5")); //$NON-NLS-1$
            }
        }

        if (this.destFile == null) {
            this.cleanup();
            throw new BuildException(Messages.getString("PCTDumpIncremental.6")); //$NON-NLS-1$
        }

        this.prepareExecTask();

        this.setProcedure(this.getProgressProcedures().getIncrementalProcedure());
        this.addParameter(new RunParameter("DFFileName", this.destFile.getAbsolutePath()));
        this.addParameter(new RunParameter("CodePage", this.codePage));
        this.addParameter(new RunParameter("RenameFile", (this.renameFile == null ? "" : this.renameFile.getAbsolutePath())));
        this.addParameter(new RunParameter("IndexMode", Integer.toString(this.activeIndexes)));
        this.addParameter(new RunParameter("DebugMode", Integer.toString(this.debugLevel)));
        
        super.execute();
    }

    /**
     * Validates a database connection exists with the supplied alias.
     * 
     * @param aliasName String
     * @return boolean
     */
    private boolean aliasDefined(String aliasName) {
        if (this.dbConnList == null) {
            return false;
        }

        Iterator connections = this.dbConnList.iterator();

        while (connections.hasNext()) {
            PCTConnection c = (PCTConnection) connections.next();

            if (c.hasNamedAlias(aliasName)) {
                return true;
            }
        }

        return false;
    }
}
