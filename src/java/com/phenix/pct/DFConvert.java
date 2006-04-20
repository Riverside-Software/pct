/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) The Apache Software Foundation.  All rights
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
import org.apache.tools.ant.DirectoryScanner;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.Copy;
import org.apache.tools.ant.types.FileSet;

import java.io.File;
import java.util.Random;

/**
 * Converts a Progress dump file (.df) to a schema holder dump file. Only Oracle dump files
 * generated for now.
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
 * @version $Revision: 414 $
 * @since 0.10
 */
public class DFConvert extends PCT {
    private final static String ORA = "ORACLE";
    private final static String MSS = "MSSQL";

    private String dbVersion = null;
    private String dbType = null;
    private String tblArea = null;
    private String idxArea = null;
    private String holderName = null;
    private File srcFile = null;
    private File destDFFile = null;
    private File destSQLFile = null;

    private int tmpNum = -1;
    private File tmpDir = null;

    /**
     * Schema holder name
     * 
     * @param holderName String
     */
    public void setHolderName(String holderName) {
        this.holderName = holderName;
    }

    /**
     * Source dump file
     * 
     * @param srcFile File
     */
    public void setSrcFile(File srcFile) {
        this.srcFile = srcFile;
    }

    /**
     * Target dump file
     * 
     * @param destFile File
     */
    public void setDestDFFile(File destFile) {
        this.destDFFile = destFile;
    }

    /**
     * Target dump file
     * 
     * @param destFile File
     */
    public void setDestSQLFile(File destFile) {
        this.destSQLFile = destFile;
    }

    /**
     * Database type. Only ORACLE and MSSQL accepted for now
     * 
     * @param dbType String -- ORACLE | MSSQL
     */
    public void setDbType(String dbType) {
        this.dbType = dbType;
    }

    /**
     * Database version.
     * 
     * @param dbVersion String
     */
    public void setDbVersion(String dbVersion) {
        this.dbVersion = dbVersion;
    }

    /**
     * Tablespace used for tables
     * 
     * @param tblSpace String
     */
    public void setTableTblSpc(String tblSpace) {
        this.tblArea = tblSpace;
        // this.idxArea = tblSpace;
    }

    /**
     * Tablespace used for indexes
     * 
     * @param tblSpace String
     */
    public void setIndexTblSpc(String tblSpace) {
        this.idxArea = tblSpace;
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        // Creates a unique temporary directory name
        while ((tmpDir == null) || ((tmpDir != null) && (tmpDir.exists()))) {
            tmpNum = new Random().nextInt() & 0xffff;
            tmpDir = new File(System.getProperty("java.io.tmpdir"), "pct" + tmpNum);
        }

        if ((this.srcFile == null) || (this.destDFFile == null) || (this.destSQLFile == null)) {
            throw new BuildException(Messages.getString("DFConvert.0")); //$NON-NLS-1$
        }

        if (this.dbType.equalsIgnoreCase(ORA))
            checkOracleAttributes();
        else if (this.dbType.equalsIgnoreCase(MSS))
            checkMSSQLAttributes();
        else
            throw new BuildException(Messages.getString("DFConvert.1")); //$NON-NLS-1$

        // Creates directory -- Yes, potentially, directory could already be created...
        tmpDir.mkdir();
        try {
            tmpDbTask().execute();
            if (this.dbType.equalsIgnoreCase(ORA))
                convertToOracleTask().execute();
            else if (this.dbType.equalsIgnoreCase(MSS))
                convertToMSSQLTask().execute();
            File f1 = new File(this.tmpDir, this.holderName + ".sql");
            File f2 = new File(this.tmpDir, this.holderName + ".df");
            copyTask(f1, this.destSQLFile).execute();
            copyTask(f2, this.destDFFile).execute();

            // .e files can be generated during DF conversion
            FileSet fs = new FileSet();
            fs.setDir(this.tmpDir);
            fs.setIncludes("*.e");

            // Parse every file, and log their content
            DirectoryScanner ds = fs.getDirectoryScanner(this.getProject());
            for (int k = 0; k < ds.getIncludedFiles().length; k++) {
                File f = new File(this.tmpDir, ds.getIncludedFiles()[k]);

            }
        } catch (BuildException be) {
            this.cleanup();
            throw be;
        }

    }

    private Task tmpDbTask() {
        PCTCreateBase task = (PCTCreateBase) getProject().createTask("PCTCreateBase"); //$NON-NLS-1$
        task.setOwningTarget(this.getOwningTarget());
        task.setTaskName(this.getTaskName());
        task.setDlcHome(this.getDlcHome());
        task.setDBName("holder");
        task.setDestDir(this.tmpDir);

        return task;

    }

    private Task convertToOracleTask() {
        PCTRun task = (PCTRun) getProject().createTask("PCTRun"); //$NON-NLS-1$
        task.setOwningTarget(this.getOwningTarget());
        task.setTaskName(this.getTaskName());
        task.setDlcHome(this.getDlcHome());
        task.setBaseDir(this.tmpDir);
        task.setProcedure("pct/protoora_wrapper.p");
        task.setParameter(this.srcFile + ";" + this.tblArea + ";" + this.idxArea + ";"
                + this.holderName + ";" + this.dbVersion);

        PCTConnection pc = new PCTConnection();
        pc.setDbDir(this.tmpDir);
        pc.setDbName("holder");
        pc.setSingleUser(true);
        task.addPCTConnection(pc);

        return task;
    }

    private Task convertToMSSQLTask() {
        PCTRun task = (PCTRun) getProject().createTask("PCTRun"); //$NON-NLS-1$
        task.setOwningTarget(this.getOwningTarget());
        task.setTaskName(this.getTaskName());
        task.setDlcHome(this.getDlcHome());
        task.setBaseDir(this.tmpDir);
        task.setProcedure("pct/protomssql_wrapper.p");
        task.setParameter(this.srcFile + ";" + this.holderName);

        PCTConnection pc = new PCTConnection();
        pc.setDbDir(this.tmpDir);
        pc.setDbName("holder");
        pc.setSingleUser(true);
        task.addPCTConnection(pc);

        return task;
    }

    private void checkOracleAttributes() throws BuildException {
        if (this.tblArea == null)
            throw new BuildException("Tablespace for tables should be assigned");
        if (this.idxArea == null)
            throw new BuildException("Tablespace for indexes should be assigned");
    }

    private void checkMSSQLAttributes() throws BuildException {
        if (this.tblArea != null)
            log("TableTblSpc attribute is not used with MSSQL");
        if (this.idxArea != null)
            log("IndexTblSpc attribute is not used with MSSQL");
    }

    /**
     * Gee, what a shame :-)
     * 
     * @param src
     * @param target
     * @return
     */
    private Task copyTask(File src, File target) {
        Copy task = (Copy) getProject().createTask("copy"); //$NON-NLS-1$
        task.setOwningTarget(this.getOwningTarget());
        task.setTaskName(this.getTaskName());
        task.setFile(src);
        task.setTofile(target);

        return task;
    }

    private void cleanup() {
        if ((this.tmpDir != null) && this.tmpDir.exists()) {
            // FIXME This won't work -- Need to empty directory before
            this.tmpDir.delete();
        }
    }
}
