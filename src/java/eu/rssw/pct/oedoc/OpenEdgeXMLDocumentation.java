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
package eu.rssw.pct.oedoc;

import java.io.File;
import java.text.MessageFormat;

import org.apache.tools.ant.BuildException;

import com.phenix.pct.Messages;
import com.phenix.pct.PCTRun;
import com.phenix.pct.RunParameter;

/**
 * Class for generating HTML documentation from XML documentation
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class OpenEdgeXMLDocumentation extends PCTRun {
    private File destFile = null;
    private File sourceDir = null;

    public OpenEdgeXMLDocumentation() {
        super();
    }

    /**
     * Destination directory
     */
    public void setDestFile(File file) {
        this.destFile = file;
    }

    public void setSourceDir(File sourceDir) {
        this.sourceDir = sourceDir;
    }

    /**
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    @Override
    public void execute() {
        checkDlcHome();

        // Destination directory must exist
        if (destFile == null) {
            throw new BuildException(MessageFormat.format(
                    Messages.getString("OpenEdgeXmlDocumentation.0"), "destFile"));
        }
        // And source directory too
        if (sourceDir == null) {
            throw new BuildException(MessageFormat.format(
                    Messages.getString("OpenEdgeXmlDocumentation.0"), "sourceDir"));
        }

        log("Generating XML documentation for " + sourceDir.getAbsolutePath() + " to " + destFile.getAbsolutePath());
        try {
            setProcedure("Consultingwerk/Studio/SmartDox/generate-class-documentation.p"); //$NON-NLS-1$
            addParameter(new RunParameter("TargetFile", destFile.getAbsolutePath())); //$NON-NLS-1$
            addParameter(new RunParameter("SourceDir", sourceDir.getAbsolutePath())); //$NON-NLS-1$
            super.execute();
            cleanup();
        } catch (BuildException be) {
            cleanup();
            throw be;
        }
    }
}