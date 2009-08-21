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

public abstract class BackgroundWorker {
    private static final AtomicInteger threadCounter = new AtomicInteger(0);

    private int threadNumber;
    private Socket socket;
    private BufferedReader reader;
    private BufferedWriter writer;

    // 0 tout début 1 connecté 2 db ok 3 propath ok 4 custom 5 terminé
    private int status;
    private Iterator dbConnections, propath;

    // Dernière commande envoyée
    private String lastCommand, lastCommandParameter;

    // Faut-il quitter la boucle infinie du thread ?
    public boolean quit = false; // FIXME

    private final PCTBgRun parent;

    public BackgroundWorker(PCTBgRun parent) {
        this.parent = parent;
    }

    public final void initialize(Socket socket) throws IOException {
        this.socket = socket;
        this.reader = new BufferedReader(new InputStreamReader(this.socket.getInputStream()));
        this.writer = new BufferedWriter(new OutputStreamWriter(this.socket.getOutputStream()));

        // FIXME Should be HELLO or something like that...
        reader.readLine();

        // Assign a unique thread number to this worker
        threadNumber = threadCounter.incrementAndGet();
    }

    public final void setDBConnections(Iterator dbConnections) {
        this.dbConnections = dbConnections;
    }

    public final void setPropath(Iterator propath) {
        this.propath = propath;
    }

    public final int getThreadNumber() {
        return threadNumber;
    }

    public final void sendCommand(String command, String param) throws IOException {
        // Check validity
        if ((command == null) || (command.trim().equals(""))) //$NON-NLS-1$
            throw new IllegalArgumentException("Invalid command");

        lastCommand = command;
        lastCommandParameter = param;

        writer.write(command + " " + param); //$NON-NLS-1$
        writer.newLine();
        writer.flush();
    }

    public final void listen() {
        boolean end = false, err = false;
        List retVals = new ArrayList();

        while (!end) {
            try {
                String[] ss = reader.readLine().split(":");

                if (ss[1].equalsIgnoreCase("OK")) {
                    if (lastCommand.equalsIgnoreCase("quit")) {
                        status = 5;
                    }
                } else if (ss[1].equalsIgnoreCase("ERR")) {
                    err = true;
                } else if (ss[1].equalsIgnoreCase("MSG")) {
                    retVals.add(ss[2]);
                } else if (ss[1].equalsIgnoreCase("END")) {
                    end = true;
                    if (!isStandardCommand(lastCommand)) {
                        handleResponse(lastCommand, lastCommandParameter, err, retVals);
                    }
                }
            } catch (IOException ioe) {
                ioe.printStackTrace();
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
                PCTConnection dbc = (PCTConnection) dbConnections.next();
                sendCommand("connect", dbc.createBackgroundConnectString());
            } else {
                status = 2;
                performAction();
            }
        } else if (status == 2) {
            if (propath.hasNext()) {
                String s = (String) propath.next();
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

        }
    }

    public final boolean isStandardCommand(String command) {
        if ("setThreadNumber".equalsIgnoreCase(command)) {
            return true;
        } else if ("connect".equalsIgnoreCase(command)) {
            return true;
        } else if ("propath".equalsIgnoreCase(command)) {
            return true;
        } else if ("quit".equalsIgnoreCase(command)) {
            return true;
        }

        return false;
    }

    public final void quit() {
        status = 4;
    }

    /**
     * This is where you code the task's logic
     */
    protected abstract boolean performCustomAction() throws IOException;

    /**
     * 
     * @param options
     */
    public abstract void setCustomOptions(Map options);

    /**
     * This is where you can handle responses from the Progress process
     * 
     * @param command Command sent
     * @param parameter Command's parameter
     * @param err An error was returned
     * @param returnValues List of string
     */
    public abstract void handleResponse(String command, String parameter, boolean err,
            List returnValues);
}
