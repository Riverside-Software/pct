/* -----------------------------------------------------------------------------
   file    :  prolint/rules/nameconv.p
   by      :  Carl Verbiest
   Credits : Jurjen Dijkstra, John Green, Breck Fairley ,
             this rule started as a copy varusage.p
   purpose :  scan for all identifiers, gather scope information and
              call a custom procedure to check the names against a coding convention
   -----------------------------------------------------------------------------

    Copyright (C) 2005 Carl Verbiest

    This file is part of Prolint.

    Prolint is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    Prolint is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Prolint; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
   --------------------------------------------------------------------------------- */

{prolint/core/ruleparams.i}
{prolint/rules/nameconv.i}

def var child               as inte no-undo.
def var grandchild          as inte no-undo.
def var greatgrandchild     as inte no-undo.
def var hCheckProc as handle no-undo.
def var checkProcName as char no-undo.
def buffer btt_procedure    for tt_procedure.

checkProcName = search("prolint/custom/rules/namecheck.p").
if checkProcName = ?
then checkProcName = search("prolint/rules/namecheck.p").
if checkProcName = ?
then return error. /* nothing to do */

/* load custom naming check and pass all parameters */
run value(checkProcName) persistent set hCheckProc(
    INPUT xreffile       ,
    INPUT listingfile    ,
    INPUT hLintSuper     ,
    INPUT hparser        ,
    INPUT hTopnode       ,
    INPUT compilationunit,
    INPUT severity       ,
    INPUT rule_id        ,
    INPUT pragma_number  ,
    INPUT ignoreAB       ,
    INPUT hpRulePersist
    ).

MAIN-BLK:
do on error undo MAIN-BLK, leave MAIN-BLK:

    assign
        child           = parserGetHandle()
        grandchild      = parserGetHandle()
        greatgrandchild = parserGetHandle().

    /* get the list of all functions and procedures */
    run ProcedureListGet in hLintSuper (output table tt_procedure).

    /* AIM: To build a complete list of tt_object (all variables and    */
    /*      parameters).                                                */

    /* STEP 1: Remove any procedures that are in a SUPER procedure,     */
    /*         within a HANDLE or EXTERNAL...                           */
    /*         Collect parameters for prototypes                        */
    /*         (IN SUPER, IN prochandle, EXTERNAL, ...).                */
    /*         We don't care at all about these parameters, so we will  */
    /*         delete the tt_objects anyway.                            */
    /*         We only use this step because we need to set the "already*/
    /*         looked at" attributes.                                   */

    for each tt_procedure
        where tt_procedure.prototype :

        /* create a list of variables and parameters, store them in tt_object */
        run searchNode            (
            input tt_procedure.startnode,
            input "BuildList":U,
            input "DEFINE":U ).

        empty temp-table tt_object.
    end.


    /* STEP 2: Build a list of all variables/parameters within this     */
    /*         compilation unit and its internal procedures.            */
    /*         First, get local vars and params in internal             */
    /*         procs/functions. Be sure to mark them as "already looked */
    /*         at" so they are skipped when querying the Program scope. */

    for each tt_procedure
        where not tt_procedure.prototype :

        /* create a list of variables and parameters, store them in tt_object */
        run searchNode            (
            input tt_procedure.startnode,
            input "BuildList":U,
            input "DEFINE":U ).

        /* if tt_procedure is a function, we must do some extra work to get parameters */
        if tt_procedure.proctype = "FUNCTION":U OR tt_procedure.proctype = "METHOD":U then
           run AddFunctionParameters(input tt_procedure.startnode).

        run AddToList (
            input RelativeFileName(parserGetNodeFilename(tt_procedure.startnode)),
            input parserGetNodeLine(tt_procedure.startNode),
            input tt_procedure.ProcType,
            input tt_procedure.ProcName,
            input "":U, /* NYI */
            input "":U,
            input "LOCAL":U,
            input "":U).
    end.

    /*         Second, add the objects at the program scope.            */
    /*         Because we have set pragma_number attributes we are      */
    /*         able to skip variabless and parameters at local scopes.  */

    release tt_procedure no-error. /* we must have not available */
    run searchNode            (
        input hTopNode,
        input "BuildList":U,
        input "DEFINE":U ).


    /* Inspect the top "Program_root" scope for remaining objects.      */
    /* This is very similar to the loop for a single tt_procedure, but  */
    /* we must be sure to skip all vars/params which already past the   */
    /* first loop. The pragma_number attribute assists us here.         */

    release tt_procedure no-error. /* we must have not available */

    /* We are done. Release all handles as we don't need kids anymore.  */
    parserReleaseHandle(child).
    parserReleaseHandle(grandchild).
    parserReleaseHandle(greatgrandchild).

    /* Start outputting the results */
    for each tt_object :
      run ObjectNameCheck in hCheckProc (buffer tt_Object).
    end.

end. /* MAIN-BLK */
delete procedure hCheckProc.


procedure BuildList :
/* purpose : recognize variable or parameter and add it to tt_object */

def input  param theNode        as inte no-undo.
def output param AbortSearch    as logi no-undo initial No.
def output param SearchChildren as logi no-undo.

def var varname     as char no-undo.
def var relName     as char no-undo.
def var vartype     as char no-undo.
def var nodetype    as char no-undo.
def var Datatype as char no-undo.
def var Scope as char no-undo.
def var ParamType   as char no-undo.


    /* set an attrib to remember we have been here before */
    parserAttrSet(theNode, pragma_number ,1).

    if available tt_procedure and tt_procedure.prototype then
        return.

    assign
      SearchChildren = No
      nodetype       = parserNodeFirstChild(theNode,child)
      ParamType      = "".

    do while nodetype <> "" :

        case nodetype :
            when "VARIABLE":U
                then assign vartype = 'VARIABLE':U.
            when "INPUT":U or
            when "OUTPUT":U or
            when "INPUTOUTPUT":U
                then assign ParamType = nodetype.
            when "PARAMETER":U
                then assign vartype = 'PARAMETER':U.
            when "ID":U
                then if varname = "":U
                     then assign varname = parserGetNodeText(child).
            when "BUFFER":U or
            when "TEMPTABLE":U
                then assign vartype = nodetype.
            when "TABLE":U
                then assign datatype = nodetype.
            when "RECORD_NAME":U
                then if relName = "":U
                     then assign relName = parserGetNodeText(child).
            when "AS":U
                then assign datatype = parserNodeFirstChild(child,grandchild).
            when "GLOBAL"
                then assign Scope = "GLOBALSHARED":U.
            when "SHARED"
                then if Scope = ""
                     then assign Scope = "SHARED":U.
        end case.

        nodetype = parserNodeNextSibling(child,child).
    end.
    if Scope = ""
    then Scope = if available tt_Procedure then "LOCAL":U else "MAIN".
    /* add to list tt_object */
    run AddToList (
        input RelativeFileName(parserGetNodeFilename(theNode)),
        input parserGetNodeLine(theNode),
        input vartype,
        input varname,
        input relName,
        input Datatype,
        input Scope,
        input ParamType ).

end procedure.

procedure BuildListFunction :
/* purpose : function variant of BuildList, paramtype already known, recognize parameter and add it to tt_object */

def input  param ParamType   as char no-undo.
def input  param theNode        as inte no-undo.
def output param AbortSearch    as logi no-undo initial No.
def output param SearchChildren as logi no-undo.

def var varname     as char no-undo.
def var vartype     as char no-undo.
def var relName     as char no-undo.
def var nodetype    as char no-undo.
def var Datatype as char no-undo.
def var Scope as char no-undo.


    /* set an attrib to remember we have been here before */
    parserAttrSet(theNode, pragma_number ,1).

    if available tt_procedure and tt_procedure.prototype then
        return.

    assign
      SearchChildren = No
      nodetype       = parserNodeFirstChild(theNode,child)
      .

    do while nodetype <> "" :

        case nodetype :
            when "ID":U
                then if varname = "":U
                then varname = parserGetNodeText(child).
            when "BUFFER":U or
            when "TABLE":U
                then datatype = nodetype.
            when "RECORD_NAME":U
                then if relName = "":U
                then relName = parserGetNodeText(child).
            when "AS":U
                then do:
                    datatype = parserNodeFirstChild(child,grandchild).
                end.
            when "GLOBAL" then Scope = "GLOBALSHARED":U.
            when "SHARED" then if Scope = "" then Scope = "SHARED":U.
        end case.

        nodetype = parserNodeNextSibling(child,child).
    end.
    if Scope = ""
    then Scope = if available tt_Procedure then "LOCAL":U else "MAIN".
    if vartype = "" then vartype = "PARAMETER".
    /* add to list tt_object */
    run AddToList (
        input RelativeFileName(parserGetNodeFilename(theNode)),
        input parserGetNodeLine(theNode),
        input vartype,
        input varname,
        input relName,
        input Datatype,
        input Scope,
        input ParamType ).

end procedure.

procedure AddToList :
/* purpose: create a new record tt_object */

def input param pSourceFile as char no-undo.
def input param pLine       as inte no-undo.
def input param pType       as char no-undo.
def input param pName       as char no-undo.
def input param prelName    as char no-undo.
def input param pDatatype   as char no-undo.
def input param pScope      as char no-undo.
def input param pParamType  as char no-undo.


   create tt_object.
   assign tt_object.sourcefile = pSourceFile
          tt_object.linenumber = pLine
          tt_object.ParamType  = pParamType
          tt_object.objType    = pType
          tt_object.objName    = pName
          tt_object.relName    = prelName
          tt_object.objDataType = pDatatype
          tt_object.objScope   = pScope
          tt_object.ProcRowid  = if available tt_procedure then rowid(tt_procedure) else ?
          tt_object.ProcName = if available tt_procedure then tt_procedure.procName else "".


end procedure.


procedure AddFunctionParameters :
/* purpose: add parameters for user-defined functions to tt_object */

def input param thenode as inte no-undo.

def var paramType as char no-undo.
def var paramID   as inte no-undo.
def var nodetype  as char no-undo.
def var lDataType as char no-undo.
def var lAbort as log  no-undo.
def var lSearchChild as log  no-undo.

    assign
        nodetype = parserNodeFirstChild(thenode, child)
        paramID  = parserGetHandle().

    /* First find the Parameter_list */
    do while nodetype <> "" and nodetype <> "Parameter_list":U:
        nodetype = parserNodeNextSibling(child,child).
    end.

    /* Now find each input, output, and inputoutput parameter node.
       We aren't interested in buffer parameter nodes. */
    if nodetype = "Parameter_list":U then
    do: /* have parameter list */
        nodetype = parserNodeFirstChild(child,child).
        do while nodetype <> "":
            paramType = nodetype.
            /* TOdo: decide if we should ignore output and inputoutput parameters */
            if lookup(paramType, "INPUT,OUTPUT,INPUTOUTPUT,BUFFER":U) > 0 then
            do:
                run BuildListFunction(paramType, child, output lAbort, output lSearchChild).
                /*
                /* The first child is either ID or table. We only want ID. */
                if parserNodeFirstChild(child, paramID) = "ID":U then

                    run AddToList (
                        input RelativeFileName(parserGetNodeFilename(paramID)),
                        input parserGetNodeLine(paramID),
                        input "parameter":U,
                        input parserGetNodeText(paramID),
                        input "", /* NYI */
                        input lDataType,
                        input "LOCAL":U,
                        input paramType ).
                */

            end.
            nodetype = parserNodeNextSibling(child,child).
        end.
    end.
    parserReleaseHandle(paramID).

end procedure.

