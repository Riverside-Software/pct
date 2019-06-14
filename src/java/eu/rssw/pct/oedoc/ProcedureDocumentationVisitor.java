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
import java.util.Collections;
import java.util.List;

import javax.xml.bind.JAXBException;

import com.openedge.core.metadata.DataTypes;
import com.openedge.core.metadata.IDataType;
import com.openedge.pdt.core.ast.ASTNode;
import com.openedge.pdt.core.ast.DatasetDeclaration;
import com.openedge.pdt.core.ast.EventDeclaration;
import com.openedge.pdt.core.ast.FunctionDeclaration;
import com.openedge.pdt.core.ast.ProcedureDeclaration;
import com.openedge.pdt.core.ast.ProgressParserTokenTypes;
import com.openedge.pdt.core.ast.ProgressTokenTypes;
import com.openedge.pdt.core.ast.TemptableDeclaration;
import com.openedge.pdt.core.ast.TypeName;
import com.openedge.pdt.core.ast.UsingDeclaration;
import com.openedge.pdt.core.ast.IndexDeclaration.IndexColumn;
import com.openedge.pdt.core.ast.internal.CompilationUnit;
import com.openedge.pdt.core.ast.model.IASTNode;
import com.openedge.pdt.core.ast.model.IASTToken;
import com.openedge.pdt.core.ast.model.IField;
import com.openedge.pdt.core.ast.model.IIndex;
import com.openedge.pdt.core.ast.model.IParameter;
import com.openedge.pdt.core.ast.visitor.ASTVisitor;

import eu.rssw.rcode.AccessModifier;
import eu.rssw.rcode.Dataset;
import eu.rssw.rcode.Event;
import eu.rssw.rcode.Function;
import eu.rssw.rcode.Parameter;
import eu.rssw.rcode.ParameterMode;
import eu.rssw.rcode.Procedure;
import eu.rssw.rcode.ProcedureCompilationUnit;
import eu.rssw.rcode.TableField;
import eu.rssw.rcode.TableIndex;
import eu.rssw.rcode.TempTable;
import eu.rssw.rcode.Using;
import eu.rssw.rcode.UsingType;

public class ProcedureDocumentationVisitor extends ASTVisitor {
    private ProcedureCompilationUnit cu = new ProcedureCompilationUnit();

    public void toXML(File out) throws IOException, JAXBException {
        cu.toXML(out);
    }

    public ProcedureCompilationUnit getProcedureCompilationUnit() {
        return cu;
    }

    @Override
    public boolean visit(CompilationUnit decl) {

        // Unfortunately this doesn't work if there are just comments in the .p
        for (IASTNode node : decl.getChildren()) {
            IASTToken n = node.getHiddenPrevious();
            while (n != null) {
                if (n.getText().split("\n", 0).length > 1)
                    cu.procComment.add(n.getText());
                n = n.getHiddenPrevious();
            }

            break;
        }

        Collections.reverse(cu.procComment);

        cu.mainProcedure = new Procedure();

        if (decl.getParameters() != null) {
            for (IParameter p : decl.getParameters()) {
                Parameter param = new Parameter();
                param.name = p.getName();
                if (p.getDataType() == null) {
                    param.dataType = "";
                } else {
                    param.dataType = p.getDataType().getName();
                }
                param.position = p.getPosition();
                param.mode = ParameterMode.from(p.getMode());
                cu.mainProcedure.parameters.add(param);
            }
        }
        return true;
    }

    @Override
    public boolean visit(ProcedureDeclaration decl) {
        if (decl == null)
            return true;

        Procedure procedure = new Procedure();
        procedure.procedureName = decl.getName();
        procedure.signature = decl.getSignature();
        procedure.procedureComment = findComment(decl);

        cu.procedures.add(procedure);

        if (decl.getParameters() != null) {
            for (IParameter p : decl.getParameters()) {
                Parameter param = new Parameter();
                param.name = p.getName();
                if (p.getDataType() == null) {
                    param.dataType = "";
                } else {
                    param.dataType = p.getDataType().getName();
                }
                param.position = p.getPosition();
                param.mode = ParameterMode.from(p.getMode());
                procedure.parameters.add(param);
            }
        }

        return true;
    }

    @Override
    public boolean visit(FunctionDeclaration decl) {
        if (decl == null || decl.isForwardDeclaration())
            return true;

        Function function = new Function();
        function.functionName = decl.getName();
        function.signature = decl.getSignature();
        function.functionComment = findComment(decl);
        function.returnType = decl.getReturnType();

        cu.functions.add(function);

        if (decl.getParameters() != null) {
            for (IParameter p : decl.getParameters()) {
                Parameter param = new Parameter();
                param.name = p.getName();
                if (p.getDataType() == null) {
                    param.dataType = "";
                } else {
                    param.dataType = p.getDataType().getName();
                }
                param.position = p.getPosition();
                param.mode = ParameterMode.from(p.getMode());
                function.parameters.add(param);
            }
        }

        return true;
    }

    @Override
    public boolean visit(EventDeclaration decl) {
        if (decl == null)
            return true;

        Event event = new Event();
        event.eventName = decl.getName();
        event.signature = decl.getSignature();
        event.modifier = AccessModifier.from(decl.getAccessModifier());
        event.isStatic = decl.isStatic();
        event.isAbstract = decl.isAbstract();
        event.isOverride = decl.isOverride();
        if (decl.isDelegate())
            event.delegateName = decl.getDelegateName();
        event.eventComment = findComment(decl);
        cu.events.add(event);

        if (decl.getParameters() != null) {
            for (IParameter p : decl.getParameters()) {
                Parameter param = new Parameter();
                param.name = p.getName();
                param.dataType = getDataTypeName(p.getDataType());
                param.position = p.getPosition();
                param.mode = ParameterMode.from(p.getMode());
                event.parameters.add(param);
            }
        }

        return true;
    }

    @Override
    public boolean visit(UsingDeclaration decl) {
        Using using = new Using();
        using.name = decl.getName();

        if (decl.getChild(ProgressParserTokenTypes.FROM) == null)
            using.type = UsingType.NONE;
        else {
            if (decl.getChild(ProgressParserTokenTypes.PROPATH) != null)
                using.type = UsingType.PROPATH;
            else if (decl.getChild(ProgressParserTokenTypes.ASSEMBLY) != null)
                using.type = UsingType.ASSEMBLY;
            else
                using.type = UsingType.NONE;
        }
        cu.usings.add(using);

        return true;
    }

    @Override
    public boolean visit(TemptableDeclaration node) {
        TempTable tt = new TempTable();
        tt.name = node.getName();
        tt.comment = findComment(node);
        tt.like = node.getLikeTable();
        tt.noUndo = node.getChild(ProgressParserTokenTypes.NO__UNDO) != null;
        tt.beforeTable = node.getBeforeTable();
        tt.xmlNodeName = node.getXmlNodeName();
        tt.serialize = node.getSerializeName();
        tt.isNew = node.getChild(ProgressParserTokenTypes.NEW) != null;
        tt.isGlobal = node.getChild(ProgressParserTokenTypes.GLOBAL) != null;
        tt.isShared = node.getChild(ProgressParserTokenTypes.SHARED) != null;
        tt.modifier = AccessModifier.from(node.getAccessModifier());

        for (IField col : node.getColumns()) {
            TableField fld = new TableField();
            fld.name = col.getName();
            fld.dataType = getDataTypeName(col.getDataType());
            fld.initialValue = col.getInitial();
            tt.fields.add(fld);
        }
        for (IIndex idx : node.getIndexes()) {
            TableIndex tidx = new TableIndex();
            tidx.name = idx.getName();
            tidx.unique = idx.isUnique();
            tidx.wordIndex = idx.isWordIndex();
            tidx.primary = idx.isPrimary();
            List<IndexColumn> lst = (List<IndexColumn>) idx.getColumnList();
            for (IndexColumn col : lst) {
                tidx.fields.add(col.getName());
            }
            tt.indexes.add(tidx);
        }
        cu.tts.add(tt);
        tt.computeText();
        return true;
    }

    @Override
    public boolean visit(DatasetDeclaration node) {
        Dataset ds = new Dataset();
        ds.name = node.getName();
        ds.comment = findComment(node);

        ds.modifier = AccessModifier.from(node.getAccessModifier());
        ds.isNew = node.getChild(ProgressParserTokenTypes.NEW) != null;
        ds.isShared = node.getChild(ProgressParserTokenTypes.SHARED) != null;

        for (String str : node.getBufferNames()) {
            ds.buffers.add(str);
        }

        cu.dss.add(ds);
        ds.computeText();

        return super.visit(node);
    }

    private static String findComment(ASTNode node) {
        // First check before the statement
        if ((node.getHiddenPrevious() != null)
                && (node.getHiddenPrevious().getType() == ProgressTokenTypes.ML__COMMENT)
                && (node.getHiddenPrevious().getText().split("\n", 0).length > 1)) {
            return node.getHiddenPrevious().getText();
        }
        IASTNode n = node.getPrevSibling();
        while ((n != null) && (n.getType() == ProgressParserTokenTypes.ANNOTATION)) {
            if ((n.getHiddenPrevious() != null)
                    && (n.getHiddenPrevious().getType() == ProgressTokenTypes.ML__COMMENT)
                    && (n.getHiddenPrevious().getText().split("\n", 0).length > 1))
                return n.getHiddenPrevious().getText();
            n = n.getPrevSibling();
        }

        // If we find nothing lets try just after, for legacy reasons
        for (IASTNode nd : node.getChildren()) {
            if (nd.getType() == ProgressParserTokenTypes.EOS__COLON) {
                IASTToken commentnode = nd.getHiddenNext();
                if (commentnode != null
                        && commentnode.getType() == ProgressTokenTypes.ML__COMMENT) {
                    return commentnode.getText();
                }
                break;
            }
        }

        return null;
    }

    private static String getDataTypeName(TypeName typeName) {
        if (typeName == null) {
            return DataTypes.UNKNOWN.getABLName(true);
        }
        IDataType idt = DataTypes.getDataType(typeName.getName());
        if (idt != null)
            return idt.getABLName(true);
        else
            return typeName.getName();

    }
}
