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

import java.io.File;


/**
  * Class for creating Progress databases
  * @author <a href="mailto:gilles.querret@nerim.net">Gilles QUERRET</a>
  **/
public class PCTCreateBase extends PCT {
    private static final int DEFAULT_BLOCK_SIZE = 8;
    private static final int DB_NAME_MAX_LENGTH = 11;
    private String dbName = null;
    private File destDir = null;
    private File structFile = null;
    private int blockSize = DEFAULT_BLOCK_SIZE;
    private boolean noInit = false;
    private boolean noSchema = false;
    private boolean overwrite = false;

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
        this.noSchema = noSchema;
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
        this.overwrite = overwrite;
    }

    /**
     * Do the work
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        ExecTask exec = null;

        // Checking there is at least an init or a structure creation
        if (this.noSchema && this.noInit) {
            throw new BuildException("noInit et noSchema");
        }

        // Checking structure file argument is given
        if (!this.noSchema && (this.structFile == null)) {
            throw new BuildException("No structure file defined");
        }

        // Checking length of the database name
        if (this.dbName.length() > DB_NAME_MAX_LENGTH) {
            throw new BuildException("Database name is longer than 11 characters");
        }

        // Checks if DB already exists
        File db = new File(destDir, dbName + ".db");

        if (db.exists()) {
            if (this.overwrite) {
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

        if (!this.noSchema) {
            exec = structCmdLine();
            exec.execute();
        }

        if (!this.noInit) {
            exec = initCmdLine();
            exec.execute();
        }
    }

    /**
     *
     * @return
     */
    private ExecTask initCmdLine() {
        ExecTask exec = (ExecTask) getProject().createTask("exec");
        File srcDB = new File(this.getDlcHome(), "empty" + this.blockSize);

        exec.setOwningTarget(this.getOwningTarget());
        exec.setTaskName(this.getTaskName());
        exec.setDescription(this.getDescription());

        exec.setExecutable(getExecPath("_dbutil").toString());
        exec.setDir(this.destDir);
        exec.createArg().setValue("procopy");
        exec.createArg().setValue(srcDB.getAbsolutePath());
        exec.createArg().setValue(this.dbName);

        return exec;
    }

    /**
     *
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

        return exec;
    }
}
