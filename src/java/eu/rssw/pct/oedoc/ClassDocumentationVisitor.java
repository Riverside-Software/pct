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
import java.util.Collections;
import java.util.List;

import javax.xml.bind.JAXBException;

import com.openedge.core.metadata.DataTypes;
import com.openedge.core.metadata.IDataType;
import com.openedge.core.runtime.IPropath;
import com.openedge.pdt.core.ast.ASTNode;
import com.openedge.pdt.core.ast.ConstructorDeclaration;
import com.openedge.pdt.core.ast.DatasetDeclaration;
import com.openedge.pdt.core.ast.DestructorDeclaration;
import com.openedge.pdt.core.ast.EnumDeclaration;
import com.openedge.pdt.core.ast.EnumeratorItem;
import com.openedge.pdt.core.ast.EventDeclaration;
import com.openedge.pdt.core.ast.MethodDeclaration;
import com.openedge.pdt.core.ast.ProgressParserTokenTypes;
import com.openedge.pdt.core.ast.ProgressTokenTypes;
import com.openedge.pdt.core.ast.PropertyDeclaration;
import com.openedge.pdt.core.ast.PropertyMethod;
import com.openedge.pdt.core.ast.SimpleToken;
import com.openedge.pdt.core.ast.TemptableDeclaration;
import com.openedge.pdt.core.ast.TypeDeclaration;
import com.openedge.pdt.core.ast.TypeName;
import com.openedge.pdt.core.ast.UsingDeclaration;
import com.openedge.pdt.core.ast.IndexDeclaration.IndexColumn;
import com.openedge.pdt.core.ast.model.IASTNode;
import com.openedge.pdt.core.ast.model.IASTToken;
import com.openedge.pdt.core.ast.model.IField;
import com.openedge.pdt.core.ast.model.IIndex;
import com.openedge.pdt.core.ast.model.IParameter;
import com.openedge.pdt.core.ast.visitor.ASTVisitor;

import antlr.CommonHiddenStreamToken;
import eu.rssw.rcode.AccessModifier;
import eu.rssw.rcode.ClassCompilationUnit;
import eu.rssw.rcode.Constructor;
import eu.rssw.rcode.Dataset;
import eu.rssw.rcode.Destructor;
import eu.rssw.rcode.EnumMember;
import eu.rssw.rcode.Event;
import eu.rssw.rcode.GetSetModifier;
import eu.rssw.rcode.Method;
import eu.rssw.rcode.Parameter;
import eu.rssw.rcode.ParameterMode;
import eu.rssw.rcode.Property;
import eu.rssw.rcode.TableField;
import eu.rssw.rcode.TableIndex;
import eu.rssw.rcode.TempTable;
import eu.rssw.rcode.Using;
import eu.rssw.rcode.UsingType;

public class ClassDocumentationVisitor extends ASTVisitor {
    private final IPropath propath;

    private ClassCompilationUnit cu = new ClassCompilationUnit();
    private boolean firstTokenVisited = false;
    private List<String> firstComments = new ArrayList<>();
    private boolean gotEnum = false;

    public ClassDocumentationVisitor(IPropath propath) {
        this.propath = propath;
    }

    public String getPackageName() {
        if (cu.packageName == null)
            return "";
        return cu.packageName;
    }

    public String getClassName() {
        return cu.className;
    }

    public ClassCompilationUnit getClassCompilationUnit() {
        return cu;
    }

    public void toXML(File out) throws IOException, JAXBException {
        cu.classToXML(out);
    }

    @Override
    public boolean visit(SimpleToken node) {
        if (!firstTokenVisited) {
            CommonHiddenStreamToken token = node.getHiddenBefore();
            while (token != null) {
                firstComments.add(token.getText());
                token = token.getHiddenBefore();
            }
            Collections.reverse(firstComments);
            firstTokenVisited = true;
        }

        return true;
    }

    @Override
    public boolean visit(TemptableDeclaration node) {
        TempTable tt = new TempTable();
        tt.name = node.getName();
        tt.comment = findPreviousComment(node);
        tt.like = node.getLikeTable();
        tt.noUndo = node.getChild(ProgressParserTokenTypes.NO__UNDO) != null;
        tt.beforeTable = node.getBeforeTable();
        tt.xmlNodeName = node.getXmlNodeName();
        tt.serialize = node.getSerializeName();
        tt.isNew = node.getChild(ProgressParserTokenTypes.NEW) != null;
        tt.isGlobal = node.getChild(ProgressParserTokenTypes.GLOBAL) != null;
        tt.isShared = node.getChild(ProgressParserTokenTypes.SHARED) != null;
        tt.modifier = AccessModifier.from(node.getAccessModifier());
        String fName = "";
        if (node.getFileName() != null) {
            fName = propath.searchRelative(node.getFileName(), false).toPortableString();
        }
        tt.definition = fName;

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
            List<IndexColumn> lst = idx.getColumnList();
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
        ds.comment = findPreviousComment(node);

        ds.modifier = AccessModifier.from(node.getAccessModifier());
        ds.isNew = node.getChild(ProgressParserTokenTypes.NEW) != null;
        ds.isShared = node.getChild(ProgressParserTokenTypes.SHARED) != null;

        for (String str : node.getBufferNames()) {
            ds.buffers.add(str);
        }
        String fName = "Main file";
        if (node.getFileName() != null) {
            fName = propath.searchRelative(node.getFileName(), false).toPortableString();
        }
        ds.definition = fName;

        cu.dss.add(ds);
        ds.computeText();

        return super.visit(node);
    }

    @Override
    public boolean visit(TypeName name) {
        if (cu.isEnum && gotEnum) {
            int pos = name.getQualifiedName().lastIndexOf('.');
            if (pos == -1) {
                cu.className = name.getQualifiedName();
            } else {
                cu.packageName = name.getQualifiedName().substring(0, pos);
                cu.className = name.getQualifiedName().substring(pos + 1);
            }
        }
        return true;
    }

    @Override
    public boolean visit(EnumDeclaration decl) {
        cu.isEnum = true;
        gotEnum = true;
        cu.classComment.addAll(firstComments);
        cu.classComment.add(findPreviousComment(decl));

        return true;
    }

    @Override
    public boolean visit(EnumeratorItem item) {
        EnumMember member = new EnumMember(item.toString());
        member.comment = findPreviousComment(item);
        cu.enumMembers.add(member);

        return true;
    }

    @Override
    public boolean visit(TypeDeclaration decl) {
        cu.packageName = decl.getPackageName();
        cu.className = decl.getClassName();
        cu.isInterface = decl.isInterface();
        cu.isAbstract = decl.isAbstract();
        cu.isFinal = decl.isFinal();
        IASTNode clzNode = decl.getChildFirstLevel(ProgressParserTokenTypes.CLASS);
        if (clzNode != null) {
            cu.isSerializable = clzNode
                    .getChildFirstLevel(ProgressParserTokenTypes.SERIALIZABLE) != null;
            cu.useWidgetPool = clzNode
                    .getChildFirstLevel(ProgressParserTokenTypes.USE__WIDGET__POOL) != null;
        }
        cu.classComment.addAll(firstComments);
        cu.classComment.add(findPreviousComment(decl));

        if (decl.getInherits() != null)
            cu.inherits = decl.getInherits().getQualifiedName();
        if (decl.getImplements() != null) {
            for (TypeName typeName : decl.getImplements()) {
                cu.interfaces.add(typeName.getQualifiedName());
            }
        }

        return true;
    }

    @Override
    public boolean visit(PropertyDeclaration decl) {
        Property prop = new Property();
        prop.name = decl.getName();
        for (int zz : decl.getAllModifiers()) {
            prop.isStatic |= (zz == ProgressParserTokenTypes.STATIC);
        }
        prop.isAbstract = decl.isAbstract();
        prop.isOverride = decl.isOverride();
        prop.dataType = getDataTypeName(decl.getDataType());
        prop.extent = decl.getExtent();
        prop.modifier = AccessModifier.from(decl.getAccessModifier());
        prop.propertyComment = findPreviousComment(decl);
        cu.properties.add(prop);

        return true;
    }

    @Override
    public boolean visit(PropertyMethod decl) {
        IASTNode node = decl.getParent();
        if (node instanceof PropertyDeclaration) {
            String propName = ((PropertyDeclaration) node).getName();
            Property prop = null;
            for (Property p : cu.properties) {
                if (p.name.equalsIgnoreCase(propName))
                    prop = p;
            }
            if (prop != null) {
                if ("get".equalsIgnoreCase(decl.getName())) {
                    prop.getModifier = GetSetModifier.from(decl.getAccessModifier());
                } else if ("set".equalsIgnoreCase(decl.getName())) {
                    prop.setModifier = GetSetModifier.from(decl.getAccessModifier());
                }
            }
        }

        return true;
    }

    @Override
    public boolean visit(ConstructorDeclaration decl) {
        if (decl == null)
            return true;
        Constructor constr = new Constructor();
        constr.signature = decl.getSignature();
        if (decl.isStatic())
            constr.modifier = AccessModifier.STATIC;
        else
            constr.modifier = AccessModifier.from(decl.getAccessModifier());
        constr.constrComment = findPreviousComment(decl);

        if (decl.getParameters() != null) {
            for (IParameter p : decl.getParameters()) {
                Parameter param = new Parameter();
                param.name = p.getName();
                param.dataType = getDataTypeName(p.getDataType());
                param.position = p.getPosition();
                param.mode = ParameterMode.from(p.getMode());
                constr.parameters.add(param);
            }
        }
        cu.constructors.add(constr);

        return true;
    }

    @Override
    public boolean visit(DestructorDeclaration decl) {
        if (decl == null)
            return true;

        Destructor destructor = new Destructor();
        destructor.destructorComment = findPreviousComment(decl);
        cu.destructors.add(destructor);

        return true;
    }

    @Override
    public boolean visit(MethodDeclaration decl) {
        if (decl == null)
            return true;

        Method method = new Method();
        method.methodName = decl.getName();
        method.signature = decl.getSignature();
        method.modifier = AccessModifier.from(decl.getAccessModifier());
        method.returnType = decl.getReturnType();
        method.isStatic = decl.isStatic();
        method.isFinal = decl.isFinal();
        method.isAbstract = decl.isAbstract();
        method.isOverride = decl.isOverride();
        method.methodComment = findPreviousComment(decl);
        cu.methods.add(method);

        if (decl.getParameters() != null) {
            for (IParameter p : decl.getParameters()) {
                Parameter param = new Parameter();
                param.name = p.getName();
                param.dataType = getDataTypeName(p.getDataType());
                param.position = p.getPosition();
                param.mode = ParameterMode.from(p.getMode());
                method.parameters.add(param);
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
        event.eventComment = findPreviousComment(decl);
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

    /**
     * Returns *last* comment
     */
    private static String findPreviousComment(ASTNode node) {
        if ((node.getHiddenPrevious() != null)
                && (node.getHiddenPrevious().getType() == ProgressTokenTypes.ML__COMMENT)) {
            return node.getHiddenPrevious().getText();
        }
        IASTNode n = node.getPrevSibling();
        while ((n != null) && (n.getType() == ProgressParserTokenTypes.ANNOTATION)) {
            if ((n.getHiddenPrevious() != null)
                    && (n.getHiddenPrevious().getType() == ProgressTokenTypes.ML__COMMENT))
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
