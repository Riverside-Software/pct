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
import org.apache.tools.ant.Project;
import org.apache.tools.ant.taskdefs.ExecTask;
import org.apache.tools.ant.types.Environment;
import org.apache.tools.ant.types.Path;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * Binary dump task
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
 * @version $Revision$
 */
public class PCTBinaryDump extends PCT {
    private List dbConnList = null;
    private List patterns = new ArrayList();
    private File dest = null;
    private Path propath = null;

    private int tblListID = -1;
    private File tblListFile = null;

    /**
     * Default constructor
     * 
     */
    public PCTBinaryDump() {
        this(true);
    }

    /**
     * Default constructor
     * 
     * @param tmp True if temporary files need to be created
     */
    public PCTBinaryDump(boolean tmp) {
        super();

        tblListID = PCT.nextRandomInt();
        tblListFile = new File(System.getProperty("java.io.tmpdir"), "tblList" + tblListID + ".txt"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
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
     * Adds a database connection
     * 
     * @param dbConn Instance of DBConnection class
     * @deprecated
     */
    public void addPCTConnection(PCTConnection dbConn) {
        addDBConnection(dbConn);
    }

    public void addDBConnection(PCTConnection dbConn) {
        if (this.dbConnList == null) {
            this.dbConnList = new ArrayList();
        }

        this.dbConnList.add(dbConn);
    }

    public void addConfiguredInclude(Pattern inc) {
        if (this.patterns == null) {
            this.patterns = new ArrayList();
        }
        inc.setInclude(true);
        this.patterns.add(inc);
    }

    public void addConfiguredExclude(Pattern exc) {
        if (this.patterns == null) {
            this.patterns = new ArrayList();
        }
        exc.setInclude(false);
        this.patterns.add(exc);
    }

    public void setDest(File dest) {
        this.dest = dest;
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        BufferedReader reader = null;

        checkDlcHome();
        if (this.dbConnList == null) {
            throw new BuildException(Messages.getString("PCTBinaryLoad.1")); //$NON-NLS-1$
        }

        if (this.dbConnList.size() > 1) {
            throw new BuildException(MessageFormat.format(
                    Messages.getString("PCTBinaryLoad.2"), new Object[]{"1"})); //$NON-NLS-1$ //$NON-NLS-2$
        }

        if (this.dest == null) {
            throw new BuildException(Messages.getString("PCTBinaryDump.0")); //$NON-NLS-1$
        }

        try {
            PCTRun exec1 = getTables();
            exec1.execute();
        } catch (BuildException be) {
            this.cleanup();
            throw be;
        }

        String s = null;
        try {
            reader = new BufferedReader(new FileReader(tblListFile));
            while ((s = reader.readLine()) != null) {
                ExecTask exec2 = dumpTask(s);
                exec2.execute();
            }
            reader.close();
        } catch (IOException ioe) {
            try {
                reader.close();
            } catch (IOException ioe2) {
            }
            this.cleanup();
            throw new BuildException(Messages.getString("PCTBinaryDump.1")); //$NON-NLS-1$
        } catch (BuildException be) {
            try {
                reader.close();
            } catch (IOException ioe2) {
            }
            this.cleanup();
            throw be;
        }

        this.cleanup();
    }

    private ExecTask dumpTask(String table) throws BuildException {
        File executable = null;
        ExecTask exec = new ExecTask(this);
        
        if (getDLCMajorVersion() >= 10)
            executable = this.getExecPath("_dbutil"); //$NON-NLS-1$
        else
            executable = this.getExecPath("_proutil"); //$NON-NLS-1$
        
        Environment.Variable var = new Environment.Variable();
        var.setKey("DLC"); //$NON-NLS-1$
        var.setValue(this.getDlcHome().toString());
        exec.addEnv(var);

        exec.setExecutable(executable.toString());

        // Database connections
        for (Iterator e = dbConnList.iterator(); e.hasNext();) {
            PCTConnection dbc = (PCTConnection) e.next();
            dbc.createArguments(exec);
        }

        // Binary dump
        exec.createArg().setValue("-C"); //$NON-NLS-1$
        exec.createArg().setValue("dump"); //$NON-NLS-1$

        // Table to dump
        exec.createArg().setValue(table);

        // Output directory
        exec.createArg().setValue(dest.getAbsolutePath());

        return exec;
    }

    private PCTRun getTables() {
        PCTRun exec = new PCTRun();
        exec.bindToOwner(this);
        exec.setDlcHome(this.getDlcHome());
        exec.setProcedure("pct/pctBinaryDump.p"); //$NON-NLS-1$
        exec.setGraphicalMode(false);
        exec.addPropath(this.propath);

        // Database connections
        for (Iterator e = dbConnList.iterator(); e.hasNext();) {
            PCTConnection dbc = (PCTConnection) e.next();
            exec.addDBConnection(dbc);
        }

        StringBuffer sb = new StringBuffer();
        sb.append(tblListFile.getAbsolutePath());
        for (Iterator i = patterns.iterator(); i.hasNext();) {
            Pattern p = (Pattern) i.next();
            StringBuffer sb2 = new StringBuffer();
            sb2.append('|');
            sb2.append((p.isInclude() ? 'I' : 'E'));
            sb2.append('$');
            sb2.append(p.getName());
            sb.append(sb2);
        }
        exec.setParameter(sb.toString());

        return exec;
    }

    /**
     * Delete temporary files if debug not activated
     * 
     */
    protected void cleanup() {
        if (this.tblListFile.exists() && !this.tblListFile.delete()) {
            log(
                    MessageFormat
                            .format(
                                    Messages.getString("PCTBinaryDump.3"), new Object[]{this.tblListFile.getAbsolutePath()}), Project.MSG_VERBOSE); //$NON-NLS-1$
        }

    }

    public static class Include extends Pattern {
    }
    public static class Exclude extends Pattern {
    }

}
