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

import java.io.File;
import java.util.List;

import org.apache.tools.ant.BuildException;

public class WSServerProcess extends PCTRun {
    private boolean webLogError = true;

    public WSServerProcess() {
        super(false, false);
    }

    @Override
    public void setProcedure(String procedure) {
        throw new BuildException(PCTBroker.UNKNOWN_ATTR);
    }

    @Override
    public void setGraphicalMode(boolean graphMode) {
        throw new BuildException(PCTBroker.UNKNOWN_ATTR);
    }

    @Override
    public void setDebugPCT(boolean debugPCT) {
        throw new BuildException(PCTBroker.UNKNOWN_ATTR);
    }

    @Override
    public void setBaseDir(File baseDir) {
        throw new BuildException(PCTBroker.UNKNOWN_ATTR);
    }

    @Override
    public void setFailOnError(boolean failOnError) {
        throw new BuildException(PCTBroker.UNKNOWN_ATTR);
    }

    public boolean isWebLogError() {
        return webLogError;
    }

    public void setWebLogError(boolean webLogError) {
        this.webLogError = webLogError;
    }

    protected List<String> getCmdLineParameters() {
        List<String> list = runAttributes.getCmdLineParameters();

        if (this.webLogError)
            list.add("-weblogerror");

        list.add("-p");
        list.add("web/objects/web-disp.p");

        for (PCTConnection conn : runAttributes.getDBConnections()) {
            list.addAll(conn.getConnectParametersList());
        }
        return list;
    }

    public String getPropath() {
        if (runAttributes.getPropath() == null)
            return "";

        StringBuilder propathList = new StringBuilder("");
        String[] lst = runAttributes.getPropath().list();
        for (int k = 0; k < lst.length; k++) {
            propathList.append(lst[k]);
            if (k < lst.length - 1)
                propathList.append(File.pathSeparatorChar);
        }
        return propathList.toString();
    }
}
