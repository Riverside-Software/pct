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

import java.io.File;


/**
 * Dumps sequences from database
 *
 * @author <a href="mailto:g.querret@gmail.com">Gilles QUERRET</a>
 */
public class DumpSequences extends PCTRun {
    private File destDir = null;
    private String encoding = null;

    /**
     * Output directory for dump
     * @param destDir directory
     */
    public void setDestDir(File destDir) {
        this.destDir = destDir;
    }

    /**
     * Set encoding to be used to dump data. If not set or empty,
     * dump will be done using -cpstream default value.
     * 
     * @param encoding
     */
    public void setEncoding(String encoding) {
        this.encoding = encoding;
    }

    /**
     * Do the work
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        if (dbConnList == null) {
            cleanup();
            throw new BuildException(Messages.getString("PCTDumpData.0")); //$NON-NLS-1$
        }

        if (dbConnList.size() > 1) {
            cleanup();
            throw new BuildException(Messages.getString("PCTDumpData.1")); //$NON-NLS-1$
        }

        if (destDir == null) {
            cleanup();
            throw new BuildException(Messages.getString("PCTDumpData.2")); //$NON-NLS-1$
        }

        addParameter(new RunParameter("destDir", destDir.toString())); //$NON-NLS-1$
        addParameter(new RunParameter("encoding", (encoding == null ? "" : encoding))); //$NON-NLS-1$ $NON-NLS-2$
        setProcedure("pct/dump_seq.p"); //$NON-NLS-1$

        super.execute();
    }
}
