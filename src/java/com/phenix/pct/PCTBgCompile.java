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
import org.apache.tools.ant.types.FileSet;
import org.apache.tools.ant.types.Mapper;
import org.apache.tools.ant.util.FileNameMapper;

import java.io.File;
import java.io.IOException;
import java.net.Socket;

import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Class for compiling Progress procedures
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET </a>
 */
public class PCTBgCompile extends PCTBgRun {
    private List filesets = new ArrayList();
    private boolean minSize = false;
    private boolean md5 = true;
    private boolean forceCompile = false;
    private boolean failOnError = false; // FIXME
    private boolean xcode = false;
    private boolean noCompile = false;
    private boolean runList = false;
    private boolean listing = false;
    private boolean preprocess = false;
    private boolean debugListing = false;
    private boolean keepXref = false;
    private String xcodeKey = null;
    private File destDir = null;
    private File xRefDir = null;
    private Mapper mapperElement = null;

    private Set units = new HashSet();
    private int compOk = 0, compNotOk = 0;

    /**
     * Reduce r-code size ? MIN-SIZE option of the COMPILE statement
     * 
     * @param minSize "true|false|on|off|yes|no"
     */
    public void setMinSize(boolean minSize) {
        this.minSize = minSize;
    }

    /**
     * Force compilation, without xref generation
     * 
     * @param forceCompile "true|false|on|off|yes|no"
     * 
     * @since 0.3b
     */
    public void setForceCompile(boolean forceCompile) {
        this.forceCompile = forceCompile;
    }

    /**
     * Create listing files during compilation
     * 
     * @param listing "true|false|on|off|yes|no"
     * 
     * @since 0.10
     */
    public void setListing(boolean listing) {
        this.listing = listing;
    }

    /**
     * Create preprocessing files during compilation
     * 
     * @param preprocess "true|false|on|off|yes|no"
     * 
     * @since 0.10
     */
    public void setPreprocess(boolean preprocess) {
        this.preprocess = preprocess;
    }

    /**
     * Create debug list files during compilation
     * 
     * @param debugListing "true|false|on|off|yes|no"
     * 
     * @since PCT 0.13
     */
    public void setDebugListing(boolean debugListing) {
        this.debugListing = debugListing;
    }

    /**
     * Immediatly quit if a progress procedure fails to compile
     * 
     * @param failOnError "true|false|on|off|yes|no"
     */
    public void setFailOnError(boolean failOnError) {
        this.failOnError = failOnError;
    }

    /**
     * Don't use XREF (and so compile everything). Removed since 0.5, use forceCompile
     * 
     * @param noXref "true|false|on|off|yes|no"
     * 
     * @deprecated
     */
    public void setNoXref(boolean noXref) {
        log(Messages.getString("PCTCompile.1")); //$NON-NLS-1$
        this.forceCompile = noXref;
    }

    /**
     * Generates a .xref in the .pct directory, result of XREF option in the COMPILE statement
     * 
     * @param keepXref "true|false|on|off|yes|no"
     */
    public void setKeepXref(boolean keepXref) {
        this.keepXref = keepXref;
    }

    /**
     * Directory where to store CRC and includes files : .pct subdirectory is created there
     * 
     * @param xrefDir File
     */
    public void setXRefDir(File xrefDir) {
        this.xRefDir = xrefDir;
    }

    /**
     * Put MD5 in r-code ? GENERATE-MD5 option of the COMPILE statement
     * 
     * @param md5 "true|false|on|off|yes|no"
     */
    public void setMD5(boolean md5) {
        this.md5 = md5;
    }

    /**
     * No real compilation ; just print the files which should be recompiled
     * 
     * @param noCompile "true|false|on|off|yes|no"
     */
    public void setNoCompile(boolean noCompile) {
        this.noCompile = noCompile;
    }

    /**
     * Generates a .run file in the .pct directory, which shows internal and external procedures
     * calls
     * 
     * @param runList "true|false|on|off|yes|no"
     */
    public void setRunList(boolean runList) {
        this.runList = runList;
    }

    /**
     * Location to store the .r files
     * 
     * @param destDir Destination directory
     */
    public void setDestDir(File destDir) {
        this.destDir = destDir;
    }

    /**
     * Procedures are encrypted ?
     * 
     * @param xcode boolean
     */
    public void setXCode(boolean xcode) {
        this.xcode = xcode;
    }

    /**
     * Compile using a specific key instead of the default key
     * 
     * @param xcodeKey String
     */
    public void setXCodeKey(String xcodeKey) {
        this.xcodeKey = xcodeKey;
    }

    /**
     * Adds a set of files to archive.
     * 
     * @param set FileSet
     */
    public void addFileset(FileSet set) {
        filesets.add(set);
    }

    /**
     * Add a nested filenamemapper.
     * 
     * @param fileNameMapper the mapper to add.
     * @since Ant 1.6.3
     */
    public void add(FileNameMapper fileNameMapper) {
        createMapper().add(fileNameMapper);
    }

    private synchronized void addCompilationCounters(int ok, int notOk) {
        compOk += ok;
        compNotOk += notOk;
    }

    /**
     * Define the mapper to map source to destination files.
     * 
     * @return a mapper to be configured.
     * @exception BuildException if more than one mapper is defined.
     */
    public Mapper createMapper() throws BuildException {
        if (mapperElement != null) {
            throw new BuildException("Cannot define more than one mapper", getLocation());
        }
        mapperElement = new Mapper(getProject());
        return mapperElement;
    }

    /**
     * returns the mapper to use based on nested elements or the flatten attribute.
     */
    private FileNameMapper getMapper() {
        FileNameMapper mapper = null;
        if (mapperElement != null) {
            mapper = mapperElement.getImplementation();
        } else {
            mapper = new RCodeMapper();
        }
        return mapper;
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        if (this.destDir == null) {
            this.cleanup();
            throw new BuildException(Messages.getString("PCTCompile.34")); //$NON-NLS-1$
        }

        // Test output directory
        if (this.destDir.exists()) {
            if (!this.destDir.isDirectory()) {
                this.cleanup();
                throw new BuildException(Messages.getString("PCTCompile.35")); //$NON-NLS-1$
            }
        } else {
            if (!this.destDir.mkdir()) {
                this.cleanup();
                throw new BuildException(Messages.getString("PCTCompile.36")); //$NON-NLS-1$
            }
        }

        // Test xRef directory
        if (this.xRefDir == null) {
            this.xRefDir = new File(this.destDir, ".pct"); //$NON-NLS-1$
        }

        if (this.xRefDir.exists()) {
            if (!this.xRefDir.isDirectory()) {
                this.cleanup();
                throw new BuildException(Messages.getString("PCTCompile.38")); //$NON-NLS-1$
            }
        } else {
            if (!this.xRefDir.mkdir()) {
                this.cleanup();
                throw new BuildException(Messages.getString("PCTCompile.39")); //$NON-NLS-1$
            }
        }

        log(Messages.getString("PCTCompile.40"), Project.MSG_INFO); //$NON-NLS-1$

        // Checking xcode and (listing || preprocess) attributes -- They're mutually exclusive
        if (this.xcode && (this.listing || this.preprocess)) {
            log(Messages.getString("PCTCompile.43"), Project.MSG_INFO); //$NON-NLS-1$ // TODO Update this message
            this.listing = false; // Useless for now, but just in case...
            this.preprocess = false; // Useless for now, but just in case...
        }

        initializeCompilationUnits();

        try {
            super.execute();
        } finally {
            log(MessageFormat.format(Messages.getString("PCTCompile.44"), new Object[]{Integer //$NON-NLS-1$
                    .valueOf(compOk)}));
            if (compNotOk > 0) {
                log(MessageFormat.format(Messages.getString("PCTCompile.45"), new Object[]{Integer //$NON-NLS-1$
                        .valueOf(compNotOk)}));
            }
        }
    }

    /**
     * Generates a list of compilation unit (which is a source file name, associated with output
     * file names (.r, XREF, listing, and so on). This list is then consumed by the background
     * workers and transmitted to the OpenEdge procedures.
     */
    private void initializeCompilationUnits() {
        // .pct dir is where PCT output files are generated
        File dotPCTDir = new File(destDir, ".pct");

        for (Iterator e = filesets.iterator(); e.hasNext();) {
            FileSet fs = (FileSet) e.next();

            String[] dsfiles = fs.getDirectoryScanner(getProject()).getIncludedFiles();

            for (int i = 0; i < dsfiles.length; i++) {
                // File to be compiled
                File inputFile = new File(fs.getDir(getProject()), dsfiles[i]);
                int srcExtPos = inputFile.getName().lastIndexOf('.');
                String extension = (srcExtPos != -1 ? inputFile.getName().substring(srcExtPos) : "");
                String fileNameNoExt = (srcExtPos != -1 ? inputFile.getName().substring(0,
                        srcExtPos) : dsfiles[0]);

                // Output directory for .r file
                String[] outputNames = getMapper().mapFileName(dsfiles[i]);
                if ((outputNames != null) && (outputNames.length >= 1)) {
                    File outputDir = null;
                    File outputFile = new File(destDir, outputNames[0]);
                    String targetFile = outputFile.getName();
                    if (extension.equalsIgnoreCase(".cls")) {
                        // Specific case, as Progress prepends package name automatically
                        // So outputDir has to be rootDir
                        outputDir = destDir;
                    } else {
                        outputDir = outputFile.getParentFile();
                    }

                    if (!outputDir.exists())
                        outputDir.mkdirs();

                    // Output directory for PCT files
                    File PCTDir = new File(dotPCTDir, outputNames[0]).getParentFile();
                    if (!PCTDir.exists())
                        PCTDir.mkdirs();

                    CompilationUnit unit = new CompilationUnit();
                    unit.inputFile = inputFile;
                    unit.outputDir = outputDir;
                    unit.debugFile = (debugListing
                            ? new File(PCTDir, fileNameNoExt + ".dbg")
                            : null);
                    unit.preprocessFile = (preprocess ? new File(PCTDir, fileNameNoExt + extension
                            + ".preprocess") : null);
                    unit.listingFile = (listing
                            ? new File(PCTDir, fileNameNoExt + extension)
                            : null);
                    unit.xrefFile = new File(PCTDir, fileNameNoExt + extension + ".xref");
                    unit.pctRoot = new File(PCTDir, fileNameNoExt + extension);
                    unit.targetFile = targetFile;
                    units.add(unit);
                }
            }
        }

    }

    protected BackgroundWorker createOpenEdgeWorker(Socket socket) {
        CompilationBackgroundWorker worker = new CompilationBackgroundWorker(this);
        try {
            worker.initialize(socket);
        } catch (Throwable uncaught) {
            throw new BuildException(uncaught);
        }

        return worker;
    }

    public class CompilationBackgroundWorker extends BackgroundWorker {
        private int customStatus = 0;

        public CompilationBackgroundWorker(PCTBgCompile parent) {
            super(parent);
        }

        protected boolean performCustomAction() throws IOException {
            if (customStatus == 0) {
                customStatus = 3;
                sendCommand("launch", "pct/pctBgCompile.p");
                return true;
            } else if (customStatus == 3) {
                customStatus = 4;
                sendCommand("setOptions", getOptions());
                return true;
            } else if (customStatus == 4) {
                customStatus = 5;
                sendCommand("getCRC", "");
                return true;
            } else if (customStatus == 5) {
                List sending = new ArrayList();
                boolean noMoreFiles = false;
                synchronized (units) {
                    int size = units.size();
                    if (size > 0) {
                        int numCU = (size > 100 ? 10 : 1);
                        Iterator iter = units.iterator();
                        for (int zz = 0; zz < numCU; zz++) {
                            sending.add((CompilationUnit) iter.next());
                        }
                        for (Iterator iter2 = sending.iterator(); iter2.hasNext();) {
                            units.remove((CompilationUnit) iter2.next());
                        }
                    } else {
                        noMoreFiles = true;
                    }
                }
                StringBuffer sb = new StringBuffer();
                if (noMoreFiles) {
                    return false;
                } else {
                    for (Iterator iter = sending.iterator(); iter.hasNext();) {
                        CompilationUnit cu = (CompilationUnit) iter.next();
                        if (sb.length() > 0)
                            sb.append('#');
                        sb.append(cu.toString());
                    }
                    sendCommand("PctCompile", sb.toString());
                    return true;
                }
            } else {
                return false;
            }
        }

        public void setCustomOptions(Map options) {

        }

        private String getOptions() {
            StringBuffer sb = new StringBuffer();
            sb.append(Boolean.toString(runList)).append(';');
            sb.append(Boolean.toString(minSize)).append(';');
            sb.append(Boolean.toString(md5)).append(';');
            sb.append(Boolean.toString(xcode)).append(';');
            sb.append(xcodeKey == null ? "" : xcodeKey).append(';');
            sb.append(Boolean.toString(forceCompile)).append(';');
            sb.append(Boolean.toString(noCompile)).append(';');
            sb.append(Boolean.toString(keepXref));

            return sb.toString();
        }

        public void handleResponse(String command, String parameter, boolean err,
                String customResponse, List returnValues) {
            if ("pctCompile".equalsIgnoreCase(command)) {
                String[] str = customResponse.split("/");
                int ok = 0, notOk = 0;
                try {
                    ok = Integer.parseInt(str[0]);
                    notOk = Integer.parseInt(str[1]);
                } catch (NumberFormatException nfe) {
                    throw new BuildException("Invalid response from pctCompile command ("
                            + customResponse + ")", nfe);
                }
                addCompilationCounters(ok, notOk);
                logMessages(returnValues);
                if (err) {
                    setBuildException();
                    if (failOnError) {
                        quit();
                    }
                }
            }
        }
    }

    private static class CompilationUnit {
        private File inputFile;
        private File outputDir;
        private File debugFile;
        private File preprocessFile;
        private File listingFile;
        private File xrefFile;
        private File pctRoot;
        private String targetFile;

        public int hashCode() {
            final int prime = 31;
            int result = 1;
            result = prime * result + ((inputFile == null) ? 0 : inputFile.hashCode());
            return result;
        }

        public boolean equals(Object obj) {
            if (this == obj)
                return true;
            if (obj == null)
                return false;
            if (getClass() != obj.getClass())
                return false;
            CompilationUnit other = (CompilationUnit) obj;
            if (inputFile == null) {
                if (other.inputFile != null)
                    return false;
            } else if (!inputFile.equals(other.inputFile))
                return false;
            return true;
        }

        public String toString() {
            return inputFile + "|" + outputDir + "|"
                    + (debugFile == null ? "" : debugFile.getAbsolutePath()) + "|"
                    + (preprocessFile == null ? "" : preprocessFile.getAbsolutePath()) + "|"
                    + (listingFile == null ? "" : listingFile.getAbsolutePath()) + "|" + xrefFile
                    + "|" + pctRoot + "|" + targetFile;
        }

    }

    public static class RCodeMapper implements FileNameMapper {

        /**
         * Ignored.
         * 
         * @param from ignored.
         */
        public void setFrom(String from) {
        }

        /**
         * Ignored.
         * 
         * @param to ignored.
         */
        public void setTo(String to) {
        }

        /**
         * Returns an one-element array containing the source file name.
         * 
         * @param sourceFileName the name to map.
         * @return the source filename in a one-element array.
         */
        public String[] mapFileName(String sourceFileName) {
            if (sourceFileName == null)
                return null;
            int extPos = sourceFileName.lastIndexOf('.');

            return new String[]{sourceFileName.substring(0, extPos) + ".r"};
        }
    }

}