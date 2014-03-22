package com.phenix.pct;

import java.io.File;

import org.apache.tools.ant.Project;
import org.apache.tools.ant.types.FileSet;

/**
 * Commodity fileset to include every source code from a set of subdirectories (for compilation), or
 * every rcode from a set of subdirectories (for libraries)
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class OpenEdgeFileSet {
    private File baseDir = null;
    private String subdirs = null;
    private String excludes = null;

    public void setBaseDir(File baseDir) {
        this.baseDir = baseDir;
    }

    public void setSubdirs(String subdirs) {
        this.subdirs = subdirs;
    }

    public void setExcludes(String excludes) {
        this.excludes = excludes;
    }

    protected FileSet getCompilationFileSet(Project project) {
        FileSet fs = new FileSet();
        fs.setProject(project);
        fs.setDir(baseDir);

        StringBuffer sb = new StringBuffer();
        for (String str : subdirs.split(",")) {
            if (sb.length() > 0) {
                sb.append(',');
            }
            sb.append(str + "/**/*.p," + str + "/**/*.w," + str + "/**/*.cls");
        }
        fs.setIncludes(sb.toString());

        if (excludes != null)
            fs.setExcludes(excludes);

        return fs;
    }

    protected FileSet getLibraryFileSet(Project project) {
        FileSet fs = new FileSet();
        fs.setProject(project);
        fs.setDir(baseDir);

        StringBuffer sb = new StringBuffer();
        for (String str : subdirs.split(",")) {
            if (sb.length() > 0) {
                sb.append(',');
            }
            sb.append(str + "/**/*.r");
        }
        fs.setIncludes(sb.toString());

        if (excludes != null)
            fs.setExcludes(excludes);

        return fs;
    }

}
