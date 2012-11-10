package eu.rssw.pct.oedoc;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.xml.bind.JAXBException;

import antlr.Token;

import com.openedge.pdt.core.ast.CustomSimpleToken;
import com.openedge.pdt.core.ast.ProcedureDeclaration;
import com.openedge.pdt.core.ast.ProgressParser;
import com.openedge.pdt.core.ast.ProgressParserTokenTypes;
import com.openedge.pdt.core.ast.ProgressTokenTypes;
import com.openedge.pdt.core.ast.Statement;
import com.openedge.pdt.core.ast.model.IASTNode;
import com.openedge.pdt.core.ast.model.IStatement;
import com.openedge.pdt.core.ast.visitor.ASTVisitor;

import eu.rssw.parser.OELexer;

public class ProcedureDocumentationVisitor extends ASTVisitor {
    private OELexer lexer;
    private ProgressParser parser;
    private ProcedureCompilationUnit cu = new ProcedureCompilationUnit();

    public ProcedureDocumentationVisitor(OELexer lexer, ProgressParser parser) {
        this.lexer = lexer;
        this.parser = parser;
    }

    public void toXML(File out) throws IOException, JAXBException {
        cu.toXML(out);
    }

    @Override
    public boolean visit(IStatement node) {
        if (node.getStatementType() == ProgressParserTokenTypes.FIND) {
            System.out.println("un stmt " + node.getClass().getName());
            Statement smt = (Statement) node;
//            System.out.println("next : " + smt.getNextSibling());
            for (IASTNode iter : smt.getChildren()) {
                System.out.println(" C : " + iter);
                for (IASTNode zz : iter.getChildren()) {
                    System.out.println(" CC : " + zz);
                    for (IASTNode zzz : zz.getChildren()) {
                        System.out.println(" CCC : " + zzz);
                        
                    }
                    
                }
            }
        }
        return super.visit(node);
    }

    @Override
    public boolean visit(ProcedureDeclaration decl) {
        if (decl == null)
            return true;

        Procedure method = new Procedure();
        method.procedureName = decl.getName();
        method.signature = decl.getSignature();
        method.modifier = AccessModifier.from(decl.getAccessModifier());
        method.procedureComment = findPreviousComment(((CustomSimpleToken) decl
                .getFirstChildRealToken()).getLexerToken());
        cu.procedures.add(method);

        if (decl.getParameters() != null) {
            for (com.openedge.pdt.core.ast.model.IParameter p : decl.getParameters()) {
                Parameter param = new Parameter();
                param.name = p.getName();
                if (p.getDataType() == null) {
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
    /*
     * public boolean visit(TypeDeclaration decl) { cu.packageName = decl.getPackageName();
     * cu.className = decl.getClassName(); cu.isInterface = decl.isInterface(); cu.isAbstract =
     * decl.isAbstract(); cu.isFinal = decl.isFinal(); cu.classComment
     * .addAll(findFirstComments(((CustomSimpleToken) decl.getFirstChildRealToken())
     * .getLexerToken()));
     * 
     * if (decl.getInherits() != null) cu.inherits = decl.getInherits().getQualifiedName(); if
     * (decl.getImplements() != null) { for (TypeName typeName : decl.getImplements()) {
     * cu.interfaces.add(typeName.getQualifiedName()); } }
     * 
     * return true; }
     * 
     * public boolean visit(PropertyDeclaration decl) { Property prop = new Property(); prop.name =
     * decl.getName(); prop.isAbstract = decl.isAbstract(); prop.dataType =
     * decl.getDataType().getName(); prop.extent = decl.getExtent(); prop.modifier =
     * AccessModifier.from(decl.getAccessModifier()); prop.propertyComment =
     * findPreviousComment(((CustomSimpleToken) decl .getFirstChildRealToken()).getLexerToken());
     * cu.properties.add(prop);
     * 
     * return true; }
     * 
     * public boolean visit(PropertyMethod decl) { IASTNode node = decl.getParent(); if (node
     * instanceof PropertyDeclaration) { String propName = ((PropertyDeclaration) node).getName();
     * Property prop = null; for (Property p : cu.properties) { if
     * (p.name.equalsIgnoreCase(propName)) prop = p; } if (prop != null) { if
     * (decl.getName().equalsIgnoreCase("get")) { prop.getModifier =
     * GetSetModifier.from(decl.getAccessModifier()); } else if
     * (decl.getName().equalsIgnoreCase("set")) { prop.setModifier =
     * GetSetModifier.from(decl.getAccessModifier()); } } }
     * 
     * return true; }
     * 
     * public boolean visit(ConstructorDeclaration decl) { if (decl == null) return true;
     * Constructor constr = new Constructor(); constr.signature = decl.getSignature(); if
     * (decl.isStatic()) constr.modifier = AccessModifier.STATIC; else constr.modifier =
     * AccessModifier.from(decl.getAccessModifier()); constr.constrComment =
     * findPreviousComment(((CustomSimpleToken) decl .getFirstChildRealToken()).getLexerToken());
     * 
     * if (decl.getParameters() != null) { for (com.openedge.pdt.core.ast.model.IParameter p :
     * decl.getParameters()) { Parameter param = new Parameter(); param.name = p.getName();
     * param.dataType = p.getDataType().getName(); param.position = p.getPosition(); param.mode =
     * ParameterMode.from(p.getMode()); constr.parameters.add(param); } }
     * cu.constructors.add(constr);
     * 
     * return true; }
     * 
     * public boolean visit(MethodDeclaration decl) { if (decl == null) return true;
     * 
     * Method method = new Method(); method.methodName = decl.getName(); method.signature =
     * decl.getSignature(); method.modifier = AccessModifier.from(decl.getAccessModifier());
     * method.returnType = decl.getReturnType(); method.isStatic = decl.isStatic();
     * method.methodComment = findPreviousComment(((CustomSimpleToken) decl
     * .getFirstChildRealToken()).getLexerToken()); cu.methods.add(method);
     * 
     * if (decl.getParameters() != null) { for (com.openedge.pdt.core.ast.model.IParameter p :
     * decl.getParameters()) { Parameter param = new Parameter(); param.name = p.getName(); if
     * (p.getDataType() == null) { System.out.println("Class " + cu.className + " -- Method " +
     * method.methodName + " -- Param " + param.name + " -- Null dataType"); param.dataType = ""; }
     * else { param.dataType = p.getDataType().getName(); } param.position = p.getPosition();
     * param.mode = ParameterMode.from(p.getMode()); method.parameters.add(param); } }
     * 
     * return true; }
     * 
     * public boolean visit(EventDeclaration decl) { if (decl == null) return true;
     * 
     * Event event = new Event(); event.eventName = decl.getName(); event.signature =
     * decl.getSignature(); event.modifier = AccessModifier.from(decl.getAccessModifier());
     * event.isStatic = decl.isStatic(); event.isAbstract = decl.isAbstract(); if
     * (decl.isDelegate()) event.delegateName = decl.getDelegateName(); event.eventComment =
     * findPreviousComment(((CustomSimpleToken) decl.getFirstChildRealToken()) .getLexerToken());
     * cu.events.add(event);
     * 
     * if (decl.getParameters() != null) { for (com.openedge.pdt.core.ast.model.IParameter p :
     * decl.getParameters()) { Parameter param = new Parameter(); param.name = p.getName();
     * param.dataType = p.getDataType().getName(); param.position = p.getPosition(); param.mode =
     * ParameterMode.from(p.getMode()); event.parameters.add(param); } }
     * 
     * return true; }
     * 
     * public boolean visit(UsingDeclaration decl) { Using using = new Using(); using.name =
     * decl.getName();
     * 
     * if (decl.getChild(ProgressParserTokenTypes.FROM) == null) using.type = UsingType.NONE; else {
     * if (decl.getChild(ProgressParserTokenTypes.PROPATH) != null) using.type = UsingType.PROPATH;
     * else if (decl.getChild(ProgressParserTokenTypes.ASSEMBLY) != null) using.type =
     * UsingType.ASSEMBLY; else using.type = UsingType.NONE; } cu.usings.add(using);
     * 
     * return true; }
     */

    private String findPreviousComment(Token t) {
        Token prevToken = null;
        for (Token token : lexer.getLexerBuffer()) {
            if ((token == t) && (prevToken != null)
                    && (prevToken.getType() == ProgressTokenTypes.ML__COMMENT))
                return prevToken.getText();
            prevToken = token;
        }

        return null;
    }

    private List<String> findFirstComments(Token t) {
        List<String> comments = new ArrayList<String>();
        for (Token token : lexer.getLexerBuffer()) {
            if (token == t)
                break;
            if (token.getType() == ProgressTokenTypes.ML__COMMENT)
                comments.add(token.getText());
        }

        return comments;
    }
}