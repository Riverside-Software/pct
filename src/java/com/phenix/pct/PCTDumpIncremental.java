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
import org.apache.tools.ant.types.Environment;

import java.io.File;

import java.util.Iterator;


/**
 * Creates a schema diff file between two databases. This is a wrapper around
 * prodict/dump_inc.p from POSSENET code.
 * @author Phillip BAIRD
 * @author <a href="gilles.querret@nerim.net">Gilles QUERRET</a>
 */
public class PCTDumpIncremental extends PCTRun {
    private File destFile = null;
    private File renameFile = null;
    private boolean activeIndexes = true;
    private String codePage = null;
    private int debugLevel = 0;

    /**
     * Specifies if new indexes are created Active (true) or Inactive (false).
     * Defaults to Active.
     * @param activeIndexes boolean
     */
    public void setActiveIndexes(boolean activeIndexes) {
        this.activeIndexes = activeIndexes;
    }

    /**
     * Specifies the CodePage for the .df file.<ul>
     * <li>code-page = ?,""          : default conversion (SESSION:STREAM)</li>
     * <li>code-page = "<code-page>" : convert to &lt;code-page&gt;</li></ul>
     * @param codePage String
     * TODO : vérifier avec PCTRun 
     */
    public void setCodePage(String codePage) {
        this.codePage = codePage;
    }

    /**
     * Sets the debug level.<ul>
     * <li>0 = debug off (only errors and important warnings)</li>
     * <li>1 = all the above plus all warnings</li>
     * <li>2 = all the above plus config info</li></ul>
     * @param debugLevel integer
     */
    public void setDebugLevel(int debugLevel) {
        this.debugLevel = debugLevel;
    }

    /**
     * Output file for incremental df.
     * @param destFile File
     */
    public void setDestFile(File destFile) {
        this.destFile = destFile;
    }

    /**
     * The RenameFile parameter is used to identify tables, database fields
     * and sequences that have changed names. The format of the file is a comma
     * seperated list that identifies the renamed object, its old name and the new
     * name. When an object is found missing, this file is checked to determine if
     * it was renamed.  If no matching entry is found, then the object
     * TODO : finir le javadoc
     * If RenameFile is not defined, then all missing objects are deleted.
     * The RenameFile has following format:<ul>
     * <li>T,&lt;old-table-name&gt;,&lt;new-table-name&gt;</li>
     * <li>F,&lt;table-name&gt;,&lt;old-field-name&gt;,&lt;new-field-name&gt;</li>
     * <li>S,&lt;old-sequence-name&gt;,&lt;new-sequence-name&gt;</li></ul>
     * @param file File
     */
    public void setRenameFile(File file) {
        renameFile = file;
    }

    /**
     * Do the work
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        if (this.dbConnList == null) {
            throw new BuildException("No database connections defined");
        }

        if (this.dbConnList.size() != 2) {
            throw new BuildException("Two database connections must be defined");
        }

        if (!aliasDefined("dictdb")) {
            throw new BuildException("Master database must have DICTDB alias.");
        }

        if (!aliasDefined("dictdb2")) {
            throw new BuildException("Slave database must have DICTDB2 alias.");
        }

        if (this.destFile == null) {
            throw new BuildException("Mandatory argument : dump file");
        }

        this.prepareExecTask();

        this.setProcedure("prodict/dump_inc.p");

        Environment.Variable var = new Environment.Variable();
        var.setKey("DUMP_INC_DFFILE");
        var.setValue(this.destFile.toString());
        this.exec.addEnv(var);

        if (this.codePage != null) {
            Environment.Variable var2 = new Environment.Variable();
            var2.setKey("DUMP_INC_CODEPAGE");
            var2.setValue(this.destFile.toString());
            this.exec.addEnv(var2);
        }

        if (this.renameFile != null) {
            Environment.Variable var3 = new Environment.Variable();
            var3.setKey("DUMP_INC_RENAMEFILE");
            var3.setValue(this.destFile.toString());
            this.exec.addEnv(var3);
        }

        Environment.Variable var4 = new Environment.Variable();
        var4.setKey("DUMP_INC_INDEXMODE");
        var4.setValue(this.activeIndexes ? "active" : "inactive");
        this.exec.addEnv(var4);

        Environment.Variable var5 = new Environment.Variable();
        var5.setKey("DUMP_INC_DEBUG");
        var5.setValue(Integer.toString(this.debugLevel));
        this.exec.addEnv(var5);

        super.execute();
    }

    /**
     * Validates a database connection exists with the supplied alias.
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
