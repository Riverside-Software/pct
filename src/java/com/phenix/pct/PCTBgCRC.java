/**
 * Copyright 2005-2019 Riverside Software
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */
package com.phenix.pct;

import org.apache.tools.ant.BuildException;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.net.Socket;
import java.util.List;
import java.util.Map;

/**
 * Generates a file containing CRC for each table (multiple databases allowed)
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
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

    @Override
    public void setProcedure(String procedure) {
        throw new BuildException("Can't set procedure attribute");
    }

    public class CRCThreadStatus extends BackgroundWorker {
        private int customStatus = 0;

        public CRCThreadStatus(PCTBgRun parent) {
            super(parent);
        }

        protected boolean performCustomAction() throws IOException {
            if (customStatus == 0) {
                customStatus = 1;
                sendCommand("launch", "pct/pctBgCRC.p");
            } else if (customStatus == 1) {
                sendCommand("getCRC", "");
                setStatusQuit();
            }
            return false;
        }

        public void setCustomOptions(Map<String, String> options) {
            // No-op
        }

        public void handleResponse(String command, String parameter, boolean err, String customResponse, List<Message> returnValues) {
            try (FileWriter fw = new FileWriter(getDestFile());
                    BufferedWriter bw = new BufferedWriter(fw)) {
                for (Message msg : returnValues) {
                    bw.write(msg.getMsg());
                    bw.newLine();
                }
            } catch (IOException caught) {
                setBuildException(caught);
            }
        }
    }

    protected BackgroundWorker createOpenEdgeWorker(Socket socket) {
        CRCThreadStatus worker = new CRCThreadStatus(this);
        try {
            worker.initialize(socket);
        } catch (Exception uncaught) {
            throw new BuildException(uncaught);
        }

        return worker;
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    @Override
    public void execute() {
        if (this.destFile == null) {
            this.cleanup();
            throw new BuildException(Messages.getString("PCTCRC.0")); //$NON-NLS-1$
        }

        if (getOptions().getDBConnections() == null) {
            this.cleanup();
            throw new BuildException(Messages.getString("PCTCRC.1")); //$NON-NLS-1$
        }

        super.execute();
    }

}
