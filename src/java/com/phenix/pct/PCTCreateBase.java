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
import org.apache.tools.ant.taskdefs.Delete;
import org.apache.tools.ant.taskdefs.ExecTask;
import org.apache.tools.ant.types.Environment;
import org.apache.tools.ant.types.Path;

import java.io.File;


/**
  * Class for creating Progress databases
  * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
  **/
public class PCTCreateBase extends PCT {
    private static final int DEFAULT_BLOCK_SIZE = 8;
    private static final int DB_NAME_MAX_LENGTH = 11;
    private String dbName = null;
    private String codepage = null;
    private File destDir = null;
    private File structFile = null;
    private int blockSize = DEFAULT_BLOCK_SIZE;
    private boolean noInit = false;
    private boolean overwrite = false;
    private File schema = null;
    private Path propath = null;
    private int[] blocks = {0, 1024, 2048, 0, 4096, 0, 0, 0, 8192};
    
    /**
     * Structure file (.st)
     * @param structFile File
     */
    public void setStructFile(File structFile) {
        this.structFile = structFile;
    }

    /**
     * Database name
     * @param dbName String
     */
    public void setDBName(String dbName) {
        this.dbName = dbName;
    }

    /**
     * If database shouldn't be initialized
     * @param noInit "true|false|on|off|yes|no"
     */
    public void setNoInit(boolean noInit) {
        this.noInit = noInit;
    }

    /**
     * No schema
     * @param noSchema "true|false|on|off|yes|no"
     */
    public void setNoSchema(boolean noSchema) {
        this.log("noSchema is deprecated and not used anymore - Use structFile instead");
    }

    /**
     * Block size
     * @param blockSize int
     */
    public void setBlockSize(int blockSize) {
        this.blockSize = blockSize;
    }

    /**
     * In which directory create the database
     * @param destDir File
     */
    public void setDestDir(File destDir) {
        this.destDir = destDir;
    }

    /**
     * Overwrite database if existent
     * @param overwrite "true|false|on|off|yes|no"
     */
    public void setOverwrite(boolean overwrite) {
        log("WARNING : this attribute doesn't work properly");
        this.overwrite = overwrite;
    }

    /**
     * Load schema after creating database
     * @param schemaFile File
     */
    public void setSchemaFile(File schemaFile) {
        this.schema = schemaFile;
    }

    /**
     * Set the propath to be used when running the procedure
     * @param propath an Ant Path object containing the propath
     */
     public void setPropath(Path propath) {
         createPropath().append(propath);
     }

     /**
      * Creates a new Path instance
      * @return Path
      */
     public Path createPropath() {
         if (this.propath == null) {
             this.propath = new Path(this.getProject());
         }

         return this.propath;
     }

     /**
      * Set the desired database codepage (copy from $DLC/prolang/codepage/emptyX)
      * @param codepage Subdirectory name from prolang directory where to find the empty database 
      */
     public void setCodepage(String codepage) {
         this.codepage = codepage;
     }

    /**
     * Do the work
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        ExecTask exec = null;

        // TODO : rediriger la sortie standard
        // Checking there is at least an init or a structure creation
        if ((this.structFile == null) && this.noInit) {
            throw new BuildException("noInit and noStruct can't be both defined to true");
        }

        // Checking dbName is defined
        if (this.dbName == null) {
            throw new BuildException("Database name not defined");
        }

        // Update destDir if not defined
        if (this.destDir == null) {
            this.destDir = this.getProject().getBaseDir();
        }

        // Checking length of the database name
        if (this.dbName.length() > DB_NAME_MAX_LENGTH) {
            throw new BuildException("Database name is longer than 11 characters");
        }

        // Checks if DB already exists
        File db = new File(destDir, dbName + ".db");

        if (db.exists()) {
            if (this.overwrite) {
                // TODO : revoir l'effacement de l'ancienne base
                Delete del = (Delete) getProject().createTask("delete");
                del.setOwningTarget(this.getOwningTarget());
                del.setTaskName(this.getTaskName());
                del.setDescription(this.getDescription());
                del.setFile(db);
                del.execute();
            } else {
                return;
            }
        }

        if (this.structFile != null) {
            exec = structCmdLine();
            exec.execute();
        }

        if (!this.noInit) {
            exec = initCmdLine();
            exec.execute();
        }

        if (this.schema != null) {
            PCTLoadSchema pls = (PCTLoadSchema) getProject().createTask("PCTLoadSchema");
            pls.setOwningTarget(this.getOwningTarget());
            pls.setTaskName(this.getTaskName());
            pls.setDescription(this.getDescription());
            pls.setSrcFile(this.schema);
            pls.setDlcHome(this.getDlcHome());
            pls.setDlcBin(this.getDlcBin());
            pls.setPropath(this.propath);
            
            PCTConnection pc = new PCTConnection();
            pc.setDbName(this.dbName);
            pc.setDbDir(this.destDir);
            pc.setSingleUser(true);
            pls.addPCTConnection(pc);
            pls.execute();
        }
    }

    /**
     * Creates the _dbutil procopy emptyX command line
     * @return
     */
    private ExecTask initCmdLine() {
        ExecTask exec = (ExecTask) getProject().createTask("exec");
        
        File srcDir = this.getDlcHome();
        if (this.codepage != null) {
            srcDir = new File(srcDir, "prolang");
            srcDir = new File(srcDir, this.codepage);
        }
        File srcDB = new File(srcDir, "empty" + this.blockSize);

        exec.setOwningTarget(this.getOwningTarget());
        exec.setTaskName(this.getTaskName());
        exec.setDescription(this.getDescription());

        exec.setExecutable(getExecPath("_dbutil").toString());
        exec.setDir(this.destDir);
        exec.createArg().setValue("procopy");
        exec.createArg().setValue(srcDB.getAbsolutePath());
        exec.createArg().setValue(this.dbName);

        Environment.Variable var = new Environment.Variable();
        var.setKey("DLC");
        var.setValue(this.getDlcHome().toString());
        exec.addEnv(var);

        return exec;
    }

    /**
     * Creates the _dbutil prostrct create command line
     * @return
     */
    private ExecTask structCmdLine() {
        ExecTask exec = (ExecTask) getProject().createTask("exec");

        exec.setOwningTarget(this.getOwningTarget());
        exec.setTaskName(this.getTaskName());
        exec.setDescription(this.getDescription());

        exec.setExecutable(getExecPath("_dbutil").toString());
        exec.setDir(this.destDir);
        exec.createArg().setValue("prostrct");
        exec.createArg().setValue("create");
        exec.createArg().setValue(this.dbName);
        exec.createArg().setValue(this.structFile.getAbsolutePath());
        exec.createArg().setValue("-blocksize");
        exec.createArg().setValue(Integer.toString(blocks[this.blockSize]));
        
        Environment.Variable var = new Environment.Variable();
        var.setKey("DLC");
        var.setValue(this.getDlcHome().toString());
        exec.addEnv(var);

        return exec;
    }
}
