/**
 * Copyright 2005-2024 Riverside Software
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
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.io.Writer;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.function.Predicate;
import java.util.stream.Stream;

import org.antlr.v4.runtime.misc.ParseCancellationException;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.types.FileSet;
import org.apache.tools.ant.types.Path;
import org.prorefactor.core.ABLNodeType;
import org.prorefactor.core.JPNode;
import org.prorefactor.core.ProToken;
import org.prorefactor.core.nodetypes.IStatement;
import org.prorefactor.core.schema.IDatabase;
import org.prorefactor.core.schema.ISchema;
import org.prorefactor.core.schema.Schema;
import org.prorefactor.refactor.RefactorSession;
import org.prorefactor.refactor.settings.ProparseSettings;
import org.prorefactor.treeparser.ParseUnit;
import org.prorefactor.treeparser.symbols.Routine;
import org.prorefactor.treeparser.symbols.Variable;
import org.sonar.plugins.openedge.api.objects.DatabaseWrapper;

import com.google.gson.stream.JsonWriter;
import com.phenix.pct.DBConnectionSet;
import com.phenix.pct.PCT;
import com.phenix.pct.PCTAlias;
import com.phenix.pct.PCTConnection;
import com.phenix.pct.PCTDumpSchema;

import eu.rssw.antlr.database.DumpFileUtils;
import eu.rssw.pct.RCodeInfo;
import eu.rssw.pct.RCodeInfo.InvalidRCodeException;
import eu.rssw.pct.elements.DataType;
import eu.rssw.pct.elements.IAccessibleElement;
import eu.rssw.pct.elements.IMethodElement;
import eu.rssw.pct.elements.IParameter;
import eu.rssw.pct.elements.IPropertyElement;
import eu.rssw.pct.elements.ITableElement;
import eu.rssw.pct.elements.ITypeInfo;
import eu.rssw.pct.elements.PrimitiveDataType;

/**
 * Generate JSON documentation from OpenEdge classes
 * 
 * @author <a href="mailto:g.querret+PCT@gmail.com">Gilles QUERRET </a>
 */
public class JsonDocumentation extends PCT {
    private File destFile = null;
    private File buildDir = null;
    private String encoding = null;
    private List<FileSet> filesets = new ArrayList<>();
    private Path propath = null;
    private Collection<PCTConnection> dbConnList = null;
    private Collection<DBConnectionSet> dbConnSet = null;
    private boolean indent = false;
    private CommentStyle style = CommentStyle.JAVADOC;
    private int numThreads = 1;

    public JsonDocumentation() {
        super();
        createPropath();
    }

    /**
     * Adds a set of files to analyze
     */
    public void addFileset(FileSet set) {
        filesets.add(set);
    }

    /**
     * RCode directory
     */
    public void setBuildDir(File buildDir) {
        this.buildDir = buildDir;
    }

    /**
     * Destination directory
     */
    public void setDestFile(File file) {
        this.destFile = file;
    }

    /**
     * Number of concurrent threads when reading rcode
     */
    public void setNumThreads(int numThreads) {
        if (numThreads <= 0)
            throw new BuildException("numThreads attribute should be greater or equal than 1");
        this.numThreads = numThreads;
    }

    /**
     * Specify if JSON files should be indented or on a single line
     */
    public void setIndent(boolean indent) {
        this.indent = indent;
    }

    /**
     * Comment style: JAVADOC (slash star star), SIMPLE (slash star), CONSULTINGWERK
     */
    public void setStyle(String style) {
        this.style = CommentStyle.valueOf(style.toUpperCase());
    }

    public void setEncoding(String encoding) {
        this.encoding = encoding;
    }

    public void addPropath(Path propath) {
        createPropath().append(propath);
    }

    public void addDBConnection(PCTConnection dbConn) {
        if (dbConnList == null) {
            dbConnList = new ArrayList<>();
        }
        dbConnList.add(dbConn);
    }

    public void addDBConnectionSet(DBConnectionSet set) {
        if (this.dbConnSet == null) {
            this.dbConnSet = new ArrayList<>();
        }
        dbConnSet.add(set);
    }

    /**
     * Creates a new Path instance
     * 
     * @return Path
     */
    private Path createPropath() {
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
        if (this.destFile == null) {
            throw new BuildException("destDir attribute is not set");
        }
        if (!createDir(destFile.getParentFile())) {
            throw new BuildException("Unable to create destination directory");
        }

        // There must be at least one fileset
        if (filesets.isEmpty()) {
            throw new BuildException("At least one fileset should be defined");
        }

        ISchema sch = null;
        try {
            log("JsonDocumentation - Generating schema", Project.MSG_INFO);
            sch = readDBSchema();
        } catch (IOException caught) {
            throw new BuildException(caught);
        }
        String pp = String.join(",", propath.list());
        log("Using PROPATH: " + pp, Project.MSG_INFO);
        ProparseSettings ppSettings = new ProparseSettings(pp, false);
        RefactorSession session = new RefactorSession(ppSettings, sch, Charset.forName(encoding));

        // Multi-threaded pool
        AtomicInteger numRCode = new AtomicInteger(0);
        ExecutorService service = Executors.newFixedThreadPool(numThreads);
        try (Stream<java.nio.file.Path> stream = Files.walk(buildDir.toPath())) {
            stream.filter(path -> path.getFileName().toString().endsWith(".r")).forEach(f -> {
                numRCode.incrementAndGet();
                service.submit(() -> {
                    ITypeInfo info = parseRCode(f.toFile());
                    if (info != null) {
                        log("TypeInfo found: " + info.getTypeName(), Project.MSG_DEBUG);
                        session.injectTypeInfo(info);
                    }
                });
            });
        } catch (IOException caught) {
            log("Unable to parse build directory " + buildDir + " - " + caught.getMessage(),
                    Project.MSG_ERR);
        }
        service.shutdown();
        try {
            service.awaitTermination(10, TimeUnit.MINUTES);
        } catch (InterruptedException caught) {
            Thread.currentThread().interrupt();
        }

        log("Generating JSON documentation in " + destFile.getAbsolutePath(), Project.MSG_INFO);
        try (Writer fw = new FileWriter(destFile); JsonWriter writer = new JsonWriter(fw)) {
            if (indent)
                writer.setIndent("  ");
            writer.beginArray();

            for (FileSet fs : filesets) {
                String[] dsfiles = fs.getDirectoryScanner(this.getProject()).getIncludedFiles();
                for (int i = 0; i < dsfiles.length; i++) {
                    parseAndWriteUnit(new File(fs.getDir(this.getProject()), dsfiles[i]), session, writer);
                }
            }
            writer.endArray();
        } catch (IOException caught) {
            throw new BuildException(caught);
        }
    }

    private void parseAndWriteUnit(File file, RefactorSession session, JsonWriter writer)
            throws IOException {
        log("Proparse: " + file.getName(), Project.MSG_DEBUG);
        try {
            ParseUnit unit = new ParseUnit(file, file.getName(), session);
            unit.treeParser01();
            if (session.getTypeInfo(unit.getClassName()) != null) {
                writeClass(writer, session.getTypeInfo(unit.getClassName()), unit);
            } else {
                writeProcedure(file.getName(), writer, unit);
            }
        } catch (UncheckedIOException | ParseCancellationException caught) {
            log("Unable to attach comments from " + file.getAbsolutePath() + " - Proparse error: "
                    + caught.getMessage(), Project.MSG_INFO);
        }
    }

    private void writeProcedure(String name, JsonWriter ofile, ParseUnit unit) throws IOException {
        ofile.beginObject();
        ofile.name("name").value(name);
        ofile.endObject();
    }

    private void writeClass(JsonWriter ofile, ITypeInfo info, ParseUnit unit) throws IOException {
        ofile.beginObject();
        ofile.name("className").value(info.getTypeName());
        ofile.name("inherits").value(info.getParentTypeName());
        ofile.name("abstract").value(info.isAbstract());
        ofile.name("final").value(info.isFinal());
        ofile.name("interface").value(info.isInterface());
        ofile.name("serializable").value(info.isSerializable());
        ofile.name("enum").value(unit.isEnum());
        boolean useWidgetPool = false;
        List<JPNode> lst = unit.getTopNode().queryStateHead(ABLNodeType.CLASS);
        if (!lst.isEmpty()) {
            useWidgetPool = !lst.get(0).queryCurrentStatement(ABLNodeType.USEWIDGETPOOL).isEmpty();
            writeDeprecatedInfo(lst.get(0).asIStatement(), ofile);
        }
        
        ofile.name("useWidgetPool").value(useWidgetPool);
        ofile.name("interfaces").beginArray();
        for (String str : info.getInterfaces()) {
            ofile.value(str);
        }
        ofile.endArray();

        List<String> classComments = getJavadoc(info, unit);
        writeComments(ofile, classComments);

        ofile.name("methods").beginArray();
        for (IMethodElement methd : info.getMethods()) {
            if (!methd.isConstructor() && !methd.isDestructor())
                writeMethod(ofile, methd, unit);
        }
        ofile.endArray();

        ofile.name("constructors").beginArray();
        for (IMethodElement methd : info.getMethods()) {
            if (methd.isConstructor())
                writeMethod(ofile, methd, unit);
        }
        ofile.endArray();

        ofile.name("destructors").beginArray();
        for (IMethodElement methd : info.getMethods()) {
            if (methd.isDestructor())
                writeMethod(ofile, methd, unit);
        }
        ofile.endArray();

        ofile.name("properties").beginArray();
        for (IPropertyElement prop : info.getProperties()) {
            ofile.beginObject();
            ofile.name("name").value(prop.getName());
            ofile.name("type").value(
                    prop.getVariable().getDataType().getPrimitive() == PrimitiveDataType.CLASS
                            ? prop.getVariable().getDataType().getClassName()
                            : prop.getVariable().getDataType().getPrimitive().getSignature());
            ofile.name("modifier").value(getModifier(prop));
            writeComments(ofile, getJavadoc(prop, unit));
            Variable v = unit.getRootScope().lookupVariable(prop.getName());
            if ((v != null) && (v.getDefineNode() != null)
                    && v.getDefineNode().getStatement().isIStatement())
                writeDeprecatedInfo(v.getDefineNode().getStatement().asIStatement(), ofile);
            ofile.endObject();
        }
        ofile.endArray();

        ofile.name("tables").beginArray();
        for (ITableElement tbl : info.getTables()) {
            ofile.beginObject();
            ofile.name("name").value(tbl.getName());
            ofile.name("modifier").value(getModifier(tbl));
            ofile.name("noundo").value(tbl.isNoUndo());
            writeComments(ofile, getJavadoc(tbl, unit));
            ofile.endObject();
        }
        ofile.endArray();

        ofile.endObject();
    }

    private void writeMethod(JsonWriter ofile, IMethodElement methd, ParseUnit unit)
            throws IOException {
        ofile.beginObject();
        ofile.name("name").value(methd.getName());
        ofile.name("signature").value(methd.getSignature());
        ofile.name("returnType")
                .value(methd.getReturnType().getPrimitive() == PrimitiveDataType.CLASS
                        ? methd.getReturnType().getClassName()
                        : methd.getReturnType().getPrimitive().getSignature());
        ofile.name("abstract").value(methd.isAbstract());
        ofile.name("static").value(methd.isStatic());
        ofile.name("extent").value(methd.getExtent());
        ofile.name("modifier").value(getModifier(methd));

        Routine routine = getRoutine(methd, unit);
        List<String> comments = getJavadoc(routine, unit);
        if ((routine != null) && (routine.getDefineNode() != null)
                && routine.getDefineNode().isIStatement())
            writeDeprecatedInfo(routine.getDefineNode().asIStatement(), ofile);
        writeComments(ofile, comments);

        ofile.name("parameters").beginArray();
        for (IParameter prm : methd.getParameters()) {
            ofile.beginObject();
            ofile.name("name").value(prm.getName());
            ofile.name("extent").value(prm.getExtent());
            ofile.name("modifier").value(prm.getMode().toString());
            switch (prm.getParameterType()) {
                case TABLE :
                case BUFFER_TEMP_TABLE :
                    ofile.name("type").value(
                            "TABLE" + (prm.getDataType() == DataType.HANDLE ? "-HANDLE" : ""));
                    break;
                case DATASET :
                    ofile.name("type").value(
                            "DATASET" + (prm.getDataType() == DataType.HANDLE ? "-HANDLE" : ""));
                    break;
                case BROWSE :
                    ofile.name("type").value("BROWSE");
                    break;
                default :
                    ofile.name("type")
                            .value(prm.getDataType().getPrimitive() == PrimitiveDataType.CLASS
                                    ? prm.getDataType().getClassName()
                                    : prm.getDataType().getPrimitive().getSignature());
            }
            ofile.endObject();
        }
        ofile.endArray();
        ofile.endObject();
    }

    private String getModifier(IAccessibleElement elem) {
        if (elem.isPublic())
            return "public";
        else if (elem.isPackageProtected())
            return "package-protected";
        else if (elem.isProtected())
            return "protected";
        else if (elem.isPackagePrivate())
            return "private";
        else
            return "private";
    }

    private void writeComments(JsonWriter ofile, List<String> comments) throws IOException {
        if (comments.isEmpty())
            return;
        ofile.name("comments").beginArray();
        for (String str : comments) {
            ofile.value(str);
        }
        ofile.endArray();
    }

    private List<String> getJavadoc(ITypeInfo info, ParseUnit unit) {
        JPNode clsNode = unit.getTopNode().queryStateHead(ABLNodeType.CLASS).stream().findFirst()
                .orElse(null);
        if (clsNode != null) {
            return getJavadoc(clsNode);
        } else
            return new ArrayList<>();

    }

    private List<String> getJavadoc(ITableElement elem, ParseUnit unit) {
        Predicate<JPNode> p1 = node -> node.isStateHead()
                && (node.getNodeType() == ABLNodeType.DEFINE)
                && (node.asIStatement().getNodeType2() == ABLNodeType.TEMPTABLE);
        Predicate<JPNode> p2 = node -> node.findDirectChild(ABLNodeType.ID) != null
                && elem.getName().equalsIgnoreCase(node.findDirectChild(ABLNodeType.ID).getText());
        JPNode ttNode = unit.getTopNode().query2(p1.and(p2)).stream().findFirst().orElse(null);
        if (ttNode != null) {
            return getJavadoc(ttNode);
        } else
            return new ArrayList<>();
    }

    private Routine getRoutine(IMethodElement elem, ParseUnit unit) {
        List<Routine> list = unit.getRootScope().lookupRoutines(elem.getName());
        if (list.isEmpty()) {
            return null;
        } else if (list.size() == 1) {
            return list.get(0);
        } else {
            String sig = elem.getSignature();
            for (Routine r : list) {
                if (r.getSignature().equalsIgnoreCase(sig))
                    return r;
            }
            return null;
        }
    }

    private List<String> getJavadoc(Routine routine, ParseUnit unit) {
        if (routine == null)
            return new ArrayList<>();
        else
            return getJavadoc(routine.getDefineNode().getStatement());
    }

    private List<String> getJavadoc(IPropertyElement elem, ParseUnit unit) {
        Variable v = unit.getRootScope().getVariable(elem.getName());
        if (v == null)
            return new ArrayList<>();
        else
            return getJavadoc(v.getDefineNode().getStatement());
    }

    private void writeDeprecatedInfo(IStatement stmt, JsonWriter writer) throws IOException {
        List<String> annotations = stmt.getAnnotations();
        if (annotations == null)
            return;
        for (String ann : annotations) {
            if ("@deprecated".equalsIgnoreCase(ann)) {
                writer.name("deprecated").beginObject().name("message").value("").endObject();
                return;
            } else if (ann.toLowerCase().startsWith("@deprecated(")) {
                writer.name("deprecated").beginObject();
                String since = "";
                String message = "";
                for (String str : ann.substring(ann.indexOf('(') + 1, ann.lastIndexOf(')'))
                        .split(",")) {
                    if ((str.indexOf('=') > -1) && "since"
                            .equalsIgnoreCase(str.substring(0, str.indexOf('=')).trim())) {
                        since = str.substring(str.indexOf('=') + 1).trim();
                    } else if ((str.indexOf('=') > -1) && "message"
                            .equalsIgnoreCase(str.substring(0, str.indexOf('=')).trim())) {
                        message = str.substring(str.indexOf('=') + 1).trim();
                    }
                }
                writer.name("message").value(dequote(message.trim()));
                if (!since.trim().isEmpty())
                    writer.name("since").value(dequote(since.trim()));
                writer.endObject();
                return;
            }
        }
    }

    private String dequote(String str) {
        if ((str.length() > 1) && (str.charAt(0) == '\'') && (str.charAt(str.length() - 1) == '\''))
            return str.substring(1, str.length() - 1);
        if ((str.length() > 1) && (str.charAt(0) == '"') && (str.charAt(str.length() - 1) == '"'))
            return str.substring(1, str.length() - 1);
        return str;
    }

    private List<String> getJavadoc(JPNode stmt) {
        // Read comments before the statement and its annotations
        List<String> comments = new ArrayList<>();
        for (ProToken tok : stmt.getHiddenTokens()) {
            if (tok.getNodeType() == ABLNodeType.COMMENT)
                comments.add(tok.getText());
        }
        stmt = stmt.getPreviousNode();
        while (stmt.getNodeType() == ABLNodeType.ANNOTATION) {
            for (ProToken tok : stmt.getHiddenTokens()) {
                if (tok.getNodeType() == ABLNodeType.COMMENT)
                    comments.add(tok.getText());
            }
            stmt = stmt.getPreviousNode();
        }

        return convertJavadoc(comments);
    }

    private List<String> convertJavadoc(List<String> comments) {
        List<String> rslt = new ArrayList<>();
        for (String s : comments) {
            rslt.addAll(convertJavadoc(s));
        }
        return rslt;
    }

    private List<String> convertJavadoc(String comment) {
        List<String> rslt = new ArrayList<>();
        if (checkStartComment(comment.trim())) {
            for (String s : comment.trim().split("\n")) {
                // First line and last line is not supposed to contain anything
                if (!checkStartComment(s.trim()) && !s.endsWith("*/")) {
                    // Trim first *
                    if (s.trim().startsWith("*"))
                        rslt.add(s.trim().substring(1).trim());
                    else
                        rslt.add(s.trim());
                }
            }
        }
        return rslt;
    }

    private boolean checkStartComment(String comment) {
        if (style == CommentStyle.JAVADOC) {
            return comment.startsWith("/**");
        } else if (style == CommentStyle.SIMPLE) {
            return comment.startsWith("/*");
        } else if (style == CommentStyle.CONSULTINGWERK) {
            return comment.startsWith("/*-");
        }
        return false;
    }

    private ITypeInfo parseRCode(File file) {
        try (FileInputStream fis = new FileInputStream(file)) {
            log("Parsing rcode: " + file.getAbsolutePath(), Project.MSG_DEBUG);
            RCodeInfo rci = new RCodeInfo(fis);
            if (rci.isClass()) {
                return rci.getTypeInfo();
            }
        } catch (InvalidRCodeException | IOException | RuntimeException caught) {
            log("Unable to parse rcode " + file.getAbsolutePath()
                    + " - Please open issue on GitHub - " + caught.getClass().getName(),
                    Project.MSG_ERR);
        }
        return null;
    }

    private Schema readDBSchema() throws IOException {
        Collection<PCTConnection> connList = getDBConnections();
        IDatabase[] dbs = new IDatabase[connList.size()];
        int cnt = 0;

        for (PCTConnection conn : connList) {
            log("Dumping schema for database #" + cnt + " - " + conn.getDbName(), Project.MSG_INFO);
            File outFile = dumpSchema(conn);
            dbs[cnt++] = new DatabaseWrapper(
                    DumpFileUtils.getDatabaseDescription(outFile.toPath(), conn.getDbName()));
            outFile.delete();
        }

        Schema schema = new Schema(dbs);
        schema.injectMetaSchema();
        for (PCTConnection conn : connList) {
            for (PCTAlias alias : conn.getAliases()) {
                schema.createAlias(alias.getName(), conn.getDbName());
            }
        }
        if (!schema.getDbSet().isEmpty())
            schema.createAlias("dictdb", schema.getDbSet().first().getName());

        return schema;
    }

    private Collection<PCTConnection> getDBConnections() {
        Collection<PCTConnection> dbs = new ArrayList<>();
        if (dbConnList != null) {
            dbs.addAll(dbConnList);
        }
        if (dbConnSet != null) {
            for (DBConnectionSet set : dbConnSet) {
                dbs.addAll(set.getDBConnections());
            }
        }
        return dbs;
    }

    private File dumpSchema(PCTConnection conn) {
        File outFile = null;
        try {
            outFile = File.createTempFile("jsondocsch", ".df");
        } catch (IOException caught) {
            throw new BuildException(caught);
        }
        PCTDumpSchema run = new PCTDumpSchema();
        run.bindToOwner(this);
        run.setDestFile(outFile);
        run.setDlcHome(getDlcHome());
        run.setCpInternal("utf-8");
        run.setCpStream("utf-8");
        run.setCpCase("basic");
        run.setCpColl("basic");
        run.addDBConnection(conn);
        run.execute();

        return outFile;
    }

    public enum CommentStyle {
        JAVADOC, // /**
        SIMPLE, // /*
        CONSULTINGWERK, // /*-
    }
}
