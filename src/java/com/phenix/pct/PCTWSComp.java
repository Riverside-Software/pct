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
import org.apache.tools.ant.taskdefs.Mkdir;
import org.apache.tools.ant.types.FileSet;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;


/**
  * Converts Webspeed HTML files to .w
  * @author <a href="mailto:gilles.querret@nerim.net">Gilles QUERRET</a>
  */
public class PCTWSComp extends PCTRun {
    private Vector filesets = new Vector();
    private boolean debug = false;
    private boolean webObject = true;
    private boolean include = false;
    private boolean keepMetaContentType = false;
    private boolean getOptions = false;
    private boolean failOnError = false;
    private File destDir = null;

    // Internal use
    private File tmpProc = null;
    private File tmpFiles = null;

    public PCTWSComp() {
        super();

        try {
            tmpProc = File.createTempFile("pct_wscomp", ".p");
            tmpFiles = File.createTempFile("comp_files", ".txt");
        } catch (IOException ioe) {
            throw new BuildException("Unable to create temp files");
        }
    }

    /**
     * Sets debug flag on in e4gl-gen.p
     * @param debug true|false|yes|no|on|off
     */
    public void setDebug(boolean debug) {
        this.debug = debug;
    }

    /**
     * Sets web-object flag on in e4gl-gen.p
     * @param webObject true|false|yes|no|on|off
     */
    public void setWebOject(boolean webObject) {
        this.webObject = webObject;
    }

    /**
     * Sets include flag on in e4gl-gen.p
     * @param include true|false|yes|no|on|off
     */
    public void setInclude(boolean include) {
        this.include = include;
    }

    /**
     * Sets keep-meta-content-type flag on in e4gl-gen.p
     * @param keepMetaContentType true|false|yes|no|on|off
     */
    public void setKeepMetaContentType(boolean keepMetaContentType) {
        this.keepMetaContentType = keepMetaContentType;
    }

    /**
     * Sets get-options flag on in e4gl-gen.p
     * @param getOptions true|false|yes|no|on|off
     */
    public void setGetOptions(boolean getOptions) {
        this.getOptions = getOptions;
    }

    /**
     * Location to store the .w files
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

    private Vector getFileList() throws BuildException {
        Vector v = new Vector();
        int j = 0;

        for (Enumeration e = filesets.elements(); e.hasMoreElements();) {
            FileSet fs = (FileSet) e.nextElement();

            // And get files from fileset
            String[] dsfiles = fs.getDirectoryScanner(this.getProject()).getIncludedFiles();

            for (int i = 0; i < dsfiles.length; i++) {
                PCTFile pctf = new PCTFile(fs.getDir(this.getProject()), dsfiles[i]);

                // Guess r-code file name
                File rFile = new File(this.destDir, pctf.baseDirExt + pctf.wFile); // File handle
                File pFile = new File(pctf.baseDir, pctf.baseDirExt + pctf.fileName);

                if (rFile.exists()) {
                    if (pFile.lastModified() > rFile.lastModified()) {
                        // Source code is more recent than R-code
                        v.add(pctf);
                    }
                } else {
                    // R-code file doesn't exist => compile it
                    v.add(pctf);
                }
            }
        }

        return v;
    }

    private void writeFileList(Vector v) throws BuildException {
        try {
            BufferedWriter bw = new BufferedWriter(new FileWriter(tmpFiles));

            for (Enumeration e = v.elements(); e.hasMoreElements();) {
                PCTFile pctf = (PCTFile) e.nextElement();
                bw.write("\"");
                bw.write(pctf.baseDir.getAbsolutePath());
                bw.write("\" \"");
                bw.write(pctf.baseDirExt);
                bw.write("\" \"");
                bw.write(pctf.fileName);
                bw.write("\" \"");
                bw.write(pctf.wFile);
                bw.write("\"");
                bw.newLine();
            }

            bw.close();
        } catch (IOException ioe) {
            throw new BuildException("Unable to write file list to compile");
        }
    }

    /**
     *
     * @param baseDir
     * @param dirs
     * @throws BuildException
     */
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

    /**
     * Do the work
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        String sOptions = "";

        if (!this.getDebugPCT()) {
            this.tmpFiles.deleteOnExit();
            this.tmpProc.deleteOnExit();
        }

        if (this.destDir == null) {
            throw new BuildException("destDir attribute not defined");
        }

        if (this.destDir.exists() && (!this.destDir.isDirectory())) {
            throw new BuildException("destDir is not a directory");
        }

        log("PCTWebCompile - Progress SpeedScript Compiler", Project.MSG_INFO);

        Vector compFiles = getFileList();
        Hashtable dirs = getDirectoryList(compFiles);
        createDirectories(this.destDir, dirs);

        // If there are no files to compile, just return...
        if (compFiles.size() == 0) {
            return;
        } else {
            log("Compiling " + compFiles.size() + " file(s) to " + this.destDir, Project.MSG_INFO);
        }

        // And then write file list
        writeFileList(compFiles);

        if (this.debug) {
            sOptions += "debug";
        }

        if (this.webObject) {
            sOptions += ",web-object";
        }

        if (this.include) {
            sOptions += ",include";
        }

        if (this.keepMetaContentType) {
            sOptions += ",keep-meta-content-type";
        }

        if (this.getOptions) {
            sOptions += ",get-options";
        }

        try {
            BufferedWriter bw = new BufferedWriter(new FileWriter(tmpProc));
            bw.write("DEFINE VARIABLE h AS HANDLE NO-UNDO.");
            bw.newLine();
            bw.write("DEFINE VARIABLE iComp AS INTEGER NO-UNDO INITIAL 0.");
            bw.newLine();
            bw.write("DEFINE VARIABLE iNoComp AS INTEGER NO-UNDO INITIAL 0.");
            bw.newLine();
            bw.write("DEFINE VARIABLE baseDir AS CHARACTER NO-UNDO.");
            bw.newLine();
            bw.write("DEFINE VARIABLE extDir AS CHARACTER NO-UNDO.");
            bw.newLine();
            bw.write("DEFINE VARIABLE fileName AS CHARACTER NO-UNDO.");
            bw.newLine();
            bw.write("DEFINE VARIABLE wFile AS CHARACTER NO-UNDO.");
            bw.newLine();
            bw.write("DEFINE VARIABLE destDir AS CHARACTER NO-UNDO INITIAL \"" +
                     escapeString(this.destDir.getAbsolutePath()) + File.separatorChar + "\".");
            bw.newLine();
            bw.write("DEFINE VARIABLE cOptions AS CHARACTER NO-UNDO.");
            bw.newLine();
            bw.write("DEFINE VARIABLE cOutFile AS CHARACTER NO-UNDO.");
            bw.newLine();
            bw.write("DEFINE VARIABLE cRetVal AS CHARACTER NO-UNDO.");
            bw.newLine();
            bw.write("DEFINE STREAM sFiles.");
            bw.newLine();
            bw.newLine();

            bw.write("{src/web/method/cgidefs.i NEW}");
            bw.newLine();

            bw.write("RUN pct/pctWSComp.p PERSISTENT SET h.");
            bw.newLine();
            bw.newLine();

            bw.write("INPUT STREAM sFiles FROM VALUE(\"" +
                     escapeString(tmpFiles.getAbsolutePath()) + "\").");
            bw.newLine();
            bw.write("FileLoop:");
            bw.newLine();
            bw.write("REPEAT:");
            bw.newLine();
            bw.write("  IMPORT STREAM sFiles baseDir extDir fileName wFile.");
            bw.newLine();
            bw.write("  ASSIGN cOutFile = destDir + extDir + wFile");
            bw.newLine();
            bw.write("         cOptions = \"" + sOptions + "\".");
            bw.newLine();
            bw.write("  RUN webutil/e4gl-gen.p (INPUT baseDir + '/' + extDir + fileName, INPUT-OUTPUT cOptions, INPUT-OUTPUT cOutFile).");
            bw.newLine();

            bw.write("  ASSIGN cRetVal = RETURN-VALUE.");
            bw.newLine();

            bw.write("  IF (cRetVal NE '') THEN DO:");
            bw.newLine();

            bw.write("    ASSIGN iNoComp = iNoComp + 1.");
            bw.newLine();

            if (this.failOnError) {
                bw.write("    LEAVE FileLoop.");
                bw.newLine();
            }

            bw.write("  END.");
            bw.newLine();
            bw.write("  ELSE DO:");
            bw.newLine();
            bw.write("    ASSIGN iComp = iComp + 1.");
            bw.newLine();

            bw.write("  END.");
            bw.newLine();

            bw.write("END.");
            bw.newLine();
            bw.write("INPUT CLOSE.");
            bw.newLine();
            bw.write("RUN finish IN h (INPUT iComp, INPUT iNoComp).");
            bw.newLine();
            bw.write("DELETE PROCEDURE h.");
            bw.newLine();
            bw.write("RETURN (IF iNoComp GT 0 THEN '1' ELSE '0').");
            bw.newLine();
            bw.close();
        } catch (IOException e) {
            throw new BuildException("Unable to write compilation program");
        }

        this.setProcedure(tmpProc.getAbsolutePath());
        super.execute();
    }

    /**
     * Inner class representing files to be transformed into .w
     * @author <a href="mailto:gilles.querret@nerim.net">Gilles QUERRET</a>
     */
    private class PCTFile {
        public File baseDir = null;
        public String baseDirExt = null;
        public String fileName = null;
        public String wFile = null;

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
                this.wFile = this.fileName + ".w";
            } else {
                this.wFile = this.fileName.substring(0, i) + ".w";
            }
        }
    }
}
