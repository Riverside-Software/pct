/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package za.co.mip.ablduck.javadoc;

import java.util.List;
import java.util.ArrayList;

import za.co.mip.ablduck.javadoc.JavadocParser;
import za.co.mip.ablduck.javadoc.JavadocParserBaseListener;

public class JavadocListener extends JavadocParserBaseListener {
    private List<String> tags = new ArrayList<>();

    public List<String> getTags() {
        return tags;
    }

    @Override
    public void enterBlockTag(JavadocParser.BlockTagContext ctx) {
        tags.add(ctx.getText());
    }
    @Override
    public void enterInlineTag(JavadocParser.InlineTagContext ctx) {
        tags.add(ctx.getText());
    }
}
