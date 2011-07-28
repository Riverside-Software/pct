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
import org.apache.tools.ant.types.Environment;
import org.apache.tools.ant.types.FileSet;

import com.phenix.pct.RCodeInfo.InvalidRCodeException;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.text.MessageFormat;
import java.util.Random;

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
    private final static Random RANDOM = new Random();

    private File dlcHome = null;
    private File dlcBin = null;
    private File dlcJava = null;
    private boolean includedPL = true;
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
            throw new BuildException(
                    MessageFormat
                            .format(
                                    Messages.getString("PCT.1"), new Object[]{"dlcHome", dlcHome.getAbsolutePath()})); //$NON-NLS-1$ //$NON-NLS-2$
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

        try {
            version = DLCVersion.getObject(dlcHome);
        } catch (IOException caught) {
            throw new BuildException(caught);
        } catch (InvalidRCodeException caught) {
            throw new BuildException(caught);
        }

        if (version.compareTo(new DLCVersion(10, 2, "B")) >= 0)
            this.pp = new ProgressV102B();
        else if (version.compareTo(new DLCVersion(10, 0, "A")) >= 0)
            this.pp = new ProgressV10();
        else if (version.compareTo(new DLCVersion(9, 0, "A")) >= 0)
            this.pp = new ProgressV9();
        else if (version.compareTo(new DLCVersion(8, 0, "A")) >= 0)
            this.pp = new ProgressV8();
        else
            throw new BuildException("Invalid Progress version : " + version.toString());
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

    protected void checkDlcHome() {
        if (getDlcHome() == null) {
            // dlcHome attribute is not defined, try to use DLC variable (-DDLC=...)
            String str = System.getProperty("DLC"); //$NON-NLS-1$
            if (str != null) {
                log(MessageFormat.format(Messages.getString("PCT.4"), new Object[]{ str }));
                setDlcHome(new File(str));
            }
        }
        if (getDlcHome() == null) {
            // dlcHome still not defined, try to use DLC environment variable
            String str = System.getenv("DLC"); //$NON-NLS-1$
            if (str != null) {
                log(MessageFormat.format(Messages.getString("PCT.5"), new Object[]{ str }));
                setDlcHome(new File(str));
            }
        }
        if (getDlcHome() == null) {
            // Fail...
            throw new BuildException(Messages.getString("PCT.3")); //$NON-NLS-1$
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
    protected File extractPL() throws IOException {
        int plID = nextRandomInt() & 0xffff;
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
    protected boolean extractPL(File f) throws IOException {
        InputStream is = this.getClass().getResourceAsStream(
                "/pct" + version.getMajorVersion() + (version.is64bits() ? "-64" : "") + ".pl");
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
     * @deprecated Use {@link PCT#getDLCMaintenanceVersion()} instead
     */
    protected String getDLCRevision() {
        return getDLCMaintenanceVersion();
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
        return version.getFullVersion() + " as of " + version.getDate();
    }

    /**
     * Returns reduced version
     * 
     * @return 10.0B02 for example
     */
    protected String getReducedVersion() {
        return version.getFullVersion();
    }

    /**
     * Returns r-code version
     * 
     * @return Long (1005 for 10.1B 32 bits for example)
     */
    protected long getRCodeVersion() {
        return version.getrCodeVersion();
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

    protected final static int nextRandomInt() {
        return RANDOM.nextInt() & 0xffff;
    }
}