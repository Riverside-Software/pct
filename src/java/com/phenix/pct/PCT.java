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
import org.apache.tools.ant.Task;

import java.io.File;

/**
 * Base class for creating tasks involving Progress. It does basic work on guessing where various
 * bin/java/etc are located.
 * 
 * @author <a href="mailto:gilles.querret@nerim.net">Gilles QUERRET </a>
 * @version $Revision$
 * @todo dlcHome should get DLC environment variable content at startup and could be overridden with
 *       setDlcHome
 */
public abstract class PCT extends Task {
    private File dlcHome = null;
    private File dlcBin = null;
    private File dlcJava = null;
    private File proxygenJar = null;
    private File progressJar = null;
    private File messagesJar = null;

    /**
     * Progress installation directory
     * 
     * @param dlcHome File
     */
    public final void setDlcHome(File dlcHome) {
        if (!dlcHome.exists()) {
            throw new BuildException("dlcHome attribute : " + dlcHome.toString() + " not found");
        }

        this.dlcHome = dlcHome;

        // Tries to guess bin directory
        if (this.dlcBin == null) {
            try {
                this.setDlcBin(new File(dlcHome, "bin"));
            } catch (BuildException be) {
            }
        }

        // Tries to guess java directory
        if (this.dlcJava == null) {
            try {
                this.setDlcJava(new File(dlcHome, "java"));
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
            throw new BuildException("dlcBin attribute : " + dlcBin.toString() + " not found");
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
            throw new BuildException("dlcJava attribute : " + dlcJava.toString() + " not found");
        }

        this.dlcJava = dlcJava;

        // Tries to guess where proxygen.zip is located
        if (this.proxygenJar == null) {
            try {
                setProxygenJar(new File(dlcJava, "proxygen.zip"));
            } catch (BuildException be) {
            }
        }

        // Tries to guess where progress.[zip|jar] is located
        if (this.progressJar == null) {
            try {
                setProgressJar(new File(dlcJava, "progress.zip"));
            } catch (BuildException be) {
            }

            if (this.progressJar == null) {
                try {
                    setProgressJar(new File(dlcJava, "progress.jar"));
                } catch (BuildException be) {
                }
            }
        }
    }

    /**
     * Proxygen.jar file
     * 
     * @param pxgJar File
     */
    public final void setProxygenJar(File pxgJar) {
        if (!pxgJar.exists()) {
            throw new BuildException("ProxygenJar attribute : " + pxgJar.toString() + " not found");
        }

        this.proxygenJar = pxgJar;
    }

    /**
     * Messages.jar file
     * 
     * @param msgJar File
     * @since 0.7
     */
    public final void setMessagesJar(File msgJar) {
        if (!msgJar.exists()) {
            throw new BuildException("ProxygenJar attribute : " + msgJar.toString() + " not found");
        }

        this.messagesJar = msgJar;

    }

    /**
     * Progress.zip file
     * 
     * @param pscJar File
     */
    public final void setProgressJar(File pscJar) {
        if (!pscJar.exists()) {
            throw new BuildException("ProgressJar attribute : " + pscJar.toString() + " not found");
        }

        this.progressJar = pscJar;
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
     * Returns the needed Jar File or directory to run Proxygen tasks
     * 
     * @return File
     */
    protected final File getProxygenJar() {
        return this.proxygenJar;
    }

    /**
     * Returns the needed Jar File or directory to run Proxygen tasks
     * 
     * @return File
     * @since 0.7
     */
    protected final File getMessagesJar() {
        return this.messagesJar;
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
     * Returns the needed Jar/Zip file or directory to run various Progress/Java tasks
     * 
     * @return File
     */
    protected final File getProgressJar() {
        return this.progressJar;
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

        File f = new File(dlcBin, exec);

        return f;
    }

    /**
     * This method has to be overridden
     */
    public abstract void execute() throws BuildException;
}