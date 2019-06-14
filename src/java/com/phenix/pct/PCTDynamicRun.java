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
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.nio.charset.Charset;
import java.text.MessageFormat;
import java.util.Collection;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
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
        jsonConfig = new File(System.getProperty(PCT.TMPDIR), "config" + configID + ".json");
        iniFile = new File(System.getProperty(PCT.TMPDIR), "config" + iniID + ".ini");
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
                        writer.value(FileUtils
                                .getRelativePath((runAttributes.getBaseDir() == null
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
            for (PCTConnection dbc : runAttributes.getAllDbConnections()) {
                writer.beginObject();
                writer.name("connect").value(dbc.createConnectString());
                writer.name("aliases").beginArray();

                Collection<PCTAlias> aliases = dbc.getAliases();
                if (aliases != null) {
                    for (PCTAlias alias : aliases) {
                        writer.value(alias.getName());
                    }
                }
                writer.endArray();
                writer.endObject();
            }
            writer.endArray();

            writer.name("parameters").beginArray();
            if (runAttributes.getRunParameters() != null) {
                for (RunParameter param : runAttributes.getRunParameters()) {
                    if (param.validate()) {
                        writer.beginObject().name("name").value(param.getName()).name("value")
                                .value(param.getValue()).endObject();
                    } else {
                        log(MessageFormat.format(Messages.getString("PCTRun.9"), param.getName()),
                                Project.MSG_WARN);
                    }
                }
            }
            writer.endArray();

            writer.name("output").beginArray();
            if (runAttributes.getOutputParameters() != null) {
                int zz = 0;
                for (OutputParameter param : runAttributes.getOutputParameters()) {
                    param.setProgressVar("outParam" + zz++);;
                    File tmpFile = new File(System.getProperty(PCT.TMPDIR),
                            param.getProgressVar() + "." + PCT.nextRandomInt() + ".out");
                    param.setTempFileName(tmpFile);
                    writer.value(tmpFile.getAbsolutePath());
                }
            }
            writer.endArray();

            writer.endObject();
        }
    }

    private void writeIniFile() throws IOException {
        try (FileWriter fw = new FileWriter(iniFile)) {
            if (runAttributes.isGraphMode()) {
                fw.write("[Startup]\n");
            } else {
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
        if ((runAttributes.getOutputParameters() != null)
                && (runAttributes.getOutputParameters().size() > 2))
            throw new BuildException("Only two OutputParameter nodes allowed");

        prepareExecTask();
        if (runAttributes.getProfiler() != null) {
            runAttributes.getProfiler().validate(false);
        }
        super.setParameter(jsonConfig.getAbsolutePath());

        try {
            // File name generation is deffered at this stage, because when defined in constructor,
            // we still don't know if we have to use source code or compiled version. And it's
            // impossible to extract source code to a directory named something.pl as Progress tries
            // to open a procedure library, and miserably fails with error 13.
            pctLib = new File(System.getProperty("java.io.tmpdir"),
                    "pct" + plID + (isSourceCodeUsed() ? "" : ".pl"));

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
            createProfilerFile();
            setExecTaskParams();
            exec.createArg().setValue("-p");
            exec.createArg().setValue(getProgressProcedures().getDynamicRunProcedure());

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

        // Reads output parameter
        if (runAttributes.getOutputParameters() != null) {
            for (OutputParameter param : runAttributes.getOutputParameters()) {
                File f = param.getTempFileName();
                try (InputStream fis = new FileInputStream(f);
                        Reader r = new InputStreamReader(fis, Charset.forName("utf-8"));
                        BufferedReader br = new BufferedReader(r)) {
                    String s = br.readLine();
                    getProject().setNewProperty(param.getName(), s);
                } catch (IOException ioe) {
                    log(MessageFormat.format(Messages.getString("PCTRun.10"), param.getName(), //$NON-NLS-1$
                            f.getAbsolutePath()), Project.MSG_ERR);
                    cleanup();
                    throw new BuildException(ioe);
                }
            }
        }

        // Now read status file
        try (Reader r = new FileReader(status); BufferedReader br = new BufferedReader(r)) {
            String s = br.readLine();
            int ret = Integer.parseInt(s);
            if (ret != 0 && runAttributes.isFailOnError()) {
                throw new BuildException(MessageFormat.format(Messages.getString("PCTRun.6"), ret)); //$NON-NLS-1$
            }
            maybeSetResultPropertyValue(ret);
        } catch (IOException caught) {
            throw new BuildException(Messages.getString("PCTRun.2"), caught); //$NON-NLS-1$
        } catch (NumberFormatException caught) {
            throw new BuildException(Messages.getString("PCTRun.3"), caught); //$NON-NLS-1$
        } finally {
            cleanup();
        }
    }

    @Override
    protected void cleanup() {
        super.cleanup();

        if (getDebugPCT())
            return;
        deleteFile(jsonConfig);
        deleteFile(iniFile);
    }
}
