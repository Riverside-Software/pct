/**
 * Copyright 2017-2024 MIP Holdings
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
package za.co.mip.ablduck;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.text.Format;
import java.text.MessageFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.types.FileSet;
import org.apache.tools.ant.types.Path;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.openedge.core.metadata.DataTypes;
import com.openedge.core.metadata.IDataType;
import com.openedge.core.runtime.IPropath;
import com.openedge.core.runtime.Propath;
import com.openedge.pdt.core.ast.ASTManager;
import com.openedge.pdt.core.ast.IASTManager;
import com.openedge.pdt.core.ast.PropathASTContext;
import com.openedge.pdt.core.ast.model.IASTContext;
import com.openedge.pdt.core.ast.model.ICompilationUnit;
import com.phenix.pct.Messages;
import com.phenix.pct.PCT;
import com.phenix.pct.Version;

import za.co.mip.ablduck.models.Cls;
import za.co.mip.ablduck.models.CompilationUnit;
import za.co.mip.ablduck.models.Data;
import za.co.mip.ablduck.models.Member;
import za.co.mip.ablduck.models.Parameter;
import za.co.mip.ablduck.models.Procedure;
import za.co.mip.ablduck.models.Search;

/**
 * Class for generating ABLDuck documentation from OpenEdge classes
 * 
 * @author <a href="mailto:robertedwardsmail@gmail.com">Robert Edwards</a>
 */
public class ABLDuck extends PCT {
    private static final int BUFFER_SIZE = 4096;
    private static final String ICON_PREFIX = "icon-";

    private Data data = new Data();
    private HashMap<String, CompilationUnit> classes = new HashMap<>();
    private HashMap<String, CompilationUnit> procedures = new HashMap<>();
    private String title = "ABLDuck documentation";
    private File destDir = null;
    private File destDirOutput = null;
    private Boolean dataFilesOnly = false;
    private List<FileSet> filesets = new ArrayList<>();
    protected Path propath = null;
    private String encoding = null;
    private Charset inputCharset = null;
    private File template = null;
    private File customLink = null;
    private boolean includeCommentsAfterNode = false;

    public ABLDuck() {
        super();
        createPropath();
    }

    /**
     * Adds a set of files to archive.
     * 
     * @param set FileSet
     */
    public void addFileset(FileSet set) {
        filesets.add(set);
    }

    public void setLegacyMode(boolean legacyMode) {
        this.includeCommentsAfterNode = legacyMode;
    }

    /**
     * Destination directory
     */
    public void setDestDir(File dir) {
        this.destDir = dir;
        this.destDirOutput = new File(dir, "output");
    }

    /**
     * Documentation title
     * 
     * @param title Documentation title
     */
    public void setTitle(String title) {
        this.title = title;
    }

    /**
     * Codepage to use when reading files
     * 
     * @param encoding String
     */
    public void setEncoding(String encoding) {
        this.encoding = encoding;
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

    /**
     * Generate the data files only
     * 
     * @param dataOnly Generate only the data files, wont extract the template
     */
    public void setDataFilesOnly(Boolean dataOnly) {
        this.dataFilesOnly = dataOnly;
    }

    /**
     * Set the template directory or zip (if null, we use default template)
     * 
     * @param template directory of template file
     */
    public void setTemplate(File template) {
        this.template = template;
    }

    /**
     * Set a customLink File
     * 
     * @param customLink customLinkFile
     */
    public void setCustomLink(File customLink) {
        this.customLink = customLink;
    }

    @Override
    public void execute() {

        // Destination directory must exist
        if (this.destDir == null) {
            throw new BuildException(MessageFormat
                    .format(Messages.getString("OpenEdgeClassDocumentation.0"), "destDir"));
        }
        // There must be at least one fileset
        if (filesets.isEmpty()) {
            throw new BuildException(Messages.getString("OpenEdgeClassDocumentation.1"));
        }

        this.destDirOutput.mkdirs();

        if (!this.dataFilesOnly) {
            // Extract template
            try {
                if (template != null && this.template.isDirectory()) {
                    copyFullRecursive(this.template, this.destDir);
                } else if (this.template != null && this.template.isFile()) {
                    unzip(new FileInputStream(this.template), this.destDir);
                } else {
                    extractTemplateDirectory(this.destDir);
                }

                // CustomLinkFile
                String vCustomLink = "resources/customlink.js";
                if (this.customLink != null && this.customLink.isFile()) {
                    vCustomLink = this.customLink.getName();
                    copyFullRecursive(this.customLink, new File(this.destDir, vCustomLink));
                }

                Format formatter = new SimpleDateFormat("EEE d MMM yyyy HH:mm:ss");
                List<String> files = Arrays.asList("index.html"); // , "template.html",
                                                                  // "print-template.html"

                for (String file : files) {
                    replaceTemplateTags("{title}", this.title,
                            Paths.get(this.destDir.getAbsolutePath(), file));
                    replaceTemplateTags("{version}", Version.getPCTVersion(),
                            Paths.get(this.destDir.getAbsolutePath(), file));
                    replaceTemplateTags("{date}", formatter.format(new Date()),
                            Paths.get(this.destDir.getAbsolutePath(), file));
                    replaceTemplateTags("{customLinkFile}", vCustomLink,
                            Paths.get(this.destDir.getAbsolutePath(), file));
                }
            } catch (IOException ex) {
                throw new BuildException(ex);
            }
        }

        Gson gson = new GsonBuilder().excludeFieldsWithoutExposeAnnotation().create();

        IPropath pp = new Propath(
                new org.eclipse.core.runtime.Path(getProject().getBaseDir().getAbsolutePath()),
                propath.list());
        IASTContext astContext = new PropathASTContext(pp);
        IProgressMonitor monitor = new NullProgressMonitor();
        IASTManager astMgr = ASTManager.getASTManager();

        log("Generating ABLDuck documentation (11.5+ method)", Project.MSG_INFO);

        for (FileSet fs : filesets) {
            // And get files from fileset
            String[] dsfiles = fs.getDirectoryScanner(this.getProject()).getIncludedFiles();

            for (int i = 0; i < dsfiles.length; i++) {
                File file = new File(fs.getDir(this.getProject()), dsfiles[i]);
                log("Generating AST for " + file.getAbsolutePath(), Project.MSG_VERBOSE);

                int extPos = file.getName().lastIndexOf('.');
                String ext = file.getName().substring(extPos);
                boolean isClass = ".cls".equalsIgnoreCase(ext);

                try (InputStream input = new FileInputStream(file);
                        Reader fsr = new InputStreamReader(input, getCharset())) {
                    ICompilationUnit root = astMgr.createAST(fsr, astContext, monitor,
                            IASTManager.EXPAND_ON, IASTManager.DLEVEL_FULL);
                    if (isClass) {
                        ABLDuckClassVisitor visitor = new ABLDuckClassVisitor(pp, includeCommentsAfterNode);
                        log("Executing AST ClassVisitor " + file.getAbsolutePath(),
                                Project.MSG_VERBOSE);
                        root.accept(visitor);

                        CompilationUnit cu = visitor.getCompilationUnit();
                        classes.put(cu.name, cu);
                    } else {

                        ABLDuckProcedureVisitor visitor = new ABLDuckProcedureVisitor(dsfiles[i]);
                        log("Executing AST ProcedureVisitor " + file.getAbsolutePath(),
                                Project.MSG_VERBOSE);
                        root.accept(visitor);

                        CompilationUnit cu = visitor.getCompilationUnit();
                        procedures.put(cu.name, cu);
                    }
                } catch (IOException e) {
                    log(e.getMessage(), Project.MSG_WARN);
                }
            }
        }

        // Procedures search objects
        for (Map.Entry<String, CompilationUnit> procedureEntry : procedures.entrySet()) {
            CompilationUnit cu = procedureEntry.getValue();
            createSearch(cu);

            Procedure procedure = new Procedure();
            procedure.name = cu.name;
            procedure.icon = ICON_PREFIX + cu.icon;

            data.procedures.add(procedure);

            if (cu.uses != null && !cu.uses.isEmpty()) {
                for (Member member : cu.members) {
                    if (member.datatype != null)
                        member.datatype = determineFullyQualifiedClassName(cu.uses,
                                member.datatype);

                    if (member.returns != null)
                        member.returns.datatype = determineFullyQualifiedClassName(cu.uses,
                                member.returns.datatype);

                    if (member.parameters != null) {
                        for (Parameter parameter : member.parameters) {
                            parameter.datatype = determineFullyQualifiedClassName(cu.uses,
                                    parameter.datatype);
                        }
                    }
                }
            }
        }

        // Determine class hierarchy, subclasses and search objects
        for (Map.Entry<String, CompilationUnit> classEntry : classes.entrySet()) {
            CompilationUnit cu = classEntry.getValue();

            createSearch(cu);

            Cls cls = new Cls();
            cls.name = cu.name;
            // Set FullName for inherts classes
            cls.inherits = determineFullyQualifiedClassName(cu.uses, cu.inherits);
            if (!cu.inherits.equals(cls.inherits)) {
                cu.inherits = cls.inherits;
            }
            cls.icon = ICON_PREFIX + cu.icon;

            data.classes.add(cls);

            // Subclasses
            for (Map.Entry<String, CompilationUnit> subclassEntry : classes.entrySet()) {
                CompilationUnit subclass = subclassEntry.getValue();
                if ("class".equals(subclass.tagname) && cu.name
                        .equals(determineFullyQualifiedClassName(subclass.uses, subclass.inherits)))
                    cu.subclasses.add(subclass.name);
            }

            // Add implementers to the interface
            if (cu.implementations != null && !cu.implementations.isEmpty()) {
                // TempList to avoid conflict
                List<String> listNewImplement = new ArrayList<>();
                Iterator<String> iter = cu.implementations.iterator();

                while (iter.hasNext()) {
                    String currentImplement = iter.next();
                    String fullInterfacePath = determineFullyQualifiedClassName(cu.uses,
                            currentImplement);
                    CompilationUnit iface = classes.get(fullInterfacePath);
                    if (iface != null) {
                        iface.implementers.add(cu.name);
                        // Set FullName for implemented interfaces
                        if (!currentImplement.equals(fullInterfacePath)) {
                            iter.remove();
                            listNewImplement.add(iface.name);
                        }
                    }
                }
                // Adding the Full implement name
                if (!listNewImplement.isEmpty()) {
                    cu.implementations.addAll(listNewImplement);
                }
            }

            // Hierarchy
            HierarchyResult result = new HierarchyResult();
            result = determineClassHierarchy(cu, result);

            List<String> hierarchy = result.getHierarchy();
            Collections.reverse(hierarchy);
            cu.superclasses.addAll(hierarchy);
            cu.superclasses.add(cu.name);

            cu.members.addAll(result.getInheritedmembers());

            if (cu.uses != null && !cu.uses.isEmpty()) {
                for (Member member : cu.members) {
                    if (member.datatype != null)
                        member.datatype = determineFullyQualifiedClassName(cu.uses,
                                member.datatype);

                    if (member.returns != null)
                        member.returns.datatype = determineFullyQualifiedClassName(cu.uses,
                                member.returns.datatype);

                    if (member.parameters != null) {
                        for (Parameter parameter : member.parameters) {
                            parameter.datatype = determineFullyQualifiedClassName(cu.uses,
                                    parameter.datatype);
                        }
                    }
                }
            }

        }

        // Write class js files out
        for (Map.Entry<String, CompilationUnit> cuEntry : classes.entrySet()) {
            CompilationUnit cu = cuEntry.getValue();

            File baseDir = new File(this.destDirOutput, "classes");

            if (!baseDir.exists()) {
                baseDir.mkdirs();
            }

            File outputFile = new File(baseDir, cu.name + ".js");
            try (OutputStreamWriter file = new OutputStreamWriter(
                    new FileOutputStream(outputFile.toString()), StandardCharsets.UTF_8)) {
                file.write("Ext.data.JsonP." + cu.name.replace(".", "_") + "(" + gson.toJson(cu)
                        + ");");
            } catch (IOException ex) {
                throw new BuildException(ex);
            }
        }

        // Write procedure js files out
        for (Map.Entry<String, CompilationUnit> procedureEntry : procedures.entrySet()) {
            CompilationUnit cu = procedureEntry.getValue();

            File baseDir = new File(this.destDirOutput, "procedures");

            if (!baseDir.exists()) {
                baseDir.mkdirs();
            }

            String filename = cu.name.replace(".", "_").replace("/", "_");
            File outputFile = new File(baseDir, filename + ".js");
            try (OutputStreamWriter file = new OutputStreamWriter(
                    new FileOutputStream(outputFile.toString()), StandardCharsets.UTF_8)) {
                file.write("Ext.data.JsonP." + filename + "(" + gson.toJson(cu) + ");");
            } catch (IOException ex) {
                throw new BuildException(ex);
            }
        }

        File dataFile = new File(this.destDir, "data.js");
        try (FileWriter file = new FileWriter(dataFile.toString())) {
            file.write("Docs = {\"data\":" + gson.toJson(data) + "}");
        } catch (IOException ex) {
            throw new BuildException(ex);
        }
    }

    private HierarchyResult determineClassHierarchy(CompilationUnit curClass,
            HierarchyResult result) {

        String inherits = curClass.inherits;

        if (!"".equals(inherits)) {
            inherits = determineFullyQualifiedClassName(curClass.uses, inherits);
            result.addHierarchy(inherits);

            CompilationUnit nextClass = classes.get(inherits);

            if (nextClass != null) {
                for (Member member : nextClass.members) {
                    if (inherits.equals(member.owner) && member.meta.isPrivate == null) {
                        // Happy with a shallow copy here
                        Member inheritedMember = new Member(member);

                        inheritedMember.id = inheritedMember.id.replace(
                                inheritedMember.tagname + "-" + inheritedMember.name,
                                inheritedMember.tagname + "-"
                                        + inheritedMember.owner.replace(".", "_") + "_"
                                        + inheritedMember.name);
                        result.addInheritedmember(inheritedMember);
                    }
                }

                determineClassHierarchy(nextClass, result);
            }
        }
        return result;
    }

    private void copyFullRecursive(File src, File dest) throws IOException {
        if (src.isDirectory()) {
            if (!dest.exists()) {
                dest.mkdirs();
            }

            File[] list = src.listFiles();
            for (File fic : list) {
                copyFullRecursive(fic, new File(dest, fic.getName()));
            }
        } else {
            Files.copy(src.toPath(), dest.toPath(), StandardCopyOption.REPLACE_EXISTING);
        }
    }

    private void extractTemplateDirectory(File outputDir) throws IOException {
        InputStream zipStream = ABLDuck.class.getResourceAsStream("resources/ablduck.zip");
        unzip(zipStream, outputDir);
    }

    public void unzip(InputStream zipStream, File unzipTo) throws IOException {
        if (!unzipTo.exists()) {
            unzipTo.mkdirs();
        }

        try (ZipInputStream zipIn = new ZipInputStream(zipStream)) {
            ZipEntry entry = zipIn.getNextEntry();

            while (entry != null) {
                String filePath = Paths.get(unzipTo.getAbsolutePath(), entry.getName()).toString();
                if (!entry.isDirectory()) {
                    extractFile(zipIn, filePath);
                } else {
                    File dir = new File(filePath);
                    dir.mkdir();
                }
                zipIn.closeEntry();
                entry = zipIn.getNextEntry();
            }
        }
    }

    private static void extractFile(ZipInputStream zipIn, String filePath) throws IOException {
        try (BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(filePath))) {
            byte[] bytesIn = new byte[BUFFER_SIZE];
            int read = 0;
            while ((read = zipIn.read(bytesIn)) != -1) {
                bos.write(bytesIn, 0, read);
            }
        }
    }

    private void replaceTemplateTags(String tag, String value, java.nio.file.Path file)
            throws IOException {
        Charset charset = StandardCharsets.UTF_8;

        String content = new String(Files.readAllBytes(file), charset);
        content = content.replaceAll(Pattern.quote(tag), Matcher.quoteReplacement(value));
        Files.write(file, content.getBytes(charset));
    }

    public String determineFullyQualifiedClassName(List<String> usings, String partialClassName) {
        if (partialClassName == null || "".equals(partialClassName))
            return partialClassName;

        IDataType idt = DataTypes.getDataType(partialClassName);
        if (idt != null)
            return partialClassName;

        // First check if we have a direct using statement for the datatype
        for (String using : usings) {
            if (using.endsWith("." + partialClassName)) {
                return using;
            }
        }

        // Now check for * using statements
        for (String using : usings) {
            if (using.endsWith("*")) {
                String fullName = using.substring(0, using.length() - 1) + partialClassName;

                if (classes.get(fullName) != null)
                    return fullName;
            }
        }

        return partialClassName;
    }

    public void createSearch(CompilationUnit cu) {
        Search search = new Search();
        search.name = ("class".equals(cu.tagname)
                ? cu.name.substring(cu.name.lastIndexOf('.') + 1)
                : cu.name.substring(cu.name.lastIndexOf('/') + 1));
        search.fullName = cu.name;
        search.icon = ICON_PREFIX + cu.icon;
        search.url = "#!/" + cu.tagname + "/" + cu.name;
        search.sort = 1;
        search.meta = cu.meta;

        data.search.add(search);

        for (Member member : cu.members) {
            search = new Search();
            search.name = member.name;
            search.fullName = ("procedure".equals(cu.tagname) ? cu.name : member.owner) + ":"
                    + member.name;
            search.icon = ICON_PREFIX + member.tagname;
            search.url = "#!/" + cu.tagname + "/"
                    + ("procedure".equals(cu.tagname) ? cu.name : member.owner) + "-"
                    + member.tagname + "-" + member.name;
            search.sort = 3;
            search.meta = member.meta;

            data.search.add(search);
        }
    }

    /**
     * Get the Charset from encoding parameter
     * 
     * @return Charset
     */
    protected Charset getCharset() {
        if (inputCharset == null) {
            try {
                inputCharset = Charset.forName(this.encoding);
            } catch (IllegalArgumentException caught) {
                inputCharset = Charset.defaultCharset();
            }
        }

        return inputCharset;
    }

}
