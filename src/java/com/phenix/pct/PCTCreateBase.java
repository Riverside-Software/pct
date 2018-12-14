/**
 * Copyright 2005-2018 Riverside Software
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

import java.io.File;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.List;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.ExecTask;
import org.apache.tools.ant.types.Environment;
import org.apache.tools.ant.types.Environment.Variable;
import org.apache.tools.ant.types.Path;
import org.apache.tools.ant.types.ResourceCollection;

/**
 * Class for creating Progress databases
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class PCTCreateBase extends PCT {
    private static final int DEFAULT_BLOCK_SIZE = 8;
    private static final int DB_NAME_MAX_LENGTH = 11;
    private static final String NEW_INSTANCE_FLAG = "-newinstance";
    private static final String RELATIVE_FLAG = "-relative";

    private String dbName = null;
    private String codepage = null;
    private File sourceDb = null;
    private File destDir = null;
    private File structFile = null;
    private File tempDir = null;
    private int blockSize = DEFAULT_BLOCK_SIZE;
    private boolean noInit = false;
    private String schema = null;
    private List<ResourceCollection> schemaResColl = new ArrayList<>();
    private Path propath = null;
    private int[] blocks = {0, 1024, 2048, 0, 4096, 0, 0, 0, 8192};
    private int wordRule = -1;
    private List<SchemaHolder> holders = null;
    private boolean failOnError = true;
    private boolean relative = false;
    private boolean enableLargeFiles = false;
    private boolean multiTenant = false;
    private boolean auditing = false;
    private String auditArea = null;
    private String auditIndexArea = null;
    private String collation = null;
    private String cpInternal = null;
    private boolean newInstance = false;
    private String numsep = null;
    private String numdec = null;
    private String cpStream = null;
    private String cpColl = null;
    private String cpCase = null;

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
     * Source database name. Leave empty to use emptyX. Not compatible with noInit
     * 
     * @param sourceDb
     */
    public void setSourceDb(File sourceDb) {
        this.sourceDb = sourceDb;
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
     * Temp directory (-T attribute) 
     */
    public void setTempDir(File tempDir) {
        this.tempDir = tempDir;
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
     * Load schema after creating database. They are loaded AFTER df files in the schema attribute.
     * 
     * @param rc Fileset
     */
    public void add(ResourceCollection rc) {
        schemaResColl.add(rc);
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
     * Sets the failOnError parameter. Defaults to true.
     * 
     * @param failOnError
     */
    public void setFailOnError(boolean failOnError) {
        this.failOnError = failOnError;
    }

    /**
     * Set relative option
     * 
     * @param relative
     */
    public void setRelative(boolean relative) {
        this.relative = relative;
    }

    /**
     * Enable LargeFiles
     * 
     * @param enableLargeFiles
     */
    public void setLargeFiles(boolean enableLargeFiles) {
        this.enableLargeFiles = enableLargeFiles;
    }

    @Deprecated
    public void setEnableLargeFiles(boolean enableLargeFiles) {
        setLargeFiles(enableLargeFiles);
    }

    /**
     * Enable auditing
     * 
     * @param auditing
     */
    public void setAuditing(boolean auditing) {
        this.auditing = auditing;
    }

    public void setAuditArea(String area) {
        this.auditArea = area;
    }

    public void setAuditIndexArea(String area) {
        this.auditIndexArea = area;
    }

    /**
     * Enable multiTenancy
     * 
     * @param multiTenant
     */
    public void setMultiTenant(boolean multiTenant) {
        this.multiTenant = multiTenant;
    }

    /**
     * Set the desired database collation (copy from $DLC/prolang or $DLC/prolang/codepage)
     * 
     * @param collation Collation name from prolang directory or codepage subdirectory
     */
    public void setCollation(String collation) {
        this.collation = collation;
    }

    /**
     * Internal code page (-cpinternal attribute)
     * 
     * @param cpInternal String
     */
    public void setCpInternal(String cpInternal) {
        this.cpInternal = cpInternal;
    }

    /**
     * Stream code page (-cpstream attribute)
     */
    public void setCpStream(String cpStream) {
        this.cpStream = cpStream;
    }

    /**
     * Collation table (-cpcoll attribute)
     */
    public void setCpColl(String cpColl) {
        this.cpColl = cpColl;
    }

    /**
     * Case table (-cpcase attribute)
     */
    public void setCpCase(String cpCase) {
        this.cpCase = cpCase;
    }

    /**
     * Enable new instance of the database
     * 
     * @param isNewInstance
     */
    public void setNewInstance(boolean isNewInstance) {
        this.newInstance = isNewInstance;
    }

    /**
     * Thousands separator (-numsep attribute)
     * 
     * @param numsep String
     */
    public void setNumSep(String numsep) {
        this.numsep = numsep;
    }

    /**
     * Decimal separator (-numdec attribute)
     * 
     * @param numdec String
     */
    public void setNumDec(String numdec) {
        this.numdec = numdec;
    }


    /**
     * Adds an Oracle schema holder
     * 
     * @param holder Instance of OracleHolder
     */
    public void addOracleHolder(OracleHolder holder) {
        if (this.holders == null) {
            this.holders = new ArrayList<>();
        }
        this.holders.add(holder);
    }

    /**
     * Adds an SQL Server schema holder
     * 
     * @param holder Instance of MSSHolder
     */
    public void addMSSHolder(MSSHolder holder) {
        if (this.holders == null) {
            this.holders = new ArrayList<>();
        }
        this.holders.add(holder);
    }

    /**
     * Adds an ODBC schema holder
     * 
     * @param holder Instance of ODBCHolder
     */
    public void addODBCHolder(ODBCHolder holder) {
        if (this.holders == null) {
            this.holders = new ArrayList<>();
        }
        this.holders.add(holder);
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    @Override
    public void execute() {
        ExecTask exec;

        checkDlcHome();

        // Checking there is at least an init or a structure creation
        if ((structFile == null) && noInit) {
            throw new BuildException(Messages.getString("PCTCreateBase.2")); //$NON-NLS-1$
        }

        // Checking dbName is defined
        if (dbName == null) {
            throw new BuildException(Messages.getString("PCTCreateBase.3")); //$NON-NLS-1$
        }

        // If schema holders defined, then no Progress schema can be loaded
        if ((holders != null) && (!holders.isEmpty())) {
            if ((schema != null) && (schema.trim().length() > 0)) {
                throw new BuildException("On peut pas !!!");
            }
            // noInit also cannot be set to true
            if (noInit) {
                throw new BuildException("on peut pas non plus !!");
            }
        }

        // Update destDir if not defined
        if (destDir == null) {
            destDir = getProject().getBaseDir();
        }

        // Checking length of the database name
        if (dbName.length() > DB_NAME_MAX_LENGTH) {
            throw new BuildException(Messages.getString("PCTCreateBase.4")); //$NON-NLS-1$
        }

        // Check collation
        if ((collation != null) && (collation.length() > 0)) {
            File srcDir = getDlcHome();
            srcDir = new File(srcDir, "prolang"); //$NON-NLS-1$
            if (codepage != null) {
                srcDir = new File(srcDir, codepage);
            }
            File collDF = new File(srcDir, collation + ".df"); //$NON-NLS-1$          
            if (!collDF.exists())
                throw new BuildException(MessageFormat.format(
                        Messages.getString("PCTCreateBase.90"), collDF.getAbsolutePath()));
            if (schema != null)
                schema = schema + "," + collDF.getAbsolutePath();
            else
                schema = collDF.getAbsolutePath();
        }

        // NoInit and sourceDb are mutually exclusive
        if (noInit && (sourceDb != null)) {
            throw new BuildException(Messages.getString("PCTCreateBase.7"));
        }
        // Codepage and sourceDb are mutually exclusive
        if ((codepage != null) && (sourceDb != null)) {
            throw new BuildException(Messages.getString("PCTCreateBase.8"));
        }

        // Checks if DB already exists
        File db = new File(destDir, dbName + ".db"); //$NON-NLS-1$
        if (db.exists()) {
            log("Database " + dbName + " already exists");
            return;
        }

        if (structFile != null) {
            if (!structFile.exists())
                throw new BuildException(MessageFormat.format(
                        Messages.getString("PCTCreateBase.6"), structFile.getAbsolutePath()));
            log(MessageFormat.format("Generating {0} structure", dbName));
            exec = structCmdLine();
            exec.execute();
        }

        if (!noInit) {
            exec = initCmdLine();
            exec.execute();
        }

        // Enable large files
        if (enableLargeFiles) {
            exec = enableLargeFilesCmdLine();
            exec.execute();
        }

        // Multi-Tenant database
        if ((getDLCMajorVersion() >= 11) && (multiTenant)) {
            exec = multiTenantCmdLine();
            exec.execute();
        }

        // Enable auditing
        if ((getDLCMajorVersion() >= 10) && (auditing)) {
            exec = enableAuditingCmdLine();
            exec.execute();
        }

        // Word rules are loaded before schema to avoid problems with newly created indexes
        if (wordRule != -1) {
            exec = wordRuleCmdLine();
            exec.execute();
        }

        if (schema != null) {
            String[] v = schema.split(",");
            for (int i = 0; i < v.length; i++) {
                String sc = v[i];
                // Bug #1245992 : use Project#resolveFile(String)
                File f = getProject().resolveFile(sc);
                if (f.isFile() && f.canRead()) {
                    PCTLoadSchema pls = createLoadSchemaTask();
                    pls.setSrcFile(f);
                    pls.execute();
                } else {
                    throw new BuildException(MessageFormat.format(
                            Messages.getString("PCTCreateBase.5"), f));
                }
            }
        }

        if (!schemaResColl.isEmpty()) {
            PCTLoadSchema pls = createLoadSchemaTask();
            for (ResourceCollection fs : schemaResColl) {
                pls.add(fs);
            }
            pls.execute();
        }

        // If a collation is loaded, indexes needs to be rebuilded
        if (collation != null) {
            exec = indexRebuildAllCmdLine();
            exec.execute();
        }

        if (holders != null) {
            for (SchemaHolder holder : holders) {
                PCTRun run = new PCTRun();
                run.bindToOwner(this);
                run.setDlcHome(getDlcHome());
                run.setDlcBin(getDlcBin());
                run.addPropath(propath);
                run.setIncludedPL(getIncludedPL());
                run.setProcedure(holder.getProcedure());
                run.setParameters(holder.getParameters());
                run.setTempDir(tempDir);
                run.setCpInternal(cpInternal);
                run.setCpStream(cpStream);
                run.setCpColl(cpColl);
                run.setCpCase(cpCase);

                PCTConnection pc = new PCTConnection();
                pc.setDbName(dbName);
                pc.setDbDir(destDir);
                pc.setSingleUser(true);
                run.addDBConnection(pc);
                run.execute();

                if (holder.getSchemaFile() != null) {
                    PCTLoadSchema pls = createLoadSchemaTask();
                    pls.setSrcFile(holder.getSchemaFile());
                    pls.execute();
                }
            }
        }
    }

    private PCTLoadSchema createLoadSchemaTask() {
        PCTLoadSchema task = new PCTLoadSchema();
        task.bindToOwner(this);
        task.setDlcHome(getDlcHome());
        task.setDlcBin(getDlcBin());
        task.addPropath(propath);
        task.setIncludedPL(getIncludedPL());
        task.setFailOnError(failOnError);
        task.setNumDec(numdec);
        task.setNumSep(numsep);
        task.setTempDir(tempDir);
        task.setCpInternal(cpInternal);
        task.setCpStream(cpStream);
        task.setCpColl(cpColl);
        task.setCpCase(cpCase);

        for (Variable var : getEnvironmentVariables()) {
            task.addEnv(var);
        }

        PCTConnection pc = new PCTConnection();
        pc.setDbName(dbName);
        pc.setDbDir(destDir);
        pc.setSingleUser(true);
        task.addDBConnection(pc);

        return task;
    }

    /**
     * Creates the _dbutil procopy emptyX command line
     * 
     * @return An ExecTask, ready to be executed
     */
    private ExecTask initCmdLine() {
        ExecTask exec = new ExecTask(this);

        File srcDB;
        if (sourceDb != null) {
            srcDB = sourceDb;
        } else {
            File srcDir = getDlcHome();
            if (codepage != null) {
                srcDir = new File(srcDir, "prolang"); //$NON-NLS-1$
                srcDir = new File(srcDir, codepage);
            }
            srcDB = new File(srcDir, "empty" + blockSize); //$NON-NLS-1$
        }
        log(MessageFormat.format("Copying DB {1} to {0}", dbName, srcDB.getAbsolutePath()));

        exec.setExecutable(getExecPath("_dbutil").toString()); //$NON-NLS-1$
        exec.setDir(destDir);
        exec.setOutput(new File(destDir, dbName + ".procopy.log"));
        exec.createArg().setValue("procopy"); //$NON-NLS-1$
        exec.createArg().setValue(srcDB.getAbsolutePath());
        exec.createArg().setValue(dbName);
        if (newInstance)
            exec.createArg().setValue(NEW_INSTANCE_FLAG);
        if (relative)
            exec.createArg().setValue(RELATIVE_FLAG);

        Environment.Variable var = new Environment.Variable();
        var.setKey("DLC"); //$NON-NLS-1$
        var.setValue(getDlcHome().toString());
        exec.addEnv(var);

        for (Variable var2 : getEnvironmentVariables()) {
            exec.addEnv(var2);
        }

        return exec;
    }

    /**
     * Creates the _dbutil prostrct create command line
     * 
     * @return An ExecTask, ready to be executed
     */
    private ExecTask structCmdLine() {
        ExecTask exec = new ExecTask(this);
        exec.setExecutable(getExecPath("_dbutil").toString()); //$NON-NLS-1$
        exec.setDir(destDir);
        exec.setOutput(new File(destDir, dbName + ".prostrct.log"));
        exec.createArg().setValue("prostrct"); //$NON-NLS-1$
        exec.createArg().setValue("create"); //$NON-NLS-1$
        exec.createArg().setValue(dbName);
        exec.createArg().setValue(structFile.getAbsolutePath());
        exec.createArg().setValue("-blocksize"); //$NON-NLS-1$
        exec.createArg().setValue(Integer.toString(blocks[blockSize]));

        Environment.Variable var = new Environment.Variable();
        var.setKey("DLC"); //$NON-NLS-1$
        var.setValue(getDlcHome().toString());
        exec.addEnv(var);

        for (Variable var2 : getEnvironmentVariables()) {
            exec.addEnv(var2);
        }

        return exec;
    }

    private ExecTask wordRuleCmdLine() {
        ExecTask exec = new ExecTask(this);
        exec.setExecutable(getExecPath("_dbutil").toString()); //$NON-NLS-1$
        exec.setDir(destDir);
        exec.createArg().setValue(dbName);
        exec.createArg().setValue("-C"); //$NON-NLS-1$
        exec.createArg().setValue("word-rules"); //$NON-NLS-1$
        exec.createArg().setValue(String.valueOf(wordRule));

        Environment.Variable var = new Environment.Variable();
        var.setKey("DLC"); //$NON-NLS-1$
        var.setValue(getDlcHome().toString());
        exec.addEnv(var);

        for (Variable var2 : getEnvironmentVariables()) {
            exec.addEnv(var2);
        }

        return exec;
    }

    private ExecTask multiTenantCmdLine() {
        ExecTask exec = new ExecTask(this);
        exec.setExecutable(getExecPath("_dbutil").toString()); //$NON-NLS-1$
        exec.setDir(destDir);
        exec.createArg().setValue(dbName);
        exec.createArg().setValue("-C"); //$NON-NLS-1$
        exec.createArg().setValue("enablemultitenancy"); //$NON-NLS-1$

        Environment.Variable var = new Environment.Variable();
        var.setKey("DLC"); //$NON-NLS-1$
        var.setValue(getDlcHome().toString());
        exec.addEnv(var);

        for (Variable var2 : getEnvironmentVariables()) {
            exec.addEnv(var2);
        }

        return exec;
    }

    private ExecTask enableLargeFilesCmdLine() {
        ExecTask exec = new ExecTask(this);
        exec.setExecutable(getExecPath("_dbutil").toString()); //$NON-NLS-1$
        exec.setDir(destDir);
        exec.createArg().setValue(dbName);
        exec.createArg().setValue("-C"); //$NON-NLS-1$
        exec.createArg().setValue("enablelargefiles"); //$NON-NLS-1$

        Environment.Variable var = new Environment.Variable();
        var.setKey("DLC"); //$NON-NLS-1$
        var.setValue(getDlcHome().toString());
        exec.addEnv(var);

        for (Variable var2 : getEnvironmentVariables()) {
            exec.addEnv(var2);
        }

        return exec;
    }

    private ExecTask enableAuditingCmdLine() {
        ExecTask exec = new ExecTask(this);
        exec.setExecutable(getExecPath("_dbutil").toString()); //$NON-NLS-1$
        exec.setDir(destDir);
        exec.createArg().setValue(dbName);
        exec.createArg().setValue("-C"); //$NON-NLS-1$
        exec.createArg().setValue("enableauditing"); //$NON-NLS-1$
        exec.createArg().setValue("area"); //$NON-NLS-1$
        exec.createArg().setValue(auditArea); //$NON-NLS-1$
        if (auditIndexArea != null) {
            exec.createArg().setValue("indexarea"); //$NON-NLS-1$
            exec.createArg().setValue(auditIndexArea); //$NON-NLS-1$
        }

        Environment.Variable var = new Environment.Variable();
        var.setKey("DLC"); //$NON-NLS-1$
        var.setValue(getDlcHome().toString());
        exec.addEnv(var);

        for (Variable var2 : getEnvironmentVariables()) {
            exec.addEnv(var2);
        }

        return exec;
    }

    private ExecTask indexRebuildAllCmdLine() {
        ExecTask exec = new ExecTask(this);
        exec.setExecutable(getExecPath("_dbutil").toString()); //$NON-NLS-1$
        exec.setDir(destDir);
        exec.createArg().setValue(dbName);
        exec.createArg().setValue("-C"); //$NON-NLS-1$
        exec.createArg().setValue("idxbuild"); //$NON-NLS-1$
        exec.createArg().setValue("all"); //$NON-NLS-1$
        if (cpInternal != null) {
            exec.createArg().setValue("-cpinternal"); //$NON-NLS-1$
            exec.createArg().setValue(cpInternal);
        }
        exec.createArg().setValue("-cpcoll"); //$NON-NLS-1$
        if ("_tran".equalsIgnoreCase(collation))
            exec.createArg().setValue("BASIC");
        else
            exec.createArg().setValue(collation);

        Environment.Variable var = new Environment.Variable();
        var.setKey("DLC"); //$NON-NLS-1$
        var.setValue(getDlcHome().toString());
        exec.addEnv(var);

        for (Variable var2 : getEnvironmentVariables()) {
            exec.addEnv(var2);
        }

        return exec;
    }

}