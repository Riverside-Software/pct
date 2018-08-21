/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package za.co.mip.ablduck.javadoc;

import java.util.List;

import antlr.StringUtils;

import java.util.ArrayList;
import java.util.HashMap;

import za.co.mip.ablduck.javadoc.JavadocParser;
import za.co.mip.ablduck.javadoc.JavadocParserBaseListener;
import za.co.mip.ablduck.models.CompilationUnit;
import za.co.mip.ablduck.models.Deprecated;

public class JavadocListener extends JavadocParserBaseListener {
    private String comment = "";

    private Boolean inAuthor = false;
    private String author = "";

    private Boolean isInternal = null;

    private Boolean inDeprecated = false;
    private Deprecated deprecated = null;
    
    private Boolean inParam = false;
    private String paramName = "";
    private String paramComment = "";
    private HashMap<String, String> parameters;
    
    private Boolean inReturns = false;
    private String returns = "";

    public String getComment() {
        return comment;
    }

    public String getAuthor() {
        return author;
    }

    public Boolean isInternal() {
        return isInternal;
    }

    public Deprecated getDeprecated() {
        return deprecated;
    }
    
    public HashMap<String, String> getParameters() {
        return parameters;
    }
    
    public String getReturn() {
        return returns;
    }

    @Override
    public void enterDescriptionLine(JavadocParser.DescriptionLineContext ctx) {
        comment = comment + ctx.getText();
    }

    @Override
    public void enterBlockTagName(JavadocParser.BlockTagNameContext ctx) {
        switch (ctx.getText()) {
            case "internal" :
                isInternal = true;
                break;
            case "deprecated" :
                inDeprecated = true;
                deprecated = new Deprecated();
                break;
            case "author" :
                inAuthor = true;
                break;
            case "param" :
                inParam = true;
                paramName = "";
                paramComment = "";
                if (parameters == null)
                    parameters = new HashMap<>();
                break;
            case "return" :
                inReturns = true;
                break;
        }
    }

    @Override
    public void enterBlockTagTextElement(JavadocParser.BlockTagTextElementContext ctx) {
        if (inDeprecated) {
            if ("".equals(deprecated.version)) {
                deprecated.version = ctx.getText();
            } else {
                deprecated.text += ctx.getText();
            }
        }

        if (inAuthor) {
            author = author += ctx.getText();
        }
        
        if (inParam) {
            if ("".equals(paramName)) {
                paramName = ctx.getText();
            } else {
                paramComment += ctx.getText();
            }
        }
        
        if (inReturns) {
            returns = returns += ctx.getText();
        }
    }

    @Override
    public void exitBlockTag(JavadocParser.BlockTagContext ctx) {
        if (inDeprecated)
            inDeprecated = false;

        if (inAuthor) 
            inAuthor = false;
        
        if (inParam) {
            inParam = false;
            parameters.put(paramName, paramComment);
        }
            
        if (inReturns) 
            inReturns = false;
    }

    /*
     * @Override public void enterInlineTag(JavadocParser.InlineTagContext ctx) {
     * tags.add(ctx.getText()); }
     */
}
