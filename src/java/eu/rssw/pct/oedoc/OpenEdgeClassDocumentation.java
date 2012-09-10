/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) 2002 The Apache Software Foundation.  All rights
 * reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution, if
 *    any, must include the following acknowlegement:
 *       "This product includes software developed by the
 *        Apache Software Foundation (http://www.apache.org/)."
 *    Alternately, this acknowlegement may appear in the software itself,
 *    if and wherever such third-party acknowlegements normally appear.
 *
 * 4. The names "Ant" and "Apache Software
 *    Foundation" must not be used to endorse or promote products derived
 *    from this software without prior written permission. For written
 *    permission, please contact apache@apache.org.
 *
 * 5. Products derived from this software may not be called "Apache"
 *    nor may "Apache" appear in their names without prior written
 *    permission of the Apache Group.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE APACHE SOFTWARE FOUNDATION OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation.  For more
 * information on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 */
package eu.rssw.pct.oedoc;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.Reader;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.xml.bind.JAXBException;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.types.FileSet;
import org.apache.tools.ant.types.Path;

import antlr.ANTLRException;

import com.openedge.pdt.core.ast.ASTNodeFactory;
import com.openedge.pdt.core.ast.CompilationUnit;
import com.openedge.pdt.core.ast.ProgressParser;
import com.phenix.pct.Messages;
import com.phenix.pct.PCT;

import eu.rssw.parser.OELexer;
import eu.rssw.parser.Propath;

/**
 * Class for generating XML documentation from OpenEdge classes
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class OpenEdgeClassDocumentation extends PCT {
    private File destDir = null;
    private String encoding = null;
    private List filesets = new ArrayList();
    protected Path propath = null;

    public OpenEdgeClassDocumentation() {
        super();
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
     * 
     * @param destFile Directory
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
    public void execute() throws BuildException {
        checkDlcHome();

        // Destination directory must exist
        if (this.destDir == null) {
            throw new BuildException(Messages.getString("OpenEdgeClassDocumentation.0"));
        }
        // There must be at least one fileset
        if (this.filesets.size() == 0) {
            throw new BuildException(Messages.getString("OpenEdgeClassDocumentation.1"));
        }

        File[] dirs = new File[propath.list().length];
        for (int zz = 0; zz < propath.list().length; zz++) {
            dirs[zz] = new File(propath.list()[zz]);
        }
        Propath propath = new Propath(dirs);

        try {
            for (Iterator e = filesets.iterator(); e.hasNext();) {
                // Parse filesets
                FileSet fs = (FileSet) e.next();

                // And get files from fileset
                String[] dsfiles = fs.getDirectoryScanner(this.getProject()).getIncludedFiles();

                for (int i = 0; i < dsfiles.length; i++) {
                    File file = new File(fs.getDir(this.getProject()), dsfiles[i]);

                    OELexer lexer = new OELexer(propath);
                    Reader inputReader = new FileReader(file);
                    lexer.load(inputReader);

                    ProgressParser parser = new ProgressParser(lexer.getTokenStream());
                    ASTNodeFactory factory = new ASTNodeFactory(parser.getTokenTypeToASTClassMap());
                    parser.setASTFactory(factory);
                    parser.setASTNodeClass("com.openedge.pdt.core.ast.CustomSimpleToken");

                    parser.openedge__unit();
                    CompilationUnit root = (CompilationUnit) parser.getAST();
                    root.setSourceRange();
                    lexer.attachIncludes(factory, root);

                    ClassDocumentationVisitor visitor = new ClassDocumentationVisitor(lexer, parser);
                    root.accept(visitor);
                    if ((visitor.cu.packageName == null) || (visitor.cu.packageName.length() == 0))
                        visitor.cu.toXML(new File(visitor.cu.className + ".xml"));
                    else
                        visitor.cu.toXML(new File(destDir, visitor.cu.packageName + "."
                                + visitor.cu.className + ".xml"));
                    
                }
            }
        } catch (IOException caught) {
            throw new BuildException(caught);
        } catch (ANTLRException caught) {
            throw new BuildException(caught);
        } catch (JAXBException caught) {
            throw new BuildException(caught);
        }
    }
}