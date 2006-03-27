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
import org.apache.tools.ant.util.StringUtils;

import java.io.File;
import java.text.MessageFormat;
import java.util.Iterator;
import java.util.List;
import java.util.Vector;

/**
 * Class for creating Progress databases
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET </a>
 * @version $Revision$
 */
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
    private String schema = null;
    private Path propath = null;
    private int[] blocks = {0, 1024, 2048, 0, 4096, 0, 0, 0, 8192};
    private int wordRule = -1;
    private List holders = null;

    /**
     * Structure file (.st)
     * 
     * @param structFile File
     */
    public void setStructFile(File structFile) {
        this.structFile = structFile;
    }

    /**
     * Database name
     * 
     * @param dbName String
     */
    public void setDBName(String dbName) {
        this.dbName = dbName;
    }

    /**
     * If database shouldn't be initialized
     * 
     * @param noInit "true|false|on|off|yes|no"
     */
    public void setNoInit(boolean noInit) {
        this.noInit = noInit;
    }

    /**
     * No schema
     * 
     * @param noSchema "true|false|on|off|yes|no"
     */
    public void setNoSchema(boolean noSchema) {
        this.log(Messages.getString("PCTCreateBase.0")); //$NON-NLS-1$
    }

    /**
     * Block size
     * 
     * @param blockSize int
     */
    public void setBlockSize(int blockSize) {
        this.blockSize = blockSize;
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
     * Load schema after creating database. Multiple schemas can be loaded : seperate them with
     * commas e.g. dump1.df,dump2.df,dump3.df
     * 
     * @param schemaFile String
     */
    public void setSchemaFile(String schemaFile) {
        this.schema = schemaFile;
    }

    /**
     * Set the propath to be used when running the procedure
     * 
     * @param propath an Ant Path object containing the propath
     */
    public void setPropath(Path propath) {
        createPropath().append(propath);
    }

    /**
     * Creates a new Path instance
     * 
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
     * 
     * @param codepage Subdirectory name from prolang directory where to find the empty database
     */
    public void setCodepage(String codepage) {
        this.codepage = codepage;
    }

    /**
     * Set the word file rule number applied to this database
     * 
     * @param wordRule Integer (0-255)
     */
    public void setWordRules(int wordRule) {
        if ((wordRule < 0) || (wordRule > 255))
            throw new BuildException("wordRule value should be between 0 and 255");
        this.wordRule = wordRule;
    }

    /**
     * 
     * @param holder
     */
    public void addHolder(SchemaHolder holder) {
        if (this.holders == null) {
            this.holders = new Vector();
        }
        this.holders.add(holder);
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        ExecTask exec = null;

        // TODO : rediriger la sortie standard
        // Checking there is at least an init or a structure creation
        if ((this.structFile == null) && this.noInit) {
            throw new BuildException(Messages.getString("PCTCreateBase.2")); //$NON-NLS-1$
        }

        // Checking dbName is defined
        if (this.dbName == null) {
            throw new BuildException(Messages.getString("PCTCreateBase.3")); //$NON-NLS-1$
        }

        // If schema holders defined, then no Progress schema can be loaded
        if ((this.holders != null) && (this.holders.size() > 0)) {
            if ((this.schema != null) && (this.schema.trim().length() > 0)) {
                throw new BuildException("On peut pas !!!");
            }
            // noInit also cannot be set to true
            if (this.noInit) {
                throw new BuildException("on peut pas non plus !!");
            }
        }

        // Update destDir if not defined
        if (this.destDir == null) {
            this.destDir = this.getProject().getBaseDir();
        }

        // Checking length of the database name
        if (this.dbName.length() > DB_NAME_MAX_LENGTH) {
            throw new BuildException(Messages.getString("PCTCreateBase.4")); //$NON-NLS-1$
        }

        // Checks if DB already exists
        File db = new File(destDir, dbName + ".db"); //$NON-NLS-1$

        if (db.exists()) {
            if (this.overwrite) {
                // TODO : revoir l'effacement de l'ancienne base
                Delete del = (Delete) getProject().createTask("delete"); //$NON-NLS-1$
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

        // Word rules are loaded before schema to avoid problems with newly created indexes
        if (this.wordRule != -1) {
            exec = wordRuleCmdLine();
            exec.execute();
        }

        if (this.schema != null) {
            Vector v = StringUtils.split(this.schema, ',');
            for (int i = 0; i < v.size(); i++) {
                String sc = (String) v.elementAt(i);
                // Bug #1245992 : first try as an absolute path
                File f = new File(sc);
                if (f.isFile() && !f.canRead())
                    throw new BuildException(MessageFormat.format(Messages
                            .getString("PCTCreateBase.5"), new Object[]{sc}));
                // Bug #1245992 : if this is not a file, then try relative path from ${basedir}
                if (!f.isFile())
                    f = new File(this.getProject().getBaseDir(), sc);
                if (f.isFile() && f.canRead()) {
                    PCTLoadSchema pls = (PCTLoadSchema) getProject().createTask("PCTLoadSchema"); //$NON-NLS-1$
                    pls.setOwningTarget(this.getOwningTarget());
                    pls.setTaskName(this.getTaskName());
                    pls.setDescription(this.getDescription());
                    pls.setSrcFile(f);
                    pls.setDlcHome(this.getDlcHome());
                    pls.setDlcBin(this.getDlcBin());
                    pls.setPropath(this.propath);
                    pls.setIncludedPL(this.getIncludedPL());

                    PCTConnection pc = new PCTConnection();
                    pc.setDbName(this.dbName);
                    pc.setDbDir(this.destDir);
                    pc.setSingleUser(true);
                    pls.addPCTConnection(pc);
                    pls.execute();
                } else {
                    throw new BuildException(MessageFormat.format(Messages
                            .getString("PCTCreateBase.5"), new Object[]{f}));
                }
            }
        }

        if (this.holders != null) {
            for (Iterator i = holders.iterator(); i.hasNext();) {
                SchemaHolder holder = (SchemaHolder) i.next();
                PCTRun run = (PCTRun) getProject().createTask("PCTRun"); //$NON-NLS-1$
                run.setOwningTarget(this.getOwningTarget());
                run.setTaskName(this.getTaskName());
                run.setDescription(this.getDescription());
                run.setDlcHome(this.getDlcHome());
                run.setDlcBin(this.getDlcBin());
                run.setPropath(this.propath);
                run.setIncludedPL(this.getIncludedPL());
                run.setProcedure("pct/holders.p");
                run.setParameter(holder.getDbName() + ";" + holder.getDbType() + ";"
                        + holder.getCodepage() + ";" + holder.getCollation() + ";"
                        + holder.getMisc());

                PCTConnection pc = new PCTConnection();
                pc.setDbName(this.dbName);
                pc.setDbDir(this.destDir);
                pc.setSingleUser(true);
                run.addPCTConnection(pc);
                run.execute();

                if (holder.getSchemaFile() != null) {
                    PCTLoadSchema pls = (PCTLoadSchema) getProject().createTask("PCTLoadSchema"); //$NON-NLS-1$
                    pls.setOwningTarget(this.getOwningTarget());
                    pls.setTaskName(this.getTaskName());
                    pls.setDescription(this.getDescription());
                    pls.setSrcFile(holder.getSchemaFile());
                    pls.setDlcHome(this.getDlcHome());
                    pls.setDlcBin(this.getDlcBin());
                    pls.setPropath(this.propath);
                    pls.addPCTConnection(pc);
                    pls.execute();

                }
            }
        }
    }

    /**
     * Creates the _dbutil procopy emptyX command line
     * 
     * @return An ExecTask, ready to be executed
     */
    private ExecTask initCmdLine() {
        ExecTask exec = (ExecTask) getProject().createTask("exec"); //$NON-NLS-1$

        File srcDir = this.getDlcHome();
        if (this.codepage != null) {
            srcDir = new File(srcDir, "prolang"); //$NON-NLS-1$
            srcDir = new File(srcDir, this.codepage);
        }
        File srcDB = new File(srcDir, "empty" + this.blockSize); //$NON-NLS-1$

        exec.setOwningTarget(this.getOwningTarget());
        exec.setTaskName(this.getTaskName());
        exec.setDescription(this.getDescription());

        exec.setExecutable(getExecPath("_dbutil").toString()); //$NON-NLS-1$
        exec.setDir(this.destDir);
        exec.createArg().setValue("procopy"); //$NON-NLS-1$
        exec.createArg().setValue(srcDB.getAbsolutePath());
        exec.createArg().setValue(this.dbName);

        Environment.Variable var = new Environment.Variable();
        var.setKey("DLC"); //$NON-NLS-1$
        var.setValue(this.getDlcHome().toString());
        exec.addEnv(var);

        return exec;
    }

    /**
     * Creates the _dbutil prostrct create command line
     * 
     * @return An ExecTask, ready to be executed
     */
    private ExecTask structCmdLine() {
        ExecTask exec = (ExecTask) getProject().createTask("exec"); //$NON-NLS-1$

        exec.setOwningTarget(this.getOwningTarget());
        exec.setTaskName(this.getTaskName());
        exec.setDescription(this.getDescription());

        exec.setExecutable(getExecPath("_dbutil").toString()); //$NON-NLS-1$
        exec.setDir(this.destDir);
        exec.createArg().setValue("prostrct"); //$NON-NLS-1$
        exec.createArg().setValue("create"); //$NON-NLS-1$
        exec.createArg().setValue(this.dbName);
        exec.createArg().setValue(this.structFile.getAbsolutePath());
        exec.createArg().setValue("-blocksize"); //$NON-NLS-1$
        exec.createArg().setValue(Integer.toString(blocks[this.blockSize]));

        Environment.Variable var = new Environment.Variable();
        var.setKey("DLC"); //$NON-NLS-1$
        var.setValue(this.getDlcHome().toString());
        exec.addEnv(var);

        return exec;
    }

    private ExecTask wordRuleCmdLine() {
        ExecTask exec = (ExecTask) getProject().createTask("exec"); //$NON-NLS-1$

        exec.setOwningTarget(this.getOwningTarget());
        exec.setTaskName(this.getTaskName());
        exec.setDescription(this.getDescription());

        exec.setExecutable(getExecPath("_proutil").toString()); //$NON-NLS-1$
        exec.setDir(this.destDir);
        exec.createArg().setValue(this.dbName);
        exec.createArg().setValue("-C"); //$NON-NLS-1$
        exec.createArg().setValue("word-rules"); //$NON-NLS-1$
        exec.createArg().setValue(String.valueOf(this.wordRule));

        Environment.Variable var = new Environment.Variable();
        var.setKey("DLC"); //$NON-NLS-1$
        var.setValue(this.getDlcHome().toString());
        exec.addEnv(var);

        return exec;
    }
}