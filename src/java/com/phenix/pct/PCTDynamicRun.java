package com.phenix.pct;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Reader;
import java.text.MessageFormat;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.taskdefs.condition.Os;
import org.apache.tools.ant.types.Environment;
import org.apache.tools.ant.util.FileUtils;

import com.google.gson.stream.JsonWriter;

public class PCTDynamicRun extends PCTRun {

    private int configID = -1;
    private int iniID = -1;
    private File jsonConfig;
    private File iniFile;

    public PCTDynamicRun() {
        super(true);
        configID = PCT.nextRandomInt();
        iniID = PCT.nextRandomInt();
        jsonConfig = new File(System.getProperty("java.io.tmpdir"), "config" + configID + ".json");
        iniFile = new File(System.getProperty("java.io.tmpdir"), "config" + iniID + ".ini");
    }

    @Override
    public void addOutputParameter(OutputParameter param) {
        throw new UnsupportedOperationException("No OutputParameter in this mode");
    }

    @Override
    public void setParameter(String param) {
        throw new UnsupportedOperationException("No -param attribute in this mode");
    }

    @Override
    public void setIniFile(File iniFile) {
        throw new UnsupportedOperationException("No -ininame attribute in this mode");
    }

    @Override
    public void addProfiler(Profiler profiler) {
        throw new UnsupportedOperationException("No profiler attribute in this mode");
    }

    @Override
    public void setMainCallback(String mainCallback) {
        throw new UnsupportedOperationException("No callback attribute in this mode");
    }

    private void writeJsonConfigFile() throws IOException {
        try (JsonWriter writer = new JsonWriter(new FileWriter(jsonConfig))) {
            writer.beginObject();
            writer.name("verbose").value(isVerbose());
            writer.name("procedure").value(runAttributes.getProcedure());
            writer.name("returnValue").value(status.getAbsolutePath());
            writer.name("propath").beginArray();
            
            String[] lst = runAttributes.getPropath().list();
            for (int k = lst.length - 1; k >= 0; k--) {
                if (runAttributes.useRelativePaths()) {
                    try {
                        writer.value(
                                FileUtils.getRelativePath((runAttributes.getBaseDir() == null
                                        ? getProject().getBaseDir()
                                        : runAttributes.getBaseDir()), new File(lst[k]))
                                        .replace('/', File.separatorChar));
                    } catch (Exception e) {
                        throw new IOException(e);
                    }
                } else {
                    writer.value(lst[k]);
                }
            }

            writer.endArray();
            
            writer.name("databases").beginArray();
            
            writer.endArray();
            writer.endObject();
        }
    }

    private void writeIniFile() throws IOException {
        try (FileWriter fw = new FileWriter(iniFile)) {
            if (runAttributes.isGraphMode()) {
                fw.write("[Startup]\n");
            }
            else {
                fw.write("[WinChar Startup]\n");
            }
            fw.write("PROPATH=" + pctLib.getAbsolutePath() + "\n");
        }
    }

    @Override
    public void execute() {
        checkDlcHome();
        if ((runAttributes.getProcedure() == null) || (runAttributes.getProcedure().length() == 0))
            throw new BuildException("Procedure attribute not defined");

        prepareExecTask();
        super.setParameter(jsonConfig.getAbsolutePath());

        try {
            // File name generation is deffered at this stage, because when defined in constructor,
            // we still don't know if
            // we have to use source code or compiled version. And it's impossible to extract source
            // code to a directory named
            // something.pl as Progress tries to open a procedure library, and miserably fails with
            // error 13.
            pctLib = new File(
                    System.getProperty("java.io.tmpdir"), "pct" + plID + (isSourceCodeUsed() ? "" : ".pl"));

            if (Os.isFamily(Os.FAMILY_WINDOWS)) {
                writeIniFile();
                super.setIniFile(iniFile);
            } else {
                Environment.Variable var = new Environment.Variable();
                var.setKey("PROPATH"); //$NON-NLS-1$
                var.setValue(pctLib.getAbsolutePath());
                exec.addEnv(var);
            }


            writeJsonConfigFile();
            setExecTaskParams();
            exec.createArg().setValue("-p");
            exec.createArg().setValue("pct/dynrun.p");
            
            
            if (getIncludedPL() && !extractPL(pctLib)) {
                throw new BuildException("Unable to extract pct.pl.");
            }

            exec.execute();
            
        } catch (BuildException be) {
            cleanup();
            throw be;
        } catch (IOException caught) {
            cleanup();
            throw new BuildException(caught);
        }

        // Now read status file
        try (Reader r = new FileReader(status); BufferedReader br = new BufferedReader(r)) {
            String s = br.readLine();
            int ret = Integer.parseInt(s);
            if (ret != 0 && runAttributes.isFailOnError()) {
                throw new BuildException(MessageFormat.format(Messages.getString("PCTRun.6"), ret)); //$NON-NLS-1$
            }
//            maybeSetResultPropertyValue(ret);
        } catch (IOException caught) {
            throw new BuildException(Messages.getString("PCTRun.2"), caught); //$NON-NLS-1$
        } catch (NumberFormatException caught) {
            throw new BuildException(Messages.getString("PCTRun.3"), caught); //$NON-NLS-1$
        } finally {
            cleanup();
        }

        // super.execute();
    }
}
