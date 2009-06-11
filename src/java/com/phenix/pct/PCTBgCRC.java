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

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Iterator;
import java.util.List;

/**
 * Generates a file containing CRC for each table (multiple databases allowed)
 * 
 * @author <a href="mailto:justus_phenix@users.sourceforge.net">Gilles QUERRET</a>
 * @version $Revision$
 */
public class PCTBgCRC extends PCTBgRun {
    private File destFile = null;

    /**
     * Output file for CRCs
     * 
     * @param destFile File
     */
    public void setDestFile(File destFile) {
        this.destFile = destFile;
    }

    public File getDestFile() {
        return this.destFile;
    }

    /**
     * Returns a new listener
     */
    protected PCTListener getListener(PCTBgRun parent) throws IOException {
        return new PCTCRCListener(this);
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        if (this.destFile == null) {
            this.cleanup();
            throw new BuildException(Messages.getString("PCTCRC.0")); //$NON-NLS-1$
        }

        if (this.dbConnList == null) {
            this.cleanup();
            throw new BuildException(Messages.getString("PCTCRC.1")); //$NON-NLS-1$
        }

        super.execute();
    }

    private class PCTCRCListener extends PCTListener {
        /**
         * Creates a new PCTCRCListener
         * 
         * @param parent PCTBgRun instance
         * @throws IOException Server socket fails
         */
        public PCTCRCListener(PCTBgCRC parent) throws IOException {
            super(parent);
        }

        /**
         * This task will run the pct/pctBgCRC.p, run its internal procedure getCRC, and then output
         * the result to destFile
         * FIXME Reprendre ce code !!!! Correction erreur de compilation...
         */
        public boolean custom(int threadNumber) throws IOException {
            sendCommand(threadNumber, "launch pct/pctBgCrc.p");
            sendCommand(threadNumber, "getCRC");
            
            return false;
        }

        /**
         * Reads response from Progress session. Write to destFile one line for each CRC found
         * 
         * @param param Procedure's parameter (empty for getCRC)
         * @param ret Return value
         * @param strings List of returned values
         * @throws IOException
         */
        public void handleGetCRC(String param, String ret, List strings) throws IOException {
            BufferedWriter bw = new BufferedWriter(new FileWriter(((PCTBgCRC) this.parent)
                    .getDestFile()));
            for (Iterator i = strings.iterator(); i.hasNext();) {
                bw.write((String) i.next());
                bw.newLine();
            }
            bw.close();
        }

        /**
         * Does nothing
         * 
         * @param param Procedure's parameter
         * @param ret Return value
         * @param strings List of returned values
         * @throws IOException
         */
        public void handleLaunch(String param, String ret, List strings) throws IOException {

        }
    }

}
