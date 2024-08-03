/**
 * Copyright 2005-2024 Riverside Software
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
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.lang.reflect.Field;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.text.MessageFormat;
import java.util.Collection;
import java.util.List;
import java.util.Properties;
import java.util.Random;
import java.util.concurrent.TimeUnit;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.BuildListener;
import org.apache.tools.ant.DefaultLogger;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.types.Environment;
import org.apache.tools.ant.types.Environment.Variable;
import org.apache.tools.ant.types.FileSet;
import org.apache.tools.ant.types.Path;
import org.apache.tools.ant.types.PatternSet;

/**
 * Base class for creating tasks involving Progress. It does basic work on guessing where various
 * bin/java/etc are located.
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 * @version $Revision$
 */
public abstract class PCT extends Task {
    public static final String TMPDIR = "java.io.tmpdir";

    // Bug #1114731 : only a few files from $DLC/java/ext are used for proxygen's classpath
    // Files found in $DLC/properties/JavaTool.properties
    private static final String JAVA_CP = "progress.zip,progress.jar,messages.jar,proxygen.zip,proxygen.jar,ext/wsdl4j.jar,ext/wsdl4j-*.jar,prowin.jar,ext/xercesImpl.jar,ext/xmlParserAPIs.jar,ext/soap.jar,ext/soap-*.jar"; //$NON-NLS-1$
    private static final Random RANDOM = new Random();
    private static final BuildListener ANALYTICS = new AnalyticsBuildListener();

    private File dlcHome = null;
    private File dlcBin = null;
    private File dlcJava = null;
    private File pdsHome = null;
    private File jdk = null;
    private File jre = null;

    // Internal use
    private ProgressProcedures pp = null;
    private DLCVersion version = null;
    private Environment env = new Environment();

    /**
     * Progress installation directory
     * 
     * @param dlcHome File
     */
    public final void setDlcHome(File dlcHome) {
        if (!dlcHome.exists()) {
            throw new BuildException(MessageFormat.format(
                    Messages.getString("PCT.1"), "dlcHome", dlcHome.getAbsolutePath())); //$NON-NLS-1$ //$NON-NLS-2$
        }

        this.dlcHome = dlcHome;

        // Tries to guess bin directory
        if (this.dlcBin == null) {
            this.setDlcBin(new File(dlcHome, "bin")); //$NON-NLS-1$
        }

        // Tries to guess java directory
        if (this.dlcJava == null) {
            try {
                this.setDlcJava(new File(dlcHome, "java")); //$NON-NLS-1$
            } catch (BuildException uncaught) {
                // $DLC/java is optional
            }
        }

        version = DLCVersion.getObject(dlcHome);
        log("OpenEdge version found : " + version.getFullVersion(), Project.MSG_VERBOSE);
        if (version == DLCVersion.UNKNOWN_VERSION) {
            throw new BuildException("Unable to read DLC version file in '" + dlcHome.toString() + "'");
        }

        if (version.compareTo(new DLCVersion(13, 0, "0")) >= 0)
            this.pp = new ProgressV13();
        else if (version.compareTo(new DLCVersion(12, 8, "0")) >= 0)
            this.pp = new ProgressV128();
        else if (version.compareTo(new DLCVersion(12, 4, "0")) >= 0)
            this.pp = new ProgressV124();
        else if (version.compareTo(new DLCVersion(12, 1, "0")) >= 0)
            this.pp = new ProgressV121();
        else if (version.compareTo(new DLCVersion(12, 0, "0")) >= 0)
            this.pp = new ProgressV12();
        else if (version.compareTo(new DLCVersion(11, 7, "0")) >= 0)
            this.pp = new ProgressV117();
        else if (version.compareTo(new DLCVersion(11, 4, "0")) >= 0)
            this.pp = new ProgressV114();
        else if (version.compareTo(new DLCVersion(11, 3, "0")) >= 0)
            this.pp = new ProgressV113();
        else if (version.compareTo(new DLCVersion(11, 0, "0")) >= 0)
            this.pp = new ProgressV11();
        else if (version.compareTo(new DLCVersion(10, 2, "B")) >= 0)
            this.pp = new ProgressV102B();
        else if (version.compareTo(new DLCVersion(10, 0, "A")) >= 0)
            this.pp = new ProgressV10();
        else
            throw new BuildException("Invalid Progress version : " + version.toString());
        log("Using object : " + pp.getClass().getName(), Project.MSG_VERBOSE);

        if (pp.externalJDK()) {
            try (InputStream input = new FileInputStream (new File(dlcHome, "properties/java.properties"))) {
                Properties props = new Properties();
                props.load(input);
                String str = props.getProperty("JAVA_HOME");
                if (str == null)
                    log("No JAVA_HOME property", Project.MSG_ERR);
                else {
                    jdk  = new File(str);
                    jre = new File(jdk, "jre");
                    if (!jdk.exists())
                        log("JAVA_HOME '" + jdk.getAbsolutePath() + "' directory doesn't exist")
                        ;
                }
            } catch (IOException uncaught) {
                log("Unable to open file $DLC/properties/java.properties", Project.MSG_ERR);
            }
        } else {
            jdk = new File(dlcHome, "jdk");
            jre = new File(dlcHome, "jre");
        }
        
    }

    public void setPdsHome(File pdsHome) {
        if (!pdsHome.exists()) {
            throw new BuildException(MessageFormat.format(
                    Messages.getString("PCT.1"), "pdsHome", pdsHome.getAbsolutePath())); //$NON-NLS-1$ //$NON-NLS-2$
        }

        this.pdsHome = pdsHome;
    }

    /**
     * Progress binary directory
     * 
     * @param dlcBin File
     * @since 0.3
     */
    public final void setDlcBin(File dlcBin) {
        if (!dlcBin.exists()) {
            throw new BuildException(MessageFormat.format(Messages.getString("PCT.1"), "dlcBin", //$NON-NLS-1$ //$NON-NLS-2$
                    dlcBin.getAbsolutePath()));
        }

        this.dlcBin = dlcBin;
    }

    /**
     * Progress java directory
     * 
     * @param dlcJava File
     * @since 0.3
     */
    public final void setDlcJava(File dlcJava) {
        if (!dlcJava.exists()) {
            throw new BuildException(MessageFormat.format(Messages.getString("PCT.1"), "dlcJava", //$NON-NLS-1$ //$NON-NLS-2$
                    dlcJava.getAbsolutePath()));
        }

        this.dlcJava = dlcJava;
    }

    /**
     * Add an environment variable to the launched process.
     * 
     * @param var new environment variable.
     */
    public final void addEnv(Environment.Variable var) {
        env.addVariable(var);
    }

    protected final Environment getEnvironment() {
        return env;
    }

    /**
     * Convenience method to retrieve a typed collection
     */
    protected final Collection<Variable> getEnvironmentVariables() {
        return env.getVariablesVector();
    }

    /**
     * Returns Progress installation directory
     * 
     * @return File
     */
    protected final File getDlcHome() {
        return this.dlcHome;
    }

    protected final File getJRE() {
        return jre;
    }

    protected final File getJDK() {
        return jdk;
    }

    protected final File getJDKBin() {
        return new File(jdk, "bin");
    }

    protected final File getPdsHome() {
        if (pdsHome == null)
            return new File(dlcHome, "oeide");

        return pdsHome;
    }

    /**
     * Returns path to java executable from JDK
     */
    protected final File getJVM() {
        File f1 = new File(getJDKBin(), "java");
        File f2 = new File(getJDKBin(), "java.exe");

        return (f1.exists() ? f1 : f2);
    }

    /**
     * Returns Progress executables directory
     * 
     * @return File
     * @since 0.3b
     */
    protected final File getDlcBin() {
        return this.dlcBin;
    }

    /**
     * Returns prolib[.exe] executable path
     */
    protected final File getProlibExecutablePath() {
        return getExecPath("prolib");
    }

    /**
     * Returns a Progress executable path
     * 
     * @param exec String
     * @return File
     */
    protected final File getExecPath(String exec) {
        if (dlcBin == null) {
            return new File(exec);
        }

        File f1 = new File(dlcBin, exec);
        File f2 = new File(dlcBin, exec + ".exe");
        File f3 = new File(dlcBin, exec + ".bat");

        return (f1.exists() ? f1 : (f2.exists() ? f2 : (f3.exists() ? f3 : f1)));
    }

    protected final File getAVMExecutable(boolean graphicalMode) {
        if (!graphicalMode) {
            return getExecPath("_progres");
        } else {
            // Starting from 11.3, 64 bits executable is available, and called prowin.exe
            // Easiest way is to check for prowin.exe, and return this File if available
            // Otherwise, fall back to prowin32
            if (version.compareTo(new DLCVersion(11, 3, "0")) >= 0) {
                File prowin = getExecPath("prowin");
                File prowin32 = getExecPath("prowin32");
                return (prowin.exists() ? prowin : prowin32);
            } else {
                return getExecPath("prowin32");
            }
        }
    }

    /**
     * Returns a fileset containing every JAR/ZIP files needed for proxygen task
     * 
     * @since 0.11
     * @param p Project
     * @return FileSet
     */
    protected FileSet getJavaFileset(Project p) {
        FileSet fs = new FileSet();
        fs.setProject(p);
        fs.setDir(this.dlcJava);
        fs.setIncludes(JAVA_CP);
        return fs;
    }

    protected Path getRestGenClasspath(Project project) {
        Path path = new Path(project);

        FileSet fs1 = new FileSet();
        fs1.setDir(dlcJava);
        fs1.setIncludes("progress.jar");
        fs1.setIncludes("1padapters-idl.jar");
        fs1.setIncludes("1padapters-util.jar");

        FileSet fs2 = new FileSet();
        fs2.setDir(new File(dlcJava, "ext"));
        PatternSet ps2 = fs2.createPatternSet();
        ps2.createInclude().setName("jettison-*.jar");
        ps2.createInclude().setName("commons-logging-*.jar");
        ps2.createInclude().setName("xmlschema-core-*.jar");
        ps2.createInclude().setName("xercesImpl-*.jar");

        FileSet fs3 = new FileSet();
        fs3.setDir(new File(dlcJava, "ant-libs"));
        fs3.setIncludes("ablwebapp.jar");
        fs3.setIncludes("ablwebapp-dependencies.jar");
        fs3.setIncludes("codemodel-dependencies.jar");
        fs3.setIncludes("ast.jar");
        fs3.setIncludes("ast-dependencies.jar");
        fs3.setIncludes("velocity-1.7.jar");
        fs3.setIncludes("velocity-1.7-dep.jar");
        fs3.setIncludes("1padapters-restExpose.jar");

        path.addFileset(fs1);
        path.addFileset(fs2);
        path.addFileset(fs3);

        return path;
    }

    /**
     * Returns an instance of ProgressProcedure
     * 
     * @since 0.12
     */
    protected ProgressProcedures getProgressProcedures() {
        checkDlcHome();
        return this.pp;
    }

    protected void checkDlcHome() {
        if (dlcHome == null) {
            String f = getProject().getProperty(DlcHome.GLOBAL_DLCHOME);
            if (f != null) {
                setDlcHome(new File(f));
            }
        }

        if (dlcHome == null) {
            // dlcHome attribute is not defined, try to use DLC variable (-DDLC=...)
            String str = System.getProperty("DLC"); //$NON-NLS-1$
            if (str != null) {
                log(MessageFormat.format(Messages.getString("PCT.4"), str));
                setDlcHome(new File(str));
            }
        }
        if (dlcHome == null) {
            // dlcHome still not defined, try to use DLC environment variable
            String str = System.getenv("DLC"); //$NON-NLS-1$
            if (str != null) {
                log(MessageFormat.format(Messages.getString("PCT.5"), str));
                setDlcHome(new File(str));
            }
        }
        if (dlcHome == null) {
            // Fail...
            throw new BuildException(Messages.getString("PCT.3")); //$NON-NLS-1$
        }

        if ((getProject() != null) && (System.getProperty("TESTLIBS") == null)) {
            getProject().addBuildListener(ANALYTICS);
        }
    }

    protected boolean isSourceCodeUsed() {
        String src = getProject().getProperty("PCT-SRC");
        if ((src != null) && Boolean.parseBoolean(src)) {
            return true;
        }

        InputStream is = this.getClass().getResourceAsStream(
                "/pct" + version.getMajorVersion() + (version.is64bits() ? "-64" : "") + ".pl");
        return (is == null);
    }

    /**
     * Extracts pct.pl from PCT.jar into a file, and returns true if the operation was OK
     * Automatically extract v9 or v10 PL
     * 
     * @param f File or directory (must not be present)
     * @return Boolean
     * @since PCT 0.10
     */
    protected boolean extractPL(File f) throws IOException {
        if (isSourceCodeUsed())
            return extractZip(f);

        String plFile = "/pct" + version.getMajorVersion() + (version.is64bits() ? "-64" : "") + ".pl";
        try (InputStream is = getClass().getResourceAsStream(plFile);
                OutputStream os = new FileOutputStream(f)) {
            byte[] b = new byte[8192];
            int k = 0;
            while ((k = is.read(b)) != -1) {
                os.write(b, 0, k);
            }
        }

        return true;
    }

    protected boolean extractNetCorePL(File f) throws IOException {
        String plFile = "/pct" + version.getMajorVersion() + "-netcore.pl";
        try (InputStream is = getClass().getResourceAsStream(plFile);
                OutputStream os = new FileOutputStream(f)) {
            byte[] b = new byte[8192];
            int k = 0;
            while ((k = is.read(b)) != -1) {
                os.write(b, 0, k);
            }
        }

        return true;
    }

    /**
     * Extracts pct-src.zip from PCT.jar into a directory, and returns true if the operation was OK.
     * 
     * @param dir Target directory
     * @return Boolean
     * @throws IOException
     * @since PCT 0.17
     */
    private boolean extractZip(File dir) throws IOException {
        log("Working with PCT source code, either because you asked for it or because the compiled version is missing in JAR file");
        InputStream is = this.getClass().getResourceAsStream("/pct-src.zip");
        if (is == null)
            return false;

        dir.mkdir();
        ZipInputStream zip = new ZipInputStream(is);
        ZipEntry ze = null;
        while ((ze = zip.getNextEntry()) != null) {
            if (!ze.isDirectory()) {
                File tmp = new File(dir, ze.getName());
                tmp.getParentFile().mkdirs();
                try (FileOutputStream fout = new FileOutputStream(tmp)) {
                    for (int c = zip.read(); c != -1; c = zip.read()) {
                        fout.write(c);
                    }
                    zip.closeEntry();
                }
            }
        }
        zip.close();

        return true;
    }

    /**
     * Returns major version number
     * 
     * @return 10.0B02 returns 10
     */
    protected int getDLCMajorVersion() {
        return version.getMajorVersion();
    }

    /**
     * Returns minor version number
     * 
     * @return 10.0B02 returns 0
     */
    protected int getDLCMinorVersion() {
        return version.getMinorVersion();
    }

    /**
     * Returns maintenance version
     * 
     * @return 10.0B02 returns B
     * @since PCT 0.17
     */
    protected String getDLCMaintenanceVersion() {
        return version.getMaintenanceVersion();
    }

    /**
     * Returns patch level string
     * 
     * @return 10.0B02 returns 02
     */
    protected String getDLCPatchLevel() {
        return version.getPatchVersion();
    }

    /**
     * Returns full version string
     * 
     * @return 10.0B02 as of Dec 12 1998
     */
    protected String getFullVersion() {
        return version.getFullVersion();
    }

    /**
     * Returns short version
     * 
     * @return 10.0B02 for example
     */
    protected String getShortVersion() {
        return version.getShortVersion();
    }

    /**
     * @return "Bitness" of rcode, valid until v10.x
     */
    protected boolean is64bits() {
        return version.is64bits();
    }

    /**
     * Returns r-code version
     * 
     * @return Long (1005 for 10.1B 32 bits for example)
     */
    protected long getRCodeVersion() {
        return version.getrCodeVersion();
    }

    protected DLCVersion getVersion() {
        return version;
    }

    public int getAntLoggerLevel() {
        try {
            List<BuildListener> listeners = getProject().getBuildListeners();
            for (BuildListener listener : listeners) {
                if (listener instanceof DefaultLogger) {
                    DefaultLogger logger = (DefaultLogger) listener;
                    Field field = DefaultLogger.class.getDeclaredField("msgOutputLevel");
                    field.setAccessible(true);
                    return (Integer) field.get(logger);
                }
            }
            return 2;
        } catch (Exception e) {
            // if unable to determine level - just return default value
            return 2;
        }
    }

    /**
     * Returns charset to be used when writing files in Java to be read by Progress session (thus
     * according to cpstream, parameter files, ...) and dealing with OE encodings (such as undefined
     * or 1252)
     */
    protected Charset getCharset(String zz) {
        if ("1250".equals(zz)) // Central Europe
            zz = "windows-1250";
        else if ("1251".equals(zz)) // Cyrillic
            zz = "windows-1251";
        else if ("1252".equals(zz)) // Western Europe
            zz = "windows-1252";
        else if ("1253".equals(zz)) // Greek
            zz = "windows-1253";
        else if ("1254".equals(zz)) // Turkish
            zz = "windows-1254";
        else if ("1255".equals(zz)) // Hebrew
            zz = "windows-1255";
        else if ("1256".equals(zz)) // Arabic
            zz = "windows-1256";
        else if ("1257".equals(zz)) // Baltic
            zz = "windows-1257";
        else if ("1258".equals(zz)) // Vietnamese
            zz = "windows-1258";
        else if ("big-5".equalsIgnoreCase(zz))
            zz = "Big5";
        try {
            if (zz == null) {
                log(Messages.getString("PCTCompile.47"), Project.MSG_VERBOSE); //$NON-NLS-1$
                return Charset.defaultCharset();
            }
            return Charset.forName(zz);
        } catch (IllegalArgumentException caught) {
            log(MessageFormat.format(Messages.getString("PCTCompile.46"), zz), Project.MSG_INFO); //$NON-NLS-1$
            return Charset.defaultCharset();
        }
    }

    /**
     * Escapes a string so it does not accidentally contain Progress escape characters
     * 
     * @param str the input string
     * @return the escaped string
     */
    protected static String escapeString(String str) {
        if (str == null) {
            return null;
        }

        int slen = str.length();
        StringBuilder res = new StringBuilder();

        for (int i = 0; i < slen; i++) {
            char c = str.charAt(i);

            switch (c) {
                case '\u007E' : // TILDE converted to TILDE TILDE
                    res.append("\u007E\u007E"); //$NON-NLS-1$
                    break;

                case '\u0022' : // QUOTATION MARK converted to TILDE APOSTROPHE
                case '\''     : // APOSTROPHE converted to TILDE APOSTROPHE
                    res.append("\u007E\u0027"); //$NON-NLS-1$
                    break;

                default :
                    res.append(c);
            }
        }

        return res.toString();
    }

    protected static final int nextRandomInt() {
        return RANDOM.nextInt() & 0xfffffff;
    }

    // ----------------------------------
    // Extracted from commons-io

    /**
     * Deletes a directory recursively.
     * 
     * @param directory directory to delete
     */
    protected void deleteDirectory(File directory) {
        if (directory == null)
            return;
        if (!directory.exists()) {
            return;
        }

        for (File f : directory.listFiles()) {
            deleteFile(f);
        }
        try {
            Files.deleteIfExists(directory.toPath());
        } catch (IOException caught) {
            log(MessageFormat.format(Messages.getString("PCTRun.5"), directory.getAbsolutePath()),
                    Project.MSG_VERBOSE);

        }
    }

    protected void deleteFile(File file) {
        if (file == null)
            return;
        if (file.isDirectory())
            deleteDirectory(file);
        try {
            Files.deleteIfExists(file.toPath());
        } catch (IOException caught) {
            log(MessageFormat.format(Messages.getString("PCTRun.5"), file.getAbsolutePath()),
                    Project.MSG_VERBOSE);
        }
    }

    protected String getPassphraseFromCmdLine(String cmdLine) {
        ProcessBuilder pb = new ProcessBuilder() //
                .command(cmdLine.split(" ")) //
                .directory(getProject().getBaseDir()) //
                .redirectOutput(ProcessBuilder.Redirect.PIPE) //
                .redirectError(ProcessBuilder.Redirect.INHERIT);
        try {
            Process process = pb.start();
            process.waitFor(30, TimeUnit.SECONDS);
            BufferedReader stdOut = new BufferedReader(
                    new InputStreamReader(process.getInputStream()));
            return stdOut.readLine();
        } catch (IOException caught) {
            throw new BuildException(caught);
        } catch (InterruptedException caught) {
            Thread.currentThread().interrupt();
            return "";
        }
    }

    protected static void copyStreamFromJar(String streamName, File outFile) throws IOException {
        try (InputStream in = PCT.class.getResourceAsStream(streamName);
                OutputStream out = new FileOutputStream(outFile)) {
            byte[] b = new byte[8192];
            int k = 0;
            while ((k = in.read(b)) != -1) {
                out.write(b, 0, k);
            }
        }
    }

    protected static boolean createDir(File dir) {
        if (dir.exists()) {
            return dir.isDirectory();
        } else {
            return dir.mkdirs();
        }
    }

}
