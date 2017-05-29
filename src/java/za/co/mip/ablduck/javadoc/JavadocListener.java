/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package za.co.mip.ablduck;

import java.util.ArrayList;

public class JavadocListener extends JavadocParserBaseListener {
    ArrayList tags = new ArrayList();
    
    public ArrayList getTags() {
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
