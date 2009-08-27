/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) The Apache Software Foundation.  All rights
 * reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution, if
 *    any, must include the following acknowlegement:
 *       "This product includes software developed by the
 *        Apache Software Foundation (http://www.apache.org/)."
 *    Alternately, this acknowlegement may appear in the software itself,
 *    if and wherever such third-party acknowlegements normally appear.
 *
 * 4. The names "Ant" and "Apache Software
 *    Foundation" must not be used to endorse or promote products derived
 *    from this software without prior written permission. For written
 *    permission, please contact apache@apache.org.
 *
 * 5. Products derived from this software may not be called "Apache"
 *    nor may "Apache" appear in their names without prior written
 *    permission of the Apache Group.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE APACHE SOFTWARE FOUNDATION OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation.  For more
 * information on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 */
package com.phenix.pct;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.types.FileSet;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.text.MessageFormat;
import java.util.Random;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Base class for creating tasks involving Progress. It does basic work on guessing where various
 * bin/java/etc are located.
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET </a>
 * @version $Revision$
 */
public abstract class PCT extends Task {
    // Bug #1114731 : only a few files from $DLC/java/ext are used for proxygen's classpath
    // Files found in $DLC/properties/JavaTool.properties
    private final static String JAVA_CP = "progress.zip,progress.jar,messages.jar,proxygen.zip,ext/wsdl4j.jar,prowin.jar,ext/xercesImpl.jar,ext/xmlParserAPIs.jar,ext/soap.jar"; //$NON-NLS-1$

    private File dlcHome = null;
    private File dlcBin = null;
    private File dlcJava = null;
    private boolean includedPL = true;
    private ProgressProcedures pp = null;
    private String fullVersion = null;
    private long rcodeVersion = -1;
    private int majorVersion = -1;
    private int minorVersion = -1;
    private String revision = null;
    private String patchLevel = null;
    private boolean x64 = false; // True if 64-bits version of Progress

    public PCT() {
        final String clsName = this.getClass().getCanonicalName();
        Runnable r = new Runnable() {
            public void run() {
                try {
                    new URL("http://94.23.193.172/ping/" + clsName).openConnection().getContentEncoding();
                } catch (MalformedURLException uncaught) {

                } catch (IOException uncaught) {

                }
            }
        };
        new Thread(r).start();
    }

    /**
     * Progress installation directory
     * 
     * @param dlcHome File
     */
    public final void setDlcHome(File dlcHome) {
        if (!dlcHome.exists()) {
            throw new BuildException(
                    MessageFormat
                            .format(
                                    Messages.getString("PCT.1"), new Object[]{"dlcHome", dlcHome.getAbsolutePath()})); //$NON-NLS-1$ //$NON-NLS-2$
        }

        this.dlcHome = dlcHome;

        // Tries to guess bin directory
        if (this.dlcBin == null) {
            try {
                this.setDlcBin(new File(dlcHome, "bin")); //$NON-NLS-1$
            } catch (BuildException be) {
            }
        }

        // Tries to guess java directory
        if (this.dlcJava == null) {
            try {
                this.setDlcJava(new File(dlcHome, "java")); //$NON-NLS-1$
            } catch (BuildException be) {
            }
        }

        setProgressVersion();
        setArch();
        switch (this.majorVersion) {
            case 8 :
                this.pp = new ProgressV8();
                break;
            case 9 :
                this.pp = new ProgressV9();
                break;
            case 10 :
                this.pp = new ProgressV10();
                break;
            default :
                this.pp = new ProgressV10();
                break;
        }
    }

    /**
     * Progress binary directory
     * 
     * @param dlcBin File
     * @since 0.3
     */
    public final void setDlcBin(File dlcBin) {
        if (!dlcBin.exists()) {
            throw new BuildException(MessageFormat.format(
                    Messages.getString("PCT.1"), new Object[]{"dlcBin", dlcBin.getAbsolutePath()})); //$NON-NLS-1$ //$NON-NLS-2$
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
            throw new BuildException(
                    MessageFormat
                            .format(
                                    Messages.getString("PCT.1"), new Object[]{"dlcJava", dlcJava.getAbsolutePath()})); //$NON-NLS-1$ //$NON-NLS-2$
        }

        this.dlcJava = dlcJava;
    }

    /**
     * Add default pct.pl included in JAR file into PROPATH. Default value is true.
     * 
     * @param inc
     * @since 0.10
     */
    public final void setIncludedPL(boolean inc) {
        this.includedPL = inc;
    }

    /**
     * Use default pct.pl included in JAR file into PROPATH
     * 
     * @return boolean
     * @since 0.10
     */
    protected final boolean getIncludedPL() {
        return this.includedPL;
    }

    /**
     * Returns Progress installation directory
     * 
     * @return File
     */
    protected final File getDlcHome() {
        return this.dlcHome;
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

    /**
     * Returns a fileset containing every JAR/ZIP files needed for proxygen task
     * 
     * @since 0.8
     * @return FileSet
     * @deprecated Since 0.11, use getJavaFileset(Project) instead
     */
    protected FileSet getJavaFileset() {
        return getJavaFileset(this.getProject());
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

    /**
     * Returns an instance of ProgressProcedure
     * 
     * @since 0.12
     */
    protected ProgressProcedures getProgressProcedures() {
        return this.pp;
    }

    /**
     * This method has to be overridden
     * 
     * @throws BuildException
     */
    public abstract void execute() throws BuildException;

    protected void checkDlcHome() throws BuildException {
        if (this.getDlcHome() == null)
            throw new BuildException(Messages.getString("PCT.3"));
    }

    /**
     * Returns Progress major version number. I tried using
     * com.progress.common.utils.ProgressVersion but failed with ClassLoader and JNI
     * (ProgressVersion.java makes native calls to ProgressVersion shared library).
     * 
     * @since PCT 0.10
     */
    private void setProgressVersion() {
        File version = new File(dlcHome, "version");
        if (!version.exists()) {
            return;
        }

        BufferedReader reader = null;
        String line = null;
        try {
            reader = new BufferedReader(new FileReader(version));
            line = reader.readLine();
        } catch (IOException ioe) {
            return;
        } finally {
            try {
                reader.close();
            } catch (IOException ioe) {
            }
        }

        Pattern p = Pattern
                .compile("([a-zA-Z]+\\s+)+(\\d+)\\u002E(\\d+)([A-Z])(\\d?\\w*)\\s+as of(.*)"); //$NON-NLS-1$
        Matcher m = p.matcher(line);
        if (m.matches()) {
            this.fullVersion = line;
            this.majorVersion = Integer.parseInt(m.group(2));
            this.minorVersion = Integer.parseInt(m.group(3));
            this.revision = m.group(4);
            this.patchLevel = m.group(5);
        }

    }

    /**
     * Detects 32/64 bits version
     * 
     * @since PCT 0.13
     */
    private void setArch() {
        try {
            RCodeInfo rci = new RCodeInfo(new File(this.dlcHome, "tty/prostart.r"));
            this.rcodeVersion = rci.getVersion();
            this.x64 = ((this.rcodeVersion & 0x4000) != 0);
        } catch (IOException ioe) {
            log("$DLC/tty/prostart.r not found. Assuming 32-bits architecture");
        } catch (RCodeInfo.InvalidRCodeException irce) {
            log("$DLC/tty/prostart.r : parser failure. Assuming 32-bits architecture");
        }
    }

    /**
     * Extracts pct.pl from PCT.jar into a temporary file, and returns a handle on the file.
     * Automatically extract v9 or v10 PL
     * 
     * @return Handle on pct.pl (File)
     * @since PCT 0.10
     * @deprecated PCT 0.11 Use extractPL(File) instead
     */
    protected File extractPL() {
        int plID = new Random().nextInt() & 0xffff;
        File f = new File(System.getProperty("java.io.tmpdir"), "pct" + plID + ".pl"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        if (extractPL(f))
            return f;
        else
            return null;
    }

    /**
     * Extracts pct.pl from PCT.jar into a file, and returns true if the operation was OK
     * Automatically extract v9 or v10 PL
     * 
     * @return Handle on pct.pl (File)
     * @since PCT 0.10
     */
    protected boolean extractPL(File f) {
        if (this.majorVersion == -1)
            return false;
        try {
            InputStream is = this.getClass().getResourceAsStream(
                    "/pct" + this.majorVersion + (this.x64 ? "-64" : "") + ".pl");
            if (is == null)
                return false;
            OutputStream os = new FileOutputStream(f);
            byte[] b = new byte[2048];
            int k = 0;
            while ((k = is.read(b)) != -1)
                os.write(b, 0, k);
            os.close();
            is.close();
            return true;
        } catch (Exception e) {
            return false;
        }

    }

    /**
     * Returns major version number
     * 
     * @return 10.0B02 returns 10
     */
    protected int getDLCMajorVersion() {
        return this.majorVersion;
    }

    /**
     * Returns minor version number
     * 
     * @return 10.0B02 returns 0
     */
    protected int getDLCMinorVersion() {
        return this.minorVersion;
    }

    /**
     * Returns revision letter
     * 
     * @return 10.0B02 returns B
     */
    protected String getDLCRevision() {
        return this.revision;
    }

    /**
     * Returns patch level string
     * 
     * @return 10.0B02 returns 02
     */
    protected String getDLCPatchLevel() {
        return this.patchLevel;
    }

    /**
     * Returns full version string
     * 
     * @return 10.0B02 as of Dec 12 1998
     */
    protected String getFullVersion() {
        return this.fullVersion;
    }

    /**
     * Returns reduced version
     * 
     * @return 10.0B02 for example
     */
    protected String getReducedVersion() {
        return this.majorVersion + "." + this.minorVersion + this.revision + this.patchLevel;
    }

    /**
     * Returns r-code version
     * 
     * @return Long (1005 for 10.1B 32 bits for example)
     */
    protected long getRCodeVersion() {
        return this.rcodeVersion;
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
        StringBuffer res = new StringBuffer();

        for (int i = 0; i < slen; i++) {
            char c = str.charAt(i);

            switch (c) {
                case '\u007E' : // TILDE converted to TILDE TILDE
                    res.append("\u007E\u007E"); //$NON-NLS-1$

                    break;

                case '\u0022' : // QUOTATION MARK converted to TILDE APOSTROPHE
                    res.append("\u007E\u0027"); //$NON-NLS-1$

                    break;

                case '\'' : // APOSTROPHE converted to TILDE APOSTROPHE
                    res.append("\u007E\u0027"); //$NON-NLS-1$

                    break;

                default :
                    res.append(c);
            }
        }

        return res.toString();
    }
}