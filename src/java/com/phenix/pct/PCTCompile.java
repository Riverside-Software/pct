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
import org.apache.tools.ant.DirectoryScanner;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.taskdefs.Mkdir;
import org.apache.tools.ant.types.Commandline;
import org.apache.tools.ant.types.FileSet;
import org.apache.tools.ant.types.Path;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;


/**
  * Class for compiling Progress procedures
  */
public class PCTCompile extends PCT {
    private Vector dbConnList = new Vector();
    private Path propath;
    private Vector filesets = new Vector();
    private boolean minSize = false;
    private boolean md5 = false;
    private boolean graphMode = false;
    private File destDir = null;
    private int inputChars = 0;

    /**
     * Set the propath to be used for this compilation.
     * @param propath an Ant Path object containing the compilation propath.
     */
    public void setPropath(Path propath) {
        if (this.propath == null) {
            this.propath = propath;
        } else {
            this.propath.append(propath);
        }
    }

    /**
     * Adds a path to the propath.
     */
    public Path createPropath() {
        if (this.propath == null) {
            this.propath = new Path(getProject());
        }

        return this.propath.createPath();
    }

    /**
     * Reduce r-code size ?
     * @param minSize "true|false|on|off|yes|no"
     */
    public void setMinSize(boolean minSize) {
        this.minSize = minSize;
    }

    /**
     * Put MD5 in r-code
     * @param md5 "true|false|on|off|yes|no"
     */
    public void setMD5(boolean md5) {
        this.md5 = md5;
    }

    /**
     * Location to store the .r files
     * @param destDir Destination directory
     */
    public void setDestDir(File destDir) {
        this.destDir = destDir;
    }

    /**
     * Adds a database connection
     * @param dbConn Instance of DBConnection class
     */
    public void addPCTConnection(PCTConnection dbConn) {
        this.dbConnList.addElement(dbConn);
    }

    /**
     * Max length of a line
     * @param inputChars Integer
     */
    public void setInputChars(int inputChars) {
        this.inputChars = inputChars;
    }

    /**
    * Adds a set of files to archive.
    */
    public void addFileset(FileSet set) {
        filesets.addElement(set);
    }

    /**
     * Graphical mode on/off (call to _progres or prowin32)
     * @param graphMode boolean
     */
    public void setGraphicalMode(boolean graphMode) {
        this.graphMode = graphMode;
    }

    /**
     * Append all files found by a directory scanner to a vector.
     */
    private void appendFiles(Vector files, DirectoryScanner ds) {
        String[] dsfiles = ds.getIncludedFiles();

        for (int i = 0; i < dsfiles.length; i++) {
            files.addElement(dsfiles[i]);
        }
    }

    /**
     * Get the complete list of files to be included in the cab.  Filenames
     * are gathered from filesets if any have been added, otherwise from the
     * traditional include parameters.
     */
    private Vector getFileList() throws BuildException {
        Vector files = new Vector();

        if (filesets.size() == 0) {
            // get files from old methods - includes and nested include
            appendFiles(files, super.getDirectoryScanner(this.getBaseDir()));
        } else {
            // get files from filesets
            for (int i = 0; i < filesets.size(); i++) {
                FileSet fs = (FileSet) filesets.elementAt(i);

                if (fs != null) {
                    appendFiles(files, fs.getDirectoryScanner(this.getProject()));
                }
            }
        }

        return files;
    }

    private Hashtable getDirectoryList(Vector files) throws BuildException {
        Hashtable dirs = new Hashtable();

        for (int i = 0; i < files.size(); i++) {
            File f = new File((String) files.elementAt(i));
            String s = f.getParent();

            if (s != null) {
                dirs.put(s, s);
            }
        }

        return dirs;
    }

    private Vector getFileListToCompile(Vector files) throws BuildException {
        Vector files2 = new Vector();
        String s = null;
        String rFile = null;
        boolean recompile = false;
        BufferedReader br = null;
        File f1 = null;
        File f2 = null;

        // Check each file to compile
        for (int i = 0; i < files.size(); i++) {
            // Search r-code file
            rFile = files.elementAt(i).toString().substring(0,
                                                            files.elementAt(i).toString()
                                                            .lastIndexOf(".")) + ".r";
            f1 = new File(((this.destDir == null) ? this.getBaseDir() : this.destDir), rFile);

            if (f1.exists()) {
                recompile = false;

                // Check against source file
                f2 = new File(this.getBaseDir(), files.elementAt(i).toString());

                if (f2.lastModified() > f1.lastModified()) {
                    recompile = true;
                }

                // Check against included files 
                try {
                    br = new BufferedReader(new FileReader(new File(((this.destDir == null)
                                                                     ? this.getBaseDir()
                                                                     : this.destDir),
                                                                    ".includes" +
                                                                    File.separatorChar +
                                                                    files.elementAt(i).toString())));

                    while (((s = br.readLine()) != null) && !(recompile)) {
                        // Search included file
                        f2 = new File(s);

                        if (f2.lastModified() > f1.lastModified()) {
                            recompile = true;
                        }
                    }
                } catch (FileNotFoundException fnfe) {
                    files2.addElement(files.elementAt(i));
                } catch (IOException ioe) {
                    files2.addElement(files.elementAt(i));
                } finally {
                    try {
                        br.close();
                    } catch (Exception e) {
                    }
                }
            } else {
                recompile = true;
            }

            if (recompile) {
                files2.addElement(files.elementAt(i));
            }
        }

        return files2;
    }

    private void createDirectories(File baseDir, Hashtable dirs)
                            throws BuildException {
        Mkdir mkdir = new Mkdir();
        mkdir.setOwningTarget(this.getOwningTarget());
        mkdir.setTaskName(this.getTaskName());
        mkdir.setDescription(this.getDescription());
        mkdir.setProject(this.getProject());

        // Creates base directory (if necessary)
        mkdir.setDir(baseDir);
        mkdir.execute();

        // Creates subdirectories
        for (Enumeration e = dirs.elements(); e.hasMoreElements();) {
            mkdir.setDir(new File(baseDir, (String) e.nextElement()));
            mkdir.execute();
        }
    }

    public void execute() throws BuildException {
        Commandline cmdLine = null;
        int result = 0;
        File tmpProc = null, tmpProc2 = null;
        

        log("PCTCompile - Progress Code Compiler", Project.MSG_INFO);

        Vector files = getFileList();
        Vector compFiles = getFileListToCompile(files);
        Hashtable dirs = getDirectoryList(files);

        if (this.destDir != null) {
            createDirectories(this.destDir, dirs);
        }

        createDirectories(new File(((this.destDir == null) ? this.getBaseDir() : this.destDir),
                                   ".xref"), dirs);
        createDirectories(new File(((this.destDir == null) ? this.getBaseDir() : this.destDir),
                                   ".includes"), dirs);

        /*if ((destDir != null) && (!destDir.isDirectory())) {
            throw new BuildException("destDir is not a directory");
        }*/

        // If there are no files to compile, just return...
        if (compFiles.size() == 0) {
            return;
        } else {
            log("Compiling " + compFiles.size() + " file(s) to " +
                ((this.destDir == null) ? this.getBaseDir() : this.destDir), Project.MSG_INFO);
        }

        try {
            // Creates Progress procedure to compile files
            tmpProc = File.createTempFile("compile", ".p");
			tmpProc2 = File.createTempFile("aliases", ".p");
			
            tmpProc.deleteOnExit();
			tmpProc2.deleteOnExit();
			
            BufferedWriter bw = new BufferedWriter(new FileWriter(tmpProc));
            BufferedWriter bw2 = new BufferedWriter(new FileWriter(tmpProc2));
            
            bw.write("ASSIGN PROPATH=\"" + propath.toString() + File.pathSeparatorChar +
                     "\" + PROPATH.");
            
            // Defines aliases
			for (Enumeration e = dbConnList.elements(); e.hasMoreElements();) {
				PCTConnection dbc = (PCTConnection) e.nextElement();
				for (Enumeration e2 = dbc.getAliases().elements(); e2.hasMoreElements();) {
					bw2.write((String) e2.nextElement());
					bw2.newLine();
				}
			}
			// Calls compile procedure
            bw2.write("RUN " + tmpProc.toString() + ".");
            bw2.newLine();         
            bw2.close();
            
            bw.newLine();
            bw.write("DEFINE VARIABLE h AS HANDLE NO-UNDO.");
            bw.newLine();
            bw.write("RUN pctCompileMsg.p PERSISTENT SET h.");
            bw.newLine();

            for (int i = 0; i < compFiles.size(); i++) {
                bw.write("COMPILE " + compFiles.elementAt(i).toString() + " SAVE");

                if (destDir != null) {
                    bw.write(" INTO VALUE(\"" + destDir + "\")");
                }

                bw.write(" MIN-SIZE=" + (this.minSize ? "TRUE" : "FALSE"));
                bw.write(" GENERATE-MD5=" + (this.md5 ? "TRUE" : "FALSE"));
                bw.write(" XREF " +
                         ((this.destDir == null) ? this.getBaseDir() : this.destDir).getAbsolutePath() +
                         "/.xref/" + compFiles.elementAt(i).toString() + " APPEND=FALSE.");

                bw.newLine();
                bw.write("IF NOT COMPILER:ERROR THEN RUN importXref IN h (INPUT '" +
                         ((this.destDir == null) ? this.getBaseDir() : this.destDir).getAbsolutePath() +
                         "/.xref/" + compFiles.elementAt(i).toString() + "', INPUT '" +
                         ((this.destDir == null) ? this.getBaseDir() : this.destDir).getAbsolutePath() +
                         "/.includes/" + compFiles.elementAt(i).toString() + "').");
                bw.newLine();
                bw.write("ELSE RUN notCompiled IN h.");
                bw.newLine();
                bw.newLine();
            }

            bw.write("RUN finish IN h.");
            bw.newLine();
            bw.write("DELETE PROCEDURE h.");
            bw.newLine();
            bw.close();
        } catch (IOException e) {
            System.out.println(e);
        }

        cmdLine = buildCompileCmdLine(tmpProc2);
        result = run(cmdLine);

        if (result != 0) {
            String msg = "Compilation failed: " + cmdLine.toString() + " - Return code : " +
                         result;
            throw new BuildException(msg, location);
        }
    }

    protected Commandline buildCompileCmdLine(File f) {
        Commandline commandLine = new Commandline();
        commandLine.setExecutable(getExecPath((this.graphMode ? "prowin32" : "_progres")));

        // Database connections
        for (Enumeration e = dbConnList.elements(); e.hasMoreElements();) {
            PCTConnection dbc = (PCTConnection) e.nextElement();
            dbc.createArguments(commandLine);
        }

        // Batch mode
        commandLine.createArgument().setValue("-b");

        // Quick access to files
        commandLine.createArgument().setValue("-q");

        // Startup procedure
        commandLine.createArgument().setValue("-p");
        commandLine.createArgument().setValue(f.toString());

        // Max length of a line
        if (this.inputChars != 0) {
            commandLine.createArgument().setValue("-inp");
            commandLine.createArgument().setValue("" + this.inputChars);
        }

        return commandLine;
    }
}
