/*
 * Copyright  2000-2004 The Apache Software Foundation
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

package eu.rssw.pct.oedoc;

import java.io.File;

import org.apache.tools.ant.BuildException;

import com.phenix.pct.Messages;
import com.phenix.pct.PCTRun;
import com.phenix.pct.RunParameter;

/**
 * Class for generating HTML documentation from XML documentation
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class OpenEdgeHTMLDocumentation extends PCTRun {
    private File destDir = null;
    private File sourceDir = null;
    private File templateDir = null;

    public OpenEdgeHTMLDocumentation() {
        super();
    }

    /**
     * Destination directory
     * 
     * @param destFile Directory
     */
    public void setDestDir(File dir) {
        this.destDir = dir;
    }

    public void setSourceDir(File sourceDir) {
        this.sourceDir = sourceDir;
    }

    public void setTemplateDir(File templateDir) {
        this.templateDir = templateDir;
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    public void execute() throws BuildException {
        checkDlcHome();

        // Destination directory must exist
        if (this.destDir == null) {
            throw new BuildException(Messages.getString("OpenEdgeClassDocumentation.0"));
        }
        if (this.sourceDir == null) {
            throw new BuildException(Messages.getString("OpenEdgeClassDocumentation.0"));
        }
        if (this.templateDir == null) {
            throw new BuildException(Messages.getString("OpenEdgeClassDocumentation.0"));
        }

        try {
            setProcedure("ConsultingWerk/studio/generate-class-reference.p"); //$NON-NLS-1$
            addParameter(new RunParameter("TargetDir", destDir.getAbsolutePath()));
            addParameter(new RunParameter("SourceDir", sourceDir.getAbsolutePath()));
            addParameter(new RunParameter("TemplateSourceDir", templateDir.getAbsolutePath()));
            super.execute();
            cleanup();
        } catch (BuildException be) {
            cleanup();
            throw be;
        }
    }

}