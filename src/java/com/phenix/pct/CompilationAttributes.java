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
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.types.ResourceCollection;

public class CompilationAttributes implements ICompilationAttributes {
    private List<ResourceCollection> resources = new ArrayList<>();
    private File destDir = null;
    private File xRefDir = null;
    private File preprocessDir = null;
    private File debugListingDir = null;
    private boolean minSize = false;
    private boolean md5 = true;
    private boolean forceCompile = false;
    private boolean xcode = false;
    private boolean runList = false;
    private boolean listing = false;
    private String listingSource = null;
    private int pageSize = -1;
    private int pageWidth = -1;
    private boolean preprocess = false;
    private boolean debugListing = false;
    private boolean keepXref = false;
    private boolean noParse = false;
    private boolean multiCompile = false;
    private boolean streamIO = false;
    private boolean v6Frame = false;
    private boolean useRevvideo = false;
    private boolean useUnderline = false;
    private boolean stringXref = false;
    private boolean appendStringXref = false;
    private boolean saveR = true;
    private boolean stopOnError = false;
    private boolean xmlXref = false;
    private boolean requireFullKeywords = false;
    private boolean requireFieldQualifiers = false;
    private boolean requireFullNames = false;
    private String languages = null;
    private int growthFactor = -1;
    private int progPerc = 0;
    private boolean flattenDbg = true;
    private String ignoredIncludes = null;
    private int fileList = 0;
    private String callback = null;
    private String outputType = null;

    // Internal use
    private final PCT parent;

    public CompilationAttributes(PCT parent) {
        this.parent = parent;
    }

    @Override
    public void setMinSize(boolean minSize) {
        this.minSize = minSize;
    }

    @Override
    public void setStringXref(boolean stringXref) {
        this.stringXref = stringXref;
    }

    @Override
    public void setAppendStringXref(boolean appendStringXref) {
        this.appendStringXref = appendStringXref;
    }

    @Override
    public void setSaveR(boolean saveR) {
        this.saveR = saveR;
    }

    @Override
    public void setForceCompile(boolean forceCompile) {
        this.forceCompile = forceCompile;
    }

    @Override
    public void setListing(boolean listing) {
        this.listing = listing;
    }

    @Override
    public void setListingSource(String source) {
        if ((source == null) || (source.trim().length() == 0) || ("preprocessor".equalsIgnoreCase(source.trim())))
            this.listingSource = source;
        else
            throw new BuildException("Invalid listingSource attribute : " + source);
    }

    @Override
    public void setPageSize(int pageSize) {
        this.pageSize = pageSize;
    }

    @Override
    public void setPageWidth(int pageWidth) {
        this.pageWidth = pageWidth;
    }

    @Override
    public void setIgnoredIncludes(String pattern) {
        this.ignoredIncludes = pattern;
    }

    @Override
    public void setPreprocess(boolean preprocess) {
        this.preprocess = preprocess;
    }

    @Override
    public void setPreprocessDir(File dir) {
        this.preprocess = true;
        this.preprocessDir = dir;
    }

    @Override
    public void setDebugListing(boolean debugListing) {
        this.debugListing = debugListing;
    }

    @Override
    public void setDebugListingDir(File debugListingDir) {
        this.debugListing = true;
        this.debugListingDir = debugListingDir;
    }

    @Override
    public void setFlattenDebugListing(boolean flatten) {
        this.flattenDbg = flatten;
    }

    @Override
    public void setNoParse(boolean noParse) {
        this.noParse = noParse;
    }

    @Override
    public void setMultiCompile(boolean multiCompile) {
        this.multiCompile = multiCompile;
    }

    @Override
    public void setStreamIO(boolean streamIO) {
        this.streamIO = streamIO;
    }

    @Override
    public void setv6Frame(boolean v6Frame) {
        this.v6Frame = v6Frame;
    }

    @Override
    public void setUseRevvideo(boolean useRevvideo) {
        this.useRevvideo = useRevvideo;
    }

    @Override
    public void setUseUnderline(boolean useUnderline) {
        this.useUnderline = useUnderline;
    }

    @Override
    public void setKeepXref(boolean keepXref) {
        this.keepXref = keepXref;
    }

    @Override
    public void setXmlXref(boolean xmlXref) {
        this.xmlXref = xmlXref;
    }

    @Override
    public void setXRefDir(File xrefDir) {
        this.xRefDir = xrefDir;
    }

    @Override
    public void setMD5(boolean md5) {
        this.md5 = md5;
    }

    @Override
    public void setRunList(boolean runList) {
        this.runList = runList;
    }

    @Override
    public void setDestDir(File destDir) {
        this.destDir = destDir;
    }

    @Override
    public void setXCode(boolean xcode) {
        this.xcode = xcode;
    }

    @Override
    public void setXCodeKey(String xcodeKey) {
        throw new UnsupportedOperationException("Not used anymore");
    }

    @Override
    public void setLanguages(String languages) {
        this.languages = languages;
    }

    @Override
    public void setTextGrowth(int growthFactor) {
        this.growthFactor = growthFactor;
    }

    @Override
    public void setProgPerc(int progPerc) {
        this.progPerc = progPerc;
    }

    @Override
    public void setRequireFullKeywords(boolean requireFullKeywords) {
        this.requireFullKeywords = requireFullKeywords;
    }

    @Override
    public void setRequireFieldQualifiers(boolean requireFieldQualifiers) {
        this.requireFieldQualifiers = requireFieldQualifiers;
    }

    @Override
    public void setRequireFullNames(boolean requireFullNames) {
        this.requireFullNames = requireFullNames;
    }

    @Override
    public void setStopOnError(boolean stopOnError) {
        this.stopOnError = stopOnError;
    }

    @Override
    public void add(ResourceCollection rc) {
        resources.add(rc);
    }

    @Override
    public void addConfiguredOEFileset(OpenEdgeFileSet oefs) {
        resources.add(oefs.getCompilationFileSet(parent.getProject()));
    }

    @Override
    public void setDisplayFiles(int display) {
        this.fileList = display;
    }

    @Override
    public void setCallbackClass(String callback) {
        this.callback = callback;
    }

    @Override
    public void setOutputType(String outputType) {
        this.outputType = outputType;
    }

    public List<ResourceCollection> getResources() {
        return resources;
    }

    public boolean isMinSize() {
        return minSize;
    }

    public boolean isMd5() {
        return md5;
    }

    public boolean isForceCompile() {
        return forceCompile;
    }

    public boolean isXcode() {
        return xcode;
    }

    public boolean isRunList() {
        return runList;
    }

    public boolean isListing() {
        return listing;
    }

    public String getListingSource() {
        return listingSource;
    }

    public int getPageSize() {
        return pageSize;
    }

    public int getPageWidth() {
        return pageWidth;
    }

    public boolean isPreprocess() {
        return preprocess;
    }

    public boolean isDebugListing() {
        return debugListing;
    }

    public boolean isKeepXref() {
        return keepXref;
    }

    public boolean isNoParse() {
        return noParse;
    }

    public boolean isMultiCompile() {
        return multiCompile;
    }

    public boolean isStreamIO() {
        return streamIO;
    }

    public boolean isV6Frame() {
        return v6Frame;
    }

    public boolean isUseRevvideo() {
        return useRevvideo;
    }

    public boolean isUseUnderline() {
        return useUnderline;
    }

    public boolean isStringXref() {
        return stringXref;
    }

    public boolean isAppendStringXref() {
        return appendStringXref;
    }

    public boolean isSaveR() {
        return saveR;
    }

    public boolean isStopOnError() {
        return stopOnError;
    }

    public boolean isXmlXref() {
        return xmlXref;
    }

    public boolean isRequireFullKeywords() {
        return requireFullKeywords;
    }

    public boolean isRequireFieldQualifiers() {
        return requireFieldQualifiers;
    }

    public boolean isRequireFullNames() {
        return requireFullNames;
    }

    public String getLanguages() {
        return languages;
    }

    public int getGrowthFactor() {
        return growthFactor;
    }

    public File getDestDir() {
        return destDir;
    }

    public File getxRefDir() {
        return xRefDir;
    }

    public int getProgPerc() {
        return progPerc;
    }

    public File getPreprocessDir() {
        return preprocessDir;
    }

    public File getDebugListingDir() {
        return debugListingDir;
    }

    public boolean isFlattenDbg() {
        return flattenDbg;
    }

    public String getIgnoredIncludes() {
        return ignoredIncludes;
    }

    public int getFileList() {
        return fileList;
    }

    public String getCallbackClass() {
        return callback;
    }

    public String getOutputType() {
        return outputType;
    }

    protected void writeCompilationProcedure(File f, Charset c) {
        boolean bAbove1173 = parent.getVersion().compareTo(new DLCVersion(11, 7, "3")) >= 0;
        try (FileOutputStream fos = new FileOutputStream(f);
                OutputStreamWriter osw = new OutputStreamWriter(fos, c);
                BufferedWriter bw = new BufferedWriter(osw)) {
            bw.write("DEFINE INPUT PARAMETER ipSrcFile AS CHARACTER NO-UNDO.");
            bw.newLine();
            bw.write("DEFINE INPUT PARAMETER ipSaveDir AS CHARACTER NO-UNDO.");
            bw.newLine();
            bw.write("DEFINE INPUT PARAMETER ipDbg AS CHARACTER NO-UNDO.");
            bw.newLine();
            bw.write("DEFINE INPUT PARAMETER ipListing AS CHARACTER NO-UNDO.");
            bw.newLine();
            bw.write("DEFINE INPUT PARAMETER ipPreprocess AS CHARACTER NO-UNDO.");
            bw.newLine();
            bw.write("DEFINE INPUT PARAMETER ipStrXref AS CHARACTER NO-UNDO.");
            bw.newLine();
            bw.write("DEFINE INPUT PARAMETER ipXREF AS CHARACTER NO-UNDO.");
            bw.newLine();
            bw.write("DEFINE INPUT PARAMETER ipOptions AS CHARACTER NO-UNDO.");
            bw.newLine();

            bw.write("DO ON STOP UNDO, RETRY: IF RETRY THEN DO: COMPILER:ERROR = TRUE. RETURN. END.");
            bw.newLine();
            bw.write("COMPILE VALUE(ipSrcFile) ");
            if (bAbove1173)
                bw.write("OPTIONS ipOptions ");
            if (isSaveR())
                bw.write("SAVE INTO VALUE(ipSaveDir) ");
            bw.write(" DEBUG-LIST VALUE(ipDbg) ");
            if (getLanguages() != null) {
                bw.write("LANGUAGES (\"" + getLanguages() + "\") ");
                if (getGrowthFactor() > 0)
                    bw.write("TEXT-SEG-GROWTH=" + getGrowthFactor() + " ");
            }
            if (isMd5())
                bw.write("GENERATE-MD5 ");
            if (isMinSize())
                bw.write("MIN-SIZE ");
            if (isStreamIO())
                bw.write("STREAM-IO ");
            if (isV6Frame()) {
                bw.write("V6FRAME ");
                if (isUseRevvideo())
                    bw.write("USE-REVVIDEO ");
                else if (isUseUnderline())
                    bw.write("USE-UNDERLINE ");
            }
            if (!isXcode()) {
                bw.write("LISTING VALUE(ipListing) ");
                if (getPageSize() != -1)
                    bw.write("PAGE-SIZE " + getPageSize() + " ");
                if (getPageWidth() != -1)
                    bw.write("PAGE-WIDTH " + getPageWidth() + " ");
                bw.write("PREPROCESS VALUE(ipPreprocess) ");
                bw.write("STRING-XREF VALUE(ipStrXref) ");
                if (isAppendStringXref())
                    bw.write("APPEND ");
                if (isXmlXref())
                    bw.write("XREF-XML VALUE(ipXREF) ");
                else
                    bw.write("XREF VALUE(ipXREF) ");

            }
            bw.write("NO-ERROR.");
            bw.newLine();
            bw.write("END.");
            bw.newLine();
        } catch (IOException caught) {
            throw new BuildException(Messages.getString("PCTCompile.2"), caught); //$NON-NLS-1$
        }
    }

}
