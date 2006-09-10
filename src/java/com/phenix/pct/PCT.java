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
import org.apache.tools.ant.types.Path;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.text.MessageFormat;

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
    // Used class to detect a v10 installation
    private final static String V10_DETECTION_CLASS = "com.progress.wsa.open4gl.WsaResponse";

    private File dlcHome = null;
    private File dlcBin = null;
    private File dlcJava = null;
    private boolean includedPL = true;

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
    protected FileSet getJavaFileset(Project p)  {
        FileSet fs = new FileSet();
        fs.setProject(p);
        fs.setDir(this.dlcJava);
        fs.setIncludes(JAVA_CP);

        return fs;
    }

    /**
     * This method has to be overridden
     * 
     * @throws BuildException
     */
    public abstract void execute() throws BuildException;

    /**
     * Returns Progress major version number. I tried using
     * com.progress.common.utils.ProgressVersion but failed with ClassLoader and JNI
     * (ProgressVersion.java makes native calls to ProgressVersion shared library). So I'm using a
     * workaround, trying to load a class which is only available under version 10.
     * 
     * @since PCT 0.10
     */
    private int getProgressVersion() {
        try {
            Path path = new Path(this.getProject());
            path.addFileset(getJavaFileset(this.getProject()));
            ClassLoader cl = this.getProject().createClassLoader(path);

            cl.loadClass(V10_DETECTION_CLASS);
            log(
                    MessageFormat
                            .format(Messages.getString("PCT.2"), new Object[]{new Integer(10)}), Project.MSG_VERBOSE); //$NON-NLS-1$
            return 10;
        } catch (ClassNotFoundException e) {
            log(
                    MessageFormat.format(Messages.getString("PCT.2"), new Object[]{new Integer(9)}), Project.MSG_VERBOSE); //$NON-NLS-1$
            return 9;
        }
    }

    /**
     * Extracts pct.pl from PCT.jar into a temporary file, and returns a handle on the file.
     * Automatically extract v9 or v10 PL
     * 
     * @return Handle on pct.pl (File)
     * @since PCT 0.10
     */
    protected File extractPL() {
        int version = getProgressVersion();
        if (version == -1)
            return null;
        try {
            File f = null;
            InputStream is = this.getClass().getResourceAsStream("/pct" + version + ".pl");
            if (is == null)
                return null;
            f = File.createTempFile("PCT", ".pl");
            OutputStream os = new FileOutputStream(f);
            byte[] b = new byte[2048];
            int k = 0;
            while ((k = is.read(b)) != -1)
                os.write(b, 0, k);
            os.close();
            is.close();
            return f;
        } catch (Exception e) {
            return null;
        }
    }
}