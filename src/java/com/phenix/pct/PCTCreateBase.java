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
import org.apache.tools.ant.types.Commandline;

import java.io.File;


/**
  * Class for creating Progress databases
  **/
public class PCTCreateBase extends PCT {
    private String dbName = null;
    private File destDir = null;
    private File structFile = null;
    private int blockSize = 8;
    private boolean noInit = false;
    private boolean noSchema = false;

    public void setStructFile(File structFile) {
        this.structFile = structFile;
    }

    public void setDBName(String dbName) {
        this.dbName = dbName;
    }

    public void setNoInit(boolean noInit) {
        this.noInit = noInit;
    }

    public void setNoSchema(boolean noSchema) {
        this.noSchema = noSchema;
    }

    public void setBlockSize(int blockSize) {
        this.blockSize = blockSize;
    }

    public void setDestDir(File destDir) {
        this.destDir = destDir;
    }

    protected File getDestDir() {
        if (destDir == null) {
            return project.getBaseDir();
        } else {
            return destDir;
        }
    }

    public void execute() throws BuildException {
        int result = 0;
        Commandline cmdLine = null;

        // Checking there is at least an init or a structure creation
        if (this.noSchema && this.noInit) {
            throw new BuildException("noInit et noSchema");
        }

        // Checking structure file argument is given 
        if (!this.noSchema && (this.structFile == null)) {
            throw new BuildException("No structure file defined");
        }

        // Checking length of the database name
        if (this.dbName.length() > 11) {
            throw new BuildException("Database name is longer than 11 characters");
        }

        if (!this.noSchema) {
            cmdLine = buildCreateCmdLine();

            result = run(cmdLine, this.getDestDir());

            if (result != 0) {
                throw new BuildException("Failed creating structure - Return code : " + result);
            }
        }

        if (!this.noInit) {
            cmdLine = buildInitCmdLine();

            result = run(cmdLine, this.getDestDir());

            if (result != 0) {
                throw new BuildException("Failed initializing database - Return code : " + result);
            }
        }
    }

    protected Commandline buildInitCmdLine() {
        File dlcHome = getDlcHome();
        Commandline cmdLine = new Commandline();
        cmdLine.setExecutable(getExecPath("_dbutil"));
        cmdLine.createArgument().setValue("procopy");

        if (dlcHome != null) {
            cmdLine.createArgument().setValue(dlcHome.getAbsolutePath() + File.separatorChar +
                                              "empty" + this.blockSize);
        } else {
            cmdLine.createArgument().setValue("empty" + this.blockSize);
        }

        cmdLine.createArgument().setValue(this.dbName);

        return cmdLine;
    }

    protected Commandline buildCreateCmdLine() {
        Commandline cmdLine = new Commandline();
        cmdLine.setExecutable(getExecPath("_dbutil"));
        cmdLine.createArgument().setValue("prostrct");
        cmdLine.createArgument().setValue("create");
        cmdLine.createArgument().setValue(this.dbName);
        cmdLine.createArgument().setValue(this.structFile.getAbsolutePath());

        return cmdLine;
    }

    protected Commandline buildProdbCmdLine() {
        Commandline cmdLine = new Commandline();
        cmdLine.setExecutable(getExecPath("_dbutil"));
        cmdLine.createArgument().setValue("prostrct");
        cmdLine.createArgument().setValue("create");
        cmdLine.createArgument().setValue(this.dbName);
        cmdLine.createArgument().setValue(this.structFile.getAbsolutePath());

        return cmdLine;
    }
}
