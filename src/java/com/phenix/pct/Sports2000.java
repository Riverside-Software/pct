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

import java.io.File;
import java.util.Iterator;

/**
 * Class for creating a sports2000 database
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class Sports2000 extends PCT {
    private static final int DB_NAME_MAX_LENGTH = 11;

    private String dbName = null;
    private File destDir = null;
    private boolean overwrite = false;

    /**
     * Database name
     * 
     * @param dbName String
     */
    public void setDBName(String dbName) {
        this.dbName = dbName;
    }

    /**
     * In which directory create the database
     * 
     * @param destDir File
     */
    public void setDestDir(File destDir) {
        this.destDir = destDir;
    }

    /**
     * Overwrite database if existent
     * 
     * @param overwrite "true|false|on|off|yes|no"
     */
    public void setOverwrite(boolean overwrite) {
        log(Messages.getString("PCTCreateBase.1")); //$NON-NLS-1$
        this.overwrite = overwrite;
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        checkDlcHome();

        // If dbName is null, then it's sports2000
        if (dbName == null) {
            dbName = "sports2000"; //$NON-NLS-1$
        }

        // Checking length of the database name
        if (dbName.length() > DB_NAME_MAX_LENGTH) {
            throw new BuildException(Messages.getString("PCTCreateBase.4")); //$NON-NLS-1$
        }

        // Update destDir if not defined
        if (destDir == null) {
            destDir = getProject().getBaseDir();
        }

        // Checks if DB already exists
        File db = new File(destDir, dbName + ".db"); //$NON-NLS-1$
        if (db.exists()) {
            if (this.overwrite) {
                Delete del = new Delete();
                del.bindToOwner(this);
                del.setFile(db);
                del.execute();
            } else {
                return;
            }
        }

        ExecTask exec = initCmdLine();
        exec.execute();
    }

    /**
     * Creates the _dbutil procopy sports2000 command line
     * 
     * @return An ExecTask, ready to be executed
     */
    private ExecTask initCmdLine() {
        ExecTask exec = new ExecTask(this);
        exec.bindToOwner(this);

        exec.setDir(destDir);
        exec.setExecutable(getExecPath("_dbutil").toString()); //$NON-NLS-1$
        exec.createArg().setValue("procopy"); //$NON-NLS-1$
        exec.createArg().setValue(new File(getDlcHome(), "sports2000").getAbsolutePath()); //$NON-NLS-1$
        exec.createArg().setValue(dbName);

        Environment.Variable var = new Environment.Variable();
        var.setKey("DLC"); //$NON-NLS-1$
        var.setValue(this.getDlcHome().toString());
        exec.addEnv(var);

        for (Iterator iter = getEnvironment().getVariablesVector().iterator(); iter.hasNext();) {
            exec.addEnv((Environment.Variable) iter.next());
        }

        return exec;
    }
}