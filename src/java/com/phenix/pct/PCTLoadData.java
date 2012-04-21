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

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.types.FileSet;

/**
 * Loads data into database
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
 * @version $Revision$
 */
public class PCTLoadData extends PCTRun {
    private File srcDir = null;
    private Collection tableList = null, tableFilesets = null;
    private String tables = null;

    // Internal use
    private int paramsId = -1;
    private File params = null;

    /**
     * Creates a new PCTLoadData object
     */
    public PCTLoadData() {
        super();

        paramsId = PCT.nextRandomInt();

        params = new File(System.getProperty("java.io.tmpdir"), "pct_params" + paramsId + ".txt"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
    }

    /**
     * Input directory
     * 
     * @param srcDir directory
     */
    public void setSrcDir(File srcDir) {
        this.srcDir = srcDir;
    }

    /**
     * Tables list to dump
     * 
     * @param tables the tables to dump
     */
    public void setTables(String tables) {
        this.tables = tables;
    }

    public void addConfiguredTable(PCTTable table) {
        if (this.tableList == null) {
            tableList = new ArrayList();
        }
        tableList.add(table);
    }

    /**
     * Adds a set of files to load
     * 
     * @param set FileSet
     */
    public void addConfiguredFileset(FileSet set) {
        if (this.tableFilesets == null) {
            tableFilesets = new ArrayList();
        }
        tableFilesets.add(set);
    }

    private String getTableList() {
        StringBuffer sb = new StringBuffer();
        if (tables != null)
            sb.append(tables);

        if (tableList != null) {
            for (Iterator iter = tableList.iterator(); iter.hasNext();) {
                PCTTable tbl = (PCTTable) iter.next();
                if (sb.length() > 0)
                    sb.append(',');
                sb.append(tbl.getName());
            }
        }
        if (tableFilesets != null) {
            for (Iterator e = tableFilesets.iterator(); e.hasNext();) {
                // Parse filesets
                FileSet fs = (FileSet) e.next();

                // And get files from fileset
                String[] dsfiles = fs.getDirectoryScanner(this.getProject()).getIncludedFiles();

                for (int i = 0; i < dsfiles.length; i++) {
                    String file = dsfiles[i];
                    if (file.endsWith(".d")) {
                        if (sb.length() > 0) {
                            sb.append(',');
                        }
                        sb.append(file.substring(0, file.lastIndexOf(".d")));
                    }
                }
            }
        }

        if (sb.length() == 0) {
            return "ALL";
        } else {
            return sb.toString();
        }
    }

    /**
     * 
     * @throws BuildException
     */
    private void writeParams() throws BuildException {
        try {
            BufferedWriter bw = new BufferedWriter(new FileWriter(params));
            String tbl = getTableList();
            log("Loading with TABLES=" + tbl, Project.MSG_VERBOSE);
            if (tbl != null) {
                bw.write("TABLES=");
                bw.write(tbl);
                bw.newLine();
            }
            bw.write("SRCDIR=" + srcDir.getAbsolutePath()); //$NON-NLS-1$
            bw.newLine();
            bw.close();
        } catch (IOException ioe) {
            throw new BuildException(Messages.getString("PCTCompile.3")); //$NON-NLS-1$
        }
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {

        if (this.dbConnList == null) {
            this.cleanup();
            throw new BuildException(Messages.getString("PCTLoadData.0")); //$NON-NLS-1$
        }

        if (this.dbConnList.size() > 1) {
            this.cleanup();
            throw new BuildException(Messages.getString("PCTLoadData.1")); //$NON-NLS-1$
        }

        if (this.srcDir == null) {
            this.cleanup();
            throw new BuildException(Messages.getString("PCTLoadData.2")); //$NON-NLS-1$
        }

        try {
            writeParams();
            this.setProcedure("pct/pctLoadData.p"); //$NON-NLS-1$
            this.setParameter(params.getAbsolutePath());
            super.execute();
            this.cleanup();
        } catch (BuildException be) {
            this.cleanup();
            throw be;
        }
    }
}
