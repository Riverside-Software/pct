package com.phenix.pct;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.apache.tools.ant.Project;
import org.apache.tools.ant.types.FileSet;

/**
 * Commodity fileset to include every source code from a set of subdirectories (for compilation), or
 * every rcode from a set of subdirectories (for libraries)
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class OpenEdgeFileSet {
    private final static String SUBDIRS = "/**";

    private File baseDir = null;
    private List<Module> moduleList = new ArrayList<Module>();
    private boolean includeSubDirs = true;
    private String modules = null;
    private String excludes = null;

    public void setBaseDir(File baseDir) {
        this.baseDir = baseDir;
    }

    public void setModules(String modules) {
        this.modules = modules;
    }

    public void setExcludes(String excludes) {
        this.excludes = excludes;
    }

    public void addConfiguredModule(Module module) {
        moduleList.add(module);
    }

    public void setIncludeSubDirs(boolean includeSubDirs) {
        this.includeSubDirs = includeSubDirs;
    }

    protected FileSet getCompilationFileSet(Project project) {
        FileSet fs = new FileSet();
        fs.setProject(project);
        fs.setDir(baseDir);

        StringBuffer sb = new StringBuffer();
        if (modules != null) {
            for (String str : modules.split(",")) {
                if (sb.length() > 0) {
                    sb.append(',');
                }
                sb.append(str + (includeSubDirs ? SUBDIRS : "") + "/*.p,");
                sb.append(str + (includeSubDirs ? SUBDIRS : "") + "/*.w,");
                sb.append(str + (includeSubDirs ? SUBDIRS : "") + "/*.cls");

            }
        }
        for (Module m : moduleList) {
            if (sb.length() > 0) {
                sb.append(',');
            }
            sb.append(m.getName() + (includeSubDirs ? SUBDIRS : "") + "/*.p,");
            sb.append(m.getName() + (includeSubDirs ? SUBDIRS : "") + "/*.w,");
            sb.append(m.getName() + (includeSubDirs ? SUBDIRS : "") + "/*.cls");
        }
        fs.setIncludes(sb.toString());

        if (excludes != null) {
            fs.setExcludes(excludes);
        }

        return fs;
    }

    protected FileSet getLibraryFileSet(Project project) {
        FileSet fs = new FileSet();
        fs.setProject(project);
        fs.setDir(baseDir);

        StringBuffer sb = new StringBuffer();
        for (String str : modules.split(",")) {
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

    public static class Module {
        private String name;

        public void setName(String name) {
            this.name = name;
        }

        public String getName() {
            return name;
        }
    }
}
