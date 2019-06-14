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
import org.apache.tools.ant.taskdefs.Java;
import org.apache.tools.ant.types.Commandline;
import org.apache.tools.ant.types.Environment;

import java.io.File;

/**
 * RESTgen task
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 */
public class RestGen extends PCT {
    // Class used by Proxygen
    private static final String PROXYGEN_CLASS = "com.progress.rest.tools.WARGenerator";

    private enum RestGenerationType {
        REST_SERVICE_PAAR("Paar"), MOBILE_SERVICE_PAAR("MobPaar"), REST_SERVICE_WAR("RESTWar"), MOBILE_SERVICE_WAR(
                "MobWar"), MOBILE_APP_WAR("MobAppWar"), MOBILE_APP("OnlyMobApp");

        private String value;

        private RestGenerationType(String value) {
            this.value = value;
        }

        public static RestGenerationType get(String str) {
            for (RestGenerationType type : RestGenerationType.values()) {
                if (type.value.equalsIgnoreCase(str))
                    return type;
            }

            return null;
        }
    }

    private File projectDir = null;
    private RestGenerationType type = null;
    private File destFile = null;
    private String services = null;
    private boolean includeJars = false;

    private Java pxg = null;

    public void setProjectDir(File project) {
        this.projectDir = project;
    }

    public void setType(String type) {
        this.type = RestGenerationType.get(type);
        if (this.type == null)
            throw new BuildException("Invalid value for argument type");
    }

    public void setDestFile(File destFile) {
        this.destFile = destFile;
    }

    public void setServices(String services) {
        this.services = services;
    }

    public void setIncludeJars(boolean includeJars) {
        this.includeJars = includeJars;
    }

    /**
     * For jvmarg nested elements
     */
    public Commandline.Argument createJvmarg() {
        if (pxg == null) {
            pxg = new Java(this);
        }

        return pxg.getCommandLine().createVmArgument();
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    @Override
    public void execute() {
        if (projectDir == null) {
            throw new BuildException(Messages.getString("PCTProxygen.1")); //$NON-NLS-1$
        }
        if (this.type == null)
            throw new BuildException("Invalid value for argument type");

        checkDlcHome();

        // Creates a new Java task to launch proxygen task
        if (pxg == null) {
            pxg = new Java(this);
        }

        pxg.setFork(true);
        pxg.setJvm(getJVM().getAbsolutePath());
        pxg.setDir(this.getProject().getBaseDir());

        pxg.setClassname(PROXYGEN_CLASS);
        pxg.createClasspath().add(getRestGenClasspath(getProject()));

        Environment.Variable installDirVar = new Environment.Variable();
        installDirVar.setKey("Install.Dir"); //$NON-NLS-1$
        installDirVar.setValue(this.getDlcHome().toString());
        pxg.addSysproperty(installDirVar);

        Environment.Variable workDirVar = new Environment.Variable();
        workDirVar.setKey("Work.Dir"); //$NON-NLS-1$
        workDirVar.setValue(getProject().getBaseDir().getAbsolutePath());
        pxg.addSysproperty(workDirVar);

        Environment.Variable dlcVar = new Environment.Variable();
        dlcVar.setKey("DLC"); //$NON-NLS-1$
        dlcVar.setValue(this.getDlcHome().toString());
        pxg.addEnv(dlcVar);

        pxg.getCommandLine().createArgument().setValue("-proj");
        pxg.getCommandLine().createArgument().setValue(projectDir.getAbsolutePath());

        if ((type == RestGenerationType.REST_SERVICE_PAAR)
                || (type == RestGenerationType.REST_SERVICE_WAR)) {
            pxg.getCommandLine().createArgument().setValue("-restSvcNames");
        } else if ((type == RestGenerationType.MOBILE_SERVICE_PAAR)
                || (type == RestGenerationType.MOBILE_SERVICE_WAR)) {
            pxg.getCommandLine().createArgument().setValue("-mobSvcNames");
        } else {
            pxg.getCommandLine().createArgument().setValue("-mobApps");
        }
        pxg.getCommandLine().createArgument().setValue(services);

        pxg.getCommandLine().createArgument().setValue("-target");
        pxg.getCommandLine().createArgument().setValue(destFile.getAbsolutePath());

        if (!includeJars) {
            pxg.getCommandLine().createArgument().setValue("-includeJars");
            pxg.getCommandLine().createArgument().setValue("false");
        }

        pxg.getCommandLine().createArgument().setValue("-gen" + type.value);

        pxg.execute();
    }
}
