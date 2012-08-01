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

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Constructor;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.types.FileSet;
import org.apache.tools.ant.types.Path;
import org.prorefactor.core.schema.Schema;
import org.prorefactor.refactor.RefactorException;
import org.prorefactor.refactor.RefactorSession;
import org.prorefactor.treeparser.ParseUnit;

import com.joanju.proparse.Environment;

import eu.rssw.pct.prolint.ILintCallback;
import eu.rssw.pct.prolint.ILintRule;
import eu.rssw.pct.prolint.XMLLintCallback;

/**
 * Lint source files
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class Prolint extends PCT {
    private List filesets = new ArrayList();
    protected Collection dbConnList = null;
    protected Path propath = null;

    private File lintFile;
    private File rulesFile;

    // Internal use
    private int lintSchemaId = -1;
    private File lintSchema = null;

    public Prolint() {
        super();

        lintSchemaId = PCT.nextRandomInt();
        lintSchema = new File(
                System.getProperty("java.io.tmpdir"), "lint_schema" + lintSchemaId + ".txt"); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
    }

    public void setLintFile(File lintFile) {
        this.lintFile = lintFile;
    }

    public void setRulesFile(File rulesFile) {
        this.rulesFile = rulesFile;
    }

    /**
     * Adds a set of files to archive.
     * 
     * @param set FileSet
     */
    public void addFileset(FileSet set) {
        filesets.add(set);
    }

    /**
     * Creates a new Path instance
     * 
     * @return Path
     */
    public Path createPropath() {
        if (this.propath == null) {
            this.propath = new Path(this.getProject());
        }

        return this.propath;
    }

    /**
     * Set the propath to be used when running the procedure
     * 
     * @param propath an Ant Path object containing the propath
     */
    public void addPropath(Path propath) {
        createPropath().append(propath);
    }

    public void addDBConnection(PCTConnection dbConn) {
        if (this.dbConnList == null) {
            this.dbConnList = new ArrayList();
        }

        this.dbConnList.add(dbConn);
    }

    /**
     * Returns a separated list of propath entries, adding standard DLC entries at the end. Standard
     * entries are $DLC/[gui/tty];$DLC;$DLC/bin
     * 
     * @return
     */
    private String getPropath() {
        String[] lst = (propath == null ? new String[]{} : propath.list());
        String str = "";
        for (int k = 0; k < lst.length; k++) {
            str = str + (str.length() == 0 ? "" : ",") + lst[k];
        }
        str = str + (str.length() == 0 ? "" : ",")
                + new File(getDlcHome(), "tty").getAbsolutePath();
        str = str + "," + getDlcHome().getAbsolutePath();
        str = str + "," + getDlcBin().getAbsolutePath();

        return str;
    }

    public void execute() throws BuildException {
        checkDlcHome();

        if (lintFile == null) {
            throw new BuildException("lintFile not set");
        }

        // Generate schema
        if ((dbConnList != null) && (dbConnList.size() > 0)) {
            PCTRun run = new PCTRun();
            run.bindToOwner(this);
            run.setDlcHome(getDlcHome());
            run.setProcedure("pct/schemadump1.p");
            run.setParameter(lintSchema.getAbsolutePath());
            for (Iterator iter = dbConnList.iterator(); iter.hasNext();) {
                run.addDBConnection((PCTConnection) iter.next());
            }
            run.execute();
        }

        try {
            lintFiles();
            cleanup();
        } catch (Throwable be) {
            cleanup();
            throw new BuildException(be);
        }
    }

    private Collection readRules(InputStream input) throws IOException {
        Properties props = new Properties();
        props.load(input);

        Collection rules = new ArrayList();
        for (Iterator iter = props.keySet().iterator(); iter.hasNext();) {
            String entry = (String) iter.next();
            String value = props.getProperty(entry);

            try {
                Class clz = Class.forName(value);
                if (ILintRule.class.isAssignableFrom(clz)) {
                    Constructor constructor = clz.getConstructor();
                    Object o = constructor.newInstance();
                    rules.add(o);
                }
            } catch (Throwable caught) {
                log("Unable to load class " + value, Project.MSG_ERR);
                throw new BuildException(caught);
            }
        }

        return rules;
    }

    private void lintFiles() throws IOException, RefactorException {
        Environment env = Environment.instance();
        RefactorSession session = RefactorSession.getInstance();
        Schema schema = Schema.getInstance();
        Collection rules = readRules((rulesFile == null ? this.getClass().getResourceAsStream(
                "/lint.properties") : new FileInputStream(rulesFile)));

        env.configSet("batch-mode", "true");
        env.configSet("opsys", "WIN32");
        env.configSet("propath", getPropath());
        env.configSet("proversion", "11.0");
        env.configSet("window-system", "TTY");

        if ((dbConnList != null) && (dbConnList.size() > 0)) {
            schema.loadSchema(lintSchema.getAbsolutePath());
            for (Iterator iter = dbConnList.iterator(); iter.hasNext();) {
                PCTConnection conn = (PCTConnection) iter.next();
                if (conn.hasAliases()) {
                    for (Iterator iter2 = conn.getAliases().iterator(); iter2.hasNext();) {
                        PCTAlias alias = (PCTAlias) iter2.next();
                        schema.aliasCreate(alias.getName(), conn.getDbName());
                    }
                }
            }
        }

        ILintCallback callback = new XMLLintCallback(lintFile);

        for (Iterator e = filesets.iterator(); e.hasNext();) {
            FileSet fs = (FileSet) e.next();
            String[] dsfiles = fs.getDirectoryScanner(this.getProject()).getIncludedFiles();
            for (int i = 0; i < dsfiles.length; i++) {
                File foo = new File(fs.getDir(this.getProject()), dsfiles[i]);
                File xref = null; // new File(xRefDir, dsfiles[i] + ".xref");
                ParseUnit unit = new ParseUnit(foo);
                try {
                    unit.treeParser01();
                    for (Iterator iter = rules.iterator(); iter.hasNext();) {
                        ILintRule rule = (ILintRule) iter.next();
                        rule.execute(unit, xref, callback);
                    }
                } catch (RefactorException uncaught) {
                    System.out.println(uncaught);
                }
            }
        }

        callback.terminate();
    }

    protected void cleanup() {
        if (lintSchema.exists() && !lintSchema.delete()) {
            log(MessageFormat
                    .format(Messages.getString("PCTCompile.42"), new Object[]{lintSchema.getAbsolutePath()}), Project.MSG_VERBOSE); //$NON-NLS-1$
        }

    }
}
