package eu.rssw.pct.oedoc;

import java.util.ArrayList;
import java.util.List;

import antlr.BaseAST;
import antlr.Token;

import com.openedge.pdt.core.ast.ConstructorDeclaration;
import com.openedge.pdt.core.ast.EventDeclaration;
import com.openedge.pdt.core.ast.MethodDeclaration;
import com.openedge.pdt.core.ast.ProgressParser;
import com.openedge.pdt.core.ast.ProgressParserTokenTypes;
import com.openedge.pdt.core.ast.ProgressTokenTypes;
import com.openedge.pdt.core.ast.PropertyDeclaration;
import com.openedge.pdt.core.ast.TypeDeclaration;
import com.openedge.pdt.core.ast.TypeName;
import com.openedge.pdt.core.ast.UsingDeclaration;
import com.openedge.pdt.core.ast.visitor.ASTVisitor;

import eu.rssw.pct.oedoc.CompilationUnit.AccessModifier;
import eu.rssw.pct.oedoc.CompilationUnit.Constructor;
import eu.rssw.pct.oedoc.CompilationUnit.Event;
import eu.rssw.pct.oedoc.CompilationUnit.Method;
import eu.rssw.pct.oedoc.CompilationUnit.Parameter;
import eu.rssw.pct.oedoc.CompilationUnit.ParameterMode;
import eu.rssw.pct.oedoc.CompilationUnit.Property;
import eu.rssw.pct.oedoc.CompilationUnit.Using;
import eu.rssw.pct.oedoc.CompilationUnit.UsingType;

public class ClassDocumentationVisitor extends ASTVisitor {
    private eu.rssw.parser.OELexer lexer;
    private ProgressParser parser;
    public CompilationUnit cu = new CompilationUnit();

    public ClassDocumentationVisitor(eu.rssw.parser.OELexer lexer, ProgressParser parser) {
        this.lexer = lexer;
        this.parser = parser;
    }

    public boolean visit(TypeDeclaration decl) {
        cu.packageName = decl.getPackageName();
        cu.className = decl.getClassName();
        cu.isInterface = decl.isInterface();
        cu.isAbstract = decl.isAbstract();
        cu.isFinal = decl.isFinal();
        BaseAST realChild = (BaseAST) decl.getFirstChildRealToken();
        cu.classComment.addAll(findFirstComments(realChild.getLine()));

        if (decl.getInherits() != null)
            cu.inherits = decl.getInherits().getQualifiedName();
        if (decl.getImplements() != null) {
            for (TypeName typeName : decl.getImplements()) {
                cu.interfaces.add(typeName.getQualifiedName());
            }
        }

        return true;
    }

    public boolean visit(PropertyDeclaration decl) {
        Property prop = new Property();
        prop.name = decl.getName();
        prop.isAbstract = decl.isAbstract();
        prop.dataType = decl.getDataType().getName();
        prop.extent = decl.getExtent();
        prop.modifier = AccessModifier.from(decl.getAccessModifier());
        BaseAST realChild = (BaseAST) decl.getFirstChildRealToken();
        prop.propertyComment = findPreviousComment(realChild.getLine(), realChild.getColumn());
        cu.properties.add(prop);

        return true;
    }

    public boolean visit(ConstructorDeclaration decl) {
        if (decl == null)
            return true;
        Constructor constr = new Constructor();
        constr.signature = decl.getSignature();
        constr.modifier = AccessModifier.from(decl.getAccessModifier());
        BaseAST realChild = (BaseAST) decl.getFirstChildRealToken();
        constr.constrComment = findPreviousComment(realChild.getLine(), realChild.getColumn());

        if (decl.getParameters() != null) {
            for (com.openedge.pdt.core.ast.model.IParameter p : decl.getParameters()) {
                Parameter param = new Parameter();
                param.name = p.getName();
                param.dataType = p.getDataType().getName();
                param.position = p.getPosition();
                param.mode = ParameterMode.from(p.getMode());
                constr.parameters.add(param);
            }
        }
        cu.constructors.add(constr);

        return true;
    }

    public boolean visit(MethodDeclaration decl) {
        if (decl == null)
            return true;

        Method method = new Method();
        method.methodName = decl.getName();
        method.signature = decl.getSignature();
        method.modifier = AccessModifier.from(decl.getAccessModifier());
        method.returnType = decl.getReturnType();
        method.isStatic = decl.isStatic();
        BaseAST realChild = (BaseAST) decl.getFirstChildRealToken();
        method.methodComment = findPreviousComment(realChild.getLine(), realChild.getColumn());
        cu.methods.add(method);

        if (decl.getParameters() != null) {
            for (com.openedge.pdt.core.ast.model.IParameter p : decl.getParameters()) {
                Parameter param = new Parameter();
                param.name = p.getName();
                if (p.getDataType() == null) {
                    System.out.println("Class " + cu.className + " -- Method " + method.methodName
                            + " -- Param " + param.name + " -- Null dataType");
                    param.dataType = "";
                } else {
                    param.dataType = p.getDataType().getName();
                }
                param.position = p.getPosition();
                param.mode = ParameterMode.from(p.getMode());
                method.parameters.add(param);
            }
        }

        return true;
    }

    public boolean visit(EventDeclaration decl) {
        if (decl == null)
            return true;

        Event event = new Event();
        event.eventName = decl.getName();
        event.signature = decl.getSignature();
        event.modifier = AccessModifier.from(decl.getAccessModifier());
        event.isStatic = decl.isStatic();
        if (decl.isDelegate())
            event.delegateName = decl.getDelegateName();
        BaseAST realChild = (BaseAST) decl.getFirstChildRealToken();
        event.eventComment = findPreviousComment(realChild.getLine(), realChild.getColumn());
        cu.events.add(event);

        if (decl.getParameters() != null) {
            for (com.openedge.pdt.core.ast.model.IParameter p : decl.getParameters()) {
                Parameter param = new Parameter();
                param.name = p.getName();
                param.dataType = p.getDataType().getName();
                param.position = p.getPosition();
                param.mode = ParameterMode.from(p.getMode());
                event.parameters.add(param);
            }
        }

        return true;
    }

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

    private String findPreviousComment(int line, int col) {
        Token prevToken = null;
        for (Token token : lexer.getLexerBuffer()) {
            if ((token.getLine() == line) && (token.getColumn() == col) && (prevToken != null)
                    && (prevToken.getType() == ProgressTokenTypes.ML__COMMENT))
                return prevToken.getText();
            prevToken = token;
        }

        return null;
    }

    private List<String> findFirstComments(int line) {
        List<String> comments = new ArrayList<String>();
        for (Token token : lexer.getLexerBuffer()) {
            if (token.getLine() >= line)
                break;
            if (token.getType() == ProgressTokenTypes.ML__COMMENT)
                comments.add(token.getText());
        }

        return comments;
    }
}