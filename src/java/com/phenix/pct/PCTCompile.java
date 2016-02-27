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

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.types.FileSet;
import org.apache.tools.ant.types.Resource;
import org.apache.tools.ant.types.ResourceCollection;
import org.apache.tools.ant.types.resources.FileResource;
import org.apache.tools.ant.util.FileUtils;

/**
 * Class for compiling Progress procedures
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class PCTCompile extends PCTRun {
    private List<ResourceCollection> resources = new ArrayList<ResourceCollection>();
    private boolean minSize = false;
    private boolean md5 = true;
    private boolean forceCompile = false;
    private boolean xcode = false;
    private boolean noCompile = false;
    private boolean runList = false;
    private boolean listing = false;
    private String listingSource = null;
    private boolean preprocess = false;
    private boolean debugListing = false;
    private boolean keepXref = false;
    private boolean noParse = false;
    private boolean multiCompile = false;
    private boolean streamIO = false;
	private boolean v6Frame = false;
    private boolean stringXref = false;
    private boolean appendStringXref = false;
    private boolean saveR = true;
    private boolean twoPass = false;
    private boolean stopOnError = false;
    private boolean xmlXref = false;
    private String xcodeKey = null;
    private String languages = null;
    private int growthFactor = -1;
    private File destDir = null;
    private File xRefDir = null;
    private int progPerc = 0;
    private File preprocessDir = null;
    private File debugListingDir = null;
    private boolean flattenDbg = true;
    private String ignoredIncludes = null;

    // Internal use
    private int fsListId = -1;
    private File fsList = null;
    private int paramsId = -1;
    private File params = null;
    private int twoPassId = -1;
    private int numFiles = 0;

    /**
     * Creates a new PCTCompile object
     */
    public PCTCompile() {
        super();

        fsListId = PCT.nextRandomInt();
        paramsId = PCT.nextRandomInt();
        twoPassId = PCT.nextRandomInt();

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
     * Append Xref Strings in one file
     * 
     * @param AppendStringXref "true|false|on|off|yes|no"
     */
    public void setAppendStringXref(boolean appendStringXref) {
        this.appendStringXref = appendStringXref;
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

    public void setListingSource(String source) {
        if ((source == null) || (source.trim().length() == 0) || ("preprocessor".equalsIgnoreCase(source.trim())))
            this.listingSource = source;
        else
            throw new BuildException("Invalid listingSource attribute : " + source);
    }

    /**
     * Ignore Includes matching this pattern
     * 
     * @param pattern "can-do pattern for includefile"
     * 
     * @since 2.x
     */
    public void setIgnoredIncludes(String pattern) {
        this.ignoredIncludes = pattern;
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

    public void setDebugListingDir(File debugListingDir) {
        this.debugListingDir = debugListingDir;
    }

    public void setFlattenDebugListing(boolean flatten) {
        this.flattenDbg = flatten;
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
     * subdirectory.
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
     * Enables v6Frame attribute in COMPILE statement
     * 
     * @param v6Frame "true|false|on|off|yes|no"
     */
    public void setv6Frame(boolean v6Frame) {
        this.v6Frame = v6Frame;
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
     * Use XML-XREF instead of standard XREF ?
     */
    public void setXmlXref(boolean xmlXref) {
        this.xmlXref = xmlXref;
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
     * Specifies progress percentage
     * 
     * @param progPerc int (a value from 0 until 100)
     */
    public void setProgPerc(int progPerc) {
        this.progPerc = progPerc;
    }

    /**
     * Legacy method. Use add(ResourceCollection)
     */
    public void addFileset(FileSet set) {
        add(set);
    }

    /**
     * Adds a ResourceCollection to compile
     * 
     * @param rc ResourceCollection
     */
    public void add(ResourceCollection rc) {
        resources.add(rc);
    }

    public void addConfiguredOEFileset(OpenEdgeFileSet oefs) {
        resources.add(oefs.getCompilationFileSet(getProject()));
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

    /**
     * Two-pass compilation: first pass preprocess source code, second pass compiles the result
     * 
     * @param twoPass Boolean
     * @since PCT 0.19
     */
    public void setTwoPass(boolean twoPass) {
        this.twoPass = twoPass;
    }

    /**
     * Immediately stop compiling when a compilation error occurs
     * 
     * @param stopOnError Boolean
     * @sinc PCT build #185
     */
    public void setStopOnError(boolean stopOnError) {
        this.stopOnError = stopOnError;
    }

    private boolean isDirInPropath(File dir) {
        if (propath == null)
            return false;
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
        // Map to quickly retrieve files associated with a base dir
        Map<String, List<String>> files = new HashMap<String, List<String>>();
        // And a list to keep order
        List<String> orderedBaseDirs = new ArrayList<String>();

        for (ResourceCollection rc : resources) {
            Iterator<Resource> iter = rc.iterator();
            while (iter.hasNext()) {
                FileResource frs = (FileResource) iter.next();

                // Each file is associated with its base directory
                String resBaseDir = "";
                if (relativePaths) {
                    if (!isDirInPropath(frs.getBaseDir()))
                        log(MessageFormat.format(Messages.getString("PCTCompile.48"), frs
                                .getBaseDir().getAbsolutePath()), Project.MSG_WARN);
                    try {
                        resBaseDir = FileUtils.getRelativePath(
                                (baseDir == null ? getProject().getBaseDir() : baseDir),
                                frs.getBaseDir()).replace('/', File.separatorChar);
                    } catch (Exception caught) {
                        throw new BuildException(caught);
                    }
                } else {
                    resBaseDir = frs.getBaseDir().getAbsolutePath(); //$NON-NLS-1$
                }

                // And stored in this set
                List<String> set = files.get(resBaseDir);
                if (set == null) {
                    set = new ArrayList<String>();
                    files.put(resBaseDir, set);
                    orderedBaseDirs.add(resBaseDir);
                }
                if (frs.isDirectory()) {
                    log("Skipping " + frs.getName() + " as it is a directory", Project.MSG_INFO);
                } else {
                    set.add(frs.getName());
                    numFiles++;
                }
            }
        }

        // Then files list is written to temp file
        BufferedWriter bw = null;
        try {
            bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(fsList),
                    getCharset()));

            for (String baseDir : orderedBaseDirs) {
                bw.write("FILESET=" + baseDir);
                bw.newLine();

                for (String f : files.get(baseDir)) {
                    bw.write(f);
                    bw.newLine();
                }
            }
        } catch (IOException caught) {
            throw new BuildException(Messages.getString("PCTCompile.2"), caught); //$NON-NLS-1$
        } finally {
            if (bw != null) {
                try {
                    bw.close();
                } catch (IOException uncaught) {

                }
            }
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
            bw.write("STOPONERROR=" + (stopOnError ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("XCODE=" + (this.xcode ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("NOCOMPILE=" + (this.noCompile ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("RUNLIST=" + (this.runList ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("LISTING=" + (this.listing ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            if (listingSource != null) {
                bw.write("LISTINGSOURCE=" + listingSource); //$NON-NLS-1$
                bw.newLine();
            }
            if (ignoredIncludes != null) {
                bw.write("IGNOREDINCLUDES=" + this.ignoredIncludes); //$NON-NLS-1$
                bw.newLine();
            }
            bw.write("PREPROCESS=" + (this.preprocess ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            if (preprocess && (preprocessDir != null)) {
                bw.write("PREPROCESSDIR=" + preprocessDir.getAbsolutePath());
                bw.newLine();
            }
            bw.write("DEBUGLISTING=" + (this.debugListing ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            if (debugListing && (debugListingDir != null)) {
                bw.write("DEBUGLISTINGDIR=" + debugListingDir.getAbsolutePath());
                bw.newLine();
            }
            bw.write("FLATTENDBG=" + (this.flattenDbg ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("KEEPXREF=" + (this.keepXref ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("XMLXREF=" + (this.xmlXref ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("NOPARSE=" + (this.noParse ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("STRINGXREF=" + (this.stringXref ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("APPENDSTRINGXREF=" + (this.appendStringXref ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("MULTICOMPILE=" + (this.multiCompile ? 1 : 0));
            bw.newLine();
            bw.write("STREAM-IO=" + (this.streamIO ? 1 : 0));
            bw.newLine();
            if (v6Frame) {
                bw.write("V6FRAME=1");
                bw.newLine();
            }
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
            if (twoPass) {
                bw.write("TWOPASS=1");
                bw.newLine();
                bw.write("TWOPASSID=" + Integer.toString(twoPassId));
                bw.newLine();
            }

            if (this.progPerc > 0) {
                bw.write("PROGPERC=" + this.progPerc); //$NON-NLS-1$
                bw.newLine();
                bw.write("NUMFILES=" + numFiles); //$NON-NLS-1$
                bw.newLine();
            }

            bw.close();
        } catch (IOException ioe) {
            throw new BuildException(Messages.getString("PCTCompile.3"), ioe); //$NON-NLS-1$
        }
    }

    private boolean createDir(File dir) {
        if (dir.exists() && !dir.isDirectory()) {
            return false;
        } 
        if (!dir.exists() && !dir.mkdirs()) {
            return false;
        }
        return true;
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        // File xRefDir = null; // Where to store XREF files

        // Create dest directory if necessary
        if (destDir == null) {
            cleanup();
            throw new BuildException(Messages.getString("PCTCompile.34")); //$NON-NLS-1$
        }
        if (!createDir(destDir)) {
            cleanup();
            throw new BuildException(MessageFormat.format(Messages.getString("PCTCompile.36"), "destDir")); //$NON-NLS-1$
        }

        // Test xRef directory
        if (this.xRefDir == null) {
            this.xRefDir = new File(this.destDir, ".pct"); //$NON-NLS-1$
        }
        if (!createDir(xRefDir)) {
            cleanup();
            throw new BuildException(MessageFormat.format(Messages.getString("PCTCompile.36"), "xrefDir")); //$NON-NLS-1$
        }
        
        // If preprocessDir is set, then preprocess is always set to true
        if (preprocessDir != null) {
            preprocess = true;
            if (!createDir(preprocessDir)) {
                cleanup();
                throw new BuildException(MessageFormat.format(Messages.getString("PCTCompile.36"), "preprocessDir")); //$NON-NLS-1$
            }
        }
        if (debugListingDir != null) {
            debugListing = true;
            if (!createDir(debugListingDir)) {
                cleanup();
                throw new BuildException(MessageFormat.format(Messages.getString("PCTCompile.36"), "debugListingDir")); //$NON-NLS-1$
            }
        }
        
        if (twoPass) {
            log("Two pass compilation activated", Project.MSG_VERBOSE);
        }

        log(Messages.getString("PCTCompile.40"), Project.MSG_INFO); //$NON-NLS-1$

        // Checking xcode and (listing || preprocess) attributes -- They're mutually exclusive
        if (this.xcode && (this.listing || this.preprocess)) {
            log(Messages.getString("PCTCompile.43"), Project.MSG_INFO); //$NON-NLS-1$ // TODO Update this message
            this.listing = false; // Useless for now, but just in case...
            this.preprocess = false; // Useless for now, but just in case...
        }

        // Verify resource collections
        for (ResourceCollection rc : resources) {
            if (!rc.isFilesystemOnly())
                throw new BuildException(
                        "PCTCompile only supports file-system resources collections");
        }

        // Ignore appendStringXref when stringXref is not enabled
        if (!this.stringXref && this.appendStringXref) {
            log(Messages.getString("PCTCompile.90"), Project.MSG_WARN); //$NON-NLS-1$
            this.appendStringXref = false;
        }

        // Check valid value for ProgPerc
        if ((this.progPerc < 0) || (this.progPerc > 100)) {
            log(MessageFormat.format(Messages.getString("PCTCompile.91"), progPerc), Project.MSG_WARN); //$NON-NLS-1$          
            this.progPerc = 0;
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

        if (!getDebugPCT()) {
            if (fsList.exists() && !fsList.delete()) {
                log(MessageFormat.format(
                        Messages.getString("PCTCompile.42"), fsList.getAbsolutePath()), Project.MSG_INFO); //$NON-NLS-1$
            }

            if (params.exists() && !params.delete()) {
                log(MessageFormat.format(
                        Messages.getString("PCTCompile.42"), params.getAbsolutePath()), Project.MSG_INFO); //$NON-NLS-1$
            }
        }
    }
}