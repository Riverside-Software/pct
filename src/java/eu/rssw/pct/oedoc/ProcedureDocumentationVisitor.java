package eu.rssw.pct.oedoc;

import java.io.File;
import java.io.IOException;

import javax.xml.bind.JAXBException;

import com.openedge.pdt.core.ast.ASTNode;
import com.openedge.pdt.core.ast.ProcedureDeclaration;
import com.openedge.pdt.core.ast.ProgressParserTokenTypes;
import com.openedge.pdt.core.ast.ProgressTokenTypes;
import com.openedge.pdt.core.ast.model.IASTNode;
import com.openedge.pdt.core.ast.visitor.ASTVisitor;

import eu.rssw.rcode.Parameter;
import eu.rssw.rcode.ParameterMode;
import eu.rssw.rcode.Procedure;
import eu.rssw.rcode.ProcedureCompilationUnit;

public class ProcedureDocumentationVisitor extends ASTVisitor {
    private ProcedureCompilationUnit cu = new ProcedureCompilationUnit();

    public void toXML(File out) throws IOException, JAXBException {
        cu.toXML(out);
    }

//    @Override
//    public boolean visit(IStatement node) {
//        if (node.getStatementType() == ProgressParserTokenTypes.FIND) {
//            Statement smt = (Statement) node;
//            for (IASTNode iter : smt.getChildren()) {
//                for (IASTNode zz : iter.getChildren()) {
//                    for (IASTNode zzz : zz.getChildren()) {
//
//                    }
//
//                }
//            }
//        }
//        return super.visit(node);
//    }

    @Override
    public boolean visit(ProcedureDeclaration decl) {
        if (decl == null)
            return true;

        Procedure method = new Procedure();
        method.procedureName = decl.getName();
        method.signature = decl.getSignature();
        method.procedureComment = findPreviousComment(decl);
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

    /**
     * Renvoie le *dernier* commentaire
     * 
     * @param node
     * @return
     */
    public static String findPreviousComment(ASTNode node) {
      if ((node.getHiddenPrevious() != null) && (node.getHiddenPrevious().getType() == ProgressTokenTypes.ML__COMMENT)) {
        return node.getHiddenPrevious().getText();
      }
      IASTNode n = node.getPrevSibling();
      while ((n != null) && (n.getType() == ProgressParserTokenTypes.ANNOTATION)) {
        if ((n.getHiddenPrevious() != null) && (n.getHiddenPrevious().getType() == ProgressTokenTypes.ML__COMMENT))
          return n.getHiddenPrevious().getText();
        n = n.getPrevSibling();
      }
      return null;
    }

}