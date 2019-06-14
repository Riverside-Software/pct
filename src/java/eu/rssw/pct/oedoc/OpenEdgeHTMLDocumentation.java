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
import java.io.IOException;
import java.net.URL;
import java.net.URLDecoder;
import java.text.MessageFormat;
import java.util.Enumeration;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;

import org.apache.tools.ant.BuildException;

import com.phenix.pct.Messages;
import com.phenix.pct.PCT;
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
    private File services = null;
    private String title = "Class reference";
    private boolean treeViewOverview = true;
    private boolean preloadClasses = true;

    // Internal use
    private boolean tempTmplDir = false;

    public OpenEdgeHTMLDocumentation() {
        super();
    }

    /**
     * Destination directory
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

    public void setServices(File services) {
        this.services = services;
    }

    public void setTreeViewOverview(boolean treeViewOverview) {
        this.treeViewOverview = treeViewOverview;
    }

    public void setPreloadClasses(boolean preloadClasses) {
        this.preloadClasses = preloadClasses;
    }

    public void setTitle(String title) {
        this.title = title;
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
        if (destDir == null) {
            throw new BuildException(MessageFormat.format(
                    Messages.getString("OpenEdgeClassDocumentation.0"), "destDir"));
        }
        if (!createDir(destDir)) {
            throw new BuildException("Unable to create destination directory");
        }
        // And source directory too
        if (sourceDir == null) {
            throw new BuildException(MessageFormat.format(
                    Messages.getString("OpenEdgeClassDocumentation.0"), "sourceDir"));
        }
        // Template directory is optional. If not set, then extract the template directory from
        // PCT.jar
        if (templateDir == null) {
            tempTmplDir = true;
            int tempDirNum = PCT.nextRandomInt();
            templateDir = new File(System.getProperty(PCT.TMPDIR), "Templates" + tempDirNum); //$NON-NLS-1$ //$NON-NLS-2$
            templateDir.mkdirs();
            new File(destDir, "resources").mkdir();
            try {
                extractTemplateDirectory(templateDir, destDir);
            } catch (IOException caught) {
                throw new BuildException(caught);
            }
        }

        log("Generating HTML documentation for " + sourceDir.getAbsolutePath());
        try {
            setProcedure("Consultingwerk/Studio/ClassDocumentation/generate-class-reference.p"); //$NON-NLS-1$
            addParameter(new RunParameter("TargetDir", destDir.getAbsolutePath())); //$NON-NLS-1$
            addParameter(new RunParameter("SourceDir", sourceDir.getAbsolutePath())); //$NON-NLS-1$
            addParameter(new RunParameter("TemplateSourceDir", templateDir.getAbsolutePath())); //$NON-NLS-1$
            addParameter(new RunParameter("Title", title)); //$NON-NLS-1$
            addParameter(new RunParameter(
                    "GenerateTreeViewOverview", Boolean.toString(treeViewOverview))); //$NON-NLS-1$
            addParameter(new RunParameter("PreloadClasses", Boolean.toString(preloadClasses))); //$NON-NLS-1$
            if (services != null) {
                addParameter(new RunParameter("Services", services.getAbsolutePath())); //$NON-NLS-1$
            }
            super.execute();
            cleanup();
        } catch (BuildException be) {
            cleanup();
            throw be;
        }
    }

    private void extractTemplateDirectory(File templateDir, File outputDir) throws IOException {
        URL url = getClass().getClassLoader().getResource(
                getClass().getName().replace(".", "/") + ".class");
        String jarPath = url.getPath().substring(5, url.getPath().indexOf('!'));

        try (JarFile jar = new JarFile(URLDecoder.decode(jarPath, "UTF-8"))) {
            Enumeration<JarEntry> entries = jar.entries();
            while (entries.hasMoreElements()) {
                JarEntry entry = entries.nextElement();
                if (entry.isDirectory())
                    continue;
                if (entry.getName().startsWith("templates/")
                        && entry.getName().endsWith(".template")) {
                    copyStreamFromJar("/" + entry.getName(),
                            new File(templateDir, entry.getName().substring(10)));
                }
                if (entry.getName().startsWith("templates/resources")) {
                    copyStreamFromJar("/" + entry.getName(),
                            new File(outputDir, entry.getName().substring(10)));
                }
            }
        }
    }

    @Override
    protected void cleanup() {
        super.cleanup();

        if (getDebugPCT())
            return;
        if (tempTmplDir)
            deleteFile(templateDir);
    }
}
