package com.phenix.pct;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.types.FileSet;
import org.apache.tools.ant.types.Path;

import eu.rssw.antlr.profiler.CoverageSession;
import eu.rssw.antlr.profiler.ProfilerUtils;

public class GenericCoverage extends Task {

    private FileSet profilerFiles;
    private File destFile;
    private Path propath;

    public void setDestFile(File destFile) {
        this.destFile = destFile;
    }
    public void addFileSet(FileSet fs) {
        this.profilerFiles = fs;
    }

    /**
     * Set the propath to be used when running the procedure
     * 
     * @param propath an Ant Path object containing the propath
     */
    public void addPropath(Path propath) {
        createPropath().append(propath);
    }

    /**
     * Creates a new Path instance
     * 
     * @return Path
     */
    public Path createPropath() {
        if (this.propath == null) {
            this.propath = new Path(this.getProject());
        }

        return this.propath;
    }

    @Override
    public void execute() throws BuildException {
        if ((profilerFiles == null) || (profilerFiles.size() == 0)) {
            log("No fileset defined, XML output will not be generated");
            return;
        }

        try {
            CoverageSession session = new CoverageSession();
            for (String str : profilerFiles.getDirectoryScanner(getProject()).getIncludedFiles()) {
                File resourceAsFile = new File(profilerFiles.getDir(getProject()), str);
                session.mergeWith(ProfilerUtils.getProfilerSession(resourceAsFile).getCoverage());
            }
            Collection<File> path = new ArrayList<File>();
            for (String str : propath.list()) {
                path.add(getProject().resolveFile(str));
            }
            ProfilerUtils.dumpCoverageAsXml(session, path, destFile);
        } catch (IOException caught) {
            throw new BuildException(caught);
        }
    }
}
