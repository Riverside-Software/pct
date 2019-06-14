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

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.Socket;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;

public abstract class BackgroundWorker {
    private static final AtomicInteger threadCounter = new AtomicInteger(0);

    private int threadNumber;
    private BufferedReader reader;
    private BufferedWriter writer;

    // 0 tout début 1 connecté 2 db ok 3 propath ok 4 custom 5 terminé
    private int status;
    private Iterator<PCTConnection> dbConnections;
    private Iterator<String> propath;

    // Dernière commande envoyée
    private String lastCommand;
    private String lastCommandParameter;

    // Faut-il quitter la boucle infinie du thread ?
    public boolean quit = false;

    private final PCTBgRun parent;

    public BackgroundWorker(PCTBgRun parent) {
        this.parent = parent;
    }

    public final void initialize(Socket socket) throws IOException {
        this.reader = new BufferedReader(new InputStreamReader(socket.getInputStream(), parent.getCharset()));
        this.writer = new BufferedWriter(new OutputStreamWriter(socket.getOutputStream(), parent.getCharset()));

        // TODO Should be HELLO or something like that...
        reader.readLine();

        // Assign a unique thread number to this worker
        threadNumber = threadCounter.incrementAndGet();
    }

    public final void setDBConnections(Iterator<PCTConnection> dbConnections) {
        this.dbConnections = dbConnections;
    }

    public final void setPropath(Iterator<String> propath) {
        this.propath = propath;
    }

    public final int getThreadNumber() {
        return threadNumber;
    }

    public final void sendCommand(String command, String param) throws IOException {
        // Check validity
        if ((command == null) || "".equals(command.trim())) //$NON-NLS-1$
            throw new IllegalArgumentException("Invalid command");

        lastCommand = command;
        lastCommandParameter = param;

        writer.write(command + " " + param); //$NON-NLS-1$
        writer.newLine();
        writer.flush();
    }

    public final void listen() {
        boolean end = false;
        boolean err = false;
        List<Message> retVals = new ArrayList<>();
        String customResponse = "";

        while (!end) {
            try {
                String str = reader.readLine();
                int idx = str.indexOf(':');
                String result = (idx == -1 ? str : str.substring(0, idx));

                if ("OK".equalsIgnoreCase(result)) {
                    if ("quit".equalsIgnoreCase(result)) {
                        status = 5;
                    }
                    if ((idx != -1) && (idx < (str.length() - 1)))
                        customResponse = str.substring(idx + 1);
                } else if ("ERR".equalsIgnoreCase(result)) {
                    err = true;
                    if ((idx != -1) && (idx < (str.length() - 1)))
                        customResponse = str.substring(idx + 1);
                } else if ("MSG".equalsIgnoreCase(result)) {
                    // Everything after MSG: is logged
                    if ((idx != -1) && (idx < (str.length() - 1)))
                        retVals.add(new Message(str.substring(idx + 1)));
                } else if ("END".equalsIgnoreCase(result)) {
                    end = true;
                    // Standard commands (i.e. sent by this class) cannnot be handled and overridden
                    if (!isStandardCommand(lastCommand)) {
                        handleResponse(lastCommand, lastCommandParameter, err, customResponse,
                                retVals);
                    } else {
                        handleStandardEventResponse(lastCommand, lastCommandParameter, err, customResponse,
                                retVals);
                    }
                }
            } catch (IOException ioe) {
                parent.log(ioe, Project.MSG_ERR);
                end = true;
            }
        }
    }

    public final void performAction() throws IOException {
        if (status == 0) {
            status = 1;
            sendCommand("setThreadNumber", Integer.toString(threadNumber));
        } else if (status == 1) {
            if (dbConnections.hasNext()) {
                PCTConnection dbc = dbConnections.next();
                sendCommand("connect", dbc.createBackgroundConnectString());
            } else {
                status = 2;
                performAction();
            }
        } else if (status == 2) {
            if (propath.hasNext()) {
                String s = propath.next();
                sendCommand("propath", s + File.pathSeparatorChar);
            } else {
                status = 3;
                performAction();
            }
        } else if (status == 3) {
            if (!performCustomAction()) {
                status = 5;
                sendCommand("quit", "");
                quit = true;
            }

        } else if (status == 4) {
            status = 5;
            sendCommand("quit", "");
            quit = true;
        } else if (status == 5) {
            // No-op
        }
    }

    public final boolean isStandardCommand(String command) {
        if ("setThreadNumber".equalsIgnoreCase(command) || "connect".equalsIgnoreCase(command)
                || "propath".equalsIgnoreCase(command) || "quit".equalsIgnoreCase(command)) {
            return true;
        }

        return false;
    }

    public final void setStatusQuit() {
        status = 4;
    }

    /**
     * This is where you code the task's logic
     */
    protected abstract boolean performCustomAction() throws IOException;

    public abstract void setCustomOptions(Map<String, String> options);

    /**
     * This is where you can handle responses from the Progress process
     * 
     * @param command Command sent
     * @param parameter Command's parameter
     * @param err An error was returned
     * @param customResponse Custom response sent by Progress
     * @param returnValues List of Message objects
     */
    public abstract void handleResponse(String command, String parameter, boolean err,
            String customResponse, List<Message> returnValues);

    public final void handleStandardEventResponse(String command, String parameter, boolean err,
            String customResponse, List<Message> returnValues) {
        if ("connect".equalsIgnoreCase(command) && err) {
            parent.logMessages(returnValues);
            parent.setBuildException(new BuildException(command + "(" + parameter + ") : " + customResponse));
            setStatusQuit();
        }        
    }

    public static final class Message {
        private final String msg;
        private final int level;

        public Message(String str) {
            int pos = str.indexOf(':');
            if (pos == -1)
                throw new IllegalArgumentException();

            level = Integer.parseInt(str.substring(0, pos));
            msg = str.substring(pos + 1);
        }

        public String getMsg() {
            return msg;
        }

        public int getLevel() {
            return level;
        }
    }
}
