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

import org.apache.tools.ant.BuildException;

/**
 * Describes profiler properties for a PCTRun node
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 * @since 0.19
 */
public class Profiler {
    private boolean enabled = false;
    private boolean coverage = false;
    private boolean statistics = false;
    private String description = "Default description";
    private File outputFile = null, outputDir = null;
    private File listings = null;

    /**
     * Enables or disables profiling for this session
     * 
     * @param enabled Boolean
     */
    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public boolean isEnabled() {
        return enabled;
    }

    /**
     * Enables or disables code coverage for this session
     * 
     * @param coverage Boolean
     */
    public void setCoverage(boolean coverage) {
        this.coverage = coverage;
    }

    public boolean hasCoverage() {
        return coverage;
    }

    /**
     * Enables or disables code statistics for this session
     * 
     * @param statistics Boolean
     */
    public void setStatistics(boolean statistics) {
        this.statistics = statistics;
    }

    public boolean hasStatistics() {
        return statistics;
    }

    /**
     * Defines description for profiler session
     */
    public void setDescription(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }

    /**
     * Defines output directory for profiler
     * 
     * @param outputDir Directory
     */
    public void setOutputDir(File outputDir) {
        this.outputDir = outputDir;
    }

    public File getOutputDir() {
        return outputDir;
    }

    /**
     * Defines output file for profiler
     * 
     * @param outputFile File
     */
    public void setOutputFile(File outputFile) {
        this.outputFile = outputFile;
    }

    public File getOutputFile() {
        return outputFile;
    }

    /**
     * Defines listing directory
     */
    public void setListings(File listings) {
        this.listings = listings;
    }

    public File getListings() {
        return listings;
    }

    /**
     * Validates object. If background task is set to true, then you can't set outputFile, only outputDir
     */
    public void validate(boolean backgroundTask) {
        if (!enabled)
            return;
        if ((outputDir == null) && (outputFile == null))
            throw new BuildException("Either outputDir or outputFile must be defined in Profiler node");
        if ((outputDir != null) && (outputFile != null))
            throw new BuildException("Only one of outputDir or outputFile must be defined in Profiler node");
        if (outputDir != null) {
            if (outputDir.exists() && !outputDir.isDirectory())
                throw new BuildException("Profiler output dir is not a directory");
            if (!outputDir.exists() && !outputDir.mkdirs())
                throw new BuildException("Unable to create profiler output directory");
        }
        if (backgroundTask && (outputFile != null))
            throw new BuildException("Only outputDir can be set for multi-threaded tasks");
        if (listings != null) {
            if (!listings.exists() || !listings.isDirectory())
                throw new BuildException("Listing dir doesn't exist or is not a directory");
        }
    }
}
