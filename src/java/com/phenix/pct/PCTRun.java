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
import org.apache.tools.ant.taskdefs.ExecTask;
import org.apache.tools.ant.types.Path;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import java.util.Enumeration;
import java.util.Vector;


/**
 * Run a Progress procedure.
 * @author <a href="mailto:gilles.querret@nerim.net">Gilles QUERRET</a>
 */
public class PCTRun extends PCT {
    // Attributes
    private boolean graphMode = false;
    private String procedure = null;
    private int inputChars = 0;
    private String cpStream = null;
    private String cpInternal = null;
    private String parameter = null;
    private File status = null;
    private int dirSize = 0;
    private int centuryYearOffset = 0;
    private int token = 0;
    private int maximumMemory = 0;
    private int stackSize = 0;
    protected boolean debugPCT = false;
    protected Vector dbConnList = null;
    protected Path propath = null;

    // Internal use
    protected ExecTask exec = null;
    private boolean compileUnderscore = false;
    private File initProc = null;
    private boolean isPrepared = false;

    /**
     * Default constructor
     *
     */
    public PCTRun() {
        super();

        try {
            status = File.createTempFile("PCTResult", ".out");
            initProc = File.createTempFile("pct_init", ".p");
        } catch (IOException ioe) {
            throw new BuildException("Unable to create temp files");
        }
    }

    /**
     * Adds a database connection
     * @param dbConn Instance of DBConnection class
     */
    public void addPCTConnection(PCTConnection dbConn) {
        if (this.dbConnList == null) {
            this.dbConnList = new Vector();
        }

        this.dbConnList.addElement(dbConn);
    }

    /**
     * Parameter (-param attribute)
     * @param param String
     */
    public void setParameter(String param) {
        this.parameter = param;
    }

    /**
     * Turns on/off debugging mode (keeps Progress temp files on disk)
     * @param debugPCT boolean
     */
    public void setDebugPCT(boolean debugPCT) {
        this.debugPCT = debugPCT;
    }

    /**
     * If files beginning with an underscore should be compiled (-zn option)
     * See POSSE documentation for more details
     * @param compUnderscore boolean
     */
    public void setCompileUnderscore(boolean compUnderscore) {
        this.compileUnderscore = compUnderscore;
    }

    /**
     * The number of compiled procedure directory entries (-D attribute)
     * @param dirSize int
     */
    public void setDirSize(int dirSize) {
        this.dirSize = dirSize;
    }

    /**
     * Graphical mode on/off (call to _progres or prowin32)
     * @param graphMode boolean
     */
    public void setGraphicalMode(boolean graphMode) {
        this.graphMode = graphMode;
    }

    /**
     * Procedure to be run (not -p param, this parameter is always pct_initXXX.p)
     * @param procedure String
     */
    public void setProcedure(String procedure) {
        this.procedure = procedure;
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

    /*public void addPropathRef(Reference r) {
        this.propath.setRefid(r);
    }*/

    /**
     * Stream code page (-cpstream attribute)
     * @param cpStream String
     */
    public void setCpStream(String cpStream) {
        this.cpStream = cpStream;
    }

    /**
     * Internal code page (-cpinternal attribute)
     * @param cpInternal String
     */
    public void setCpInternal(String cpInternal) {
        this.cpInternal = cpInternal;
    }

    /**
     * The number of characters allowed in a single statement (-inp attribute)
     * @param inputChars Integer
     */
    public void setInputChars(int inputChars) {
        this.inputChars = inputChars;
    }

    /**
     * Century year offset (-yy attribute)
     * @param centuryYearOffset Integer
     */
    public void setCenturyYearOffset(int centuryYearOffset) {
        this.centuryYearOffset = centuryYearOffset;
    }

    /**
     * The number of tokens allowed in a 4GL statement (-tok attribute)
     * @param token int
     */
    public void setToken(int token) {
        this.token = token;
    }

    /**
     * The amount of memory allocated for r-code segments
     * @param maximumMemory int
     */
    public void setMaximumMemory(int maximumMemory) {
        this.maximumMemory = maximumMemory;
    }

    /**
     * The size of the stack in 1KB units.
     * @param stackSize int
     */
    public void setStackSize(int stackSize) {
        this.stackSize = stackSize;
    }

    /**
     * Returns status file name (where to write progress procedure result)
     * @return String
     */
    protected String getStatusFileName() {
        return status.getAbsolutePath();
    }

    /**
     * Do the work
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        if (!this.isPrepared) {
            this.prepareExecTask();
        }

        if (!this.debugPCT) {
            status.deleteOnExit();
            initProc.deleteOnExit();
        }

        this.createInitProcedure();
        this.setExecTaskParams();
        exec.execute();
        exec = null;

        // Now read status file
        try {
            BufferedReader br = new BufferedReader(new FileReader(status));
            String s = br.readLine();
            int ret = Integer.parseInt(s);

            if (ret != 0) {
                throw new BuildException("Return code : " + ret);
            }
        } catch (FileNotFoundException fnfe) {
        } catch (IOException ioe) {
        } catch (NumberFormatException nfe) {
            throw new BuildException("Progress procedure failed - No return value");
        }
    }

    /**
     * Creates and initialize
     * @throws BuildException
     */
    protected void prepareExecTask() throws BuildException {
        if (!this.isPrepared) {
            exec = (ExecTask) getProject().createTask("exec");
            exec.setOwningTarget(this.getOwningTarget());
            exec.setTaskName(this.getTaskName());
            exec.setDescription(this.getDescription());
        }

        this.isPrepared = true;
    }

    private void setExecTaskParams() {
        File a = this.getExecPath((this.graphMode ? "prowin32" : "_progres"));

        exec.setExecutable(a.toString());

        // Database connections
        if (dbConnList != null) {
            for (Enumeration e = dbConnList.elements(); e.hasMoreElements();) {
                PCTConnection dbc = (PCTConnection) e.nextElement();
                dbc.createArguments(exec);
            }
        }

        // Batch mode
        exec.createArg().setValue("-b");

        // Quick access to files
        exec.createArg().setValue("-q");

        // Startup procedure
        exec.createArg().setValue("-p");
        exec.createArg().setValue(this.initProc.getAbsolutePath());

        // Max length of a line
        if (this.inputChars != 0) {
            exec.createArg().setValue("-inp");
            exec.createArg().setValue("" + this.inputChars);
        }

        // Stream code page
        exec.createArg().setValue("-cpstream");
        exec.createArg().setValue(((this.cpStream == null) ? "undefined" : this.cpStream));

        // Internal code page
        exec.createArg().setValue("-cpinternal");
        exec.createArg().setValue(((this.cpInternal == null) ? "undefined" : this.cpInternal));

        // Directory size
        if (this.dirSize != 0) {
            exec.createArg().setValue("-D");
            exec.createArg().setValue(Integer.toString(this.dirSize));
        }

        if (this.centuryYearOffset != 0) {
            exec.createArg().setValue("-yy");
            exec.createArg().setValue(Integer.toString(this.centuryYearOffset));
        }

        if (this.maximumMemory != 0) {
            exec.createArg().setValue("-mmax");
            exec.createArg().setValue(Integer.toString(this.maximumMemory));
        }

        if (this.stackSize != 0) {
            exec.createArg().setValue("-s");
            exec.createArg().setValue(Integer.toString(this.stackSize));
        }

        if (this.token != 0) {
            exec.createArg().setValue("-tok");
            exec.createArg().setValue(Integer.toString(this.token));
        }

        if (this.compileUnderscore) {
            exec.createArg().setValue("-zn");
        }

        // Parameter
        if (this.parameter != null) {
            exec.createArg().setValue("-param");
            exec.createArg().setValue(this.parameter);
        }
    }

    private void createInitProcedure() throws BuildException {
        try {
            BufferedWriter bw = new BufferedWriter(new FileWriter(this.initProc));

            bw.write("DEFINE VARIABLE i AS INTEGER NO-UNDO INITIAL ?.");
            bw.newLine();

            // Defines aliases
            if (dbConnList != null) {
                for (Enumeration e = dbConnList.elements(); e.hasMoreElements();) {
                    PCTConnection dbc = (PCTConnection) e.nextElement();
                    Vector aliases = dbc.getAliases();

                    if (aliases != null) {
                        for (Enumeration e2 = aliases.elements(); e2.hasMoreElements();) {
                            PCTAlias alias = (PCTAlias) e2.nextElement();
                            bw.write("CREATE ALIAS '");
                            bw.write(alias.getName());
                            bw.write("' FOR DATABASE ");
                            bw.write(dbc.getDbName());

                            if (alias.getNoError()) {
                                bw.write(" NO-ERROR");
                            }

                            bw.write(".");
                            bw.newLine();
                        }
                    }
                }
            }

            // Defines PROPATH
            if (this.propath != null) {
                bw.write("ASSIGN PROPATH='");
                bw.write(this.propath.toString());
                bw.write(File.pathSeparatorChar + "' + PROPATH.");
                bw.newLine();
            }

            // TODO : vérifier que le programme compile avant de le lancer 
            bw.write("RUN VALUE('" + escapeString(this.procedure) + "') NO-ERROR.");
            bw.newLine();
            bw.write("IF ERROR-STATUS:ERROR THEN ASSIGN i = 1.");
            bw.newLine();
            bw.write("IF (i EQ ?) THEN ASSIGN i = INTEGER (RETURN-VALUE) NO-ERROR.");
            bw.newLine();
            bw.write("IF (i EQ ?) THEN ASSIGN i = 1.");
            bw.newLine();
            bw.write("OUTPUT TO VALUE('" + escapeString(status.getAbsolutePath()) + "').");
            bw.newLine();
            bw.write("PUT UNFORMATTED i SKIP.");
            bw.newLine();
            bw.write("OUTPUT CLOSE.");
            bw.newLine();
            bw.write("QUIT.");
            bw.newLine();
            bw.close();
        } catch (IOException ioe) {
            throw new BuildException();
        }
    }

    /**
     * Escapes a string so it does not accidentally contain Progress escape characters
     * @param str the input string
     * @return the escaped string
     */
    protected String escapeString(String str) {
        if (str == null) {
            return null;
        }

        int slen = str.length();
        StringBuffer res = new StringBuffer();

        for (int i = 0; i < slen; i++) {
            char c = str.charAt(i);

            switch (c) {
            case '\u007E':
                res.append("\u007E\u007E");

                break;

            case '\u0022':
                res.append("\u007E\u0027");

                break;

            case '\'':
                res.append("\u007E\u0027");

                break;

            default:
                res.append(c);
            }
        }

        return res.toString();
    }
}
