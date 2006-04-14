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
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.Copy;
import org.apache.tools.ant.taskdefs.ExecTask;

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
    private String dbVersion = null;
    private String dbType = null;
    private String tblArea = null;
    private String idxArea = null;
    private String holderName = null;
    private File srcFile = null;
    private File destDFFile = null;
    private File destSQLFile = null;

    // private String tmpDb = null;
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
     * @param destDFFile File
     */
    public void setDestDFFile(File destFile) {
        this.destDFFile = destFile;
    }
    /**
     * Target dump file
     * 
     * @param destDFFile File
     */
    public void setDestsQLFile(File destFile) {
        this.destSQLFile = destFile;
    }
    /**
     * Database type. Only ORACLE accepted for now
     * 
     * @param dbType String -- ORACLE | MSSQL | ODBC
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
     * Tablespace used for tables and indexes
     * 
     * @param tblSpace String
     */
    public void setTableSpace(String tblSpace) {
        this.tblArea = tblSpace;
        this.idxArea = tblSpace;
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        // Creates a unique temporary directory name
        while ((tmpDir != null) && (!tmpDir.exists())) {
            tmpNum = new Random().nextInt() & 0xffff;
            tmpDir = new File(System.getProperty("java.io.tmpdir"), "pct" + tmpNum);
        }
        
        if ((this.srcFile == null) || (this.destDFFile == null) || (this.destSQLFile == null)) {
            throw new BuildException(Messages.getString("DFConvert.0")); //$NON-NLS-1$
        }

        if (!this.dbType.equalsIgnoreCase("ORACLE")) {
            throw new BuildException(Messages.getString("DFConvert.1")); //$NON-NLS-1$
        }

        // Creates directory -- Yes, potentially directory could already be created...
        tmpDir.mkdir();
        try {
            tmpDbTask().execute();
            convertToOracleTask().execute();
            File f1 = new File(this.tmpDir, this.holderName + ".sql");
            File f2 = new File(this.tmpDir, this.holderName + ".df");
            copyTask(f1, this.destSQLFile).execute();
            copyTask(f2, this.destDFFile).execute();
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
        task.setDBName("oratmp");
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
        pc.setDbName("oratmp");
        pc.setSingleUser(true);
        task.addPCTConnection(pc);

        return task;
    }
    
    /**
     * Gee, what a shame :-)
     * 
     * @param src
     * @param target
     * @return
     */
    private Task copyTask(File src, File target) {
        Copy task = (Copy) getProject().createTask("Copy"); //$NON-NLS-1$
        task.setFile(src);
        task.setTofile(target);
        
        return task;
    }
    
    
    private void cleanup() {
        // Don't forget cleanup
    }
}
