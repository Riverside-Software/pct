/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) The Apache Software Foundation.  All rights
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
import org.apache.tools.ant.taskdefs.Mkdir;
import org.apache.tools.ant.types.FileSet;

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
  * @author <a href="mailto:gilles.querret@nerim.net">Gilles QUERRET</a>
  */
public class PCTCompile extends PCTRun {
    private Vector filesets = new Vector();
    private boolean minSize = false;
    private boolean md5 = true;
    private boolean noXref = false;
    private boolean forceCompile = false;
    private boolean failOnError = false;
    private File destDir = null;
    private File xRefDir = null;
    private Hashtable _dirs = new Hashtable();

    /**
     * Reduce r-code size ?
     * MIN-SIZE option of the COMPILE statement
     * @param minSize "true|false|on|off|yes|no"
     */
    public void setMinSize(boolean minSize) {
        this.minSize = minSize;
    }

    /**
     * Always force compilation
     * @param forceCompile "true|false|on|off|yes|no"
     * @since 0.3b
     */
    public void setForceCompile(boolean forceCompile) {
        this.forceCompile = forceCompile;
    }

    /**
     * Immediatly quit if a progress procedure fails to compile
     * @param failOnError "true|false|on|off|yes|no"
     */
    public void setFailOnError(boolean failOnError) {
        this.failOnError = failOnError;
    }

    /**
     * Don't use XREF (and so compile everything)
     * @param noXref "true|false|on|off|yes|no"
     */
    public void setNoXref(boolean noXref) {
        this.noXref = noXref;
    }

    /**
     * Directory where to store xref and includes files
     * .xref and .includes subdirectories are created there
     * @param xrefDir File
     */
    public void setXRefDir(File xrefDir) {
        this.xRefDir = xrefDir;
    }

    /**
     * Put MD5 in r-code ?
     * GENERATE-MD5 option of the COMPILE statement
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
     * Adds a set of files to archive.
     * @param set FileSet
     */
    public void addFileset(FileSet set) {
        filesets.addElement(set);
    }

    /**
     * Checks whether files from a fileset need to be compiled
     * @param inc Directory where XREF and include files are located
     * @return Vector of PCTFile
     * @throws BuildException
     */
    private Vector getFileList(File inc) throws BuildException {
        Vector v = new Vector();
        int j = 0;

        for (Enumeration e = filesets.elements(); e.hasMoreElements();) {
            // Parse filesets
            FileSet fs = (FileSet) e.nextElement();

            // Creates a new entry in hashtable
            _dirs.put(fs.getDir(this.getProject()).getAbsolutePath(), new Integer(++j));

            // And get files from fileset
            String[] dsfiles = fs.getDirectoryScanner(this.getProject()).getIncludedFiles();

            for (int i = 0; i < dsfiles.length; i++) {
                PCTFile pctf = new PCTFile(fs.getDir(this.getProject()), dsfiles[i]);

                if (this.forceCompile) {
                    // Always recompile
                    v.add(pctf);
                } else {
                    // Guess r-code file name
                    File rFile = new File(this.destDir, pctf.baseDirExt + pctf.rCode); // File handle
                    File pFile = new File(pctf.baseDir, pctf.baseDirExt + pctf.fileName);

                    if (rFile.exists()) {
                        if (pFile.lastModified() > rFile.lastModified()) {
                            // Source code is more recent than R-code
                            v.add(pctf);
                        } else if (!this.noXref) {
                            // Must check if included files are more recent
                            BufferedReader br = null;
                            String incFile = null;

                            try {
                                // Opens a reader to includes file
                                br = new BufferedReader(new FileReader(new File(inc,
                                                                                pctf.baseDirExt +
                                                                                pctf.fileName)));

                                boolean compile = false;

                                while (((incFile = br.readLine()) != null) && !(compile)) {
                                    File f = new File(incFile);

                                    if (f.lastModified() > rFile.lastModified()) {
                                        v.add(pctf);
                                        compile = true;
                                    }
                                }

                                br.close();
                            } catch (FileNotFoundException fnfe) {
                                // Includes file not found => compile source code
                                v.add(pctf);
                            } catch (IOException ioe) {
                                // Error occured => compile source code
                                v.add(pctf);
                            }
                        } else {
                            // Included files not checked => compile it
                            v.add(pctf);
                        }
                    } else {
                        // R-code file doesn't exist => compile it
                        v.add(pctf);
                    }
                }
            }
        }

        return v;
    }

    /**
     * Checks if directories need to be created
     * @param v File list to compile
     * @return Hashtable of directories to be created
     * @throws BuildException Something went wrong
     */
    private Hashtable getDirectoryList(Vector v) throws BuildException {
        Hashtable dirs = new Hashtable();

        for (Enumeration e = v.elements(); e.hasMoreElements();) {
            // Parse filesets
            PCTFile pctf = (PCTFile) e.nextElement();
            dirs.put(pctf.baseDirExt, pctf.baseDirExt);
        }

        return dirs;
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

    /**
     * Do the work
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        File tmpProc = null; // Compile procedure
        File xRefDir = null; // Where to store XREF files
        File includesDir = null; // Where to store INCLUDES files

        if (this.destDir == null) {
            throw new BuildException("destDir attribute not defined");
        }

        if (this.destDir.exists() && (!this.destDir.isDirectory())) {
            throw new BuildException("destDir is not a directory");
        }

        log("PCTCompile - Progress Code Compiler", Project.MSG_INFO);

        if (!this.noXref) {
            if (this.xRefDir == null) {
                xRefDir = new File(destDir, ".xref");
                includesDir = new File(destDir, ".includes");
            } else {
                xRefDir = new File(this.xRefDir, ".xref");
                includesDir = new File(this.xRefDir, ".includes");
            }
        }

        Vector compFiles = getFileList(includesDir);
        Hashtable dirs = getDirectoryList(compFiles);
        createDirectories(this.destDir, dirs);

        if (!this.noXref) {
            createDirectories(xRefDir, dirs);
            createDirectories(includesDir, dirs);
        }

        // If there are no files to compile, just return...
        if (compFiles.size() == 0) {
            return;
        } else {
            log("Compiling " + compFiles.size() + " file(s) to " + this.destDir, Project.MSG_INFO);
        }

        try {
            // Creates Progress procedure to compile files
            tmpProc = File.createTempFile("pct_compile", ".p");

            if (!this.debug) {
                tmpProc.deleteOnExit();
            }

            BufferedWriter bw = new BufferedWriter(new FileWriter(tmpProc));
            bw.write("DEFINE VARIABLE h AS HANDLE NO-UNDO.");
            bw.newLine();
            bw.write("DEFINE VARIABLE iComp AS INTEGER NO-UNDO INITIAL 0.");
            bw.newLine();
            bw.write("DEFINE VARIABLE iNoComp AS INTEGER NO-UNDO INITIAL 0.");
            bw.newLine();
            bw.write("DEFINE VARIABLE destDir AS CHARACTER NO-UNDO INITIAL \"" +
                     escapeString(this.destDir.getAbsolutePath()) + File.separatorChar + "\".");
            bw.newLine();
            bw.newLine();

            for (Enumeration e = _dirs.keys(); e.hasMoreElements();) {
                String s = escapeString((String) e.nextElement());
                Integer i = (Integer) _dirs.get(s);
                bw.write("DEFINE VARIABLE dir" + i + " AS CHARACTER NO-UNDO INITIAL \"" + s +
                         File.separatorChar + "\".");
                bw.newLine();
            }

            bw.newLine();

            if (!this.noXref) {
                bw.write("DEFINE VARIABLE xRefDir AS CHARACTER NO-UNDO INITIAL \"" +
                         escapeString(xRefDir.getAbsolutePath()) + File.separatorChar + "\".");
                bw.newLine();
                bw.write("DEFINE VARIABLE includesDir AS CHARACTER NO-UNDO INITIAL \"" +
                         escapeString(includesDir.getAbsolutePath()) + File.separatorChar + "\".");
                bw.newLine();
            }

            bw.newLine();

            bw.write("RUN pct/pctCompileMsg.p PERSISTENT SET h.");
            bw.newLine();
            bw.newLine();

            for (Enumeration e = compFiles.elements(); e.hasMoreElements();) {
                PCTFile pctf = (PCTFile) e.nextElement();
                Integer i = (Integer) _dirs.get(pctf.baseDir.getAbsolutePath());
                bw.write("COMPILE VALUE (dir" + i + " + \"" + pctf.baseDirExt + pctf.fileName +
                         "\") SAVE INTO VALUE (destDir + \"" + pctf.baseDirExt + "\")");

                bw.write(" MIN-SIZE=" + (this.minSize ? "TRUE" : "FALSE"));
                bw.write(" GENERATE-MD5=" + (this.md5 ? "TRUE" : "FALSE"));

                if (!this.noXref) {
                    bw.write(" XREF VALUE (xRefDir + \"" + pctf.baseDirExt + pctf.fileName +
                             "\") APPEND=FALSE");
                }

                bw.write(".");
                bw.newLine();

                bw.write("IF COMPILER:ERROR THEN DO:");
                bw.newLine();

                bw.write("  ASSIGN iNoComp = iNoComp + 1.");
                bw.newLine();

                if (this.failOnError) {
                    bw.write("RUN finish IN h (INPUT iComp, INPUT iNoComp).");
                    bw.newLine();
                    bw.write("DELETE PROCEDURE h.");
                    bw.newLine();
                    bw.write("RETURN '1'.");
                    bw.newLine();
                }

                bw.write("END.");
                bw.newLine();
                bw.write("ELSE DO:");
                bw.newLine();
                bw.write("  ASSIGN iComp = iComp + 1.");
                bw.newLine();

                if (!this.noXref) {
                    bw.write("  RUN importXref IN h (INPUT xRefDir + '" + pctf.baseDirExt +
                             pctf.fileName + "', INPUT includesDir + '" + pctf.baseDirExt +
                             pctf.fileName + "').");
                    bw.newLine();
                }

                bw.write("END.");
                bw.newLine();
                bw.newLine();
            }

            bw.write("RUN finish IN h (INPUT iComp, INPUT iNoComp).");
            bw.newLine();
            bw.write("DELETE PROCEDURE h.");
            bw.newLine();
            bw.write("RETURN (IF iNoComp GT 0 THEN '1' ELSE '0').");
            bw.newLine();
            bw.close();
        } catch (IOException e) {
            System.out.println(e);
        }

        this.setProcedure(tmpProc.getAbsolutePath());
        super.execute();
    }

    private class PCTFile {
        public File baseDir = null;
        public String baseDirExt = null;
        public String fileName = null;
        public String rCode = null;

        public PCTFile(File baseDir, String fileName) {
            this.baseDir = baseDir;

            String s = escapeString(fileName.replace('\\', '/'));
            int i = s.lastIndexOf('/');

            if (i == -1) {
                this.fileName = fileName;
                this.baseDirExt = "" + File.separatorChar;
            } else {
                this.baseDirExt = s.substring(0, i) + File.separatorChar;
                this.fileName = s.substring(i + 1); // Exception ???
            }

            i = this.fileName.lastIndexOf('.');

            if (i == -1) {
                this.rCode = this.fileName + ".r";
            } else {
                this.rCode = this.fileName.substring(0, i) + ".r";
            }
        }
    }
}
