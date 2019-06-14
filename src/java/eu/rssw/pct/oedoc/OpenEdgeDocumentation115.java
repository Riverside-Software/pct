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
import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.JAXBException;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.types.FileSet;
import org.apache.tools.ant.types.Path;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;

import com.openedge.core.runtime.IPropath;
import com.openedge.core.runtime.Propath;
import com.openedge.pdt.core.ast.ASTManager;
import com.openedge.pdt.core.ast.ASTNode;
import com.openedge.pdt.core.ast.IASTManager;
import com.openedge.pdt.core.ast.PropathASTContext;
import com.openedge.pdt.core.ast.model.IASTContext;
import com.openedge.pdt.core.ast.model.IASTNode;
import com.openedge.pdt.core.ast.model.ICompilationUnit;
import com.phenix.pct.Messages;
import com.phenix.pct.PCT;

import java.text.MessageFormat;

/**
 * Class for generating XML documentation from OpenEdge classes
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class OpenEdgeDocumentation115 extends PCT {
    private File destDir = null;
    private String encoding = null;
    private List<FileSet> filesets = new ArrayList<>();
    protected Path propath = null;

    public OpenEdgeDocumentation115() {
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

    /**
     * Destination directory
     */
    public void setDestDir(File dir) {
        this.destDir = dir;
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
     * Do the work
     * 
     * @throws BuildException Something went wrong
     */
    @Override
    public void execute() {
        checkDlcHome();

        // Destination directory must exist
        if (this.destDir == null) {
            throw new BuildException(MessageFormat.format(Messages.getString("OpenEdgeClassDocumentation.0"), "destDir"));
        }
        if (!createDir(destDir)) {
            throw new BuildException("Unable to create destination directory");
        }

        // There must be at least one fileset
        if (filesets.isEmpty()) {
            throw new BuildException(Messages.getString("OpenEdgeClassDocumentation.1"));
        }
        IPropath pp = new Propath(new org.eclipse.core.runtime.Path(getProject().getBaseDir().getAbsolutePath()), propath.list());
        IASTContext astContext = new PropathASTContext(pp);
        IProgressMonitor monitor = new NullProgressMonitor();
        IASTManager astMgr = ASTManager.getASTManager();

        log("Generating XML documentation (11.5+ method)", Project.MSG_INFO);
        try {
            for (FileSet fs : filesets) {
                // And get files from fileset
                String[] dsfiles = fs.getDirectoryScanner(this.getProject()).getIncludedFiles();

                for (int i = 0; i < dsfiles.length; i++) {
                    File file = new File(fs.getDir(this.getProject()), dsfiles[i]);
                    log("Generating AST for " + file.getAbsolutePath(), Project.MSG_VERBOSE);
                    int extPos = file.getName().lastIndexOf('.');
                    String ext = file.getName().substring(extPos);
                    boolean isClass = ".cls".equalsIgnoreCase(ext);

                    ICompilationUnit root = astMgr.createAST(file, astContext, monitor, IASTManager.EXPAND_ON, IASTManager.DLEVEL_FULL);
                    if (isClass) {
                        ClassDocumentationVisitor visitor = new ClassDocumentationVisitor(pp);
                        log("Executing AST ClassVisitor " + file.getAbsolutePath(), Project.MSG_VERBOSE);
                        root.accept(visitor);
                        if (visitor.getPackageName().length() == 0)
                            visitor.toXML(new File(destDir, visitor.getClassName() + ".xml"));
                        else
                            visitor.toXML(new File(destDir, visitor.getPackageName() + "."
                                    + visitor.getClassName() + ".xml"));
                    } else {
                        ProcedureDocumentationVisitor visitor = new ProcedureDocumentationVisitor();
                        log("Executing AST ProcedureVisitor " + file.getAbsolutePath(), Project.MSG_VERBOSE);
                        root.accept(visitor);
                        File destFile = new File(destDir, dsfiles[i] + ".xml");
                        destFile.getParentFile().mkdirs();
                        visitor.toXML(destFile);
                    }
                }
            }
        } catch (IOException | JAXBException caught) {
            throw new BuildException(caught);
        }
    }

    public static void setSourceRange(ASTNode node) {
        if (node instanceof ICompilationUnit) {
            node.setStartPosition(1);
        }

        if ((node.getFirstChild1() == null) || (node.getType() == 22)) {
            node.setStartPosition(node.getTokenStart());
            node.setLength(node.getTokenLength());
        }

        IASTNode prev = null;
        for (IASTNode child = node.getFirstChild1(); child != null; child = child.getNextSibling1()) {
            ((ASTNode) child).setParent(node);
            if (prev != null) {
                ((ASTNode) child).setPrevSibling(prev);
            }
            prev = child;

            if (child.getType() != 22) {
                setSourceRange((ASTNode) child);
            }
        }
    }

}
