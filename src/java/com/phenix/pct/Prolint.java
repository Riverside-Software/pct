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

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.types.FileSet;
import org.apache.tools.ant.types.Path;

/**
 * Lint source files
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class Prolint extends PCTRun {
    private List filesets = new ArrayList();
    private File destDir = null;
    private List handlers = new ArrayList();
    private List excludeRules = new ArrayList();
    
    // Internal use
    private int fsListId = -1;
    private File fsList = null;
    private int paramsId = -1;
    private File params = null;
    private int lintTmpDirId = -1;
    private File lintTmpDir = null;
    private int parseTmpDirId = -1;
    private File parseTmpDir = null;

    public Prolint(){
        super();
        
        fsListId = PCT.nextRandomInt();
        paramsId = PCT.nextRandomInt();
        lintTmpDirId = PCT.nextRandomInt();
        parseTmpDirId = PCT.nextRandomInt();
        
        fsList = new File(System.getProperty("java.io.tmpdir"), "pct_filesets" + fsListId + ".txt"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        params = new File(System.getProperty("java.io.tmpdir"), "pct_params" + paramsId + ".txt"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        lintTmpDir = new File(System.getProperty("java.io.tmpdir"), "prolint" + lintTmpDirId); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        lintTmpDir.mkdir();
        parseTmpDir = new File(System.getProperty("java.io.tmpdir"), "proparse" + parseTmpDirId); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
        parseTmpDir.mkdir();
        
        addPropath(new Path(getProject(), lintTmpDir.getAbsolutePath()));
        super.setGraphicalMode(true);
        super.setAssemblies(parseTmpDir);
    }

    public void setGraphicalMode(boolean graphMode) {
        throw new BuildException("graphicalMode attribute can't be set in Prolint task");
    }

    public void setAssemblies(File assemblies) {
        throw new BuildException("assemblies attribute can't be set in Prolint task");
    }
    
    /**
     * Location to store the .r files
     * 
     * @param destDir Destination directory
     */
    public void setDestDir(File destDir) {
        this.destDir = destDir;
    }

    /**
     * Adds a set of files to archive.
     * 
     * @param set FileSet
     */
    public void addFileset(FileSet set) {
        filesets.add(set);
    }
    
    public void addLintHandler(Handler handler) {
        handlers.add(handler);
    }
    
    public void addExcludeRule(ExcludeRule rule) {
        excludeRules.add(rule);
    }
    
    /**
     * 
     * @throws BuildException
     */
    private void writeFileList() throws BuildException {
        try {
            BufferedWriter bw = new BufferedWriter(new FileWriter(fsList));

            for (Iterator e = filesets.iterator(); e.hasNext();) {
                // Parse filesets
                FileSet fs = (FileSet) e.next();
                bw.write("FILESET=" + fs.getDir(this.getProject()).getAbsolutePath()); //$NON-NLS-1$
                bw.newLine();

                // And get files from fileset
                String[] dsfiles = fs.getDirectoryScanner(this.getProject()).getIncludedFiles();

                for (int i = 0; i < dsfiles.length; i++) {
                    bw.write(dsfiles[i]);
                    bw.newLine();
                }
            }

            bw.close();
        } catch (IOException ioe) {
            throw new BuildException(Messages.getString("PCTCompile.2"), ioe); //$NON-NLS-1$
        }
    }
    
    /**
     * 
     * @throws BuildException
     */
    private void writeParams() throws BuildException {
        try {
            BufferedWriter bw = new BufferedWriter(new FileWriter(params));
            bw.write("FILESETS=" + fsList.getAbsolutePath()); //$NON-NLS-1$
            bw.newLine();
            bw.close();
        } catch (IOException ioe) {
            throw new BuildException(Messages.getString("PCTCompile.3"), ioe); //$NON-NLS-1$
        }
    }
    
    private void writeCustomLint() throws BuildException {
        File prolint = new File(lintTmpDir, "prolint");
        File filters = new File(prolint, "filters");
        File rules = new File(prolint, "rules");
        File oHandler = new File(prolint, "outputhandlers");
        File custom = new File(prolint, "custom");
        File settings = new File(prolint, "settings");
        File profile = new File(settings, "pct");
        filters.mkdirs();
        rules.mkdirs();
        oHandler.mkdirs();
        custom.mkdirs();
        profile.mkdirs();
        try {
            BufferedWriter bw = new BufferedWriter(new FileWriter(new File(custom, "prolint.properties.p")));
            bw.write("RUN SetProlintProperty ('outputhandlers.resultwindow', '').");
            bw.newLine();
            bw.write("RUN SetProlintProperty ('outputhandlers.outputdirectory', '" + destDir.getAbsolutePath() + "').");
            bw.newLine();
            bw.close();
            
            BufferedWriter bw2 = new BufferedWriter(new FileWriter(new File(profile, "handlers.d")));
            for (Iterator iter = handlers.iterator(); iter.hasNext(); ) {
                Handler h = (Handler) iter.next();
                bw2.write("\"" + h.getName() + "\"");
                bw2.newLine();
            }
            bw2.close();

            BufferedWriter bw3 = new BufferedWriter(new FileWriter(new File(oHandler, "severity.d")));
            for (Iterator iter = excludeRules.iterator(); iter.hasNext(); ) {
                ExcludeRule h = (ExcludeRule) iter.next();
                bw3.write("\"no\" \"" + h.getName() + "\"");
                bw3.newLine();
            }
            bw3.close();

          BufferedWriter bw4 = new BufferedWriter(new FileWriter(new File(profile, "choices.d")));
          bw4.write("\"xml.p\" 10 \"*\" \"XML export\"");
          bw4.newLine();
          bw4.close();

          copyStreamFromJar("/eu/rssw/pct/prolint/rules.d", new File(rules, "rules.d"));
          copyStreamFromJar("/eu/rssw/pct/prolint/IKVM.OpenJDK.Core.dll", new File(parseTmpDir, "IKVM.OpenJDK.Core.dll"));
          copyStreamFromJar("/eu/rssw/pct/prolint/IKVM.Runtime.dll", new File(parseTmpDir, "IKVM.Runtime.dll"));
          copyStreamFromJar("/eu/rssw/pct/prolint/proparse.net.dll", new File(parseTmpDir, "proparse.net.dll"));
          copyStreamFromJar("/eu/rssw/pct/prolint/assemblies.xml", new File(parseTmpDir, "assemblies.xml"));
          
        } catch (IOException caught) {
            throw new BuildException(Messages.getString("Prolint.1"), caught); //$NON-NLS-1$
        }
    }

    public void execute() throws BuildException {
        checkDlcHome();

        if (destDir == null) {
            throw new BuildException("destDir not set");
        }
        
        try {
            writeFileList();
            writeParams();
            writeCustomLint();
            setProcedure("pct/prolint.p");
            setParameter(params.getAbsolutePath());
            super.execute();
            cleanup();
        } catch (BuildException be) {
            cleanup();
            throw be;
        }
    }

    protected void cleanup() {
        super.cleanup();

        if (!getDebugPCT()) {
            if (fsList.exists() && !fsList.delete()) {
                log(
                        MessageFormat
                                .format(
                                        Messages.getString("PCTCompile.42"), new Object[]{fsList.getAbsolutePath()}), Project.MSG_VERBOSE); //$NON-NLS-1$
            }

            if (params.exists() && !params.delete()) {
                log(
                        MessageFormat
                                .format(
                                        Messages.getString("PCTCompile.42"), new Object[]{params.getAbsolutePath()}), Project.MSG_VERBOSE); //$NON-NLS-1$
            }
            if (lintTmpDir.exists()) {
                try {
                    PCT.deleteDirectory(lintTmpDir);
                } catch (IOException caught) {
                log(
                        MessageFormat
                                .format(
                                        Messages.getString("PCTCompile.42"), new Object[]{lintTmpDir.getAbsolutePath()}), Project.MSG_VERBOSE); //$NON-NLS-1$
                }
            }
            if (parseTmpDir.exists()) {
                try {
                    PCT.deleteDirectory(parseTmpDir);
                } catch (IOException caught) {
                log(
                        MessageFormat
                                .format(
                                        Messages.getString("PCTCompile.42"), new Object[]{parseTmpDir.getAbsolutePath()}), Project.MSG_VERBOSE); //$NON-NLS-1$
                }
            }
        }
    }
}
