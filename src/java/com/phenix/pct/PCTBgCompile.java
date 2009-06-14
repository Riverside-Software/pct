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

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

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
    private String xcodeKey = null;
    private File destDir = null;
    private File xRefDir = null;
    private Mapper mapperElement = null;

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
     * @param fileNameMapper the mapper to add.
     * @since Ant 1.6.3
     */
    public void add(FileNameMapper fileNameMapper) {
        createMapper().add(fileNameMapper);
    }

    /**
     * Define the mapper to map source to destination files.
     * @return a mapper to be configured.
     * @exception BuildException if more than one mapper is defined.
     */
    public Mapper createMapper() throws BuildException {
        if (mapperElement != null) {
            throw new BuildException("Cannot define more than one mapper",
                                     getLocation());
        }
        mapperElement = new Mapper(getProject());
        return mapperElement;
    }

    /**
     * returns the mapper to use based on nested elements or the
     * flatten attribute.
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
        // File xRefDir = null; // Where to store XREF files

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

        super.execute();
    }

    protected PCTListener getListener(PCTBgRun parent) throws IOException {
        return new PCTCompileListener(this);
    }
    
    private static class CompilationUnit {
        private File inputFile;
        private File outputDir;
        private File debugFile;
        private File preprocessFile;
        private File listingFile;
        private File xrefFile;
        private File pctRoot;

        public String toString() {
            return inputFile + "|" + outputDir + "|" + debugFile + "|" + preprocessFile + "|" + listingFile + "|" + xrefFile + "|" + pctRoot + "|";
        }

    }
    
    private class PCTCompileListener extends PCTListener {
        boolean leave = false;
        boolean error = false;
        private List units = new ArrayList();
        
        /**
         * Creates a new PCTCRCListener
         * 
         * @param parent PCTBgRun instance
         * @throws IOException Server socket fails
         */
        public PCTCompileListener(PCTBgCompile parent) throws IOException {
            super(parent);
            
            // Génération des unités de compilation
            File dotPCTDir = new File(destDir, ".pct");
            for (Iterator e = filesets.iterator(); e.hasNext() && !leave;) {
                FileSet fs = (FileSet) e.next();

                // And get files from fileset
                String[] dsfiles = fs.getDirectoryScanner(getProject()).getIncludedFiles();
                for (int i = 0; i < dsfiles.length && !leave; i++) {
                    // File to be compiled
                    File inputFile = new File(fs.getDir(getProject()), dsfiles[i]);
                    int srcExtPos = dsfiles[i].lastIndexOf('.');
                    String extension = dsfiles[i].substring(srcExtPos);
                    
                    // Output directory for .r file
                    String[] outputNames = getMapper().mapFileName(dsfiles[i]);
                    if ((outputNames != null) && (outputNames.length >= 1)) {
                        File outputDir = null;
                        File outputFile = new File(destDir, outputNames[0]);
                        if (extension.equalsIgnoreCase(".cls")) {
                            // Specific case, as Progress prepends package name automatically
                            // So outputDir has to be rootDir
                            outputDir = destDir;
                        }
                        else {
                            outputDir = new File(destDir, outputNames[0]).getParentFile();
                        }
                        
                        if (!outputDir.exists())
                            outputDir.mkdirs();
                        
                        // File produced by Progress compiler (always source file name with extension .r)
                        int extPos = inputFile.getName().lastIndexOf('.');
                        File progressFile = new File(outputDir, inputFile.getName().substring(0, extPos) + ".r");
//                        File outputFile = new File(destDir, outputNames[0]);
                        
                        // Output directory for PCT files appended with filename
                        int extPos2 = outputNames[0].lastIndexOf('.');
                        File PCTRoot = new File(dotPCTDir, outputNames[0].substring(0, extPos2) + dsfiles[i].substring(srcExtPos));
                        int rIndex = PCTRoot.getAbsolutePath().lastIndexOf('.');
                        // Output directory for PCT files
                        File PCTDir = PCTRoot.getParentFile();
                        if (!PCTDir.exists())
                            PCTDir.mkdirs();
                        
                        CompilationUnit unit = new CompilationUnit();
                        units.add(unit);
                        unit.inputFile=inputFile;
                        unit.outputDir=outputDir;
                        unit.debugFile = new File((rIndex == -1 ? PCTRoot.getAbsolutePath() : PCTRoot.getAbsolutePath().substring(0, rIndex)) + ".dbg");
                        unit.preprocessFile = new File(PCTRoot.getAbsolutePath() + ".preprocess");
                        unit.listingFile = new File(PCTRoot.getAbsolutePath());
                        unit.xrefFile=new File(PCTRoot.getAbsolutePath() + ".xref");
                        unit.pctRoot = PCTRoot;
//                        StringBuffer sb = new StringBuffer("pctCompile ");
//    
//                        sb.append(inputFile.getAbsolutePath());
//                        sb.append('|');
//                        sb.append(outputDir);
//                        sb.append('|');
//                        if (debugListing)
//                            sb.append((rIndex == -1 ? PCTRoot.getAbsolutePath() : PCTRoot.getAbsolutePath().substring(0, rIndex))).append(".dbg");
//                        sb.append('|');
//                        if (preprocess)
//                            sb.append(PCTRoot.getAbsolutePath()).append(".preprocess");
//                        sb.append('|');
//                        if (listing)
//                            sb.append(PCTRoot.getAbsolutePath());
//                        sb.append('|');
//                        sb.append(new File(destDir, "XREF").getAbsolutePath());
//                        sb.append('|');
//                        sb.append(PCTRoot.getAbsolutePath());
//                        sb.append('|');
//                        if (progressFile.compareTo(outputFile) != 0)
//                            sb.append(outputFile.getAbsolutePath());
//                        sendCommand(sb.toString());
                    }
                }
            }
        }

        /**
         * This task will run the pct/pctBgCRC.p, run its internal procedure getCRC, and then output
         * the result to destFile
         */
        public boolean custom(int threadNumber) throws IOException {
            // Starting background process
            sendCommand(threadNumber, "launch pct/pctBgCompile.p");
            // Getting CRC
//            sendCommand("getCRC");

            // Setting global options
//            if (minSize)
//                sendCommand("setMinSize");
//            if (md5)
//                sendCommand("setMD5");
//            if (xcode)
//                sendCommand("setXCode");
//            if (xcodeKey != null)
//                sendCommand("setXCodeKey " + xcodeKey);
//            if (forceCompile)
//                sendCommand("setForceCompilation");
//            if (runList)
//                sendCommand("setRunList");
//            if (noCompile)
//                sendCommand("setNoCompile");
            
            // .pct subdirectory handles .crc and .inc files 
//            File dotPCTDir = new File(destDir, ".pct");
//            for (Enumeration e = filesets.elements(); e.hasMoreElements() && !leave;) {
//                FileSet fs = (FileSet) e.nextElement();
//
//                // And get files from fileset
//                String[] dsfiles = fs.getDirectoryScanner(getProject()).getIncludedFiles();
//                for (int i = 0; i < dsfiles.length && !leave; i++) {
//                    // File to be compiled
//                    File inputFile = new File(fs.getDir(getProject()), dsfiles[i]);
//                    int srcExtPos = dsfiles[i].lastIndexOf('.');
//                    String extension = dsfiles[i].substring(srcExtPos);
//                    
//                    // Output directory for .r file
//                    String[] outputNames = getMapper().mapFileName(dsfiles[i]);
//                    if ((outputNames != null) && (outputNames.length >= 1)) {
//                        File outputDir = null;
//                        File outputFile = new File(destDir, outputNames[0]);
//                        if (extension.equalsIgnoreCase(".cls")) {
//                            // Specific case, as Progress prepends package name automatically
//                            // So outputDir has to be rootDir
//                            outputDir = destDir;
//                        }
//                        else {
//                            outputDir = new File(destDir, outputNames[0]).getParentFile();
//                        }
//                        
//                        if (!outputDir.exists())
//                            outputDir.mkdirs();
//                        
//                        // File produced by Progress compiler (always source file name with extension .r)
//                        int extPos = inputFile.getName().lastIndexOf('.');
//                        File progressFile = new File(outputDir, inputFile.getName().substring(0, extPos) + ".r");
////                        File outputFile = new File(destDir, outputNames[0]);
//                        
//                        // Output directory for PCT files appended with filename
//                        int extPos2 = outputNames[0].lastIndexOf('.');
//                        File PCTRoot = new File(dotPCTDir, outputNames[0].substring(0, extPos2) + dsfiles[i].substring(srcExtPos));
//                        int rIndex = PCTRoot.getAbsolutePath().lastIndexOf('.');
//                        // Output directory for PCT files
//                        File PCTDir = PCTRoot.getParentFile();
//                        if (!PCTDir.exists())
//                            PCTDir.mkdirs();
//                        
//                        StringBuffer sb = new StringBuffer("pctCompile ");
//    
//                        sb.append(inputFile.getAbsolutePath());
//                        sb.append('|');
//                        sb.append(outputDir);
//                        sb.append('|');
//                        if (debugListing)
//                            sb.append((rIndex == -1 ? PCTRoot.getAbsolutePath() : PCTRoot.getAbsolutePath().substring(0, rIndex))).append(".dbg");
//                        sb.append('|');
//                        if (preprocess)
//                            sb.append(PCTRoot.getAbsolutePath()).append(".preprocess");
//                        sb.append('|');
//                        if (listing)
//                            sb.append(PCTRoot.getAbsolutePath());
//                        sb.append('|');
//                        sb.append(new File(destDir, "XREF").getAbsolutePath());
//                        sb.append('|');
//                        sb.append(PCTRoot.getAbsolutePath());
//                        sb.append('|');
//                        if (progressFile.compareTo(outputFile) != 0)
//                            sb.append(outputFile.getAbsolutePath());
//                        sendCommand(sb.toString());
//                    }
//                }
//            }
            return error;
        }

        public void handleLaunch(Integer threadNumber, String param) throws IOException {
            // Nothing
            sendCommand(threadNumber.intValue(), "setOptions " + getOptions());
        }

        private String getOptions() {
            StringBuffer sb = new StringBuffer();
            sb.append(Boolean.toString(runList)).append(';');
            sb.append(Boolean.toString(minSize)).append(';');
            sb.append(Boolean.toString(md5)).append(';');
            sb.append(Boolean.toString(xcode)).append(';');
            sb.append(xcodeKey).append(';');
            sb.append(Boolean.toString(forceCompile)).append(';');
            sb.append(Boolean.toString(noCompile));
            
            return sb.toString();
        }

        public void handleSetOptions(Integer threadNumber, String param) throws IOException {
            // Nothing
            sendCommand(threadNumber.intValue(), "GetCRC");
        }

        /**
         * Handles getCRC response
         */
        public void handleGetCRC(Integer threadNumber, String param /*String param, String ret, List strings*/) throws IOException {
            // Nothing
            handlePctCompile(threadNumber, "");
        }

        public void handlePctCompile(Integer threadNumber, String param) throws IOException {
            if (statuses[threadNumber.intValue()].lastCmdStatus == 2) buildException = true;
            synchronized (units) {
                int size = units.size();
                if (size > 0) {
                    int numCU = 1;
                    /* if (size > 1000)
                        numCU = 50;
                    else */ if (size > 100)
                        numCU = 10;
                    StringBuffer sb = new StringBuffer();
                    for (int zz = 0; zz < numCU; zz++) {
                        CompilationUnit cu = (CompilationUnit) units.remove(0);
                        if (sb.length() > 0)
                            sb.append('#');
                        sb.append(cu.toString());
                    }
                    
                    sendCommand(threadNumber.intValue(), "PctCompile " + sb.toString());
                }
                else {
                    sendCommand(threadNumber.intValue(), "Quit");
                }
            }
        }
        
        /**
         * Handles pctCompile response
         */
        /*public void handlePctCompile(String param, String ret, List strings) {
            Iterator i = strings.iterator();
            String errNum = (String) i.next();
            error |= (Integer.parseInt(errNum) > 0);
            leave = (Integer.parseInt(errNum) > 0) && failOnError;
            while (i.hasNext()) {
                log((String) i.next());
            }
        }*/
    }

    public static class RCodeMapper implements FileNameMapper {

        /**
         * Ignored.
         * @param from ignored.
         */
        public void setFrom(String from) {
        }

        /**
         * Ignored.
         * @param to ignored.
         */
        public void setTo(String to) {
        }

        /**
         * Returns an one-element array containing the source file name.
         * @param sourceFileName the name to map.
         * @return the source filename in a one-element array.
         */
        public String[] mapFileName(String sourceFileName) {
            if (sourceFileName == null)
                return null;
            int extPos = sourceFileName.lastIndexOf('.');
            
            return new String[] {sourceFileName.substring(0, extPos) + ".r"};
        }
    }

}