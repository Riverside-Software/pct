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
import org.apache.tools.ant.types.Commandline;

import java.io.File;


public class PCTDumpSchema extends PCT {
    private PCTConnection dbConn = null;
    private File destFile = null;

    public void addPCTConnection(PCTConnection dbConn)
                          throws BuildException {
        if (this.dbConn != null) {
            throw new BuildException("Only one connection allowed");
        }

        this.dbConn = dbConn;
    }

    public void setDestFile(File destFile) {
        this.destFile = destFile;
    }

    public void execute() throws BuildException {
        Commandline cmdLine = null;
        int result = 0;

        if (this.destFile == null) {
            throw new BuildException("Mandatory argument : dump file");
        }

        if (this.dbConn == null) {
            throw new BuildException("No database connection defined");
        }

        cmdLine = buildCmdLine();
        result = run(cmdLine);

        if (result != 0) {
            throw new BuildException("Failed dumping schema [" + result + "]");
        }
    }

    private Commandline buildCmdLine() {
        Commandline commandLine = new Commandline();

        commandLine.setExecutable(getExecPath("_progres"));
        commandLine.createArgument().setValue("-b");
        this.dbConn.createArguments(commandLine);
        commandLine.createArgument().setValue("-p");
        commandLine.createArgument().setValue("pctDumpSchema.p");
        commandLine.createArgument().setValue("-param");
        commandLine.createArgument().setValue(destFile.toString());

        return commandLine;
    }
}
