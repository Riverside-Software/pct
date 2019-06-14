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

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.DefaultExcludes;

public class DlcHome extends Task {
    public static final String GLOBAL_DLCHOME = "__DLC_HOME__";

    private File value = null;

    @Override
    public void execute() {
        if (value == null)
            throw new BuildException("Value can't be null");
        getProject().setProperty(GLOBAL_DLCHOME, value.getAbsolutePath());

        DefaultExcludes excludes = new DefaultExcludes();
        excludes.bindToOwner(this);
        excludes.setAdd("/.pct/**");
        excludes.execute();
    }

    public void setValue(File file) {
        this.value = file;
    }

}
