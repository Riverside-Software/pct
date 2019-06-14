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

import java.util.MissingResourceException;
import java.util.ResourceBundle;

public class ProgressV11 implements ProgressProcedures {
    private static final String BUNDLE_NAME = "com.phenix.pct.ProgressV11"; //$NON-NLS-1$
    private static final ResourceBundle RESOURCE_BUNDLE = ResourceBundle.getBundle(BUNDLE_NAME);

    @Override
    public String getCompileProcedure() {
        return "pct/pctCompile.p";
    }

    @Override
    public String getDynamicRunProcedure() {
        return "pct/v11/dynrun.p";
    }

    @Override
    public String getIncrementalProcedure() {
        return "pct/v11/silentIncDump.p";
    }

    @Override
    public String getDumpUsersProcedure() {
        return "pct/v11/dmpUsers.p";
    }

    @Override
    public String getLoadUsersProcedure() {
        return "pct/v11/loadUsers.p";
    }

    @Override
    public String getLoadSchemaProcedure() {
        return "pct/loadSch.p";
    }

    @Override
    public String getLoadMultipleTablesDataProcedure() {
        return "pct/loadData1.p";
    }

    @Override
    public String getLoadSingleTableDataProcedure() {
        return "pct/v11/loadData2.p";
    }

    @Override
    public String getInitString() {
        return getString("ProgressV11.0"); //$NON-NLS-1$
    }

    @Override
    public String getSuperInitString() {
        return getString("ProgressV11.13"); //$NON-NLS-1$
    }

    @Override
    public String getConnectString() {
        return getString("ProgressV11.1"); //$NON-NLS-1$
    }

    @Override
    public String getAliasString() {
        return getString("ProgressV11.2"); //$NON-NLS-1$
    }

    @Override
    public String getDBAliasString() {
        return getString("ProgressV11.15"); //$NON-NLS-1$
    }

    @Override
    public String getPropathString() {
        return getString("ProgressV11.3"); //$NON-NLS-1$
    }

    @Override
    public String getRunString() {
        return getString("ProgressV11.4"); //$NON-NLS-1$
    }

    @Override
    public String getReturnProc() {
        return getString("ProgressV11.5"); //$NON-NLS-1$
    }

    @Override
    public String getParameterString() {
        return getString("ProgressV11.6"); //$NON-NLS-1$
    }

    @Override
    public String getOutputParameterDeclaration() {
        return getString("ProgressV11.8"); //$NON-NLS-1$
    }

    @Override
    public String getOutputParameterProc() {
        return getString("ProgressV11.9"); //$NON-NLS-1$
    }

    @Override
    public String getAfterRun() {
        return getString("ProgressV11.10"); //$NON-NLS-1$
    }

    @Override
    public String getOutputParameterCall() {
        return getString("ProgressV11.11"); //$NON-NLS-1$
    }

    @Override
    public String getQuit() {
        return getString("ProgressV11.12"); //$NON-NLS-1$
    }

    @Override
    public String getCallbackString() {
        return getString("ProgressV11.14"); //$NON-NLS-1$
    }

    @Override
    public String getXCodeSessionKey() {
        return getString("ProgressV11.16"); //$NON-NLS-1$
    }

    public String getString(String key) {
        try {
            return RESOURCE_BUNDLE.getString(key);
        } catch (MissingResourceException e) {
            return '!' + key + '!';
        }
    }

}
