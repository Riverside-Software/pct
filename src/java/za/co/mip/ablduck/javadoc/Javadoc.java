/**
 * Copyright 2017 MIP Holdings
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
package za.co.mip.ablduck.javadoc;

import java.util.List;

import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.ParseTreeWalker;

import za.co.mip.ablduck.javadoc.JavadocLexer;
import za.co.mip.ablduck.javadoc.JavadocParser;

public class Javadoc {
    
    public static List<String> parseComment(String comment, String source){
        
        JavadocLexer lexer = new JavadocLexer(CharStreams.fromString(comment, source));
        lexer.removeErrorListeners();
        lexer.addErrorListener(DescriptiveErrorListener.INSTANCE);
        
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        
        JavadocParser parser = new JavadocParser(tokens);
        parser.removeErrorListeners();
        parser.addErrorListener(DescriptiveErrorListener.INSTANCE);
        
        JavadocParser.DocumentationContext documentation = parser.documentation();
        
        ParseTreeWalker walker = new ParseTreeWalker();
        JavadocListener listener = new JavadocListener();
        walker.walk(listener, documentation);
               
        return listener.getTags();
    }
}
