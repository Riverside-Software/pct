/**
 * Copyright 2005-2025 Riverside Software
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

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import eu.rssw.pct.RCodeInfo;
import eu.rssw.pct.RCodeInfo.InvalidRCodeException;

public class DLCVersion implements Comparable<DLCVersion> {
    public static final DLCVersion UNKNOWN_VERSION = new DLCVersion(0, 0, "");

    private static final String MAIN_PATTERN = "(?:[a-zA-Z]+\\s+)+((\\d+)(?:[A-Z0-9\\u002E])*)\\s+as of(.*)";
    private static final String V11_PATTERN = "\\d+(?:\\u002E(\\d+)(?:\\u002E(\\d+)(?:\\u002E(\\d+))?)?)?[a-zA-Z]*";
    private static final String OLD_PATTERN = "\\d+\\u002E(\\d+)([A-Z])([A-Z0-9]*)";

    private final long rCodeVersion;
    private final int majorVersion;
    private final int minorVersion;
    private final String fullVersion;
    private final String shortVersion;
    private final String maintenanceVersion;
    private final String patchVersion;
    private final String date;
    private final boolean arch;

    /**
     * Only use for testing purposes
     */
    public DLCVersion(int major, int minor, String maintenance) {
        this.majorVersion = major;
        this.minorVersion = minor;
        this.maintenanceVersion = maintenance;
        this.patchVersion = "00";
        this.date = "00/00/00";
        this.rCodeVersion = -1;
        this.arch = false;
        this.fullVersion = major + "." + minor + maintenance;
        this.shortVersion = fullVersion;
    }

    private DLCVersion(Builder builder) {
        fullVersion = builder.fullVersion;
        shortVersion = builder.shortVersion;
        date = builder.date;
        majorVersion = builder.major;
        minorVersion = builder.minor;
        maintenanceVersion = builder.maintenance;
        patchVersion = builder.patch;
        arch = builder.arch;
        rCodeVersion = builder.rCodeVersion;
    }

    /**
     * Only use for testing purposes
     */
    public static DLCVersion getObject(String versionStr) {
        Builder builder = new Builder();
        readVersionFile(builder, versionStr);

        return new DLCVersion(builder);
    }

    public static DLCVersion getObject(File dir) {
        Builder builder = new Builder();

        try {
            // Read version file
            readVersionFile(builder, extractVersionInfo(dir));
            File prostart = new File(dir, "tty/prostart.r");
            if (prostart.exists()) {
                readArch(builder, new File(dir, "tty/prostart.r"));
            }
        } catch (IOException caught) {
            return UNKNOWN_VERSION;
        }

        return new DLCVersion(builder);
    }

    protected static void readVersionFile(Builder builder, String str) {
        Matcher m = Pattern.compile(MAIN_PATTERN).matcher(str);
        if (m.matches()) {
            builder.fullVersion = m.group(0);
            builder.shortVersion = m.group(1);
            builder.date = m.group(3);
            builder.major = Integer.parseInt(m.group(2));
            if (builder.major >= 11)
                extractNewVersion(builder, m.group(1));
            else
                extractOldVersion(builder, m.group(1));
        } else {
            throw new IllegalArgumentException("Invalid $DLC/version file : " + str);
        }
    }

    private static void readArch(Builder builder, File prostart) throws IOException {
        try {
            RCodeInfo rci = new RCodeInfo(new FileInputStream(prostart));
            builder.rCodeVersion = rci.getVersion();
            builder.arch = rci.is64bits();
        } catch (InvalidRCodeException caught) {
            throw new IOException(caught);
        }
    }

    private static void extractNewVersion(Builder builder, String str) {
        Matcher m = Pattern.compile(V11_PATTERN).matcher(str);
        if (m.matches()) {
            builder.minor = Integer.parseInt((m.group(1) == null ? "0" : m.group(1)));
            builder.maintenance = (m.group(2) == null ? "0" : m.group(2));
            builder.patch = (m.group(3) == null ? "" : m.group(3));
        } else {
            throw new IllegalArgumentException("Invalid $DLC/version file : " + str);
        }
    }

    private static void extractOldVersion(Builder builder, String str) {
        Matcher m = Pattern.compile(OLD_PATTERN).matcher(str);
        if (m.matches()) {
            builder.minor = Integer.parseInt(m.group(1));
            builder.maintenance = m.group(2);
            builder.patch = (m.group(3) == null ? "" : m.group(3));
        } else {
            throw new IllegalArgumentException("Invalid $DLC/version file : " + str);
        }
    }

    private static String extractVersionInfo(File dir) throws IOException {
        File version = new File(dir, "version");

        try (BufferedReader reader = new BufferedReader(new FileReader(version))) {
            return reader.readLine();
        }
    }

    public String getFullVersion() {
        return fullVersion;
    }

    public String getShortVersion() {
        return shortVersion;
    }

    public int getMajorVersion() {
        return majorVersion;
    }

    public int getMinorVersion() {
        return minorVersion;
    }

    public String getMaintenanceVersion() {
        return maintenanceVersion;
    }

    public String getPatchVersion() {
        return patchVersion;
    }

    public String getDate() {
        return date;
    }

    /**
     * @return "Bitness" of rcode, valid until v10.x
     */
    public boolean is64bits() {
        return arch;
    }

    public long getrCodeVersion() {
        return rCodeVersion;
    }

    @Override
    public String toString() {
        if (majorVersion >= 11) {
            return majorVersion + "." + minorVersion + "." + maintenanceVersion + "."
                    + patchVersion + (arch ? " 64 bits" : "");
        } else {
            return majorVersion + "." + minorVersion + maintenanceVersion + patchVersion
                    + (arch ? " 64 bits" : "");
        }
    }

    public static class Builder {
        long rCodeVersion;
        int major;
        int minor;
        String fullVersion;
        String shortVersion;
        String maintenance;
        String patch;
        String date;
        boolean arch;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == this) {
            return true;
        } else if (obj == null) {
            return false;
        } else if (this.getClass() == obj.getClass()) {
            DLCVersion other = (DLCVersion) obj;
            return (majorVersion == other.majorVersion) && (minorVersion == other.minorVersion)
                    && (maintenanceVersion.equals(other.maintenanceVersion));
        } else
            return false;
    }

    @Override
    public int hashCode() {
        return (majorVersion + "." + minorVersion + "." + maintenanceVersion).hashCode();
    }

    /**
     * Compares only major, minor and maintenance
     */
    @Override
    public int compareTo(DLCVersion other) {
        if ((majorVersion - other.majorVersion) != 0)
            return majorVersion - other.majorVersion;
        if ((minorVersion - other.minorVersion) != 0)
            return minorVersion - other.minorVersion;
        try {
            // First, try to compare numeric values ; if not applicable, try string comparison
            int maint = Integer.parseInt(maintenanceVersion);
            int otherMaint = Integer.parseInt(other.maintenanceVersion);
            return maint - otherMaint;
        } catch (NumberFormatException uncaught) {
            return maintenanceVersion.compareTo(other.maintenanceVersion);
        }
    }
}
