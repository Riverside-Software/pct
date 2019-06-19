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

/**
 * Feeds properties with Progress version
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 * @version $Revision$
 */
public class ProgressVersion extends PCT {
    private String fullVersion;
    private String reducedVersion;
    private String majorVersion;
    private String minorVersion;
    private String revision;
    private String patchLevel;
    private String rcodeVersion;
    private String bitness;

    public void setMajorVersion(String majorVersion) {
        this.majorVersion = majorVersion;
    }

    public void setMinorVersion(String minorVersion) {
        this.minorVersion = minorVersion;
    }

    public void setRevision(String revision) {
        this.revision = revision;
    }

    public void setPatchLevel(String patchLevel) {
        this.patchLevel = patchLevel;
    }

    public void setFullVersion(String fullVersion) {
        this.fullVersion = fullVersion;
    }

    public void setReducedVersion(String reducedVersion) {
        this.reducedVersion = reducedVersion;
    }

    public void setRCodeVersion(String rcodeVersion) {
        this.rcodeVersion = rcodeVersion;
    }

    public void setBitness(String bitness) {
        this.bitness = bitness;
    }

    @Override
    public void execute() {
        checkDlcHome();
        if (this.majorVersion != null)
            getProject().setNewProperty(this.majorVersion, Integer.toString(getDLCMajorVersion()));
        if (this.minorVersion != null)
            getProject().setNewProperty(this.minorVersion, Integer.toString(getDLCMinorVersion()));
        if (this.revision != null)
            getProject().setNewProperty(this.revision, getDLCMaintenanceVersion());
        if (this.patchLevel != null)
            getProject().setNewProperty(this.patchLevel, getDLCPatchLevel());
        if (this.fullVersion != null)
            getProject().setNewProperty(this.fullVersion, getFullVersion());
        if (this.reducedVersion != null)
            getProject().setNewProperty(this.reducedVersion, getReducedVersion());
        if (this.rcodeVersion != null)
            getProject().setNewProperty(this.rcodeVersion, Long.toString(getRCodeVersion()));
        if (this.bitness != null)
            getProject().setNewProperty(this.bitness, is64bits() ? "64" : "32");
    }

}
