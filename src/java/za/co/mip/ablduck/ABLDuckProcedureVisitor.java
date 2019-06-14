/**
 * Copyright 2017-2019 MIP Holdings
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
package za.co.mip.ablduck;

import java.util.ArrayList;

import eu.rssw.pct.oedoc.ProcedureDocumentationVisitor;
import eu.rssw.rcode.Dataset;
import eu.rssw.rcode.Function;
import eu.rssw.rcode.Procedure;
import eu.rssw.rcode.ProcedureCompilationUnit;
import eu.rssw.rcode.TempTable;
import eu.rssw.rcode.Using;
import za.co.mip.ablduck.models.CompilationUnit;

public class ABLDuckProcedureVisitor extends ProcedureDocumentationVisitor {
    private String procedureFilename;

    public ABLDuckProcedureVisitor(String filename) {
        this.procedureFilename = filename;
    }

    public CompilationUnit getCompilationUnit() {
        CompilationUnit cu = new CompilationUnit();
        ProcedureCompilationUnit procedureUnit = getProcedureCompilationUnit();

        cu.files = new ArrayList<String>();
        cu.uses = new ArrayList<String>();
        for (Using using : procedureUnit.usings) {
            cu.uses.add(using.name);
        }

        String procedureId = procedureFilename.substring(0, procedureFilename.indexOf('.'))
                .replace('/', '_');
        cu.id = "procedure-" + procedureId;
        cu.tagname = "procedure";
        // Unfortunately - is used for seperating file-member etc in the url
        cu.name = procedureFilename.replace('-', '_').replace("\\", "/");
        cu.icon = "procedure";

        String c = null;
        if (!procedureUnit.procComment.isEmpty()) {
            for (int i = procedureUnit.procComment.size() - 1; i >= 0; i--) {
                // Assuming last comment will always be the class
                // comment, will need to cater for license later
                c = procedureUnit.procComment.get(i);
                if (c != null)
                    break;
            }
        }

        Comment procComment = ABLDuckClassVisitor.parseComment(c);
        cu.comment = procComment.getComment();
        cu.author = procComment.getAuthor();
        cu.meta.isInternal = procComment.isInternal();
        cu.meta.isDeprecated = procComment.getDeprecated();

        cu.members = new ArrayList<>();

        // Main Parameters
        if (!procedureUnit.mainProcedure.parameters.isEmpty()) {
            cu.parameters = ABLDuckClassVisitor.addParameters(
                    procedureUnit.mainProcedure.parameters, procComment.getParameters());
        }

        // Procedure
        for (Procedure procedure : procedureUnit.procedures) {
            cu.members.add(ABLDuckClassVisitor.readProcedure(procedure));
        }

        // Function
        for (Function function : procedureUnit.functions) {
            cu.members.add(ABLDuckClassVisitor.readFunction(function));
        }

        // Temp-Tables
        for (TempTable tempTable : procedureUnit.tts) {
            cu.members.add(ABLDuckClassVisitor.readTempTable(tempTable));
        }

        // Datasets
        for (Dataset dataset : procedureUnit.dss) {
            cu.members.add(ABLDuckClassVisitor.readDataset(dataset));
        }

        return cu;
    }

}
