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
import org.apache.tools.ant.types.Commandline;
import org.apache.tools.ant.types.Environment;
import org.apache.tools.ant.types.Path;
import org.apache.tools.ant.types.Commandline.Argument;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import java.text.MessageFormat;
import java.util.Collection;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.List;
import java.util.SortedSet;
import java.util.Vector;

/**
 * Run a Progress procedure.
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET </a>
 * @version $Revision$
 */
public class PCTRun extends PCT {
    // Attributes
    private String procedure = null;
    private String cpStream = null;
    private String cpInternal = null;
    private String parameter = null;
    private String numsep = null;
    private String numdec = null;
    private File paramFile = null;
    private File status = null;
    private File iniFile = null;
    private int inputChars = 0;
    private int dirSize = 0;
    private int centuryYearOffset = 0;
    private int token = 0;
    private int maximumMemory = 0;
    private int stackSize = 0;
    private int ttBufferSize = 0;
    private int messageBufferSize = 0;
    private int debugReady = -1;
    private boolean graphMode = false;
    private boolean debugPCT = false;
    private boolean compileUnderscore = false;
    protected Collection dbConnList = null;
    protected Path propath = null;

    // Internal use
    protected ExecTask exec = null;
    private File initProc = null;
    private boolean prepared = false;

    /**
     * Default constructor
     * 
     */
    public PCTRun() {
        super();

        try {
            status = File.createTempFile("PCTResult", ".out"); //$NON-NLS-1$ //$NON-NLS-2$
            initProc = File.createTempFile("pct_init", ".p"); //$NON-NLS-1$ //$NON-NLS-2$
        } catch (IOException ioe) {
            throw new BuildException(Messages.getString("PCTRun.0")); //$NON-NLS-1$
        }
    }

    /**
     * Adds a database connection
     * 
     * @param dbConn Instance of PCTConnection class
     */
    public void addPCTConnection(PCTConnection dbConn) {
        if (this.dbConnList == null) {
            this.dbConnList = new Vector();
        }

        this.dbConnList.add(dbConn);
    }

    /**
     * Parameter file (-pf attribute)
     * 
     * @param pf File
     */
    public void setParamFile(File pf) {
        this.paramFile = pf;
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
     * Parameter (-param attribute)
     * 
     * @param param String
     */
    public void setParameter(String param) {
        this.parameter = param;
    }

    /**
     * Turns on/off debugging mode (keeps Progress temp files on disk)
     * 
     * @param debugPCT boolean
     */
    public void setDebugPCT(boolean debugPCT) {
        this.debugPCT = debugPCT;
    }

// En prévision du passage en v10 uniquement 
//    public void setDebugReady(int debugReady) {
//    	if ((debugReady >= 0) && (debugReady <= 65535))
//    		this.debugReady = debugReady;
//    	else
//    		log("Port number for debugReady should be between 0 and 65535");
//    }

    /**
     * If files beginning with an underscore should be compiled (-zn option) See POSSE documentation
     * for more details
     * 
     * @param compUnderscore boolean
     */
    public void setCompileUnderscore(boolean compUnderscore) {
        this.compileUnderscore = compUnderscore;
    }

    /**
     * The number of compiled procedure directory entries (-D attribute)
     * 
     * @param dirSize int
     */
    public void setDirSize(int dirSize) {
        this.dirSize = dirSize;
    }

    /**
     * Graphical mode on/off (call to _progres or prowin32)
     * 
     * @param graphMode boolean
     */
    public void setGraphicalMode(boolean graphMode) {
        this.graphMode = graphMode;
    }

    /**
     * Sets .ini file to use (-basekey INI -ininame xxx)
     * 
     * @param iniFile File
     */
    public void setIniFile(File iniFile) {
        this.iniFile = iniFile;
    }

    /**
     * Procedure to be run (not -p param, this parameter is always pct_initXXX.p)
     * 
     * @param procedure String
     */
    public void setProcedure(String procedure) {
        this.procedure = procedure;
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

    /*
     * public void addPropathRef(Reference r) { this.propath.setRefid(r); }
     */

    /**
     * Stream code page (-cpstream attribute)
     * 
     * @param cpStream String
     */
    public void setCpStream(String cpStream) {
        this.cpStream = cpStream;
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
     * The number of characters allowed in a single statement (-inp attribute)
     * 
     * @param inputChars Integer
     */
    public void setInputChars(int inputChars) {
        this.inputChars = inputChars;
    }

    /**
     * Century year offset (-yy attribute)
     * 
     * @param centuryYearOffset Integer
     */
    public void setCenturyYearOffset(int centuryYearOffset) {
        this.centuryYearOffset = centuryYearOffset;
    }

    /**
     * The number of tokens allowed in a 4GL statement (-tok attribute)
     * 
     * @param token int
     */
    public void setToken(int token) {
        this.token = token;
    }

    /**
     * The amount of memory allocated for r-code segments
     * 
     * @param maximumMemory int
     */
    public void setMaximumMemory(int maximumMemory) {
        this.maximumMemory = maximumMemory;
    }

    /**
     * The size of the stack in 1KB units.
     * 
     * @param stackSize int
     */
    public void setStackSize(int stackSize) {
        this.stackSize = stackSize;
    }

    /**
     * Buffer Size for Temporary Tables (-Bt attribute)
     * 
     * @param ttBufferSize int
     */
    public void setTTBufferSize(int ttBufferSize) {
        this.ttBufferSize = ttBufferSize;
    }

    /**
     * Message buffer size (-Mm attribute)
     * 
     * @param msgBufSize int
     */
    public void setMsgBufferSize(int msgBufSize) {
        this.messageBufferSize = msgBufSize;
    }

    /**
     * Port number on which debugger should connect (-debugReady parameter)
     * 
     * @param debugReady int
     */
    public void setDebugReady(int debugReady) {
        this.debugReady = debugReady;
    }

    /**
     * Exec task is prepared ?
     * 
     * @return boolean
     */
    public boolean isPrepared() {
    	return this.prepared;
    }

    /**
     * Returns status file name (where to write progress procedure result)
     * 
     * @return String
     */
    protected String getStatusFileName() {
        return status.getAbsolutePath();
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        BufferedReader br = null;

        if (!this.prepared) {
            this.prepareExecTask();
        }

        this.createInitProcedure();
        this.setExecTaskParams();

        // Startup procedure
        exec.createArg().setValue("-p"); //$NON-NLS-1$
        exec.createArg().setValue(this.initProc.getAbsolutePath());

        try {
            exec.execute();
        } catch (BuildException be) {
            this.cleanup();
            throw be;
        }

        // Now read status file
        try {
            br = new BufferedReader(new FileReader(status));

            String s = br.readLine();
            br.close();

            this.cleanup();
            int ret = Integer.parseInt(s);

            if (ret != 0) {
                throw new BuildException(MessageFormat.format(
                        Messages.getString("PCTRun.6"), new Object[]{new Integer(ret)})); //$NON-NLS-1$
            }
        } catch (FileNotFoundException fnfe) {
            this.cleanup();
            throw new BuildException(Messages.getString("PCTRun.1")); //$NON-NLS-1$
        } catch (IOException ioe) {
            try {
                br.close();
            } catch (IOException ioe2) {
            }
            this.cleanup();
            throw new BuildException(Messages.getString("PCTRun.2")); //$NON-NLS-1$
        } catch (NumberFormatException nfe) {
            throw new BuildException(Messages.getString("PCTRun.3")); //$NON-NLS-1$
        }
    }

    /**
     * Creates and initialize
     */
    protected void prepareExecTask() {
        if (!this.prepared) {
            exec = (ExecTask) getProject().createTask("exec"); //$NON-NLS-1$
            exec.setOwningTarget(this.getOwningTarget());
            exec.setTaskName(this.getTaskName());
            exec.setDescription(this.getDescription());

            Environment.Variable var = new Environment.Variable();
            var.setKey("DLC"); //$NON-NLS-1$
            var.setValue(this.getDlcHome().toString());
            exec.addEnv(var);
        }

        this.prepared = true;
    }

    protected List getCmdLineParameters() {
    	List list = new Vector();

        // Parameter file
        if (this.paramFile != null) {
        	list.add("-pf"); //$NON-NLS-1$
        	list.add(this.paramFile.getAbsolutePath());
        }

        // Batch mode
        list.add("-b"); //$NON-NLS-1$
        list.add("-q"); //$NON-NLS-1$
        
        // DebugReady
        if (this.debugReady != -1) {
        	list.add("-debugReady"); //$NON-NLS-1$
        	list.add(Integer.toString(this.debugReady));
        }

        // Inifile
        if (this.iniFile != null) {
        	list.add("-basekey"); //$NON-NLS-1$
        	list.add("INI"); //$NON-NLS-1$
        	list.add("-ininame"); //$NON-NLS-1$
        	list.add(Commandline.quoteArgument(this.iniFile.getAbsolutePath()));
        }

        // Max length of a line
        if (this.inputChars != 0) {
        	list.add("-inp"); //$NON-NLS-1$
        	list.add(Integer.toString(this.inputChars));
        }

        // Stream code page
        if (this.cpStream != null) {
        	list.add("-cpstream"); //$NON-NLS-1$
        	list.add(this.cpStream);
        }

        // Internal code page
        if (this.cpInternal != null) {
        	list.add("-cpinternal"); //$NON-NLS-1$
        	list.add(this.cpInternal);
        }

        // Directory size
        if (this.dirSize != 0) {
        	list.add("-D"); //$NON-NLS-1$
        	list.add(Integer.toString(this.dirSize));
        }

        if (this.centuryYearOffset != 0) {
        	list.add("-yy"); //$NON-NLS-1$
        	list.add(Integer.toString(this.centuryYearOffset));
        }

        if (this.maximumMemory != 0) {
        	list.add("-mmax"); //$NON-NLS-1$
        	list.add(Integer.toString(this.maximumMemory));
        }

        if (this.stackSize != 0) {
        	list.add("-s"); //$NON-NLS-1$
        	list.add(Integer.toString(this.stackSize));
        }

        if (this.token != 0) {
        	list.add("-tok"); //$NON-NLS-1$
        	list.add(Integer.toString(this.token));
        }

        if (this.messageBufferSize != 0) {
        	list.add("-Mm"); //$NON-NLS-1$
        	list.add(Integer.toString(this.messageBufferSize));
        }

        if (this.compileUnderscore) {
        	list.add("-zn"); //$NON-NLS-1$
        }

        if (this.ttBufferSize != 0) {
        	list.add("-Bt"); //$NON-NLS-1$
        	list.add(Integer.toString(this.ttBufferSize));
        }

        if (this.numsep != null) {
            int tmpSep = 0;
            try {
                tmpSep = Integer.parseInt(this.numsep);
            } catch (NumberFormatException nfe) {
                if (this.numsep.length() == 1)
                    tmpSep = this.numsep.charAt(0);
                else
                    throw new BuildException(MessageFormat.format(Messages.getString("PCTRun.4"), //$NON-NLS-1$
                            new Object[]{"numsep"})); //$NON-NLS-1$
            }
            list.add("-numsep"); //$NON-NLS-1$
            list.add(Integer.toString(tmpSep));
        }

        if (this.numdec != null) {
            int tmpDec = 0;
            try {
                tmpDec = Integer.parseInt(this.numdec);
            } catch (NumberFormatException nfe) {
                if (this.numdec.length() == 1)
                    tmpDec = this.numdec.charAt(0);
                else
                    throw new BuildException(MessageFormat.format(Messages.getString("PCTRun.4"), //$NON-NLS-1$
                            new Object[]{"numdec"})); //$NON-NLS-1$
            }
            list.add("-numdec"); //$NON-NLS-1$
            list.add(Integer.toString(tmpDec));
        }

        // Parameter
        if (this.parameter != null) {
        	list.add("-param"); //$NON-NLS-1$
        	list.add(this.parameter);
        }
        
    	return list;
    }
    
    protected void setExecTaskParams() {
        File a = this.getExecPath((this.graphMode ? "prowin32" : "_progres")); //$NON-NLS-1$ //$NON-NLS-2$
        exec.setExecutable(a.toString());
        
        for (Iterator i = getCmdLineParameters().iterator(); i.hasNext(); ) {
        	exec.createArg().setValue((String) i.next());
        }
    }

    private void createInitProcedure() throws BuildException {
        try {
            BufferedWriter bw = new BufferedWriter(new FileWriter(this.initProc));

            bw.write("DEFINE VARIABLE i AS INTEGER NO-UNDO INITIAL ?."); //$NON-NLS-1$
            bw.newLine();

            // Defines aliases
            if (dbConnList != null) {
                for (Iterator i = dbConnList.iterator(); i.hasNext();) {
                    PCTConnection dbc = (PCTConnection) i.next();
                    bw.write("CONNECT VALUE(\"" + dbc.createConnectString() + "\") NO-ERROR."); //$NON-NLS-1$ //$NON-NLS-2$
                    bw.newLine();
                    bw.write("IF ERROR-STATUS:ERROR THEN RUN returnValue(14)."); //$NON-NLS-1$
                    bw.newLine();
                    
                    Collection aliases = dbc.getAliases();
                    if (aliases != null) {
                        for (Iterator i2 = aliases.iterator(); i2.hasNext();) {
                            PCTAlias alias = (PCTAlias) i2.next();
                            bw.write("CREATE ALIAS '"); //$NON-NLS-1$
                            bw.write(alias.getName());
                            bw.write("' FOR DATABASE "); //$NON-NLS-1$
                            bw.write(dbc.getDbName());

                            if (alias.getNoError()) {
                                bw.write(" NO-ERROR"); //$NON-NLS-1$
                            }

                            bw.write("."); //$NON-NLS-1$
                            bw.newLine();
                        }
                    }
                }
                bw.newLine();
            }

            // Defines PROPATH
            if (this.propath != null) {
                // Bug #1058733 : multiple assignments for propath, as a long propath
                // could lead to error 135 (More than xxx characters in a single
                // statement--use -inp parm)
                String[] lst = this.propath.list();
                for (int k = lst.length - 1; k >= 0; k--) {
                    bw.write("ASSIGN PROPATH='"); //$NON-NLS-1$
                    bw.write(lst[k]);
                    bw.write(File.pathSeparatorChar + "' + PROPATH."); //$NON-NLS-1$
                    bw.newLine();
                }
            }

            bw.write("  RUN VALUE('" + escapeString(this.procedure) + "') NO-ERROR."); //$NON-NLS-1$ //$NON-NLS-2$
            bw.newLine();
            bw.write("  IF ERROR-STATUS:ERROR THEN ASSIGN i = 1."); //$NON-NLS-1$
            bw.newLine();
            bw.write("  IF (i EQ ?) THEN ASSIGN i = INTEGER (RETURN-VALUE) NO-ERROR."); //$NON-NLS-1$
            bw.newLine();
            bw.write("  IF (i EQ ?) THEN ASSIGN i = 1."); //$NON-NLS-1$
            bw.newLine();
            bw.write("RUN returnValue(i)."); //$NON-NLS-1$
            bw.newLine();
            bw.write("PROCEDURE returnValue PRIVATE."); //$NON-NLS-1$
            bw.newLine();
            bw.write("  DEFINE INPUT PARAMETER retVal AS INTEGER NO-UNDO."); //$NON-NLS-1$
            bw.newLine();
            bw.write("  OUTPUT TO VALUE('" + escapeString(status.getAbsolutePath()) + "')."); //$NON-NLS-1$ //$NON-NLS-2$
            bw.newLine();
            bw.write("  PUT UNFORMATTED retVal SKIP."); //$NON-NLS-1$
            bw.newLine();
            bw.write("  OUTPUT CLOSE."); //$NON-NLS-1$
            bw.newLine();
            bw.write("  QUIT."); //$NON-NLS-1$
            bw.newLine();
            bw.write("END PROCEDURE"); //$NON-NLS-1$
            bw.newLine();
            bw.close();
        } catch (IOException ioe) {
            throw new BuildException();
        }
    }

    /**
     * Escapes a string so it does not accidentally contain Progress escape characters
     * 
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
                case '\u007E' :
                    res.append("\u007E\u007E"); //$NON-NLS-1$

                    break;

                case '\u0022' :
                    res.append("\u007E\u0027"); //$NON-NLS-1$

                    break;

                case '\'' :
                    res.append("\u007E\u0027"); //$NON-NLS-1$

                    break;

                default :
                    res.append(c);
            }
        }

        return res.toString();
    }

    /**
     * Return PCT Debug status
     * 
     * @return boolean
     */
    protected boolean getDebugPCT() {
        return this.debugPCT;
    }

    /**
     * Delete temporary files if debug not activated
     * 
     */
    protected void cleanup() {
        if (!this.debugPCT) {
            if (this.initProc.exists() && !this.initProc.delete()) {
                log(
                        MessageFormat
                                .format(
                                        Messages.getString("PCTRun.5"), new Object[]{this.initProc.getAbsolutePath()}), Project.MSG_VERBOSE); //$NON-NLS-1$
            }

            if (this.status.exists() && !this.status.delete()) {
                log(
                        MessageFormat
                                .format(
                                        Messages.getString("PCTRun.5"), new Object[]{this.status.getAbsolutePath()}), Project.MSG_VERBOSE); //$NON-NLS-1$
            }
        }
    }
}