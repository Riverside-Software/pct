/**
 * Copyright 2005-2025 Riverside Software
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
import java.io.IOException;
import java.nio.file.Files;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.apache.tools.ant.Project;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.types.FileSet;
import org.apache.tools.ant.types.Path;
import org.apache.tools.ant.types.Path.PathElement;
import org.eclipse.aether.RepositoryException;

import com.google.gson.GsonBuilder;

import eu.rssw.openedge.ls.IDependencyResolver.LocalDependency;
import eu.rssw.openedge.ls.OpenEdgeDependencyResolver;
import eu.rssw.openedge.ls.mapping.ProjectConfigFile;
import eu.rssw.openedge.ls.mapping.ProjectConfigFile.Dependency;

public class PCTDependencies extends Task {
    private String projectName;
    private Map<LocalDependency, java.nio.file.Path> dependencyHash;
    private OpenEdgeDependencyResolver resolver;

    // Task attributes
    private File srcFile;
    private String pathId = "";
    private File assemblyPath = null;

    /**
     * Path to openedge-project.json
     */
    public void setSrcFile(File srcFile) {
        this.srcFile = srcFile;
    }

    /**
     * Path reference name
     */
    public void setPathId(String pathRefName) {
        this.pathId = pathRefName;
    }

    /**
     * Path to assemblies.xml and assemblies.config
     */
    public void setAssemblies(File assemblyPath) {
        this.assemblyPath = assemblyPath;
    }

    @Override
    public void execute() {
        List<LocalDependency> resolvedDependencies = new ArrayList<>();
        dependencyHash = new HashMap<>();
        projectName = getProject().getName();
        resolver = new OpenEdgeDependencyResolver();

        if (srcFile == null)
            srcFile = new File(getProject().getBaseDir(), "openedge-project.json");
        log(MessageFormat.format(Messages.getString("PCTDependencies.0"), srcFile),
                Project.MSG_VERBOSE);

        // list dependencies
        try (BufferedReader reader = Files.newBufferedReader(srcFile.toPath())) {
            ProjectConfigFile config = new GsonBuilder().create().fromJson(reader,
                    ProjectConfigFile.class);
            if ((config != null) && (config.dependencies != null)) {
                for (Dependency dep : config.dependencies) {
                    if (dep == null)
                        continue;
                    log(MessageFormat.format(Messages.getString("PCTDependencies.1"), dep.groupId,
                            dep.artifactId, dep.extension,
                            dep.classifier == null ? "" : dep.classifier,
                            dep.version == null ? "" : dep.version), Project.MSG_INFO);
                    File dlFile = resolver.downloadArtifact(dep.groupId, dep.artifactId,
                            dep.version, dep.classifier, dep.extension);
                    LocalDependency locDependency = new LocalDependency(dep.groupId, dep.artifactId,
                            dep.version, dep.classifier, dep.extension, dlFile);
                    resolvedDependencies.add(locDependency);
                }
            }
        } catch (IOException | RepositoryException caught) {
            log(MessageFormat.format(Messages.getString("PCTDependencies.2"), caught),
                    Project.MSG_ERR);
        }

        try {
            Path path = processArtifacts(resolvedDependencies);
            getProject().addReference(pathId, path);
            log("Dependencies propath created: " + path, Project.MSG_DEBUG);
        } catch (IOException e) {
            log(MessageFormat.format(Messages.getString("PCTDependencies.3"), e),
                    Project.MSG_ERR);
        }

        writeAssemblyConfig(resolvedDependencies);
    }

    private void writeAssemblyConfig(List<LocalDependency> resolvedDependencies) {
        String fullPath = resolvedDependencies.stream() //
                .filter(it -> "assembly".equals(it.classifier())) //
                .map(it -> dependencyHash.get(it).toString()) //
                .collect(Collectors.joining(";"));
        File parentDir = assemblyPath == null ? getProject().getBaseDir() : assemblyPath;
        File assembliesConfigPath = new File(parentDir, "assemblies.config");
        if (!fullPath.isEmpty()) {
            resolver.writeAssembliesConfig(assembliesConfigPath.toPath(), fullPath, projectName);
        }
    }

    private Path processArtifacts(List<LocalDependency> resolvedDependencies) throws IOException {
        File dotDir = new File(getProject().getBaseDir(), ".dependencies");
        Files.createDirectories(dotDir.toPath());

        Path path = new Path(getProject());
        for (LocalDependency dep : resolvedDependencies) {
            java.nio.file.Path extractPath = resolver.processArtifact(dep, dotDir.toPath(),
                    projectName);
            if (extractPath != null) {
                log(MessageFormat.format(Messages.getString("PCTDependencies.4"),
                        dep.localFile().getAbsolutePath(), extractPath), Project.MSG_INFO);
                dependencyHash.put(dep, extractPath);
            }

            if (dep.classifier() == null) {
                if ("zip".equals(dep.extension()) && extractPath != null) {
                    FileSet fs = new FileSet();
                    fs.setDir(extractPath.toFile());
                    fs.setIncludes("*.pl,*.apl");
                    path.add(fs);

                    PathElement pathElement = path.new PathElement();
                    pathElement.setLocation(extractPath.toFile());
                    path.add(pathElement);
                } else if ("pl".equals(dep.extension()) || "apl".equals(dep.extension())) {
                    PathElement pathElement = path.new PathElement();
                    pathElement.setLocation(dep.localFile());
                    path.add(pathElement);
                }
            }
        }

        return path;
    }
}
