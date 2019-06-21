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
package net.cordova.prounit;

import java.io.File;
import java.text.MessageFormat;

import org.apache.tools.ant.BuildException;

import com.phenix.pct.Messages;
import com.phenix.pct.PCTRun;

/**
 * Ant task for ProUnit tests. For more details about ProUnit, see <a
 * href="http://sourceforge.net/projects/prounit/">the SourceForge project's page</a> or <a
 * href="http://prounit.sourceforge.net/">ProUnit's website</a>.
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET</a>
 * @version $Revision$
 */
public class ProUnit extends PCTRun {
    private File xmlProject;
    private File result;
    private String template;
    private boolean compatibility = false;

    /**
     * Path to the XML file saved using ProUnit GUI version.
     * 
     * @param project Mandatory
     */
    public void setProject(File project) {
        this.xmlProject = project;
    }

    /**
     * Path to the resulting execution file (XML).
     * 
     * @param result Optional
     */
    public void setResult(File result) {
        this.result = result;
    }

    /**
     * Template used to format the result file.
     * 
     * @param template Optional
     */
    public void setTemplate(String template) {
        this.template = template;
    }

    /**
     * Configures compatibility mode for older version of prounit
     */
    public void setCompatibility(boolean compatibility) {
        this.compatibility = compatibility;
    }

    @Override
    public void execute() {
        // This parameter is mandatory (to get a return-value)
        StringBuilder sb = new StringBuilder("-runningAnt=true");
        String proc = "startProUnitBatch.p";

        if ((xmlProject == null) || !xmlProject.isFile()) {
            throw new BuildException(MessageFormat.format(
                    Messages.getString("ProUnit.0"), "project")); //$NON-NLS-1$ //$NON-NLS-2$
        } else {
            sb.append(" -projectFile=").append(xmlProject);
        }

        if (result != null) {
            sb.append(" -resultFile=").append(result);
        }

        if (template != null) {
            sb.append(" -resultTemplate=").append(template);
        }

        // Use a different procedure for older versions of prounit
        if (compatibility)
            proc = "batchRunner.p";

        this.setProcedure(proc); //$NON-NLS-1$
        this.setParameter(sb.toString());

        super.execute();
    }
}
