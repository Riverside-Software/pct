/*
 * Copyright  2000-2004 The Apache Software Foundation
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package com.phenix.pct;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.types.FileSet;
import org.apache.tools.ant.util.FileUtils;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;

import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.List;

/**
 * Class for compiling Progress procedures
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class PCTCompile extends PCTRun {
    private List<FileSet> filesets = new ArrayList<FileSet>();
    private boolean minSize = false;
    private boolean md5 = true;
    private boolean forceCompile = false;
    private boolean xcode = false;
    private boolean noCompile = false;
    private boolean runList = false;
    private boolean listing = false;
    private boolean preprocess = false;
    private boolean debugListing = false;
    private boolean keepXref = false;
    private boolean noParse = false;
    private boolean multiCompile = false;
    private boolean streamIO = false;
    private boolean stringXref = false;
    private boolean saveR = true;
    private String xcodeKey = null;
    private String languages = null;
    private int growthFactor = -1;
    private File destDir = null;
    private File xRefDir = null;
    private File preprocessDir = null;

    // Internal use
    private int fsListId = -1;
    private File fsList = null;
    private int paramsId = -1;
    private File params = null;

    /**
     * Creates a new PCTCompile object
     */
    public PCTCompile() {
        super();

        fsListId = PCT.nextRandomInt();
        paramsId = PCT.nextRandomInt();

        fsList = new File(System.getProperty("java.io.tmpdir"), "pct_filesets" + fsListId + ".txt"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        params = new File(System.getProperty("java.io.tmpdir"), "pct_params" + paramsId + ".txt"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
    }

    /**
     * Reduce r-code size ? MIN-SIZE option of the COMPILE statement
     * 
     * @param minSize "true|false|on|off|yes|no"
     */
    public void setMinSize(boolean minSize) {
        this.minSize = minSize;
    }

    /**
     * Generate String Xref Files (STRING-XREF). Option is ignored when working with Progress v9 and
     * below (FIXME)
     * 
     * @param stringXref "true|false|on|off|yes|no"
     * 
     * @since 0.19
     */
    public void setStringXref(boolean stringXref) {
        this.stringXref = stringXref;
    }

    /**
     * Turns on/off R-Code generation in destDir Attribute SAVE=[TRUE|FALSE] from COMPILE statement
     * 
     * @param saveR "true|false|on|off|yes|no"
     * 
     * @since 0.19
     */
    public void setSaveR(boolean saveR) {
        this.saveR = saveR;
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

    public void setPreprocessDir(File dir) {
        this.preprocessDir = dir;
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
     * Disables completely XREF generation and parsing. This means there's no generated file in .pct
     * subdirectory. This attribute is not public right now, still being tested. This is used just
     * to bypass a bug when compiling classes.
     * 
     * @param noParse "true|false|on|off|yes|no"
     */
    public void setNoParse(boolean noParse) {
        this.noParse = noParse;
    }

    /**
     * Enables/Disables compiler:multi-compile option
     * 
     * @param multiCompile "true|false|on|off|yes|no"
     */
    public void setMultiCompile(boolean multiCompile) {
        this.multiCompile = multiCompile;
    }

    /**
     * Enables STREAM-IO attribute in COMPILE statement
     * 
     * @param streamIO "true|false|on|off|yes|no"
     */
    public void setStreamIO(boolean streamIO) {
        this.streamIO = streamIO;
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
     * Identifies which language segments to include in the compiled r-code. LANGUAGES option of the
     * COMPILE statement
     * 
     * @param languages String
     */
    public void setLanguages(String languages) {
        this.languages = languages;
    }

    /**
     * Specifies the factor by which ABL increases the length of strings. TEXT-SEG-GROWTH option of
     * the COMPILE statement
     * 
     * @param growthFactor int (must be positive)
     */
    public void setTextGrowth(int growthFactor) {
        this.growthFactor = growthFactor;
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
     * Use relative paths in COMPILE statements, and when defining PROPATH
     * 
     * @param rel Boolean
     * @since PCT 0.19
     */
    public void setRelativePaths(boolean rel) {
        this.relativePaths = rel;
    }

    private boolean isDirInPropath(File dir) {
        for (String str : propath.list()) {
            if (new File(str).equals(dir))
                return true;
        }
        return false;
    }

    /**
     * 
     * @throws BuildException
     */
    private void writeFileList() throws BuildException {
        try {
            BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(
                    fsList), getCharset()));

            for (FileSet fs : filesets) {
                if (relativePaths) {
                    if (!isDirInPropath(fs.getDir()))
                        log(MessageFormat.format(Messages.getString("PCTCompile.48"), fs.getDir()
                                .getAbsolutePath()), Project.MSG_WARN);
                    try {
                        bw.write("FILESET="
                                + FileUtils.getRelativePath(
                                        (baseDir == null ? getProject().getBaseDir() : baseDir),
                                        fs.getDir()).replace('/', File.separatorChar));
                    } catch (Exception caught) {
                        try {
                            bw.close();
                        } catch (IOException uncaught) {

                        }
                        throw new BuildException(caught);
                    }
                } else
                    bw.write("FILESET=" + fs.getDir(this.getProject()).getAbsolutePath()); //$NON-NLS-1$
                bw.newLine();

                // And get files from fileset
                for (String str : fs.getDirectoryScanner(this.getProject()).getIncludedFiles()) {
                    bw.write(str);
                    bw.newLine();
                }
            }

            bw.close();
        } catch (IOException ioe) {
            throw new BuildException(Messages.getString("PCTCompile.2"), ioe); //$NON-NLS-1$
        }
    }

    /**
     * 
     * @throws BuildException
     */
    private void writeParams() throws BuildException {

        try {
            BufferedWriter bw = new BufferedWriter(new FileWriter(params));
            bw.write("FILESETS=" + fsList.getAbsolutePath()); //$NON-NLS-1$
            bw.newLine();
            bw.write("OUTPUTDIR=" + destDir.getAbsolutePath()); //$NON-NLS-1$
            bw.newLine();
            bw.write("PCTDIR=" + xRefDir.getAbsolutePath()); //$NON-NLS-1$
            bw.newLine();
            bw.write("MINSIZE=" + (this.minSize ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("MD5=" + (this.md5 ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("FORCECOMPILE=" + (this.forceCompile ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("FAILONERROR=" + (failOnError ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("XCODE=" + (this.xcode ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("NOCOMPILE=" + (this.noCompile ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("RUNLIST=" + (this.runList ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("LISTING=" + (this.listing ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("PREPROCESS=" + (this.preprocess ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            if (preprocess && (preprocessDir != null)) {
                bw.write("PREPROCESSDIR=" + preprocessDir.getAbsolutePath());
                bw.newLine();
            }
            bw.write("DEBUGLISTING=" + (this.debugListing ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("KEEPXREF=" + (this.keepXref ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("NOPARSE=" + (this.noParse ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("STRINGXREF=" + (this.stringXref ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("MULTICOMPILE=" + (this.multiCompile ? 1 : 0));
            bw.newLine();
            bw.write("STREAM-IO=" + (this.streamIO ? 1 : 0));
            bw.newLine();
            bw.write("SAVER=" + (this.saveR ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("RELATIVE=" + (relativePaths ? 1 : 0));
            bw.newLine();
            if (languages != null) {
                bw.write("LANGUAGES=" + languages); //$NON-NLS-1$
                bw.newLine();
                if (growthFactor > 0) {
                    bw.write("GROWTH=" + growthFactor); //$NON-NLS-1$
                    bw.newLine();
                }
            }
            if (this.xcodeKey != null) {
                bw.write("XCODEKEY=" + this.xcodeKey); //$NON-NLS-1$
                bw.newLine();
            }
            bw.close();
        } catch (IOException ioe) {
            throw new BuildException(Messages.getString("PCTCompile.3"), ioe); //$NON-NLS-1$
        }
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

        // If preprocessDir is set, then preprocess is always set to true
        if (preprocessDir != null)
            preprocess = true;

        log(Messages.getString("PCTCompile.40"), Project.MSG_INFO); //$NON-NLS-1$

        // Checking xcode and (listing || preprocess) attributes -- They're mutually exclusive
        if (this.xcode && (this.listing || this.preprocess)) {
            log(Messages.getString("PCTCompile.43"), Project.MSG_INFO); //$NON-NLS-1$ // TODO Update this message
            this.listing = false; // Useless for now, but just in case...
            this.preprocess = false; // Useless for now, but just in case...
        }

        checkDlcHome();

        try {
            writeFileList();
            writeParams();
            this.setProcedure(this.getProgressProcedures().getCompileProcedure());
            this.setParameter(params.getAbsolutePath());
            super.execute();
            this.cleanup();
        } catch (BuildException be) {
            this.cleanup();
            throw be;
        }
    }

    /**
     * Delete temporary files if debug not activated
     * 
     * @see PCTRun#cleanup
     */
    protected void cleanup() {
        super.cleanup();

        if (!this.getDebugPCT()) {
            if (this.fsList.exists() && !this.fsList.delete()) {
                log(MessageFormat.format(
                        Messages.getString("PCTCompile.42"), this.fsList.getAbsolutePath()), Project.MSG_VERBOSE); //$NON-NLS-1$
            }

            if (this.params.exists() && !this.params.delete()) {
                log(MessageFormat.format(
                        Messages.getString("PCTCompile.42"), this.params.getAbsolutePath()), Project.MSG_VERBOSE); //$NON-NLS-1$
            }
        }
    }
}