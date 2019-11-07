/**
 * Copyright 2005-2019 Riverside Software
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
import org.apache.tools.ant.types.Path;
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
    private CompilationAttributes compAttrs;

    // Internal use
    private int compId = -1;
    private File compDir = null;
    private int fsListId = -1;
    private File fsList = null;
    private int paramsId = -1;
    private File params = null;
    private int numFiles = 0;

    /**
     * Creates a new PCTCompile object
     */
    public PCTCompile() {
        super();
        compAttrs = new CompilationAttributes(this);

        fsListId = PCT.nextRandomInt();
        paramsId = PCT.nextRandomInt();
        compId = PCT.nextRandomInt();
        fsList = new File(System.getProperty(PCT.TMPDIR), "pct_filesets" + fsListId + ".txt"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        params = new File(System.getProperty(PCT.TMPDIR), "pct_params" + paramsId + ".txt"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        compDir = new File(System.getProperty(PCT.TMPDIR), "pctcomp" + compId); //$NON-NLS-1$ //$NON-NLS-2$
    }

    /**
     * Should only be accessed from CompilationWrapper
     */
    protected void setCompilationAttributes(CompilationAttributes attrs) {
        this.compAttrs = attrs;
    }

    @Override
    public void setProcedure(String procedure) {
        throw new BuildException("Can't set procedure attribute here");
    }

    @Override
    public void setParameter(String param) {
        throw new BuildException("Can't set parameter attribute here");
    }

    /**
     * Generates text file with all files from resource collections
     */
    private void writeFileList() {
        // Map to quickly retrieve files associated with a base dir
        Map<String, List<String>> files = new HashMap<>();
        // And a list to keep order
        List<String> orderedBaseDirs = new ArrayList<>();

        for (ResourceCollection rc : compAttrs.getResources()) {
            Iterator<Resource> iter = rc.iterator();
            while (iter.hasNext()) {
                FileResource frs = (FileResource) iter.next();

                // Each file is associated with its base directory
                String resBaseDir = "";
                if (runAttributes.useRelativePaths()) {
                    if (!isDirInPropath(frs.getBaseDir()))
                        log(MessageFormat.format(Messages.getString("PCTCompile.48"), frs
                                .getBaseDir().getAbsolutePath()), Project.MSG_WARN);
                    try {
                        resBaseDir = FileUtils.getRelativePath(
                                (runAttributes.getBaseDir() == null ? getProject().getBaseDir() : runAttributes.getBaseDir()),
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
                    set = new ArrayList<>();
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
        try (FileOutputStream fos = new FileOutputStream(fsList);
                OutputStreamWriter osw = new OutputStreamWriter(fos, getCharset());
                BufferedWriter bw = new BufferedWriter(osw)) {
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
        }
    }

    /**
     * Generates parameter file for pct/compile.p
     */
    private void writeParams() {
        try (FileWriter fw = new FileWriter(params); BufferedWriter bw = new BufferedWriter(fw)) {
            bw.write("FILESETS=" + fsList.getAbsolutePath()); //$NON-NLS-1$
            bw.newLine();
            if (compAttrs.getDestDir() != null) {
                bw.write("OUTPUTDIR=" + compAttrs.getDestDir().getAbsolutePath()); //$NON-NLS-1$
                bw.newLine();
            }
            bw.write("PCTDIR=" + compAttrs.getxRefDir().getAbsolutePath()); //$NON-NLS-1$
            bw.newLine();
            bw.write("FORCECOMPILE=" + (compAttrs.isForceCompile() ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("STOPONERROR=" + (compAttrs.isStopOnError() ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("XCODE=" + (compAttrs.isXcode() ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("RUNLIST=" + (compAttrs.isRunList() ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("LISTING=" + (compAttrs.isListing() ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            if (compAttrs.getListingSource() != null) {
                bw.write("LISTINGSOURCE=" + compAttrs.getListingSource()); //$NON-NLS-1$
                bw.newLine();
            }
            if (compAttrs.getIgnoredIncludes() != null) {
                bw.write("IGNOREDINCLUDES=" + compAttrs.getIgnoredIncludes()); //$NON-NLS-1$
                bw.newLine();
            }
            bw.write("PREPROCESS=" + (compAttrs.isPreprocess() ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            if (compAttrs.isPreprocess() && (compAttrs.getPreprocessDir() != null)) {
                bw.write("PREPROCESSDIR=" + compAttrs.getPreprocessDir().getAbsolutePath());
                bw.newLine();
            }
            bw.write("DEBUGLISTING=" + (compAttrs.isDebugListing() ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            if (compAttrs.isDebugListing() && (compAttrs.getDebugListingDir() != null)) {
                bw.write("DEBUGLISTINGDIR=" + compAttrs.getDebugListingDir().getAbsolutePath());
                bw.newLine();
            }
            bw.write("FLATTENDBG=" + (compAttrs.isFlattenDbg() ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("KEEPXREF=" + (compAttrs.isKeepXref() ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("XMLXREF=" + (compAttrs.isXmlXref() ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("NOPARSE=" + (compAttrs.isNoParse() ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("STRINGXREF=" + (compAttrs.isStringXref() ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("APPENDSTRINGXREF=" + (compAttrs.isAppendStringXref() ? 1 : 0)); //$NON-NLS-1$
            bw.newLine();
            bw.write("MULTICOMPILE=" + (compAttrs.isMultiCompile() ? 1 : 0));
            bw.newLine();
            bw.write("RELATIVE=" + (runAttributes.useRelativePaths() ? 1 : 0));
            bw.newLine();

            if (compAttrs.getProgPerc() > 0) {
                bw.write("PROGPERC=" + compAttrs.getProgPerc()); //$NON-NLS-1$
                bw.newLine();
                bw.write("NUMFILES=" + numFiles); //$NON-NLS-1$
                bw.newLine();
            }

            bw.write("FULLKW=" + (compAttrs.isRequireFullKeywords() ? 1 : 0));
            bw.newLine();
            bw.write("FIELDQLF=" + (compAttrs.isRequireFieldQualifiers() ? 1 : 0));
            bw.newLine();
            bw.write("FULLNAMES=" + (compAttrs.isRequireFullNames() ? 1 : 0));
            bw.newLine();
            bw.write("FILELIST=" + compAttrs.getFileList());
            bw.newLine();
            if (compAttrs.getCallbackClass() != null) {
                bw.write("CALLBACKCLASS=" + compAttrs.getCallbackClass());
                bw.newLine();
            }
            if (compAttrs.getOutputType() != null) {
                bw.write("OUTPUTTYPE=" + compAttrs.getOutputType());
                bw.newLine();
            }
        } catch (IOException ioe) {
            throw new BuildException(Messages.getString("PCTCompile.3"), ioe); //$NON-NLS-1$
        }
    }

    /**
     * Do the work
     *
     * @throws BuildException Something went wrong
     */
    @Override
    public void execute() {
        // Create dest directory if necessary
        if (compAttrs.getDestDir() != null && !createDir(compAttrs.getDestDir())) {
            cleanup();
            throw new BuildException(MessageFormat.format(Messages.getString("PCTCompile.36"), "destDir")); //$NON-NLS-1$
        }

        if (compDir.exists() || !compDir.mkdirs()) {
            this.cleanup();
            throw new BuildException("Unable to create temp directory for compile procedure");
        }

        if (!compAttrs.isXcode() && (runAttributes.getXCodeSessionKey() != null) && !runAttributes.getXCodeSessionKey().trim().isEmpty()) {
            log("xcode attribute set to false, resetting xcodeSessionKey attribute");
            runAttributes.setXCodeSessionKey(null);
        }

        // Test xRef directory
        if (compAttrs.getxRefDir() == null) {
            compAttrs.setXRefDir(new File(compAttrs.getDestDir(), ".pct")); //$NON-NLS-1$
        }
        if (!createDir(compAttrs.getxRefDir())) {
            cleanup();
            throw new BuildException(MessageFormat.format(Messages.getString("PCTCompile.36"), "xrefDir")); //$NON-NLS-1$
        }

        // If preprocessDir is set, then preprocess is always set to true
        if (compAttrs.getPreprocessDir() != null && !createDir(compAttrs.getPreprocessDir())) {
            cleanup();
            throw new BuildException(MessageFormat.format(Messages.getString("PCTCompile.36"), "preprocessDir")); //$NON-NLS-1$
        }
        if (compAttrs.getDebugListingDir() != null && !createDir(compAttrs.getDebugListingDir())) {
            cleanup();
            throw new BuildException(MessageFormat.format(Messages.getString("PCTCompile.36"), "debugListingDir")); //$NON-NLS-1$
        }

        log(Messages.getString("PCTCompile.40"), Project.MSG_INFO); //$NON-NLS-1$

        // Checking xcode and (listing || preprocess) attributes -- They're mutually exclusive
        if (compAttrs.isXcode() && (compAttrs.isListing() || compAttrs.isPreprocess())) {
            log(Messages.getString("PCTCompile.43"), Project.MSG_INFO); //$NON-NLS-1$ // TODO Update this message
            compAttrs.setListing(false); // Useless for now, but just in case...
            compAttrs.setPreprocess(false); // Useless for now, but just in case...
        }

        // Verify resource collections
        for (ResourceCollection rc : compAttrs.getResources()) {
            if (!rc.isFilesystemOnly()) {
                cleanup();
                throw new BuildException(
                        "PCTCompile only supports file-system resources collections");
            }
        }

        // Ignore appendStringXref when stringXref is not enabled
        if (!compAttrs.isStringXref() && compAttrs.isAppendStringXref()) {
            log(Messages.getString("PCTCompile.90"), Project.MSG_WARN); //$NON-NLS-1$
            compAttrs.setAppendStringXref(false);
        }

        // Check valid value for ProgPerc
        if ((compAttrs.getProgPerc() < 0) || (compAttrs.getProgPerc() > 100)) {
            log(MessageFormat.format(Messages.getString("PCTCompile.91"), compAttrs.getProgPerc()), Project.MSG_WARN); //$NON-NLS-1$
            compAttrs.setProgPerc(0);
        }

        // Display warning message if xmlXref and stringXref used at the same time
        if (compAttrs.isXmlXref() && compAttrs.isStringXref()) {
            log(Messages.getString("PCTCompile.92"), Project.MSG_WARN); //$NON-NLS-1$
        }

        checkDlcHome();

        try {
            compAttrs.writeCompilationProcedure(new File(compDir, "pctcomp.p"), getCharset());
            writeFileList();
            writeParams();
            runAttributes.addPropath(new Path(getProject(), compDir.getAbsolutePath()));
            runAttributes.setProcedure(this.getProgressProcedures().getCompileProcedure());
            runAttributes.setParameter(params.getAbsolutePath());
            super.execute();
            cleanup();
        } catch (BuildException be) {
            this.cleanup();
            throw be;
        }
    }

    @Override
    protected void cleanup() {
        super.cleanup();

        if (getDebugPCT())
            return;
        deleteFile(fsList);
        deleteFile(params);
        deleteFile(compDir);
    }
}
