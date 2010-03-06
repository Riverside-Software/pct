package com.phenix.pct;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.phenix.pct.RCodeInfo.InvalidRCodeException;

public class DLCVersion {
    private static final String MAIN_PATTERN = "(?:[a-zA-Z]+\\s+)+((\\d+)(?:[A-Z0-9\\u002E])*)\\s+as of(.*)";
    private static final String V11_PATTERN = "\\d+(?:\\u002E(\\d+)(?:\\u002E(\\d+)(?:\\u002E(\\d+))?)?)?[a-zA-Z]*";
    private static final String OLD_PATTERN = "\\d+\\u002E(\\d+)([A-Z])([A-Z0-9]*)";

    private final int majorVersion, minorVersion;
    private final String fullVersion, maintenanceVersion, patchVersion;
    private final boolean arch;

    private DLCVersion(Builder builder) {
        fullVersion = builder.fullVersion;
        majorVersion = builder.major;
        minorVersion = builder.minor;
        maintenanceVersion = builder.maintenance;
        patchVersion = builder.patch;
        arch = builder.arch;
    }

    public static DLCVersion getObject(File dir) throws IOException, InvalidRCodeException {
        Builder builder = new Builder();

        // Read version file
        readVersionFile(builder, extractVersionInfo(dir));
        readArch(builder, new File(dir, "tty/prostart.r"));

        return new DLCVersion(builder);
    }

    protected static void readVersionFile(Builder builder, String str) {
        Matcher m = Pattern.compile(MAIN_PATTERN).matcher(str);
        if (m.matches()) {
            builder.fullVersion = m.group(0);
            builder.major = Integer.parseInt(m.group(2));
            if (builder.major >= 11)
                extractNewVersion(builder, m.group(1));
            else
                extractOldVersion(builder, m.group(1));
        } else {
            throw new IllegalArgumentException("Invalid $DLC/version file : " + str);
        }
    }

    protected static void readArch(Builder builder, File prostart) throws IOException,
            InvalidRCodeException {
        RCodeInfo rci = new RCodeInfo(prostart);
        builder.rCodeVersion = rci.getVersion();
        builder.arch = ((builder.rCodeVersion & 0x4000) != 0);
    }

    private static void extractNewVersion(Builder builder, String str) {
        Matcher m = Pattern.compile(V11_PATTERN).matcher(str);
        if (m.matches()) {
            builder.minor = Integer.parseInt((m.group(1) == null ? "0" : m.group(1)));
            builder.maintenance = (m.group(2) == null ? "0" : m.group(2));
            builder.patch = (m.group(3) == null ? "0" : m.group(3));
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

        BufferedReader reader = null;
        try {
            reader = new BufferedReader(new FileReader(version));
            return reader.readLine();
        } finally {
            try {
                reader.close();
            } catch (IOException ioe) {
            }
        }

    }

    public String getFullVersion() {
        return fullVersion;
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

    public boolean is64bits() {
        return arch;
    }

    public String toString() {
        if (majorVersion >= 11) {
            return majorVersion + "." + minorVersion + "." + maintenanceVersion + "."
                    + patchVersion + (arch ? " 64 bits" : "");
        } else {
            return majorVersion + "." + minorVersion + maintenanceVersion + patchVersion
                    + (arch ? " 64 bits" : "");
        }
    }
    protected static class Builder {
        long rCodeVersion;
        int major, minor;
        String fullVersion, maintenance, patch;
        boolean arch;
    }
}
