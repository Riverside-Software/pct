/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) 2002 The Apache Software Foundation.  All rights
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
import org.apache.tools.ant.types.PatternSet;
import org.apache.tools.ant.types.selectors.SelectorUtils;

import java.io.File;

import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import java.util.Vector;

/**
 * Extracts files from a PL archive
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
 */
public class PLExtract extends PCT {
    private Vector patternSet = null;
    private File src = null;
    private File dest = null;
    private boolean overwrite = false;

    /**
     * Default constructor
     */
    public PLExtract() {
        super();
    }

    /**
     * Sets output directory
     * 
     * @param dest File
     */
    public void setDest(File dest) {
        this.dest = dest;
    }

    /**
     * Sets source file
     * 
     * @param src File
     */
    public void setSrc(File src) {
        this.src = src;
    }

    /**
     * Overwrites files ?
     * 
     * @param overwrite boolean
     */
    public void setOverwrite(boolean overwrite) {
        this.overwrite = overwrite;
    }

    /**
     * Adds a patternset
     * 
     * @param set PatternSet
     */
    public void addPatternset(PatternSet set) {
        if (this.patternSet == null)
            this.patternSet = new Vector();

        patternSet.addElement(set);
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        if ((this.src == null) || (!this.src.exists()))
            throw new BuildException(Messages.getString("PLExtract.1"));

        if (this.dest == null)
            throw new BuildException(Messages.getString("PLExtract.2"));
        if (!this.dest.exists())
            if (!this.dest.mkdirs())
                throw new BuildException(Messages.getString("PLExtract.3"));

        PLReader reader = new PLReader(this.src);
        reader.init();
        List files = reader.getFileList();

        Set includePatterns = new HashSet();
        Set excludePatterns = new HashSet();
        getPatterns(includePatterns, excludePatterns);
        
        for (Iterator i = files.iterator(); i.hasNext();) {
            PLReader.FileEntry file = (PLReader.FileEntry) i.next();
            File destFile = new File(this.dest, file.getFileName());
            if ((this.overwrite) || (!this.overwrite && !destFile.exists())) {
                String name = file.getFileName();
                boolean included = false;

                for (Iterator iter = includePatterns.iterator(); !included && iter.hasNext();) {
                    String pattern = (String) iter.next();
                    included = SelectorUtils.matchPath(pattern, name);
                }

                for (Iterator iter = excludePatterns.iterator(); included && iter.hasNext();) {
                    String pattern = (String) iter.next();
                    included = !SelectorUtils.matchPath(pattern, name);
                }

                if (included) {
                    reader.extractFile(file, destFile);
                }
            }
        }

    }

    // This is cut'n'paste from Expand task
    private void getPatterns(Set includePatterns, Set excludePatterns) {
        if (this.patternSet != null && this.patternSet.size() > 0) {
            for (int v = 0, size = this.patternSet.size(); v < size; v++) {
                PatternSet p = (PatternSet) this.patternSet.elementAt(v);
                String[] incls = p.getIncludePatterns(getProject());
                if (incls == null || incls.length == 0) {
                    // no include pattern implicitly means includes="**"
                    incls = new String[]{"**"};
                }

                for (int w = 0; w < incls.length; w++) {
                    String pattern = incls[w].replace('/', File.separatorChar).replace('\\',
                            File.separatorChar);
                    if (pattern.endsWith(File.separator)) {
                        pattern += "**";
                    }
                    includePatterns.add(pattern);
                }

                String[] excls = p.getExcludePatterns(getProject());
                if (excls != null) {
                    for (int w = 0; w < excls.length; w++) {
                        String pattern = excls[w].replace('/', File.separatorChar).replace('\\',
                                File.separatorChar);
                        if (pattern.endsWith(File.separator)) {
                            pattern += "**";
                        }
                        excludePatterns.add(pattern);
                    }
                }
            }
        } else {
            includePatterns.add("**");
            excludePatterns.add("");

        }
    }
}
