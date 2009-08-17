package com.phenix.pct;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.Socket;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

public abstract class BackgroundWorker {
    private int threadNumber;

    private Socket socket;
    private BufferedReader reader;
    private BufferedWriter writer;

    // 0 tout début 1 connecté 2 db ok 3 propath ok 4 custom 5 terminé
    protected int status;
    private Iterator dbConnections;
    private Iterator propath;

    // Dernière commande envoyée
    private String lastCommand;
    // Dernier paramètre de commande envoyé
    private String lastCommandParameter;
    // Succès ou échec de la commande
    protected int lastCmdStatus;

    // Valeurs renvoyées par la commande
    private final List retVals = new ArrayList();

    // Faut-il quitter la boucle infinie du thread ?
    public boolean quit = false; // FIXME

    private final PCTBgRun parent;
    
    private static final AtomicInteger threadCounter = new AtomicInteger(0);
    
    public BackgroundWorker(PCTBgRun parent) {
        this.parent = parent;
    }
    
    public void initialize(Socket socket) throws IOException {
        this.socket = socket;
        this.reader = new BufferedReader(new InputStreamReader(this.socket.getInputStream()));
        this.writer = new BufferedWriter(new OutputStreamWriter(this.socket.getOutputStream()));

        // FIXME Should be HELLO or something like that...
        reader.readLine();

        threadNumber = threadCounter.incrementAndGet(); 
    }

    public void setDBConnections(Iterator dbConnections) {
        this.dbConnections = dbConnections;
    }

    public void setPropath(Iterator propath) {
        this.propath = propath;
    }

    public abstract void setCustomOptions(Map options);

    public void setLastCommand(String command, String param) {
        lastCommand = command;
        lastCommandParameter = param;
    }

    public int getThreadNumber() {
        return threadNumber;
    }

    public boolean sendCommand(int tNum, String command, String param) throws IOException {
        // Check validity
        if ((command == null) || (command.trim().equals(""))) //$NON-NLS-1$
            return false;

        // First character in capital letters
        if (command.length() == 1) {
            command = command.toUpperCase();
        } else {
            command = command.substring(0, 1).toUpperCase() + command.substring(1);
        }

        setLastCommand(command, param);

        writer.write(command + " " + param); //$NON-NLS-1$
        writer.newLine();
        writer.flush();

        return true;
    }

    public void listen(int tNum) {
        boolean end = false;
        
        while (!end) {
        try {
            String s = reader.readLine();
            String[] ss = s.split(":");

//            Integer threadNumber = new Integer(ss[0]);
            if (ss[1].equalsIgnoreCase("OK")) {
                if (lastCommand.equalsIgnoreCase("quit")) {
                    status = 5;
                } else {
                    lastCmdStatus = 1;
                }
            } else if (ss[1].equalsIgnoreCase("ERR")) {
                lastCmdStatus = 2;
            } else if (ss[1].equalsIgnoreCase("MSG")) {
                retVals.add(ss[2]);
            } else if (ss[1].equalsIgnoreCase("END")) {
                end = true;
                // On envoie la sauce
                Method m = this.getClass().getMethod("handle" + lastCommand, //$NON-NLS-1$
                        new Class[]{Integer.class, String.class});
                m.invoke(this, new Object[]{Integer.valueOf(0), lastCommandParameter});
            }
        } catch (IOException ioe) {
            ioe.printStackTrace();
            return;
        } catch (SecurityException e) {
            e.printStackTrace();
            return;
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
            return;
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
            return;
        } catch (IllegalAccessException e) {
            e.printStackTrace();
            return;
        } catch (InvocationTargetException e) {
            e.printStackTrace();
            return;
        }}
    }

    public void performAction() throws IOException {
        if (status == 0) {
            status = 1;
            sendCommand(0, "setThreadNumber", Integer.toString(threadNumber));
        } else if (status == 1) {
            if (dbConnections.hasNext()) {
                PCTConnection dbc = (PCTConnection) dbConnections.next();
                sendCommand(0, "Connect", dbc.createBackgroundConnectString());
            } else {
                status = 2;
                performAction();
            }
        } else if (status == 2) {
            if (propath.hasNext()) {
                String s = (String) propath.next();
                sendCommand(0, "Propath", s + File.pathSeparatorChar);
            } else {
                status = 3;
                performAction();
            }
        } else if (status == 3) {
            if (!performCustomAction(0)) {
                status = 5;
                sendCommand(0, "Quit", "");
                quit = true;
            }
            
        } else if (status == 4) {
            status = 5;
            sendCommand(0, "Quit", "");
            quit = true;
        } else if (status == 5) {
            
        }
    }
    
    public void quit() {
        status =4 ;
    }

    /**
     * This is where you code the task's logic
     */
    protected abstract boolean performCustomAction(int threadNumber) throws IOException;

}
