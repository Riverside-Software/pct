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
    private boolean failOnError = false;
    private File destDir = null;
    private File xRefDir = null;

    /**
     * Reduce r-code size ?
     * @param minSize "true|false|on|off|yes|no"
     */
    public void setMinSize(boolean minSize) {
        this.minSize = minSize;
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
    * Adds a set of files to archive.
    * @param set FileSet
    */
    public void addFileset(FileSet set) {
        filesets.addElement(set);
    }

    private Hashtable getFileList(File inc) throws BuildException {
        Hashtable arg = new Hashtable();
        boolean compile = false;

        for (Enumeration e = filesets.elements(); e.hasMoreElements();) {
            FileSet fs = (FileSet) e.nextElement();
            log("Nouveau fileset : " + fs.getDir(this.getProject()), Project.MSG_DEBUG);

            //File fsRoot = fs.getDir(this.getProject());
            //log("Racine du fileset : " + fsRoot.getAbsolutePath());
            String[] dsfiles = fs.getDirectoryScanner(this.getProject()).getIncludedFiles();

            for (int i = 0; i < dsfiles.length; i++) {
                String pFileName = dsfiles[i];
                log("Fichier dans FS : " + dsfiles[i], Project.MSG_DEBUG);

                File pFile = new File(fs.getDir(this.getProject()), pFileName);
                log("File : " + pFile.getAbsolutePath(), Project.MSG_DEBUG);

                if (this.noXref) {
                    arg.put(pFileName, pFile);
                } else {
                    String rFileName = pFileName.substring(0, pFileName.lastIndexOf(".")) + ".r";
                    log("RCode correspondant : " + rFileName, Project.MSG_DEBUG);

                    File rFile = new File(this.destDir, rFileName);
                    log("Fichier rcode : " + rFile.getAbsolutePath(), Project.MSG_DEBUG);

                    if (rFile.exists()) {
                        log("Fichier .r trouvé", Project.MSG_DEBUG);
                        compile = false;

                        if (pFile.lastModified() > rFile.lastModified()) {
                            log(".P modifié après .r on ajoute");
                            arg.put(pFileName, pFile);

                            // arg.addElement(pCode);
                        } else {
                            BufferedReader br = null;
                            String incFile = null;

                            try {
                                compile = false;
                                br = new BufferedReader(new FileReader(new File(inc, pFileName)));

                                while (((incFile = br.readLine()) != null) && !(compile)) {
                                    File shit = new File(incFile);

                                    if (shit.lastModified() > rFile.lastModified()) {
                                        compile = true;
                                        arg.put(pFileName, pFile);

                                        //                                    arg.addElement(pCode);
                                    }
                                }

                                br.close();
                            } catch (FileNotFoundException fnfe) {
                                arg.put(pFileName, pFile);

                                //                            arg.addElement(pCode);
                            } catch (IOException ioe) {
                                arg.put(pFileName, pFile);

                                //                            arg.addElement(pCode);
                            }
                        }
                    } else {
                        log("Fichier .r pas trouvé - Ajout de " + pFile.getAbsolutePath(),
                            Project.MSG_DEBUG);
                        arg.put(pFileName, pFile);

                        //                    arg.addElement(pCode);
                    }
                }
            }

            // appendFiles(files, fs.getDirectoryScanner(this.getProject()));
        }

        return arg;
    }

    private Hashtable getDirectoryList(Hashtable files)
                                throws BuildException {
        Hashtable dirs = new Hashtable();

        for (Enumeration e = files.keys(); e.hasMoreElements();) {
            File f = new File((String) e.nextElement());
            String s = f.getParent();

            if (s != null) {
                dirs.put(s, s);
            }
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
        Hashtable compFiles = null; // File list to compile

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

        compFiles = getFileList(includesDir);

        //compFiles = files;

        /*if (this.noXref) {
            compFiles = files;
        } else {
            compFiles = getFileListToCompile(files);
        }*/
        Hashtable dirs = getDirectoryList(compFiles);
        createDirectories(this.destDir, dirs);

        if (!this.noXref) {
            createDirectories(xRefDir, dirs);
            createDirectories(includesDir, dirs);
        }

        // If there are no files to compile, just return...
        /*if (compFiles.size() == 0) {
            return;
        } else {*/
        log("Compiling " + compFiles.size() + " file(s) to " + this.destDir, Project.MSG_INFO);

        /*}*/
        try {
            // Creates Progress procedure to compile files
            tmpProc = File.createTempFile("pct_compile", ".p");
            tmpProc.deleteOnExit();

            BufferedWriter bw = new BufferedWriter(new FileWriter(tmpProc));
            bw.write("DEFINE VARIABLE h AS HANDLE NO-UNDO.");
            bw.newLine();
            bw.write("DEFINE VARIABLE iComp AS INTEGER NO-UNDO INITIAL 0.");
            bw.newLine();
            bw.write("DEFINE VARIABLE iNoComp AS INTEGER NO-UNDO INITIAL 0.");
            bw.newLine();
            bw.write("RUN pct/pctCompileMsg.p PERSISTENT SET h.");
            bw.newLine();

            for (Enumeration e = compFiles.keys(); e.hasMoreElements();) {
                File xRefFile = null;
                File includesFile = null;
                File outputDir = null;

                String fileName = (String) e.nextElement();
                File s = (File) compFiles.get(fileName);
                String parent = new File(fileName).getParent();

                if (parent == null) {
                    outputDir = destDir;
                } else {
                    outputDir = new File(destDir, parent);
                }

                bw.write("COMPILE VALUE (\"" + s.getAbsolutePath() + "\") SAVE INTO VALUE (\"" +
                         outputDir + "\")");

                bw.write(" MIN-SIZE=" + (this.minSize ? "TRUE" : "FALSE"));
                bw.write(" GENERATE-MD5=" + (this.md5 ? "TRUE" : "FALSE"));

                if (!this.noXref) {
                    xRefFile = new File(xRefDir, fileName);
                    includesFile = new File(includesDir, fileName);
                    bw.write(" XREF VALUE (\"" + xRefFile.getAbsolutePath() + "\") APPEND=FALSE");
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
                    bw.write("  RUN importXref IN h (INPUT '" + xRefFile.getAbsolutePath() +
                             "', INPUT '" + includesFile.getAbsolutePath() + "').");
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
        this.run();
    }
}
