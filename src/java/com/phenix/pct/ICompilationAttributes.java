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

import java.io.File;

import org.apache.tools.ant.types.ResourceCollection;

/**
 * Compilation tasks attributes (PCTCompile and PCTBgCompile).
 */
public interface ICompilationAttributes {

    /**
     * MIN-SIZE option of COMPILE statement
     */
    void setMinSize(boolean minSize);

    /**
     * STRING-XREF option of COMPILE statement. Ignored with Progress v9 and below
     */
    void setStringXref(boolean stringXref);

    /**
     * Append XREF strings in one file
     */
    void setAppendStringXref(boolean appendStringXref);

    /**
     * SAVE option of COMPILE statement
     */
    void setSaveR(boolean saveR);

    /**
     * Force compilation, without checking XREF
     */
    void setForceCompile(boolean forceCompile);

    /**
     * Create listing files during compilation
     */
    void setListing(boolean listing);

    /**
     * Switch listing source to PREPROCESS'ed file
     *
     * @param source Can be empty or 'PREPROCESS'
     */
    void setListingSource(String source);

    /**
     * PAGE-SIZE option of COMPILE statement.
     */
    void setPageSize(int pageSize);

    /**
     * PAGE-WIDTH option of COMPILE statement.
     */
    void setPageWidth(int pageWidth);

    /**
     * Ignore include files matching this pattern
     */
    void setIgnoredIncludes(String pattern);

    /**
     * Create preprocessing files during compilation
     */
    void setPreprocess(boolean preprocess);

    /**
     * Output directory for preprocess files
     */
    void setPreprocessDir(File dir);

    /**
     * Create debug list files during compilation
     */
    void setDebugListing(boolean debugListing);

    /**
     * Output directory for debug listing files
     */
    void setDebugListingDir(File debugListingDir);

    /**
     * Flattens debug listing files. Debug listing file of foo/bar/proc.p will be called foo_bar_proc.p in debugListingDir
     */
    void setFlattenDebugListing(boolean flatten);

    /**
     * Disables completely XREF generation and parsing. This means there's no generated file in .pct
     * subdirectory.
     */
    void setNoParse(boolean noParse);

    /**
     * Enables/Disables compiler:multi-compile option
     */
    void setMultiCompile(boolean multiCompile);

    /**
     * Enables STREAM-IO attribute in COMPILE statement
     */
    void setStreamIO(boolean streamIO);

    /**
     * Enables v6Frame attribute in COMPILE statement
     */
    void setv6Frame(boolean v6Frame);

    /**
     * Enables USE-REVVIDEO attribute in COMPILE statement
     */
    void setUseRevvideo(boolean useRevvideo);

    /**
     * Enables USE-UNDERLINE attribute in COMPILE statement
     */
    void setUseUnderline(boolean useUnderline);

    /**
     * Generates a .xref in the .pct directory, result of XREF option in the COMPILE statement
     */
    void setKeepXref(boolean keepXref);

    /**
     * Use XML-XREF instead of standard XREF
     */
    void setXmlXref(boolean xmlXref);

    /**
     * Directory where to store CRC and includes files : .pct subdirectory is created there
     */
    void setXRefDir(File xrefDir);

    /**
     * GENERATE-MD5 option of COMPILE statement
     */
    void setMD5(boolean md5);

    /**
     * Generates a .run file in the .pct directory, which shows internal and external procedures
     * calls
     */
    void setRunList(boolean runList);

    /**
     * Location to store the .r files
     */
    void setDestDir(File destDir);

    /**
     * Procedures are encrypted ?
     */
    void setXCode(boolean xcode);

    /**
     * Compile using a specific key instead of the default key
     */
    void setXCodeKey(String xcodeKey);

    /**
     * Identifies which language segments to include in the compiled r-code. LANGUAGES option of the
     * COMPILE statement
     */
    void setLanguages(String languages);

    /**
     * TEXT-SEG-GROWTH option of COMPILE statement
     */
    void setTextGrowth(int growthFactor);

    /**
     * Specifies progress percentage
     *
     * @param progPerc int (a value from 0 until 100)
     */
    void setProgPerc(int progPerc);

    void setRequireFullKeywords(boolean requireFullKeywords);

    void setRequireFieldQualifiers(boolean requireFieldQualifiers);

    void setRequireFullNames(boolean requireFullNames);

    /**
     * Adds a ResourceCollection to compile
     */
    void add(ResourceCollection rc);

    void addConfiguredOEFileset(OpenEdgeFileSet oefs);

    /**
     * Immediately stop compiling when a compilation error occurs
     *
     * @param stopOnError Boolean
     * @since PCT build #185
     */
    void setStopOnError(boolean stopOnError);

    /**
     * 1 will display files to be recompiled (and reason). 2 will display all files. 0 doesn't display anything
     */
    void setDisplayFiles(int display);

    /**
     * Callback class for compilation procedure. Only under OE 11.3+
     *
     * @param callback ABL Class
     */
    void setCallbackClass(String callback);

    /**
     * json value will display, the errors and warnings in json format
     *
     * @param outputType String
     */
    void setOutputType(String outputType);
}
