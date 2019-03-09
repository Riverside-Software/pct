/**
 * Copyright 2017-2018 MIP Holdings
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
import java.util.List;
import java.util.Map;

import eu.rssw.pct.oedoc.ProcedureDocumentationVisitor;
import eu.rssw.rcode.AccessModifier;
import eu.rssw.rcode.Dataset;
import eu.rssw.rcode.Event;
import eu.rssw.rcode.Function;
import eu.rssw.rcode.Procedure;
import eu.rssw.rcode.ProcedureCompilationUnit;
import eu.rssw.rcode.TempTable;
import eu.rssw.rcode.Using;
import za.co.mip.ablduck.models.CompilationUnit;
import za.co.mip.ablduck.models.Member;
import za.co.mip.ablduck.models.Parameter;
import za.co.mip.ablduck.models.Return;

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
        cu.name = procedureFilename.replace('-', '_').replace("\\", "/"); // Unfortunately - is used for seperating
                                                       // file-member etc in the url
        cu.icon = "procedure";

        String c = null;
        if (!procedureUnit.procComment.isEmpty()) {
            for (int i = procedureUnit.procComment.size() - 1; i >= 0; i--) {
                c = procedureUnit.procComment.get(i); // Assuming last comment will always be the
                                                      // class
                                                      // comment, will need to cater for license
                                                      // later
                if (c != null)
                    break;
            }
        }

        Comment procComment = parseComment(c);

        cu.comment = procComment.getComment();
        cu.author = procComment.getAuthor();

        cu.meta.isInternal = procComment.isInternal();
        cu.meta.isDeprecated = procComment.getDeprecated();

        cu.members = new ArrayList<>();

        // Main Parameters
        if (!procedureUnit.mainProcedure.parameters.isEmpty()) {
            cu.parameters = addParameters(procedureUnit.mainProcedure.parameters,
                    procComment.getParameters());
        }

        // Procedure
        for (Procedure procedure : procedureUnit.procedures) {
            Member member = new Member();

            member.id = "procedure-" + procedure.procedureName;
            member.name = procedure.procedureName;
            member.tagname = "procedure";

            Comment procedureComment = parseComment(procedure.procedureComment);

            member.comment = procedureComment.getComment();

            member.meta.isPrivate = (procedure.isPrivate ? true : null);
            member.meta.isInternal = procedureComment.isInternal();
            member.meta.isDeprecated = procedureComment.getDeprecated();

            member.parameters = addParameters(procedure.parameters,
                    procedureComment.getParameters());

            cu.members.add(member);
        }

        // Function
        for (Function function : procedureUnit.functions) {
            Member member = new Member();

            member.id = "function-" + function.functionName;
            member.name = function.functionName;
            member.tagname = "function";

            Comment functionComment = parseComment(function.functionComment);

            member.comment = functionComment.getComment();

            member.meta.isPrivate = (function.isPrivate ? true : null);
            member.meta.isInternal = functionComment.isInternal();
            member.meta.isDeprecated = functionComment.getDeprecated();

            member.parameters = addParameters(function.parameters, functionComment.getParameters());

            member.returns = new Return();
            member.returns.comment = functionComment.getReturn();
            member.returns.datatype = function.returnType;

            cu.members.add(member);
        }

        // Temp-Tables
        for (TempTable tempTable : procedureUnit.tts) {
            Member member = new Member();

            member.id = "temptable-" + tempTable.name;
            member.name = tempTable.name;
            member.tagname = "temptable";
            member.definition = tempTable.aceText.replace("\n", "<br>&nbsp;&nbsp;&nbsp;&nbsp;");

            Comment tempTableComment = parseComment(tempTable.comment);

            member.comment = tempTableComment.getComment();
            member.meta.isInternal = tempTableComment.isInternal();
            member.meta.isDeprecated = tempTableComment.getDeprecated();

            member.meta.isPrivate = (tempTable.modifier == AccessModifier.PRIVATE ? true : null);
            member.meta.isProtected = (tempTable.modifier == AccessModifier.PROTECTED
                    ? true
                    : null);
            member.meta.isStatic = (tempTable.modifier == AccessModifier.STATIC ? true : null);
            member.meta.isNew = (tempTable.isNew ? true : null);
            member.meta.isGlobal = (tempTable.isGlobal ? true : null);
            member.meta.isShared = (tempTable.isShared ? true : null);
            member.meta.isNoUndo = (tempTable.noUndo ? true : null);

            cu.members.add(member);
        }

        // Datasets
        for (Dataset dataset : procedureUnit.dss) {
            Member member = new Member();

            member.id = "dataset-" + dataset.name;
            member.name = dataset.name;
            member.tagname = "dataset";
            member.definition = dataset.aceText.replace("\n", "<br>&nbsp;&nbsp;&nbsp;&nbsp;");

            Comment datasetComment = parseComment(dataset.comment);

            member.comment = datasetComment.getComment();
            member.meta.isInternal = datasetComment.isInternal();
            member.meta.isDeprecated = datasetComment.getDeprecated();

            member.meta.isPrivate = (dataset.modifier == AccessModifier.PRIVATE ? true : null);
            member.meta.isProtected = (dataset.modifier == AccessModifier.PROTECTED ? true : null);
            member.meta.isStatic = (dataset.modifier == AccessModifier.STATIC ? true : null);
            member.meta.isNew = (dataset.isNew ? true : null);
            member.meta.isShared = (dataset.isShared ? true : null);

            cu.members.add(member);
        }

        // Events
        for (Event event : procedureUnit.events) {
            Member member = new Member();

            member.id = "event-" + event.eventName;
            member.name = event.eventName;
            member.tagname = "event";

            Comment eventComment = parseComment(event.eventComment);

            member.comment = eventComment.getComment();

            member.meta.isPrivate = (event.modifier == AccessModifier.PRIVATE ? true : null);
            member.meta.isProtected = (event.modifier == AccessModifier.PROTECTED ? true : null);
            member.meta.isStatic = (event.modifier == AccessModifier.STATIC ? true : null);
            member.meta.isAbstract = (event.isAbstract ? true : null);
            member.meta.isOverride = (event.isOverride ? true : null);
            member.meta.isInternal = eventComment.isInternal();
            member.meta.isDeprecated = eventComment.getDeprecated();

            member.returns = new Return();
            member.returns.comment = eventComment.getReturn();
            member.returns.datatype = "VOID";

            member.parameters = addParameters(event.parameters, eventComment.getParameters());

            cu.members.add(member);
        }

        return cu;
    }

    public Comment parseComment(String comment) {

        Comment commentParser = new Comment();

        commentParser.parseComment(comment);

        return commentParser;
    }

    public List<Parameter> addParameters(List<eu.rssw.rcode.Parameter> parameters,
            Map<String, String> parameterComments) {
        List<Parameter> memberParams = null;

        if (!parameters.isEmpty()) {
            memberParams = new ArrayList<>();
            for (eu.rssw.rcode.Parameter param : parameters) {
                Parameter parameter = new Parameter();

                parameter.name = param.name;
                parameter.datatype = param.dataType;
                parameter.mode = (param.mode == null ? "" : param.mode.toString());

                if (parameterComments != null)
                    parameter.comment = parameterComments.get(parameter.name);
                else
                    parameter.comment = "";

                memberParams.add(parameter);
            }
        }

        return memberParams;
    }

}
